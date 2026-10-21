-- 0003_groups
-- Phase 2: role and permission catalog, groups, membership, join requests,
-- invitations and group image storage. Rules: docs/ARCHITECTURE.md §3b.
--
-- Clients only read these tables. Every write goes through the C# API, which
-- sets request.jwt.claims (sub = acting user) in its transaction, so the
-- triggers below enforce the same rules a second time through auth.uid().

-- ---------------------------------------------------------------------------
-- Catalog: group_roles, group_permissions, group_role_permissions
-- owner: groups
-- ---------------------------------------------------------------------------
create table public.group_roles (
  slug text primary key check (slug ~ '^[a-z_]+$'),
  name text not null,
  rank int  not null unique check (rank between 1 and 100)
);

comment on table public.group_roles is 'owner: groups. Group roles and their rank (rank rule).';

insert into public.group_roles (slug, name, rank) values
  ('owner',      'Grup Sahibi',     100),
  ('admin',      'Yönetici',         80),
  ('discipline', 'Disiplin Kurulu',  60),
  ('moderator',  'Moderatör',        50),
  ('member',     'Üye',              10);

create table public.group_permissions (
  slug        text primary key check (slug ~ '^[a-z_]+\.[a-z_]+$'),
  description text not null
);

comment on table public.group_permissions is
  'owner: groups. Permission catalog. Each phase adds its own permissions in its migration.';

insert into public.group_permissions (slug, description) values
  ('group.edit',      'Grup profilini, görselleri, kategoriyi ve katılım tipini düzenleme'),
  ('group.delete',    'Grubu silme'),
  ('group.transfer',  'Sahipliği devretme'),
  ('roles.assign',    'Rol atama ve alma'),
  ('members.approve', 'Katılım isteklerini onaylama ve reddetme'),
  ('members.invite',  'Davet gönderme ve geri alma');

-- The owner holds every permission implicitly and has no rows here.
create table public.group_role_permissions (
  role       text not null references public.group_roles (slug) on delete cascade check (role <> 'owner'),
  permission text not null references public.group_permissions (slug) on delete cascade,
  primary key (role, permission)
);

comment on table public.group_role_permissions is 'owner: groups. Which role grants which permission (owner excluded).';

insert into public.group_role_permissions (role, permission) values
  ('admin', 'group.edit'),
  ('admin', 'members.approve'),
  ('admin', 'members.invite');

alter table public.group_roles enable row level security;
alter table public.group_permissions enable row level security;
alter table public.group_role_permissions enable row level security;
revoke all on public.group_roles, public.group_permissions, public.group_role_permissions from anon, authenticated;
grant select on public.group_roles, public.group_permissions, public.group_role_permissions to anon, authenticated;

create policy group_roles_select_all on public.group_roles for select to anon, authenticated using (true);
create policy group_permissions_select_all on public.group_permissions for select to anon, authenticated using (true);
create policy group_role_permissions_select_all on public.group_role_permissions for select to anon, authenticated using (true);

-- ---------------------------------------------------------------------------
-- groups
-- owner: groups
-- ---------------------------------------------------------------------------
create table public.groups (
  id                uuid primary key default gen_random_uuid(),
  handle            text not null unique
                    constraint groups_handle_format
                    check (handle ~ '^[a-z0-9_.]{3,30}$' and handle !~ '^\.|\.$|\.\.'),
  name              text not null
                    constraint groups_name_length check (char_length(btrim(name)) between 3 and 60),
  category_slug     text not null references public.categories (slug),
  join_policy       text not null default 'open' check (join_policy in ('open', 'request', 'invite')),
  about             text not null default '' constraint groups_about_length check (char_length(about) <= 1000),
  rules             text not null default '' constraint groups_rules_length check (char_length(rules) <= 2000),
  links             jsonb not null default '[]'::jsonb
                    constraint groups_links_shape check (jsonb_typeof(links) = 'array' and jsonb_array_length(links) <= 5),
  logo_path         text check (logo_path is null or logo_path like id::text || '/%'),
  cover_path        text check (cover_path is null or cover_path like id::text || '/%'),
  owner_id          uuid not null references public.profiles (id) on delete restrict,
  member_count      int  not null default 0,
  status            text not null default 'active' check (status in ('active', 'suspended')),
  suspension_reason text,
  suspended_at      timestamptz,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  constraint groups_suspension_consistent
    check ((status = 'suspended') = (suspended_at is not null) and (status = 'suspended' or suspension_reason is null))
);

