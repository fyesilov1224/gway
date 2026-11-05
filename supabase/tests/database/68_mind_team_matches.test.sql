begin;
create extension if not exists pgtap with schema extensions;

select plan(14);

-- o1 owns group A (m1 a member with a duel rating); o2 owns group B; x is an outsider.
insert into auth.users (id, email, aud, role)
select ('00000000-0000-0000-0000-00000000d5e' || s)::uuid, 'mteam-' || s || '@test.local', 'authenticated', 'authenticated'
from unnest(array['1', '2', '3', '4']) s;
insert into public.profiles (id, username, display_name)
select ('00000000-0000-0000-0000-00000000d5e' || s)::uuid, 'mteam_user_' || s, 'Düello ' || s
from unnest(array['1', '2', '3', '4']) s;

create function pg_temp.act(uid uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;
create function pg_temp.u(s text) returns uuid language sql as $$ select ('00000000-0000-0000-0000-00000000d5e' || s)::uuid $$;
create function pg_temp.ga() returns uuid language sql as $$ select '00000000-0000-0000-0000-00000000d5a1'::uuid $$;
create function pg_temp.gb() returns uuid language sql as $$ select '00000000-0000-0000-0000-00000000d5b1'::uuid $$;

select pg_temp.act(pg_temp.u('1'));
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id)
values (pg_temp.ga(), 'mteam.a.test', 'Düello A', 'chess', 'open', pg_temp.u('1'));
insert into public.group_members (group_id, user_id) values (pg_temp.ga(), pg_temp.u('1'));
select pg_temp.act(pg_temp.u('2'));
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id)
values (pg_temp.gb(), 'mteam.b.test', 'Düello B', 'chess', 'open', pg_temp.u('2'));
insert into public.group_members (group_id, user_id) values (pg_temp.gb(), pg_temp.u('2'));
select pg_temp.act(pg_temp.u('3'));
insert into public.group_members (group_id, user_id) values (pg_temp.ga(), pg_temp.u('3'));
reset role;

-- The API's writes: a duel match of A against B, a chess match between them too, and group ratings per game.
insert into public.chess_team_matches (id, home_group_id, away_group_id, boards, game, length, starts_at, created_by)
values ('00000000-0000-0000-0000-00000000d5c1', pg_temp.ga(), pg_temp.gb(), 2, 'mind', 10, now() + interval '1 hour', pg_temp.u('1'));
insert into public.chess_team_matches (home_group_id, away_group_id, boards, category, base_seconds, increment_seconds, starts_at, created_by)
values (pg_temp.gb(), pg_temp.ga(), 2, 'blitz', 180, 2, now() + interval '1 hour', pg_temp.u('2'));
insert into public.chess_group_ratings (group_id, game, rating, matches, wins)
values (pg_temp.ga(), 'mind', 1260, 1, 1), (pg_temp.gb(), 'mind', 1140, 1, 0), (pg_temp.gb(), 'chess', 1300, 2, 2);
insert into public.mind_ratings (user_id, length, rating, games) values (pg_temp.u('3'), 10, 1450, 8);

select is((select count(*)::int from public.notifications where type = 'mind_team_invite' and recipient_id = pg_temp.u('2')
           and group_id = pg_temp.ga()), 1, 'a duel invitation has its own notice');
select is((select count(*)::int from public.notifications where type = 'chess_team_invite' and recipient_id = pg_temp.u('1')), 1,
  'and a chess one keeps the chess notice');

-- Format: a duel match has a question count and no time control, chess the other way round.
select throws_ok(
  $$insert into public.chess_team_matches (home_group_id, away_group_id, boards, game, length, category, base_seconds, increment_seconds, starts_at)
    values ('00000000-0000-0000-0000-00000000d5a1', '00000000-0000-0000-0000-00000000d5b1', 2, 'mind', 10, 'blitz', 180, 2, now())$$,
  '23514', null, 'a duel match has no time control');
select throws_ok(
  $$insert into public.chess_team_matches (home_group_id, away_group_id, boards, game, length, starts_at)
    values ('00000000-0000-0000-0000-00000000d5a1', '00000000-0000-0000-0000-00000000d5b1', 2, 'mind', 7, now())$$,
  '23514', null, 'only 5, 10, 20 or 50 questions');
select throws_ok(
  $$insert into public.chess_team_matches (home_group_id, away_group_id, boards, game, starts_at)
    values ('00000000-0000-0000-0000-00000000d5a1', '00000000-0000-0000-0000-00000000d5b1', 2, 'chess', now())$$,
  '23514', null, 'a chess match still needs its time control');
select throws_ok(
  $$insert into public.chess_team_matches (home_group_id, away_group_id, boards, game, length, starts_at)
    values ('00000000-0000-0000-0000-00000000d5b1', '00000000-0000-0000-0000-00000000d5a1', 2, 'mind', 5, now() + interval '2 hours')$$,
  '23505', null, 'one open duel match between two groups');
select throws_ok(
  $$insert into public.chess_group_ratings (group_id, game) values ('00000000-0000-0000-0000-00000000d5a1', 'mind')$$,
  '23505', null, 'one rating per group and game');

-- Reads.
select pg_temp.act(pg_temp.u('4'));
set local role authenticated;
select results_eq($$select name, rank from public.chess_group_leaderboard(target_game => 'mind')$$,
  $$values ('Düello A', 1::bigint), ('Düello B', 2::bigint)$$, 'the duel group leaderboard ranks by the duel Elo');
select results_eq($$select name, rating from public.chess_group_leaderboard()$$,
  $$values ('Düello B', 1300)$$, 'the chess one keeps its own Elo and is the default');
select is_empty($$select * from public.chess_team_candidates('00000000-0000-0000-0000-00000000d5c1', '00000000-0000-0000-0000-00000000d5a1')$$,
  'only a captain sees the candidates');
select throws_ok($$update public.chess_group_ratings set rating = 3000$$, '42501', null, 'clients cannot change group Elo');
reset role;
select pg_temp.act(pg_temp.u('1'));
set local role authenticated;
select results_eq(
  $$select username, rating, games from public.chess_team_candidates('00000000-0000-0000-0000-00000000d5c1', '00000000-0000-0000-0000-00000000d5a1')$$,
  $$values ('mteam_user_3', 1450, 8), ('mteam_user_1', 1200, 0)$$, 'candidates carry their rating at the match''s question count');
reset role;

-- A duel can sit on a team seat and be lost by not coming.
select lives_ok(
  $$insert into public.mind_matches (a_id, b_id, length, rated, source, a_rating, b_rating, starts_at, deadline_at, team_match_id,
                                     status, result, termination, ended_at)
    values ('00000000-0000-0000-0000-00000000d5e1', '00000000-0000-0000-0000-00000000d5e2', 10, true, 'team_match', 1200, 1200, now(),
            now() + interval '10 minutes', '00000000-0000-0000-0000-00000000d5c1', 'finished', 'a', 'no_show', now())$$,
  'a team seat duel ends with no_show');
select ok(exists (select 1 from public.group_permissions where slug = 'games.team_match' and description like '%grup düellosu%'),
  'the captain permission covers duels');

select * from finish();
rollback;
