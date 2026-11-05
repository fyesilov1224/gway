-- 0087_mind_arena
-- Faz 21c (docs/ARCHITECTURE.md §3j, Turnuvalar): the chess arena becomes an arena of either game. Zihin Düellosu
-- arenas set a question count; the API pairs waiting players into duels. Weekly (Saturday 21:00, 10 questions, 60 min)
-- and monthly (last Saturday 19:00, 20 questions, 120 min) duel arenas join the schedule. Medals count per game.
-- owner: games

-- ---------------------------------------------------------------------------
-- Arenas of either game
-- ---------------------------------------------------------------------------
alter table public.chess_tournaments
  add column game text not null default 'chess' check (game in ('chess', 'mind')),
  add column length int check (length in (5, 10, 20, 50));
alter table public.chess_tournaments
  alter column category drop not null,
  alter column base_seconds drop not null,
  alter column increment_seconds drop not null;
alter table public.chess_tournaments drop constraint chess_tournaments_time_control;
alter table public.chess_tournaments add constraint chess_tournaments_format check (
  (game = 'chess' and length is null and category is not null and (base_seconds, increment_seconds) in
    ((60, 0), (120, 1), (180, 0), (180, 2), (300, 0), (300, 3), (600, 0), (600, 5), (900, 10)))
  or (game = 'mind' and length is not null and category is null and base_seconds is null and increment_seconds is null));

comment on table public.chess_tournaments is
  'owner: games. An arena of chess or Zihin Düellosu (game): scheduled, live between starts_at and ends_at (games started '
  'before the end still count), finished.';

drop index public.chess_tournaments_scheduled_once;
create unique index chess_tournaments_scheduled_once on public.chess_tournaments (game, kind, starts_at) where kind <> 'custom';

-- A duel player's running arena duel.
alter table public.chess_tournament_players add column current_match_id uuid references public.mind_matches (id) on delete set null;

alter table public.mind_matches drop constraint mind_matches_source_check;
alter table public.mind_matches add constraint mind_matches_source_check check (source in ('seek', 'challenge', 'team_match', 'arena'));
alter table public.mind_matches add column tournament_id uuid references public.chess_tournaments (id) on delete set null;
create index mind_matches_tournament_idx on public.mind_matches (tournament_id) where tournament_id is not null;

-- ---------------------------------------------------------------------------
-- Schedule: the chess arenas as before, plus the duel arenas on Saturdays.
-- ---------------------------------------------------------------------------
create or replace function private.chess_schedule_tournaments(as_of timestamptz default now())
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  added int := 0;
  n int;
  today date := (as_of at time zone 'Europe/Istanbul')::date;
begin
  insert into public.chess_tournaments (kind, category, base_seconds, increment_seconds, starts_at, ends_at)
  select 'weekly', 'blitz', 180, 2, s, s + interval '60 minutes'
  from (select ((d::date + time '21:00') at time zone 'Europe/Istanbul') as s
        from generate_series(today, today + 35, interval '1 day') as d
        where extract(isodow from d) = 7) w
  where w.s > as_of
  on conflict (game, kind, starts_at) where kind <> 'custom' do nothing;
  get diagnostics n = row_count;
  added := added + n;

  insert into public.chess_tournaments (kind, category, base_seconds, increment_seconds, starts_at, ends_at)
  select 'monthly', 'blitz', 300, 0, s, s + interval '120 minutes'
  from (select ((last_day - ((extract(isodow from last_day)::int) % 7)) + time '19:00') at time zone 'Europe/Istanbul' as s
        from (select (date_trunc('month', today + make_interval(months => m)) + interval '1 month - 1 day')::date as last_day
              from generate_series(0, 1) as m) months) t
  where t.s > as_of
  on conflict (game, kind, starts_at) where kind <> 'custom' do nothing;
  get diagnostics n = row_count;
  added := added + n;

  insert into public.chess_tournaments (game, kind, length, starts_at, ends_at)
  select 'mind', 'weekly', 10, s, s + interval '60 minutes'
  from (select ((d::date + time '21:00') at time zone 'Europe/Istanbul') as s
        from generate_series(today, today + 35, interval '1 day') as d
        where extract(isodow from d) = 6) w
  where w.s > as_of
  on conflict (game, kind, starts_at) where kind <> 'custom' do nothing;
  get diagnostics n = row_count;
  added := added + n;

  -- The last Saturday: step back from the month's last day to isodow 6.
  insert into public.chess_tournaments (game, kind, length, starts_at, ends_at)
  select 'mind', 'monthly', 20, s, s + interval '120 minutes'
  from (select ((last_day - ((extract(isodow from last_day)::int + 1) % 7)) + time '19:00') at time zone 'Europe/Istanbul' as s
        from (select (date_trunc('month', today + make_interval(months => m)) + interval '1 month - 1 day')::date as last_day
              from generate_series(0, 1) as m) months) t
  where t.s > as_of
  on conflict (game, kind, starts_at) where kind <> 'custom' do nothing;
  get diagnostics n = row_count;
  return added + n;
