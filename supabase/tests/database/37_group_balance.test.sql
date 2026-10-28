begin;
create extension if not exists pgtap with schema extensions;

select plan(18);

-- b1 owner of g1, b2 owner of g2, b3 member of both, b4 outsider, b5 member of g2 with public groups,
-- b6 moderator of g2, b7 platform staff.
insert into auth.users (id, email, aud, role)
select ('00000000-0000-0000-0000-0000004700b' || i)::uuid, 'bal' || i || '@test.local', 'authenticated', 'authenticated'
from generate_series(1, 7) i;
insert into public.profiles (id, username, display_name)
select ('00000000-0000-0000-0000-0000004700b' || i)::uuid, 'bal_user' || i, 'Bal ' || i
from generate_series(1, 7) i;
update public.profiles set groups_public = true where id = '00000000-0000-0000-0000-0000004700b5';
insert into public.platform_staff (user_id, role) values ('00000000-0000-0000-0000-0000004700b7', 'support');

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;
create function pg_temp.u(i int) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000004700b' || i)::uuid $$;
create function pg_temp.g(i int) returns uuid language sql as $$ select ('00000000-0000-0000-0000-00000047000' || i)::uuid $$;
create function pg_temp.join(grp int, i int) returns void language plpgsql as $$
begin
  perform pg_temp.act(pg_temp.u(i)::text);
  insert into public.group_members (group_id, user_id) values (pg_temp.g(grp), pg_temp.u(i));
end $$;

select pg_temp.act(pg_temp.u(1)::text);
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id, province)
values (pg_temp.g(1), 'denge.bir', 'Denge Bir', 'hiking', 'open', pg_temp.u(1), 34);
insert into public.group_members (group_id, user_id) values (pg_temp.g(1), pg_temp.u(1));
select pg_temp.act(pg_temp.u(2)::text);
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id, province)
values (pg_temp.g(2), 'denge.iki', 'Denge İki', 'hiking', 'open', pg_temp.u(2), 34);
insert into public.group_members (group_id, user_id) values (pg_temp.g(2), pg_temp.u(2));
select pg_temp.join(1, 3), pg_temp.join(2, 3), pg_temp.join(2, 5), pg_temp.join(2, 6);
select pg_temp.act(pg_temp.u(2)::text);
insert into public.group_member_roles (group_id, user_id, role) values (pg_temp.g(2), pg_temp.u(6), 'moderator');

-- Membership visibility ---------------------------------------------------------------------------
set local role authenticated;
select pg_temp.act(pg_temp.u(1)::text);
select is(
  (select array_agg(user_id order by user_id) from public.group_members where group_id = pg_temp.g(2)),
  array[pg_temp.u(2), pg_temp.u(5), pg_temp.u(6)],
  'another group''s owner sees its team and public members, not the shared member');
select is(
  (select count(*)::int from public.group_members where user_id = pg_temp.u(3)), 1,
  'on a member''s profile another group''s owner sees only the shared group');
select ok(
  exists (select 1 from public.group_members where group_id = pg_temp.g(1) and user_id = pg_temp.u(3)),
  'the owner sees their own member');

select pg_temp.act(pg_temp.u(3)::text);
select is((select count(*)::int from public.group_members where user_id = pg_temp.u(3)), 2, 'a person sees all their memberships');

select pg_temp.act(pg_temp.u(5)::text);
select is((select count(*)::int from public.group_members where group_id = pg_temp.g(2)), 4, 'a member sees the whole member list');

select pg_temp.act(pg_temp.u(4)::text);
select is((select count(*)::int from public.group_members where group_id = pg_temp.g(2)), 3, 'an outsider sees the team and public members');
select is((select member_count from public.groups where id = pg_temp.g(2)), 4, 'the member count stays public');

select pg_temp.act(pg_temp.u(7)::text);
select is((select count(*)::int from public.group_members where group_id = pg_temp.g(2)), 4, 'platform staff see every member');

-- The setting is the person's own simple write.
select pg_temp.act(pg_temp.u(3)::text);
update public.profiles set groups_public = true where id = pg_temp.u(3);
select pg_temp.act(pg_temp.u(4)::text);
update public.profiles set groups_public = true where id = pg_temp.u(1);
select pg_temp.act(pg_temp.u(1)::text);
select is((select count(*)::int from public.group_members where user_id = pg_temp.u(3)), 2, 'public groups show every membership');
reset role;
select is((select groups_public from public.profiles where id = pg_temp.u(1)), false, 'nobody else changes the setting');

set local role anon;
select is((select count(*)::int from public.group_members where group_id = pg_temp.g(2)), 4, 'visitors see the team and public members (b3 is public now)');
reset role;

