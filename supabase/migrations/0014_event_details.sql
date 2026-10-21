-- 0014_event_details
-- Phase 8: event requirements and equipment, approval-based attendance
-- (requested → going / waitlisted), the motorcycle, camping and chess
-- categories. Rules: docs/ARCHITECTURE.md §3d (Faz 8 additions).

-- ---------------------------------------------------------------------------
-- Categories (core)
-- ---------------------------------------------------------------------------
insert into public.categories (slug, name, sort_order) values
  ('motorcycle', 'Motosiklet', 45),
  ('camping',    'Kamp',       55),
  ('chess',      'Satranç',   115);

-- ---------------------------------------------------------------------------
-- events, event_attendees (events)
-- ---------------------------------------------------------------------------
alter table public.events
  add column requirements text not null default '' check (char_length(requirements) <= 500),
  add column equipment text[] not null default '{}' check (cardinality(equipment) <= 10),
  add column approval_required boolean not null default false;

comment on column public.events.approval_required is
  'Joining sends a request (status requested); an events.manage holder approves or declines it.';

alter table public.event_attendees drop constraint event_attendees_status_check;
alter table public.event_attendees add constraint event_attendees_status_check
  check (status in ('requested', 'going', 'waitlisted'));

create index event_attendees_requested_idx on public.event_attendees (event_id, created_at) where status = 'requested';

-- Trims the equipment list; each item 1–60 characters.
create function private.clean_equipment(items text[])
returns text[]
language plpgsql
immutable
set search_path = ''
as $$
declare
  cleaned text[] := '{}';
  item text;
begin
  foreach item in array coalesce(items, '{}') loop
    item := btrim(item);
    if char_length(item) not between 1 and 60 then
      raise exception 'equipment_invalid' using errcode = 'P0001';
    end if;
    cleaned := cleaned || item;
  end loop;
  return cleaned;
end;
$$;

-- Events: as in 0010, with the Phase 8 fields among the edited ones.
create or replace function private.events_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
begin
  if tg_op = 'DELETE' then
    if not exists (select 1 from public.groups g where g.id = old.group_id) then
      return old;
    end if;
    perform private.raise_event_rule('event_delete_forbidden');
  end if;

  if tg_op = 'INSERT' then
    if actor is null or actor is distinct from new.created_by or not private.has_group_permission(new.group_id, 'events.manage') then
      perform private.raise_event_rule('event_forbidden');
    end if;
    if new.starts_at < now() + interval '14 minutes' or new.starts_at > now() + interval '1 year' then
      perform private.raise_event_rule('event_time_invalid');
    end if;
    -- Locking the group serializes concurrent creations against the monthly limit.
    perform 1 from public.groups where id = new.group_id for update;
    if private.group_events_left(new.group_id) <= 0 then
      perform private.raise_event_rule('monthly_limit_reached');
    end if;
    new.title := btrim(new.title);
    new.location := btrim(new.location);
    new.requirements := btrim(new.requirements);
    new.equipment := private.clean_equipment(new.equipment);
    new.going_count := 0;
    new.waitlist_count := 0;
    new.canceled_at := null;
    new.cancel_reason := null;
    new.reminded_day_at := null;
    new.reminded_hour_at := null;
    new.created_at := now();
    new.updated_at := now();
    return new;
  end if;

  if pg_trigger_depth() > 1 then
    return new;
  end if;
  if (new.id, new.group_id, new.created_at) is distinct from (old.id, old.group_id, old.created_at)
     or (new.created_by is distinct from old.created_by and new.created_by is not null)
     or (new.going_count, new.waitlist_count) is distinct from (old.going_count, old.waitlist_count) then
    perform private.raise_event_rule('event_immutable');
  end if;
  if (new.reminded_day_at, new.reminded_hour_at) is distinct from (old.reminded_day_at, old.reminded_hour_at) and actor is not null then
    perform private.raise_event_rule('event_immutable');
  end if;

  if new.canceled_at is distinct from old.canceled_at or new.cancel_reason is distinct from old.cancel_reason then
    if old.canceled_at is not null or new.canceled_at is null then
      perform private.raise_event_rule('event_already_canceled');
    end if;
    if not (private.has_group_permission(old.group_id, 'events.manage') or private.is_platform_staff(array['admin', 'moderator'])) then
      perform private.raise_event_rule('event_forbidden');
    end if;
    new.canceled_at := now();
  end if;

  if (new.title, new.description, new.starts_at, new.ends_at, new.location, new.link_url, new.capacity,
      new.fee_amount, new.fee_currency, new.fee_note, new.cover_path, new.requirements, new.equipment, new.approval_required)
     is distinct from
     (old.title, old.description, old.starts_at, old.ends_at, old.location, old.link_url, old.capacity,
      old.fee_amount, old.fee_currency, old.fee_note, old.cover_path, old.requirements, old.equipment, old.approval_required) then
    if not private.has_group_permission(old.group_id, 'events.manage') then
      perform private.raise_event_rule('event_forbidden');
    end if;
    if old.canceled_at is not null or old.starts_at <= now() then
      perform private.raise_event_rule('event_closed');
    end if;
    if new.starts_at is distinct from old.starts_at
       and (new.starts_at < now() + interval '14 minutes' or new.starts_at > now() + interval '1 year') then
      perform private.raise_event_rule('event_time_invalid');
    end if;
    if new.capacity is not null and new.capacity < old.going_count then
      perform private.raise_event_rule('capacity_below_going');
    end if;
    new.title := btrim(new.title);
    new.location := btrim(new.location);
    new.requirements := btrim(new.requirements);
    new.equipment := private.clean_equipment(new.equipment);
    new.updated_at := now();
  end if;
  return new;
