begin;
create extension if not exists pgtap with schema extensions;

select plan(7);

-- c1 signs in on a phone (session s1) and a tablet (session s2).
insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-0000000fc001', 'c1@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000fc002', 'c2@test.local', 'authenticated', 'authenticated');
insert into public.profiles (id, username, display_name) values
  ('00000000-0000-0000-0000-0000000fc001', 'clean_one', 'One'),
  ('00000000-0000-0000-0000-0000000fc002', 'clean_two', 'Two');
insert into auth.sessions (id, user_id, created_at, updated_at) values
  ('00000000-0000-0000-0000-00000005e001', '00000000-0000-0000-0000-0000000fc001', now(), now()),
  ('00000000-0000-0000-0000-00000005e002', '00000000-0000-0000-0000-0000000fc001', now(), now());

create function pg_temp.act(uid text, sid text) returns void language sql as $$
  select set_config('request.jwt.claims',
    json_build_object('sub', uid, 'role', 'authenticated', 'session_id', sid)::text, true);
$$;

set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000fc001', '00000000-0000-0000-0000-00000005e001');
select public.register_push_device('token-phone-first-0000000000', 'android');
select pg_temp.act('00000000-0000-0000-0000-0000000fc001', '00000000-0000-0000-0000-00000005e002');
select public.register_push_device('token-tablet-00000000000000', 'android');
reset role;

select is(
  (select session_id::text from public.push_devices where token = 'token-phone-first-0000000000'),
  '00000000-0000-0000-0000-00000005e001', 'a device remembers the session that registered it'
);

-- FCM gives the phone a new token: it replaces the old one instead of adding a device.
set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000fc001', '00000000-0000-0000-0000-00000005e001');
select public.register_push_device('token-phone-second-000000000', 'android');
reset role;
select is(
  (select array_agg(token order by token) from public.push_devices where user_id = '00000000-0000-0000-0000-0000000fc001'),
  array['token-phone-second-000000000', 'token-tablet-00000000000000'],
  'one session keeps one device'
);

-- Signing out deletes the session; its device goes with it, the other stays.
delete from auth.sessions where id = '00000000-0000-0000-0000-00000005e001';
select is(
  (select array_agg(token) from public.push_devices where user_id = '00000000-0000-0000-0000-0000000fc001'),
  array['token-tablet-00000000000000'], 'signing out removes that device only'
);

-- A token still valid after its session was signed out registers nothing.
set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000fc001', '00000000-0000-0000-0000-00000005e001');
select lives_ok(
  $$ select public.register_push_device('token-after-sign-out-0000000', 'android') $$,
  'registering from a signed-out session does not fail'
);
reset role;
select is(
  (select count(*)::int from public.push_devices where token = 'token-after-sign-out-0000000'), 0,
  'but adds no device'
);

-- The phone changes hands: the token moves to the new session.
insert into auth.sessions (id, user_id, created_at, updated_at) values
  ('00000000-0000-0000-0000-00000005e003', '00000000-0000-0000-0000-0000000fc002', now(), now());
set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000fc002', '00000000-0000-0000-0000-00000005e003');
select public.register_push_device('token-tablet-00000000000000', 'android');
reset role;
select is(
  (select user_id::text || ' ' || session_id::text from public.push_devices where token = 'token-tablet-00000000000000'),
  '00000000-0000-0000-0000-0000000fc002 00000000-0000-0000-0000-00000005e003',
  'a token moves to the person and session that signed in last'
);

-- Clients still cannot write the bookkeeping columns.
set local role authenticated;
select throws_ok(
  $$ update public.push_devices set last_checked_at = now(), session_id = null $$,
  '42501', null, 'only the backend marks probes'
);
reset role;

select * from finish();
rollback;
