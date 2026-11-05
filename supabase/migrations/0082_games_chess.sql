-- 0082_games_chess
-- Faz 20a (docs/ARCHITECTURE.md §3i): chess between people. The API (C#) is the only writer of games, ratings,
-- seeks and challenges: it validates every move, keeps the clock and updates Elo. Clients read under RLS and follow
-- their game, seek and challenges through Realtime. A person writes only their own flag (chess_players.country).
-- owner: games

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------
create table public.chess_players (
  user_id           uuid primary key references public.profiles (id) on delete cascade,
  country           text check (country ~ '^[A-Z]{2}$'),
  -- 'infinity' is a permanent suspension; set only by the platform team through the API.
  suspended_until   timestamptz,
  suspension_reason text check (suspension_reason is null or char_length(suspension_reason) between 3 and 500),
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

comment on table public.chess_players is
  'owner: games. A person''s chess card: the flag they chose and a platform suspension. No row means no flag.';

create table public.chess_ratings (
  user_id    uuid not null references public.profiles (id) on delete cascade,
  category   text not null check (category in ('bullet', 'blitz', 'rapid')),
  rating     int not null default 1200 check (rating >= 100),
  peak       int not null default 1200,
  games      int not null default 0 check (games >= 0),
  wins       int not null default 0 check (wins >= 0),
  draws      int not null default 0 check (draws >= 0),
  losses     int not null default 0 check (losses >= 0),
  updated_at timestamptz not null default now(),
  primary key (user_id, category)
);

comment on table public.chess_ratings is 'owner: games. Elo per time category; written by the API with the game result.';

create index chess_ratings_board_idx on public.chess_ratings (category, rating desc);

create table public.chess_games (
  id                uuid primary key default gen_random_uuid(),
  white_id          uuid references public.profiles (id) on delete set null,
  black_id          uuid references public.profiles (id) on delete set null,
  category          text not null check (category in ('bullet', 'blitz', 'rapid')),
  base_seconds      int not null,
  increment_seconds int not null,
  rated             boolean not null,
  source            text not null check (source in ('seek', 'challenge')),
  status            text not null default 'active' check (status in ('active', 'finished', 'aborted')),
  result            text check (result in ('white', 'black', 'draw')),
  termination       text check (termination in ('checkmate', 'resign', 'timeout', 'timeout_draw', 'stalemate',
                                                'insufficient', 'fifty_moves', 'repetition', 'agreement', 'aborted')),
  moves             text[] not null default '{}',
  san               text[] not null default '{}',
  fen               text not null default 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
  white_ms          bigint not null,
  black_ms          bigint not null,
  -- When the side to move started thinking; with fewer than two plies it starts the 30-second first-move window.
  turn_started_at   timestamptz not null default now(),
  draw_offer        text check (draw_offer in ('white', 'black')),
  white_offer_ply   int,
  black_offer_ply   int,
  white_rating      int not null,
  black_rating      int not null,
  white_delta       int,
  black_delta       int,
  rematch_of        uuid references public.chess_games (id) on delete set null,
  created_at        timestamptz not null default now(),
  ended_at          timestamptz,
  constraint chess_games_players check (white_id <> black_id),
  constraint chess_games_time_control check ((base_seconds, increment_seconds) in
    ((60, 0), (120, 1), (180, 0), (180, 2), (300, 0), (300, 3), (600, 0), (600, 5), (900, 10))),
  constraint chess_games_outcome check (
    (status = 'active' and result is null and termination is null and ended_at is null)
    or (status = 'finished' and result is not null and termination is not null and termination <> 'aborted' and ended_at is not null)
    or (status = 'aborted' and result is null and termination = 'aborted' and ended_at is not null)),
  constraint chess_games_moves check (cardinality(moves) = cardinality(san))
);

comment on table public.chess_games is
  'owner: games. One game. Only the API writes: moves are validated there, clocks are server time. Realtime-published.';

create index chess_games_white_idx on public.chess_games (white_id, created_at desc);
create index chess_games_black_idx on public.chess_games (black_id, created_at desc);
create index chess_games_active_idx on public.chess_games (turn_started_at) where status = 'active';

create table public.chess_seeks (
  user_id           uuid primary key references public.profiles (id) on delete cascade,
  category          text not null check (category in ('bullet', 'blitz', 'rapid')),
  base_seconds      int not null,
  increment_seconds int not null,
  rated             boolean not null,
  rating            int not null,
  game_id           uuid references public.chess_games (id) on delete cascade,
  created_at        timestamptz not null default now(),
  touched_at        timestamptz not null default now()
);

comment on table public.chess_seeks is
  'owner: games. Someone waiting for a quick game; game_id is set when paired. Refreshed every 20 s, dropped after 60 s.';

create index chess_seeks_pool_idx on public.chess_seeks (base_seconds, increment_seconds, rated, created_at) where game_id is null;

create table public.chess_challenges (
  id                uuid primary key default gen_random_uuid(),
  challenger_id     uuid not null references public.profiles (id) on delete cascade,
  opponent_id       uuid not null references public.profiles (id) on delete cascade,
  category          text not null check (category in ('bullet', 'blitz', 'rapid')),
  base_seconds      int not null,
  increment_seconds int not null,
  rated             boolean not null,
  color             text not null default 'random' check (color in ('random', 'white', 'black')),
  status            text not null default 'pending' check (status in ('pending', 'accepted', 'declined', 'canceled', 'expired')),
  game_id           uuid references public.chess_games (id) on delete set null,
  rematch_of        uuid references public.chess_games (id) on delete set null,
  created_at        timestamptz not null default now(),
  expires_at        timestamptz not null default now() + interval '10 minutes',
  responded_at      timestamptz,
  constraint chess_challenges_people check (challenger_id <> opponent_id)
);

comment on table public.chess_challenges is
  'owner: games. An invitation to a game; pending for 10 minutes. Both people read it; the API writes.';

create unique index chess_challenges_one_pending on public.chess_challenges (challenger_id, opponent_id) where status = 'pending';
create index chess_challenges_opponent_idx on public.chess_challenges (opponent_id, created_at desc);
create index chess_challenges_challenger_idx on public.chess_challenges (challenger_id, created_at desc);
create index chess_challenges_pending_idx on public.chess_challenges (expires_at) where status = 'pending';

-- ---------------------------------------------------------------------------
-- RLS: deny by default; reads below, the only client write is one's own flag.
-- ---------------------------------------------------------------------------
alter table public.chess_players enable row level security;
alter table public.chess_ratings enable row level security;
alter table public.chess_games enable row level security;
alter table public.chess_seeks enable row level security;
alter table public.chess_challenges enable row level security;
revoke all on public.chess_players, public.chess_ratings, public.chess_games, public.chess_seeks, public.chess_challenges
  from anon, authenticated;

-- The suspension reason stays with the platform team.
grant select (user_id, country, suspended_until, created_at, updated_at) on public.chess_players to authenticated;
grant insert (user_id, country) on public.chess_players to authenticated;
-- user_id too: the app saves the flag with an upsert, which sets every column it sends; RLS keeps it one's own.
grant update (user_id, country) on public.chess_players to authenticated;
grant select on public.chess_ratings, public.chess_games, public.chess_seeks, public.chess_challenges to authenticated;

create policy chess_players_select on public.chess_players for select to authenticated
  using (user_id = (select auth.uid()) or private.is_account_visible(user_id) or (select private.is_platform_staff()));
create policy chess_players_insert_own on public.chess_players for insert to authenticated
  with check (user_id = (select auth.uid()) and (select private.is_account_active(auth.uid())));
create policy chess_players_update_own on public.chess_players for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()) and (select private.is_account_active(auth.uid())));

