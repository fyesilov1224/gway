-- 0026_live_notifications
-- A scheduled broadcast is announced to every member of the group, and every
-- member hears when it starts; members can turn both off in their preferences.
-- Rules: docs/ARCHITECTURE.md §3c (Bildirimler, Tercihler) and §8 (Planlı yayın ve hatırlatma).

-- ---------------------------------------------------------------------------
-- Preferences and types (notifications owns the tables)
-- ---------------------------------------------------------------------------
alter table public.notification_preferences add column live_broadcasts boolean not null default true;
grant insert (live_broadcasts), update (live_broadcasts) on public.notification_preferences to authenticated;

alter table public.notifications drop constraint notifications_type_check;
alter table public.notifications add constraint notifications_type_check
  check (type in ('like', 'comment', 'reply', 'comment_like', 'mention', 'follow', 'follow_request', 'follow_accepted',
                  'live_scheduled', 'live_started', 'event_promoted', 'event_updated', 'event_canceled', 'event_reminder',
                  'case_vote', 'sanction_applied', 'appeal_submitted', 'appeal_decided',
                  'event_approved', 'event_declined', 'event_review', 'goal_completed',
                  'teammate_request', 'teammate_accepted'));

create or replace function private.wants_notification(uid uuid, kind text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce((
    select case kind
             when 'event_reminder_day' then p.event_reminder_day
             when 'event_reminder_hour' then p.event_reminder_hour
             when 'event_updated' then p.event_updates
             when 'event_canceled' then p.event_updates
             when 'event_review' then p.event_review_requests
             when 'live_scheduled' then p.live_broadcasts
             when 'live_started' then p.live_broadcasts
             else true
           end
    from public.notification_preferences p where p.user_id = uid
  ), true);
$$;

-- ---------------------------------------------------------------------------
-- Triggers on live_broadcasts
-- ---------------------------------------------------------------------------

-- Scheduled: every member but the host; canceled: the announcement goes.
create function private.notify_live_scheduled()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'UPDATE' then
    delete from public.notifications where type = 'live_scheduled' and live_id = new.id;
    return null;
  end if;
  insert into public.notifications (recipient_id, actor_id, type, live_id)
  select m.user_id, new.host_id, 'live_scheduled', new.id
  from public.group_members m
  where m.group_id = new.group_id
    and m.user_id <> new.host_id
    and private.is_account_active(m.user_id)
    and not private.is_blocked_between(m.user_id, new.host_id)
    and private.wants_notification(m.user_id, 'live_scheduled');
  return null;
end;
$$;

revoke all on function private.notify_live_scheduled() from public;

create trigger notify_live_scheduled
  after insert on public.live_broadcasts
  for each row when (new.status = 'scheduled')
  execute function private.notify_live_scheduled();

create trigger notify_live_scheduled_canceled
  after update of status on public.live_broadcasts
  for each row when (old.status = 'scheduled' and new.status = 'canceled')
  execute function private.notify_live_scheduled();

-- Started: every member who wants it, and anyone who asked for a reminder anyway.
create or replace function private.notify_live_started()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.notifications (recipient_id, actor_id, type, live_id)
  select m.user_id, new.host_id, 'live_started', new.id
  from public.group_members m
  where m.group_id = new.group_id
    and m.user_id <> new.host_id
    and private.is_account_active(m.user_id)
    and not private.is_blocked_between(m.user_id, new.host_id)
    and (private.wants_notification(m.user_id, 'live_started')
         or exists (select 1 from public.live_reminders r where r.broadcast_id = new.id and r.user_id = m.user_id));
  return null;
end;
$$;

-- ---------------------------------------------------------------------------
-- my_notifications also returns when a scheduled broadcast starts
-- ---------------------------------------------------------------------------
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
    'live_scheduled_at', (select b.scheduled_at from public.live_broadcasts b where b.id = n.live_id),
    'event_id', n.event_id,
    'event_title', (select e.title from public.events e where e.id = n.event_id),
    'event_starts_at', (select e.starts_at from public.events e where e.id = n.event_id),
    'group', (select jsonb_build_object('id', g.id, 'handle', g.handle, 'name', g.name, 'logo_path', g.logo_path)
              from public.groups g where g.id = n.group_id),
    'sanction_type', (select s.type from public.sanctions s where s.id = n.sanction_id),
    'goal_id', n.goal_id,
    'goal_title', (select g.title from public.goals g where g.id = n.goal_id),
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
