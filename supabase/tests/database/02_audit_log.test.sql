begin;
create extension if not exists pgtap with schema extensions;

select plan(14);

insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-0000000000a1', 'admin@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000b1', 'user@test.local', 'authenticated', 'authenticated');

insert into public.platform_staff (user_id, role) values
  ('00000000-0000-0000-0000-0000000000a1', 'admin');

-- service role (backend) ---------------------------------------------------
set local role service_role;

select lives_ok(
  $$ insert into public.audit_log (actor_id, actor_kind, action, target_type, target_id)
     values ('00000000-0000-0000-0000-0000000000a1', 'staff', 'user.suspended', 'user',
             '00000000-0000-0000-0000-0000000000b1') $$,
  'service role can append to audit_log'
);

select lives_ok(
  $$ insert into public.audit_log (actor_kind, action, target_type)
     values ('system', 'subscription.expired', 'subscription') $$,
  'system entries need no actor'
);

select throws_ok(
  $$ insert into public.audit_log (actor_kind, action, target_type)
     values ('user', 'group.joined', 'group') $$,
  '23514',
  null,
  'user and staff entries require actor_id'
);

select throws_ok(
  $$ insert into public.audit_log (actor_kind, action, target_type)
     values ('system', 'Not A Code', 'x') $$,
  '23514',
  null,
  'action must be a dotted lowercase code'
);

select throws_ok(
  $$ update public.audit_log set action = 'user.restored' $$,
  '42501',
  null,
  'service role cannot update audit_log'
);

select throws_ok(
  $$ delete from public.audit_log $$,
  '42501',
  null,
  'service role cannot delete from audit_log'
);

reset role;

select throws_ok(
  $$ truncate public.audit_log $$,
  '42501',
  null,
  'even the table owner cannot truncate audit_log'
);

select throws_ok(
  $$ delete from public.audit_log $$,
  '42501',
  null,
  'even the table owner cannot delete from audit_log'
);

-- anon ---------------------------------------------------------------------
set local role anon;

select throws_ok(
  $$ select * from public.audit_log $$,
  '42501',
  null,
  'anon cannot read audit_log'
);

-- regular user -------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000b1","role":"authenticated"}', true);

select is_empty(
  $$ select * from public.audit_log $$,
  'regular user cannot see audit entries, even about themselves'
);

select throws_ok(
  $$ insert into public.audit_log (actor_id, actor_kind, action, target_type)
     values ('00000000-0000-0000-0000-0000000000b1', 'user', 'user.restored', 'user') $$,
  '42501',
  null,
  'regular user cannot write audit entries'
);

-- staff --------------------------------------------------------------------
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);

-- now() is the transaction start time, so this matches only rows inserted by this test
-- (the log is append-only and may hold rows from other test runs).
select is(
  (select count(*)::int from public.audit_log where occurred_at = now()),
  2,
  'staff can read all audit entries'
);

select throws_ok(
  $$ insert into public.audit_log (actor_id, actor_kind, action, target_type)
     values ('00000000-0000-0000-0000-0000000000a1', 'staff', 'user.restored', 'user') $$,
  '42501',
  null,
  'staff cannot write audit entries directly'
);

select throws_ok(
  $$ delete from public.audit_log $$,
  '42501',
  null,
  'staff cannot delete audit entries'
);

select * from finish();
rollback;
