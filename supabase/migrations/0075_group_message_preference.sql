-- 0075_group_message_preference
-- Message notices split by chat kind (docs/ARCHITECTURE.md §3c, Mesaj bildirimi, user request 2026-11-03):
-- `messages` now covers direct chats only and `group_messages` covers group chats. Everyone keeps the choice they
-- had made for both.

alter table public.notification_preferences add column group_messages boolean not null default true;
update public.notification_preferences set group_messages = messages;
grant insert (group_messages), update (group_messages) on public.notification_preferences to authenticated;

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
             when 'group_message' then p.group_messages
             else true
           end
    from public.notification_preferences p where p.user_id = uid
  ), true);
$$;

-- As in 0068, with the preference read by chat kind.
create or replace function private.notify_message()
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
      and private.wants_notification(r.uid, case conv.kind when 'group' then 'group_message' else 'message' end)
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
