begin;
create extension if not exists pgtap with schema extensions;

select plan(16);

-- k1 owner (attends both events), k2 member (attends the first), k3 outsider.
insert into auth.users (id, email, aud, role)
select ('00000000-0000-0000-0000-0000000ca00' || i)::uuid, 'k' || i || '@test.local', 'authenticated', 'authenticated'
from generate_series(1, 3) i;
insert into public.profiles (id, username, display_name)
select ('00000000-0000-0000-0000-0000000ca00' || i)::uuid, 'calendar_user' || i, 'Takvim ' || i
from generate_series(1, 3) i;

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;
create function pg_temp.u(i int) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000000ca00' || i)::uuid $$;
create function pg_temp.g() returns uuid language sql as $$ select '00000000-0000-0000-0000-0000000cb001'::uuid $$;
create function pg_temp.e(i int) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000000ce00' || i)::uuid $$;

select pg_temp.act('00000000-0000-0000-0000-0000000ca001');
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id)
values (pg_temp.g(), 'takvim.grubu', 'Takvim Grubu', 'hiking', 'open', pg_temp.u(1));
insert into public.group_members (group_id, user_id) values (pg_temp.g(), pg_temp.u(1));
select pg_temp.act('00000000-0000-0000-0000-0000000ca002');
insert into public.group_members (group_id, user_id) values (pg_temp.g(), pg_temp.u(2));

-- Two overlapping events within the next day: 19–22 h and 20 h (no end: two hours).
select pg_temp.act('00000000-0000-0000-0000-0000000ca001');
insert into public.events (id, group_id, created_by, title, starts_at, ends_at, location) values
  (pg_temp.e(1), pg_temp.g(), pg_temp.u(1), 'Akşam yürüyüşü', now() + interval '19 hours', now() + interval '22 hours', 'Moda'),
  (pg_temp.e(2), pg_temp.g(), pg_temp.u(1), 'Gece koşusu', now() + interval '20 hours', null, 'Caddebostan');
insert into public.event_attendees (event_id, user_id) values (pg_temp.e(1), pg_temp.u(1)), (pg_temp.e(2), pg_temp.u(1));
select pg_temp.act('00000000-0000-0000-0000-0000000ca002');
insert into public.event_attendees (event_id, user_id) values (pg_temp.e(1), pg_temp.u(2));

-- Preferences (the user's own write) -----------------------------------------------------------------
select is(private.wants_notification(pg_temp.u(2), 'event_updated'), true, 'without a row every kind is wanted');
set local role authenticated;
select lives_ok(
  $$ insert into public.notification_preferences (user_id, event_reminder_day, event_updates) values (pg_temp.u(2), false, false) $$,
  'a user saves their own preferences'
);
select throws_ok(
  $$ insert into public.notification_preferences (user_id) values (pg_temp.u(3)) $$,
  '42501', null, 'nobody saves preferences for someone else'
);
select lives_ok(
  $$ update public.notification_preferences set event_reminder_hour = false where user_id = pg_temp.u(2) $$,
  'a user changes their preferences'
);
select pg_temp.act('00000000-0000-0000-0000-0000000ca003');
select is((select count(*)::int from public.notification_preferences), 0, 'others'' preferences are private');
reset role;
set local role anon;
select throws_ok($$ select * from public.notification_preferences $$, '42501', null, 'visitors cannot read preferences');
reset role;

-- Calendar --------------------------------------------------------------------------------------------
set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000ca002');
select is(jsonb_array_length(public.calendar_events(now(), now() + interval '7 days')), 1, 'my calendar has the events I attend');
select is(jsonb_array_length(public.calendar_events(now(), now() + interval '7 days', include_groups => true)), 2,
  'with my groups it has every event of my groups');
select is(jsonb_array_length(public.calendar_events(now(), now() + interval '90 days')), 0, 'ranges are at most 62 days');
select pg_temp.act('00000000-0000-0000-0000-0000000ca003');
select is(jsonb_array_length(public.calendar_events(now(), now() + interval '7 days', include_groups => true)), 0,
  'an outsider''s calendar is empty');
select is(jsonb_array_length(public.calendar_events(now(), now() + interval '7 days', pg_temp.g())), 2, 'a public group''s calendar is open');

select pg_temp.act('00000000-0000-0000-0000-0000000ca001');
select is(public.event_detail(pg_temp.e(1))->'conflicts'->0->>'title', 'Gece koşusu', 'the event page names my overlapping event');
select pg_temp.act('00000000-0000-0000-0000-0000000ca002');
select is(jsonb_array_length(public.event_detail(pg_temp.e(1))->'conflicts'), 0, 'no conflict without a second event');
reset role;

-- Notifications follow the preferences ------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000ca001');
update public.events set location = 'Moda sahili' where id = pg_temp.e(1);
select is(
  (select array_agg(recipient_id order by recipient_id) from public.notifications where event_id = pg_temp.e(1) and type = 'event_updated'),
  array[pg_temp.u(1)],
  'a change reaches only those who want change notices'
);

select set_config('request.jwt.claims', '', true);
select private.send_event_reminders();
select is((select count(*)::int from public.notifications where recipient_id = pg_temp.u(1) and type = 'event_reminder'), 2,
  'reminders go to those who want them');
select is((select count(*)::int from public.notifications where recipient_id = pg_temp.u(2) and type = 'event_reminder'), 0,
  'turned-off reminders are not written');

select * from finish();
rollback;
