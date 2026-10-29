-- 0051: invite links — a shareable, expiring link that lets anyone who opens it join the group directly
-- (docs/ARCHITECTURE.md §3b, Davet bağlantısı; user decision 2026-10-29).

-- ---------------------------------------------------------------------------
-- Tables (owner: groups; the backend writes, triggers check the rules again)
-- ---------------------------------------------------------------------------
create table public.group_invite_links (
  id          uuid primary key default gen_random_uuid(),
  group_id    uuid not null references public.groups (id) on delete cascade,
  code        text not null unique check (code ~ '^[a-hj-km-np-z2-9]{12}$'),
  created_by  uuid references public.profiles (id) on delete set null,
  expires_at  timestamptz not null,
  max_uses    int check (max_uses between 1 and 1000),
  use_count   int not null default 0 check (use_count >= 0),
  revoked_at  timestamptz,
  revoked_by  uuid references public.profiles (id) on delete set null,
  created_at  timestamptz not null default now(),
  constraint group_invite_links_uses_within_limit check (max_uses is null or use_count <= max_uses)
);

comment on table public.group_invite_links is
  'owner: groups. Shareable invitations; anyone with a valid code joins directly (docs/ARCHITECTURE.md §3b).';

create index group_invite_links_group_idx on public.group_invite_links (group_id, created_at desc);

create table public.group_invite_link_uses (
  id       bigint generated always as identity primary key,
  link_id  uuid not null references public.group_invite_links (id) on delete cascade,
  user_id  uuid not null references public.profiles (id) on delete cascade,
  used_at  timestamptz not null default now()
);

comment on table public.group_invite_link_uses is 'owner: groups. Who joined with which link; the link''s use_count follows it.';

create index group_invite_link_uses_link_idx on public.group_invite_link_uses (link_id);
create index group_invite_link_uses_user_idx on public.group_invite_link_uses (user_id);

alter table public.group_invite_links enable row level security;
alter table public.group_invite_link_uses enable row level security;

revoke all on public.group_invite_links, public.group_invite_link_uses from anon, authenticated;
grant select on public.group_invite_links, public.group_invite_link_uses to authenticated;

create policy group_invite_links_select_inviters_or_staff on public.group_invite_links for select to authenticated
  using ((select private.has_group_permission(group_id, 'members.invite')) or (select private.is_platform_staff()));

create policy group_invite_link_uses_select_inviters_or_staff on public.group_invite_link_uses for select to authenticated
  using (exists (select 1 from public.group_invite_links l
                 where l.id = link_id and private.has_group_permission(l.group_id, 'members.invite'))
         or (select private.is_platform_staff()));

-- A link that lets someone in right now.
create function private.invite_link_valid(l public.group_invite_links)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select l.revoked_at is null and l.expires_at > now() and (l.max_uses is null or l.use_count < l.max_uses)
    and exists (select 1 from public.groups g where g.id = l.group_id and g.status = 'active');
$$;

revoke all on function private.invite_link_valid(public.group_invite_links) from public;
grant execute on function private.invite_link_valid(public.group_invite_links) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- Guards
-- ---------------------------------------------------------------------------
create function private.group_invite_links_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
begin
  if tg_op = 'DELETE' then
    -- Only the cascade from a deleted group.
    if exists (select 1 from public.groups g where g.id = old.group_id) then
      perform private.raise_group_rule('invite_link_delete_forbidden');
    end if;
    return old;
  end if;

  if tg_op = 'INSERT' then
    if actor is null or new.created_by is distinct from actor or not private.has_group_permission(new.group_id, 'members.invite') then
      perform private.raise_group_rule('invitation_forbidden');
    end if;
    if new.expires_at <= now() or new.expires_at > now() + interval '30 days'
       or new.use_count <> 0 or new.revoked_at is not null or new.revoked_by is not null then
      perform private.raise_group_rule('invite_link_invalid');
    end if;
    if (select count(*) from public.group_invite_links l
        where l.group_id = new.group_id and private.invite_link_valid(l)) >= 20 then
      perform private.raise_group_rule('invite_link_limit_reached');
    end if;
    new.created_at := now();
    return new;
  end if;

  if (new.id, new.group_id, new.code, new.expires_at, new.max_uses, new.created_at)
     is distinct from (old.id, old.group_id, old.code, old.expires_at, old.max_uses, old.created_at)
     -- An account going away nulls created_by.
     or (new.created_by is distinct from old.created_by and new.created_by is not null) then
    perform private.raise_group_rule('invite_link_immutable');
  end if;
  -- The counter follows the uses table.
  if new.use_count is distinct from old.use_count
     and new.use_count <> (select count(*) from public.group_invite_link_uses u where u.link_id = new.id) then
    perform private.raise_group_rule('invite_link_immutable');
  end if;
  if new.revoked_at is distinct from old.revoked_at or new.revoked_by is distinct from old.revoked_by then
    if new.revoked_by is null and old.revoked_by is not null and new.revoked_at is not distinct from old.revoked_at then
      return new; -- the revoker's account went away
    end if;
    if old.revoked_at is not null or new.revoked_at is null or new.revoked_by is distinct from actor
       or not (private.has_group_permission(new.group_id, 'members.invite') or private.is_platform_staff(array['admin', 'moderator'])) then
      perform private.raise_group_rule('invitation_forbidden');
    end if;
    new.revoked_at := now();
  end if;
  return new;
