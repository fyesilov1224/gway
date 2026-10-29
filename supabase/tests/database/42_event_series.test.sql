begin;
create extension if not exists pgtap with schema extensions;

select plan(19);

-- o1 owns group 5201 (pro plan) and 5202 (free plan); m1 is a plain member of 5201; a1 platform admin.
insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-00000052a001', 'series-admin@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000052d001', 'series-owner@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000052c001', 'series-m1@test.local', 'authenticated', 'authenticated');

insert into public.profiles (id, username, display_name) values
  ('00000000-0000-0000-0000-00000052a001', 'series_admin', 'Admin'),
  ('00000000-0000-0000-0000-00000052d001', 'series_owner', 'Owner'),
  ('00000000-0000-0000-0000-00000052c001', 'series_m1', 'M1');

insert into public.platform_staff (user_id, role) values ('00000000-0000-0000-0000-00000052a001', 'admin');

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;

-- A series of the owner with its first date, starting tomorrow.
create function pg_temp.series(id uuid, grp uuid, weeks int, until date) returns void language sql as $$
  insert into public.event_series (id, group_id, created_by, interval_weeks, until)
  values (id, grp, '00000000-0000-0000-0000-00000052d001', weeks, until);
  insert into public.events (group_id, created_by, title, starts_at, ends_at, location, series_id)
  values (grp, '00000000-0000-0000-0000-00000052d001', 'Salı koşusu', now() + interval '1 day',
          now() + interval '1 day 2 hours', 'Sahil', id);
$$;

create function pg_temp.dates(s uuid) returns bigint language sql as $$
  select count(*) from public.events where series_id = s;
$$;

select pg_temp.act('00000000-0000-0000-0000-00000052d001');
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id) values
  ('00000000-0000-0000-0000-000000005201', 'series.pro', 'Series Pro', 'running', 'open', '00000000-0000-0000-0000-00000052d001'),
  ('00000000-0000-0000-0000-000000005202', 'series.free', 'Series Free', 'running', 'open', '00000000-0000-0000-0000-00000052d001');
insert into public.group_members (group_id, user_id) values
  ('00000000-0000-0000-0000-000000005201', '00000000-0000-0000-0000-00000052d001'),
  ('00000000-0000-0000-0000-000000005202', '00000000-0000-0000-0000-00000052d001');
select pg_temp.act('00000000-0000-0000-0000-00000052c001');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-000000005201', '00000000-0000-0000-0000-00000052c001');

select pg_temp.act('00000000-0000-0000-0000-00000052a001');
insert into public.group_subscriptions (group_id, plan_slug, granted_by, grant_reason, starts_at, ends_at)
values ('00000000-0000-0000-0000-000000005201', 'pro', '00000000-0000-0000-0000-00000052a001', 'Test paketi', now(), now() + interval '60 days');

-- Starting --------------------------------------------------------------------------------
set local role authenticated;
select throws_ok(
  $$ insert into public.event_series (group_id, created_by, interval_weeks)
     values ('00000000-0000-0000-0000-000000005201', '00000000-0000-0000-0000-00000052a001', 1) $$,
  '42501', null, 'clients cannot write series');
reset role;

select pg_temp.act('00000000-0000-0000-0000-00000052c001');
select throws_ok(
  $$ insert into public.event_series (group_id, created_by, interval_weeks)
     values ('00000000-0000-0000-0000-000000005201', '00000000-0000-0000-0000-00000052c001', 1) $$,
  'P0001', 'event_forbidden', 'a plain member cannot start a series');

select pg_temp.act('00000000-0000-0000-0000-00000052d001');
select throws_ok(
  $$ insert into public.event_series (group_id, created_by, interval_weeks)
     values ('00000000-0000-0000-0000-000000005201', '00000000-0000-0000-0000-00000052d001', 3) $$,
  '23514', null, 'a series repeats every one or two weeks');
select throws_ok(
  $$ insert into public.event_series (group_id, created_by, interval_weeks, until)
     values ('00000000-0000-0000-0000-000000005201', '00000000-0000-0000-0000-00000052d001', 1, current_date + 400) $$,
  'P0001', 'event_time_invalid', 'a series ends within a year');
