begin;
create extension if not exists pgtap with schema extensions;

select plan(26);

-- a and b dueled; c is an outsider; d is a suspended account; e is suspended from games only.
insert into auth.users (id, email, aud, role)
select ('00000000-0000-0000-0000-00000000d1e' || s)::uuid, 'mind-' || s || '@test.local', 'authenticated', 'authenticated'
from unnest(array['a', 'b', 'c', 'd', 'e']) s;
insert into public.profiles (id, username, display_name)
select ('00000000-0000-0000-0000-00000000d1e' || s)::uuid, 'mind_user_' || s, 'Zihin ' || s
from unnest(array['a', 'b', 'c', 'd', 'e']) s;
update public.account_status set status = 'suspended', suspended_until = null
where user_id = '00000000-0000-0000-0000-00000000d1ed';

create function pg_temp.act(uid uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;
create function pg_temp.u(s text) returns uuid language sql as $$ select ('00000000-0000-0000-0000-00000000d1e' || s)::uuid $$;

-- Fixtures as the API would write them.
insert into public.mind_matches (id, a_id, b_id, length, rated, source, a_rating, b_rating, starts_at, deadline_at)
values ('00000000-0000-0000-0000-00000000d191', pg_temp.u('a'), pg_temp.u('b'), 5, true, 'seek', 1200, 1200, now(), now() + interval '2 minutes'),
       ('00000000-0000-0000-0000-00000000d192', pg_temp.u('a'), pg_temp.u('d'), 5, true, 'seek', 1200, 1200, now(), now() + interval '2 minutes');
insert into public.mind_questions (match_id, idx, kind, level, payload, solution, limit_ms)
values ('00000000-0000-0000-0000-00000000d191', 0, 'math', 1, '{"expression": "4 + 5", "choices": [9, 8, 10, 11]}', '{"choice": 0}', 11000);
insert into public.mind_answers (match_id, user_id, idx) values ('00000000-0000-0000-0000-00000000d191', pg_temp.u('a'), 0);
insert into public.mind_seeks (user_id, length, rating) values (pg_temp.u('a'), 10, 1200);
insert into public.mind_challenges (id, challenger_id, opponent_id, length, rated)
values ('00000000-0000-0000-0000-00000000d1c1', pg_temp.u('a'), pg_temp.u('b'), 20, true);
insert into public.mind_ratings (user_id, length, rating, games, wins)
select pg_temp.u(s), 10, r, 6, 3
from (values ('a', 1500), ('b', 1300), ('c', 1700), ('d', 1900), ('e', 2000)) v (s, r);
insert into public.mind_ratings (user_id, length, rating, games) values (pg_temp.u('b'), 50, 1600, 4);
insert into public.chess_players (user_id, country, suspended_until, suspension_reason)
values (pg_temp.u('e'), null, 'infinity', 'Hile'), (pg_temp.u('c'), 'NL', null, null);

select ok((select bool_and(relrowsecurity) from pg_class
           where oid in ('public.mind_ratings'::regclass, 'public.mind_matches'::regclass, 'public.mind_questions'::regclass,
                         'public.mind_answers'::regclass, 'public.mind_seeks'::regclass, 'public.mind_challenges'::regclass)),
  'RLS is on for every duel table');

set local role anon;
select throws_ok('select count(*) from public.mind_matches', '42501', null, 'anon cannot read matches');
select throws_ok('select * from public.mind_leaderboard(10)', '42501', null, 'anon cannot read the leaderboard');
reset role;

-- The outsider.
select pg_temp.act(pg_temp.u('c'));
set local role authenticated;
select is((select count(*)::int from public.mind_matches where id = '00000000-0000-0000-0000-00000000d191'), 1,
  'a match between visible people is public to signed-in people');
select is((select count(*)::int from public.mind_matches where id = '00000000-0000-0000-0000-00000000d192'), 0,
  'a match with a hidden account is not shown to others');
select is_empty('select * from public.mind_seeks', 'someone else''s seek is private');
select is_empty('select * from public.mind_challenges', 'someone else''s challenge is private');
select throws_ok($$update public.mind_matches set a_score = 999$$, '42501', null, 'clients cannot write scores');
select throws_ok($$update public.mind_ratings set rating = 3000$$, '42501', null, 'clients cannot change ratings');
select throws_ok($$insert into public.mind_seeks (user_id, length, rating) values ('00000000-0000-0000-0000-00000000d1ec', 5, 1200)$$,
  '42501', null, 'seeks go through the API');
select throws_ok(
  $$insert into public.mind_challenges (challenger_id, opponent_id, length, rated)
    values ('00000000-0000-0000-0000-00000000d1ec', '00000000-0000-0000-0000-00000000d1eb', 5, true)$$,
  '42501', null, 'challenges go through the API');

-- The leaderboard: 5+ matches, not suspended from games, account visible.
select results_eq(
  $$select username, rank from public.mind_leaderboard(10)$$,
  $$values ('mind_user_c', 1::bigint), ('mind_user_a', 2::bigint), ('mind_user_b', 3::bigint)$$,
  'ranked by rating; the hidden account and the suspended player are left out');
select is((select country from public.mind_leaderboard(10) where username = 'mind_user_c'), 'NL', 'the games flag comes along');
select is_empty($$select * from public.mind_leaderboard(50)$$, 'fewer than five rated matches is not ranked yet');
select results_eq($$select length, rank from public.mind_ranks() order by length$$,
  $$values (5, null::bigint), (10, 1::bigint), (20, null::bigint), (50, null::bigint)$$, 'my place at each length');
select results_eq($$select rank from public.mind_ranks('00000000-0000-0000-0000-00000000d1eb') where length = 10$$,
  $$values (3::bigint)$$, 'and someone else''s');
reset role;

-- The players: questions and answers stay with the API even for them.
select pg_temp.act(pg_temp.u('a'));
set local role authenticated;
select throws_ok('select * from public.mind_questions', '42501', null, 'a player cannot read the questions');
select throws_ok('select * from public.mind_answers', '42501', null, 'nor the answers');
select is((select count(*)::int from public.mind_seeks), 1, 'a person sees their own seek');
select is((select count(*)::int from public.mind_matches where pg_temp.u('a') in (a_id, b_id)), 2,
  'a player sees their own matches, also against a hidden account');
reset role;
select pg_temp.act(pg_temp.u('b'));
set local role authenticated;
select is((select count(*)::int from public.mind_challenges), 1, 'the opponent sees the challenge');
reset role;

select is((select count(*)::int from public.notifications where recipient_id = pg_temp.u('b') and type = 'mind_challenge'
           and actor_id = pg_temp.u('a')), 1, 'a challenge notifies the opponent');

-- Constraints the API relies on.
select throws_ok(
  $$insert into public.mind_matches (a_id, b_id, length, rated, source, a_rating, b_rating, starts_at, deadline_at)
    values ('00000000-0000-0000-0000-00000000d1ea', '00000000-0000-0000-0000-00000000d1eb', 7, true, 'seek', 1200, 1200, now(), now() + interval '1 minute')$$,
  '23514', null, 'only 5, 10, 20 or 50 questions');
select throws_ok(
  $$insert into public.mind_challenges (challenger_id, opponent_id, length, rated)
    values ('00000000-0000-0000-0000-00000000d1ea', '00000000-0000-0000-0000-00000000d1eb', 5, true)$$,
  '23505', null, 'one pending challenge per pair');
select throws_ok(
  $$update public.mind_matches set status = 'finished' where id = '00000000-0000-0000-0000-00000000d191'$$,
  '23514', null, 'a finished match needs a result');
select throws_ok(
  $$update public.mind_matches set a_points = '{1,1,1,1,1,1}' where id = '00000000-0000-0000-0000-00000000d191'$$,
  '23514', null, 'no more points than questions');

select * from finish();
rollback;
