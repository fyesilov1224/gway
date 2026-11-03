begin;
create extension if not exists pgtap with schema extensions;

select plan(28);

-- n1 owner, n2 n3 Yönetici, n4 Disiplin Kurulu, n5 n6 n7 members, n8 Moderatör.
insert into auth.users (id, email, aud, role)
select ('00000000-0000-0000-0000-0000000bf00' || i)::uuid, 'n' || i || '@test.local', 'authenticated', 'authenticated'
from generate_series(1, 8) i;
insert into public.profiles (id, username, display_name)
select ('00000000-0000-0000-0000-0000000bf00' || i)::uuid, 'ban_user' || i, 'Ban ' || i
from generate_series(1, 8) i;

create function pg_temp.act(i int) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', ('00000000-0000-0000-0000-0000000bf00' || i), 'role', 'authenticated')::text, true);
$$;
create function pg_temp.u(i int) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000000bf00' || i)::uuid $$;
create function pg_temp.g() returns uuid language sql as $$ select '00000000-0000-0000-0000-0000000bd001'::uuid $$;
create function pg_temp.ban(by_user int, subject int, days int, illegal text default null) returns uuid language plpgsql as $$
declare id uuid;
begin
  perform pg_temp.act(by_user);
  insert into public.moderation_cases (group_id, subject_id, opened_by, sanction, duration_days, reason, threshold, voting_ends_at,
                                       illegal_category, direct)
  values (pg_temp.g(), pg_temp.u(subject), pg_temp.u(by_user), 'ban', days, 'Grup kurallarını ağır biçimde çiğnedi', 'majority', now(),
          illegal, true)
  returning moderation_cases.id into id;
  return id;
end;
$$;

select pg_temp.act(1);
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id)
values (pg_temp.g(), 'ban.grubu', 'Ban Grubu', 'hiking', 'open', pg_temp.u(1));
insert into public.group_members (group_id, user_id) values (pg_temp.g(), pg_temp.u(1));
do $$ begin
  for i in 2..8 loop
    perform pg_temp.act(i);
    insert into public.group_members (group_id, user_id) values (pg_temp.g(), pg_temp.u(i));
  end loop;
end $$;
select pg_temp.act(1);
insert into public.group_member_roles (group_id, user_id, role) values
  (pg_temp.g(), pg_temp.u(2), 'admin'),
  (pg_temp.g(), pg_temp.u(3), 'admin'),
  (pg_temp.g(), pg_temp.u(4), 'discipline'),
  (pg_temp.g(), pg_temp.u(8), 'moderator');

-- 1. Direct bans -----------------------------------------------------------------------------------------
select ok(private.user_has_group_permission(pg_temp.u(2), pg_temp.g(), 'members.ban'), 'a Yönetici may ban without a vote');
select ok(not private.user_has_group_permission(pg_temp.u(4), pg_temp.g(), 'members.ban'), 'the board does not');
select ok(not private.user_has_group_permission(pg_temp.u(8), pg_temp.g(), 'members.ban'), 'nor does a Moderatör');

select throws_ok($$ select pg_temp.ban(8, 5, 30) $$, 'P0001', 'case_forbidden', 'a Moderatör cannot ban directly');
select throws_ok($$ select pg_temp.ban(2, 3, 30) $$, 'P0001', 'rank_violation', 'a Yönetici cannot ban another Yönetici');
select throws_ok($$ select pg_temp.ban(2, 1, null) $$, 'P0001', 'rank_violation', 'nor the owner');
select throws_ok(
  $$ select pg_temp.act(2);
     insert into public.moderation_cases (group_id, subject_id, opened_by, sanction, reason, threshold, voting_ends_at, direct)
     values (pg_temp.g(), pg_temp.u(5), pg_temp.u(2), 'kick', 'Grup kurallarını çiğnedi', 'majority', now(), true) $$,
  '23514', null, 'only a ban goes without a vote');

-- A board case is open about n5 when the Yönetici bans directly.
select pg_temp.act(8);
insert into public.moderation_cases (id, group_id, subject_id, opened_by, sanction, duration_days, reason, threshold, voting_ends_at)
values ('00000000-0000-0000-0000-0000000bc001', pg_temp.g(), pg_temp.u(5), pg_temp.u(8), 'mute', 7, 'Yorumlarda hakaret ediyor', 'majority', now());
insert into public.sanctions (case_id, type, interim) values ('00000000-0000-0000-0000-0000000bc001', 'mute', true);