select lives_ok($$ select pg_temp.series('00000000-0000-0000-0000-0000005200a1', '00000000-0000-0000-0000-000000005201', 1, null) $$,
  'an inviter starts a weekly series');
select lives_ok($$ select pg_temp.series('00000000-0000-0000-0000-0000005200a2', '00000000-0000-0000-0000-000000005201', 2, null) $$,
  'and a fortnightly one');
select lives_ok($$ select pg_temp.series('00000000-0000-0000-0000-0000005200a3', '00000000-0000-0000-0000-000000005201', 1, current_date + 10) $$,
  'and one that ends in ten days');
select throws_ok(
  $$ insert into public.events (group_id, created_by, title, starts_at, location, series_id)
     values ('00000000-0000-0000-0000-000000005202', '00000000-0000-0000-0000-00000052d001', 'Başka grup', now() + interval '2 days', 'Park',
             '00000000-0000-0000-0000-0000005200a1') $$,
  'P0001', 'event_series_stopped', 'a date joins only a series of its own group');

-- Opening the next weeks --------------------------------------------------------------------
reset role;
select is(private.extend_event_series(), 5, 'the job opens the dates of the next 4 weeks');
select is(pg_temp.dates('00000000-0000-0000-0000-0000005200a1'), 4::bigint, 'weekly: tomorrow and three more weeks');
select is(pg_temp.dates('00000000-0000-0000-0000-0000005200a2'), 2::bigint, 'fortnightly: tomorrow and in two weeks');
select ok(
  pg_temp.dates('00000000-0000-0000-0000-0000005200a3') = 2
  and (select stopped_at is not null from public.event_series where id = '00000000-0000-0000-0000-0000005200a3'),
  'a series opens up to its end date, then stops');
select is(private.extend_event_series(), 0, 'a second run opens nothing new');
select ok(
  (select bool_and(e.starts_at - p.starts_at = interval '7 days' and e.ends_at - e.starts_at = interval '2 hours')
   from public.events e
   join lateral (select x.starts_at from public.events x where x.series_id = e.series_id and x.starts_at < e.starts_at
                 order by x.starts_at desc limit 1) p on true
   where e.series_id = '00000000-0000-0000-0000-0000005200a1'),
  'each date copies the last one a week later, with its length');

-- The monthly limit -----------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-00000052d001');
select pg_temp.series('00000000-0000-0000-0000-0000005200b1', '00000000-0000-0000-0000-000000005202', 1, null);
reset role;
select private.extend_event_series('00000000-0000-0000-0000-0000005200b1');
select private.extend_event_series('00000000-0000-0000-0000-0000005200b1');
select is(pg_temp.dates('00000000-0000-0000-0000-0000005200b1'), 2::bigint, 'the free plan stops the series at its monthly limit');
select is(
  (select count(*) from public.notifications where type = 'event_series_limit' and recipient_id = '00000000-0000-0000-0000-00000052d001'),
  1::bigint, 'the owner is told once');

-- Stopping --------------------------------------------------------------------------------
select throws_ok(
  $$ update public.events set series_id = null where series_id = '00000000-0000-0000-0000-0000005200a1' $$,
  'P0001', 'event_immutable', 'a date never leaves its series');
select pg_temp.act('00000000-0000-0000-0000-00000052c001');
select throws_ok(
  $$ update public.event_series set stopped_at = now(), stopped_by = '00000000-0000-0000-0000-00000052c001'
     where id = '00000000-0000-0000-0000-0000005200a1' $$,
  'P0001', 'event_forbidden', 'a plain member cannot stop a series');
select pg_temp.act('00000000-0000-0000-0000-00000052a001');
select lives_ok(
  $$ update public.event_series set stopped_at = now(), stopped_by = '00000000-0000-0000-0000-00000052a001'
     where id = '00000000-0000-0000-0000-0000005200a1' $$,
  'a platform admin stops a series');

select * from finish();
rollback;
