begin;
create extension if not exists pgtap with schema extensions;

select plan(22);

-- o1 owner of an invite-only group, m1 plain member, n1 and n2 newcomers, a1 platform moderator.
insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-00000051a001', 'link-staff@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000051d001', 'link-owner@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000051c001', 'link-m1@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000051c002', 'link-n1@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000051c003', 'link-n2@test.local', 'authenticated', 'authenticated');

insert into public.profiles (id, username, display_name) values
  ('00000000-0000-0000-0000-00000051a001', 'link_staff', 'Staff'),
  ('00000000-0000-0000-0000-00000051d001', 'link_owner', 'Owner'),
  ('00000000-0000-0000-0000-00000051c001', 'link_m1', 'M1'),
  ('00000000-0000-0000-0000-00000051c002', 'link_n1', 'N1'),
  ('00000000-0000-0000-0000-00000051c003', 'link_n2', 'N2');

insert into public.platform_staff (user_id, role) values ('00000000-0000-0000-0000-00000051a001', 'moderator');

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;

-- A link of group 5101 made by the owner.
create function pg_temp.link(id uuid, code text, days int, max_uses int) returns void language sql as $$
  insert into public.group_invite_links (id, group_id, code, created_by, expires_at, max_uses)
  values (id, '00000000-0000-0000-0000-000000005101', code, '00000000-0000-0000-0000-00000051d001', now() + make_interval(days => days), max_uses);
$$;

select pg_temp.act('00000000-0000-0000-0000-00000051d001');
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id)
values ('00000000-0000-0000-0000-000000005101', 'link.test', 'Link', 'cycling', 'invite', '00000000-0000-0000-0000-00000051d001');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-000000005101', '00000000-0000-0000-0000-00000051d001');
-- m1 joins with an in-app invitation from the owner.
insert into public.group_invitations (group_id, user_id, invited_by)
values ('00000000-0000-0000-0000-000000005101', '00000000-0000-0000-0000-00000051c001', '00000000-0000-0000-0000-00000051d001');
select pg_temp.act('00000000-0000-0000-0000-00000051c001');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-000000005101', '00000000-0000-0000-0000-00000051c001');

-- Making links -------------------------------------------------------------------------
set local role authenticated;
select throws_ok(
  $$ insert into public.group_invite_links (group_id, code, created_by, expires_at)
     values ('00000000-0000-0000-0000-000000005101', 'abcdefghjkmn', '00000000-0000-0000-0000-00000051c001', now() + interval '1 day') $$,
  '42501', null, 'clients cannot write links');
reset role;

select throws_ok(
  $$ insert into public.group_invite_links (group_id, code, created_by, expires_at)
     values ('00000000-0000-0000-0000-000000005101', 'abcdefghjkmn', '00000000-0000-0000-0000-00000051c001', now() + interval '1 day') $$,
  'P0001', 'invitation_forbidden', 'a plain member cannot make a link');
select pg_temp.act('00000000-0000-0000-0000-00000051d001');
select throws_ok($$ select pg_temp.link(gen_random_uuid(), 'abcdefghjkmn', 31, null) $$,
  'P0001', 'invite_link_invalid', 'a link lasts at most 30 days');
select throws_ok($$ select pg_temp.link(gen_random_uuid(), 'ABCDEFGHJKMN', 7, null) $$,
  '23514', null, 'codes have the fixed alphabet');
select throws_ok($$ select pg_temp.link(gen_random_uuid(), 'abcdefghjkmn', 7, 0) $$,
  '23514', null, 'a use limit is at least 1');
select lives_ok($$ select pg_temp.link('00000000-0000-0000-0000-0000005100b1', 'abcdefghjkmn', 7, 1) $$,
  'an inviter makes a link with a use limit');
select lives_ok($$ select pg_temp.link('00000000-0000-0000-0000-0000005100b2', 'pqrstuvwxyz2', 1, null) $$,
  'an inviter makes an unlimited link');
select throws_ok(
  $$ select pg_temp.link(gen_random_uuid(), 'zz' || translate(lpad(n::text, 10, '0'), '0123456789', 'abcdefghjk'), 7, null) from generate_series(1, 19) n $$,
  'P0001', 'invite_link_limit_reached', 'a group has at most 20 valid links');

-- Who sees them --------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-00000051c001');
set local role authenticated;
select is((select count(*) from public.group_invite_links), 0::bigint, 'a plain member does not see the links');
reset role;
select pg_temp.act('00000000-0000-0000-0000-00000051a001');
set local role authenticated;
select is((select count(*) from public.group_invite_links), 2::bigint, 'platform staff see the links');
reset role;
set local role anon;
select ok((public.invite_link_preview('abcdefghjkmn') ->> 'valid')::boolean, 'anyone previews a valid link');
select is(public.invite_link_preview('abcdefghjkmn') #>> '{group,handle}', 'link.test', 'the preview shows the public group');
select is(public.invite_link_preview('nosuchcode22'), null, 'an unknown code shows nothing');
reset role;

-- Joining ----------------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-00000051c002');
select throws_ok(
  $$ insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-000000005101', '00000000-0000-0000-0000-00000051c002') $$,
  'P0001', 'join_not_allowed', 'an invite-only group still needs an invitation');
select throws_ok(
  $$ insert into public.group_invite_link_uses (link_id, user_id) values ('00000000-0000-0000-0000-0000005100b1', '00000000-0000-0000-0000-00000051c003') $$,
  'P0001', 'invite_link_invalid', 'nobody uses a link for someone else');
select lives_ok(
  $$ insert into public.group_invite_link_uses (link_id, user_id) values ('00000000-0000-0000-0000-0000005100b1', '00000000-0000-0000-0000-00000051c002');
     insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-000000005101', '00000000-0000-0000-0000-00000051c002') $$,
  'a valid link lets the newcomer join the invite-only group');
select is((select use_count from public.group_invite_links where id = '00000000-0000-0000-0000-0000005100b1'), 1, 'the use is counted');

select pg_temp.act('00000000-0000-0000-0000-00000051c003');
select throws_ok(
  $$ insert into public.group_invite_link_uses (link_id, user_id) values ('00000000-0000-0000-0000-0000005100b1', '00000000-0000-0000-0000-00000051c003') $$,
  'P0001', 'invite_link_invalid', 'a used-up link lets nobody else in');

-- Revoking ----------------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-00000051c001');
select throws_ok(
  $$ update public.group_invite_links set revoked_at = now(), revoked_by = '00000000-0000-0000-0000-00000051c001'
     where id = '00000000-0000-0000-0000-0000005100b2' $$,
  'P0001', 'invitation_forbidden', 'a plain member cannot revoke');
select pg_temp.act('00000000-0000-0000-0000-00000051a001');
select lives_ok(
  $$ update public.group_invite_links set revoked_at = now(), revoked_by = '00000000-0000-0000-0000-00000051a001'
     where id = '00000000-0000-0000-0000-0000005100b2' $$,
  'a platform moderator revokes a link');
select ok(not (public.invite_link_preview('pqrstuvwxyz2') ->> 'valid')::boolean, 'a revoked link is no longer valid');
select throws_ok(
  $$ update public.group_invite_links set use_count = 0 where id = '00000000-0000-0000-0000-0000005100b1' $$,
  'P0001', 'invite_link_immutable', 'the counter cannot be reset');

select * from finish();
rollback;
