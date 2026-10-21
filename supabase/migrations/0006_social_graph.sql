-- 0006_social_graph
-- Phase 4: private accounts, follows, follow requests, blocks (profile) and
-- group follows (groups). Rules: docs/ARCHITECTURE.md §3c.
--
-- Follow, request and block writes go through the C# API, which names the
-- actor in request.jwt.claims; the triggers below check the same rules again.
-- Group follows are the user's own simple write (RLS).

-- ---------------------------------------------------------------------------
-- profiles.is_private
-- ---------------------------------------------------------------------------
alter table public.profiles add column is_private boolean not null default false;
comment on column public.profiles.is_private is
  'Private account: following needs approval and content is shown to followers only.';
grant update (is_private) on public.profiles to authenticated;

-- ---------------------------------------------------------------------------
-- follows, follow_requests, blocks
-- owner: profile
-- ---------------------------------------------------------------------------
create table public.follows (
  follower_id uuid not null references public.profiles (id) on delete cascade,
  followee_id uuid not null references public.profiles (id) on delete cascade,
  created_at  timestamptz not null default now(),
  primary key (follower_id, followee_id),
  constraint follows_not_self check (follower_id <> followee_id)
);
create index follows_followee_idx on public.follows (followee_id, created_at desc);
comment on table public.follows is 'owner: profile. Who follows whom. Mutual follows show as friends.';

create table public.follow_requests (
  requester_id uuid not null references public.profiles (id) on delete cascade,
  target_id    uuid not null references public.profiles (id) on delete cascade,
  created_at   timestamptz not null default now(),
  primary key (requester_id, target_id),
  constraint follow_requests_not_self check (requester_id <> target_id)
);
create index follow_requests_target_idx on public.follow_requests (target_id, created_at desc);
comment on table public.follow_requests is 'owner: profile. Pending follows of private accounts.';

create table public.blocks (
  blocker_id uuid not null references public.profiles (id) on delete cascade,
  blocked_id uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  constraint blocks_not_self check (blocker_id <> blocked_id)
);
create index blocks_blocked_idx on public.blocks (blocked_id);
comment on table public.blocks is 'owner: profile. Blocks hide both sides from each other; only the blocker sees the row.';

-- ---------------------------------------------------------------------------
-- Visibility helpers
-- ---------------------------------------------------------------------------
create function private.is_blocked_between(a uuid, b uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.blocks
    where (blocker_id = a and blocked_id = b) or (blocker_id = b and blocked_id = a)
  );
$$;

