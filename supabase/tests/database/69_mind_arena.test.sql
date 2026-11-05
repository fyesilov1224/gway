begin;
create extension if not exists pgtap with schema extensions;

select plan(10);

insert into auth.users (id, email, aud, role)
select ('00000000-0000-0000-0000-00000000d6e' || s)::uuid, 'marena-' || s || '@test.local', 'authenticated', 'authenticated'
from unnest(array['1', '2']) s;
insert into public.profiles (id, username, display_name)
select ('00000000-0000-0000-0000-00000000d6e' || s)::uuid, 'marena_user_' || s, 'Turnuva ' || s
from unnest(array['1', '2']) s;

create function pg_temp.act(uid uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;
create function pg_temp.u(s text) returns uuid language sql as $$ select ('00000000-0000-0000-0000-00000000d6e' || s)::uuid $$;

-- The API's writes: a finished duel arena won by u1 and a finished chess arena where u1 came second.
insert into public.chess_tournaments (id, game, kind, title, length, starts_at, ends_at, status)
values ('00000000-0000-0000-0000-00000000d6a1', 'mind', 'custom', 'Düello Kupası', 10, now() - interval '2 hours', now() - interval '1 hour', 'live');
insert into public.chess_tournaments (id, kind, title, category, base_seconds, increment_seconds, starts_at, ends_at, status)
values ('00000000-0000-0000-0000-00000000d6a2', 'custom', 'Satranç Kupası', 'blitz', 180, 2, now() - interval '2 hours', now() - interval '1 hour', 'live');
insert into public.chess_tournament_players (tournament_id, user_id, points, games, wins, final_rank)
values ('00000000-0000-0000-0000-00000000d6a1', pg_temp.u('1'), 4, 2, 2, 1), ('00000000-0000-0000-0000-00000000d6a1', pg_temp.u('2'), 0, 2, 0, 2),
       ('00000000-0000-0000-0000-00000000d6a2', pg_temp.u('1'), 2, 2, 1, 2);
update public.chess_tournaments set status = 'finished', finished_at = now()
where id in ('00000000-0000-0000-0000-00000000d6a1', '00000000-0000-0000-0000-00000000d6a2');

select is((select count(*)::int from public.notifications where recipient_id = pg_temp.u('1') and type = 'mind_arena_medal'), 1,
  'a duel arena medal has its own notice');
select is((select count(*)::int from public.notifications where recipient_id = pg_temp.u('1') and type = 'chess_arena_medal'), 1,
  'and the chess one keeps the chess notice');

select pg_temp.act(pg_temp.u('2'));
set local role authenticated;
select results_eq($$select gold, silver, bronze from public.chess_medals('00000000-0000-0000-0000-00000000d6e1', 'mind')$$,
  $$values (1, 0, 0)$$, 'duel medals count duel arenas only');
select results_eq($$select gold, silver, bronze from public.chess_medals('00000000-0000-0000-0000-00000000d6e1')$$,
  $$values (0, 1, 0)$$, 'chess medals stay the default');
select is((select playing from public.chess_tournament_standings('00000000-0000-0000-0000-00000000d6a1') where username = 'marena_user_1'), false,
  'standings read for duel arenas too');
reset role;

-- Format: a duel arena has a question count and no time control.
select throws_ok(
  $$insert into public.chess_tournaments (game, kind, title, length, category, base_seconds, increment_seconds, starts_at, ends_at)
    values ('mind', 'custom', 'Karışık', 10, 'blitz', 180, 2, now(), now() + interval '1 hour')$$,
  '23514', null, 'a duel arena has no time control');
select throws_ok(
  $$insert into public.chess_tournaments (game, kind, title, length, starts_at, ends_at)
    values ('mind', 'custom', 'Yedili', 7, now(), now() + interval '1 hour')$$,
  '23514', null, 'only 5, 10, 20 or 50 questions');

-- The schedule: duel arenas on Saturdays, chess on Sundays, idempotent.
select ok(private.chess_schedule_tournaments('2026-11-01 12:00+03') >= 0, 'scheduling runs');
select is((select count(*)::int from public.chess_tournaments
           where game = 'mind' and kind = 'weekly' and starts_at > '2026-11-01 12:00+03'
             and (extract(isodow from starts_at at time zone 'Europe/Istanbul') <> 6 or length <> 10
                  or extract(hour from starts_at at time zone 'Europe/Istanbul') <> 21)), 0,
  'weekly duel arenas are Saturday 21:00 with 10 questions');
select is((select count(*)::int from public.chess_tournaments
           where game = 'mind' and kind = 'monthly' and starts_at = '2026-11-28 19:00+03' and length = 20), 1,
  'the monthly duel arena is the last Saturday at 19:00 with 20 questions');

select * from finish();
rollback;
