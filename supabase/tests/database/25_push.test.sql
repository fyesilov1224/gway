begin;
create extension if not exists pgtap with schema extensions;

select plan(12);

-- p1 and p2 sign in on phones; p1 hands a phone to p2.
insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-0000000fa001', 'p1@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000fa002', 'p2@test.local', 'authenticated', 'authenticated');
insert into public.profiles (id, username, display_name) values
  ('00000000-0000-0000-0000-0000000fa001', 'push_one', 'One'),
  ('00000000-0000-0000-0000-0000000fa002', 'push_two', 'Two');

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;

set local role authenticated;

-- Registering ---------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000fa001');
select lives_ok(
  $$ select public.register_push_device('token-of-phone-one-0000000000', 'android') $$,
  'a person registers their phone'
);
select throws_ok(
  $$ insert into public.push_devices (token, user_id, platform)
     values ('token-written-directly-000000', '00000000-0000-0000-0000-0000000fa001', 'android') $$,
  '42501', null, 'devices are written only through register_push_device'
);
select throws_ok(
  $$ select public.register_push_device('token-of-phone-one-0000000000', 'fax') $$,
  '23514', null, 'the platform is android, ios or web'
);
select is((select count(*)::int from public.push_devices), 1, 'the person reads their own device');

select pg_temp.act('00000000-0000-0000-0000-0000000fa002');
select is((select count(*)::int from public.push_devices), 0, 'others cannot read it');
delete from public.push_devices where token = 'token-of-phone-one-0000000000';
reset role;
select is((select count(*)::int from public.push_devices where token = 'token-of-phone-one-0000000000'), 1, 'nor delete it');

-- The phone changes hands ---------------------------------------------------------------------
set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000fa002');
select public.register_push_device('token-of-phone-one-0000000000', 'android');
reset role;
select is(
  (select user_id::text from public.push_devices where token = 'token-of-phone-one-0000000000'),
  '00000000-0000-0000-0000-0000000fa002', 'the token moves to whoever signs in on the device'
);

-- At most 10 devices ---------------------------------------------------------------------
set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000fa001');
select public.register_push_device('token-of-many-phones-' || lpad(i::text, 9, '0'), 'android') from generate_series(1, 11) i;
select is((select count(*)::int from public.push_devices), 10, 'only the 10 latest devices stay');

delete from public.push_devices where token = 'token-of-many-phones-000000011';
select is((select count(*)::int from public.push_devices), 9, 'a person deletes their own device');
reset role;

-- Push queue ---------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000fa002');
insert into public.follows (follower_id, followee_id) values ('00000000-0000-0000-0000-0000000fa002', '00000000-0000-0000-0000-0000000fa001');
select is(
  (select pushed_at from public.notifications where recipient_id = '00000000-0000-0000-0000-0000000fa001' and type = 'follow'),
  null, 'a new notification waits for the push'
);

set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000fa001');
select throws_ok(
  $$ update public.notifications set pushed_at = now() where recipient_id = '00000000-0000-0000-0000-0000000fa001' $$,
  '42501', null, 'only the backend marks notifications as pushed'
);
reset role;

select set_config('request.jwt.claims', '', true);
select throws_ok(
  $$ select public.register_push_device('token-without-a-person-000000', 'web') $$,
  'P0001', 'push_forbidden', 'nobody registers without signing in'
);

select * from finish();
rollback;
