begin;
create extension if not exists pgtap with schema extensions;

select plan(22);

-- d1 owner, d2 Yönetici, d3..d6 members.
insert into auth.users (id, email, aud, role)
select ('00000000-0000-0000-0000-0000000dd00' || i)::uuid, 'd' || i || '@test.local', 'authenticated', 'authenticated'
from generate_series(1, 6) i;
insert into public.profiles (id, username, display_name)
select ('00000000-0000-0000-0000-0000000dd00' || i)::uuid, 'detail_user' || i, 'Detail ' || i
from generate_series(1, 6) i;

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;
create function pg_temp.u(i int) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000000dd00' || i)::uuid $$;
create function pg_temp.e() returns uuid language sql as $$ select '00000000-0000-0000-0000-0000000de001'::uuid $$;
create function pg_temp.join_event(i int) returns void language sql as $$
  select pg_temp.act(pg_temp.u(i)::text);
  insert into public.event_attendees (event_id, user_id) values (pg_temp.e(), pg_temp.u(i));
$$;
create function pg_temp.status_of(i int) returns text language sql as $$
  select status from public.event_attendees where event_id = pg_temp.e() and user_id = pg_temp.u(i);
$$;

select pg_temp.act('00000000-0000-0000-0000-0000000dd001');
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id)
values ('00000000-0000-0000-0000-0000000dc001', 'motor.grubu', 'Motor Grubu', 'motorcycle', 'open', pg_temp.u(1));
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-0000000dc001', pg_temp.u(1));
do $$ begin
  for i in 2..6 loop
    perform pg_temp.act(pg_temp.u(i)::text);
    insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-0000000dc001', pg_temp.u(i));
  end loop;
end $$;
select pg_temp.act('00000000-0000-0000-0000-0000000dd001');
insert into public.group_member_roles (group_id, user_id, role) values ('00000000-0000-0000-0000-0000000dc001', pg_temp.u(2), 'admin');

-- Categories and the new fields ---------------------------------------------------------------------
select is((select count(*)::int from public.categories where slug in ('motorcycle', 'camping', 'chess')), 3,
  'motorcycle, camping and chess are categories');

select pg_temp.act('00000000-0000-0000-0000-0000000dd002');
select throws_ok(
  $$ insert into public.events (group_id, created_by, title, starts_at, location, equipment)
     values ('00000000-0000-0000-0000-0000000dc001', pg_temp.u(2), 'Tur', now() + interval '2 days', 'Kadıköy', array['Kask', '  ']) $$,
  'P0001', 'equipment_invalid', 'an empty equipment item is rejected'
);
select lives_ok(
  $$ insert into public.events (id, group_id, created_by, title, starts_at, location, capacity, requirements, equipment, approval_required)
     values (pg_temp.e(), '00000000-0000-0000-0000-0000000dc001', pg_temp.u(2), 'Şile turu', now() + interval '2 days', 'Kadıköy iskele', 1,
             '  En az 1 yıllık ehliyet  ', array[' Kask ', 'Mont'], true) $$,
  'a Yönetici creates an approval event with requirements and equipment'
);
select results_eq(
  $$ select requirements, equipment from public.events where id = pg_temp.e() $$,
  $$ values ('En az 1 yıllık ehliyet'::text, array['Kask', 'Mont']) $$,
  'requirements and equipment are trimmed'
);
select is(private.event_card(e)->'category'->>'name', 'Motosiklet', 'the event shows its group''s category')
from public.events e where e.id = pg_temp.e();

-- Requests ------------------------------------------------------------------------------------------
select pg_temp.join_event(3);
select is(pg_temp.status_of(3), 'requested', 'joining an approval event sends a request');
select is((select going_count + waitlist_count from public.events where id = pg_temp.e()), 0, 'requests take no seat');
select pg_temp.act('00000000-0000-0000-0000-0000000dd003');
select throws_ok(
  $$ update public.event_attendees set status = 'going' where event_id = pg_temp.e() and user_id = pg_temp.u(3) $$,
  'P0001', 'attendance_forbidden', 'nobody approves their own request'
);
select is(public.event_detail(pg_temp.e())->'requests', 'null'::jsonb, 'members do not see the requests');

select pg_temp.act('00000000-0000-0000-0000-0000000dd002');
select is(jsonb_array_length(public.event_detail(pg_temp.e())->'requests'), 1, 'managers see the requests');
select lives_ok(
  $$ update public.event_attendees set status = 'going' where event_id = pg_temp.e() and user_id = pg_temp.u(3) $$,
  'a manager approves a request'
);
select is(pg_temp.status_of(3), 'going', 'the approved member goes');
select is((select count(*)::int from public.notifications where recipient_id = pg_temp.u(3) and type = 'event_approved'), 1,
  'the member hears about the approval');

select pg_temp.join_event(4);
select pg_temp.act('00000000-0000-0000-0000-0000000dd002');
update public.event_attendees set status = 'going' where event_id = pg_temp.e() and user_id = pg_temp.u(4);
select is(pg_temp.status_of(4), 'waitlisted', 'an approval on a full event goes to the waitlist');

select pg_temp.join_event(5);
select pg_temp.act('00000000-0000-0000-0000-0000000dd004');
select throws_ok(
  $$ delete from public.event_attendees where event_id = pg_temp.e() and user_id = pg_temp.u(5) $$,
  'P0001', 'attendance_forbidden', 'members cannot decline others'
);
select pg_temp.act('00000000-0000-0000-0000-0000000dd002');
select lives_ok(
  $$ delete from public.event_attendees where event_id = pg_temp.e() and user_id = pg_temp.u(5) $$,
  'a manager declines a request'
);
select is((select count(*)::int from public.notifications where recipient_id = pg_temp.u(5) and type = 'event_declined'), 1,
  'the member hears about the decline');

select pg_temp.join_event(6);
delete from public.event_attendees where event_id = pg_temp.e() and user_id = pg_temp.u(6);
select is((select count(*)::int from public.notifications where recipient_id = pg_temp.u(6) and type = 'event_declined'), 0,
  'withdrawing your own request sends nothing');

select pg_temp.act('00000000-0000-0000-0000-0000000dd001');
insert into public.event_attendees (event_id, user_id) values (pg_temp.e(), pg_temp.u(1));
select is(pg_temp.status_of(1), 'waitlisted', 'managers skip the request (the event is full)');

-- Edits ---------------------------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000dd003');
select throws_ok(
  $$ update public.events set requirements = 'Herkes gelebilir' where id = pg_temp.e() $$,
  'P0001', 'event_forbidden', 'members cannot edit the requirements'
);
select pg_temp.act('00000000-0000-0000-0000-0000000dd002');
select lives_ok(
  $$ update public.events set approval_required = false, equipment = array['Kask'] where id = pg_temp.e() $$,
  'managers edit the new fields'
);

set local role anon;
select set_config('request.jwt.claims', '', true);
select is((select equipment from public.events where id = pg_temp.e()), array['Kask'], 'visitors read the equipment of a public event');
reset role;

select * from finish();
rollback;
