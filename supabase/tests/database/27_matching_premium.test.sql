begin;
create extension if not exists pgtap with schema extensions;

select plan(28);

-- These tests check life without packages; the welcome trial (0050) would open every one.
alter table public.group_members disable trigger group_members_welcome_trial;

-- p1 woman looking for men (buys Premium), p2 and p3 men looking for women; all follow one group. a1 is a platform admin.
insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-0000000fe001', 'p1@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000fe002', 'p2@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000fe003', 'p3@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000fe0a1', 'a1@test.local', 'authenticated', 'authenticated');
insert into public.profiles (id, username, display_name) values
  ('00000000-0000-0000-0000-0000000fe001', 'prem_one', 'Bir'),
  ('00000000-0000-0000-0000-0000000fe002', 'prem_two', 'İki'),
  ('00000000-0000-0000-0000-0000000fe003', 'prem_three', 'Üç'),
  ('00000000-0000-0000-0000-0000000fe0a1', 'prem_admin', 'Yönetici');
insert into public.platform_staff (user_id, role) values ('00000000-0000-0000-0000-0000000fe0a1', 'admin');

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;

select pg_temp.act('00000000-0000-0000-0000-0000000fe001');
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id)
values ('00000000-0000-0000-0000-0000000fe0c1', 'premium.grup', 'Premium Grubu', 'music', 'open', '00000000-0000-0000-0000-0000000fe001');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-0000000fe0c1', '00000000-0000-0000-0000-0000000fe001');
insert into public.match_profiles (user_id, birth_date, gender, province, friend, dating, interested_in, consent_version)
values ('00000000-0000-0000-0000-0000000fe001', date '1995-05-05', 'woman', 34, true, true, '{man}', 'v1');

select pg_temp.act('00000000-0000-0000-0000-0000000fe002');
insert into public.group_follows (user_id, group_id) values ('00000000-0000-0000-0000-0000000fe002', '00000000-0000-0000-0000-0000000fe0c1');
insert into public.match_profiles (user_id, birth_date, gender, province, friend, dating, interested_in, consent_version)
values ('00000000-0000-0000-0000-0000000fe002', date '1992-02-02', 'man', 34, true, true, '{woman}', 'v1');

select pg_temp.act('00000000-0000-0000-0000-0000000fe003');
insert into public.group_follows (user_id, group_id) values ('00000000-0000-0000-0000-0000000fe003', '00000000-0000-0000-0000-0000000fe0c1');
insert into public.match_profiles (user_id, birth_date, gender, province, friend, dating, interested_in, consent_version)
values ('00000000-0000-0000-0000-0000000fe003', date '1990-01-01', 'man', 6, true, true, '{woman}', 'v1');
reset role;

insert into public.match_photos (user_id, path, position)
select u::uuid, u || '/' || n || '.jpg', n
from unnest(array['00000000-0000-0000-0000-0000000fe001', '00000000-0000-0000-0000-0000000fe002', '00000000-0000-0000-0000-0000000fe003']) u,
     generate_series(0, 1) n;

-- Catalog and orders ---------------------------------------------------------------------
set local role anon;
select is((select count(*)::int from public.personal_plan_prices where plan_slug = 'matching_premium'), 4,
  'Premium prices are public');
reset role;

create function pg_temp.order_premium(buyer text, amount int) returns uuid language sql as $$
  insert into public.billing_orders (buyer_id, personal_plan_slug, period, provider, country, currency, amount_minor,
                                     billing_details, sales_terms_version)
  values (buyer::uuid, 'matching_premium', 'month', 'paytr', 'TR', 'TRY', amount, '{}', 1)
  returning id;
$$;

select pg_temp.act('00000000-0000-0000-0000-0000000fe001');
select throws_ok($$ select pg_temp.order_premium('00000000-0000-0000-0000-0000000fe001', 100) $$,
  'P0001', 'order_price_mismatch', 'a personal order is at the list price');
select throws_ok($$ select pg_temp.order_premium('00000000-0000-0000-0000-0000000fe002', 24900) $$,
  'P0001', 'order_forbidden', 'nobody orders for someone else');
select throws_ok(
  $$ insert into public.billing_orders (buyer_id, personal_plan_slug, group_name, group_handle, period, provider, currency, amount_minor,
                                        billing_details, sales_terms_version)
     values ('00000000-0000-0000-0000-0000000fe001', 'matching_premium', 'X', 'x', 'month', 'paytr', 'TRY', 24900, '{}', 1) $$,
  '23514', null, 'a personal order names no group');
create temp table premium_order as select pg_temp.order_premium('00000000-0000-0000-0000-0000000fe001', 24900) as id;
select pass('the buyer orders Premium at the list price');

