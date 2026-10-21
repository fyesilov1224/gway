begin;
create extension if not exists pgtap with schema extensions;

select plan(57);

-- d1 owner, d2 member, d3 outsider, a1 platform admin, a2 platform support.
insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-0000000000a1', 'admin@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000a2', 'support@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000d1', 'd1@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000d2', 'd2@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000d3', 'd3@test.local', 'authenticated', 'authenticated');

insert into public.platform_staff (user_id, role) values
  ('00000000-0000-0000-0000-0000000000a1', 'admin'),
  ('00000000-0000-0000-0000-0000000000a2', 'support');

insert into public.profiles (id, username, display_name) values
  ('00000000-0000-0000-0000-0000000000d1', 'bill_owner', 'Owner'),
  ('00000000-0000-0000-0000-0000000000d2', 'bill_member', 'Member'),
  ('00000000-0000-0000-0000-0000000000d3', 'bill_outsider', 'Outsider');

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;

create function pg_temp.no_actor() returns void language sql as $$
  select set_config('request.jwt.claims', '', true);
$$;

-- A checkout order of d1 for group e001 (monthly, TRY).
create function pg_temp.open_order(order_id uuid, plan text, amount int) returns void language sql as $$
  insert into public.billing_orders (id, group_id, group_name, group_handle, buyer_id, plan_slug, period, provider,
                                     country, currency, amount_minor, billing_details, sales_terms_version)
  values (order_id, '00000000-0000-0000-0000-00000000e001', 'Bisiklet', 'bisiklet',
          '00000000-0000-0000-0000-0000000000d1', plan, 'month', 'paytr', 'TR', 'TRY', amount,
          '{"firstName":"Ada","lastName":"Yılmaz"}', 1);
$$;

select pg_temp.act('00000000-0000-0000-0000-0000000000d1');
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id)
values ('00000000-0000-0000-0000-00000000e001', 'bisiklet', 'Bisiklet', 'cycling', 'open', '00000000-0000-0000-0000-0000000000d1');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-00000000e001', '00000000-0000-0000-0000-0000000000d1');
select pg_temp.act('00000000-0000-0000-0000-0000000000d2');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-00000000e001', '00000000-0000-0000-0000-0000000000d2');

-- Catalog ------------------------------------------------------------------------
set local role anon;
select is((select count(*)::int from public.plans), 4, 'anyone reads the plan catalog');
select is((select count(*)::int from public.plan_prices), 12, 'anyone reads the price list');
reset role;

select is(
  (select array_agg(slug order by tier) from public.plans),
  array['free', 'starter', 'pro', 'community'], 'four plans ordered by tier'
);
select is(
  (select amount_minor from public.plan_prices where plan_slug = 'pro' and currency = 'TRY' and period = 'year'),
  699000, 'yearly price is ten months'
);

set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000000a1');
select throws_ok($$ update public.plans set max_members = 1 $$, '42501', null, 'clients cannot change plans, even staff');
select throws_ok($$ insert into public.plan_prices values ('free', 'TRY', 'month', 1) $$, '42501', null, 'clients cannot add prices');
reset role;

select pg_temp.no_actor();
select throws_ok($$ update public.plans set max_members = 99 where slug = 'pro' $$,
  'P0001', 'plan_update_forbidden', 'plans change only on behalf of a platform admin');
select pg_temp.act('00000000-0000-0000-0000-0000000000a2');
select throws_ok($$ update public.plans set max_members = 99 where slug = 'pro' $$,
  'P0001', 'plan_update_forbidden', 'support staff cannot change plans');
select pg_temp.act('00000000-0000-0000-0000-0000000000a1');
select lives_ok($$ update public.plans set max_members = 1200, name = ' Pro+ ' where slug = 'pro' $$, 'platform admin changes a plan');
select is((select (name, max_members)::text from public.plans where slug = 'pro'), '(Pro+,1200)', 'name is trimmed');
select lives_ok($$ update public.plans set is_active = false where slug = 'free' $$, 'free plan update runs');
select is((select is_active from public.plans where slug = 'free'), true, 'free plan never goes off sale');
select throws_ok($$ update public.plans set tier = 9 where slug = 'pro' $$,
  'P0001', 'plan_identity_immutable', 'tier is immutable');
select throws_ok($$ delete from public.plans where slug = 'community' $$,
  'P0001', 'plan_delete_forbidden', 'plans are never deleted');
select throws_ok($$ delete from public.plan_prices where plan_slug = 'pro' $$,
  'P0001', 'price_delete_forbidden', 'prices are never deleted');
select lives_ok($$ update public.plan_prices set amount_minor = 79900 where plan_slug = 'pro' and currency = 'TRY' and period = 'month' $$,
  'platform admin changes a price');
select throws_ok($$ insert into public.plan_prices values ('free', 'TRY', 'month', 100) $$,
  '23514', null, 'the free plan has no price');

-- Orders ---------------------------------------------------------------------------
select pg_temp.no_actor();
select throws_ok($$ select pg_temp.open_order('00000000-0000-0000-0000-0000000000f1', 'starter', 24900) $$,
  'P0001', 'order_forbidden', 'order needs the buyer as actor');