-- Invitation limit --------------------------------------------------------------------------------
insert into public.audit_log (actor_id, actor_kind, action, target_type, target_id, group_id)
select pg_temp.u(1), 'user', 'group.invitation_sent', 'user', gen_random_uuid()::text, pg_temp.g(1)
from generate_series(1, 49);
insert into public.audit_log (actor_id, actor_kind, action, target_type, target_id, group_id, occurred_at)
select pg_temp.u(1), 'user', 'group.invitation_sent', 'user', gen_random_uuid()::text, pg_temp.g(1), now() - interval '25 hours'
from generate_series(1, 10);

select pg_temp.act(pg_temp.u(1)::text);
select lives_ok(
  $$ insert into public.group_invitations (group_id, user_id) values (pg_temp.g(1), pg_temp.u(4)) $$,
  'the 50th invitation of the day goes out (older ones do not count)');
insert into public.audit_log (actor_id, actor_kind, action, target_type, target_id, group_id)
values (pg_temp.u(1), 'user', 'group.invitation_sent', 'user', pg_temp.u(4)::text, pg_temp.g(1));
select throws_ok(
  $$ insert into public.group_invitations (group_id, user_id) values (pg_temp.g(1), pg_temp.u(5)) $$,
  'P0001', 'invitation_limit_reached', 'a group sends at most 50 invitations a day');
reset role;
set local role anon;
select throws_ok(
  $$ select private.group_invitations_sent_today('00000000-0000-0000-0000-000000470001') $$,
  '42501', null, 'visitors cannot count invitations');
reset role;

-- Same-day events -------------------------------------------------------------------------------
-- g3: same province, another category; g4: no province; g5: same kind, the next day.
select pg_temp.act(pg_temp.u(4)::text);
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id, province)
values (pg_temp.g(3), 'denge.uc', 'Denge Üç', 'running', 'open', pg_temp.u(4), 34),
       (pg_temp.g(4), 'denge.dort', 'Denge Dört', 'hiking', 'open', pg_temp.u(4), null);
insert into public.group_members (group_id, user_id) values (pg_temp.g(3), pg_temp.u(4)), (pg_temp.g(4), pg_temp.u(4));
insert into public.events (group_id, created_by, title, starts_at, location) values
  (pg_temp.g(3), pg_temp.u(4), 'Koşu', now() + interval '24 hours', 'Moda'),
  (pg_temp.g(4), pg_temp.u(4), 'İlsiz yürüyüş', now() + interval '24 hours', 'Moda');
select pg_temp.act(pg_temp.u(5)::text);
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id, province)
values (pg_temp.g(5), 'denge.bes', 'Denge Beş', 'hiking', 'open', pg_temp.u(5), 34);
insert into public.group_members (group_id, user_id) values (pg_temp.g(5), pg_temp.u(5));
insert into public.events (group_id, created_by, title, starts_at, location) values
  (pg_temp.g(5), pg_temp.u(5), 'Ertesi gün', now() + interval '50 hours', 'Belgrad');
select pg_temp.act(pg_temp.u(2)::text);
insert into public.events (id, group_id, created_by, title, starts_at, location) values
  ('00000000-0000-0000-0000-0000004700e1', pg_temp.g(2), pg_temp.u(2), 'Rakip yürüyüş', now() + interval '24 hours', 'Belgrad'),
  ('00000000-0000-0000-0000-0000004700e2', pg_temp.g(2), pg_temp.u(2), 'İptal yürüyüş', now() + interval '25 hours', 'Belgrad');
update public.events set canceled_at = now(), cancel_reason = 'Hava kötü' where id = '00000000-0000-0000-0000-0000004700e2';
select pg_temp.act(pg_temp.u(1)::text);
insert into public.events (group_id, created_by, title, starts_at, location) values
  (pg_temp.g(1), pg_temp.u(1), 'Kendi yürüyüşüm', now() + interval '24 hours', 'Polonezköy');

set local role authenticated;
select is(public.similar_events_count(pg_temp.g(1), now() + interval '12 hours', now() + interval '36 hours'), 1,
  'only other groups'' live events of the same province and category that day count');
select is(public.similar_events_count(pg_temp.g(4), now() + interval '12 hours', now() + interval '36 hours'), null,
  'a group without a province gets no number');
select is(public.similar_events_count(pg_temp.g(1), now(), now() + interval '30 days'), null,
  'the window is at most two days');
reset role;
set local role anon;
select throws_ok(
  $$ select public.similar_events_count('00000000-0000-0000-0000-000000470001', now(), now() + interval '1 day') $$,
  '42501', null, 'visitors cannot ask');
reset role;

select * from finish();
rollback;