-- One direction only: the profile rule hides a blocker from the people they blocked.
create function private.has_blocked(blocker uuid, blocked uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (select 1 from public.blocks where blocker_id = blocker and blocked_id = blocked);
$$;

create function private.user_follows(follower uuid, followee uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (select 1 from public.follows where follower_id = follower and followee_id = followee);
$$;

-- Whether the current user may see the author's content (posts, stories, follow lists).
create function private.can_view_user_content(author uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select author = (select auth.uid())
    or private.is_platform_staff()
    or (
      private.is_account_active(author)
      and exists (select 1 from public.profiles p where p.id = author)
      and not private.is_blocked_between(author, (select auth.uid()))
      and (
        not (select p.is_private from public.profiles p where p.id = author)
        or private.user_follows((select auth.uid()), author)
      )
    );
$$;

revoke all on function private.is_blocked_between(uuid, uuid) from public;
revoke all on function private.has_blocked(uuid, uuid) from public;
revoke all on function private.user_follows(uuid, uuid) from public;
revoke all on function private.can_view_user_content(uuid) from public;
grant execute on function private.is_blocked_between(uuid, uuid) to anon, authenticated, service_role;
grant execute on function private.has_blocked(uuid, uuid) to anon, authenticated, service_role;
grant execute on function private.user_follows(uuid, uuid) to anon, authenticated, service_role;
grant execute on function private.can_view_user_content(uuid) to anon, authenticated, service_role;

-- A blocked user no longer sees the blocker's profile. The blocker still sees
-- the blocked profile (to unblock).
drop policy profiles_select_visible on public.profiles;
create policy profiles_select_visible
  on public.profiles for select to anon, authenticated
  using (
    id = (select auth.uid())
    or (select private.is_platform_staff())
    or (
      private.is_account_active(id)
      and not private.has_blocked(id, (select auth.uid()))
    )
  );

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------
alter table public.follows enable row level security;
alter table public.follow_requests enable row level security;
alter table public.blocks enable row level security;

revoke all on public.follows, public.follow_requests, public.blocks from anon, authenticated;
grant select on public.follows to anon, authenticated;
grant select on public.follow_requests, public.blocks to authenticated;

-- Follow lists are part of a user's content.
create policy follows_select_visible
  on public.follows for select to anon, authenticated
  using (
    follower_id = (select auth.uid()) or followee_id = (select auth.uid())
    or (private.can_view_user_content(follower_id) and private.can_view_user_content(followee_id))
  );

create policy follow_requests_select_parties
  on public.follow_requests for select to authenticated
  using (requester_id = (select auth.uid()) or target_id = (select auth.uid()));

create policy blocks_select_blocker
  on public.blocks for select to authenticated
  using (blocker_id = (select auth.uid()));

-- ---------------------------------------------------------------------------
-- Triggers: second enforcement (actor = auth.uid())
-- ---------------------------------------------------------------------------
create function private.raise_social_rule(code text)
returns void
language plpgsql
set search_path = ''
as $$
begin
  raise exception '%', code using errcode = 'P0001';
end;
$$;

-- Daily limit shared by follows and requests.
create function private.check_follow_rate(actor uuid)
returns void
language plpgsql
set search_path = ''
as $$
begin
  if (select count(*) from public.follows where follower_id = actor and created_at > now() - interval '24 hours')
     + (select count(*) from public.follow_requests where requester_id = actor and created_at > now() - interval '24 hours')
     >= 200 then
    perform private.raise_social_rule('follow_rate_limited');
  end if;
end;
$$;

create function private.follows_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
begin
  if tg_op = 'DELETE' then
    -- Cascades from a deleted profile, and block clean-up (nested trigger).
    if pg_trigger_depth() > 1
       or not exists (select 1 from public.profiles where id = old.follower_id)
       or not exists (select 1 from public.profiles where id = old.followee_id) then
      return old;
    end if;
    if actor is null or actor not in (old.follower_id, old.followee_id) then
      perform private.raise_social_rule('unfollow_forbidden');
    end if;
    return old;
  end if;

  if actor is null then
    perform private.raise_social_rule('follow_forbidden');
  end if;
  if private.is_blocked_between(new.follower_id, new.followee_id) then
    perform private.raise_social_rule('blocked');
  end if;
  if not private.is_account_active(new.follower_id) or not private.is_account_active(new.followee_id) then
    perform private.raise_social_rule('account_not_active');
  end if;

  if actor = new.follower_id then
    -- Direct follow: only public accounts, except after the owner switched to public (nested trigger).
    if pg_trigger_depth() = 1 and (select is_private from public.profiles where id = new.followee_id) then
      perform private.raise_social_rule('follow_requires_approval');
    end if;
    perform private.check_follow_rate(actor);
  elsif actor = new.followee_id then
    -- Accepting a request.
    if not exists (select 1 from public.follow_requests r
                   where r.requester_id = new.follower_id and r.target_id = new.followee_id) then
      perform private.raise_social_rule('no_follow_request');
    end if;
  else
    perform private.raise_social_rule('follow_forbidden');
  end if;

  new.created_at := now();
  return new;
end;
$$;

create trigger follows_guard
  before insert or delete on public.follows
  for each row execute function private.follows_guard();

create function private.follow_requests_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
begin
  if tg_op = 'DELETE' then
    if pg_trigger_depth() > 1
       or not exists (select 1 from public.profiles where id = old.requester_id)
       or not exists (select 1 from public.profiles where id = old.target_id) then
      return old;
    end if;
    if actor is null or actor not in (old.requester_id, old.target_id) then
      perform private.raise_social_rule('request_delete_forbidden');
    end if;
    return old;
  end if;

  if actor is null or actor <> new.requester_id then
    perform private.raise_social_rule('follow_forbidden');
  end if;
  if private.is_blocked_between(new.requester_id, new.target_id) then
    perform private.raise_social_rule('blocked');
  end if;
  if not (select is_private from public.profiles where id = new.target_id) then
    perform private.raise_social_rule('account_is_public');
  end if;
  if private.user_follows(new.requester_id, new.target_id) then
    perform private.raise_social_rule('already_following');
  end if;
  perform private.check_follow_rate(actor);
  new.created_at := now();
  return new;
end;
$$;

create trigger follow_requests_guard
  before insert or delete on public.follow_requests
  for each row execute function private.follow_requests_guard();

create function private.blocks_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
begin
  if tg_op = 'DELETE' then
    if not exists (select 1 from public.profiles where id = old.blocker_id)
       or not exists (select 1 from public.profiles where id = old.blocked_id) then
      return old;
    end if;
    if actor is distinct from old.blocker_id then
      perform private.raise_social_rule('unblock_forbidden');
    end if;
    return old;
  end if;
  if actor is null or actor <> new.blocker_id then
    perform private.raise_social_rule('block_forbidden');
  end if;
  new.created_at := now();
  return new;
end;
$$;

create trigger blocks_guard
  before insert or delete on public.blocks
  for each row execute function private.blocks_guard();

-- A block removes follows and requests in both directions.
create function private.blocks_after_insert()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  delete from public.follows
  where (follower_id = new.blocker_id and followee_id = new.blocked_id)
     or (follower_id = new.blocked_id and followee_id = new.blocker_id);
  delete from public.follow_requests
  where (requester_id = new.blocker_id and target_id = new.blocked_id)
     or (requester_id = new.blocked_id and target_id = new.blocker_id);
  return null;
end;
$$;

create trigger blocks_after_insert
  after insert on public.blocks
  for each row execute function private.blocks_after_insert();

-- Going public accepts every pending request.
create function private.profiles_after_privacy_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if old.is_private and not new.is_private then
    insert into public.follows (follower_id, followee_id)
    select r.requester_id, r.target_id from public.follow_requests r where r.target_id = new.id
    on conflict do nothing;
    delete from public.follow_requests where target_id = new.id;
  end if;
  return null;
end;
$$;

create trigger profiles_after_privacy_change
  after update of is_private on public.profiles
  for each row execute function private.profiles_after_privacy_change();

-- ---------------------------------------------------------------------------
-- group_follows
-- owner: groups
-- ---------------------------------------------------------------------------
create table public.group_follows (
  user_id    uuid not null references public.profiles (id) on delete cascade,
  group_id   uuid not null references public.groups (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, group_id)
);
create index group_follows_group_idx on public.group_follows (group_id);
comment on table public.group_follows is 'owner: groups. Users following a group; its posts reach their feed.';

alter table public.group_follows enable row level security;
revoke all on public.group_follows from anon, authenticated;
grant select on public.group_follows to anon, authenticated;
grant insert (user_id, group_id), delete on public.group_follows to authenticated;

create policy group_follows_select_visible
  on public.group_follows for select to anon, authenticated
  using (user_id = (select auth.uid()) or private.is_group_visible(group_id));

create policy group_follows_insert_own
  on public.group_follows for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and (select private.is_account_active(auth.uid()))
    and private.is_group_visible(group_id)
  );

create policy group_follows_delete_own
  on public.group_follows for delete to authenticated
  using (user_id = (select auth.uid()));