select pg_temp.act('00000000-0000-0000-0000-0000000000d2');
select throws_ok($$ select pg_temp.open_order('00000000-0000-0000-0000-0000000000f1', 'starter', 24900) $$,
  'P0001', 'order_forbidden', 'nobody orders for someone else');
select throws_ok(
  $$ insert into public.billing_orders (group_id, group_name, group_handle, buyer_id, plan_slug, period, provider,
                                        currency, amount_minor, billing_details, sales_terms_version)
     values ('00000000-0000-0000-0000-00000000e001', 'Bisiklet', 'bisiklet', '00000000-0000-0000-0000-0000000000d2',
             'starter', 'month', 'paytr', 'TRY', 24900, '{}', 1) $$,
  'P0001', 'order_forbidden', 'a member without billing.manage cannot order'
);
select pg_temp.act('00000000-0000-0000-0000-0000000000d1');
select throws_ok($$ select pg_temp.open_order('00000000-0000-0000-0000-0000000000f1', 'starter', 100) $$,
  'P0001', 'order_price_mismatch', 'order amount must equal the list price');
select throws_ok($$ select pg_temp.open_order('00000000-0000-0000-0000-0000000000f1', 'free', 100) $$,
  'P0001', 'order_price_mismatch', 'the free plan cannot be ordered');
select lives_ok($$ select pg_temp.open_order('00000000-0000-0000-0000-0000000000f1', 'starter', 24900) $$, 'owner opens an order');
select lives_ok($$ select pg_temp.open_order('00000000-0000-0000-0000-0000000000f2', 'starter', 24900) $$, 'owner opens a second order');
select lives_ok($$ select pg_temp.open_order('00000000-0000-0000-0000-0000000000f3', 'pro', 79900) $$, 'owner orders at the new price');

select pg_temp.act('00000000-0000-0000-0000-0000000000a1');
update public.plans set is_active = false where slug = 'community';
select pg_temp.act('00000000-0000-0000-0000-0000000000d1');
select throws_ok($$ select pg_temp.open_order('00000000-0000-0000-0000-0000000000f4', 'community', 199900) $$,
  'P0001', 'order_price_mismatch', 'a plan off sale cannot be ordered');

select pg_temp.no_actor();
select throws_ok($$ update public.billing_orders set amount_minor = 1 where id = '00000000-0000-0000-0000-0000000000f1' $$,
  'P0001', 'order_immutable', 'order amount is immutable');
select throws_ok($$ update public.billing_orders set status = 'refunded' where id = '00000000-0000-0000-0000-0000000000f1' $$,
  'P0001', 'order_status_invalid', 'a pending order cannot be refunded');
select lives_ok($$ update public.billing_orders set status = 'paid' where id in ('00000000-0000-0000-0000-0000000000f1', '00000000-0000-0000-0000-0000000000f2') $$,
  'settlement marks orders paid');
select isnt((select paid_at from public.billing_orders where id = '00000000-0000-0000-0000-0000000000f1'), null, 'paid_at is set');
select throws_ok($$ update public.billing_orders set status = 'failed' where id = '00000000-0000-0000-0000-0000000000f1' $$,
  'P0001', 'order_status_invalid', 'a paid order never fails');
select throws_ok($$ update public.billing_orders set status = 'refunded' where id = '00000000-0000-0000-0000-0000000000f1' $$,
  'P0001', 'order_status_invalid', 'only a platform admin marks a refund');
select throws_ok($$ delete from public.billing_orders where id = '00000000-0000-0000-0000-0000000000f3' $$,
  'P0001', 'order_delete_forbidden', 'orders are never deleted');

-- Subscriptions --------------------------------------------------------------------
select throws_ok(
  $$ insert into public.group_subscriptions (group_id, plan_slug, period, order_id, starts_at, ends_at)
     values ('00000000-0000-0000-0000-00000000e001', 'pro', 'month', '00000000-0000-0000-0000-0000000000f3', now(), now() + interval '30 days') $$,
  'P0001', 'subscription_order_mismatch', 'subscription needs a paid order'
);
select throws_ok(
  $$ insert into public.group_subscriptions (group_id, plan_slug, period, order_id, starts_at, ends_at)
     values ('00000000-0000-0000-0000-00000000e001', 'pro', 'month', '00000000-0000-0000-0000-0000000000f1', now(), now() + interval '30 days') $$,
  'P0001', 'subscription_order_mismatch', 'subscription plan must match its order'
);
select lives_ok(
  $$ insert into public.group_subscriptions (id, group_id, plan_slug, period, order_id, starts_at, ends_at)
     values ('00000000-0000-0000-0000-0000000000b1', '00000000-0000-0000-0000-00000000e001', 'starter', 'month',
             '00000000-0000-0000-0000-0000000000f1', now() - interval '10 days', now() + interval '20 days') $$,
  'paid order opens its slice'
);
select throws_ok(
  $$ insert into public.group_subscriptions (group_id, plan_slug, period, order_id, starts_at, ends_at)
     values ('00000000-0000-0000-0000-00000000e001', 'starter', 'month', '00000000-0000-0000-0000-0000000000f2',
             now() + interval '19 days', now() + interval '49 days') $$,
  '23P01', null, 'slices of a group never overlap'
);
select lives_ok(
  $$ insert into public.group_subscriptions (id, group_id, plan_slug, period, order_id, starts_at, ends_at)
     values ('00000000-0000-0000-0000-0000000000b2', '00000000-0000-0000-0000-00000000e001', 'starter', 'month',
             '00000000-0000-0000-0000-0000000000f2', now() + interval '20 days', now() + interval '50 days') $$,
  'a renewal starts where the timeline ends'
);
select throws_ok($$ update public.group_subscriptions set starts_at = now() where id = '00000000-0000-0000-0000-0000000000b2' $$,
  'P0001', 'subscription_immutable', 'slice start is immutable');
