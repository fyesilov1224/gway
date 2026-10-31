begin;
create extension if not exists pgtap with schema extensions;

select plan(16);

-- o1 owns group 5501 (İstanbul); a1 explores, b1 is someone else.
insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-00000055d001', 'explore-owner@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000055a001', 'explore-a1@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000055b001', 'explore-b1@test.local', 'authenticated', 'authenticated');
insert into public.profiles (id, username, display_name) values
  ('00000000-0000-0000-0000-00000055d001', 'explore_owner', 'Owner'),
  ('00000000-0000-0000-0000-00000055a001', 'explore_a1', 'A1'),
  ('00000000-0000-0000-0000-00000055b001', 'explore_b1', 'B1');

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;
create function pg_temp.ev(i int) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000005500e' || i)::uuid $$;

-- Outlines and the point lookup -------------------------------------------------------------------------------------
select is((select count(*)::int from public.province_shapes), 81, 'every province has an outline');
select is(private.province_at(40.990, 29.029), 34::smallint, 'Kadıköy is in İstanbul');
select is(private.province_at(37.035, 27.430), 48::smallint, 'Bodrum is in Muğla');
select is(private.province_at(40.9833, 27.5167), 59::smallint, 'a point on a simplified coast falls to the nearest province');
select is(private.province_at(34.0, 30.0), null, 'the open sea is in no province');

-- Events: 1 Bodrum point, 2 no point (group province), 3 future, 4 absent, 5 canceled, 6 surprise with an Ankara venue.
select pg_temp.act('00000000-0000-0000-0000-00000055d001');
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id, province)
values ('00000000-0000-0000-0000-000000005501', 'explore.test', 'Explore', 'hiking', 'open', '00000000-0000-0000-0000-00000055d001', 34);
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-000000005501', '00000000-0000-0000-0000-00000055d001');
-- Setup only: six events are over the free plan's monthly limit, which 15_events tests.
alter table public.events disable trigger events_guard;
insert into public.events (id, group_id, created_by, title, starts_at, location, meeting_lat, meeting_lng, surprise_reveal_hours)
select pg_temp.ev(i), '00000000-0000-0000-0000-000000005501', '00000000-0000-0000-0000-00000055d001', 'Gezi ' || i,
       now() + interval '1 day', 'Yer', case when i = 1 then 37.035 end, case when i = 1 then 27.430 end, case when i = 6 then 3 end
from generate_series(1, 6) i;
alter table public.events enable trigger events_guard;
insert into public.event_venues (event_id, location, meeting_lat, meeting_lng) values (pg_temp.ev(6), 'Kızılay', 39.920, 32.854);
select is((select province from public.events where id = pg_temp.ev(1)), 48::smallint, 'an event gets the province of its point');
select is((select province from public.event_venues where event_id = pg_temp.ev(6)), 6::smallint, 'a hidden venue too');

select pg_temp.act('00000000-0000-0000-0000-00000055a001');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-000000005501', '00000000-0000-0000-0000-00000055a001');
insert into public.event_attendees (event_id, user_id) select pg_temp.ev(i), '00000000-0000-0000-0000-00000055a001' from generate_series(1, 6) i;

-- Setup only: move the events into the past, mark one absent and cancel one.
reset role;
alter table public.events disable trigger user;
update public.events set starts_at = now() - interval '3 days' where id in (pg_temp.ev(1), pg_temp.ev(2), pg_temp.ev(4), pg_temp.ev(5), pg_temp.ev(6));
update public.events set canceled_at = now(), cancel_reason = 'Hava' where id = pg_temp.ev(5);
alter table public.events enable trigger user;
alter table public.event_attendees disable trigger user;
update public.event_attendees set no_show_at = now() where event_id = pg_temp.ev(4);
alter table public.event_attendees enable trigger user;

-- The map -------------------------------------------------------------------------------------------------------------
set local role authenticated;
select throws_ok($$ select * from public.province_shapes $$, '42501', null, 'clients do not read the outlines table');
select pg_temp.act('00000000-0000-0000-0000-00000055a001');
select is((public.my_exploration() ->> 'event_count')::int, 3, 'only events attended: started, not absent, not canceled');
select is(
  (select array_agg((p ->> 'id')::int order by (p ->> 'id')::int) from jsonb_array_elements(public.my_exploration() -> 'provinces') p),
  array[6, 34, 48], 'the point''s province, the group''s province and the surprise venue''s province');
select is(jsonb_array_length(public.my_exploration() -> 'points'), 2, 'the points of the events with one');
select is((public.my_exploration() ->> 'province_total')::int, 81, 'out of 81');
select pg_temp.act('00000000-0000-0000-0000-00000055b001');
select is((public.my_exploration() ->> 'event_count')::int, 0, 'everyone sees only their own map');
reset role;
set local role anon;
select throws_ok($$ select public.my_exploration() $$, '42501', null, 'visitors have no map');
reset role;

select is(private.explored_province_count('00000000-0000-0000-0000-00000055a001'), 3, 'the admin count');
select pg_temp.act('00000000-0000-0000-0000-00000055a001');
select lives_ok($$ select public.record_card_share('map') $$, 'sharing the map card is counted');

select finish();
rollback;
