-- 0063_surprise_events
-- Faz 18h: surprise events (user decision, 2026-10-31; docs/ARCHITECTURE.md §3d, Sürpriz organizasyon).
-- The event's public location holds the organizer's hint; the real venue and its map point live in event_venues,
-- which nobody reads directly. The venue is served in the event card to the group's event managers and platform
-- staff at any time, and to those going once the reveal time (1, 3, 6, 12 or 24 hours before the start) has come.
-- Before that the map shows the event at its group's province center.

-- ---------------------------------------------------------------------------
-- events: the reveal setting (owner: events)
-- ---------------------------------------------------------------------------
alter table public.events
  add column surprise_reveal_hours smallint check (surprise_reveal_hours in (1, 3, 6, 12, 24)),
  add column venue_revealed_at timestamptz,
  -- A surprise has no public map point or link (they would give the venue away) and does not repeat.
  add constraint events_surprise_hidden check (
    surprise_reveal_hours is null or (meeting_lat is null and link_url is null and series_id is null));

comment on column public.events.surprise_reveal_hours is
  'Set for a surprise event: the venue (event_venues) opens to those going this many hours before the start; location is the hint.';
comment on column public.events.venue_revealed_at is 'When the reveal notification went out; kept by the reveal job.';

create index events_surprise_reveal_idx on public.events (starts_at)
  where surprise_reveal_hours is not null and venue_revealed_at is null and canceled_at is null;

create function private.events_surprise_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
begin
  if tg_op = 'INSERT' then
    new.venue_revealed_at := null;
    return new;
  end if;
  if new.venue_revealed_at is distinct from old.venue_revealed_at and actor is not null then
    perform private.raise_event_rule('event_immutable');
  end if;
  if new.surprise_reveal_hours is distinct from old.surprise_reveal_hours then
    if not private.has_group_permission(old.group_id, 'events.manage') then
      perform private.raise_event_rule('event_forbidden');
    end if;
    if old.canceled_at is not null or old.starts_at <= now() then
      perform private.raise_event_rule('event_closed');
    end if;
    -- Turning the surprise off makes the location public; a new surprise is announced again.
    if new.surprise_reveal_hours is null then
      new.venue_revealed_at := null;
    end if;
  end if;
  return new;
end;
$$;

create trigger events_surprise_guard
  before insert or update on public.events
  for each row execute function private.events_surprise_guard();

-- ---------------------------------------------------------------------------
-- event_venues (owner: events)
-- ---------------------------------------------------------------------------
create table public.event_venues (
  event_id    uuid primary key references public.events (id) on delete cascade,
  location    text not null check (char_length(location) between 2 and 200),
  meeting_lat double precision check (meeting_lat between -90 and 90),
  meeting_lng double precision check (meeting_lng between -180 and 180),
  updated_at  timestamptz not null default now(),
  constraint event_venues_meeting_point_pair check ((meeting_lat is null) = (meeting_lng is null))
);

comment on table public.event_venues is
  'owner: events. The hidden venue of a surprise event; read only through private.event_venue, written by the backend.';

alter table public.event_venues enable row level security;
revoke all on table public.event_venues from anon, authenticated;

create function private.event_venues_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  e public.events;
begin
  select * into e from public.events where id = coalesce(new.event_id, old.event_id);
  if tg_op = 'DELETE' then
    if e.id is null then
      return old;
    end if;
    if not private.has_group_permission(e.group_id, 'events.manage') then
      perform private.raise_event_rule('event_forbidden');
    end if;
    return old;
  end if;
  if new.event_id is distinct from coalesce(old.event_id, new.event_id) then
    perform private.raise_event_rule('event_immutable');
  end if;
  if e.surprise_reveal_hours is null then
    perform private.raise_event_rule('event_not_surprise');
  end if;
  if not private.has_group_permission(e.group_id, 'events.manage') then
    perform private.raise_event_rule('event_forbidden');
  end if;
  if e.canceled_at is not null or e.starts_at <= now() then
    perform private.raise_event_rule('event_closed');
  end if;
  new.location := btrim(new.location);
  new.updated_at := now();
  return new;
