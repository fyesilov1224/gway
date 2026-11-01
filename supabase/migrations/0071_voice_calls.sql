-- 0071_voice_calls
-- Phase 15.11: one-to-one voice calls between matched people, only for those the platform team allowed
-- (docs/ARCHITECTURE.md §8c). Calls live in the live module (LiveKit); notifications rows come from triggers here.

-- ---------------------------------------------------------------------------
-- call_permissions (owner: live): one row a person
-- ---------------------------------------------------------------------------
create table public.call_permissions (
  user_id      uuid primary key references public.profiles (id) on delete cascade,
  status       text not null check (status in ('requested', 'active', 'declined', 'revoked')),
  note         text check (char_length(note) <= 300),
  requested_at timestamptz,
  decided_at   timestamptz,
  decided_by   uuid references public.profiles (id) on delete set null,
  reason       text check (char_length(reason) <= 500),
  updated_at   timestamptz not null default now()
);

create index call_permissions_status_idx on public.call_permissions (status, requested_at);

comment on table public.call_permissions is
  'owner: live. Who may make voice calls: requested by the person, decided by the platform team (docs/ARCHITECTURE.md §8c).';

alter table public.call_permissions enable row level security;
revoke all on public.call_permissions from anon, authenticated;
grant select on public.call_permissions to authenticated;

create policy call_permissions_select on public.call_permissions for select to authenticated
  using (user_id = (select auth.uid()) or private.is_platform_staff(array['admin', 'support', 'moderator']));

-- ---------------------------------------------------------------------------
-- calls (owner: live)
-- ---------------------------------------------------------------------------
create table public.calls (
  id              uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations (id) on delete cascade,
  caller_id       uuid not null references public.profiles (id) on delete cascade,
  callee_id       uuid not null references public.profiles (id) on delete cascade,
  status          text not null default 'ringing'
                  check (status in ('ringing', 'active', 'ended', 'missed', 'declined', 'canceled')),
  created_at      timestamptz not null default now(),
  answered_at     timestamptz,
  ended_at        timestamptz,
  end_reason      text check (end_reason in ('hangup', 'time_limit', 'not_allowed', 'missed', 'declined', 'canceled')),
  ended_by        uuid references public.profiles (id) on delete set null,
  constraint calls_two_people check (caller_id <> callee_id)
);

create index calls_caller_idx on public.calls (caller_id, created_at desc);
create index calls_callee_idx on public.calls (callee_id, created_at desc);
create index calls_open_idx on public.calls (status) where status in ('ringing', 'active');

comment on table public.calls is
  'owner: live. Voice calls between two matched people; written by the backend. No audio is recorded.';

alter table public.calls enable row level security;
revoke all on public.calls from anon, authenticated;
grant select on public.calls to authenticated;

-- Only the two people: the platform team never sees whom a person called.
create policy calls_select on public.calls for select to authenticated
  using ((select auth.uid()) in (caller_id, callee_id));

-- The callee's app rings from the row; both see it change.
alter publication supabase_realtime add table public.calls;

