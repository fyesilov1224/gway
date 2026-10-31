begin;
create extension if not exists pgtap with schema extensions;

select plan(20);

-- o1 owns group 5401 (İstanbul); m1 goes to the surprise, m2 is a member who does not go.
insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-00000054d001', 'surprise-owner@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000054c001', 'surprise-m1@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000054c002', 'surprise-m2@test.local', 'authenticated', 'authenticated');
insert into public.profiles (id, username, display_name) values
  ('00000000-0000-0000-0000-00000054d001', 'surprise_owner', 'Owner'),
  ('00000000-0000-0000-0000-00000054c001', 'surprise_m1', 'M1'),
  ('00000000-0000-0000-0000-00000054c002', 'surprise_m2', 'M2');

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;
create function pg_temp.ev() returns uuid language sql as $$ select '00000000-0000-0000-0000-0000005400e1'::uuid $$;
create function pg_temp.surprise() returns jsonb language sql as $$ select public.event_detail(pg_temp.ev()) -> 'surprise' $$;

select pg_temp.act('00000000-0000-0000-0000-00000054d001');
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id, province)
values ('00000000-0000-0000-0000-000000005401', 'surprise.test', 'Surprise', 'running', 'open', '00000000-0000-0000-0000-00000054d001', 34);
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-000000005401', '00000000-0000-0000-0000-00000054d001');
insert into public.events (id, group_id, created_by, title, starts_at, location, surprise_reveal_hours) values
  (pg_temp.ev(), '00000000-0000-0000-0000-000000005401', '00000000-0000-0000-0000-00000054d001',
   'Gizemli akşam', now() + interval '20 hours', 'Kadıköy, deniz kenarında', 3),
  ('00000000-0000-0000-0000-0000005400e2', '00000000-0000-0000-0000-000000005401', '00000000-0000-0000-0000-00000054d001',
   'Normal koşu', now() + interval '20 hours', 'Sahil', null);

select lives_ok($$ insert into public.event_venues (event_id, location, meeting_lat, meeting_lng)
                   values (pg_temp.ev(), 'Moda Sahnesi', 40.9850, 29.0260) $$, 'the organizer stores the venue');
select throws_ok($$ insert into public.event_venues (event_id, location) values ('00000000-0000-0000-0000-0000005400e2', 'Yer') $$,
  'P0001', 'event_not_surprise', 'only a surprise has a hidden venue');
select throws_ok($$ update public.events set link_url = 'https://maps.example/moda' where id = pg_temp.ev() $$,
  '23514', null, 'a surprise has no public link');
select throws_ok($$ update public.events set venue_revealed_at = now() where id = pg_temp.ev() $$,
  'P0001', 'event_immutable', 'nobody marks the reveal by hand');

select pg_temp.act('00000000-0000-0000-0000-00000054c001');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-000000005401', '00000000-0000-0000-0000-00000054c001');
insert into public.event_attendees (event_id, user_id) values (pg_temp.ev(), '00000000-0000-0000-0000-00000054c001');
select pg_temp.act('00000000-0000-0000-0000-00000054c002');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-000000005401', '00000000-0000-0000-0000-00000054c002');
select throws_ok($$ update public.event_venues set location = 'Başka yer' where event_id = pg_temp.ev() $$,
  'P0001', 'event_forbidden', 'members do not change the venue');

-- Before the reveal ------------------------------------------------------------------------------------------------
set local role authenticated;
select throws_ok($$ select * from public.event_venues $$, '42501', null, 'clients do not read the venue table');
select pg_temp.act('00000000-0000-0000-0000-00000054c001');
select is(pg_temp.surprise() -> 'venue', 'null'::jsonb, 'those going do not see the venue before the reveal');
select is(pg_temp.surprise() ->> 'province', 'İstanbul', 'they see the province');
select is(public.event_detail(pg_temp.ev()) ->> 'location', 'Kadıköy, deniz kenarında', 'and the hint');
select pg_temp.act('00000000-0000-0000-0000-00000054d001');
select is(pg_temp.surprise() #>> '{venue,location}', 'Moda Sahnesi', 'the organizer always sees the venue');
select is(
  (select e ->> 'lat' from jsonb_array_elements(public.map_items(35, 25, 43, 45) -> 'events') e where e ->> 'id' = pg_temp.ev()::text),
  (select lat::text from public.provinces where id = 34), 'the map shows the province center, not the venue');
reset role;
select set_config('request.jwt.claims', '', true);
select is(private.reveal_event_venues(), 0, 'nothing is revealed early');

-- The reveal -------------------------------------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-00000054d001');
update public.events set starts_at = now() + interval '2 hours' where id = pg_temp.ev();
set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-00000054c001');
select is(pg_temp.surprise() #>> '{venue,location}', 'Moda Sahnesi', 'from the reveal time those going see the venue');
select pg_temp.act('00000000-0000-0000-0000-00000054c002');
select is(pg_temp.surprise() -> 'venue', 'null'::jsonb, 'members who do not go still do not');
reset role;

select set_config('request.jwt.claims', '', true);
select is(private.reveal_event_venues(), 1, 'the job tells those going');
select is((select count(*)::int from public.notifications
           where type = 'event_venue_revealed' and recipient_id = '00000000-0000-0000-0000-00000054c001'), 1, 'with a notification');
select is(private.reveal_event_venues(), 0, 'once');

select pg_temp.act('00000000-0000-0000-0000-00000054d001');
create temp table before_change as
  select count(*) as n from public.notifications where type = 'event_updated' and recipient_id = '00000000-0000-0000-0000-00000054c001';
update public.event_venues set location = 'Moda Parkı' where event_id = pg_temp.ev();
select is((select count(*) from public.notifications where type = 'event_updated' and recipient_id = '00000000-0000-0000-0000-00000054c001'),
          (select n + 1 from before_change), 'a venue changed after the reveal is announced');

update public.events set surprise_reveal_hours = null where id = pg_temp.ev();
select is((select venue_revealed_at from public.events where id = pg_temp.ev()), null, 'turning the surprise off clears the reveal');
select is(public.event_detail(pg_temp.ev()) -> 'surprise', 'null'::jsonb, 'and the card has no surprise');

select finish();
rollback;