end;
$$;

create trigger event_venues_guard
  before insert or update or delete on public.event_venues
  for each row execute function private.event_venues_guard();

-- A venue changed after the reveal is announced to those going, like any change of place.
create function private.event_venues_after_update()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  person uuid;
begin
  if (new.location, new.meeting_lat, new.meeting_lng) is not distinct from (old.location, old.meeting_lat, old.meeting_lng) then
    return null;
  end if;
  if exists (select 1 from public.events e where e.id = new.event_id and e.venue_revealed_at is not null) then
    for person in
      select a.user_id from public.event_attendees a
      where a.event_id = new.event_id and a.status = 'going' and private.wants_notification(a.user_id, 'event_updated')
    loop
      perform private.notify_event(person, new.event_id, 'event_updated');
    end loop;
  end if;
  return null;
end;
$$;

revoke all on function private.event_venues_after_update() from public;

create trigger event_venues_after_update
  after update on public.event_venues
  for each row execute function private.event_venues_after_update();

-- ---------------------------------------------------------------------------
-- Who sees the venue
-- ---------------------------------------------------------------------------
create function private.event_reveal_at(e public.events)
returns timestamptz
language sql
immutable
set search_path = ''
as $$
  select e.starts_at - make_interval(hours => e.surprise_reveal_hours);
$$;

-- The venue for the viewer, or null: event managers and platform staff always, those going from the reveal time on.
create function private.event_venue(e public.events)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'location', v.location,
    'meeting', case when v.meeting_lat is null then null else jsonb_build_object('lat', v.meeting_lat, 'lng', v.meeting_lng) end)
  from public.event_venues v
  where v.event_id = e.id
    and (private.has_group_permission(e.group_id, 'events.manage')
         or private.is_platform_staff()
         or (now() >= private.event_reveal_at(e)
             and exists (select 1 from public.event_attendees a
                         where a.event_id = e.id and a.user_id = (select auth.uid()) and a.status = 'going')));
$$;

revoke all on function private.event_venue(public.events) from public;
revoke all on function private.event_reveal_at(public.events) from public;

-- The event card (0052) with the surprise: when the venue opens, the group's province and, for the viewer, the venue.
create or replace function private.event_card(e public.events)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'id', e.id,
    'group', jsonb_build_object('id', g.id, 'handle', g.handle, 'name', g.name, 'logo_path', g.logo_path),
    'category', jsonb_build_object('slug', c.slug, 'name', c.name),
    'title', e.title,
    'description', e.description,
    'starts_at', e.starts_at,
    'ends_at', e.ends_at,
    'location', e.location,
    'meeting', case when e.meeting_lat is null then null
                    else jsonb_build_object('lat', e.meeting_lat, 'lng', e.meeting_lng) end,
    'surprise', case when e.surprise_reveal_hours is null then null else jsonb_build_object(
                  'reveal_hours', e.surprise_reveal_hours,
                  'reveal_at', private.event_reveal_at(e),
                  'province', (select p.name from public.provinces p where p.id = g.province),
                  'venue', private.event_venue(e)) end,
    'link_url', e.link_url,
    'capacity', e.capacity,
    'fee_amount', e.fee_amount,
    'fee_currency', e.fee_currency,
    'fee_note', e.fee_note,
    'cover_path', e.cover_path,
    'requirements', e.requirements,
    'equipment', to_jsonb(e.equipment),
    'approval_required', e.approval_required,
    'going_count', e.going_count,
    'waitlist_count', e.waitlist_count,
    'canceled_at', e.canceled_at,
    'cancel_reason', e.cancel_reason,
    'series', (select jsonb_build_object('id', s.id, 'weeks', s.interval_weeks, 'until', s.until, 'active', s.stopped_at is null)
               from public.event_series s where s.id = e.series_id),
    'rating_avg', (select round(avg(r.rating), 1) from public.event_reviews r where r.event_id = e.id),
    'rating_count', (select count(*) from public.event_reviews r where r.event_id = e.id),
    'posts_count', (select count(*) from public.posts p where p.event_id = e.id and p.removed_at is null),
    'my_status', (select a.status from public.event_attendees a where a.event_id = e.id and a.user_id = (select auth.uid())),
    'my_place', (select count(*) + 1 from public.event_attendees w, public.event_attendees me
                 where me.event_id = e.id and me.user_id = (select auth.uid()) and me.status = 'waitlisted'
                   and w.event_id = e.id and w.status = 'waitlisted' and (w.created_at, w.user_id) < (me.created_at, me.user_id))
  )
  from public.groups g
  join public.categories c on c.slug = g.category_slug
  where g.id = e.group_id;
