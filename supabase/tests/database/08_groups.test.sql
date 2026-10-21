begin;
create extension if not exists pgtap with schema extensions;

select plan(62);

-- c1 owner, c2 future admin, c3 member, c4 outsider, c5 suspended account, a1 platform staff.
insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-0000000000a1', 'staff@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000c1', 'c1@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000c2', 'c2@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000c3', 'c3@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000c4', 'c4@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000c5', 'c5@test.local', 'authenticated', 'authenticated');

insert into public.platform_staff (user_id, role) values ('00000000-0000-0000-0000-0000000000a1', 'moderator');

insert into public.profiles (id, username, display_name) values
  ('00000000-0000-0000-0000-0000000000a1', 'test_staff', 'Staff'),
  ('00000000-0000-0000-0000-0000000000c1', 'test_owner', 'Owner'),
  ('00000000-0000-0000-0000-0000000000c2', 'test_admin', 'Admin'),
  ('00000000-0000-0000-0000-0000000000c3', 'test_member', 'Member'),
  ('00000000-0000-0000-0000-0000000000c4', 'test_outsider', 'Outsider'),
  ('00000000-0000-0000-0000-0000000000c5', 'test_suspended', 'Suspended');

update public.account_status set status = 'suspended', suspension_reason = 'test'
where user_id = '00000000-0000-0000-0000-0000000000c5';

-- Acts as the given user (what the backend does in each transaction).
create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;

-- Creation ---------------------------------------------------------------------
select throws_ok(
  $$ insert into public.groups (id, handle, name, category_slug, owner_id)
     values ('00000000-0000-0000-0000-00000000f001', 'kosu', 'Koşu', 'running', '00000000-0000-0000-0000-0000000000c1') $$,
  'P0001', 'group_create_forbidden', 'group cannot be created without an actor'
);

select pg_temp.act('00000000-0000-0000-0000-0000000000c2');
select throws_ok(
  $$ insert into public.groups (id, handle, name, category_slug, owner_id)
     values ('00000000-0000-0000-0000-00000000f001', 'kosu', 'Koşu', 'running', '00000000-0000-0000-0000-0000000000c1') $$,
  'P0001', 'group_create_forbidden', 'nobody can create a group owned by someone else'
);

select pg_temp.act('00000000-0000-0000-0000-0000000000c1');
select throws_ok(
  $$ insert into public.groups (handle, name, category_slug, owner_id)
     values ('destek', 'Destek', 'running', '00000000-0000-0000-0000-0000000000c1') $$,
  'P0001', 'handle_reserved', 'reserved handle is rejected'
);
select throws_ok(
  $$ insert into public.groups (handle, name, category_slug, owner_id)
     values ('.kosu', 'Koşu', 'running', '00000000-0000-0000-0000-0000000000c1') $$,
  '23514', null, 'malformed handle is rejected'
);
select lives_ok(
  $$ insert into public.groups (id, handle, name, category_slug, join_policy, owner_id, member_count, status) values
       ('00000000-0000-0000-0000-00000000f001', 'kosu', '  Koşu Kulübü ', 'running', 'open',    '00000000-0000-0000-0000-0000000000c1', 99, 'active'),
       ('00000000-0000-0000-0000-00000000f002', 'doga', 'Doğa Grubu',     'nature',  'request', '00000000-0000-0000-0000-0000000000c1', 0, 'active'),
       ('00000000-0000-0000-0000-00000000f003', 'muzik', 'Müzik Grubu',   'music',   'invite',  '00000000-0000-0000-0000-0000000000c1', 0, 'active');
     insert into public.group_members (group_id, user_id) values
       ('00000000-0000-0000-0000-00000000f001', '00000000-0000-0000-0000-0000000000c1'),
       ('00000000-0000-0000-0000-00000000f002', '00000000-0000-0000-0000-0000000000c1'),
       ('00000000-0000-0000-0000-00000000f003', '00000000-0000-0000-0000-0000000000c1') $$,
  'owner creates groups and joins them'
);
select is(
  (select (name, member_count)::text from public.groups where id = '00000000-0000-0000-0000-00000000f001'),
  '("Koşu Kulübü",1)', 'name is trimmed and member_count is maintained, not taken from input'
);
select is(public.is_group_handle_available('kosu'), false, 'used handle is unavailable');
select is(public.is_group_handle_available('yeni.grup'), true, 'free handle is available');

-- Joining ------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000000c1');
select throws_ok(
  $$ insert into public.group_members (group_id, user_id)
     values ('00000000-0000-0000-0000-00000000f001', '00000000-0000-0000-0000-0000000000c4') $$,
  'P0001', 'join_not_allowed', 'nobody can add someone else to an open group'
);

