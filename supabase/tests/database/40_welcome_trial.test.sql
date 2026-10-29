begin;
create extension if not exists pgtap with schema extensions;

select plan(14);

-- o1 owner, m1 and m2 members, a1 platform admin.
insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-00000050a001', 'trial-admin@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000050d001', 'trial-owner@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000050c001', 'trial-m1@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000050c002', 'trial-m2@test.local', 'authenticated', 'authenticated');

insert into public.profiles (id, username, display_name) values
  ('00000000-0000-0000-0000-00000050a001', 'trial_admin', 'Admin'),
  ('00000000-0000-0000-0000-00000050d001', 'trial_owner', 'Owner'),
  ('00000000-0000-0000-0000-00000050c001', 'trial_m1', 'M1'),
  ('00000000-0000-0000-0000-00000050c002', 'trial_m2', 'M2');

insert into public.platform_staff (user_id, role) values ('00000000-0000-0000-0000-00000050a001', 'admin');

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;

create function pg_temp.trials(uid uuid) returns bigint language sql as $$
  select count(*) from public.user_subscriptions where user_id = uid and welcome_trial;
$$;

-- m2 already has Hepsi Bir Arada for 10 days, given by an admin.
select pg_temp.act('00000000-0000-0000-0000-00000050a001');
insert into public.user_subscriptions (user_id, plan_slug, granted_by, grant_reason, starts_at, ends_at)
values ('00000000-0000-0000-0000-00000050c002', 'matching_premium', '00000000-0000-0000-0000-00000050a001', 'Destek', now(),
        now() + interval '10 days');

-- Creating a group --------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-00000050d001');
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id) values
  ('00000000-0000-0000-0000-000000005001', 'trial.one', 'Trial One', 'cycling', 'open', '00000000-0000-0000-0000-00000050d001'),
  ('00000000-0000-0000-0000-000000005002', 'trial.two', 'Trial Two', 'cycling', 'open', '00000000-0000-0000-0000-00000050d001');
insert into public.group_members (group_id, user_id) values
  ('00000000-0000-0000-0000-000000005001', '00000000-0000-0000-0000-00000050d001'),
  ('00000000-0000-0000-0000-000000005002', '00000000-0000-0000-0000-00000050d001');

select is(pg_temp.trials('00000000-0000-0000-0000-00000050d001'), 1::bigint, 'founding groups gives the owner one trial');

-- Joining -----------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-00000050c001');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-000000005001', '00000000-0000-0000-0000-00000050c001');
select pg_temp.act('00000000-0000-0000-0000-00000050c002');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-000000005001', '00000000-0000-0000-0000-00000050c002');

select ok(
  (select ends_at = starts_at + interval '30 days' and starts_at <= now()
   from public.user_subscriptions where user_id = '00000000-0000-0000-0000-00000050c001' and welcome_trial),
  'the first group gives 30 days starting now');
select ok(
  private.has_matching_feature('00000000-0000-0000-0000-00000050c001', 'reveal')
  and private.has_matching_feature('00000000-0000-0000-0000-00000050c001', 'unlimited')
  and private.has_matching_feature('00000000-0000-0000-0000-00000050c001', 'chat')
  and private.has_matching_feature('00000000-0000-0000-0000-00000050c001', 'teammates'),
  'the trial opens matching, likes, chat and teammates');
select is(
  (select starts_at from public.user_subscriptions where user_id = '00000000-0000-0000-0000-00000050c002' and welcome_trial),
  (select ends_at from public.user_subscriptions where user_id = '00000000-0000-0000-0000-00000050c002' and not welcome_trial),
  'the trial follows the time the person already has');
select is(
  (select count(*) from public.audit_log where action = 'personal_plan.welcome_trial'
     and data ->> 'userId' = '00000000-0000-0000-0000-00000050c001'),
  1::bigint, 'the trial is in the audit log');

select pg_temp.act('00000000-0000-0000-0000-00000050c001');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-000000005002', '00000000-0000-0000-0000-00000050c001');
delete from public.group_members where group_id = '00000000-0000-0000-0000-000000005001' and user_id = '00000000-0000-0000-0000-00000050c001';
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-000000005001', '00000000-0000-0000-0000-00000050c001');
select is(pg_temp.trials('00000000-0000-0000-0000-00000050c001'), 1::bigint, 'another group or rejoining gives no second trial');

-- Messages keep their rule -----------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-00000050c001');
set local role authenticated;
select ok(not public.can_message('00000000-0000-0000-0000-00000050c002'),
  'the trial does not open messages to a group mate who is neither a match nor a teammate');

-- Who writes the trial --------------------------------------------------------------
select throws_ok(
  $$ insert into public.user_subscriptions (user_id, plan_slug, grant_reason, starts_at, ends_at, welcome_trial)
     values ('00000000-0000-0000-0000-00000050c001', 'matching_premium', 'Hoş geldin denemesi', now(), now() + interval '30 days', true) $$,
  '42501', null, 'clients cannot write a trial');
select throws_ok($$ select private.grant_welcome_trial('00000000-0000-0000-0000-00000050c001') $$,
  '42501', null, 'clients cannot call the trial grant');
reset role;

select throws_ok(
  $$ insert into public.user_subscriptions (user_id, plan_slug, grant_reason, starts_at, ends_at, welcome_trial)
     values ('00000000-0000-0000-0000-00000050a001', 'matching_premium', 'Hoş geldin denemesi', now(), now() + interval '30 days', true) $$,
  'P0001', 'subscription_grant_forbidden', 'no trial without a group');
select throws_ok(
  $$ insert into public.user_subscriptions (user_id, plan_slug, grant_reason, starts_at, ends_at, welcome_trial)
     values ('00000000-0000-0000-0000-00000050c002', 'matching_teammates', 'Hoş geldin denemesi', now(), now() + interval '30 days', true) $$,
  '23514', null, 'the trial is only Hepsi Bir Arada');
select throws_ok(
  $$ update public.user_subscriptions set welcome_trial = false
     where user_id = '00000000-0000-0000-0000-00000050c001' and welcome_trial $$,
  'P0001', 'subscription_immutable', 'a trial cannot be turned into a grant');

-- An admin can still end it -----------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-00000050a001');
select lives_ok(
  $$ update public.user_subscriptions set ends_at = now(), canceled_at = now(), cancel_reason = 'admin'
     where user_id = '00000000-0000-0000-0000-00000050c001' and welcome_trial $$,
  'a platform admin cancels a trial');
select ok(not private.has_matching_feature('00000000-0000-0000-0000-00000050c001', 'teammates'),
  'a canceled trial opens nothing');

select * from finish();
rollback;