$$;

-- ---------------------------------------------------------------------------
-- The reveal: run by the backend's event job with the reminders
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
                  'event_venue_revealed'));

create function private.reveal_event_venues()
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  e public.events;
  person uuid;
  sent int := 0;
begin
  for e in
    select * from public.events
    where surprise_reveal_hours is not null and venue_revealed_at is null and canceled_at is null
      and starts_at > now() and private.event_reveal_at(events) <= now()
    for update skip locked
  loop
    for person in select a.user_id from public.event_attendees a where a.event_id = e.id and a.status = 'going' loop
      perform private.notify_event(person, e.id, 'event_venue_revealed');
      sent := sent + 1;
    end loop;
    update public.events set venue_revealed_at = now() where id = e.id;
  end loop;
  return sent;
end;
$$;

revoke all on function private.reveal_event_venues() from public;
grant execute on function private.reveal_event_venues() to service_role;

-- ---------------------------------------------------------------------------
-- The map (0055): a surprise shows at its group's province center until it starts
-- ---------------------------------------------------------------------------
create or replace function private.map_items(south double precision, west double precision, north double precision,
                                             east double precision, category text default null,
                                             starts_before timestamptz default null)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'groups', coalesce((
      select jsonb_agg(item order by members desc, id)
      from (
        select g.id, g.member_count as members, jsonb_build_object(
          'id', g.id, 'handle', g.handle, 'name', g.name, 'logo_path', g.logo_path, 'member_count', g.member_count,
          'category', jsonb_build_object('slug', c.slug, 'name', c.name),
          'province', p.id, 'lat', p.lat, 'lng', p.lng) as item
        from public.groups g
        join public.provinces p on p.id = g.province
        join public.categories c on c.slug = g.category_slug
        where g.status = 'active'
          and p.lat between map_items.south and map_items.north and p.lng between map_items.west and map_items.east
          and (map_items.category is null or g.category_slug = map_items.category)
          and map_items.starts_before is null
        order by g.member_count desc, g.id
        limit 200
      ) found), '[]'::jsonb),
    'events', coalesce((
      select jsonb_agg(item order by starts, id)
      from (
        select e.id, e.starts_at as starts, jsonb_build_object(
          'id', e.id, 'title', e.title, 'starts_at', e.starts_at, 'location', e.location,
          'going_count', e.going_count, 'capacity', e.capacity,
          'lat', coalesce(e.meeting_lat, p.lat), 'lng', coalesce(e.meeting_lng, p.lng),
          'surprise', e.surprise_reveal_hours is not null,
          'group', jsonb_build_object('id', g.id, 'handle', g.handle, 'name', g.name, 'logo_path', g.logo_path),
          'category', jsonb_build_object('slug', c.slug, 'name', c.name)) as item
        from public.events e
        join public.groups g on g.id = e.group_id
        join public.categories c on c.slug = g.category_slug
        left join public.provinces p on p.id = g.province and e.surprise_reveal_hours is not null
        where g.status = 'active' and e.canceled_at is null and e.starts_at > now()
          and coalesce(e.meeting_lat, p.lat) is not null
          and coalesce(e.meeting_lat, p.lat) between map_items.south and map_items.north
          and coalesce(e.meeting_lng, p.lng) between map_items.west and map_items.east
          and (map_items.category is null or g.category_slug = map_items.category)
          and (map_items.starts_before is null or e.starts_at < map_items.starts_before)
        order by e.starts_at, e.id
        limit 200
      ) found), '[]'::jsonb)
  );
$$;
