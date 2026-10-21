-- 0001_foundation
-- Platform-wide foundations: private schema, immutable audit log, platform staff.
-- Rules: docs/ARCHITECTURE.md §6.

-- ---------------------------------------------------------------------------
-- private schema: SECURITY DEFINER helpers, not exposed through the Data API.
-- ---------------------------------------------------------------------------
create schema if not exists private;

revoke all on schema private from public;
grant usage on schema private to authenticated, service_role;

-- Functions in private are not executable unless granted explicitly.
alter default privileges in schema private revoke execute on functions from public;

-- ---------------------------------------------------------------------------
-- platform_staff
-- owner: admin
-- Users allowed into the admin panel. Managed only by the backend.
-- ---------------------------------------------------------------------------
create table public.platform_staff (
  user_id    uuid primary key references auth.users (id) on delete cascade,
  role       text not null check (role in ('admin', 'moderator', 'support')),
  created_at timestamptz not null default now(),
  created_by uuid references auth.users (id) on delete set null
);

comment on table public.platform_staff is
  'owner: admin. Platform team members and their admin panel role.';

alter table public.platform_staff enable row level security;

revoke all on public.platform_staff from anon, authenticated;
grant select on public.platform_staff to authenticated;

-- A user may read only their own staff row (admin panel sign-in check).
create policy platform_staff_select_own
  on public.platform_staff
  for select
  to authenticated
  using (user_id = (select auth.uid()));

-- ---------------------------------------------------------------------------
-- private.is_platform_staff
-- True when the current user is staff, optionally limited to given roles.
-- ---------------------------------------------------------------------------
create function private.is_platform_staff(roles text[] default null)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.platform_staff s
    where s.user_id = (select auth.uid())
      and (roles is null or s.role = any (roles))
  );
$$;

revoke all on function private.is_platform_staff(text[]) from public;
grant execute on function private.is_platform_staff(text[]) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- audit_log
-- owner: core
-- Append-only record of role, sanction, subscription and admin actions.
-- Written only by the backend (service role). Never updated or deleted.
-- Holds no personal data besides user ids (KVKK).
-- ---------------------------------------------------------------------------
create table public.audit_log (
  id          bigint generated always as identity primary key,
  occurred_at timestamptz not null default now(),
  actor_id    uuid,
  actor_kind  text not null check (actor_kind in ('user', 'staff', 'system')),
  action      text not null check (action ~ '^[a-z_]+(\.[a-z_]+)+$'),
  target_type text not null,
  target_id   text,
  group_id    uuid,
  data        jsonb not null default '{}'::jsonb,
  ip          inet,
  constraint audit_log_actor_required check (actor_kind = 'system' or actor_id is not null)
);

comment on table public.audit_log is
  'owner: core. Immutable audit trail. Insert via backend only; update/delete/truncate are blocked.';
comment on column public.audit_log.actor_id is
  'auth.users id. Intentionally no foreign key so account deletion never rewrites the log.';
comment on column public.audit_log.action is
  'Dotted action code, e.g. group.role_assigned, member.banned, subscription.activated.';

create index audit_log_occurred_at_idx on public.audit_log (occurred_at desc);
create index audit_log_actor_idx on public.audit_log (actor_id, occurred_at desc);
create index audit_log_group_idx on public.audit_log (group_id, occurred_at desc) where group_id is not null;
create index audit_log_target_idx on public.audit_log (target_type, target_id);

alter table public.audit_log enable row level security;

revoke all on public.audit_log from anon, authenticated;
grant select on public.audit_log to authenticated;

create policy audit_log_select_staff
  on public.audit_log
  for select
  to authenticated
  using ((select private.is_platform_staff()));

-- Immutability applies to every role, including service_role and postgres.
create function private.audit_log_block_change()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception 'audit_log is append-only: % is not allowed', tg_op
    using errcode = 'insufficient_privilege';
end;
$$;

create trigger audit_log_no_update_delete
  before update or delete on public.audit_log
  for each row execute function private.audit_log_block_change();

create trigger audit_log_no_truncate
  before truncate on public.audit_log
  for each statement execute function private.audit_log_block_change();
