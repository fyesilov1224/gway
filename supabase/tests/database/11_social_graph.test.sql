begin;
create extension if not exists pgtap with schema extensions;

select plan(31);

-- k1 public, k2 private, k3 public, k4 private (later switches to public).
insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-0000000bb001', 'k1@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000bb002', 'k2@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000bb003', 'k3@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000bb004', 'k4@test.local', 'authenticated', 'authenticated');
insert into public.profiles (id, username, display_name, is_private) values
  ('00000000-0000-0000-0000-0000000bb001', 'graph_one', 'One', false),
  ('00000000-0000-0000-0000-0000000bb002', 'graph_two', 'Two', true),
  ('00000000-0000-0000-0000-0000000bb003', 'graph_three', 'Three', false),
  ('00000000-0000-0000-0000-0000000bb004', 'graph_four', 'Four', true);

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;

-- Writes are the backend's ----------------------------------------------------------
set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000bb001');
select throws_ok(
  $$ insert into public.follows (follower_id, followee_id) values ('00000000-0000-0000-0000-0000000bb001', '00000000-0000-0000-0000-0000000bb003') $$,
  '42501', null, 'clients cannot follow directly'
);
select throws_ok(
  $$ insert into public.blocks (blocker_id, blocked_id) values ('00000000-0000-0000-0000-0000000bb001', '00000000-0000-0000-0000-0000000bb003') $$,
  '42501', null, 'clients cannot block directly'
);
reset role;

select set_config('request.jwt.claims', '', true);
select throws_ok(
  $$ insert into public.follows (follower_id, followee_id) values ('00000000-0000-0000-0000-0000000bb001', '00000000-0000-0000-0000-0000000bb003') $$,
  'P0001', 'follow_forbidden', 'a follow needs an actor'
);

-- Public and private accounts --------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000bb001');
select lives_ok(
  $$ insert into public.follows (follower_id, followee_id) values ('00000000-0000-0000-0000-0000000bb001', '00000000-0000-0000-0000-0000000bb003') $$,
  'following a public account is immediate'
);
select throws_ok(
  $$ insert into public.follows (follower_id, followee_id) values ('00000000-0000-0000-0000-0000000bb001', '00000000-0000-0000-0000-0000000bb002') $$,
  'P0001', 'follow_requires_approval', 'a private account needs a request'
);
select throws_ok(
  $$ insert into public.follow_requests (requester_id, target_id) values ('00000000-0000-0000-0000-0000000bb001', '00000000-0000-0000-0000-0000000bb003') $$,
  'P0001', 'account_is_public', 'public accounts take no requests'
);
select lives_ok(
  $$ insert into public.follow_requests (requester_id, target_id) values ('00000000-0000-0000-0000-0000000bb001', '00000000-0000-0000-0000-0000000bb002') $$,
  'a user asks to follow a private account'
);

select pg_temp.act('00000000-0000-0000-0000-0000000bb003');
select throws_ok(
  $$ insert into public.follows (follower_id, followee_id) values ('00000000-0000-0000-0000-0000000bb001', '00000000-0000-0000-0000-0000000bb002') $$,
  'P0001', 'follow_forbidden', 'nobody accepts on someone else''s behalf'
);
select pg_temp.act('00000000-0000-0000-0000-0000000bb002');
select throws_ok(
  $$ insert into public.follows (follower_id, followee_id) values ('00000000-0000-0000-0000-0000000bb003', '00000000-0000-0000-0000-0000000bb002') $$,
  'P0001', 'no_follow_request', 'accepting needs a request'
);
select lives_ok(
  $$ insert into public.follows (follower_id, followee_id) values ('00000000-0000-0000-0000-0000000bb001', '00000000-0000-0000-0000-0000000bb002');
     delete from public.follow_requests where requester_id = '00000000-0000-0000-0000-0000000bb001' and target_id = '00000000-0000-0000-0000-0000000bb002' $$,
  'the private account accepts the request'
);

-- Who sees what ---------------------------------------------------------------------
set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000bb003');
select is(private.can_view_user_content('00000000-0000-0000-0000-0000000bb002'), false, 'a private account''s content is hidden from non-followers');
select is((select count(*)::int from public.follows where followee_id = '00000000-0000-0000-0000-0000000bb002'), 0,
  'a private account''s followers are hidden from non-followers');
