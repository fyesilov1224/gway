-- 0077_push_wakeup
-- Pushes go out at once (docs/ARCHITECTURE.md §3c, Push; user report 2026-11-04 "mesajlar geç gidiyor"): a new
-- notification row wakes the API's push dispatcher through LISTEN/NOTIFY instead of waiting for its next poll.
-- The channel carries no data, so nothing about the notification leaves the table.
-- owner: notifications

create or replace function private.wake_push_dispatcher()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform pg_notify('gway_push', '');
  return null;
end;
$$;

revoke all on function private.wake_push_dispatcher() from public;

create trigger notifications_wake_push
  after insert on public.notifications
  for each statement execute function private.wake_push_dispatcher();
