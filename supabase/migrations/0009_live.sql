-- 0009_live
-- Phase 7: live audio rooms of groups (LiveKit), scheduled broadcasts with
-- reminders, live comments and the monthly live minute limit.
-- Rules: docs/ARCHITECTURE.md §8.
--
-- Broadcasts and kicks are written by the C# API (actor in request.jwt.claims;
-- none for the monitor's system writes). Comments and reminders are the
-- user's own simple writes (RLS). Triggers re-check the rules.

-- ---------------------------------------------------------------------------
-- Permissions: live.start (owner, Yönetici), live.moderate (owner, Yönetici,
-- Disiplin Kurulu, Moderatör)
-- ---------------------------------------------------------------------------
insert into public.group_permissions (slug, description) values
  ('live.start', 'Canlı yayın başlatma ve planlama'),
  ('live.moderate', 'Canlı yayında sahneye alma ve indirme, mikrofon kapatma, odadan atma, yorum silme, yayını bitirme');
insert into public.group_role_permissions (role, permission) values
  ('admin', 'live.start'),
  ('admin', 'live.moderate'),
  ('discipline', 'live.moderate'),
  ('moderator', 'live.moderate');

-- ---------------------------------------------------------------------------
-- live_broadcasts, live_kicks, live_comments, live_reminders
-- owner: live
-- ---------------------------------------------------------------------------
create table public.live_broadcasts (
  id           uuid primary key default gen_random_uuid(),
  group_id     uuid not null references public.groups (id) on delete cascade,
  host_id      uuid references public.profiles (id) on delete set null,
  title        text not null check (char_length(title) between 3 and 80),
  status       text not null check (status in ('scheduled', 'live', 'ended', 'canceled')),
  scheduled_at timestamptz,
  started_at   timestamptz,
  ended_at     timestamptz,
  end_reason   text check (end_reason in ('host', 'moderator', 'admin', 'limit', 'host_left', 'empty')),
  created_at   timestamptz not null default now(),
  constraint live_broadcasts_times check (
    case status
      when 'scheduled' then scheduled_at is not null and started_at is null and ended_at is null and end_reason is null
      when 'live' then started_at is not null and ended_at is null and end_reason is null
      when 'ended' then started_at is not null and ended_at is not null and end_reason is not null
      else scheduled_at is not null and started_at is null and ended_at is not null and end_reason is null
    end)
);

comment on table public.live_broadcasts is
  'owner: live. Audio rooms of a group; the LiveKit room is named after the id. History stays after the end.';

create unique index live_broadcasts_one_live_idx on public.live_broadcasts (group_id) where status = 'live';
create index live_broadcasts_group_idx on public.live_broadcasts (group_id, status, coalesce(started_at, scheduled_at) desc);
create index live_broadcasts_live_idx on public.live_broadcasts (started_at) where status = 'live';

create table public.live_kicks (
  broadcast_id uuid not null references public.live_broadcasts (id) on delete cascade,
  user_id      uuid not null references public.profiles (id) on delete cascade,
  kicked_by    uuid references public.profiles (id) on delete set null,
  created_at   timestamptz not null default now(),
  primary key (broadcast_id, user_id)
);

comment on table public.live_kicks is 'owner: live. People removed from a broadcast; they get no token for it again.';

create table public.live_comments (
  id           bigint generated always as identity primary key,
  broadcast_id uuid not null references public.live_broadcasts (id) on delete cascade,
  user_id      uuid not null references public.profiles (id) on delete cascade,
  body         text not null check (char_length(btrim(body)) between 1 and 300),
  created_at   timestamptz not null default now()
);

comment on table public.live_comments is 'owner: live. Written comments of a broadcast; streamed with Realtime.';

create index live_comments_broadcast_idx on public.live_comments (broadcast_id, id);
create index live_comments_user_idx on public.live_comments (user_id, created_at desc);