select is((select count(*)::int from public.follow_requests), 0, 'requests are visible to their parties only');
select pg_temp.act('00000000-0000-0000-0000-0000000bb001');
select is(private.can_view_user_content('00000000-0000-0000-0000-0000000bb002'), true, 'followers see a private account''s content');
select is((select count(*)::int from public.follows where followee_id = '00000000-0000-0000-0000-0000000bb002'), 1, 'and its followers');
select is(
  (select (follower_count, following_count, i_follow, follows_me, is_private, can_view)::text
   from public.profile_social('00000000-0000-0000-0000-0000000bb002')),
  '(1,0,t,f,t,t)', 'profile counts and relationship'
);
reset role;

-- Removing a follower and unfollowing ------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000bb004');
select throws_ok(
  $$ delete from public.follows where follower_id = '00000000-0000-0000-0000-0000000bb001' and followee_id = '00000000-0000-0000-0000-0000000bb003' $$,
  'P0001', 'unfollow_forbidden', 'outsiders cannot end a follow'
);
select pg_temp.act('00000000-0000-0000-0000-0000000bb002');
select lives_ok(
  $$ delete from public.follows where follower_id = '00000000-0000-0000-0000-0000000bb001' and followee_id = '00000000-0000-0000-0000-0000000bb002' $$,
  'a user removes a follower'
);

-- Blocking ------------------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000bb003');
select lives_ok(
  $$ insert into public.blocks (blocker_id, blocked_id) values ('00000000-0000-0000-0000-0000000bb003', '00000000-0000-0000-0000-0000000bb001') $$,
  'a user blocks someone'
);
select is(
  (select count(*)::int from public.follows where '00000000-0000-0000-0000-0000000bb003' in (follower_id, followee_id)
     and '00000000-0000-0000-0000-0000000bb001' in (follower_id, followee_id)),
  0, 'a block removes follows in both directions'
);
select pg_temp.act('00000000-0000-0000-0000-0000000bb001');
select throws_ok(
  $$ insert into public.follows (follower_id, followee_id) values ('00000000-0000-0000-0000-0000000bb001', '00000000-0000-0000-0000-0000000bb003') $$,
  'P0001', 'blocked', 'a blocked user cannot follow again'
);
select throws_ok(
  $$ delete from public.blocks where blocker_id = '00000000-0000-0000-0000-0000000bb003' $$,
  'P0001', 'unblock_forbidden', 'only the blocker unblocks'
);

set local role authenticated;
select is((select count(*)::int from public.profiles where id = '00000000-0000-0000-0000-0000000bb003'), 0,
  'a blocked user no longer sees the blocker''s profile');
select is((select count(*)::int from public.blocks), 0, 'blocks are private to the blocker');
select is((select count(*)::int from public.search_profiles('graph_three')), 0, 'search hides the blocker');
select pg_temp.act('00000000-0000-0000-0000-0000000bb003');
select is((select count(*)::int from public.profiles where id = '00000000-0000-0000-0000-0000000bb001'), 1,
  'the blocker still sees the blocked profile (to unblock)');
select is((select count(*)::int from public.blocks), 1, 'the blocker sees the block');
reset role;

-- Going public accepts pending requests ----------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000bb001');
insert into public.follow_requests (requester_id, target_id) values ('00000000-0000-0000-0000-0000000bb001', '00000000-0000-0000-0000-0000000bb004');
select pg_temp.act('00000000-0000-0000-0000-0000000bb004');
update public.profiles set is_private = false where id = '00000000-0000-0000-0000-0000000bb004';
select is(
  (select (exists (select 1 from public.follows where follower_id = '00000000-0000-0000-0000-0000000bb001'
                   and followee_id = '00000000-0000-0000-0000-0000000bb004'),
           exists (select 1 from public.follow_requests where target_id = '00000000-0000-0000-0000-0000000bb004'))::text),
  '(t,f)', 'going public turns requests into follows'
);

-- Group follows (own simple write) -----------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000bb001');
insert into public.groups (id, handle, name, category_slug, owner_id)
values ('00000000-0000-0000-0000-00000000e201', 'takip.grubu', 'Takip Grubu', 'music', '00000000-0000-0000-0000-0000000bb001');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-00000000e201', '00000000-0000-0000-0000-0000000bb001');

set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000bb002');
select lives_ok(
  $$ insert into public.group_follows (user_id, group_id) values ('00000000-0000-0000-0000-0000000bb002', '00000000-0000-0000-0000-00000000e201') $$,
  'a user follows a group'
);
select throws_ok(
  $$ insert into public.group_follows (user_id, group_id) values ('00000000-0000-0000-0000-0000000bb004', '00000000-0000-0000-0000-00000000e201') $$,
  '42501', null, 'nobody follows a group for someone else'
);
select lives_ok(
  $$ delete from public.group_follows where group_id = '00000000-0000-0000-0000-00000000e201' $$,
  'a user unfollows a group'
);

select * from finish();
rollback;