create policy chess_ratings_select on public.chess_ratings for select to authenticated
  using (user_id = (select auth.uid()) or private.is_account_visible(user_id) or (select private.is_platform_staff()));

-- Games are public to signed-in people, like a game record; a hidden account's games stay with its opponent.
create policy chess_games_select on public.chess_games for select to authenticated
  using (
    white_id = (select auth.uid()) or black_id = (select auth.uid())
    or (select private.is_platform_staff())
    or ((white_id is null or private.is_account_visible(white_id)) and (black_id is null or private.is_account_visible(black_id)))
  );

create policy chess_seeks_select_own on public.chess_seeks for select to authenticated
  using (user_id = (select auth.uid()));

create policy chess_challenges_select_party on public.chess_challenges for select to authenticated
  using (challenger_id = (select auth.uid()) or opponent_id = (select auth.uid()) or (select private.is_platform_staff()));

create function private.chess_players_touch()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create trigger chess_players_touch before update on public.chess_players
  for each row execute function private.chess_players_touch();

alter publication supabase_realtime add table public.chess_games, public.chess_seeks, public.chess_challenges;

-- ---------------------------------------------------------------------------
-- Leaderboard
-- ---------------------------------------------------------------------------

-- Ranked: at least 5 rated games in the category, not suspended, account visible. Rating, then more games, first.
create function private.chess_ranked(target_category text)
returns table (rank bigint, user_id uuid, rating int, games int, wins int, draws int, losses int)
language sql
stable
security definer
set search_path = ''
as $$
  select rank() over (order by r.rating desc, r.games desc), r.user_id, r.rating, r.games, r.wins, r.draws, r.losses
  from public.chess_ratings r
  left join public.chess_players p on p.user_id = r.user_id
  where r.category = target_category and r.games >= 5
    and (p.suspended_until is null or p.suspended_until <= now())
    and private.is_account_visible(r.user_id);