end;
$$;

create trigger group_invite_links_guard
  before insert or update or delete on public.group_invite_links
  for each row execute function private.group_invite_links_guard();

create function private.group_invite_link_uses_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  l public.group_invite_links;
begin
  if tg_op = 'DELETE' then
    -- Only cascades (deleted link, group or account).
    if exists (select 1 from public.group_invite_links x where x.id = old.link_id)
       and exists (select 1 from public.profiles p where p.id = old.user_id) then
      perform private.raise_group_rule('invite_link_immutable');
    end if;
    return old;
  end if;
  if tg_op = 'UPDATE' then
    perform private.raise_group_rule('invite_link_immutable');
  end if;

  select * into l from public.group_invite_links where id = new.link_id for update;
  if (select auth.uid()) is distinct from new.user_id or not private.invite_link_valid(l) then
    perform private.raise_group_rule('invite_link_invalid');
  end if;
  new.used_at := now();
  return new;
end;
$$;

create trigger group_invite_link_uses_guard
  before insert or update or delete on public.group_invite_link_uses
  for each row execute function private.group_invite_link_uses_guard();

create function private.group_invite_link_uses_count()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.group_invite_links set use_count = use_count + 1 where id = new.link_id;
  return null;
end;
$$;

revoke all on function private.group_invite_link_uses_count() from public;

create trigger group_invite_link_uses_count
  after insert on public.group_invite_link_uses
  for each row execute function private.group_invite_link_uses_count();

-- As in 0012, plus joining with a link used in this transaction.
create or replace function private.group_members_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
  g public.groups;
begin
  if tg_op = 'INSERT' then
    select * into g from public.groups where id = new.group_id;
    if actor is null or g.id is null then
      perform private.raise_group_rule('join_not_allowed');
    end if;
    if g.status <> 'active' then
      perform private.raise_group_rule('group_not_active');
    end if;
    if not private.is_account_active(new.user_id) then
      perform private.raise_group_rule('account_not_active');
    end if;

    if new.user_id = g.owner_id then
      -- The owner joins their own group while creating it.
      if actor <> g.owner_id then
        perform private.raise_group_rule('join_not_allowed');
      end if;
    elsif actor = new.user_id then
      if g.join_policy <> 'open' and not exists (
        select 1 from public.group_invitations i where i.group_id = new.group_id and i.user_id = new.user_id
      ) and not exists (
        select 1 from public.group_invite_link_uses u join public.group_invite_links l on l.id = u.link_id
        where l.group_id = new.group_id and u.user_id = new.user_id and u.used_at = now()
      ) then
        perform private.raise_group_rule('join_not_allowed');
      end if;
    elsif not (
      private.has_group_permission(new.group_id, 'members.approve')
      and exists (select 1 from public.group_join_requests r where r.group_id = new.group_id and r.user_id = new.user_id)
    ) then
      perform private.raise_group_rule('join_not_allowed');
    end if;

    new.joined_at := now();
    return new;
  end if;

  -- Cascades from a deleted group or profile are always allowed.
  if not exists (select 1 from public.groups g2 where g2.id = old.group_id)
     or not exists (select 1 from public.profiles p where p.id = old.user_id) then
    return old;
  end if;
  if exists (select 1 from public.groups g2 where g2.id = old.group_id and g2.owner_id = old.user_id) then
    perform private.raise_group_rule('owner_cannot_leave');
  end if;
  -- Removing other members is a sanction (§3e): kick or ban inserted in this transaction.
  if actor is distinct from old.user_id and not exists (
    select 1 from public.sanctions s
    where s.group_id = old.group_id and s.user_id = old.user_id and s.type in ('kick', 'ban')
      and not s.interim and s.created_at = now()
  ) then
    perform private.raise_group_rule('leave_not_allowed');
  end if;
  return old;
end;
$$;

-- ---------------------------------------------------------------------------
-- Preview: what anyone holding the code may see (the group is public anyway)
-- ---------------------------------------------------------------------------
create function private.invite_link_preview(link_code text)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'valid', private.invite_link_valid(l),
    'expires_at', l.expires_at,
    'group', jsonb_build_object(
      'id', g.id, 'handle', g.handle, 'name', g.name, 'category_slug', g.category_slug, 'about', g.about,
      'logo_path', g.logo_path, 'cover_path', g.cover_path, 'member_count', g.member_count, 'join_policy', g.join_policy))
  from public.group_invite_links l
  join public.groups g on g.id = l.group_id
  where l.code = link_code and g.status = 'active';
$$;

create function public.invite_link_preview(link_code text)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.invite_link_preview(link_code);
$$;

revoke all on function private.invite_link_preview(text), public.invite_link_preview(text) from public;
grant execute on function private.invite_link_preview(text), public.invite_link_preview(text) to anon, authenticated;
