begin;
create extension if not exists pgtap with schema extensions;

select plan(27);

insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-0000000000a1', 'admin@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000b1', 'u1@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000b2', 'u2@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000b3', 'u3@test.local', 'authenticated', 'authenticated');

insert into public.platform_staff (user_id, role)
values ('00000000-0000-0000-0000-0000000000a1', 'admin');

-- b2 has a profile and is pending deletion, b3 has a profile and is suspended.
insert into public.profiles (id, username, display_name) values
  ('00000000-0000-0000-0000-0000000000b2', 'gizli.kisi', 'Gizli Kişi'),
  ('00000000-0000-0000-0000-0000000000b3', 'askida', 'Askıda');

update public.account_status
set status = 'pending_deletion', deletion_requested_at = now(), deletion_scheduled_for = now() + interval '30 days'
where user_id = '00000000-0000-0000-0000-0000000000b2';

update public.account_status
set status = 'suspended', suspension_reason = 'test'
where user_id = '00000000-0000-0000-0000-0000000000b3';

-- b1: onboarding --------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000b1","role":"authenticated"}', true);

select is(public.is_username_available('ayse_k'), true, 'free username is available');
select is(public.is_username_available('gizli.kisi'), false, 'username of a hidden account is still taken');
select is(public.is_username_available('admin'), false, 'reserved username is unavailable');
select is(public.is_username_available('Ayse'), false, 'uppercase is not a valid username');

select throws_ok(
  $$ insert into public.profiles (id, username, display_name)
     values ('00000000-0000-0000-0000-0000000000b1', 'ab', 'Ayşe') $$,
  '23514', null, 'username shorter than 3 is rejected'
);
select throws_ok(
  $$ insert into public.profiles (id, username, display_name)
     values ('00000000-0000-0000-0000-0000000000b1', '.ayse', 'Ayşe') $$,
  '23514', null, 'username starting with a dot is rejected'
);
select throws_ok(
  $$ insert into public.profiles (id, username, display_name)
     values ('00000000-0000-0000-0000-0000000000b1', 'ay..se', 'Ayşe') $$,
  '23514', null, 'username with consecutive dots is rejected'
);
select throws_ok(
  $$ insert into public.profiles (id, username, display_name)
     values ('00000000-0000-0000-0000-0000000000b1', 'destek', 'Ayşe') $$,
  'P0001', 'username_reserved', 'reserved username is rejected'
);
select throws_ok(
  $$ insert into public.profiles (id, username, display_name)
     values ('00000000-0000-0000-0000-0000000000b1', 'gizli.kisi', 'Ayşe') $$,
  '23505', null, 'duplicate username is rejected'
);
select throws_ok(
  $$ insert into public.profiles (id, username, display_name)
     values ('00000000-0000-0000-0000-0000000000b2', 'baskasi', 'Başkası') $$,
  '42501', null, 'user cannot create a profile for someone else'
);
select throws_ok(
  $$ insert into public.profiles (id, username, display_name, username_changed_at)
     values ('00000000-0000-0000-0000-0000000000b1', 'ayse_k', 'Ayşe', now() - interval '1 year') $$,
  '42501', null, 'user cannot set username_changed_at'
);
select throws_ok(
  $$ insert into public.profiles (id, username, display_name, avatar_path)
     values ('00000000-0000-0000-0000-0000000000b1', 'ayse_k', 'Ayşe', '00000000-0000-0000-0000-0000000000b2/a.jpg') $$,
  '23514', null, 'avatar path must be inside the user''s own folder'
);
select lives_ok(
  $$ insert into public.profiles (id, username, display_name, bio)
     values ('00000000-0000-0000-0000-0000000000b1', 'ayse_k', '  Ayşe  ', 'Doğa yürüyüşü') $$,
  'user can create their own profile'
);
select is(
  (select display_name from public.profiles where id = '00000000-0000-0000-0000-0000000000b1'),
  'Ayşe', 'display name is trimmed'
);

-- username change rule --------------------------------------------------------
select lives_ok(
  $$ update public.profiles set username = 'ayse.k' where id = '00000000-0000-0000-0000-0000000000b1' $$,
  'first username change is allowed'
);
select throws_ok(
  $$ update public.profiles set username = 'ayse.k2' where id = '00000000-0000-0000-0000-0000000000b1' $$,
  'P0001', 'username_change_too_soon', 'second change within 30 days is rejected'
);
select lives_ok(
  $$ update public.profiles set bio = 'Koşu' where id = '00000000-0000-0000-0000-0000000000b1' $$,
  'other fields can still be edited'
);

-- visibility ------------------------------------------------------------------
select results_eq(
  $$ select username from public.profiles where id::text like '00000000-0000-0000-0000-0000000000%' order by username $$,
  $$ values ('ayse.k'::text) $$,
  'user sees own profile but not pending-deletion or suspended profiles'
);

select is_empty(
  $$ update public.profiles set bio = 'hack' where id <> '00000000-0000-0000-0000-0000000000b1' returning id $$,
  'user cannot edit someone else''s profile'
);

-- interests -------------------------------------------------------------------
select lives_ok(
  $$ insert into public.profile_interests (user_id, category_slug)
     select '00000000-0000-0000-0000-0000000000b1', slug from public.categories order by sort_order limit 10 $$,
  'user can add up to 10 interests'
);
select throws_ok(
  $$ insert into public.profile_interests (user_id, category_slug)
     values ('00000000-0000-0000-0000-0000000000b1', 'volunteering') $$,
  'P0001', 'interest_limit_reached', 'the 11th interest is rejected'
);
select throws_ok(
  $$ insert into public.profile_interests (user_id, category_slug)
     values ('00000000-0000-0000-0000-0000000000b2', 'music') $$,
  '42501', null, 'user cannot add interests to someone else'
);

-- anon ------------------------------------------------------------------------
set local role anon;
select results_eq(
  $$ select username from public.profiles where id::text like '00000000-0000-0000-0000-0000000000%' $$,
  $$ values ('ayse.k'::text) $$,
  'anon sees only active profiles'
);
select is((select count(*)::int from public.profile_interests where user_id::text like '00000000-0000-0000-0000-0000000000%'), 10, 'anon sees interests of active profiles');

-- suspended user cannot write ---------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000b3","role":"authenticated"}', true);

select is(
  (select count(*)::int from public.profiles where id = '00000000-0000-0000-0000-0000000000b3'),
  1, 'suspended user still sees their own profile'
);
select throws_ok(
  $$ update public.profiles set bio = 'x' where id = '00000000-0000-0000-0000-0000000000b3' $$,
  '42501', null, 'suspended user cannot edit their profile'
);

-- staff -----------------------------------------------------------------------
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);
select is((select count(*)::int from public.profiles where id::text like '00000000-0000-0000-0000-0000000000%'), 3, 'staff sees all profiles');

select * from finish();
rollback;
