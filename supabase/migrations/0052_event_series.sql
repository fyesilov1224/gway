-- 0052: recurring events — a series keeps the next 4 weeks of dates open; each date is its own event and counts
-- against the month it is opened in (docs/ARCHITECTURE.md §3d, Tekrarlayan organizasyon; user decision 2026-10-29).

-- ---------------------------------------------------------------------------
-- Table (owner: events; the backend and the series job write)
-- ---------------------------------------------------------------------------
create table public.event_series (
  id               uuid primary key default gen_random_uuid(),
  group_id         uuid not null references public.groups (id) on delete cascade,
  created_by       uuid references public.profiles (id) on delete set null,
  interval_weeks   smallint not null check (interval_weeks in (1, 2)),
  until            date,
  stopped_at       timestamptz,
  stopped_by       uuid references public.profiles (id) on delete set null,
  limit_notice_for timestamptz,
  created_at       timestamptz not null default now()
);

comment on table public.event_series is
  'owner: events. A repeat rule; its dates are events (series_id). limit_notice_for: the date the owner was last told the monthly limit stopped.';

create index event_series_group_idx on public.event_series (group_id);
create index event_series_active_idx on public.event_series (id) where stopped_at is null;

alter table public.events add column series_id uuid references public.event_series (id) on delete set null;

create index events_series_idx on public.events (series_id, starts_at desc) where series_id is not null;

alter table public.event_series enable row level security;
revoke all on public.event_series from anon, authenticated;
grant select on public.event_series to anon, authenticated;

create policy event_series_select_visible on public.event_series for select to anon, authenticated
  using (private.is_group_visible(group_id));

-- ---------------------------------------------------------------------------
-- Guards
-- ---------------------------------------------------------------------------
create function private.event_series_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
begin
  if tg_op = 'DELETE' then
    if exists (select 1 from public.groups g where g.id = old.group_id) then
      perform private.raise_event_rule('event_delete_forbidden');
    end if;
    return old;
  end if;

  if tg_op = 'INSERT' then
    if actor is null or actor is distinct from new.created_by or not private.has_group_permission(new.group_id, 'events.manage') then
      perform private.raise_event_rule('event_forbidden');
    end if;
    if new.until is not null and (new.until < (now() at time zone 'Europe/Istanbul')::date
                                  or new.until > (now() at time zone 'Europe/Istanbul')::date + 366) then
      perform private.raise_event_rule('event_time_invalid');
    end if;
    new.stopped_at := null;
    new.stopped_by := null;
    new.limit_notice_for := null;
    new.created_at := now();
    return new;
  end if;

  if (new.id, new.group_id, new.interval_weeks, new.until, new.created_at)
     is distinct from (old.id, old.group_id, old.interval_weeks, old.until, old.created_at)
     or (new.created_by is distinct from old.created_by and new.created_by is not null) then
    perform private.raise_event_rule('event_immutable');
  end if;
  if new.stopped_at is distinct from old.stopped_at or new.stopped_by is distinct from old.stopped_by then
    if new.stopped_by is null and old.stopped_by is not null and new.stopped_at is not distinct from old.stopped_at then
      return new; -- the stopper's account went away
    end if;
    if old.stopped_at is not null or new.stopped_at is null then
      perform private.raise_event_rule('event_series_stopped');
    end if;
    -- The series job stops it without an actor (until passed, owner lost the permission).
    if actor is not null and (new.stopped_by is distinct from actor or not (
         private.has_group_permission(new.group_id, 'events.manage') or private.is_platform_staff(array['admin', 'moderator']))) then
      perform private.raise_event_rule('event_forbidden');
    end if;
    new.stopped_at := now();
  end if;
  return new;
end;
$$;

create trigger event_series_guard
  before insert or update or delete on public.event_series
  for each row execute function private.event_series_guard();

