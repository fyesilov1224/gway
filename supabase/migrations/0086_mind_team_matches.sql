-- 0086_mind_team_matches
-- Faz 21b (docs/ARCHITECTURE.md §3j, Grupların düellosu): the chess team match becomes a match of either game.
-- A Zihin Düellosu team match sets a question count instead of a time control; at the start the API opens one duel per
-- seat. Each game keeps its own group Elo. The API (C#) is the only writer, as before.
-- owner: games

update public.group_permissions
set description = 'Başka grupları satranç takım maçına ve grup düellosuna davet etme, daveti yanıtlama ve oyuncu dizme'
where slug = 'games.team_match';

-- ---------------------------------------------------------------------------
-- Team matches of either game
-- ---------------------------------------------------------------------------
alter table public.chess_team_matches
  add column game text not null default 'chess' check (game in ('chess', 'mind')),
  add column length int check (length in (5, 10, 20, 50));
alter table public.chess_team_matches
  alter column category drop not null,
  alter column base_seconds drop not null,
  alter column increment_seconds drop not null;
alter table public.chess_team_matches drop constraint chess_team_matches_time_control;
alter table public.chess_team_matches add constraint chess_team_matches_format check (
  (game = 'chess' and length is null and category is not null and (base_seconds, increment_seconds) in
    ((180, 0), (180, 2), (300, 0), (300, 3), (600, 0), (600, 5), (900, 10)))
  or (game = 'mind' and length is not null and category is null and base_seconds is null and increment_seconds is null));

comment on table public.chess_team_matches is
  'owner: games. A team match between two groups in chess or Zihin Düellosu (game): invited, accepted, live at starts_at, '
  'finished when every board is decided.';

-- One open match per game between the same two groups.
drop index public.chess_team_matches_one_open;
create unique index chess_team_matches_one_open on public.chess_team_matches
  (game, least(home_group_id, away_group_id), greatest(home_group_id, away_group_id)) where status in ('invited', 'accepted', 'live');

alter table public.chess_team_boards add column mind_match_id uuid references public.mind_matches (id) on delete set null;
create unique index chess_team_boards_mind_match on public.chess_team_boards (mind_match_id) where mind_match_id is not null;

-- Each game has its own group Elo.
alter table public.chess_group_ratings add column game text not null default 'chess' check (game in ('chess', 'mind'));
alter table public.chess_group_ratings drop constraint chess_group_ratings_pkey;
alter table public.chess_group_ratings add primary key (group_id, game);

-- A duel can be a seat of a team match; a side that never took a question loses it (no_show).
alter table public.mind_matches drop constraint mind_matches_source_check;
alter table public.mind_matches add constraint mind_matches_source_check check (source in ('seek', 'challenge', 'team_match'));
alter table public.mind_matches drop constraint mind_matches_termination_check;
alter table public.mind_matches add constraint mind_matches_termination_check
  check (termination in ('completed', 'time', 'resign', 'aborted', 'no_show'));
alter table public.mind_matches add column team_match_id uuid references public.chess_team_matches (id) on delete set null;

-- ---------------------------------------------------------------------------
-- Reads
-- ---------------------------------------------------------------------------
drop function public.chess_group_leaderboard(int, int);

-- Groups by the game's Elo: at least one finished team match, active. Rating, then more matches, first.
create function public.chess_group_leaderboard(page_size int default 50, page_offset int default 0, target_game text default 'chess')
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
  where r.game = target_game and r.matches > 0 and g.status = 'active'
  order by r.rating desc, r.matches desc, g.name
  limit least(greatest(page_size, 1), 100) offset greatest(page_offset, 0);
$$;

revoke all on function public.chess_group_leaderboard(int, int, text) from public;
grant execute on function public.chess_group_leaderboard(int, int, text) to authenticated, service_role;

-- Candidates carry their rating in the match's game: the chess category, or the duel length.
create or replace function private.chess_team_candidates(target_match uuid, target_group uuid)
returns table (user_id uuid, username text, display_name text, avatar_path text, country text, rating int, games int)
language sql
stable
security definer
set search_path = ''
as $$
  select p.id, p.username, p.display_name, p.avatar_path, cp.country,
         coalesce(r.rating, mr.rating, 1200), coalesce(r.games, mr.games, 0)
  from public.chess_team_matches tm
  join public.group_members m on m.group_id = target_group
  join public.profiles p on p.id = m.user_id
  left join public.chess_players cp on cp.user_id = p.id
  left join public.chess_ratings r on tm.game = 'chess' and r.user_id = p.id and r.category = tm.category
  left join public.mind_ratings mr on tm.game = 'mind' and mr.user_id = p.id and mr.length = tm.length
  where tm.id = target_match and target_group in (tm.home_group_id, tm.away_group_id)
    and private.user_has_group_permission((select auth.uid()), target_group, 'games.team_match')
    and private.is_account_active(p.id)
    and (cp.suspended_until is null or cp.suspended_until <= now())
  order by coalesce(r.rating, mr.rating, 1200) desc, p.username;
$$;

-- ---------------------------------------------------------------------------
-- Notifications (notifications owns the table): the duel has its own four notices.
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
                  'mind_challenge', 'mind_team_invite', 'mind_team_accepted', 'mind_team_declined', 'mind_team_start'));

create or replace function private.notify_chess_team_match()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor uuid := coalesce(new.responded_by, new.created_by);
  prefix text := case new.game when 'mind' then 'mind_' else 'chess_' end;
begin
  if tg_op = 'INSERT' then
    insert into public.notifications (recipient_id, actor_id, type, group_id)
    select m.user_id, new.created_by, prefix || 'team_invite', new.home_group_id
    from public.group_members m
    where m.group_id = new.away_group_id and new.created_by is not null and m.user_id <> new.created_by
      and private.user_has_group_permission(m.user_id, new.away_group_id, 'games.team_match');
  elsif old.status = 'invited' and new.status in ('accepted', 'declined') and new.created_by is not null and actor is not null then
    insert into public.notifications (recipient_id, actor_id, type, group_id)
    values (new.created_by, actor, prefix || case new.status when 'accepted' then 'team_accepted' else 'team_declined' end, new.away_group_id);
  elsif old.status = 'accepted' and new.status = 'live' then
    insert into public.notifications (recipient_id, actor_id, type, group_id)
    select l.user_id, l.user_id, prefix || 'team_start', case when l.group_id = new.home_group_id then new.away_group_id else new.home_group_id end
    from public.chess_team_lineups l
    where l.match_id = new.id and private.wants_notification(l.user_id, prefix || 'team_start');
  end if;
  return null;
end;
$$;
