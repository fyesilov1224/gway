begin;
create extension if not exists pgtap with schema extensions;

select plan(14);

-- o1 owner, a1 platform admin, a2 platform support.
insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-00000045a001', 'grant-admin@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000045a002', 'grant-support@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000045d001', 'grant-owner@test.local', 'authenticated', 'authenticated');

insert into public.profiles (id, username, display_name) values
  ('00000000-0000-0000-0000-00000045a001', 'grant_admin', 'Admin'),
  ('00000000-0000-0000-0000-00000045a002', 'grant_support', 'Support'),
  ('00000000-0000-0000-0000-00000045d001', 'grant_owner', 'Owner');

insert into public.platform_staff (user_id, role) values
  ('00000000-0000-0000-0000-00000045a001', 'admin'),
  ('00000000-0000-0000-0000-00000045a002', 'support');

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;

-- A granted slice of group 4501 by the given admin.
create function pg_temp.grant_slice(slice uuid, admin uuid, plan text, starts timestamptz, ends timestamptz) returns void language sql as $$
  insert into public.group_subscriptions (id, group_id, plan_slug, granted_by, grant_reason, starts_at, ends_at)
  values (slice, '00000000-0000-0000-0000-000000004501', plan, admin, 'Kampanya desteği', starts, ends);
$$;

select pg_temp.act('00000000-0000-0000-0000-00000045d001');
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id)
values ('00000000-0000-0000-0000-000000004501', 'grant.test', 'Grant', 'cycling', 'open', '00000000-0000-0000-0000-00000045d001');

-- Granting ---------------------------------------------------------------------------
set local role authenticated;
select throws_ok(
  $$ insert into public.group_subscriptions (group_id, plan_slug, granted_by, grant_reason, starts_at, ends_at)
     values ('00000000-0000-0000-0000-000000004501', 'pro', '00000000-0000-0000-0000-00000045d001', 'kendime', now(), now() + interval '30 days') $$,
  '42501', null, 'clients cannot write subscriptions');
reset role;

select throws_ok(
  $$ select pg_temp.grant_slice('00000000-0000-0000-0000-0000004500b1', '00000000-0000-0000-0000-00000045d001', 'pro', now(), now() + interval '30 days') $$,
  'P0001', 'subscription_grant_forbidden', 'the owner cannot grant their group a plan');
select pg_temp.act('00000000-0000-0000-0000-00000045a002');
select throws_ok(
  $$ select pg_temp.grant_slice('00000000-0000-0000-0000-0000004500b1', '00000000-0000-0000-0000-00000045a002', 'pro', now(), now() + interval '30 days') $$,
  'P0001', 'subscription_grant_forbidden', 'support staff cannot grant a plan');
select pg_temp.act('00000000-0000-0000-0000-00000045a001');
select throws_ok(
  $$ select pg_temp.grant_slice('00000000-0000-0000-0000-0000004500b1', '00000000-0000-0000-0000-00000045a002', 'pro', now(), now() + interval '30 days') $$,
  'P0001', 'subscription_grant_forbidden', 'an admin grants only in their own name');
select throws_ok(
  $$ select pg_temp.grant_slice('00000000-0000-0000-0000-0000004500b1', '00000000-0000-0000-0000-00000045a001', 'free', now(), now() + interval '30 days') $$,
  'P0001', 'subscription_invalid', 'the free plan is never granted');
select throws_ok(
  $$ insert into public.group_subscriptions (group_id, plan_slug, granted_by, starts_at, ends_at)
     values ('00000000-0000-0000-0000-000000004501', 'pro', '00000000-0000-0000-0000-00000045a001', now(), now() + interval '30 days') $$,
  '23514', null, 'a grant without a reason is refused');
select throws_ok(
  $$ insert into public.group_subscriptions (group_id, plan_slug, period, granted_by, grant_reason, starts_at, ends_at)
     values ('00000000-0000-0000-0000-000000004501', 'pro', 'month', '00000000-0000-0000-0000-00000045a001', 'Kampanya', now(), now() + interval '30 days') $$,
  '23514', null, 'a grant has no billing period');
select lives_ok(
  $$ select pg_temp.grant_slice('00000000-0000-0000-0000-0000004500b1', '00000000-0000-0000-0000-00000045a001', 'pro', now(), now() + interval '30 days') $$,
  'a platform admin grants a plan with a reason');
select is(private.group_plan_slug('00000000-0000-0000-0000-000000004501'), 'pro', 'the granted plan is the current plan');

-- Cancelling --------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-00000045a002');
select throws_ok(
  $$ update public.group_subscriptions set ends_at = now(), canceled_at = now(), cancel_reason = 'admin', cancel_note = 'Destekten iptal'
     where id = '00000000-0000-0000-0000-0000004500b1' $$,
  'P0001', 'subscription_cancel_forbidden', 'support staff cannot cancel');
select pg_temp.act('00000000-0000-0000-0000-00000045a001');
select throws_ok(
  $$ update public.group_subscriptions set ends_at = now(), canceled_at = now(), cancel_reason = 'upgraded', cancel_note = 'Not'
     where id = '00000000-0000-0000-0000-0000004500b1' $$,
  '23514', null, 'only an admin cancellation carries a reason');
select lives_ok(
  $$ update public.group_subscriptions set ends_at = now(), canceled_at = now(), cancel_reason = 'admin', cancel_note = 'Kural ihlali'
     where id = '00000000-0000-0000-0000-0000004500b1' $$,
  'a platform admin cancels with a reason');
select throws_ok(
  $$ update public.group_subscriptions set cancel_note = 'Başka gerekçe' where id = '00000000-0000-0000-0000-0000004500b1' $$,
  'P0001', 'subscription_cancel_invalid', 'the cancellation reason is never rewritten');

-- The admin's account going away keeps the slice and its reason.
delete from auth.users where id = '00000000-0000-0000-0000-00000045a001';
select is(
  (select (granted_by is null, grant_reason, cancel_note)::text from public.group_subscriptions where id = '00000000-0000-0000-0000-0000004500b1'),
  '(t,"Kampanya desteği","Kural ihlali")', 'a deleted admin leaves the slice and both reasons');

select * from finish();
rollback;
