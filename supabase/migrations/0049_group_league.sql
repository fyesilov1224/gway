-- 0049: groups league — groups of the same category and province play a monthly season
-- (docs/ARCHITECTURE.md §3d, Gruplar Ligi). Points come from the source records; a closed
-- season is frozen in league_results.

-- ---------------------------------------------------------------------------
-- Tables (owner: events; the backend writes, clients read through the functions below)
-- ---------------------------------------------------------------------------
create table public.league_exclusions (
  month       date not null check (month = date_trunc('month', month)::date),
  group_id    uuid not null references public.groups (id) on delete cascade,
  reason      text not null check (char_length(reason) between 3 and 500),
  excluded_by uuid references public.profiles (id) on delete set null,
  created_at  timestamptz not null default now(),
  primary key (month, group_id)
);

comment on table public.league_exclusions is
  'owner: events. A group the platform team took out of a month''s league (e.g. fake attendance).';

create table public.league_seasons (
  month        date primary key check (month = date_trunc('month', month)::date),
  finalized_at timestamptz not null default now()
);

comment on table public.league_seasons is 'owner: events. Closed seasons; their standings are frozen in league_results.';

create table public.league_results (
  month         date not null references public.league_seasons (month) on delete cascade,
  category_slug text not null,
  province      smallint not null,
  group_id      uuid not null references public.groups (id) on delete cascade,
  rank          int not null check (rank > 0),
  points        int not null,
  attended      int not null,
  held          int not null,
  welcomes      int not null,
  good_reviews  int not null,
  primary key (month, group_id)
);

comment on table public.league_results is 'owner: events. Final standings of a closed season, one row per group with points.';

create index league_results_league_idx on public.league_results (month, category_slug, province, rank);
create index league_results_group_idx on public.league_results (group_id, month desc);

alter table public.league_exclusions enable row level security;
alter table public.league_seasons enable row level security;
alter table public.league_results enable row level security;
revoke all on public.league_exclusions, public.league_seasons, public.league_results from anon, authenticated;

-- Only the platform team excludes, and only from a season still open (second layer of the API).
create function private.league_exclusions_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  target date := coalesce(new.month, old.month);
begin
  -- Cascades (a deleted group) pass.
  if pg_trigger_depth() > 1 then
    return coalesce(new, old);
  end if;
  if not private.is_platform_staff() then
    raise exception 'league_forbidden' using errcode = 'P0001';
  end if;
  if exists (select 1 from public.league_seasons s where s.month = target) then
    raise exception 'league_season_closed' using errcode = 'P0001';
  end if;
  if tg_op = 'INSERT' then
    new.excluded_by := (select p.id from public.profiles p where p.id = (select auth.uid()));
    new.created_at := now();
  end if;
  return coalesce(new, old);
end;
$$;

create trigger league_exclusions_guard
  before insert or update or delete on public.league_exclusions
  for each row execute function private.league_exclusions_guard();

-- ---------------------------------------------------------------------------
-- Points
-- ---------------------------------------------------------------------------

-- The first day of the month that holds the moment in Turkey.
create function private.turkey_month(at timestamptz)
returns date
language sql
stable
set search_path = ''
as $$
  select date_trunc('month', (at at time zone 'Europe/Istanbul'))::date;
$$;

-- Every active group with a province and points in the month, with the breakdown.
create function private.league_scores(target_month date)
returns table (group_id uuid, category_slug text, province smallint, member_count int, name text,
               points int, attended int, held int, welcomes int, good_reviews int)
language sql
stable
security definer
set search_path = ''
as $$
  with bounds as (
    select (target_month::timestamp at time zone 'Europe/Istanbul') as from_at,
           ((target_month + interval '1 month')::timestamp at time zone 'Europe/Istanbul') as to_at
  ), ev as (
    select e.id, e.group_id, e.created_by
    from public.events e, bounds b
    where e.starts_at >= b.from_at and e.starts_at < b.to_at and e.canceled_at is null
      and coalesce(e.ends_at, e.starts_at + interval '2 hours') <= now()
  ), att as (
    select ev.id, ev.group_id, count(*) as n, count(*) filter (where a.user_id <> ev.created_by) as others
    from ev join public.event_attendees a on a.event_id = ev.id
    where a.status = 'going' and a.no_show_at is null and private.is_account_active(a.user_id)
    group by ev.id, ev.group_id
  ), per_group as (
    select g.id, g.category_slug, g.province, g.member_count, g.name,
      coalesce((select sum(least(att.n, 30)) from att where att.group_id = g.id), 0)::int as attended,
      coalesce((select count(*) from att where att.group_id = g.id and att.others >= 3), 0)::int as held,
      coalesce((select count(*) from public.event_welcomes w join ev on ev.id = w.event_id
                where ev.group_id = g.id and w.greeter_id is not null
                  and private.attended_event(w.newcomer_id, w.event_id) and private.attended_event(w.greeter_id, w.event_id)), 0)::int as welcomes,
      coalesce((select count(*) from public.event_reviews r join ev on ev.id = r.event_id
                where ev.group_id = g.id and r.rating >= 4), 0)::int as good_reviews
    from public.groups g
    where g.status = 'active' and g.province is not null
      and not exists (select 1 from public.league_exclusions x where x.group_id = g.id and x.month = target_month)
  )
  select id, category_slug, province, member_count, name,
         attended + 5 * held + 3 * welcomes + good_reviews, attended, held, welcomes, good_reviews
  from per_group
  where attended + 5 * held + 3 * welcomes + good_reviews > 0;