comment on table public.groups is 'owner: groups. Group profile page. Written only by the backend.';
comment on column public.groups.owner_id is
  'Owner (rank 100). Restricts profile deletion: owners must transfer or delete their groups first.';
comment on column public.groups.member_count is 'Maintained by trigger on group_members.';

create index groups_category_idx on public.groups (category_slug, member_count desc);
create index groups_popular_idx on public.groups (member_count desc, created_at desc);
create index groups_owner_idx on public.groups (owner_id);

-- ---------------------------------------------------------------------------
-- group_members, group_member_roles
-- owner: groups
-- ---------------------------------------------------------------------------
create table public.group_members (
  group_id  uuid not null references public.groups (id) on delete cascade,
  user_id   uuid not null references public.profiles (id) on delete cascade,
  joined_at timestamptz not null default now(),
  primary key (group_id, user_id)
);

comment on table public.group_members is 'owner: groups. Membership (role "member", rank 10). The owner is a member too.';

create index group_members_user_idx on public.group_members (user_id, joined_at desc);

-- Assigned roles. Owner comes from groups.owner_id, member from group_members.
create table public.group_member_roles (
  group_id    uuid not null,
  user_id     uuid not null,
  role        text not null references public.group_roles (slug)
              check (role in ('admin', 'discipline', 'moderator')),
  assigned_at timestamptz not null default now(),
  primary key (group_id, user_id, role),
  foreign key (group_id, user_id) references public.group_members (group_id, user_id) on delete cascade
);

comment on table public.group_member_roles is 'owner: groups. Roles assigned by the owner. Removed with the membership.';

-- ---------------------------------------------------------------------------
-- group_join_requests, group_invitations (pending only; resolved rows are deleted)
-- owner: groups
-- ---------------------------------------------------------------------------
create table public.group_join_requests (
  group_id   uuid not null references public.groups (id) on delete cascade,
  user_id    uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (group_id, user_id)
);

comment on table public.group_join_requests is 'owner: groups. Pending requests to join "request" groups.';

create table public.group_invitations (
  group_id   uuid not null references public.groups (id) on delete cascade,
  user_id    uuid not null references public.profiles (id) on delete cascade,
  invited_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now(),
  primary key (group_id, user_id)
);

comment on table public.group_invitations is 'owner: groups. Pending in-app invitations (by username).';

create index group_invitations_user_idx on public.group_invitations (user_id, created_at desc);

-- ---------------------------------------------------------------------------
-- Permission helpers
-- ---------------------------------------------------------------------------

-- Roles a user holds in a group: owner, member and assigned roles.
create function private.group_roles_of(target_group uuid, uid uuid)
returns setof text
language sql
stable
security definer
set search_path = ''
as $$
  select 'owner' from public.groups g where g.id = target_group and g.owner_id = uid
  union all
  select 'member' from public.group_members m where m.group_id = target_group and m.user_id = uid
  union all
  select r.role from public.group_member_roles r where r.group_id = target_group and r.user_id = uid;
$$;

-- Highest rank of the user's roles; 0 for non-members.
create function private.group_rank(target_group uuid, uid uuid)
returns int
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(max(r.rank), 0)
  from private.group_roles_of(target_group, uid) x (role)
  join public.group_roles r on r.slug = x.role;
$$;

