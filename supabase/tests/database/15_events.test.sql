begin;
create extension if not exists pgtap with schema extensions;

select plan(35);

-- e1 owner, e2 Yönetici, e3..e6 members, e7 outsider, e8 platform admin.
insert into auth.users (id, email, aud, role)
select ('00000000-0000-0000-0000-0000000ef00' || i)::uuid, 'e' || i || '@test.local', 'authenticated', 'authenticated'
from generate_series(1, 8) i;
insert into public.profiles (id, username, display_name)
select ('00000000-0000-0000-0000-0000000ef00' || i)::uuid, 'event_user' || i, 'Event ' || i
from generate_series(1, 8) i;
insert into public.platform_staff (user_id, role) values ('00000000-0000-0000-0000-0000000ef008', 'admin');

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;
create function pg_temp.u(i int) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000000ef00' || i)::uuid $$;
create function pg_temp.join_event(i int, e text) returns void language sql as $$
  select pg_temp.act(pg_temp.u(i)::text);
  insert into public.event_attendees (event_id, user_id) values (e::uuid, pg_temp.u(i));
$$;
create function pg_temp.status_of(i int, e text) returns text language sql as $$
  select status from public.event_attendees where event_id = e::uuid and user_id = pg_temp.u(i);
$$;

select pg_temp.act('00000000-0000-0000-0000-0000000ef001');
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id)
values ('00000000-0000-0000-0000-0000000ec001', 'etkinlik.grubu', 'Etkinlik Grubu', 'hiking', 'open', pg_temp.u(1));
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-0000000ec001', pg_temp.u(1));
do $$ begin
  for i in 2..6 loop
    perform pg_temp.act(pg_temp.u(i)::text);
    insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-0000000ec001', pg_temp.u(i));
  end loop;
end $$;
select pg_temp.act('00000000-0000-0000-0000-0000000ef001');
insert into public.group_member_roles (group_id, user_id, role) values ('00000000-0000-0000-0000-0000000ec001', pg_temp.u(2), 'admin');

-- Creating (backend writes) ------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000ef003');
select throws_ok(
  $$ insert into public.events (group_id, created_by, title, starts_at, location)
     values ('00000000-0000-0000-0000-0000000ec001', pg_temp.u(3), 'Üye etkinliği', now() + interval '1 day', 'Park') $$,
  'P0001', 'event_forbidden', 'members without events.manage cannot create events'
);
select pg_temp.act('00000000-0000-0000-0000-0000000ef002');
select throws_ok(
  $$ insert into public.events (group_id, created_by, title, starts_at, location)
     values ('00000000-0000-0000-0000-0000000ec001', pg_temp.u(2), 'Hemen', now() + interval '5 minutes', 'Park') $$,
  'P0001', 'event_time_invalid', 'an event starts at least 15 minutes ahead'
);
select lives_ok(
  $$ insert into public.events (id, group_id, created_by, title, starts_at, location, capacity, fee_amount, fee_currency)
     values ('00000000-0000-0000-0000-0000000ee001', '00000000-0000-0000-0000-0000000ec001', pg_temp.u(2),
             'Belgrad Ormanı yürüyüşü', now() + interval '2 days', ' Bahçeköy girişi ', 2, 15000, 'TRY') $$,
  'a Yönetici creates an event'
);
select is((select location from public.events where id = '00000000-0000-0000-0000-0000000ee001'), 'Bahçeköy girişi', 'text is trimmed');
select lives_ok(
  $$ insert into public.events (id, group_id, created_by, title, starts_at, location)
     values ('00000000-0000-0000-0000-0000000ee002', '00000000-0000-0000-0000-0000000ec001', pg_temp.u(2),
             'Akşam buluşması', now() + interval '30 minutes', 'Kadıköy') $$,
  'a second event this month'
);
select throws_ok(
  $$ insert into public.events (group_id, created_by, title, starts_at, location)
     values ('00000000-0000-0000-0000-0000000ec001', pg_temp.u(2), 'Üçüncü', now() + interval '3 days', 'Park') $$,
  'P0001', 'monthly_limit_reached', 'the free plan allows two events a month'
);

