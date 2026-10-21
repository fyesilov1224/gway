begin;
create extension if not exists pgtap with schema extensions;

select plan(12);

insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-0000000000a1', 'admin@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000a2', 'support@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000b1', 'user@test.local', 'authenticated', 'authenticated');

insert into public.platform_staff (user_id, role) values
  ('00000000-0000-0000-0000-0000000000a1', 'admin'),
  ('00000000-0000-0000-0000-0000000000a2', 'support');

select has_table('public', 'platform_staff', 'platform_staff exists');
select col_is_pk('public', 'platform_staff', 'user_id', 'user_id is the primary key');

select throws_ok(
  $$ insert into public.platform_staff (user_id, role)
     values ('00000000-0000-0000-0000-0000000000b1', 'owner') $$,
  '23514',
  null,
  'unknown staff role is rejected'
);

-- anon -------------------------------------------------------------------
set local role anon;

select throws_ok(
  $$ select * from public.platform_staff $$,
  '42501',
  null,
  'anon cannot read platform_staff'
);

-- regular user -------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000b1","role":"authenticated"}', true);

select is_empty(
  $$ select * from public.platform_staff $$,
  'non-staff user sees no staff rows'
);

select is(
  private.is_platform_staff(),
  false,
  'is_platform_staff() is false for a regular user'
);

select throws_ok(
  $$ insert into public.platform_staff (user_id, role)
     values ('00000000-0000-0000-0000-0000000000b1', 'admin') $$,
  '42501',
  null,
  'user cannot make themselves staff'
);

-- staff ------------------------------------------------------------------
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a2","role":"authenticated"}', true);

select results_eq(
  $$ select user_id from public.platform_staff $$,
  $$ values ('00000000-0000-0000-0000-0000000000a2'::uuid) $$,
  'staff sees only their own row'
);

select is(private.is_platform_staff(), true, 'support is staff');
select is(private.is_platform_staff(array['admin']), false, 'support is not admin');

select throws_ok(
  $$ update public.platform_staff set role = 'admin'
     where user_id = '00000000-0000-0000-0000-0000000000a2' $$,
  '42501',
  null,
  'staff cannot promote themselves'
);

select throws_ok(
  $$ delete from public.platform_staff $$,
  '42501',
  null,
  'staff cannot delete staff rows'
);

select * from finish();
rollback;
