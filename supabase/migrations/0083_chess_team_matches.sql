-- 0083_chess_team_matches
-- Faz 20b (docs/ARCHITECTURE.md §3i, Takım maçı ve grup Elo'su): a group invites another to a team match on 2–10
-- boards; both line up members; at the start the API opens one game per board. The match score moves the groups'
-- own Elo. The API (C#) is the only writer; clients read under RLS and Realtime.
-- owner: games

-- ---------------------------------------------------------------------------
-- Permission (groups owns the catalog): owners have it, Yöneticiler get it.
-- ---------------------------------------------------------------------------
insert into public.group_permissions (slug, description) values
  ('games.team_match', 'Başka grupları satranç takım maçına davet etme, daveti yanıtlama ve tahtalara oyuncu dizme');
insert into public.group_role_permissions (role, permission) values ('admin', 'games.team_match');

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------
create table public.chess_group_ratings (
  group_id   uuid primary key references public.groups (id) on delete cascade,
  rating     int not null default 1200 check (rating >= 100),
  peak       int not null default 1200,
  matches    int not null default 0 check (matches >= 0),
  wins       int not null default 0 check (wins >= 0),
  draws      int not null default 0 check (draws >= 0),
  losses     int not null default 0 check (losses >= 0),
  updated_at timestamptz not null default now()
);

comment on table public.chess_group_ratings is 'owner: games. A group''s Elo from team matches; written with the match result.';

create table public.chess_team_matches (
  id                uuid primary key default gen_random_uuid(),
  home_group_id     uuid not null references public.groups (id) on delete cascade,
  away_group_id     uuid not null references public.groups (id) on delete cascade,
  boards            int not null check (boards between 2 and 10),
  category          text not null check (category in ('blitz', 'rapid')),
  base_seconds      int not null,
  increment_seconds int not null,
  starts_at         timestamptz not null,
  status            text not null default 'invited'
                    check (status in ('invited', 'accepted', 'declined', 'canceled', 'live', 'finished')),
  created_by        uuid references public.profiles (id) on delete set null,
  responded_by      uuid references public.profiles (id) on delete set null,
  home_points       numeric(4, 1),
  away_points       numeric(4, 1),
  home_rating       int,
  away_rating       int,
  home_delta        int,
  away_delta        int,
  created_at        timestamptz not null default now(),
  responded_at      timestamptz,
  ended_at          timestamptz,
  constraint chess_team_matches_groups check (home_group_id <> away_group_id),
  constraint chess_team_matches_time_control check ((base_seconds, increment_seconds) in
    ((180, 0), (180, 2), (300, 0), (300, 3), (600, 0), (600, 5), (900, 10))),
  constraint chess_team_matches_result check ((status = 'finished') = (home_points is not null and away_points is not null))
);

comment on table public.chess_team_matches is
  'owner: games. A team match between two groups: invited, accepted, live at starts_at, finished when every board is decided.';

create index chess_team_matches_home_idx on public.chess_team_matches (home_group_id, starts_at desc);
create index chess_team_matches_away_idx on public.chess_team_matches (away_group_id, starts_at desc);
create index chess_team_matches_due_idx on public.chess_team_matches (starts_at) where status in ('invited', 'accepted');
-- One open match between the same two groups at a time, whoever invited.
create unique index chess_team_matches_one_open on public.chess_team_matches
  (least(home_group_id, away_group_id), greatest(home_group_id, away_group_id)) where status in ('invited', 'accepted', 'live');

create table public.chess_team_lineups (
  match_id uuid not null references public.chess_team_matches (id) on delete cascade,
  group_id uuid not null references public.groups (id) on delete cascade,
  board    int not null check (board between 1 and 10),
  user_id  uuid not null references public.profiles (id) on delete cascade,
  primary key (match_id, group_id, board),
  unique (match_id, user_id)
);

comment on table public.chess_team_lineups is 'owner: games. Who plays which board for a side; set by the side''s captains before the start.';

create table public.chess_team_boards (
  match_id    uuid not null references public.chess_team_matches (id) on delete cascade,
  board       int not null check (board between 1 and 10),
  home_id     uuid references public.profiles (id) on delete set null,
  away_id     uuid references public.profiles (id) on delete set null,
  game_id     uuid references public.chess_games (id) on delete set null,
  home_points numeric(2, 1) check (home_points in (0, 0.5, 1)),
  away_points numeric(2, 1) check (away_points in (0, 0.5, 1)),
  primary key (match_id, board),
  constraint chess_team_boards_decided check ((home_points is null) = (away_points is null))
);

comment on table public.chess_team_boards is
  'owner: games. One board of a started match: its game, or a forfeit when a side had nobody there. Points once decided.';

create unique index chess_team_boards_game on public.chess_team_boards (game_id) where game_id is not null;

-- A game of a team match knows its board; a side that never made its first move loses it (no_show).
alter table public.chess_games drop constraint chess_games_termination_check;
alter table public.chess_games add constraint chess_games_termination_check
  check (termination in ('checkmate', 'resign', 'timeout', 'timeout_draw', 'stalemate', 'insufficient', 'fifty_moves',
                         'repetition', 'agreement', 'aborted', 'no_show'));
alter table public.chess_games drop constraint chess_games_source_check;
alter table public.chess_games add constraint chess_games_source_check check (source in ('seek', 'challenge', 'team_match'));
alter table public.chess_games add column team_match_id uuid references public.chess_team_matches (id) on delete set null;

-- ---------------------------------------------------------------------------
-- RLS: everything is public to signed-in people while both groups are visible; only the API writes.
-- ---------------------------------------------------------------------------
alter table public.chess_group_ratings enable row level security;
alter table public.chess_team_matches enable row level security;
alter table public.chess_team_lineups enable row level security;
alter table public.chess_team_boards enable row level security;
revoke all on public.chess_group_ratings, public.chess_team_matches, public.chess_team_lineups, public.chess_team_boards
  from anon, authenticated;
grant select on public.chess_group_ratings, public.chess_team_matches, public.chess_team_lineups, public.chess_team_boards
  to authenticated;

create policy chess_group_ratings_select on public.chess_group_ratings for select to authenticated
  using (private.is_group_visible(group_id));

create policy chess_team_matches_select on public.chess_team_matches for select to authenticated
  using ((private.is_group_visible(home_group_id) and private.is_group_visible(away_group_id)) or (select private.is_platform_staff()));

create policy chess_team_lineups_select on public.chess_team_lineups for select to authenticated
  using (exists (select 1 from public.chess_team_matches m where m.id = match_id));

create policy chess_team_boards_select on public.chess_team_boards for select to authenticated
  using (exists (select 1 from public.chess_team_matches m where m.id = match_id));

alter publication supabase_realtime add table public.chess_team_matches, public.chess_team_boards;

-- ---------------------------------------------------------------------------
-- Reads
-- ---------------------------------------------------------------------------

-- Groups by Elo: at least one finished team match, active. Rating, then more matches, first.
create function public.chess_group_leaderboard(page_size int default 50, page_offset int default 0)
returns table (rank bigint, group_id uuid, handle text, name text, logo_path text, category_slug text, member_count int,
               rating int, matches int, wins int, draws int, losses int)
language sql
stable
security invoker
set search_path = ''
as $$
  select rank() over (order by r.rating desc, r.matches desc), g.id, g.handle, g.name, g.logo_path, g.category_slug, g.member_count,
         r.rating, r.matches, r.wins, r.draws, r.losses
  from public.chess_group_ratings r
  join public.groups g on g.id = r.group_id
  where r.matches > 0 and g.status = 'active'
  order by r.rating desc, r.matches desc, g.name
  limit least(greatest(page_size, 1), 100) offset greatest(page_offset, 0);
$$;

-- The groups where the signed-in person may arrange team matches. The work runs as the owner in private;
-- the exposed schema only has invoker wrappers (00_rls_enabled).
create function private.chess_captain_groups()
returns table (group_id uuid, handle text, name text, logo_path text)
language sql
stable
security definer
set search_path = ''
as $$
  select g.id, g.handle, g.name, g.logo_path
  from public.group_members m
  join public.groups g on g.id = m.group_id
  where m.user_id = (select auth.uid()) and g.status = 'active'
    and private.user_has_group_permission((select auth.uid()), g.id, 'games.team_match')
  order by g.name;
$$;

-- Members a captain can put on a board, with their rating in the match's category. Empty for anyone else.
create function private.chess_team_candidates(target_match uuid, target_group uuid)
returns table (user_id uuid, username text, display_name text, avatar_path text, country text, rating int, games int)
language sql
stable
security definer
set search_path = ''
as $$
  select p.id, p.username, p.display_name, p.avatar_path, cp.country, coalesce(r.rating, 1200), coalesce(r.games, 0)
  from public.chess_team_matches tm
  join public.group_members m on m.group_id = target_group
  join public.profiles p on p.id = m.user_id
  left join public.chess_players cp on cp.user_id = p.id
  left join public.chess_ratings r on r.user_id = p.id and r.category = tm.category
  where tm.id = target_match and target_group in (tm.home_group_id, tm.away_group_id)
    and private.user_has_group_permission((select auth.uid()), target_group, 'games.team_match')
    and private.is_account_active(p.id)
    and (cp.suspended_until is null or cp.suspended_until <= now())
  order by coalesce(r.rating, 1200) desc, p.username;
$$;

create function public.chess_captain_groups()
returns table (group_id uuid, handle text, name text, logo_path text)
language sql
stable
security invoker
set search_path = ''
as $$
  select * from private.chess_captain_groups();
$$;

create function public.chess_team_candidates(target_match uuid, target_group uuid)
returns table (user_id uuid, username text, display_name text, avatar_path text, country text, rating int, games int)
language sql
stable
security invoker
set search_path = ''
as $$
  select * from private.chess_team_candidates(target_match, target_group);
$$;

revoke all on function public.chess_group_leaderboard(int, int), public.chess_captain_groups(), public.chess_team_candidates(uuid, uuid),
  private.chess_captain_groups(), private.chess_team_candidates(uuid, uuid) from public;
grant execute on function public.chess_group_leaderboard(int, int), public.chess_captain_groups(), public.chess_team_candidates(uuid, uuid),
  private.chess_captain_groups(), private.chess_team_candidates(uuid, uuid) to authenticated, service_role;

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
                  'chess_challenge', 'chess_team_invite', 'chess_team_accepted', 'chess_team_declined', 'chess_team_start'));