create table public.live_reminders (
  broadcast_id uuid not null references public.live_broadcasts (id) on delete cascade,
  user_id      uuid not null references public.profiles (id) on delete cascade,
  created_at   timestamptz not null default now(),
  primary key (broadcast_id, user_id)
);

comment on table public.live_reminders is 'owner: live. Members to notify when a scheduled broadcast starts.';

create index live_reminders_user_idx on public.live_reminders (user_id);

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

-- Minutes the group was live this calendar month (Turkey time), running broadcasts up to now.
create function private.live_minutes_used(target_group uuid)
returns int
language sql
stable
security definer
set search_path = ''
as $$
  with month as (
    select (date_trunc('month', now() at time zone 'Europe/Istanbul') at time zone 'Europe/Istanbul') as starts
  )
  select coalesce(ceil(sum(extract(epoch from (coalesce(b.ended_at, now()) - greatest(b.started_at, month.starts)))) / 60), 0)::int
  from public.live_broadcasts b, month
  where b.group_id = target_group
    and b.status in ('live', 'ended')
    and coalesce(b.ended_at, now()) > month.starts;
$$;

create function private.live_minutes_left(target_group uuid)
returns int
language sql
stable
security definer
set search_path = ''
as $$
  select greatest((private.group_plan_limits(target_group)).monthly_live_minutes - private.live_minutes_used(target_group), 0);
$$;

-- Members (and staff) see a group's broadcasts and comments.
create function private.can_view_live(target_broadcast uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.live_broadcasts b
    where b.id = target_broadcast and (private.is_group_member(b.group_id) or private.is_platform_staff())
  );
$$;

