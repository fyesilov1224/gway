begin;
create extension if not exists pgtap with schema extensions;

select plan(10);

-- s1 is suspended for three days, b1 is banned (no end date), v1 is a visitor.
insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-00000057a001', 'notice-s1@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000057a002', 'notice-b1@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000057a003', 'notice-v1@test.local', 'authenticated', 'authenticated');

insert into public.profiles (id, username, display_name) values
  ('00000000-0000-0000-0000-00000057a001', 'notice_s1', 'S1'),
  ('00000000-0000-0000-0000-00000057a002', 'notice_b1', 'B1'),
  ('00000000-0000-0000-0000-00000057a003', 'notice_v1', 'V1');

update public.account_status set status = 'suspended', suspended_until = now() + interval '3 days', suspension_reason = 'Spam'
where user_id = '00000000-0000-0000-0000-00000057a001';
update public.account_status set status = 'suspended', suspended_until = null, suspension_reason = 'Taciz'
where user_id = '00000000-0000-0000-0000-00000057a002';

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;

-- Visibility -------------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-00000057a003');
set local role authenticated;
select is((select count(*)::int from public.profiles where id = '00000000-0000-0000-0000-00000057a001'), 1,
  'a suspended profile stays visible');
select is((select count(*)::int from public.profiles where id = '00000000-0000-0000-0000-00000057a002'), 0,
  'a banned profile is gone');
select isnt(public.account_notice('00000000-0000-0000-0000-00000057a001') ->> 'suspended_until', null,
  'the notice gives the end of the suspension');
select is(public.account_notice('00000000-0000-0000-0000-00000057a001') ->> 'suspension_reason', null,
  'the reason is not in the notice');
select is(public.account_notice('00000000-0000-0000-0000-00000057a002'), null, 'a ban gives no notice');
select is(public.account_notice('00000000-0000-0000-0000-00000057a003'), null, 'an active account gives no notice');
reset role;

set local role anon;
select is((select count(*)::int from public.profiles where id = '00000000-0000-0000-0000-00000057a002'), 0,
  'anonymous visitors do not see a ban either');
reset role;

-- The token hook -------------------------------------------------------------------------------
select is(private.custom_access_token_hook(jsonb_build_object(
  'user_id', '00000000-0000-0000-0000-00000057a001', 'claims', jsonb_build_object('role', 'authenticated'))) #>> '{claims,role}',
  'unverified', 'a suspended account gets the restricted role');
select is(private.custom_access_token_hook(jsonb_build_object(
  'user_id', '00000000-0000-0000-0000-00000057a002', 'claims', jsonb_build_object('role', 'authenticated'))) #>> '{claims,role}',
  'unverified', 'so does a banned one');
select is(private.custom_access_token_hook(jsonb_build_object(
  'user_id', '00000000-0000-0000-0000-00000057a003', 'claims', jsonb_build_object('role', 'authenticated'))) #>> '{claims,role}',
  'authenticated', 'an active account is untouched');

select * from finish();
rollback;
