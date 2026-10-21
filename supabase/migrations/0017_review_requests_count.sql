-- 0017_review_requests_count
-- Review requests skip people who turned them off before counting, like the reminders do
-- (docs/ARCHITECTURE.md §3d, Değerlendirme isteği).

create or replace function private.send_review_requests()
returns int
language plpgsql
security definer
set search_path = ''
as $$
declare
  e public.events;
  person uuid;
  sent int := 0;
begin
  for e in
    select * from public.events
    where canceled_at is null and review_asked_at is null
      and coalesce(ends_at, starts_at + interval '2 hours') <= now()
      and coalesce(ends_at, starts_at + interval '2 hours') > now() - interval '1 day'
    for update skip locked
  loop
    for person in
      select a.user_id from public.event_attendees a
      where a.event_id = e.id and a.status = 'going' and private.wants_notification(a.user_id, 'event_review')
    loop
      perform private.notify_event(person, e.id, 'event_review');
      sent := sent + 1;
    end loop;
    update public.events set review_asked_at = now() where id = e.id;
  end loop;
  return sent;
end;
$$;