-- In the room: an active member of the group, the broadcast live and the user not kicked.
create function private.can_join_live(target_broadcast uuid, uid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select uid is not null
     and private.is_account_active(uid)
     and exists (
       select 1 from public.live_broadcasts b
       join public.groups g on g.id = b.group_id and g.status = 'active'
       join public.group_members m on m.group_id = b.group_id and m.user_id = uid
       where b.id = target_broadcast and b.status = 'live'
     )
     and not exists (select 1 from public.live_kicks k where k.broadcast_id = target_broadcast and k.user_id = uid);
$$;

-- The host or a live.moderate holder, outranking the target (§8, Rütbe kuralı).
create function private.can_moderate_live(target_broadcast uuid, actor uuid, target uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.live_broadcasts b
    where b.id = target_broadcast
      and (b.host_id = actor or private.user_has_group_permission(actor, b.group_id, 'live.moderate'))
      and private.is_account_active(actor)
      and private.group_rank(b.group_id, actor) > private.group_rank(b.group_id, target)
  );
$$;

revoke all on function private.live_minutes_used(uuid), private.live_minutes_left(uuid), private.can_view_live(uuid),
  private.can_join_live(uuid, uuid), private.can_moderate_live(uuid, uuid, uuid) from public;
grant execute on function private.live_minutes_used(uuid), private.live_minutes_left(uuid),
  private.can_join_live(uuid, uuid), private.can_moderate_live(uuid, uuid, uuid) to service_role;
grant execute on function private.can_view_live(uuid), private.can_join_live(uuid, uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------
alter table public.live_broadcasts enable row level security;
alter table public.live_kicks enable row level security;
alter table public.live_comments enable row level security;
alter table public.live_reminders enable row level security;

revoke all on public.live_broadcasts, public.live_kicks, public.live_comments, public.live_reminders from anon, authenticated;
grant select on public.live_broadcasts, public.live_kicks, public.live_comments, public.live_reminders to authenticated;
grant insert (broadcast_id, user_id, body), delete on public.live_comments to authenticated;
grant insert (broadcast_id, user_id), delete on public.live_reminders to authenticated;

create policy live_broadcasts_select_members on public.live_broadcasts for select to authenticated
  using (private.is_group_member(group_id) or (select private.is_platform_staff()));

create policy live_kicks_select_staff on public.live_kicks for select to authenticated
  using ((select private.is_platform_staff()));

create policy live_comments_select_members on public.live_comments for select to authenticated
  using (private.can_view_live(broadcast_id));
create policy live_comments_insert_own on public.live_comments for insert to authenticated
  with check (user_id = (select auth.uid()) and private.can_join_live(broadcast_id, (select auth.uid())));
create policy live_comments_delete_own on public.live_comments for delete to authenticated
  using (user_id = (select auth.uid()));

create policy live_reminders_select_own on public.live_reminders for select to authenticated
  using (user_id = (select auth.uid()));
create policy live_reminders_insert_own on public.live_reminders for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and (select private.is_account_active(auth.uid()))
    and exists (
      select 1 from public.live_broadcasts b
      where b.id = broadcast_id and b.status = 'scheduled' and private.is_group_member(b.group_id)
    )
  );
create policy live_reminders_delete_own on public.live_reminders for delete to authenticated
  using (user_id = (select auth.uid()));

-- ---------------------------------------------------------------------------
-- Triggers
-- ---------------------------------------------------------------------------
create function private.raise_live_rule(code text)
returns void
language plpgsql
set search_path = ''
as $$
begin
  raise exception '%', code using errcode = 'P0001';
end;
$$;

-- Broadcasts: started or scheduled by a live.start holder as host; then only the
-- status moves forward. Without an actor it is the monitor of the backend (system).
create function private.live_broadcasts_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
begin
  if tg_op = 'DELETE' then
    if not exists (select 1 from public.groups g where g.id = old.group_id) then
      return old;
    end if;
    perform private.raise_live_rule('broadcast_delete_forbidden');
  end if;

  if tg_op = 'INSERT' then
    if actor is null or actor is distinct from new.host_id or not private.has_group_permission(new.group_id, 'live.start') then
      perform private.raise_live_rule('live_forbidden');
    end if;
    new.created_at := now();
    new.ended_at := null;
    new.end_reason := null;
    if new.status = 'live' then
      if private.live_minutes_left(new.group_id) <= 0 then
        perform private.raise_live_rule('minutes_exhausted');
      end if;
      new.scheduled_at := null;
      new.started_at := now();
    elsif new.status = 'scheduled' then
      if new.scheduled_at < now() + interval '4 minutes' or new.scheduled_at > now() + interval '30 days' then
        perform private.raise_live_rule('schedule_invalid');
      end if;
      if (select count(*) from public.live_broadcasts b where b.group_id = new.group_id and b.status = 'scheduled') >= 5 then
        perform private.raise_live_rule('too_many_scheduled');
      end if;
      new.started_at := null;
    else
      perform private.raise_live_rule('status_invalid');
    end if;
    return new;
  end if;

  -- The host link empties when the account of the host is deleted.
  if pg_trigger_depth() > 1 and new.host_id is null and old.host_id is not null
     and (new.id, new.status) = (old.id, old.status) then
    return new;
  end if;
  if (new.id, new.group_id, new.host_id, new.title, new.scheduled_at, new.created_at)
     is distinct from (old.id, old.group_id, old.host_id, old.title, old.scheduled_at, old.created_at) then
    perform private.raise_live_rule('broadcast_immutable');
  end if;

  if old.status = 'scheduled' and new.status = 'live' then
    if actor is null or actor is distinct from old.host_id or not private.has_group_permission(old.group_id, 'live.start') then
      perform private.raise_live_rule('live_forbidden');
    end if;
    if now() < old.scheduled_at - interval '15 minutes' then
      perform private.raise_live_rule('too_early');
    end if;
    if private.live_minutes_left(old.group_id) <= 0 then
      perform private.raise_live_rule('minutes_exhausted');
    end if;
    new.started_at := now();
    return new;
  end if;

  if old.status = 'scheduled' and new.status = 'canceled' then
    if actor is not null and actor is distinct from old.host_id
       and not private.can_moderate_live(old.id, actor, old.host_id) then
      perform private.raise_live_rule('live_forbidden');
    end if;
    new.ended_at := now();
    new.end_reason := null;
    return new;
  end if;

  if old.status = 'live' and new.status = 'ended' then
    if new.end_reason = 'host' then
      if actor is null or actor is distinct from old.host_id then
        perform private.raise_live_rule('live_forbidden');
      end if;
    elsif new.end_reason = 'moderator' then
      if actor is null or not private.can_moderate_live(old.id, actor, old.host_id) then
        perform private.raise_live_rule('live_forbidden');
      end if;
    elsif new.end_reason = 'admin' then
      if not private.is_platform_staff(array['admin', 'moderator']) then
        perform private.raise_live_rule('live_forbidden');
      end if;
    elsif actor is not null then
      perform private.raise_live_rule('live_forbidden');
    end if;
    new.ended_at := now();
    return new;
  end if;

  perform private.raise_live_rule('status_invalid');
  return null;
end;
$$;

create trigger live_broadcasts_guard
  before insert or update or delete on public.live_broadcasts
  for each row execute function private.live_broadcasts_guard();

-- Kicks: the host or an outranking live.moderate holder, during the broadcast.
create function private.live_kicks_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
begin
  if tg_op = 'INSERT' then
    if actor is null or not private.can_moderate_live(new.broadcast_id, actor, new.user_id)
       or not exists (select 1 from public.live_broadcasts b where b.id = new.broadcast_id and b.status = 'live') then
      perform private.raise_live_rule('live_forbidden');
    end if;
    new.kicked_by := actor;
    new.created_at := now();
    return new;
  end if;
  if pg_trigger_depth() > 1 then
    return coalesce(new, old);
  end if;
  perform private.raise_live_rule('kick_immutable');
  return null;
end;
$$;

create trigger live_kicks_guard
  before insert or update or delete on public.live_kicks
  for each row execute function private.live_kicks_guard();

-- Comments: at most 20 a minute; others' comments only by an outranking moderator.
create function private.live_comments_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
begin
  if tg_op = 'INSERT' then
    if (select count(*) from public.live_comments c
        where c.user_id = new.user_id and c.created_at > now() - interval '1 minute') >= 20 then
      perform private.raise_live_rule('comment_rate_limited');
    end if;
    new.body := btrim(new.body);
    new.created_at := now();
    return new;
  end if;
  if tg_op = 'DELETE' then
    if pg_trigger_depth() > 1 or actor = old.user_id or private.can_moderate_live(old.broadcast_id, actor, old.user_id) then
      return old;
    end if;
    perform private.raise_live_rule('live_forbidden');
  end if;
  perform private.raise_live_rule('comment_immutable');
  return null;
end;
$$;

create trigger live_comments_guard
  before insert or update or delete on public.live_comments
  for each row execute function private.live_comments_guard();

-- ---------------------------------------------------------------------------
-- Notification: a scheduled broadcast went live (notifications owns the table)
-- ---------------------------------------------------------------------------
alter table public.notifications add column live_id uuid references public.live_broadcasts (id) on delete cascade;
alter table public.notifications drop constraint notifications_type_check;
alter table public.notifications add constraint notifications_type_check
  check (type in ('like', 'comment', 'reply', 'comment_like', 'mention', 'follow', 'follow_request', 'follow_accepted',
                  'live_started'));

create function private.notify_live_started()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.notifications (recipient_id, actor_id, type, live_id)
  select r.user_id, new.host_id, 'live_started', new.id
  from public.live_reminders r
  where r.broadcast_id = new.id
    and r.user_id <> new.host_id
    and private.is_account_active(r.user_id)
    and not private.is_blocked_between(r.user_id, new.host_id);
  return null;
end;
$$;

revoke all on function private.notify_live_started() from public;

create trigger notify_live_started
  after update of status on public.live_broadcasts
  for each row when (old.status = 'scheduled' and new.status = 'live')
  execute function private.notify_live_started();

-- my_notifications also returns the broadcast of live_started.
create or replace function public.my_notifications(before_id bigint default null, page_size int default 30)
returns setof jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select jsonb_build_object(
    'id', n.id,
    'type', n.type,
    'created_at', n.created_at,
    'read', n.read_at is not null,
    'actor', jsonb_build_object('id', a.id, 'username', a.username, 'display_name', a.display_name, 'avatar_path', a.avatar_path),
    'post_id', n.post_id,
    'post_thumb', (select coalesce(m.thumb_path, m.poster_path, m.path) from public.post_media m
                   where m.post_id = n.post_id order by m.position limit 1),
    'post_thumb_kind', (select m.kind from public.post_media m where m.post_id = n.post_id order by m.position limit 1),
    'comment', (select left(c.body, 120) from public.comments c where c.id = n.comment_id),
    'live_id', n.live_id,
    'live_title', (select b.title from public.live_broadcasts b where b.id = n.live_id),
    'i_follow', private.user_follows((select auth.uid()), n.actor_id),
    'requested', exists (select 1 from public.follow_requests r
                         where r.requester_id = (select auth.uid()) and r.target_id = n.actor_id)
  )
  from public.notifications n
  join public.profiles a on a.id = n.actor_id
  where n.recipient_id = (select auth.uid()) and (before_id is null or n.id < before_id)
  order by n.id desc
  limit least(greatest(page_size, 1), 60);
$$;

-- ---------------------------------------------------------------------------
-- RPCs
-- ---------------------------------------------------------------------------

-- One broadcast as the screens show it.
create function private.live_card(b public.live_broadcasts)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'id', b.id,
    'title', b.title,
    'status', b.status,
    'scheduled_at', b.scheduled_at,
    'started_at', b.started_at,
    'ended_at', b.ended_at,
    'group', jsonb_build_object('id', g.id, 'handle', g.handle, 'name', g.name, 'logo_path', g.logo_path),
    'host', case when h.id is null then null
                 else jsonb_build_object('id', h.id, 'username', h.username, 'display_name', h.display_name,
                                         'avatar_path', h.avatar_path) end,
    'reminded', exists (select 1 from public.live_reminders r where r.broadcast_id = b.id and r.user_id = (select auth.uid()))
  )
  from public.groups g
  left join public.profiles h on h.id = b.host_id
  where g.id = b.group_id;
