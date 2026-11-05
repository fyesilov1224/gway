begin;
create extension if not exists pgtap with schema extensions;

select plan(18);

-- o1 owns group A (y1 is its Yönetici, m1 a member); o2 owns group B; x is an outsider.
insert into auth.users (id, email, aud, role)
select ('00000000-0000-0000-0000-0000000c5e0' || s)::uuid, 'team-' || s || '@test.local', 'authenticated', 'authenticated'
from unnest(array['1', '2', '3', '4', '5']) s;
insert into public.profiles (id, username, display_name)
select ('00000000-0000-0000-0000-0000000c5e0' || s)::uuid, 'team_user_' || s, 'Takım ' || s
from unnest(array['1', '2', '3', '4', '5']) s;

create function pg_temp.act(uid uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;
create function pg_temp.u(s text) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000000c5e0' || s)::uuid $$;
create function pg_temp.ga() returns uuid language sql as $$ select '00000000-0000-0000-0000-0000000c5ea1'::uuid $$;
create function pg_temp.gb() returns uuid language sql as $$ select '00000000-0000-0000-0000-0000000c5eb1'::uuid $$;

-- u1 owner of A, u3 Yönetici of A, u4 member of A, u2 owner of B, u5 outsider.
select pg_temp.act(pg_temp.u('1'));
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id)
values (pg_temp.ga(), 'team.a.test', 'Takım A', 'chess', 'open', pg_temp.u('1'));
insert into public.group_members (group_id, user_id) values (pg_temp.ga(), pg_temp.u('1'));
select pg_temp.act(pg_temp.u('2'));
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id)
values (pg_temp.gb(), 'team.b.test', 'Takım B', 'chess', 'open', pg_temp.u('2'));
insert into public.group_members (group_id, user_id) values (pg_temp.gb(), pg_temp.u('2'));
select pg_temp.act(pg_temp.u('3'));
insert into public.group_members (group_id, user_id) values (pg_temp.ga(), pg_temp.u('3'));
select pg_temp.act(pg_temp.u('4'));
insert into public.group_members (group_id, user_id) values (pg_temp.ga(), pg_temp.u('4'));
reset role;
select pg_temp.act(pg_temp.u('1'));
insert into public.group_member_roles (group_id, user_id, role) values (pg_temp.ga(), pg_temp.u('3'), 'admin');

-- The API's writes.
insert into public.chess_team_matches (id, home_group_id, away_group_id, boards, category, base_seconds, increment_seconds, starts_at, created_by)
values ('00000000-0000-0000-0000-0000000c5ec1', pg_temp.ga(), pg_temp.gb(), 2, 'blitz', 180, 2, now() + interval '1 hour', pg_temp.u('1'));
insert into public.chess_group_ratings (group_id, rating, matches, wins) values (pg_temp.ga(), 1250, 1, 1), (pg_temp.gb(), 1150, 1, 0);

select ok((select bool_and(relrowsecurity) from pg_class
           where oid in ('public.chess_group_ratings'::regclass, 'public.chess_team_matches'::regclass,
                         'public.chess_team_lineups'::regclass, 'public.chess_team_boards'::regclass)), 'RLS is on for every team table');
select ok(exists (select 1 from public.group_role_permissions where role = 'admin' and permission = 'games.team_match'),
  'Yöneticiler may arrange team matches');
select ok(private.user_has_group_permission(pg_temp.u('3'), pg_temp.ga(), 'games.team_match'), 'the Yönetici of A is a captain');
select ok(not private.user_has_group_permission(pg_temp.u('4'), pg_temp.ga(), 'games.team_match'), 'a plain member is not');

select is((select count(*)::int from public.notifications where type = 'chess_team_invite' and recipient_id = pg_temp.u('2')
           and group_id = pg_temp.ga()), 1, 'the invited group''s owner is told, naming the inviting group');
select is((select count(*)::int from public.notifications where type = 'chess_team_invite' and recipient_id <> pg_temp.u('2')), 0,
  'nobody else is');

set local role anon;
select throws_ok('select count(*) from public.chess_team_matches', '42501', null, 'anon cannot read matches');
select throws_ok('select * from public.chess_group_leaderboard()', '42501', null, 'anon cannot read the group leaderboard');
reset role;

select pg_temp.act(pg_temp.u('5'));
set local role authenticated;
select is((select count(*)::int from public.chess_team_matches where id = '00000000-0000-0000-0000-0000000c5ec1'), 1,
  'matches between visible groups are public to signed-in people');
select throws_ok($$update public.chess_team_matches set status = 'accepted'$$, '42501', null, 'clients cannot answer for a group');
select throws_ok(
  $$insert into public.chess_team_lineups (match_id, group_id, board, user_id)
    values ('00000000-0000-0000-0000-0000000c5ec1', '00000000-0000-0000-0000-0000000c5ea1', 1, '00000000-0000-0000-0000-0000000c5e05')$$,
  '42501', null, 'clients cannot line up');
select throws_ok($$update public.chess_group_ratings set rating = 3000$$, '42501', null, 'clients cannot change group Elo');
select is_empty($$select * from public.chess_captain_groups()$$, 'an outsider captains nothing');
select is_empty($$select * from public.chess_team_candidates('00000000-0000-0000-0000-0000000c5ec1', '00000000-0000-0000-0000-0000000c5ea1')$$,
  'and sees no candidates for a side');
select results_eq($$select name, rank from public.chess_group_leaderboard() where group_id in
                    ('00000000-0000-0000-0000-0000000c5ea1', '00000000-0000-0000-0000-0000000c5eb1') order by rank$$,
  $$values ('Takım A', 1::bigint), ('Takım B', 2::bigint)$$, 'groups are ranked by Elo');
reset role;

select pg_temp.act(pg_temp.u('3'));
set local role authenticated;
select results_eq($$select name from public.chess_captain_groups() where group_id = '00000000-0000-0000-0000-0000000c5ea1'$$,
  $$values ('Takım A')$$, 'the Yönetici captains A');
select is((select count(*)::int from public.chess_team_candidates('00000000-0000-0000-0000-0000000c5ec1', '00000000-0000-0000-0000-0000000c5ea1')), 3,
  'and sees A''s members as candidates');
select is_empty($$select * from public.chess_team_candidates('00000000-0000-0000-0000-0000000c5ec1', '00000000-0000-0000-0000-0000000c5eb1')$$,
  'but not B''s');
reset role;

select * from finish();
rollback;