-- Reading ------------------------------------------------------------------------------------------------
set local role anon;
select set_config('request.jwt.claims', '', true);
select is((select count(*)::int from public.events where group_id = '00000000-0000-0000-0000-0000000ec001'), 2, 'anyone sees the events of a visible group');
select is(jsonb_array_length(public.group_events('00000000-0000-0000-0000-0000000ec001')->'events'), 2, 'group_events lists upcoming ones');
reset role;
set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000ef002');
select is((public.group_events('00000000-0000-0000-0000-0000000ec001')->>'events_left')::int, 0, 'managers see the events left this month');
select pg_temp.act('00000000-0000-0000-0000-0000000ef003');
select is(public.group_events('00000000-0000-0000-0000-0000000ec001')->>'events_left', null, 'members do not');
select throws_ok($$ update public.events set title = 'Başka' $$, '42501', null, 'clients cannot write events');
reset role;

-- Attendance and the waitlist (backend writes as the joiner) ---------------------------------------------------
select pg_temp.join_event(3, '00000000-0000-0000-0000-0000000ee001');
select pg_temp.join_event(4, '00000000-0000-0000-0000-0000000ee001');
select pg_temp.join_event(5, '00000000-0000-0000-0000-0000000ee001');
select is(pg_temp.status_of(5, '00000000-0000-0000-0000-0000000ee001'), 'waitlisted', 'a full event puts newcomers on the waitlist');
select is((select going_count || '/' || waitlist_count from public.events where id = '00000000-0000-0000-0000-0000000ee001'), '2/1', 'counters follow');
select throws_ok(
  $$ select pg_temp.join_event(7, '00000000-0000-0000-0000-0000000ee001') $$,
  'P0001', 'attendance_forbidden', 'outsiders cannot join'
);
select pg_temp.act('00000000-0000-0000-0000-0000000ef003');
select throws_ok(
  $$ delete from public.event_attendees where user_id = pg_temp.u(4) $$,
  'P0001', 'attendance_forbidden', 'nobody removes someone else'
);
delete from public.event_attendees where user_id = pg_temp.u(3);
select is(pg_temp.status_of(5, '00000000-0000-0000-0000-0000000ee001'), 'going', 'a freed seat goes to the waitlist');
select is((select count(*)::int from public.notifications where recipient_id = pg_temp.u(5) and type = 'event_promoted'), 1,
  'and tells the promoted person');

select pg_temp.join_event(6, '00000000-0000-0000-0000-0000000ee001');
select pg_temp.act('00000000-0000-0000-0000-0000000ef002');
select throws_ok(
  $$ update public.events set capacity = 1 where id = '00000000-0000-0000-0000-0000000ee001' $$,
  'P0001', 'capacity_below_going', 'capacity cannot drop below the people going'
);
update public.events set capacity = 3 where id = '00000000-0000-0000-0000-0000000ee001';
select is(pg_temp.status_of(6, '00000000-0000-0000-0000-0000000ee001'), 'going', 'more room promotes the waitlist');

update public.events set starts_at = now() + interval '3 days' where id = '00000000-0000-0000-0000-0000000ee001';
select is((select count(*)::int from public.notifications where type = 'event_updated' and event_id = '00000000-0000-0000-0000-0000000ee001'), 3,
  'a new time is announced to everyone going');

-- Leaving the group drops upcoming attendance.
select pg_temp.act('00000000-0000-0000-0000-0000000ef006');
delete from public.group_members where group_id = '00000000-0000-0000-0000-0000000ec001' and user_id = pg_temp.u(6);
select is(pg_temp.status_of(6, '00000000-0000-0000-0000-0000000ee001'), null, 'leaving the group leaves its events');