$$;

revoke all on function private.live_card(public.live_broadcasts) from public;
grant execute on function private.live_card(public.live_broadcasts) to authenticated;

-- A group's live and upcoming broadcasts; minutes for those who may start one.
create function public.group_live(target_group uuid)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select jsonb_build_object(
    'live', (select private.live_card(b) from public.live_broadcasts b where b.group_id = target_group and b.status = 'live'),
    'scheduled', coalesce((select jsonb_agg(private.live_card(b) order by b.scheduled_at)
                           from public.live_broadcasts b where b.group_id = target_group and b.status = 'scheduled'), '[]'),
    'minutes_left', case when private.has_group_permission(target_group, 'live.start')
                         then private.live_minutes_left(target_group) end
  );
$$;

-- Broadcasts live right now in the user's groups (home).
create function public.my_live_broadcasts()
returns setof jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.live_card(b)
  from public.live_broadcasts b
  where b.status = 'live' and private.is_group_member(b.group_id)
  order by b.started_at desc
  limit 20;
$$;

create function public.live_broadcast(target_broadcast uuid)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.live_card(b) from public.live_broadcasts b where b.id = target_broadcast;
$$;

revoke all on function public.group_live(uuid), public.my_live_broadcasts(), public.live_broadcast(uuid) from public;
grant execute on function public.group_live(uuid), public.my_live_broadcasts(), public.live_broadcast(uuid) to authenticated;
grant execute on function private.live_minutes_left(uuid) to authenticated;

-- Group pages and rooms follow broadcasts and comments live (RLS applies to Realtime).
alter publication supabase_realtime add table public.live_broadcasts, public.live_comments;