create function pg_temp.open_slice(order_id uuid, starts timestamptz) returns void language sql as $$
  insert into public.user_subscriptions (user_id, plan_slug, period, order_id, starts_at, ends_at)
  values ('00000000-0000-0000-0000-0000000fe001', 'matching_premium', 'month', order_id, starts, starts + interval '1 month');
$$;

select throws_ok($$ select pg_temp.open_slice((select id from premium_order), now()) $$,
  'P0001', 'subscription_order_mismatch', 'an unpaid order opens nothing');
update public.billing_orders set status = 'paid' where id = (select id from premium_order);
select lives_ok($$ select pg_temp.open_slice((select id from premium_order), now() - interval '1 minute') $$,
  'the paid order opens a month of Premium');
select ok(private.has_matching_premium('00000000-0000-0000-0000-0000000fe001'), 'she has Premium');
select ok(not private.has_matching_premium('00000000-0000-0000-0000-0000000fe002'), 'he does not');

select throws_ok(
  $$ insert into public.user_subscriptions (user_id, plan_slug, granted_by, grant_reason, starts_at, ends_at)
     values ('00000000-0000-0000-0000-0000000fe002', 'matching_premium', '00000000-0000-0000-0000-0000000fe001', 'hediye', now(), now() + interval '1 day') $$,
  'P0001', 'subscription_grant_forbidden', 'only a platform admin grants Premium');
select pg_temp.act('00000000-0000-0000-0000-0000000fe0a1');
select throws_ok(
  $$ insert into public.user_subscriptions (user_id, plan_slug, granted_by, grant_reason, starts_at, ends_at)
     values ('00000000-0000-0000-0000-0000000fe001', 'matching_premium', '00000000-0000-0000-0000-0000000fe0a1', 'telafi', now(), now() + interval '1 day') $$,
  '23P01', null, 'slices of one plan never overlap');

set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000fe002');
select throws_ok(
  $$ insert into public.user_subscriptions (user_id, plan_slug, granted_by, grant_reason, starts_at, ends_at)
     values ('00000000-0000-0000-0000-0000000fe002', 'matching_premium', '00000000-0000-0000-0000-0000000fe002', 'kendime', now(), now() + interval '1 day') $$,
  '42501', null, 'users never write subscriptions');
select is((select count(*)::int from public.user_subscriptions), 0, 'nor see other people''s');

-- Allowances ---------------------------------------------------------------------
select is((public.match_status())->>'likes_left', '10', 'free: ten likes');
select is((public.match_status())->>'super_likes_left', '1', 'free: one super like');
select throws_ok($$ select public.match_deck('dating', 20, 30) $$, 'P0001', 'package_required', 'filters need a package');
select throws_ok($$ select public.match_admirers('dating') $$, 'P0001', 'package_required', 'so does the list of admirers');
select throws_ok(
  $$ insert into public.match_boosts (user_id, ends_at) values ('00000000-0000-0000-0000-0000000fe002', now() + interval '30 minutes') $$,
  '42501', null, 'boosts are written only by the backend');

select pg_temp.act('00000000-0000-0000-0000-0000000fe001');
select is((public.match_status())->>'likes_left', null, 'Premium: unlimited likes');
select is((public.match_status())->>'super_likes_left', '5', 'Premium: five super likes');
select is((select count(*)::int from public.match_deck('dating', 20, null, null, 6)), 1, 'Premium filters by province');
reset role;

-- A super like and a boost (the backend writes) ---------------------------------------------------------------------
select throws_ok(
  $$ insert into public.match_swipes (swiper_id, target_id, mode, liked, super)
     values ('00000000-0000-0000-0000-0000000fe002', '00000000-0000-0000-0000-0000000fe001', 'dating', false, true) $$,
  '23514', null, 'a super like is a like');
insert into public.match_swipes (swiper_id, target_id, mode, liked, super)
values ('00000000-0000-0000-0000-0000000fe003', '00000000-0000-0000-0000-0000000fe001', 'dating', true, true);
select is((select count(*)::int from public.notifications
           where recipient_id = '00000000-0000-0000-0000-0000000fe001' and type = 'match_super_liked'), 1,
  'she hears of the super like');

set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000fe001');
select is((select d->>'display_name' from public.match_deck('dating') d limit 1), 'Üç', 'the super liker comes first');
select is((select (d->>'super_liked_me')::boolean from public.match_deck('dating') d limit 1), true, 'and the card says so');
select is((select a->>'display_name' from public.match_admirers('dating') a), 'Üç', 'Premium sees who liked her');
select pg_temp.act('00000000-0000-0000-0000-0000000fe002');
select is((public.match_status())->'admirers'->>'dating', '0', 'he has no admirers yet');

select ok(private.has_matching_feature('00000000-0000-0000-0000-0000000fe0a1', 'chat')
  and private.has_matching_feature('00000000-0000-0000-0000-0000000fe0a1', 'teammates'), 'a platform admin has every feature');

select * from finish();
rollback;
