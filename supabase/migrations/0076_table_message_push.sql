-- 0076_table_message_push
-- Tonight's small table chat rings too (docs/ARCHITECTURE.md §3c, Mesaj bildirimi, user request 2026-11-03): everyone
-- at the table but the sender, under the "Grup mesajları" preference like a group chat.

-- As in 0075, with the table's members as recipients.
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
    where conv.kind in ('direct', 'table') and cm.conversation_id = conv.id and cm.user_id <> new.sender_id
      and cm.state = 'active'
  ), wanted as (
    select r.uid from recipients r
    where not private.is_blocked_between(r.uid, new.sender_id)
      and private.is_account_active(r.uid)
      and private.wants_notification(r.uid, case when conv.kind = 'direct' then 'message' else 'group_message' end)
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
