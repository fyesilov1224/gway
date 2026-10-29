begin;
create extension if not exists pgtap with schema extensions;

select plan(23);

-- m1 owner, m2 member, m3 platform moderator.
insert into auth.users (id, email, aud, role)
select ('00000000-0000-0000-0000-0000000cc10' || i)::uuid, 'm' || i || '@test.local', 'authenticated', 'authenticated'
from generate_series(1, 3) i;
insert into public.profiles (id, username, display_name)
select ('00000000-0000-0000-0000-0000000cc10' || i)::uuid, 'map_user' || i, 'Harita ' || i
from generate_series(1, 3) i;
insert into public.platform_staff (user_id, role) values ('00000000-0000-0000-0000-0000000cc103', 'moderator');

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;
create function pg_temp.u(i int) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000000cc10' || i)::uuid $$;
create function pg_temp.grp(i int) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000000cc20' || i)::uuid $$;
create function pg_temp.ev(i int) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000000cc30' || i)::uuid $$;
-- A box around Istanbul, far from the seed's demo data only by chance; results are filtered to this test's rows.
create function pg_temp.items(kind text, category text default null) returns setof jsonb language sql as $$
  select i from jsonb_array_elements(public.map_items(40.5, 28.0, 41.5, 30.0, category)->kind) i
  where i->>'id' like '00000000-0000-0000-0000-0000000cc%';
$$;

-- Two groups in Istanbul (one suspended later), events with and without a meeting point.
select pg_temp.act('00000000-0000-0000-0000-0000000cc101');
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id) values
  (pg_temp.grp(1), 'harita.bir', 'Harita Bir', 'hiking', 'open', pg_temp.u(1)),
  (pg_temp.grp(2), 'harita.iki', 'Harita İki', 'music', 'open', pg_temp.u(1));
insert into public.group_members (group_id, user_id) values (pg_temp.grp(1), pg_temp.u(1)), (pg_temp.grp(2), pg_temp.u(1));
select pg_temp.act('00000000-0000-0000-0000-0000000cc102');
insert into public.group_members (group_id, user_id) values (pg_temp.grp(1), pg_temp.u(2));

-- Provinces --------------------------------------------------------------------------------------------
set local role anon;
select is((select count(*)::int from public.provinces), 81, 'everyone reads the 81 provinces');
select throws_ok($$ select public.map_items(0, 0, 1, 1) $$, '42501', null, 'the map needs a session');
reset role;
set local role authenticated;
select throws_ok($$ insert into public.provinces values (82, 'Yok', 0, 0) $$, '42501', null, 'nobody writes provinces');
reset role;

-- Group province ---------------------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000cc102');
select throws_ok($$ update public.groups set province = 34 where id = pg_temp.grp(1) $$, 'P0001', 'group_edit_forbidden',
  'members do not set the province');
select pg_temp.act('00000000-0000-0000-0000-0000000cc101');
select lives_ok($$ update public.groups set province = 34 where id in (pg_temp.grp(1), pg_temp.grp(2)) $$, 'the owner sets it');
select throws_ok($$ update public.groups set province = 99 where id = pg_temp.grp(1) $$, '23503', null, 'only real provinces');

-- Meeting point ------------------------------------------------------------------------------------------
-- Setup only: the monthly event limit of the free plan is tested in 15_events.
alter table public.events disable trigger user;
insert into public.events (id, group_id, created_by, title, starts_at, location, meeting_lat, meeting_lng) values
  (pg_temp.ev(1), pg_temp.grp(1), pg_temp.u(1), 'Belgrad yürüyüşü', now() + interval '2 days', 'Bahçeköy girişi', 41.1801, 28.9862),
  (pg_temp.ev(2), pg_temp.grp(1), pg_temp.u(1), 'Noktasız', now() + interval '2 days', 'Kadıköy', null, null),
  (pg_temp.ev(3), pg_temp.grp(2), pg_temp.u(1), 'İptal', now() + interval '2 days', 'Moda', 40.98, 29.02),
  (pg_temp.ev(4), pg_temp.grp(2), pg_temp.u(1), 'Geçmiş', now() + interval '2 days', 'Moda', 40.98, 29.03),
  (pg_temp.ev(5), pg_temp.grp(2), pg_temp.u(1), 'Konser', now() + interval '3 days', 'Harbiye', 41.04, 28.99);