select pg_temp.act('00000000-0000-0000-0000-0000000000c2');
select lives_ok(
  $$ insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-00000000f001', '00000000-0000-0000-0000-0000000000c2') $$,
  'user joins an open group'
);
select pg_temp.act('00000000-0000-0000-0000-0000000000c3');
select lives_ok(
  $$ insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-00000000f001', '00000000-0000-0000-0000-0000000000c3') $$,
  'second user joins an open group'
);

select pg_temp.act('00000000-0000-0000-0000-0000000000c5');
select throws_ok(
  $$ insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-00000000f001', '00000000-0000-0000-0000-0000000000c5') $$,
  'P0001', 'account_not_active', 'suspended account cannot join'
);

select pg_temp.act('00000000-0000-0000-0000-0000000000c4');
select throws_ok(
  $$ insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-00000000f002', '00000000-0000-0000-0000-0000000000c4') $$,
  'P0001', 'join_not_allowed', 'request group cannot be joined directly'
);
select throws_ok(
  $$ insert into public.group_join_requests (group_id, user_id) values ('00000000-0000-0000-0000-00000000f003', '00000000-0000-0000-0000-0000000000c4') $$,
  'P0001', 'join_request_not_allowed', 'invite group does not take requests'
);
select lives_ok(
  $$ insert into public.group_join_requests (group_id, user_id) values ('00000000-0000-0000-0000-00000000f002', '00000000-0000-0000-0000-0000000000c4') $$,
  'user requests to join a request group'
);

select pg_temp.act('00000000-0000-0000-0000-0000000000c3');
select throws_ok(
  $$ insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-00000000f002', '00000000-0000-0000-0000-0000000000c4') $$,
  'P0001', 'join_not_allowed', 'non-approver cannot approve a request'
);
select pg_temp.act('00000000-0000-0000-0000-0000000000c1');
select lives_ok(
  $$ insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-00000000f002', '00000000-0000-0000-0000-0000000000c4');
     delete from public.group_join_requests where group_id = '00000000-0000-0000-0000-00000000f002' and user_id = '00000000-0000-0000-0000-0000000000c4' $$,
  'owner approves a request'
);

select pg_temp.act('00000000-0000-0000-0000-0000000000c3');
select throws_ok(
  $$ insert into public.group_invitations (group_id, user_id) values ('00000000-0000-0000-0000-00000000f003', '00000000-0000-0000-0000-0000000000c4') $$,
  'P0001', 'invitation_not_allowed', 'non-member cannot invite'
);
select pg_temp.act('00000000-0000-0000-0000-0000000000c1');
select lives_ok(
  $$ insert into public.group_invitations (group_id, user_id, invited_by)
     values ('00000000-0000-0000-0000-00000000f003', '00000000-0000-0000-0000-0000000000c4', '00000000-0000-0000-0000-0000000000c3') $$,
  'owner invites a user'
);
select is(
  (select invited_by from public.group_invitations where group_id = '00000000-0000-0000-0000-00000000f003'),
  '00000000-0000-0000-0000-0000000000c1'::uuid, 'invited_by is the actor, not the input'
);
select pg_temp.act('00000000-0000-0000-0000-0000000000c4');
select lives_ok(
  $$ insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-00000000f003', '00000000-0000-0000-0000-0000000000c4');
     delete from public.group_invitations where group_id = '00000000-0000-0000-0000-00000000f003' and user_id = '00000000-0000-0000-0000-0000000000c4' $$,
  'invited user joins an invite group'
);

