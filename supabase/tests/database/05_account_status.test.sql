begin;
create extension if not exists pgtap with schema extensions;

select plan(10);

insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-0000000000a1', 'admin@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000b1', 'u1@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000b2', 'u2@test.local', 'authenticated', 'authenticated');

insert into public.platform_staff (user_id, role)
values ('00000000-0000-0000-0000-0000000000a1', 'support');

select is(
  (select status from public.account_status where user_id = '00000000-0000-0000-0000-0000000000b1'),
  'active',
  'a new auth user gets an active account_status row'
);

select throws_ok(
  $$ update public.account_status set status = 'pending_deletion'
     where user_id = '00000000-0000-0000-0000-0000000000b1' $$,
  '23514', null, 'pending_deletion requires a scheduled date'
);

-- is_account_active ----------------------------------------------------------
update public.account_status
set status = 'suspended', suspension_reason = 'test', suspended_until = now() + interval '1 day'
where user_id = '00000000-0000-0000-0000-0000000000b2';

select is(private.is_account_active('00000000-0000-0000-0000-0000000000b2'), false, 'suspended account is inactive');

update public.account_status set suspended_until = now() - interval '1 minute'
where user_id = '00000000-0000-0000-0000-0000000000b2';

select is(private.is_account_active('00000000-0000-0000-0000-0000000000b2'), true, 'expired suspension counts as active');

update public.account_status
set status = 'pending_deletion', suspended_until = null, suspension_reason = null,
    deletion_requested_at = now(), deletion_scheduled_for = now() + interval '30 days'
where user_id = '00000000-0000-0000-0000-0000000000b2';

select is(private.is_account_active('00000000-0000-0000-0000-0000000000b2'), false, 'pending deletion is inactive');
select is(private.is_account_active(gen_random_uuid()), false, 'unknown user is inactive');

-- access ---------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000b1","role":"authenticated"}', true);

select results_eq(
  $$ select user_id from public.account_status $$,
  $$ values ('00000000-0000-0000-0000-0000000000b1'::uuid) $$,
  'user sees only their own account status'
);

select throws_ok(
  $$ update public.account_status set status = 'active' $$,
  '42501', null, 'user cannot change account status'
);

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);

-- Scoped to this test's users; seed data may exist.
select is((select count(*)::int from public.account_status where user_id::text like '00000000-0000-0000-0000-0000000000%'), 3, 'staff sees all account statuses');

set local role anon;
select throws_ok(
  $$ select * from public.account_status $$,
  '42501', null, 'anon cannot read account status'
);

select * from finish();
rollback;