select lives_ok($$ select pg_temp.ban(2, 5, 30) $$, 'a Yönetici bans a member for 30 days without a vote');
select is((select status from public.moderation_cases where subject_id = pg_temp.u(5) and direct), 'approved', 'the direct case is approved at once');
select is((select count(*)::int from public.case_votes v join public.moderation_cases c on c.id = v.case_id
           where c.subject_id = pg_temp.u(5) and c.direct), 0, 'nobody votes on it');
select is((select count(*)::int from public.notifications where type = 'case_vote' and actor_id = pg_temp.u(2)), 0,
  'and nobody is asked to');
select is(private.case_outcome('00000000-0000-0000-0000-0000000bc001'), 'rejected', 'the open board case is superseded');
select lives_ok(
  $$ update public.moderation_cases set status = 'rejected' where id = '00000000-0000-0000-0000-0000000bc001' $$,
  'and closes as rejected');
select lives_ok(
  $$ update public.sanctions set lifted_at = now(), lift_reason = 'decided'
     where case_id = '00000000-0000-0000-0000-0000000bc001' and interim $$,
  'its emergency mute is lifted');

select pg_temp.act(2);
select lives_ok(
  $$ insert into public.sanctions (case_id, type) select id, 'ban' from public.moderation_cases where subject_id = pg_temp.u(5) and direct $$,
  'the ban of the approved direct case is applied');
select ok((select ends_at between now() + interval '29 days' and now() + interval '31 days' from public.sanctions
           where user_id = pg_temp.u(5) and type = 'ban'), 'for the 30 days chosen');

-- Permanent and illegal: the owner bans a Yönetici.
select lives_ok($$ select pg_temp.ban(1, 3, null, 'fraud') $$, 'the owner bans a Yönetici permanently as illegal activity');
select is((select status from public.moderation_cases where subject_id = pg_temp.u(3) and direct), 'approved',
  'the illegal-activity case is approved, so a platform referral may open from it');

-- 2. Call permission from a group --------------------------------------------------------------------------
set local role authenticated;
select pg_temp.act(6);
select throws_ok($$ select public.request_call_permission('00000000-0000-0000-0000-0000000bd999', null) $$, 'P0001', 'call_group_invalid',
  'a request goes to a group the person belongs to');
select lives_ok($$ select public.request_call_permission(pg_temp.g(), 'Ekip arkadaşımla konuşmak istiyorum') $$, 'a member asks the group');
select pg_temp.act(2);
select is((select (public.group_call_permissions(pg_temp.g())->'items'->0->>'status')), 'requested', 'the Yönetici sees the request');
select pg_temp.act(7);
select is(public.group_call_permissions(pg_temp.g()), null, 'a plain member does not');
reset role;

select pg_temp.act(6);
select throws_ok($$ update public.call_permissions set status = 'active' where user_id = pg_temp.u(6) $$, 'P0001', 'call_forbidden',
  'the person cannot decide their own request');
select pg_temp.act(8);
select throws_ok($$ update public.call_permissions set status = 'active' where user_id = pg_temp.u(6) $$, 'P0001', 'call_forbidden',
  'a Moderatör cannot decide');
select pg_temp.act(2);
update public.call_permissions set status = 'active' where user_id = pg_temp.u(6);
select ok(private.has_call_permission(pg_temp.u(6)), 'the Yönetici opens voice calls for the member');

-- The board member asks and is declined; the owner asks and is granted, but a Yönetici cannot close it (rank).
select pg_temp.act(4);
select public.request_call_permission(pg_temp.g(), null);
select pg_temp.act(2);
update public.call_permissions set status = 'declined', reason = 'Şimdilik değil' where user_id = pg_temp.u(4);
select is((select status from public.call_permissions where user_id = pg_temp.u(4)), 'declined', 'a Yönetici declines a lower rank');
select pg_temp.act(1);
select public.request_call_permission(pg_temp.g(), null);
select pg_temp.act(2);
update public.call_permissions set status = 'active' where user_id = pg_temp.u(1);
select throws_ok($$ update public.call_permissions set status = 'revoked', reason = 'Kapat' where user_id = pg_temp.u(1) $$,
  'P0001', 'call_rank_violation', 'a Yönetici opens the owner''s request but cannot close it');


-- Leaving the group closes the permission it gave.
select pg_temp.act(6);
delete from public.group_members where group_id = pg_temp.g() and user_id = pg_temp.u(6);
select is((select status from public.call_permissions where user_id = pg_temp.u(6)), 'revoked', 'leaving the group closes the permission');

select * from finish();
rollback;