end;
$$;

-- Attendance: the joiner joins a future event of their group; the trigger picks requested
-- (approval events, unless the joiner manages events), going or waitlisted. An events.manage
-- holder turns a request into going or waitlisted, or deletes it (declines).
create or replace function private.event_attendees_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
  e public.events;
begin
  if tg_op = 'INSERT' then
    select * into e from public.events where id = new.event_id for update;
    if actor is null or actor is distinct from new.user_id or not private.is_account_active(actor)
       or not exists (select 1 from public.group_members m where m.group_id = e.group_id and m.user_id = actor) then
      perform private.raise_event_rule('attendance_forbidden');
    end if;
    if e.canceled_at is not null or e.starts_at <= now() then
      perform private.raise_event_rule('event_closed');
    end if;
    if e.approval_required and not private.has_group_permission(e.group_id, 'events.manage') then
      new.status := 'requested';
    elsif e.capacity is null or e.going_count < e.capacity then
      new.status := 'going';
    else
      new.status := 'waitlisted';
    end if;
    new.created_at := now();
    return new;
  end if;
  if pg_trigger_depth() > 1 then
    return coalesce(new, old);
  end if;
  if tg_op = 'DELETE' then
    if actor = old.user_id
       or (old.status = 'requested' and private.has_group_permission((select ev.group_id from public.events ev where ev.id = old.event_id), 'events.manage')) then
      return old;
    end if;
    perform private.raise_event_rule('attendance_forbidden');
  end if;

  -- Approval: requested → going or waitlisted, decided here by the free seats.
  select * into e from public.events where id = old.event_id for update;
  if old.status <> 'requested' or new.status = 'requested' or (new.event_id, new.user_id) is distinct from (old.event_id, old.user_id)
     or not private.has_group_permission(e.group_id, 'events.manage') then
    perform private.raise_event_rule('attendance_forbidden');
  end if;
  if e.canceled_at is not null or e.starts_at <= now() then
    perform private.raise_event_rule('event_closed');
  end if;
  if e.capacity is null or e.going_count < e.capacity then
    new.status := 'going';
  else
    new.status := 'waitlisted';
  end if;
  -- The waitlist order starts at the approval.
  new.created_at := now();
  return new;
end;
$$;

-- The requester hears the outcome of their request.
create function private.event_attendees_notify()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'UPDATE' then
    perform private.notify_event(new.user_id, new.event_id, 'event_approved');
  elsif (select auth.uid()) is distinct from old.user_id and exists (select 1 from public.events e where e.id = old.event_id) then
    perform private.notify_event(old.user_id, old.event_id, 'event_declined');
  end if;
  return null;
end;
$$;

revoke all on function private.event_attendees_notify() from public;

create trigger event_attendees_notify_approved
  after update of status on public.event_attendees
  for each row when (old.status = 'requested' and new.status <> 'requested')
  execute function private.event_attendees_notify();
create trigger event_attendees_notify_declined
  after delete on public.event_attendees
  for each row when (old.status = 'requested' and pg_trigger_depth() < 1)
  execute function private.event_attendees_notify();

-- ---------------------------------------------------------------------------
-- Notifications (notifications owns the table)
-- ---------------------------------------------------------------------------
alter table public.notifications drop constraint notifications_type_check;
alter table public.notifications add constraint notifications_type_check
  check (type in ('like', 'comment', 'reply', 'comment_like', 'mention', 'follow', 'follow_request', 'follow_accepted',
                  'live_started', 'event_promoted', 'event_updated', 'event_canceled', 'event_reminder',
                  'case_vote', 'sanction_applied', 'appeal_submitted', 'appeal_decided',
                  'event_approved', 'event_declined'));

-- ---------------------------------------------------------------------------
-- RPCs
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
    'my_status', (select a.status from public.event_attendees a where a.event_id = e.id and a.user_id = (select auth.uid())),
    'my_place', (select count(*) + 1 from public.event_attendees w, public.event_attendees me
                 where me.event_id = e.id and me.user_id = (select auth.uid()) and me.status = 'waitlisted'
                   and w.event_id = e.id and w.status = 'waitlisted' and (w.created_at, w.user_id) < (me.created_at, me.user_id))
  )
  from public.groups g
  join public.categories c on c.slug = g.category_slug
  where g.id = e.group_id;
$$;

-- Managers also get the pending requests (oldest first).
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
                                          'avatar_path', p.avatar_path) order by a.created_at)
      from (select * from public.event_attendees where event_id = e.id and status = 'going' order by created_at limit 24) a
      join public.profiles p on p.id = a.user_id), '[]') end,
    'requests', case when private.has_group_permission(e.group_id, 'events.manage') then coalesce((
      select jsonb_agg(jsonb_build_object('id', p.id, 'username', p.username, 'display_name', p.display_name,
                                          'avatar_path', p.avatar_path) order by a.created_at)
      from (select * from public.event_attendees where event_id = e.id and status = 'requested' order by created_at limit 100) a
      join public.profiles p on p.id = a.user_id), '[]') end
  )
  from public.events e where e.id = target_event;
$$;
