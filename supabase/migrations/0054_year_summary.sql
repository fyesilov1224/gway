-- 0054: the year in review and "Ben de oradaydım" — shareable story cards made on the device from the person's own
-- numbers (docs/ARCHITECTURE.md §3d, Yılın özeti; user decision 2026-10-29).

-- ---------------------------------------------------------------------------
-- The year in review (owner: events; read only, the person's own)
-- ---------------------------------------------------------------------------
create function private.year_summary(uid uuid, target_year int)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  with bounds as (
    select (make_date(target_year, 1, 1)::timestamp at time zone 'Europe/Istanbul') as from_at,
           (make_date(target_year + 1, 1, 1)::timestamp at time zone 'Europe/Istanbul') as to_at
  ), attended as (
    select e.id, e.title, e.starts_at, e.group_id, g.name as group_name, g.handle, g.category_slug, g.province,
           extract(epoch from coalesce(e.ends_at, e.starts_at + interval '2 hours') - e.starts_at) / 3600 as hours
    from public.event_attendees a
    join public.events e on e.id = a.event_id
    join public.groups g on g.id = e.group_id
    cross join bounds b
    where a.user_id = uid and a.status = 'going' and a.no_show_at is null and e.canceled_at is null
      and coalesce(e.ends_at, e.starts_at + interval '2 hours') <= now()
      and e.starts_at >= b.from_at and e.starts_at < b.to_at
  )
  select jsonb_build_object(
    'year', target_year,
    'attended', (select count(*) from attended),
    'hours', (select coalesce(round(sum(hours))::int, 0) from attended),
    'groups', (select count(distinct group_id) from attended),
    'provinces', (select count(distinct province) from attended where province is not null),
    'categories', coalesce((
      select jsonb_agg(jsonb_build_object('slug', c.slug, 'name', c.name, 'count', x.n) order by x.n desc, c.name)
      from (select category_slug, count(*) as n from attended group by category_slug order by n desc, category_slug limit 3) x
      join public.categories c on c.slug = x.category_slug), '[]'::jsonb),
    'top_group', (
      select jsonb_build_object('name', group_name, 'handle', handle, 'count', n)
      from (select group_name, handle, count(*) as n from attended group by group_id, group_name, handle
            order by n desc, group_name limit 1) t),
    'first_event', (
      select jsonb_build_object('title', title, 'starts_at', starts_at, 'group', group_name)
      from attended order by starts_at limit 1),
    'organized', (
      select count(*) from public.events e cross join bounds b
      where e.created_by = uid and e.canceled_at is null and coalesce(e.ends_at, e.starts_at + interval '2 hours') <= now()
        and e.starts_at >= b.from_at and e.starts_at < b.to_at),
    'memories', (
      select count(*) from public.posts p join public.events e on e.id = p.event_id cross join bounds b
      where p.author_id = uid and p.removed_at is null and p.created_at >= b.from_at and p.created_at < b.to_at),
    'welcomed', (
      select count(*) from public.event_welcomes w join public.events e on e.id = w.event_id cross join bounds b
      where w.greeter_id = uid and e.starts_at >= b.from_at and e.starts_at < b.to_at
        and private.attended_event(uid, w.event_id) and private.attended_event(w.newcomer_id, w.event_id)));
$$;

-- Only the signed-in person's own year, between 2026 and this year.
create function public.year_summary(target_year int)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select case
    when (select auth.uid()) is null
      or target_year < 2026 or target_year > extract(year from now() at time zone 'Europe/Istanbul')::int then null
    else private.year_summary((select auth.uid()), target_year) end;
$$;

revoke all on function private.year_summary(uuid, int), public.year_summary(int) from public;
grant execute on function private.year_summary(uuid, int), public.year_summary(int) to authenticated;

-- ---------------------------------------------------------------------------
-- Shares of the cards (owner: events; the person's own write, read by them and platform staff)
-- ---------------------------------------------------------------------------
create table public.story_card_shares (
  id         bigint generated always as identity primary key,
  user_id    uuid not null references public.profiles (id) on delete cascade,
  kind       text not null check (kind in ('year', 'event')),
  created_at timestamptz not null default now()
);

comment on table public.story_card_shares is 'owner: events. One row each time someone opens the share sheet for a story card.';

create index story_card_shares_user_idx on public.story_card_shares (user_id, created_at desc);
create index story_card_shares_created_idx on public.story_card_shares (created_at);

alter table public.story_card_shares enable row level security;
revoke all on public.story_card_shares from anon, authenticated;
grant select on public.story_card_shares to authenticated;

create policy story_card_shares_select_own_or_staff on public.story_card_shares for select to authenticated
  using (user_id = (select auth.uid()) or (select private.is_platform_staff()));

create function private.record_card_share(card_kind text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  me uuid := (select auth.uid());
begin
  if me is null or not private.is_account_active(me) then
    perform private.raise_event_rule('share_forbidden');
  end if;
  if (select count(*) from public.story_card_shares s where s.user_id = me and s.created_at > now() - interval '1 day') >= 50 then
    return; -- counting, not a feature: past the cap the share still happens, it is just not counted
  end if;
  insert into public.story_card_shares (user_id, kind) values (me, card_kind);
end;
$$;

create function public.record_card_share(card_kind text)
returns void
language sql
volatile
security invoker
set search_path = ''
as $$
  select private.record_card_share(card_kind);
$$;

revoke all on function private.record_card_share(text), public.record_card_share(text) from public;
grant execute on function private.record_card_share(text), public.record_card_share(text) to authenticated;

-- ---------------------------------------------------------------------------
-- The event page knows whether the viewer was there (as in 0053, plus was_there)
-- ---------------------------------------------------------------------------
create or replace function public.event_detail(target_event uuid)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.event_card(e) || jsonb_build_object(
    'can_manage', private.has_group_permission(e.group_id, 'events.manage'),
    'is_member', private.is_group_member(e.group_id),
    'attendees', case when private.is_group_member(e.group_id) then coalesce((
      select jsonb_agg(jsonb_build_object('id', p.id, 'username', p.username, 'display_name', p.display_name,
                                          'avatar_path', p.avatar_path,
                                          'confirmed', case when private.has_group_permission(e.group_id, 'events.manage')
                                                            then a.confirmed_at is not null end) order by a.created_at)
      from (select * from public.event_attendees where event_id = e.id and status = 'going' order by created_at limit 24) a
      join public.profiles p on p.id = a.user_id), '[]') end,
    'requests', case when private.has_group_permission(e.group_id, 'events.manage') then coalesce((
      select jsonb_agg(jsonb_build_object('id', p.id, 'username', p.username, 'display_name', p.display_name,
                                          'avatar_path', p.avatar_path) order by a.created_at)
      from (select * from public.event_attendees where event_id = e.id and status = 'requested' order by created_at limit 100) a
      join public.profiles p on p.id = a.user_id), '[]') end,
    'conflicts', coalesce((
      select jsonb_agg(jsonb_build_object('id', o.id, 'title', o.title, 'starts_at', o.starts_at) order by o.starts_at)
      from public.event_attendees a
      join public.events o on o.id = a.event_id
      where a.user_id = (select auth.uid()) and o.id <> e.id and o.canceled_at is null
        and private.event_span(o) && private.event_span(e)
    ), '[]'),
    'can_post', e.canceled_at is null and e.starts_at <= now() and (
      exists (select 1 from public.event_attendees a
              where a.event_id = e.id and a.user_id = (select auth.uid()) and a.status = 'going' and a.no_show_at is null)
      or private.has_group_permission(e.group_id, 'events.manage')),
    'can_review', private.can_review_event(e.id, (select auth.uid())),
    'was_there', case when private.attended_event((select auth.uid()), e.id) then jsonb_build_object(
      'count_in_group', (
        select count(*) from public.event_attendees a join public.events x on x.id = a.event_id
        where a.user_id = (select auth.uid()) and x.group_id = e.group_id and x.starts_at <= e.starts_at
          and private.attended_event(a.user_id, x.id))) end,
    'my_confirmed', (select a.confirmed_at is not null from public.event_attendees a
                     where a.event_id = e.id and a.user_id = (select auth.uid()) and a.status = 'going'),
    'confirmed_count', case when private.has_group_permission(e.group_id, 'events.manage') then (
      select count(*) from public.event_attendees a where a.event_id = e.id and a.status = 'going' and a.confirmed_at is not null) end,
    'my_review', (select jsonb_build_object('rating', r.rating, 'comment', r.comment)
                  from public.event_reviews r where r.event_id = e.id and r.user_id = (select auth.uid())),
    'reviews', case when private.has_group_permission(e.group_id, 'events.manage') then coalesce((
      select jsonb_agg(jsonb_build_object('id', p.id, 'username', p.username, 'display_name', p.display_name,
                                          'avatar_path', p.avatar_path, 'rating', r.rating, 'comment', r.comment,
                                          'updated_at', r.updated_at) order by r.updated_at desc)
      from public.event_reviews r join public.profiles p on p.id = r.user_id
      where r.event_id = e.id), '[]') end,
    'roll', case when private.has_group_permission(e.group_id, 'events.manage') and private.is_roll_open(e) then coalesce((
      select jsonb_agg(jsonb_build_object('id', p.id, 'username', p.username, 'display_name', p.display_name,
                                          'avatar_path', p.avatar_path, 'no_show', a.no_show_at is not null) order by p.display_name)
      from public.event_attendees a join public.profiles p on p.id = a.user_id
      where a.event_id = e.id and a.status = 'going'), '[]') end
  )
  from public.events e where e.id = target_event;
$$;