$$;

-- ---------------------------------------------------------------------------
-- Closing a season
-- ---------------------------------------------------------------------------

-- Closes every season that ended more than 8 days before as_of (the roll call stays open 7 days),
-- freezes its standings and tells the members of each league's top three. Returns how many.
create function private.finalize_league_seasons(as_of timestamptz default now())
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  m date := coalesce((select max(s.month) + interval '1 month' from public.league_seasons s)::date, date '2026-10-01');
  closed int := 0;
begin
  while (m + interval '1 month' + interval '8 days') <= (as_of at time zone 'Europe/Istanbul') loop
    insert into public.league_seasons (month) values (m);
    insert into public.league_results (month, category_slug, province, group_id, rank, points, attended, held, welcomes, good_reviews)
    select m, s.category_slug, s.province, s.group_id,
           rank() over (partition by s.category_slug, s.province order by s.points desc, s.member_count, s.name),
           s.points, s.attended, s.held, s.welcomes, s.good_reviews
    from private.league_scores(m) s;

    insert into public.notifications (recipient_id, actor_id, type, group_id)
    select gm.user_id, g.owner_id, 'league_result', g.id
    from public.league_results r
    join public.groups g on g.id = r.group_id
    join public.group_members gm on gm.group_id = g.id
    where r.month = m and r.rank <= 3 and private.is_account_active(gm.user_id);

    closed := closed + 1;
    m := (m + interval '1 month')::date;
  end loop;
  return closed;
end;
$$;

revoke all on function private.turkey_month(timestamptz), private.league_scores(date), private.finalize_league_seasons(timestamptz) from public;
grant execute on function private.finalize_league_seasons(timestamptz), private.league_scores(date) to service_role;

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
                  'league_result'));

-- ---------------------------------------------------------------------------
-- Pages
-- ---------------------------------------------------------------------------

-- A league's table: frozen for a closed season, live otherwise. At most 100 groups.
create function private.league_table(target_category text, target_province smallint, target_month date)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  with m as (
    select coalesce(date_trunc('month', target_month)::date, private.turkey_month(now())) as month
  ), closed as (
    select exists (select 1 from public.league_seasons s, m where s.month = m.month) as yes
  ), live as (
    select rank() over (order by s.points desc, s.member_count, s.name)::int as rank, s.group_id, s.points,
           s.attended, s.held, s.welcomes, s.good_reviews
    from m, private.league_scores(m.month) s
    where not (select yes from closed) and s.category_slug = target_category and s.province = target_province
  ), frozen as (
    select r.rank, r.group_id, r.points, r.attended, r.held, r.welcomes, r.good_reviews
    from public.league_results r, m
    where (select yes from closed) and r.month = m.month and r.category_slug = target_category and r.province = target_province
  ), standings as (
    select * from live union all select * from frozen
  )
  select jsonb_build_object(
    'month', (select month from m),
    'category', target_category,
    'province', target_province,
    'finalized', (select yes from closed),
    'rows', coalesce((
      select jsonb_agg(jsonb_build_object(
        'rank', r.rank, 'points', r.points, 'attended', r.attended, 'held', r.held, 'welcomes', r.welcomes,
        'good_reviews', r.good_reviews,
        'group', jsonb_build_object('id', g.id, 'handle', g.handle, 'name', g.name, 'logo_path', g.logo_path,
                                    'member_count', g.member_count)
      ) order by r.rank, g.name)
      from (select * from standings order by rank limit 100) r join public.groups g on g.id = r.group_id
      where g.status = 'active'), '[]'::jsonb)
  );
$$;

-- The group page's card: this month's place and the top-three finishes of the last 12 seasons.
create function private.group_league(target_group uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  g public.groups;
  m date := private.turkey_month(now());
  me record;
  total int;
begin
  select * into g from public.groups where id = target_group;
  if g.id is null or g.province is null or not private.is_group_visible(g.id) then
    return null;
  end if;
  select count(*)::int into total from private.league_scores(m) s
  where s.category_slug = g.category_slug and s.province = g.province;
  select x.rank, x.points into me from (
    select s.group_id, s.points, rank() over (order by s.points desc, s.member_count, s.name)::int as rank
    from private.league_scores(m) s where s.category_slug = g.category_slug and s.province = g.province
  ) x where x.group_id = g.id;

  return jsonb_build_object(
    'month', m,
    'category', g.category_slug,
    'province', g.province,
    'rank', me.rank,
    'points', coalesce(me.points, 0),
    'groups', total,
    'titles', coalesce((
      select jsonb_agg(jsonb_build_object('month', r.month, 'rank', r.rank) order by r.month desc)
      from public.league_results r
      where r.group_id = g.id and r.rank <= 3 and r.month >= (m - interval '12 months')::date), '[]'::jsonb)
  );
end;
$$;

create function public.league_table(target_category text, target_province smallint, target_month date default null)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.league_table(target_category, target_province, target_month);
$$;

create function public.group_league(target_group uuid)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.group_league(target_group);
$$;

revoke all on function private.league_table(text, smallint, date), private.group_league(uuid) from public;
grant execute on function private.league_table(text, smallint, date), private.group_league(uuid) to authenticated, service_role;
revoke all on function public.league_table(text, smallint, date), public.group_league(uuid) from public, anon;
grant execute on function public.league_table(text, smallint, date), public.group_league(uuid) to authenticated;