-- ---------------------------------------------------------------------------
-- Rules
-- ---------------------------------------------------------------------------
create function private.has_call_permission(uid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (select 1 from public.call_permissions p where p.user_id = uid and p.status = 'active');
$$;

-- Why caller cannot call callee now, or null. Busy is checked separately (it needs locks).
create function private.call_blocker(caller uuid, callee uuid)
returns text
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if caller is null or callee is null or caller = callee
     or not private.is_account_active(caller) or not private.is_account_active(callee) then
    return 'call_forbidden';
  end if;
  if not private.has_call_permission(caller) then return 'call_no_permission'; end if;
  if private.is_blocked_between(caller, callee) then return 'call_blocked'; end if;
  if not private.are_matched(caller, callee) then return 'call_not_matched'; end if;
  if not private.has_matching_feature(caller, 'chat') then return 'call_chat_locked'; end if;
  if not private.has_call_permission(callee) then return 'call_peer_no_permission'; end if;
  if not private.has_matching_feature(callee, 'chat') then return 'call_peer_chat_locked'; end if;
  return null;
end;
$$;

create function private.in_open_call(uid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (select 1 from public.calls c
                 where c.status in ('ringing', 'active') and uid in (c.caller_id, c.callee_id));
$$;

-- Starts a call in a direct conversation as the acting user (the backend's acting transaction). Returns the call id.
create function private.start_call(conv uuid)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  me uuid := (select auth.uid());
  peer uuid;
  reason text;
  id uuid;
begin
  if not exists (select 1 from public.conversations c
                 where c.id = conv and c.kind = 'direct' and me in (c.user_a, c.user_b)) then
    raise exception 'call_forbidden' using errcode = 'P0001';
  end if;
  peer := private.conversation_peer(conv, me);
  reason := private.call_blocker(me, peer);
  if reason is not null then
    raise exception '%', reason using errcode = 'P0001';
  end if;
  -- Both people, smaller id first: two calls between the same pair cannot both start.
  perform pg_advisory_xact_lock(hashtext('call:' || least(me, peer)::text));
  perform pg_advisory_xact_lock(hashtext('call:' || greatest(me, peer)::text));
  if private.in_open_call(me) or private.in_open_call(peer) then
    raise exception 'call_busy' using errcode = 'P0001';
  end if;
  if (select count(*) from public.calls c where c.caller_id = me and c.created_at > now() - interval '1 minute') >= 3 then
    raise exception 'call_rate_limited' using errcode = 'P0001';
  end if;
  insert into public.calls (conversation_id, caller_id, callee_id) values (conv, me, peer) returning calls.id into id;
  return id;
end;
$$;

revoke all on function private.has_call_permission(uuid), private.call_blocker(uuid, uuid), private.in_open_call(uuid),
  private.start_call(uuid) from public;

-- The person asks for the feature (their own row; only to "requested"). Declined or revoked: again after 7 days.
create function private.request_call_permission(request_note text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  me uuid := (select auth.uid());
  current public.call_permissions;
begin
  if me is null or not private.is_account_active(me) then
    raise exception 'call_forbidden' using errcode = 'P0001';
  end if;
  if char_length(coalesce(request_note, '')) > 300 then
    raise exception 'call_note_too_long' using errcode = 'P0001';
  end if;
  select * into current from public.call_permissions where user_id = me;
  if found and current.status in ('requested', 'active') then
    raise exception 'call_permission_exists' using errcode = 'P0001';
  end if;
  if found and current.decided_at > now() - interval '7 days' then
    raise exception 'call_permission_cooldown' using errcode = 'P0001';
  end if;
  insert into public.call_permissions (user_id, status, note, requested_at, updated_at)
  values (me, 'requested', nullif(btrim(request_note), ''), now(), now())
  on conflict (user_id) do update
    set status = 'requested', note = excluded.note, requested_at = excluded.requested_at,
        decided_at = null, decided_by = null, reason = null, updated_at = excluded.updated_at;
end;
$$;

create function public.request_call_permission(request_note text default null)
returns void
language sql
security invoker
set search_path = ''
as $$
  select private.request_call_permission(request_note);
$$;

revoke all on function private.request_call_permission(text), public.request_call_permission(text) from public;
grant execute on function private.request_call_permission(text), public.request_call_permission(text) to authenticated;

-- ---------------------------------------------------------------------------
-- Notifications (notifications owns the table; the same pattern as every trigger)
-- ---------------------------------------------------------------------------
alter table public.notifications add column call_id uuid references public.calls (id) on delete cascade;
create index notifications_call_idx on public.notifications (call_id) where call_id is not null;

alter table public.notifications drop constraint notifications_type_check;
alter table public.notifications add constraint notifications_type_check
  check (type in ('like', 'comment', 'reply', 'comment_like', 'mention', 'follow', 'follow_request', 'follow_accepted',
                  'live_scheduled', 'live_started', 'event_promoted', 'event_updated', 'event_canceled', 'event_reminder',
                  'case_vote', 'sanction_applied', 'appeal_submitted', 'appeal_decided',
                  'event_approved', 'event_declined', 'event_review', 'goal_completed',
                  'teammate_request', 'teammate_accepted', 'match_created', 'match_super_liked',
                  'welcome_requested', 'welcome_matched', 'welcome_released', 'welcome_withdrawn', 'welcome_thanked',
                  'league_result', 'event_series_limit', 'tonight_table_invite', 'tonight_table_ready',
                  'event_venue_revealed', 'handshake', 'message',
                  'call_incoming', 'call_missed',
                  'call_permission_granted', 'call_permission_declined', 'call_permission_revoked'));

-- Like chat messages, a ringing call exists only to be pushed.
drop policy notifications_select_own on public.notifications;
drop policy notifications_update_own on public.notifications;
drop policy notifications_delete_own on public.notifications;
create policy notifications_select_own on public.notifications for select to authenticated
  using (recipient_id = (select auth.uid()) and type not in ('message', 'call_incoming'));
create policy notifications_update_own on public.notifications for update to authenticated
  using (recipient_id = (select auth.uid()) and type not in ('message', 'call_incoming'))
  with check (recipient_id = (select auth.uid()) and type not in ('message', 'call_incoming'));
create policy notifications_delete_own on public.notifications for delete to authenticated
  using (recipient_id = (select auth.uid()) and type not in ('message', 'call_incoming'));

create function private.notify_call()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    insert into public.notifications (recipient_id, actor_id, type, conversation_id, call_id)
    values (new.callee_id, new.caller_id, 'call_incoming', new.conversation_id, new.id);
  elsif new.status = 'missed' and old.status = 'ringing' then
    insert into public.notifications (recipient_id, actor_id, type, conversation_id, call_id)
    values (new.callee_id, new.caller_id, 'call_missed', new.conversation_id, new.id);
  end if;
  -- A ringing push that has not gone out yet is pointless once the call is answered or over.
  if tg_op = 'UPDATE' and new.status <> 'ringing' then
    delete from public.notifications n where n.call_id = new.id and n.type = 'call_incoming' and n.pushed_at is null;
  end if;
  return null;
end;
$$;

revoke all on function private.notify_call() from public;

create trigger notify_call
  after insert or update of status on public.calls
  for each row execute function private.notify_call();

-- Granted, declined or revoked: the person hears about it (the actor is the person, so no staff name shows).
create function private.notify_call_permission()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'UPDATE' and new.status = old.status then
    return null;
  end if;
  if new.status in ('active', 'declined', 'revoked') then
    insert into public.notifications (recipient_id, actor_id, type)
    values (new.user_id, new.user_id, case new.status when 'active' then 'call_permission_granted'
                                                      when 'declined' then 'call_permission_declined'
                                                      else 'call_permission_revoked' end);
  end if;
  return null;
end;
$$;

revoke all on function private.notify_call_permission() from public;

create trigger notify_call_permission
  after insert or update of status on public.call_permissions
  for each row execute function private.notify_call_permission();

-- The notification list also carries the chat, so a missed call opens it (§8c).
create or replace function public.my_notifications(before_id bigint default null, page_size int default 30)
returns setof jsonb
language sql
stable
security invoker
set search_path = ''
as $f$
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
    'live_scheduled_at', (select b.scheduled_at from public.live_broadcasts b where b.id = n.live_id),
    'event_id', n.event_id,
    'event_title', (select e.title from public.events e where e.id = n.event_id),
    'event_starts_at', (select e.starts_at from public.events e where e.id = n.event_id),
    'group', (select jsonb_build_object('id', g.id, 'handle', g.handle, 'name', g.name, 'logo_path', g.logo_path)
              from public.groups g where g.id = n.group_id),
    'sanction_type', (select s.type from public.sanctions s where s.id = n.sanction_id),
    'goal_id', n.goal_id,
    'goal_title', (select g.title from public.goals g where g.id = n.goal_id),
    'match_id', n.match_id,
    'conversation_id', n.conversation_id,
    'i_follow', private.user_follows((select auth.uid()), n.actor_id),
    'requested', exists (select 1 from public.follow_requests r
                         where r.requester_id = (select auth.uid()) and r.target_id = n.actor_id)
  )
  from public.notifications n
  join public.profiles a on a.id = n.actor_id
  where n.recipient_id = (select auth.uid()) and (before_id is null or n.id < before_id)
  order by n.id desc
  limit least(greatest(page_size, 1), 60);
$f$;
