-- Chess ratings move to Glicko-2 (docs/ARCHITECTURE.md §3i, Puan; user decision 2026-11-07): each rating keeps a
-- deviation (RD) and a volatility; the API writes them with the result. A rating with RD above 110 is provisional:
-- listed apart on the leaderboard, shown with "?". Existing ratings stay; their RD comes from the games played.

alter table public.chess_ratings
  add column deviation  real not null default 350 check (deviation between 30 and 350),
  add column volatility real not null default 0.06 check (volatility > 0 and volatility < 1),
  add column rated_at   timestamptz;

comment on column public.chess_ratings.deviation is 'Glicko-2 rating deviation (RD); above 110 the rating is provisional.';
comment on column public.chess_ratings.volatility is 'Glicko-2 volatility.';
comment on column public.chess_ratings.rated_at is 'Last rated game; idle days widen the deviation before the next one.';
comment on table public.chess_ratings is 'owner: games. Glicko-2 per time category; written by the API with the game result.';

update public.chess_ratings
set deviation = greatest(60, 350 * power(0.8, games)), rated_at = updated_at
where games > 0;

create index chess_games_rated_end_idx on public.chess_games (category, ended_at) where rated and status = 'finished';

-- ---------------------------------------------------------------------------
-- Leaderboard
-- ---------------------------------------------------------------------------

drop function public.chess_ranks(uuid);
drop function public.chess_leaderboard(text, int, int);
drop function private.chess_ranked(text);

-- Everyone with a rated game in the category, not suspended, account visible. Established ratings are ranked (rating,
-- then more games); provisional ones carry no rank. Trend: the rating change over the last 30 days.
create function private.chess_ranked(target_category text)
returns table (rank bigint, user_id uuid, rating int, games int, wins int, draws int, losses int, provisional boolean, trend int)
language sql
stable
security definer
set search_path = ''
as $$
  with board as (
    select r.user_id, r.rating, r.games, r.wins, r.draws, r.losses, r.deviation > 110 as provisional
    from public.chess_ratings r
    left join public.chess_players p on p.user_id = r.user_id
    where r.category = target_category and r.games >= 1
      and (p.suspended_until is null or p.suspended_until <= now())
      and private.is_account_visible(r.user_id)
  )
  select case when not b.provisional then rank() over (partition by b.provisional order by b.rating desc, b.games desc) end,
         b.user_id, b.rating, b.games, b.wins, b.draws, b.losses, b.provisional,
         coalesce((
           select sum(case when g.white_id = b.user_id then g.white_delta else g.black_delta end)
           from public.chess_games g
           where g.category = target_category and g.rated and g.status = 'finished'
             and g.ended_at > now() - interval '30 days' and b.user_id in (g.white_id, g.black_id)
         ), 0)::int
  from board b;
$$;

create function public.chess_leaderboard(target_category text, page_size int default 50, page_offset int default 0)
returns table (rank bigint, user_id uuid, username text, display_name text, avatar_path text, country text,
               rating int, games int, wins int, draws int, losses int, provisional boolean, trend int)
language sql
stable
security invoker
set search_path = ''
as $$
  select k.rank, k.user_id, pr.username, pr.display_name, pr.avatar_path, cp.country, k.rating, k.games, k.wins, k.draws,
         k.losses, k.provisional, k.trend
  from private.chess_ranked(target_category) k
  join public.profiles pr on pr.id = k.user_id
  left join public.chess_players cp on cp.user_id = k.user_id
  order by k.provisional, k.rank, k.rating desc, pr.username
  limit least(greatest(page_size, 1), 100) offset greatest(page_offset, 0);
$$;

-- A person's place in each category (the signed-in person by default); null where they are not ranked or provisional.
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