-- Roles and rank rule -------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000000c3');
select throws_ok(
  $$ insert into public.group_member_roles (group_id, user_id, role) values ('00000000-0000-0000-0000-00000000f001', '00000000-0000-0000-0000-0000000000c2', 'admin') $$,
  'P0001', 'role_assign_forbidden', 'member cannot assign roles'
);
select pg_temp.act('00000000-0000-0000-0000-0000000000c1');
select lives_ok(
  $$ insert into public.group_member_roles (group_id, user_id, role) values
       ('00000000-0000-0000-0000-00000000f001', '00000000-0000-0000-0000-0000000000c2', 'admin'),
       ('00000000-0000-0000-0000-00000000f001', '00000000-0000-0000-0000-0000000000c3', 'moderator'),
       ('00000000-0000-0000-0000-00000000f001', '00000000-0000-0000-0000-0000000000c3', 'discipline') $$,
  'owner assigns roles, a member may hold several'
);
select throws_ok(
  $$ insert into public.group_member_roles (group_id, user_id, role) values ('00000000-0000-0000-0000-00000000f001', '00000000-0000-0000-0000-0000000000c1', 'admin') $$,
  'P0001', 'rank_violation', 'owner cannot give themselves a role (equal rank)'
);
select throws_ok(
  $$ insert into public.group_member_roles (group_id, user_id, role) values ('00000000-0000-0000-0000-00000000f001', '00000000-0000-0000-0000-0000000000c4', 'admin') $$,
  '23503', null, 'roles are only given to members'
);
select throws_ok(
  $$ insert into public.group_member_roles (group_id, user_id, role) values ('00000000-0000-0000-0000-00000000f001', '00000000-0000-0000-0000-0000000000c2', 'owner') $$,
  'P0001', 'rank_violation', 'owner is not an assignable role'
);
select pg_temp.act('00000000-0000-0000-0000-0000000000c2');
select throws_ok(
  $$ delete from public.group_member_roles where group_id = '00000000-0000-0000-0000-00000000f001' and user_id = '00000000-0000-0000-0000-0000000000c3' and role = 'moderator' $$,
  'P0001', 'role_assign_forbidden', 'admin cannot remove roles'
);
select is(
  private.group_rank('00000000-0000-0000-0000-00000000f001', '00000000-0000-0000-0000-0000000000c3'),
  60, 'effective rank is the highest role'
);

-- Permissions as seen by clients ---------------------------------------------------
set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000000c2');
select is(private.has_group_permission('00000000-0000-0000-0000-00000000f001', 'group.edit'), true, 'admin can edit the group');
select is(private.has_group_permission('00000000-0000-0000-0000-00000000f001', 'roles.assign'), false, 'admin cannot assign roles');
select is(private.has_group_permission('00000000-0000-0000-0000-00000000f002', 'group.edit'), false, 'admin role does not carry over to other groups');
select is(private.has_group_permission('00000000-0000-0000-0000-00000000f001', 'no.such'), false, 'unknown permission is never granted');
select pg_temp.act('00000000-0000-0000-0000-0000000000c1');
select is(
  public.my_group_permissions('00000000-0000-0000-0000-00000000f001'),
  (select array_agg(slug order by slug) from public.group_permissions),
  'owner holds every permission'
);
select pg_temp.act('00000000-0000-0000-0000-0000000000c3');
select is(public.my_group_permissions('00000000-0000-0000-0000-00000000f001'), '{live.moderate,members.mute,reports.review}'::text[], 'moderator moderates live broadcasts, reports and emergency mutes');

select throws_ok(
  $$ insert into public.groups (handle, name, category_slug, owner_id) values ('direct', 'Direct', 'art', '00000000-0000-0000-0000-0000000000c3') $$,
  '42501', null, 'clients cannot create groups directly'
);
select throws_ok(
  $$ insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-00000000f001', '00000000-0000-0000-0000-0000000000c3') $$,
  '42501', null, 'clients cannot write memberships directly'
);
select throws_ok(
  $$ update public.groups set name = 'Hack' where id = '00000000-0000-0000-0000-00000000f001' $$,
  '42501', null, 'clients cannot update groups directly'
);

select pg_temp.act('00000000-0000-0000-0000-0000000000c2');
select is((select count(*)::int from public.group_join_requests), 0, 'non-approver sees no join requests of others');

select lives_ok(
  $$ insert into storage.objects (bucket_id, name, owner_id)
     values ('group-images', '00000000-0000-0000-0000-00000000f001/logo.jpg', '00000000-0000-0000-0000-0000000000c2') $$,
  'editor uploads into the group folder'
);
select pg_temp.act('00000000-0000-0000-0000-0000000000c3');
select throws_ok(
  $$ insert into storage.objects (bucket_id, name, owner_id)
     values ('group-images', '00000000-0000-0000-0000-00000000f001/cover.jpg', '00000000-0000-0000-0000-0000000000c3') $$,
  '42501', null, 'member without group.edit cannot upload'
);
select pg_temp.act('00000000-0000-0000-0000-0000000000c2');
select throws_ok(
  $$ insert into storage.objects (bucket_id, name, owner_id)
     values ('group-images', 'not-a-group/logo.jpg', '00000000-0000-0000-0000-0000000000c2') $$,
  '42501', null, 'upload outside a group folder is rejected'
);
reset role;

