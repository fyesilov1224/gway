-- 0073_call_ended_push
-- User decision 2026-11-02 (docs/ARCHITECTURE.md §8c, Akış): a ringing push opens the phone's incoming call screen, so
-- when the call stops ringing (the caller gives up, the callee declines, or it is answered elsewhere) the callee's
-- phone hears about it and closes that screen. Like call_incoming it exists only to be pushed (hidden from the list).
-- owner: live (rows), notifications (table)

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
                  'call_incoming', 'call_missed', 'call_ended',
                  'call_permission_granted', 'call_permission_declined', 'call_permission_revoked'));

drop policy notifications_select_own on public.notifications;
drop policy notifications_update_own on public.notifications;
drop policy notifications_delete_own on public.notifications;
create policy notifications_select_own on public.notifications for select to authenticated
  using (recipient_id = (select auth.uid()) and type not in ('message', 'call_incoming', 'call_ended'));
create policy notifications_update_own on public.notifications for update to authenticated
  using (recipient_id = (select auth.uid()) and type not in ('message', 'call_incoming', 'call_ended'))
  with check (recipient_id = (select auth.uid()) and type not in ('message', 'call_incoming', 'call_ended'));
create policy notifications_delete_own on public.notifications for delete to authenticated
  using (recipient_id = (select auth.uid()) and type not in ('message', 'call_incoming', 'call_ended'));

-- As in 0071, plus call_ended once a ringing push went out and the call stops ringing without being missed.
create or replace function private.notify_call()
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
  elsif old.status = 'ringing' and new.status in ('canceled', 'declined', 'active')
        and exists (select 1 from public.notifications n
                    where n.call_id = new.id and n.type = 'call_incoming' and n.pushed_at is not null) then
    insert into public.notifications (recipient_id, actor_id, type, conversation_id, call_id)
    values (new.callee_id, new.caller_id, 'call_ended', new.conversation_id, new.id);
  end if;
  -- A ringing push that has not gone out yet is pointless once the call is answered or over.
  if tg_op = 'UPDATE' and new.status <> 'ringing' then
    delete from public.notifications n where n.call_id = new.id and n.type = 'call_incoming' and n.pushed_at is null;
  end if;
  return null;
end;
$$;

revoke all on function private.notify_call() from public;
