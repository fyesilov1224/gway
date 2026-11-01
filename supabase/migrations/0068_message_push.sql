-- 0068_message_push
-- Chat messages ring the phone (docs/ARCHITECTURE.md §3c, Push, Mesaj bildirimi): a trigger on messages writes
-- `message` notifications for the backend to push. They are not part of the in-app notification list.

-- ---------------------------------------------------------------------------
-- Preference (notifications owns the table); on by default like every other
-- ---------------------------------------------------------------------------
alter table public.notification_preferences add column messages boolean not null default true;
grant insert (messages), update (messages) on public.notification_preferences to authenticated;

-- ---------------------------------------------------------------------------
-- notifications: the conversation and its latest message
-- ---------------------------------------------------------------------------
alter table public.notifications
  add column conversation_id uuid references public.conversations (id) on delete cascade,
  add column message_id uuid references public.messages (id) on delete cascade;

create index notifications_conversation_idx on public.notifications (conversation_id) where conversation_id is not null;
create index notifications_message_idx on public.notifications (message_id) where message_id is not null;

alter table public.notifications drop constraint notifications_type_check;
alter table public.notifications add constraint notifications_type_check
  check (type in ('like', 'comment', 'reply', 'comment_like', 'mention', 'follow', 'follow_request', 'follow_accepted',
                  'live_scheduled', 'live_started', 'event_promoted', 'event_updated', 'event_canceled', 'event_reminder',
                  'case_vote', 'sanction_applied', 'appeal_submitted', 'appeal_decided',
                  'event_approved', 'event_declined', 'event_review', 'goal_completed',
                  'teammate_request', 'teammate_accepted', 'match_created', 'match_super_liked',
                  'welcome_requested', 'welcome_matched', 'welcome_released', 'welcome_withdrawn', 'welcome_thanked',
                  'league_result', 'event_series_limit', 'tonight_table_invite', 'tonight_table_ready',
                  'event_venue_revealed', 'handshake', 'message'));

-- Message rows exist only to be pushed: the app's list, unread count and live arrivals never see them.
drop policy notifications_select_own on public.notifications;
drop policy notifications_update_own on public.notifications;
drop policy notifications_delete_own on public.notifications;
create policy notifications_select_own on public.notifications for select to authenticated
  using (recipient_id = (select auth.uid()) and type <> 'message');
create policy notifications_update_own on public.notifications for update to authenticated
  using (recipient_id = (select auth.uid()) and type <> 'message')
  with check (recipient_id = (select auth.uid()) and type <> 'message');
create policy notifications_delete_own on public.notifications for delete to authenticated
  using (recipient_id = (select auth.uid()) and type <> 'message');

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
             when 'match_created' then p.match_alerts
             when 'match_super_liked' then p.match_alerts
             when 'message' then p.messages
             else true
           end
    from public.notification_preferences p where p.user_id = uid
  ), true);
$$;

-- ---------------------------------------------------------------------------
-- Trigger on messages (messaging's table, notifications' rows: the same pattern as every notification trigger)
-- ---------------------------------------------------------------------------
-- Direct: the other person once they accepted the chat (a request does not ring). Group: every member but the
-- sender. A burst from one chat stays one notification: a row still waiting for the push takes the newest message.
create function private.notify_message()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  conv public.conversations;
begin
  select * into conv from public.conversations c where c.id = new.conversation_id;
  if not found then
    return null;
  end if;

  with recipients as (
    select m.user_id as uid
    from public.group_members m
    where conv.kind = 'group' and m.group_id = conv.group_id and m.user_id <> new.sender_id
    union
    select cm.user_id
    from public.conversation_members cm
    where conv.kind = 'direct' and cm.conversation_id = conv.id and cm.user_id <> new.sender_id and cm.state = 'active'
  ), wanted as (
    select r.uid from recipients r
    where not private.is_blocked_between(r.uid, new.sender_id)
      and private.is_account_active(r.uid)
      and private.wants_notification(r.uid, 'message')
  ), refreshed as (
    update public.notifications n
    set message_id = new.id, actor_id = new.sender_id, created_at = now()
    from wanted w
    where n.recipient_id = w.uid and n.type = 'message' and n.conversation_id = conv.id and n.pushed_at is null
    returning n.recipient_id
  )
  insert into public.notifications (recipient_id, actor_id, type, conversation_id, message_id)
  select w.uid, new.sender_id, 'message', conv.id, new.id
  from wanted w
  where w.uid not in (select r.recipient_id from refreshed r);

  return null;
end;
$$;

revoke all on function private.notify_message() from public;

create trigger notify_message
  after insert on public.messages
  for each row execute function private.notify_message();
