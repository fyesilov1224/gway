-- 0084_chess_arena
-- Faz 20c (docs/ARCHITECTURE.md §3i, Arena turnuvaları): weekly and monthly arenas scheduled by the database,
-- extra ones opened by the platform team. Players join, the API pairs whoever is waiting, every finished game adds
-- points (2 / 1 / 0, doubled on a streak of two wins). The API (C#) is the only writer.
-- owner: games

create table public.chess_tournaments (
  id                uuid primary key default gen_random_uuid(),
  kind              text not null check (kind in ('weekly', 'monthly', 'custom')),
  -- Custom arenas have a title; weekly and monthly ones are named by the app in the reader's language.
  title             text check (title is null or char_length(btrim(title)) between 3 and 80),
  category          text not null check (category in ('bullet', 'blitz', 'rapid')),
  base_seconds      int not null,
  increment_seconds int not null,
  starts_at         timestamptz not null,
  ends_at           timestamptz not null,
  status            text not null default 'scheduled' check (status in ('scheduled', 'live', 'finished', 'canceled')),
  created_by        uuid references public.profiles (id) on delete set null,
  created_at        timestamptz not null default now(),
  finished_at       timestamptz,
  constraint chess_tournaments_window check (ends_at > starts_at and ends_at <= starts_at + interval '6 hours'),
  constraint chess_tournaments_title check ((kind = 'custom') = (title is not null)),
  constraint chess_tournaments_time_control check ((base_seconds, increment_seconds) in
    ((60, 0), (120, 1), (180, 0), (180, 2), (300, 0), (300, 3), (600, 0), (600, 5), (900, 10)))
);

comment on table public.chess_tournaments is
  'owner: games. An arena: scheduled, live between starts_at and ends_at (games started before the end still count), finished.';

create unique index chess_tournaments_scheduled_once on public.chess_tournaments (kind, starts_at) where kind <> 'custom';
create index chess_tournaments_window_idx on public.chess_tournaments (status, starts_at);

create table public.chess_tournament_players (
  tournament_id   uuid not null references public.chess_tournaments (id) on delete cascade,
  user_id         uuid not null references public.profiles (id) on delete cascade,
  points          int not null default 0 check (points >= 0),
  games           int not null default 0,
  wins            int not null default 0,
  draws           int not null default 0,
  losses          int not null default 0,
  -- Wins in a row; from two on the next result scores double (fire).
  streak          int not null default 0,
  opponent_rating_sum bigint not null default 0,
  -- In the pairing pool now; false while paused or before the start.
  waiting         boolean not null default false,
  waiting_since   timestamptz,
  current_game_id uuid references public.chess_games (id) on delete set null,
  last_opponent   uuid references public.profiles (id) on delete set null,
  final_rank      int check (final_rank > 0),
  joined_at       timestamptz not null default now(),
  primary key (tournament_id, user_id)
);

comment on table public.chess_tournament_players is
  'owner: games. A player''s arena score. final_rank is written when the arena finishes; 1–3 are its medals.';

create index chess_tournament_players_pool on public.chess_tournament_players (tournament_id, points desc) where waiting;
create index chess_tournament_players_user on public.chess_tournament_players (user_id, final_rank);

alter table public.chess_games drop constraint chess_games_source_check;
alter table public.chess_games add constraint chess_games_source_check check (source in ('seek', 'challenge', 'team_match', 'arena'));
alter table public.chess_games add column tournament_id uuid references public.chess_tournaments (id) on delete set null;
create index chess_games_tournament_idx on public.chess_games (tournament_id) where tournament_id is not null;

alter table public.chess_tournaments enable row level security;
alter table public.chess_tournament_players enable row level security;
revoke all on public.chess_tournaments, public.chess_tournament_players from anon, authenticated;
grant select on public.chess_tournaments, public.chess_tournament_players to authenticated;

create policy chess_tournaments_select on public.chess_tournaments for select to authenticated using (true);
create policy chess_tournament_players_select on public.chess_tournament_players for select to authenticated
  using (user_id = (select auth.uid()) or private.is_account_visible(user_id) or (select private.is_platform_staff()));

alter publication supabase_realtime add table public.chess_tournaments, public.chess_tournament_players;

-- ---------------------------------------------------------------------------
-- Schedule: every Sunday 21:00 (Turkey) a 60-minute 3+2 weekly arena; the last Sunday of each month 19:00 a
-- 120-minute 5+0 monthly arena. Keeps 35 days ahead; idempotent. Called by the API's monitor.
-- ---------------------------------------------------------------------------
create function private.chess_schedule_tournaments(as_of timestamptz default now())
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  added int;
  monthly int;
  today date := (as_of at time zone 'Europe/Istanbul')::date;
begin
  insert into public.chess_tournaments (kind, category, base_seconds, increment_seconds, starts_at, ends_at)
  select 'weekly', 'blitz', 180, 2, s, s + interval '60 minutes'
  from (select ((d::date + time '21:00') at time zone 'Europe/Istanbul') as s
        from generate_series(today, today + 35, interval '1 day') as d
        where extract(isodow from d) = 7) w
  where w.s > as_of
  on conflict (kind, starts_at) where kind <> 'custom' do nothing;
  get diagnostics added = row_count;

  insert into public.chess_tournaments (kind, category, base_seconds, increment_seconds, starts_at, ends_at)
  select 'monthly', 'blitz', 300, 0, s, s + interval '120 minutes'
  from (select ((last_day - ((extract(isodow from last_day)::int) % 7)) + time '19:00') at time zone 'Europe/Istanbul' as s
        from (select (date_trunc('month', today + make_interval(months => m)) + interval '1 month - 1 day')::date as last_day
              from generate_series(0, 1) as m) months) t
  where t.s > as_of
  on conflict (kind, starts_at) where kind <> 'custom' do nothing;
  get diagnostics monthly = row_count;
  return added + monthly;
end;
$$;

-- Standings: points, then performance (average opponent rating + 400 × (wins − losses) / games).
create function public.chess_tournament_standings(target uuid)
returns table (rank bigint, user_id uuid, username text, display_name text, avatar_path text, country text, points int, games int,
               wins int, draws int, losses int, streak int, performance int, waiting boolean, playing boolean, final_rank int)
language sql
stable
security invoker
set search_path = ''
as $$
  select rank() over (order by tp.points desc, perf.value desc nulls last), tp.user_id, p.username, p.display_name, p.avatar_path,
         cp.country, tp.points, tp.games, tp.wins, tp.draws, tp.losses, tp.streak, perf.value, tp.waiting,
         tp.current_game_id is not null, tp.final_rank
  from public.chess_tournament_players tp
  join public.profiles p on p.id = tp.user_id
  left join public.chess_players cp on cp.user_id = tp.user_id
  cross join lateral (select case when tp.games > 0
                         then round(tp.opponent_rating_sum::numeric / tp.games + 400.0 * (tp.wins - tp.losses) / tp.games)::int end as value) perf
  where tp.tournament_id = target
  order by 1, p.username
  limit 500;
$$;

-- A person's arena medals: places 1, 2 and 3 in finished arenas.
create function public.chess_medals(target uuid)
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
  where tp.user_id = target and t.status = 'finished';
$$;

revoke all on function private.chess_schedule_tournaments(timestamptz), public.chess_tournament_standings(uuid), public.chess_medals(uuid)
  from public;
grant execute on function private.chess_schedule_tournaments(timestamptz) to service_role;
grant execute on function public.chess_tournament_standings(uuid), public.chess_medals(uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- Notifications (notifications owns the table): the start for people who joined early, the result for the top three.
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
                  'chess_arena_start', 'chess_arena_medal'));

create function private.notify_chess_arena()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if old.status = 'scheduled' and new.status = 'live' then
    insert into public.notifications (recipient_id, actor_id, type)
    select tp.user_id, tp.user_id, 'chess_arena_start'
    from public.chess_tournament_players tp
    where tp.tournament_id = new.id and private.wants_notification(tp.user_id, 'chess_arena_start');
  elsif old.status = 'live' and new.status = 'finished' then
    insert into public.notifications (recipient_id, actor_id, type)
    select tp.user_id, tp.user_id, 'chess_arena_medal'
    from public.chess_tournament_players tp
    where tp.tournament_id = new.id and tp.final_rank <= 3;
  end if;
  return null;
end;
$$;

revoke all on function private.notify_chess_arena() from public;

create trigger notify_chess_arena after update of status on public.chess_tournaments
  for each row execute function private.notify_chess_arena();