-- Edit, transfer, leave --------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000000c3');
select throws_ok(
  $$ update public.groups set about = 'x' where id = '00000000-0000-0000-0000-00000000f001' $$,
  'P0001', 'group_edit_forbidden', 'member cannot edit the group'
);
select pg_temp.act('00000000-0000-0000-0000-0000000000c2');
select lives_ok(
  $$ update public.groups set about = 'Her pazar koşuyoruz.' where id = '00000000-0000-0000-0000-00000000f001' $$,
  'admin edits the group'
);
select throws_ok(
  $$ update public.groups set handle = 'kosu2' where id = '00000000-0000-0000-0000-00000000f001' $$,
  'P0001', 'handle_immutable', 'handle cannot change'
);
select throws_ok(
  $$ update public.groups set owner_id = '00000000-0000-0000-0000-0000000000c2' where id = '00000000-0000-0000-0000-00000000f001' $$,
  'P0001', 'ownership_transfer_forbidden', 'admin cannot take ownership'
);
select pg_temp.act('00000000-0000-0000-0000-0000000000c1');
select throws_ok(
  $$ delete from public.group_members where group_id = '00000000-0000-0000-0000-00000000f001' and user_id = '00000000-0000-0000-0000-0000000000c1' $$,
  'P0001', 'owner_cannot_leave', 'owner cannot leave'
);
select throws_ok(
  $$ delete from public.group_members where group_id = '00000000-0000-0000-0000-00000000f001' and user_id = '00000000-0000-0000-0000-0000000000c3' $$,
  'P0001', 'leave_not_allowed', 'removing another member is not a Phase 2 action'
);
select throws_ok(
  $$ update public.groups set owner_id = '00000000-0000-0000-0000-0000000000c5' where id = '00000000-0000-0000-0000-00000000f001' $$,
  'P0001', 'new_owner_not_member', 'ownership only goes to a member'
);
select lives_ok(
  $$ update public.groups set owner_id = '00000000-0000-0000-0000-0000000000c2' where id = '00000000-0000-0000-0000-00000000f001' $$,
  'owner transfers ownership to a member'
);

select pg_temp.act('00000000-0000-0000-0000-0000000000c3');
select lives_ok(
  $$ delete from public.group_members where group_id = '00000000-0000-0000-0000-00000000f001' and user_id = '00000000-0000-0000-0000-0000000000c3' $$,
  'member leaves'
);
select is(
  (select count(*)::int from public.group_member_roles where user_id = '00000000-0000-0000-0000-0000000000c3'),
  0, 'roles go with the membership'
);

-- Suspension and visibility ------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000000c1');
select throws_ok(
  $$ update public.groups set status = 'suspended', suspended_at = now(), suspension_reason = 'x' where id = '00000000-0000-0000-0000-00000000f002' $$,
  'P0001', 'group_suspension_forbidden', 'owner cannot change the platform status'
);
select pg_temp.act('00000000-0000-0000-0000-0000000000a1');
select lives_ok(
  $$ update public.groups set status = 'suspended', suspended_at = now(), suspension_reason = 'Spam' where id = '00000000-0000-0000-0000-00000000f002' $$,
  'platform moderator suspends a group'
);

set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000000c3');
select is(
  (select count(*)::int from public.groups where id = '00000000-0000-0000-0000-00000000f002'),
  0, 'suspended group is hidden from non-members'
);
select pg_temp.act('00000000-0000-0000-0000-0000000000c4');
select is(
  (select count(*)::int from public.groups where id = '00000000-0000-0000-0000-00000000f002'),
  1, 'suspended group stays visible to its members'
);
select pg_temp.act('00000000-0000-0000-0000-0000000000c1');
select is(private.has_group_permission('00000000-0000-0000-0000-00000000f002', 'group.edit'), false, 'no permission works in a suspended group');
reset role;

set local role anon;
select is((select count(*)::int from public.groups where handle in ('kosu', 'muzik')), 2, 'anonymous visitors see active groups');
select throws_ok($$ select * from public.group_invitations $$, '42501', null, 'anonymous visitors cannot read invitations');
reset role;

-- Deletion and cascades -----------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000000c4');
select throws_ok(
  $$ delete from public.groups where id = '00000000-0000-0000-0000-00000000f003' $$,
  'P0001', 'group_delete_forbidden', 'member cannot delete the group'
);
select pg_temp.act('00000000-0000-0000-0000-0000000000c1');
select lives_ok(
  $$ delete from public.groups where id = '00000000-0000-0000-0000-00000000f003' $$,
  'owner deletes the group with its memberships'
);

select pg_temp.act('00000000-0000-0000-0000-0000000000c1');
select throws_ok(
  $$ delete from public.profiles where id = '00000000-0000-0000-0000-0000000000c1' $$,
  '23503', null, 'a group owner''s profile cannot be deleted'
);

select set_config('request.jwt.claims', '', true);
select lives_ok(
  $$ delete from auth.users where id = '00000000-0000-0000-0000-0000000000c4' $$,
  'account purge cascades memberships without an actor'
);

select * from finish();
rollback;
