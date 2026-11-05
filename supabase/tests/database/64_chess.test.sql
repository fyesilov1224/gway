begin;
create extension if not exists pgtap with schema extensions;

select plan(33);

-- a and b played a game; c is an outsider; d is a suspended account; e is suspended from chess only.
insert into auth.users (id, email, aud, role)
select ('00000000-0000-0000-0000-0000000c4e0' || s)::uuid, 'chess-' || s || '@test.local', 'authenticated', 'authenticated'
from unnest(array['a', 'b', 'c', 'd', 'e']) s;
insert into public.profiles (id, username, display_name)
select ('00000000-0000-0000-0000-0000000c4e0' || s)::uuid, 'chess_user_' || s, 'Satranç ' || s
from unnest(array['a', 'b', 'c', 'd', 'e']) s;
update public.account_status set status = 'suspended', suspended_until = null
where user_id = '00000000-0000-0000-0000-0000000c4e0d';

create function pg_temp.act(uid uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;
create function pg_temp.u(s text) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000000c4e0' || s)::uuid $$;

-- Fixtures as the API would write them (service role bypasses RLS).
insert into public.chess_games (id, white_id, black_id, category, base_seconds, increment_seconds, rated, source,
                                white_ms, black_ms, white_rating, black_rating)
values ('00000000-0000-0000-0000-0000000c4e91', pg_temp.u('a'), pg_temp.u('b'), 'blitz', 180, 2, true, 'seek',
        180000, 180000, 1200, 1200),
       ('00000000-0000-0000-0000-0000000c4e92', pg_temp.u('a'), pg_temp.u('d'), 'blitz', 180, 2, true, 'seek',
        180000, 180000, 1200, 1200);
insert into public.chess_seeks (user_id, category, base_seconds, increment_seconds, rated, rating)
values (pg_temp.u('a'), 'blitz', 300, 0, true, 1200);
insert into public.chess_challenges (id, challenger_id, opponent_id, category, base_seconds, increment_seconds, rated)
values ('00000000-0000-0000-0000-0000000c4ec1', pg_temp.u('a'), pg_temp.u('b'), 'rapid', 600, 0, true);
insert into public.chess_ratings (user_id, category, rating, games, wins)
select pg_temp.u(s), 'blitz', r, 6, 3
from (values ('a', 1500), ('b', 1300), ('c', 1700), ('d', 1900), ('e', 2000)) v (s, r);
insert into public.chess_ratings (user_id, category, rating, games) values (pg_temp.u('b'), 'rapid', 1600, 4);
insert into public.chess_players (user_id, suspended_until, suspension_reason)
values (pg_temp.u('e'), 'infinity', 'Motor kullanımı');

select ok((select bool_and(relrowsecurity) from pg_class
           where oid in ('public.chess_players'::regclass, 'public.chess_ratings'::regclass, 'public.chess_games'::regclass,
                         'public.chess_seeks'::regclass, 'public.chess_challenges'::regclass)), 'RLS is on for every chess table');

-- Anonymous visitors read nothing.
set local role anon;
select throws_ok('select count(*) from public.chess_games', '42501', null, 'anon cannot read games');
select throws_ok('select count(*) from public.chess_ratings', '42501', null, 'anon cannot read ratings');
select throws_ok('select * from public.chess_leaderboard(''blitz'')', '42501', null, 'anon cannot read the leaderboard');
reset role;

-- The outsider.
select pg_temp.act(pg_temp.u('c'));
set local role authenticated;
select is((select count(*)::int from public.chess_games where id = '00000000-0000-0000-0000-0000000c4e91'), 1,
  'a game between visible people is public to signed-in people');
select is((select count(*)::int from public.chess_games where id = '00000000-0000-0000-0000-0000000c4e92'), 0,
  'a game with a hidden account is not shown to others');
select is_empty('select * from public.chess_seeks', 'someone else''s seek is private');
select is_empty('select * from public.chess_challenges', 'someone else''s challenge is private');
select throws_ok(
  $$insert into public.chess_games (white_id, black_id, category, base_seconds, increment_seconds, rated, source, white_ms, black_ms, white_rating, black_rating)
    values ('00000000-0000-0000-0000-0000000c4e0c', '00000000-0000-0000-0000-0000000c4e0b', 'blitz', 180, 2, true, 'seek', 1, 1, 1200, 1200)$$,
  '42501', null, 'clients cannot create games');
select throws_ok($$update public.chess_games set result = 'white'$$, '42501', null, 'clients cannot write results');
select throws_ok($$update public.chess_ratings set rating = 3000$$, '42501', null, 'clients cannot change ratings');
select throws_ok(
  $$insert into public.chess_seeks (user_id, category, base_seconds, increment_seconds, rated, rating)
    values ('00000000-0000-0000-0000-0000000c4e0c', 'blitz', 180, 2, true, 1200)$$,
  '42501', null, 'seeks go through the API');
select throws_ok(
  $$insert into public.chess_challenges (challenger_id, opponent_id, category, base_seconds, increment_seconds, rated)
    values ('00000000-0000-0000-0000-0000000c4e0c', '00000000-0000-0000-0000-0000000c4e0b', 'blitz', 180, 2, true)$$,
  '42501', null, 'challenges go through the API');

-- Flag: one's own row only, and only the country.
select lives_ok($$insert into public.chess_players (user_id, country) values ('00000000-0000-0000-0000-0000000c4e0c', 'TR')$$,
  'a person sets their own flag');
select lives_ok($$insert into public.chess_players (user_id, country) values ('00000000-0000-0000-0000-0000000c4e0c', 'DE')
                  on conflict (user_id) do update set user_id = excluded.user_id, country = excluded.country$$,
  'and changes it with the upsert the app sends');
select throws_ok($$update public.chess_players set user_id = '00000000-0000-0000-0000-0000000c4e0b'
                   where user_id = '00000000-0000-0000-0000-0000000c4e0c'$$,
  '42501', null, 'a row cannot be handed to someone else');
select throws_ok($$insert into public.chess_players (user_id, country) values ('00000000-0000-0000-0000-0000000c4e0b', 'TR')$$,
  '42501', null, 'not someone else''s');
select throws_ok($$update public.chess_players set suspended_until = null$$, '42501', null, 'nobody lifts their own suspension');
select throws_ok($$select suspension_reason from public.chess_players$$, '42501', null, 'the suspension reason is not readable');
select throws_ok($$insert into public.chess_players (user_id, country) values ('00000000-0000-0000-0000-0000000c4e0c', 'tr')$$,
  '23514', null, 'the country is a two-letter upper-case code');

-- The leaderboard: 5+ games, not suspended from chess, account visible.
select results_eq(
  $$select username, rank from public.chess_leaderboard('blitz')$$,
  $$values ('chess_user_c', 1::bigint), ('chess_user_a', 2::bigint), ('chess_user_b', 3::bigint)$$,
  'ranked by rating; the hidden account and the suspended player are left out');
select is((select country from public.chess_leaderboard('blitz') where username = 'chess_user_c'), 'DE', 'the flag comes along');
select is_empty($$select * from public.chess_leaderboard('rapid')$$, 'fewer than five rated games is not ranked yet');
select results_eq($$select category, rank from public.chess_ranks() order by category$$,
  $$values ('blitz', 1::bigint), ('bullet', null::bigint), ('rapid', null::bigint)$$, 'my place in each category');
select results_eq($$select rank from public.chess_ranks('00000000-0000-0000-0000-0000000c4e0b') where category = 'blitz'$$,
  $$values (3::bigint)$$, 'and someone else''s');
reset role;

-- The players.
select pg_temp.act(pg_temp.u('b'));
set local role authenticated;
select is((select count(*)::int from public.chess_challenges), 1, 'the opponent sees the challenge');
select is_empty('select * from public.chess_seeks', 'but not the challenger''s seek');
reset role;
select pg_temp.act(pg_temp.u('a'));
set local role authenticated;
select is((select count(*)::int from public.chess_seeks), 1, 'a person sees their own seek');
select is((select count(*)::int from public.chess_games where pg_temp.u('a') in (white_id, black_id)), 2,
  'a player sees their own games, also against a hidden account');
reset role;

-- The invitation rings the opponent.
select is((select count(*)::int from public.notifications where recipient_id = pg_temp.u('b') and type = 'chess_challenge'
           and actor_id = pg_temp.u('a')), 1, 'a challenge notifies the opponent');

-- Constraints the API relies on.
select throws_ok(
  $$insert into public.chess_games (white_id, black_id, category, base_seconds, increment_seconds, rated, source, white_ms, black_ms, white_rating, black_rating)
    values ('00000000-0000-0000-0000-0000000c4e0a', '00000000-0000-0000-0000-0000000c4e0b', 'blitz', 240, 0, true, 'seek', 1, 1, 1200, 1200)$$,
  '23514', null, 'only catalog time controls');
select throws_ok(
  $$insert into public.chess_challenges (challenger_id, opponent_id, category, base_seconds, increment_seconds, rated)
    values ('00000000-0000-0000-0000-0000000c4e0a', '00000000-0000-0000-0000-0000000c4e0b', 'blitz', 180, 2, true)$$,
  '23505', null, 'one pending challenge per pair');
select throws_ok(
  $$update public.chess_games set status = 'finished' where id = '00000000-0000-0000-0000-0000000c4e91'$$,
  '23514', null, 'a finished game needs a result');

select * from finish();
rollback;