$$;

create function public.chess_leaderboard(target_category text, page_size int default 50, page_offset int default 0)
returns table (rank bigint, user_id uuid, username text, display_name text, avatar_path text, country text,
               rating int, games int, wins int, draws int, losses int)
language sql
stable
security invoker
set search_path = ''
as $$
  select k.rank, k.user_id, pr.username, pr.display_name, pr.avatar_path, cp.country, k.rating, k.games, k.wins, k.draws, k.losses
  from private.chess_ranked(target_category) k
  join public.profiles pr on pr.id = k.user_id
  left join public.chess_players cp on cp.user_id = k.user_id
  order by k.rank, pr.username
  limit least(greatest(page_size, 1), 100) offset greatest(page_offset, 0);
$$;

-- A person's place in each category (the signed-in person by default); null where they are not ranked.
create function public.chess_ranks(target uuid default null)
returns table (category text, rank bigint)
language sql
stable
security invoker
set search_path = ''
as $$
  select c.category, (select k.rank from private.chess_ranked(c.category) k where k.user_id = coalesce(target, (select auth.uid())))
  from (values ('bullet'), ('blitz'), ('rapid')) as c (category);
$$;

revoke all on function private.chess_ranked(text), public.chess_leaderboard(text, int, int), public.chess_ranks(uuid) from public;
grant execute on function private.chess_ranked(text), public.chess_leaderboard(text, int, int), public.chess_ranks(uuid)
  to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- Notifications (notifications owns the table): an invitation rings the opponent.
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
                  'chess_challenge'));

create function private.notify_chess_challenge()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if private.wants_notification(new.opponent_id, 'chess_challenge') then
    insert into public.notifications (recipient_id, actor_id, type) values (new.opponent_id, new.challenger_id, 'chess_challenge');
  end if;
  return null;
end;
$$;

revoke all on function private.notify_chess_challenge(), private.chess_players_touch() from public;

create trigger notify_chess_challenge after insert on public.chess_challenges
  for each row execute function private.notify_chess_challenge();