-- The notice names the other group (group_id) and who acted.
create function private.notify_chess_team_match()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor uuid := coalesce(new.responded_by, new.created_by);
begin
  if tg_op = 'INSERT' then
    insert into public.notifications (recipient_id, actor_id, type, group_id)
    select m.user_id, new.created_by, 'chess_team_invite', new.home_group_id
    from public.group_members m
    where m.group_id = new.away_group_id and new.created_by is not null and m.user_id <> new.created_by
      and private.user_has_group_permission(m.user_id, new.away_group_id, 'games.team_match');
  elsif old.status = 'invited' and new.status in ('accepted', 'declined') and new.created_by is not null and actor is not null then
    insert into public.notifications (recipient_id, actor_id, type, group_id)
    values (new.created_by, actor, case new.status when 'accepted' then 'chess_team_accepted' else 'chess_team_declined' end, new.away_group_id);
  elsif old.status = 'accepted' and new.status = 'live' then
    insert into public.notifications (recipient_id, actor_id, type, group_id)
    select l.user_id, l.user_id, 'chess_team_start', case when l.group_id = new.home_group_id then new.away_group_id else new.home_group_id end
    from public.chess_team_lineups l
    where l.match_id = new.id and private.wants_notification(l.user_id, 'chess_team_start');
  end if;
  return null;
end;
$$;

revoke all on function private.notify_chess_team_match() from public;

create trigger notify_chess_team_match after insert or update of status on public.chess_team_matches
  for each row execute function private.notify_chess_team_match();
