begin;
create extension if not exists pgtap with schema extensions;

select plan(14);

insert into auth.users (id, email, aud, role)
select ('00000000-0000-0000-0000-0000000c6e0' || s)::uuid, 'arena-' || s || '@test.local', 'authenticated', 'authenticated'
from unnest(array['1', '2', '3', '4']) s;
insert into public.profiles (id, username, display_name)
select ('00000000-0000-0000-0000-0000000c6e0' || s)::uuid, 'arena_user_' || s, 'Arena ' || s
from unnest(array['1', '2', '3', '4']) s;

create function pg_temp.act(uid uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;
create function pg_temp.u(s text) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000000c6e0' || s)::uuid $$;
create function pg_temp.t() returns uuid language sql as $$ select '00000000-0000-0000-0000-0000000c6ef1'::uuid $$;

-- The API's writes: a live arena with three players; u1 leads on performance over u2 at equal points.
insert into public.chess_tournaments (id, kind, title, category, base_seconds, increment_seconds, starts_at, ends_at, status)
values (pg_temp.t(), 'custom', 'Test Arenası', 'blitz', 180, 2, now() - interval '10 minutes', now() + interval '50 minutes', 'scheduled');
insert into public.chess_tournament_players (tournament_id, user_id, points, games, wins, losses, opponent_rating_sum)
values (pg_temp.t(), pg_temp.u('1'), 4, 2, 2, 0, 2800), (pg_temp.t(), pg_temp.u('2'), 4, 3, 2, 1, 3300), (pg_temp.t(), pg_temp.u('3'), 0, 1, 0, 1, 1200);

select ok((select bool_and(relrowsecurity) from pg_class
           where oid in ('public.chess_tournaments'::regclass, 'public.chess_tournament_players'::regclass)), 'RLS is on for arenas');

update public.chess_tournaments set status = 'live' where id = pg_temp.t();
select is((select count(*)::int from public.notifications where type = 'chess_arena_start'
           and recipient_id in (pg_temp.u('1'), pg_temp.u('2'), pg_temp.u('3'))), 3, 'the start tells everyone who joined');

set local role anon;
select throws_ok('select count(*) from public.chess_tournaments', '42501', null, 'anon cannot read arenas');
reset role;

select pg_temp.act(pg_temp.u('4'));
set local role authenticated;
select is((select count(*)::int from public.chess_tournaments where id = '00000000-0000-0000-0000-0000000c6ef1'), 1, 'arenas are public to signed-in people');
select throws_ok($$update public.chess_tournaments set status = 'finished'$$, '42501', null, 'clients cannot change an arena');
select throws_ok(
  $$insert into public.chess_tournament_players (tournament_id, user_id) values ('00000000-0000-0000-0000-0000000c6ef1', '00000000-0000-0000-0000-0000000c6e04')$$,
  '42501', null, 'joining goes through the API');
select throws_ok($$update public.chess_tournament_players set points = 99$$, '42501', null, 'clients cannot change points');
select throws_ok($$select private.chess_schedule_tournaments()$$, '42501', null, 'only the API keeps the schedule');
select results_eq($$select username, rank, performance from public.chess_tournament_standings('00000000-0000-0000-0000-0000000c6ef1')$$,
  $$values ('arena_user_1', 1::bigint, 1800), ('arena_user_2', 2::bigint, 1233), ('arena_user_3', 3::bigint, 800)$$,
  'points first, then performance');
reset role;

-- The end: places 1–3 are medals and are told.
update public.chess_tournament_players set final_rank = case user_id when pg_temp.u('1') then 1 when pg_temp.u('2') then 2 else 3 end
where tournament_id = pg_temp.t();
update public.chess_tournaments set status = 'finished', finished_at = now() where id = pg_temp.t();
select is((select count(*)::int from public.notifications where type = 'chess_arena_medal'
           and recipient_id in (pg_temp.u('1'), pg_temp.u('2'), pg_temp.u('3'))), 3, 'the top three are told');

select pg_temp.act(pg_temp.u('4'));
set local role authenticated;
select results_eq($$select gold, silver, bronze from public.chess_medals('00000000-0000-0000-0000-0000000c6e01')$$,
  $$values (1, 0, 0)$$, 'a winner has a gold medal');
select results_eq($$select gold, silver, bronze from public.chess_medals('00000000-0000-0000-0000-0000000c6e04')$$,
  $$values (0, 0, 0)$$, 'someone who did not play has none');
reset role;

select is(private.chess_schedule_tournaments('2026-11-01 12:00+03') >= 0, true, 'scheduling runs');
select is(private.chess_schedule_tournaments('2026-11-01 12:00+03'), 0, 'and running it again adds nothing');

select * from finish();
rollback;