update public.events set canceled_at = now(), cancel_reason = 'Yağmur' where id = pg_temp.ev(3);
update public.events set starts_at = now() - interval '1 day' where id = pg_temp.ev(4);
alter table public.events enable trigger user;

select throws_ok($$ update public.events set meeting_lat = 41 where id = pg_temp.ev(2) $$, '23514', null,
  'latitude and longitude come together');
select throws_ok($$ update public.events set meeting_lat = 91, meeting_lng = 29 where id = pg_temp.ev(2) $$, '23514', null,
  'only real coordinates');
select pg_temp.act('00000000-0000-0000-0000-0000000cc102');
select throws_ok($$ update public.events set meeting_lat = 41, meeting_lng = 29 where id = pg_temp.ev(2) $$, 'P0001', 'event_forbidden',
  'members do not move the meeting point');
select pg_temp.act('00000000-0000-0000-0000-0000000cc101');
select is(
  (select private.event_card(e)->'meeting' from public.events e where e.id = pg_temp.ev(1)),
  '{"lat": 41.1801, "lng": 28.9862}'::jsonb, 'the event shows its meeting point'
);

-- Map ----------------------------------------------------------------------------------------------------
set local role authenticated;
select is((select count(*)::int from pg_temp.items('groups')), 2, 'groups appear at their province center');
select is((select (i->>'lat')::float from pg_temp.items('groups') i limit 1), 41.0082::float, 'at the center of Istanbul');
select is(
  (select array_agg(i->>'title' order by i->>'title') from pg_temp.items('events') i),
  array['Belgrad yürüyüşü', 'Konser'], 'only upcoming events with a meeting point; canceled and past ones stay off'
);
select is((select count(*)::int from pg_temp.items('events', 'music')), 1, 'the category filter applies to events');
select is((select count(*)::int from pg_temp.items('groups', 'hiking')), 1, 'and to groups');
select is(
  (select count(*)::int from jsonb_array_elements(public.map_items(36.0, 30.0, 37.0, 31.0)->'events') i
   where i->>'id' like '00000000-0000-0000-0000-0000000cc%'), 0,
  'nothing outside the visible box'
);
-- Starting soon (Faz 18m): events before a time, and no groups.
select is(
  (select array_agg(i->>'title') from jsonb_array_elements(public.map_items(40.5, 28.0, 41.5, 30.0, null, now() + interval '60 hours')->'events') i
   where i->>'id' like '00000000-0000-0000-0000-0000000cc%'),
  array['Belgrad yürüyüşü'], 'only events starting before the time');
select is(
  (select count(*)::int from jsonb_array_elements(public.map_items(40.5, 28.0, 41.5, 30.0, null, now() + interval '60 hours')->'groups') i
   where i->>'id' like '00000000-0000-0000-0000-0000000cc%'),
  0, 'groups have no time, so they stay off');
select is(
  (select count(*)::int from jsonb_array_elements(public.map_items(40.5, 28.0, 41.5, 30.0, 'music', now() + interval '7 days')->'events') i
   where i->>'id' like '00000000-0000-0000-0000-0000000cc%'),
  1, 'the time and the category together');
reset role;
select pg_temp.act('00000000-0000-0000-0000-0000000cc103');
update public.groups set status = 'suspended', suspension_reason = 'test', suspended_at = now() where id = pg_temp.grp(2);
set local role authenticated;
select is((select count(*)::int from pg_temp.items('groups')), 1, 'suspended groups leave the map');
select is((select count(*)::int from pg_temp.items('events', 'music')), 0, 'with their events');
reset role;

-- Staff removes a meeting point -------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000cc103');
select lives_ok($$ update public.events set meeting_lat = null, meeting_lng = null where id = pg_temp.ev(1) $$,
  'a platform moderator removes an inappropriate meeting point');
select throws_ok($$ update public.events set meeting_lat = 41, meeting_lng = 29 where id = pg_temp.ev(1) $$, 'P0001', 'event_forbidden',
  'but does not set one');

select * from finish();
rollback;