end;
$$;

-- Medals per game; chess by default.
drop function public.chess_medals(uuid);
create function public.chess_medals(target uuid, target_game text default 'chess')
returns table (gold int, silver int, bronze int)
language sql
stable
security invoker
set search_path = ''
as $$
  select count(*) filter (where tp.final_rank = 1)::int, count(*) filter (where tp.final_rank = 2)::int,
         count(*) filter (where tp.final_rank = 3)::int
  from public.chess_tournament_players tp
  join public.chess_tournaments t on t.id = tp.tournament_id
  where tp.user_id = target and t.status = 'finished' and t.game = target_game;
$$;

revoke all on function public.chess_medals(uuid, text) from public;
grant execute on function public.chess_medals(uuid, text) to authenticated, service_role;

-- Standings say whether a player is in a game or a duel.
create or replace function public.chess_tournament_standings(target uuid)
returns table (rank bigint, user_id uuid, username text, display_name text, avatar_path text, country text, points int, games int,
               wins int, draws int, losses int, streak int, performance int, waiting boolean, playing boolean, final_rank int)
language sql
stable
security invoker
set search_path = ''
as $$
  select rank() over (order by tp.points desc, perf.value desc nulls last), tp.user_id, p.username, p.display_name, p.avatar_path,
         cp.country, tp.points, tp.games, tp.wins, tp.draws, tp.losses, tp.streak, perf.value, tp.waiting,
         tp.current_game_id is not null or tp.current_match_id is not null, tp.final_rank
  from public.chess_tournament_players tp
  join public.profiles p on p.id = tp.user_id
  left join public.chess_players cp on cp.user_id = tp.user_id
  cross join lateral (select case when tp.games > 0
                         then round(tp.opponent_rating_sum::numeric / tp.games + 400.0 * (tp.wins - tp.losses) / tp.games)::int end as value) perf
  where tp.tournament_id = target
  order by 1, p.username
  limit 500;
$$;

-- ---------------------------------------------------------------------------
-- Notifications (notifications owns the table)
-- ---------------------------------------------------------------------------
alter table public.notifications drop constraint notifications_type_check;
alter table public.notifications add constraint notifications_type_check
  check (type in ('like', 'comment', 'reply', 'comment_like', 'mention', 'follow', 'follow_request', 'follow_accepted',
                  'live_scheduled', 'live_started', 'event_promoted', 'event_updated', 'event_canceled', 'event_reminder',
                  'case_vote', 'sanction_applied', 'appeal_submitted', 'appeal_decided',
                  'event_approved', 'event_declined', 'event_review', 'goal_completed',
                  'teammate_request', 'teammate_accepted', 'match_created', 'match_super_liked',
                  'welcome_requested', 'welcome_matched', 'welcome_released', 'welcome_withdrawn', 'welcome_thanked',
                  'league_result', 'event_series_limit', 'tonight_table_invite', 'tonight_table_ready',
                  'event_venue_revealed', 'handshake', 'message',
                  'call_incoming', 'call_missed', 'call_ended',
                  'call_permission_granted', 'call_permission_declined', 'call_permission_revoked',
                  'chess_challenge', 'chess_team_invite', 'chess_team_accepted', 'chess_team_declined', 'chess_team_start',
                  'chess_arena_start', 'chess_arena_medal',
                  'mind_challenge', 'mind_team_invite', 'mind_team_accepted', 'mind_team_declined', 'mind_team_start',
                  'mind_arena_start', 'mind_arena_medal'));

create or replace function private.notify_chess_arena()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  prefix text := case new.game when 'mind' then 'mind_' else 'chess_' end;
begin
  if old.status = 'scheduled' and new.status = 'live' then
    insert into public.notifications (recipient_id, actor_id, type)
    select tp.user_id, tp.user_id, prefix || 'arena_start'
    from public.chess_tournament_players tp
    where tp.tournament_id = new.id and private.wants_notification(tp.user_id, prefix || 'arena_start');
  elsif old.status = 'live' and new.status = 'finished' then
    insert into public.notifications (recipient_id, actor_id, type)
    select tp.user_id, tp.user_id, prefix || 'arena_medal'
    from public.chess_tournament_players tp
    where tp.tournament_id = new.id and tp.final_rank <= 3;
  end if;
  return null;
end;
$$;