-- Members see who goes; outsiders only the count.
set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000ef007');
select is((select count(*)::int from public.event_attendees), 0, 'outsiders do not see attendees');
select is((public.event_detail('00000000-0000-0000-0000-0000000ee001'))->'attendees', 'null'::jsonb, 'nor in the detail');
select pg_temp.act('00000000-0000-0000-0000-0000000ef004');
select is(jsonb_array_length((public.event_detail('00000000-0000-0000-0000-0000000ee001'))->'attendees'), 2, 'members do');
reset role;

-- Reminders (system job) ----------------------------------------------------------------------------------------
select pg_temp.join_event(4, '00000000-0000-0000-0000-0000000ee002');
select set_config('request.jwt.claims', '', true);
select is(private.send_event_reminders(), 1, 'the hour reminder goes to people going');
select is(private.send_event_reminders(), 0, 'once');

-- Cancel -----------------------------------------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000ef002');
update public.events set canceled_at = now(), cancel_reason = 'Hava durumu' where id = '00000000-0000-0000-0000-0000000ee001';
select is((select count(*)::int from public.notifications where type = 'event_canceled' and event_id = '00000000-0000-0000-0000-0000000ee001'), 2,
  'a cancellation is announced');
select throws_ok(
  $$ select pg_temp.join_event(3, '00000000-0000-0000-0000-0000000ee001') $$,
  'P0001', 'event_closed', 'a canceled event takes nobody'
);

-- Polls ------------------------------------------------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000ef003');
select throws_ok(
  $$ insert into public.polls (group_id, created_by, question) values ('00000000-0000-0000-0000-0000000ec001', pg_temp.u(3), 'Ne zaman?') $$,
  'P0001', 'poll_forbidden', 'members cannot open polls'
);
select pg_temp.act('00000000-0000-0000-0000-0000000ef002');
insert into public.polls (id, group_id, created_by, question, is_anonymous)
values ('00000000-0000-0000-0000-0000000ea001', '00000000-0000-0000-0000-0000000ec001', pg_temp.u(2), 'Hangi gün?', true);
insert into public.poll_options (poll_id, position, label) values
  ('00000000-0000-0000-0000-0000000ea001', 0, 'Cumartesi'), ('00000000-0000-0000-0000-0000000ea001', 1, 'Pazar');

set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000ef003');
select lives_ok(
  $$ insert into public.poll_votes (poll_id, option_id, user_id)
     select poll_id, id, pg_temp.u(3) from public.poll_options where poll_id = '00000000-0000-0000-0000-0000000ea001' and position = 0 $$,
  'a member votes'
);
select throws_ok(
  $$ insert into public.poll_votes (poll_id, option_id, user_id)
     select poll_id, id, pg_temp.u(3) from public.poll_options where poll_id = '00000000-0000-0000-0000-0000000ea001' and position = 1 $$,
  'P0001', 'poll_single_choice', 'one vote on a single-choice poll'
);
select pg_temp.act('00000000-0000-0000-0000-0000000ef004');
select is((select count(*)::int from public.poll_votes), 0, 'votes on an anonymous poll stay hidden');
select is(((public.group_polls('00000000-0000-0000-0000-0000000ec001'))->0->'options'->0->>'votes')::int, 1, 'but the results count them');
select pg_temp.act('00000000-0000-0000-0000-0000000ef007');
select is(jsonb_array_length(public.group_polls('00000000-0000-0000-0000-0000000ec001')), 0, 'outsiders see no polls');
reset role;

select pg_temp.act('00000000-0000-0000-0000-0000000ef002');
update public.polls set closed_at = now() where id = '00000000-0000-0000-0000-0000000ea001';
set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000ef004');
select throws_ok(
  $$ insert into public.poll_votes (poll_id, option_id, user_id)
     select poll_id, id, pg_temp.u(4) from public.poll_options where poll_id = '00000000-0000-0000-0000-0000000ea001' and position = 1 $$,
  '42501', null, 'a closed poll takes no votes'
);
reset role;

select * from finish();
rollback;
