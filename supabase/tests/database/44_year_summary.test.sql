begin;
create extension if not exists pgtap with schema extensions;

select plan(13);

-- o1 owns group 5401 (running); m1 went to two past events and skipped one; m2 is another member.
insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-00000054d001', 'year-owner@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000054c001', 'year-m1@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000054c002', 'year-m2@test.local', 'authenticated', 'authenticated');

insert into public.profiles (id, username, display_name) values
  ('00000000-0000-0000-0000-00000054d001', 'year_owner', 'Owner'),
  ('00000000-0000-0000-0000-00000054c001', 'year_m1', 'M1'),
  ('00000000-0000-0000-0000-00000054c002', 'year_m2', 'M2');

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;

select pg_temp.act('00000000-0000-0000-0000-00000054d001');
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id)
values ('00000000-0000-0000-0000-000000005401', 'year.test', 'Sahil Koşucuları', 'running', 'open', '00000000-0000-0000-0000-00000054d001');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-000000005401', '00000000-0000-0000-0000-00000054d001');
select pg_temp.act('00000000-0000-0000-0000-00000054c001');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-000000005401', '00000000-0000-0000-0000-00000054c001');
select pg_temp.act('00000000-0000-0000-0000-00000054c002');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-000000005401', '00000000-0000-0000-0000-00000054c002');

-- Past events this year, written with triggers off (the guard refuses past starts).
set local session_replication_role = replica;
insert into public.events (id, group_id, created_by, title, starts_at, ends_at, location) values
  ('00000000-0000-0000-0000-0000005400e1', '00000000-0000-0000-0000-000000005401', '00000000-0000-0000-0000-00000054d001',
   'İlk koşu', date_trunc('year', now()) + interval '10 days', date_trunc('year', now()) + interval '10 days 3 hours', 'Sahil'),
  ('00000000-0000-0000-0000-0000005400e2', '00000000-0000-0000-0000-000000005401', '00000000-0000-0000-0000-00000054d001',
   'İkinci koşu', date_trunc('year', now()) + interval '20 days', null, 'Sahil'),
  ('00000000-0000-0000-0000-0000005400e3', '00000000-0000-0000-0000-000000005401', '00000000-0000-0000-0000-00000054d001',
   'Gidilmeyen koşu', date_trunc('year', now()) + interval '30 days', null, 'Sahil');
insert into public.event_attendees (event_id, user_id, status, no_show_at) values
  ('00000000-0000-0000-0000-0000005400e1', '00000000-0000-0000-0000-00000054c001', 'going', null),
  ('00000000-0000-0000-0000-0000005400e2', '00000000-0000-0000-0000-00000054c001', 'going', null),
  ('00000000-0000-0000-0000-0000005400e3', '00000000-0000-0000-0000-00000054c001', 'going', now());
set local session_replication_role = origin;

-- The year in review --------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-00000054c001');
set local role authenticated;
select is((public.year_summary(extract(year from now())::int) ->> 'attended')::int, 2, 'a no-show does not count');
select is((public.year_summary(extract(year from now())::int) ->> 'hours')::int, 5, 'three hours and a default two');
select is(public.year_summary(extract(year from now())::int) #>> '{top_group,name}', 'Sahil Koşucuları', 'the group gone to most');
select is(public.year_summary(extract(year from now())::int) #>> '{first_event,title}', 'İlk koşu', 'the first event of the year');
select is(public.year_summary(extract(year from now())::int) #>> '{categories,0,slug}', 'running', 'the categories gone to most');
select is(public.year_summary(2025), null, 'nothing before 2026');
select is(public.year_summary(extract(year from now())::int + 1), null, 'nothing in the future');
reset role;

select pg_temp.act('00000000-0000-0000-0000-00000054d001');
set local role authenticated;
select is((public.year_summary(extract(year from now())::int) ->> 'organized')::int, 3, 'the owner organized three');
select is(public.event_detail('00000000-0000-0000-0000-0000005400e2') ->> 'was_there', null, 'the owner was not there as an attendee');
reset role;

select pg_temp.act('00000000-0000-0000-0000-00000054c001');
set local role authenticated;
select is((public.event_detail('00000000-0000-0000-0000-0000005400e2') #>> '{was_there,count_in_group}')::int, 2,
  'the second event with this group');

-- Shares --------------------------------------------------------------------------------
select lives_ok($$ select public.record_card_share('year') $$, 'a share is counted');
select throws_ok($$ select public.record_card_share('poster') $$, '23514', null, 'only the known cards');
reset role;
select pg_temp.act('00000000-0000-0000-0000-00000054c002');
set local role authenticated;
select is((select count(*) from public.story_card_shares), 0::bigint, 'others do not see whose shares');
reset role;

select * from finish();
rollback;
