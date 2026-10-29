begin;
create extension if not exists pgtap with schema extensions;

select plan(11);

-- o1 owns group 5301; m1 goes, m2 waits (capacity 1), m3 is a plain member.
insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-00000053d001', 'confirm-owner@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000053c001', 'confirm-m1@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000053c002', 'confirm-m2@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000053c003', 'confirm-m3@test.local', 'authenticated', 'authenticated');

insert into public.profiles (id, username, display_name) values
  ('00000000-0000-0000-0000-00000053d001', 'confirm_owner', 'Owner'),
  ('00000000-0000-0000-0000-00000053c001', 'confirm_m1', 'M1'),
  ('00000000-0000-0000-0000-00000053c002', 'confirm_m2', 'M2'),
  ('00000000-0000-0000-0000-00000053c003', 'confirm_m3', 'M3');

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;

select pg_temp.act('00000000-0000-0000-0000-00000053d001');
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id)
values ('00000000-0000-0000-0000-000000005301', 'confirm.test', 'Confirm', 'running', 'open', '00000000-0000-0000-0000-00000053d001');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-000000005301', '00000000-0000-0000-0000-00000053d001');
insert into public.events (id, group_id, created_by, title, starts_at, location, capacity) values
  ('00000000-0000-0000-0000-0000005300e1', '00000000-0000-0000-0000-000000005301', '00000000-0000-0000-0000-00000053d001',
   'Sabah koşusu', now() + interval '20 hours', 'Sahil', 1);

select pg_temp.act('00000000-0000-0000-0000-00000053c001');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-000000005301', '00000000-0000-0000-0000-00000053c001');
insert into public.event_attendees (event_id, user_id) values ('00000000-0000-0000-0000-0000005300e1', '00000000-0000-0000-0000-00000053c001');
select pg_temp.act('00000000-0000-0000-0000-00000053c002');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-000000005301', '00000000-0000-0000-0000-00000053c002');
insert into public.event_attendees (event_id, user_id) values ('00000000-0000-0000-0000-0000005300e1', '00000000-0000-0000-0000-00000053c002');
select pg_temp.act('00000000-0000-0000-0000-00000053c003');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-000000005301', '00000000-0000-0000-0000-00000053c003');

-- Confirming ------------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-00000053c001');
set local role authenticated;
select throws_ok(
  $$ update public.event_attendees set confirmed_at = now() where user_id = '00000000-0000-0000-0000-00000053c001' $$,
  '42501', null, 'clients do not write the table itself');
select ok(public.confirm_attendance('00000000-0000-0000-0000-0000005300e1'), 'a going attendee confirms');
select ok(public.confirm_attendance('00000000-0000-0000-0000-0000005300e1'), 'confirming again changes nothing');
select is((public.event_detail('00000000-0000-0000-0000-0000005300e1') ->> 'my_confirmed')::boolean, true, 'the attendee sees it');
select is(public.event_detail('00000000-0000-0000-0000-0000005300e1') ->> 'confirmed_count', null, 'members do not see the count');
select is(public.event_detail('00000000-0000-0000-0000-0000005300e1') #>> '{attendees,0,confirmed}', null,
  'members do not see who confirmed');
reset role;

select pg_temp.act('00000000-0000-0000-0000-00000053c002');
set local role authenticated;
select ok(not public.confirm_attendance('00000000-0000-0000-0000-0000005300e1'), 'a waitlisted person has no seat to confirm');
reset role;

select pg_temp.act('00000000-0000-0000-0000-00000053c003');
select throws_ok(
  $$ update public.event_attendees set confirmed_at = now() where user_id = '00000000-0000-0000-0000-00000053c002' $$,
  'P0001', 'attendance_forbidden', 'nobody confirms for someone else');

select pg_temp.act('00000000-0000-0000-0000-00000053d001');
set local role authenticated;
select is((public.event_detail('00000000-0000-0000-0000-0000005300e1') ->> 'confirmed_count')::int, 1, 'the organizer sees how many confirmed');
select is((public.event_detail('00000000-0000-0000-0000-0000005300e1') #>> '{attendees,0,confirmed}')::boolean, true,
  'and who');
reset role;

-- Not answering removes nobody; leaving frees the seat for the waitlist.
select pg_temp.act('00000000-0000-0000-0000-00000053c001');
delete from public.event_attendees where event_id = '00000000-0000-0000-0000-0000005300e1' and user_id = '00000000-0000-0000-0000-00000053c001';
select is((select status from public.event_attendees where user_id = '00000000-0000-0000-0000-00000053c002'), 'going',
  '"Gelemiyorum" gives the seat to the next on the waitlist');

select * from finish();
rollback;
