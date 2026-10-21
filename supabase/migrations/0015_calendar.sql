-- 0015_calendar
-- Phase 9: calendar reads over events, conflicts on the event page, and the
-- user's notification preferences for event reminders and changes.
-- Rules: docs/ARCHITECTURE.md §3d (Takvim) and §3c (Bildirimler, Tercihler).

-- ---------------------------------------------------------------------------
-- notification_preferences
-- owner: notifications
-- ---------------------------------------------------------------------------
create table public.notification_preferences (
  user_id             uuid primary key references public.profiles (id) on delete cascade,
  event_reminder_day  boolean not null default true,
  event_reminder_hour boolean not null default true,
  event_updates       boolean not null default true,
  updated_at          timestamptz not null default now()
);

comment on table public.notification_preferences is
  'owner: notifications. Opt-outs; no row means every kind is on. The user''s own write.';

alter table public.notification_preferences enable row level security;
revoke all on public.notification_preferences from anon, authenticated;
grant select, insert (user_id, event_reminder_day, event_reminder_hour, event_updates),
  update (event_reminder_day, event_reminder_hour, event_updates) on public.notification_preferences to authenticated;

create policy notification_preferences_select_own on public.notification_preferences for select to authenticated
  using (user_id = (select auth.uid()));
create policy notification_preferences_insert_own on public.notification_preferences for insert to authenticated
  with check (user_id = (select auth.uid()));
create policy notification_preferences_update_own on public.notification_preferences for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

create function private.notification_preferences_touch()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create trigger notification_preferences_touch
  before insert or update on public.notification_preferences
  for each row execute function private.notification_preferences_touch();

-- Whether uid still wants this kind; kinds without a preference are always wanted.
create function private.wants_notification(uid uuid, kind text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce((
    select case kind
             when 'event_reminder_day' then p.event_reminder_day
             when 'event_reminder_hour' then p.event_reminder_hour
             when 'event_updated' then p.event_updates
             when 'event_canceled' then p.event_updates
             else true
           end
    from public.notification_preferences p where p.user_id = uid
  ), true);
$$;

revoke all on function private.wants_notification(uuid, text) from public;

-- ---------------------------------------------------------------------------
-- Event notifications respect the preferences (events writes them)
-- ---------------------------------------------------------------------------
create or replace function private.notify_event(recipient uuid, target_event uuid, kind text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not private.is_account_active(recipient) or not private.wants_notification(recipient, kind) then
    return;
  end if;
  insert into public.notifications (recipient_id, actor_id, type, event_id)
  select recipient, coalesce(e.created_by, g.owner_id), kind, e.id
  from public.events e join public.groups g on g.id = e.group_id
  where e.id = target_event;
end;
$$;

create or replace function private.send_event_reminders()
returns int
language plpgsql
security definer
set search_path = ''
as $$
declare
  e public.events;
  person uuid;
  within_hour boolean;
  preference text;
  sent int := 0;
begin
  for e in
    select * from public.events
    where canceled_at is null and starts_at > now()
      and ((reminded_hour_at is null and starts_at <= now() + interval '1 hour')
        or (reminded_day_at is null and starts_at > now() + interval '1 hour' and starts_at <= now() + interval '24 hours'))
    for update skip locked
  loop
    within_hour := e.starts_at <= now() + interval '1 hour';
    if within_hour then
      preference := 'event_reminder_hour';
    else
      preference := 'event_reminder_day';
    end if;
    for person in
      select a.user_id from public.event_attendees a
      where a.event_id = e.id and a.status = 'going'
        and private.wants_notification(a.user_id, preference)
    loop
      perform private.notify_event(person, e.id, 'event_reminder');
      sent := sent + 1;
    end loop;
    if within_hour then
      update public.events set reminded_hour_at = now(), reminded_day_at = coalesce(reminded_day_at, now()) where id = e.id;
    else
      update public.events set reminded_day_at = now() where id = e.id;
    end if;
  end loop;
  return sent;
end;
$$;

-- ---------------------------------------------------------------------------
-- Calendar
-- ---------------------------------------------------------------------------

-- The span an event occupies; without an end, two hours (as in the calendar file).
create function private.event_span(e public.events)
returns tstzrange
language sql
immutable
set search_path = ''
as $$
  select tstzrange(e.starts_at, coalesce(e.ends_at, e.starts_at + interval '2 hours'));
$$;

-- Events starting in [range_start, range_end): a group's, or the caller's own (attending, waiting
-- or requested) plus, with include_groups, every event of the groups they belong to.
create function private.calendar_events(range_start timestamptz, range_end timestamptz, target_group uuid, include_groups boolean)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select case when range_end <= range_start or range_end - range_start > interval '62 days' then '[]'::jsonb else coalesce((
    select jsonb_agg(private.event_card(e) order by e.starts_at)
    from (
      select e0.* from public.events e0
      where e0.starts_at >= range_start and e0.starts_at < range_end
        and case
              when target_group is not null then e0.group_id = target_group and private.is_group_visible(e0.group_id)
              else exists (select 1 from public.event_attendees a where a.event_id = e0.id and a.user_id = (select auth.uid()))
                or (include_groups and exists (
                      select 1 from public.group_members m
                      join public.groups g on g.id = m.group_id and g.status = 'active'
                      where m.group_id = e0.group_id and m.user_id = (select auth.uid())))
            end
      order by e0.starts_at
      limit 500
    ) e
  ), '[]'::jsonb) end;
$$;

create function public.calendar_events(range_start timestamptz, range_end timestamptz, target_group uuid default null,
                                       include_groups boolean default false)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.calendar_events(range_start, range_end, target_group, include_groups);
$$;

revoke all on function private.event_span(public.events), private.calendar_events(timestamptz, timestamptz, uuid, boolean) from public;
grant execute on function private.event_span(public.events) to anon, authenticated, service_role;
grant execute on function private.calendar_events(timestamptz, timestamptz, uuid, boolean) to anon, authenticated;
revoke all on function public.calendar_events(timestamptz, timestamptz, uuid, boolean) from public;
grant execute on function public.calendar_events(timestamptz, timestamptz, uuid, boolean) to anon, authenticated;

-- The event page also lists the caller's other events at the same time.
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
      join public.profiles p on p.id = a.user_id), '[]') end,
    'conflicts', coalesce((
      select jsonb_agg(jsonb_build_object('id', o.id, 'title', o.title, 'starts_at', o.starts_at) order by o.starts_at)
      from public.event_attendees a
      join public.events o on o.id = a.event_id
      where a.user_id = (select auth.uid()) and o.id <> e.id and o.canceled_at is null
        and private.event_span(o) && private.event_span(e)
    ), '[]')
  )
  from public.events e where e.id = target_event;
$$;