-- A date joins a running series of its own group and never moves to another.
create function private.events_series_check()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'UPDATE' then
    if new.series_id is distinct from old.series_id and pg_trigger_depth() = 1 then
      perform private.raise_event_rule('event_immutable');
    end if;
    return new;
  end if;
  if new.series_id is not null and not exists (
    select 1 from public.event_series s where s.id = new.series_id and s.group_id = new.group_id and s.stopped_at is null
  ) then
    perform private.raise_event_rule('event_series_stopped');
  end if;
  return new;
end;
$$;

create trigger events_series_check
  before insert or update of series_id on public.events
  for each row execute function private.events_series_check();

-- ---------------------------------------------------------------------------
-- The series job: opens the dates of the next 4 weeks
-- ---------------------------------------------------------------------------
create function private.extend_event_series(target_series uuid default null)
returns int
language plpgsql
security definer
set search_path = ''
as $$
declare
  s public.event_series;
  latest public.events;
  next_start timestamptz;
  step interval;
  opened int := 0;
  -- The caller's actor (the backend starting a series), given back at the end.
  caller text := current_setting('request.jwt.claims', true);
begin
  for s in
    select x.* from public.event_series x join public.groups g on g.id = x.group_id
    where x.stopped_at is null and g.status = 'active' and (target_series is null or x.id = target_series)
    order by x.created_at
    for update of x skip locked
  loop
    step := make_interval(weeks => s.interval_weeks);
    loop
      select * into latest from public.events where series_id = s.id order by starts_at desc limit 1;
      exit when latest.id is null;
      next_start := ((latest.starts_at at time zone 'Europe/Istanbul') + step) at time zone 'Europe/Istanbul';
      exit when next_start > now() + interval '28 days';

      perform set_config('request.jwt.claims', '', true);
      if s.until is not null and (next_start at time zone 'Europe/Istanbul')::date > s.until then
        update public.event_series set stopped_at = now() where id = s.id;
        exit;
      end if;
      if s.created_by is null then
        update public.event_series set stopped_at = now() where id = s.id;
        exit;
      end if;

      -- The dates are opened in the owner's name, so the event rules apply to them as to any other.
      perform set_config('request.jwt.claims', json_build_object('sub', s.created_by, 'role', 'authenticated')::text, true);
      if not private.has_group_permission(s.group_id, 'events.manage') then
        perform set_config('request.jwt.claims', '', true);
        update public.event_series set stopped_at = now() where id = s.id;
        exit;
      end if;
      if private.group_events_left(s.group_id) <= 0 then
        perform set_config('request.jwt.claims', '', true);
        if s.limit_notice_for is distinct from next_start then
          update public.event_series set limit_notice_for = next_start where id = s.id;
          if private.is_account_active(s.created_by) then
            insert into public.notifications (recipient_id, actor_id, type, event_id)
            values (s.created_by, s.created_by, 'event_series_limit', latest.id);
          end if;
        end if;
        exit;
      end if;

      insert into public.events (group_id, created_by, title, description, starts_at, ends_at, location, link_url, capacity,
                                 fee_amount, fee_currency, fee_note, cover_path, requirements, equipment, approval_required,
                                 meeting_lat, meeting_lng, series_id)
      values (s.group_id, s.created_by, latest.title, latest.description, next_start,
              case when latest.ends_at is null then null
                   else ((latest.ends_at at time zone 'Europe/Istanbul') + step) at time zone 'Europe/Istanbul' end,
              latest.location, latest.link_url, latest.capacity, latest.fee_amount, latest.fee_currency, latest.fee_note,
              latest.cover_path, latest.requirements, latest.equipment, latest.approval_required,
              latest.meeting_lat, latest.meeting_lng, s.id);
      opened := opened + 1;
    end loop;
  end loop;
  perform set_config('request.jwt.claims', coalesce(caller, ''), true);
  return opened;
end;
$$;

revoke all on function private.extend_event_series(uuid) from public;
grant execute on function private.extend_event_series(uuid) to service_role;

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
                  'league_result', 'event_series_limit'));

-- ---------------------------------------------------------------------------
-- Event cards say whether a date belongs to a running series (as in 0023, plus series)
-- ---------------------------------------------------------------------------
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