-- True when uid (active account) is a member of the active group and one of
-- their roles grants the permission. The owner holds every catalog permission.
create function private.user_has_group_permission(uid uuid, target_group uuid, permission_slug text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select uid is not null
     and private.is_account_active(uid)
     and exists (select 1 from public.groups g where g.id = target_group and g.status = 'active')
     and exists (select 1 from public.group_members m where m.group_id = target_group and m.user_id = uid)
     and exists (select 1 from public.group_permissions p where p.slug = permission_slug)
     and (
       exists (select 1 from public.groups g where g.id = target_group and g.owner_id = uid)
       or exists (
         select 1
         from private.group_roles_of(target_group, uid) x (role)
         join public.group_role_permissions rp on rp.role = x.role
         where rp.permission = permission_slug
       )
     );
$$;

create function private.has_group_permission(target_group uuid, permission_slug text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select private.user_has_group_permission((select auth.uid()), target_group, permission_slug);
$$;

create function private.is_group_member(target_group uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.group_members m
    where m.group_id = target_group and m.user_id = (select auth.uid())
  );
$$;

-- Active groups are public; suspended ones only for members and staff.
create function private.is_group_visible(target_group uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.groups g
    where g.id = target_group
      and (g.status = 'active' or private.is_group_member(g.id) or private.is_platform_staff())
  );
$$;

create function private.group_permissions_of(target_group uuid)
returns text[]
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(array_agg(p.slug order by p.slug), '{}')
  from public.group_permissions p
  where private.has_group_permission(target_group, p.slug);
$$;

create function private.is_group_handle_taken(candidate text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select candidate = any (private.reserved_usernames())
      or exists (select 1 from public.groups g where g.handle = candidate);
$$;

revoke all on function private.group_roles_of(uuid, uuid) from public;
revoke all on function private.group_rank(uuid, uuid) from public;
revoke all on function private.user_has_group_permission(uuid, uuid, text) from public;
revoke all on function private.has_group_permission(uuid, text) from public;
revoke all on function private.is_group_member(uuid) from public;
revoke all on function private.is_group_visible(uuid) from public;
revoke all on function private.group_permissions_of(uuid) from public;
revoke all on function private.is_group_handle_taken(text) from public;
grant execute on function private.group_rank(uuid, uuid) to service_role;
grant execute on function private.user_has_group_permission(uuid, uuid, text) to service_role;
grant execute on function private.has_group_permission(uuid, text) to authenticated, service_role;
grant execute on function private.is_group_member(uuid) to anon, authenticated, service_role;
grant execute on function private.is_group_visible(uuid) to anon, authenticated, service_role;
grant execute on function private.group_permissions_of(uuid) to authenticated;
grant execute on function private.is_group_handle_taken(text) to authenticated;

-- RPC: the signed-in user's permissions in a group (drives which actions the UI shows).
create function public.my_group_permissions(target_group uuid)
returns text[]
language sql
stable
security invoker
set search_path = ''
as $$
  select private.group_permissions_of(target_group);
$$;

-- RPC: true when the handle is well-formed, not reserved and unused.
create function public.is_group_handle_available(name text)
returns boolean
language sql
stable
security invoker
set search_path = ''
as $$
  select name ~ '^[a-z0-9_.]{3,30}$'
     and name !~ '^\.|\.$|\.\.'
     and not private.is_group_handle_taken(name);
$$;

revoke all on function public.my_group_permissions(uuid) from public, anon;
grant execute on function public.my_group_permissions(uuid) to authenticated;
revoke all on function public.is_group_handle_available(text) from public, anon;
grant execute on function public.is_group_handle_available(text) to authenticated;

-- ---------------------------------------------------------------------------
-- RLS: clients read, never write
-- ---------------------------------------------------------------------------
alter table public.groups enable row level security;
alter table public.group_members enable row level security;
alter table public.group_member_roles enable row level security;
alter table public.group_join_requests enable row level security;
alter table public.group_invitations enable row level security;

revoke all on public.groups, public.group_members, public.group_member_roles,
              public.group_join_requests, public.group_invitations from anon, authenticated;
grant select on public.groups, public.group_members, public.group_member_roles to anon, authenticated;
grant select on public.group_join_requests, public.group_invitations to authenticated;

create policy groups_select_visible
  on public.groups for select to anon, authenticated
  using (status = 'active' or private.is_group_member(id) or (select private.is_platform_staff()));

create policy group_members_select_visible
  on public.group_members for select to anon, authenticated
  using (
    private.is_group_visible(group_id)
    and (user_id = (select auth.uid()) or private.is_account_active(user_id) or (select private.is_platform_staff()))
  );

create policy group_member_roles_select_visible
  on public.group_member_roles for select to anon, authenticated
  using (
    private.is_group_visible(group_id)
    and (user_id = (select auth.uid()) or private.is_account_active(user_id) or (select private.is_platform_staff()))
  );

create policy group_join_requests_select_own_or_approver
  on public.group_join_requests for select to authenticated
  using (
    user_id = (select auth.uid())
    or private.has_group_permission(group_id, 'members.approve')
    or (select private.is_platform_staff())
  );

create policy group_invitations_select_own_or_inviter
  on public.group_invitations for select to authenticated
  using (
    user_id = (select auth.uid())
    or private.has_group_permission(group_id, 'members.invite')
    or (select private.is_platform_staff())
  );

-- ---------------------------------------------------------------------------
-- Triggers: second enforcement of the backend's rules (actor = auth.uid())
-- ---------------------------------------------------------------------------
create function private.raise_group_rule(code text)
returns void
language plpgsql
set search_path = ''
as $$
begin
  raise exception '%', code using errcode = 'P0001';
end;
$$;

create function private.groups_before_write()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
begin
  if tg_op = 'DELETE' then
    if not private.has_group_permission(old.id, 'group.delete') then
      perform private.raise_group_rule('group_delete_forbidden');
    end if;
    return old;
  end if;

  new.name := btrim(new.name);
  new.about := btrim(new.about);
  new.rules := btrim(new.rules);

  if tg_op = 'INSERT' then
    if actor is null or actor is distinct from new.owner_id then
      perform private.raise_group_rule('group_create_forbidden');
    end if;
    if new.handle = any (private.reserved_usernames()) then
      perform private.raise_group_rule('handle_reserved');
    end if;
    new.member_count := 0;
    new.status := 'active';
    new.suspension_reason := null;
    new.suspended_at := null;
    new.created_at := now();
    new.updated_at := now();
    return new;
  end if;

  new.created_at := old.created_at;
  if new.handle is distinct from old.handle then
    perform private.raise_group_rule('handle_immutable');
  end if;

  if (new.name, new.category_slug, new.join_policy, new.about, new.rules, new.links, new.logo_path, new.cover_path)
     is distinct from
     (old.name, old.category_slug, old.join_policy, old.about, old.rules, old.links, old.logo_path, old.cover_path) then
    if not private.has_group_permission(old.id, 'group.edit') then
      perform private.raise_group_rule('group_edit_forbidden');
    end if;
    new.updated_at := now();
  else
    new.updated_at := old.updated_at;
  end if;

  if new.owner_id is distinct from old.owner_id then
    if not private.has_group_permission(old.id, 'group.transfer') then
      perform private.raise_group_rule('ownership_transfer_forbidden');
    end if;
    if not exists (select 1 from public.group_members m where m.group_id = old.id and m.user_id = new.owner_id)
       or not private.is_account_active(new.owner_id) then
      perform private.raise_group_rule('new_owner_not_member');
    end if;
  end if;

  if (new.status, new.suspension_reason) is distinct from (old.status, old.suspension_reason)
     and not private.is_platform_staff(array['admin', 'moderator']) then
    perform private.raise_group_rule('group_suspension_forbidden');
  end if;

  return new;
end;
$$;

create trigger groups_before_write
  before insert or update or delete on public.groups
  for each row execute function private.groups_before_write();

create function private.group_members_guard()
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
  -- Removing other members is a sanction (Phase 6).
  if actor is distinct from old.user_id then
    perform private.raise_group_rule('leave_not_allowed');
  end if;
  return old;
end;
$$;

create trigger group_members_guard
  before insert or delete on public.group_members
  for each row execute function private.group_members_guard();

create function private.group_members_count()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    update public.groups set member_count = member_count + 1 where id = new.group_id;
  else
    update public.groups set member_count = greatest(member_count - 1, 0) where id = old.group_id;
  end if;
  return null;
end;
$$;

create trigger group_members_count
  after insert or delete on public.group_members
  for each row execute function private.group_members_count();

create function private.group_member_roles_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
  r public.group_member_roles;
  actor_rank int;
begin
  if tg_op = 'DELETE' then
    -- Cascade from a removed membership (member left, group or profile deleted).
    if not exists (
      select 1 from public.group_members m where m.group_id = old.group_id and m.user_id = old.user_id
    ) then
      return old;
    end if;
    r := old;
  else
    r := new;
  end if;

  if not private.has_group_permission(r.group_id, 'roles.assign') then
    perform private.raise_group_rule('role_assign_forbidden');
  end if;

  -- Rank rule: the actor must outrank both the member and the role.
  actor_rank := private.group_rank(r.group_id, actor);
  if actor_rank <= private.group_rank(r.group_id, r.user_id)
     or actor_rank <= (select gr.rank from public.group_roles gr where gr.slug = r.role) then
    perform private.raise_group_rule('rank_violation');
  end if;

  if tg_op = 'INSERT' then
    new.assigned_at := now();
    return new;
  end if;
  return old;
end;
$$;

create trigger group_member_roles_guard
  before insert or delete on public.group_member_roles
  for each row execute function private.group_member_roles_guard();

create function private.group_join_requests_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
begin
  if tg_op = 'INSERT' then
    if actor is distinct from new.user_id
       or not private.is_account_active(new.user_id)
       or not exists (
         select 1 from public.groups g
         where g.id = new.group_id and g.status = 'active' and g.join_policy = 'request'
       )
       or exists (select 1 from public.group_members m where m.group_id = new.group_id and m.user_id = new.user_id) then
      perform private.raise_group_rule('join_request_not_allowed');
    end if;
    new.created_at := now();
    return new;
  end if;

  if not exists (select 1 from public.groups g where g.id = old.group_id)
     or not exists (select 1 from public.profiles p where p.id = old.user_id) then
    return old;
  end if;
  if actor is distinct from old.user_id and not private.has_group_permission(old.group_id, 'members.approve') then
    perform private.raise_group_rule('join_request_forbidden');
  end if;
  return old;
end;
$$;

create trigger group_join_requests_guard
  before insert or delete on public.group_join_requests
  for each row execute function private.group_join_requests_guard();

create function private.group_invitations_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
begin
  if tg_op = 'INSERT' then
    if not private.has_group_permission(new.group_id, 'members.invite')
       or not private.is_account_active(new.user_id)
       or exists (select 1 from public.group_members m where m.group_id = new.group_id and m.user_id = new.user_id) then
      perform private.raise_group_rule('invitation_not_allowed');
    end if;
    new.invited_by := actor;
    new.created_at := now();
    return new;
  end if;

  if not exists (select 1 from public.groups g where g.id = old.group_id)
     or not exists (select 1 from public.profiles p where p.id = old.user_id) then
    return old;
  end if;
  if actor is distinct from old.user_id and not private.has_group_permission(old.group_id, 'members.invite') then
    perform private.raise_group_rule('invitation_forbidden');
  end if;
  return old;
end;
$$;

create trigger group_invitations_guard
  before insert or delete on public.group_invitations
  for each row execute function private.group_invitations_guard();

-- ---------------------------------------------------------------------------
-- Storage: group-images
-- owner: groups
-- Public read; members with group.edit write inside <group_id>/.
-- ---------------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types) values
  ('group-images', 'group-images', true, 5242880, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

-- Group id of a storage path, or null when the first folder is not a uuid.
create function private.group_id_from_path(object_name text)
returns uuid
language sql
immutable
set search_path = ''
as $$
  select case
    when (storage.foldername(object_name))[1] ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
    then ((storage.foldername(object_name))[1])::uuid
  end;
$$;

revoke all on function private.group_id_from_path(text) from public;
grant execute on function private.group_id_from_path(text) to authenticated, service_role;

create policy group_images_select_editor
  on storage.objects for select to authenticated
  using (bucket_id = 'group-images' and private.has_group_permission(private.group_id_from_path(name), 'group.edit'));

create policy group_images_insert_editor
  on storage.objects for insert to authenticated
  with check (bucket_id = 'group-images' and private.has_group_permission(private.group_id_from_path(name), 'group.edit'));

create policy group_images_update_editor
  on storage.objects for update to authenticated
  using (bucket_id = 'group-images' and private.has_group_permission(private.group_id_from_path(name), 'group.edit'))
  with check (bucket_id = 'group-images' and private.has_group_permission(private.group_id_from_path(name), 'group.edit'));

create policy group_images_delete_editor
  on storage.objects for delete to authenticated
  using (bucket_id = 'group-images' and private.has_group_permission(private.group_id_from_path(name), 'group.edit'));