select throws_ok(
  $$ update public.group_subscriptions set ends_at = ends_at + interval '1 day', canceled_at = now(), cancel_reason = 'upgraded'
     where id = '00000000-0000-0000-0000-0000000000b2' $$,
  'P0001', 'subscription_cancel_invalid', 'cancelling never extends a slice'
);
select throws_ok(
  $$ update public.group_subscriptions set ends_at = starts_at, canceled_at = now(), cancel_reason = 'admin'
     where id = '00000000-0000-0000-0000-0000000000b2' $$,
  'P0001', 'subscription_cancel_forbidden', 'only a platform admin cancels as admin'
);
select throws_ok($$ delete from public.group_subscriptions where id = '00000000-0000-0000-0000-0000000000b2' $$,
  'P0001', 'subscription_delete_forbidden', 'slices are never deleted');

-- Current plan ------------------------------------------------------------------------
select is(private.group_plan_slug('00000000-0000-0000-0000-00000000e001'), 'starter', 'current slice sets the plan');

set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000000d2');
select is(
  (select (plan_slug, member_count, paid_until > now() + interval '49 days')::text
   from public.group_plan('00000000-0000-0000-0000-00000000e001')),
  '(starter,2,t)', 'a member sees the plan, usage and how long it is paid'
);
select is((select count(*)::int from public.group_subscriptions), 0, 'a member cannot read the subscriptions');
select is((select count(*)::int from public.billing_orders), 0, 'a member cannot read the orders');
select pg_temp.act('00000000-0000-0000-0000-0000000000d3');
select is((select count(*)::int from public.group_plan('00000000-0000-0000-0000-00000000e001')), 0, 'an outsider sees no plan');
select pg_temp.act('00000000-0000-0000-0000-0000000000d1');
select is((select count(*)::int from public.group_subscriptions), 2, 'the owner reads the timeline');
select is((select count(*)::int from public.billing_orders), 3, 'the buyer reads their orders');
select pg_temp.act('00000000-0000-0000-0000-0000000000a2');
select is(
  (select count(*)::int from public.billing_orders where buyer_id = '00000000-0000-0000-0000-0000000000d1'), 3,
  'platform staff read orders of any buyer'
);
reset role;

set local role anon;
select throws_ok($$ select * from public.group_plan('00000000-0000-0000-0000-00000000e001') $$, '42501', null, 'anon cannot call group_plan');
reset role;

-- Cancel by the system (upgrade replaces the queued slice).
select pg_temp.no_actor();
select lives_ok(
  $$ update public.group_subscriptions set ends_at = starts_at, canceled_at = now(), cancel_reason = 'upgraded'
     where id = '00000000-0000-0000-0000-0000000000b2' $$,
  'an upgrade closes a queued slice'
);

-- Member limit ----------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000000a1');
update public.plans set max_members = 2 where slug = 'starter';
select pg_temp.act('00000000-0000-0000-0000-0000000000d3');
select throws_ok(
  $$ insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-00000000e001', '00000000-0000-0000-0000-0000000000d3') $$,
  'P0001', 'member_limit_reached', 'a full group takes no new member'
);
select pg_temp.act('00000000-0000-0000-0000-0000000000a1');
update public.plans set max_members = 3 where slug = 'starter';
select pg_temp.act('00000000-0000-0000-0000-0000000000d3');
select lives_ok(
  $$ insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-00000000e001', '00000000-0000-0000-0000-0000000000d3') $$,
  'a raised limit lets the member in'
);

-- Legal ------------------------------------------------------------------------------------
set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000000d3');
select is(
  (select count(*)::int from public.pending_legal_documents() where kind = 'distance_sales'), 0,
  'the sales contract is not asked at sign-up'
);
reset role;
select throws_ok(
  $$ insert into public.legal_documents (kind, version, title, body) values ('distance_sales', 2, 'Sözleşme', 'Metin') $$,
  '23514', null, 'the sales contract is a purchase document'
);

-- Deleting the group keeps the financial record --------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000000d1');
delete from public.groups where id = '00000000-0000-0000-0000-00000000e001';
select is(
  (select (count(*), count(group_id))::text from public.billing_orders where buyer_id = '00000000-0000-0000-0000-0000000000d1'),
  '(3,0)', 'orders stay after the group is deleted, detached from it'
);

select * from finish();
rollback;
