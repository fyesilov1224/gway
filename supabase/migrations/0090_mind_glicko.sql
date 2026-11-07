-- Zihin Düellosu ratings move to Glicko-2 like chess (docs/ARCHITECTURE.md §3j, Puan; user request 2026-11-07): each
-- rating keeps a deviation (RD) and a volatility; above RD 110 it is provisional (listed apart, shown with "?").
-- The leaderboard lists everyone with a rated duel and the change over the last 30 days.

alter table public.mind_ratings
  add column deviation  real not null default 350 check (deviation between 30 and 350),
  add column volatility real not null default 0.06 check (volatility > 0 and volatility < 1),
  add column rated_at   timestamptz;

comment on column public.mind_ratings.deviation is 'Glicko-2 rating deviation (RD); above 110 the rating is provisional.';
comment on column public.mind_ratings.volatility is 'Glicko-2 volatility.';
comment on column public.mind_ratings.rated_at is 'Last rated duel; idle days widen the deviation before the next one.';
comment on table public.mind_ratings is 'owner: games. Glicko-2 per question count; written by the API with the match result.';

update public.mind_ratings
set deviation = greatest(60, 350 * power(0.8, games)), rated_at = updated_at
where games > 0;

create index mind_matches_rated_end_idx on public.mind_matches (length, ended_at) where rated and status = 'finished';

drop function public.mind_ranks(uuid);
drop function public.mind_leaderboard(int, int, int);
drop function private.mind_ranked(int);

-- Everyone with a rated duel at the length, not suspended from games, account visible. Established ratings are ranked
-- (rating, then more duels); provisional ones carry no rank. Trend: the rating change over the last 30 days.
create function private.mind_ranked(target_length int)
returns table (rank bigint, user_id uuid, rating int, games int, wins int, draws int, losses int, provisional boolean, trend int)
language sql
stable
security definer
set search_path = ''
as $$
  with board as (
    select r.user_id, r.rating, r.games, r.wins, r.draws, r.losses, r.deviation > 110 as provisional
    from public.mind_ratings r
    left join public.chess_players p on p.user_id = r.user_id
    where r.length = target_length and r.games >= 1
      and (p.suspended_until is null or p.suspended_until <= now())
      and private.is_account_visible(r.user_id)
  )
  select case when not b.provisional then rank() over (partition by b.provisional order by b.rating desc, b.games desc) end,
         b.user_id, b.rating, b.games, b.wins, b.draws, b.losses, b.provisional,
         coalesce((
           select sum(case when m.a_id = b.user_id then m.a_delta else m.b_delta end)
           from public.mind_matches m
           where m.length = target_length and m.rated and m.status = 'finished'
             and m.ended_at > now() - interval '30 days' and b.user_id in (m.a_id, m.b_id)
         ), 0)::int
  from board b;
$$;

create function public.mind_leaderboard(target_length int, page_size int default 50, page_offset int default 0)
returns table (rank bigint, user_id uuid, username text, display_name text, avatar_path text, country text,
               rating int, games int, wins int, draws int, losses int, provisional boolean, trend int)
language sql
stable
security invoker
set search_path = ''
as $$
  select k.rank, k.user_id, pr.username, pr.display_name, pr.avatar_path, cp.country, k.rating, k.games, k.wins, k.draws,
         k.losses, k.provisional, k.trend
  from private.mind_ranked(target_length) k
  join public.profiles pr on pr.id = k.user_id
  left join public.chess_players cp on cp.user_id = k.user_id
  order by k.provisional, k.rank, k.rating desc, pr.username
  limit least(greatest(page_size, 1), 100) offset greatest(page_offset, 0);
$$;

-- A person's place at each length (the signed-in person by default); null where they are not ranked or provisional.
create function public.mind_ranks(target uuid default null)
returns table (length int, rank bigint)
language sql
stable
security invoker
set search_path = ''
as $$
  select l.length, (select k.rank from private.mind_ranked(l.length) k where k.user_id = coalesce(target, (select auth.uid())))
  from (values (5), (10), (20), (50)) as l (length);
$$;

revoke all on function private.mind_ranked(int), public.mind_leaderboard(int, int, int), public.mind_ranks(uuid) from public;
grant execute on function private.mind_ranked(int), public.mind_leaderboard(int, int, int), public.mind_ranks(uuid)
  to authenticated, service_role;
