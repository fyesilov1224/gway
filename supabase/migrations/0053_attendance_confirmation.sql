-- 0053: "Geliyor musun?" — a going attendee confirms their seat in the last day; nobody is removed for not answering
-- (docs/ARCHITECTURE.md §3d; user decision 2026-10-29).

alter table public.event_attendees add column confirmed_at timestamptz;

comment on column public.event_attendees.confirmed_at is 'Set by the attendee ("Evet, geliyorum"); managers see it.';

-- As in 0019, plus the confirmation.
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
    new.no_show_at := null;
    new.no_show_by := null;
    new.confirmed_at := null;
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

  select * into e from public.events where id = old.event_id for update;

  -- Roll call: a going attendee is marked as a no-show or cleared.
  if new.no_show_at is distinct from old.no_show_at then
    if (new.event_id, new.user_id, new.status, new.created_at) is distinct from (old.event_id, old.user_id, old.status, old.created_at)
       or old.status <> 'going' or not private.has_group_permission(e.group_id, 'events.manage') then
      perform private.raise_event_rule('attendance_forbidden');
    end if;
    if not private.is_roll_open(e) then
      perform private.raise_event_rule('roll_closed');
    end if;
    if new.no_show_at is null then
      new.no_show_by := null;
    else
      new.no_show_at := now();
      new.no_show_by := actor;
    end if;
    return new;
  end if;

  -- "Geliyor musun?": a going attendee confirms their own seat once, before the start (§3d).
  if new.confirmed_at is distinct from old.confirmed_at then
    if (new.event_id, new.user_id, new.status, new.created_at, new.no_show_at)
         is distinct from (old.event_id, old.user_id, old.status, old.created_at, old.no_show_at)
       or old.status <> 'going' or old.confirmed_at is not null or new.confirmed_at is null or actor is distinct from old.user_id then
      perform private.raise_event_rule('attendance_forbidden');
    end if;
    if e.canceled_at is not null or e.starts_at <= now() then
      perform private.raise_event_rule('event_closed');
    end if;
    new.confirmed_at := now();
    return new;
  end if;

  -- Approval: requested → going or waitlisted, decided here by the free seats.
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
  new.confirmed_at := null;
  return new;
end;
$$;

-- The attendee's own write (docs/ARCHITECTURE.md §2): true when the seat is now confirmed.
create function private.confirm_attendance(target_event uuid)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.event_attendees set confirmed_at = now()
  where event_id = target_event and user_id = (select auth.uid()) and status = 'going' and confirmed_at is null;
  return exists (select 1 from public.event_attendees a
                 where a.event_id = target_event and a.user_id = (select auth.uid()) and a.confirmed_at is not null);
end;
$$;

create function public.confirm_attendance(target_event uuid)
returns boolean
language sql
volatile
security invoker
set search_path = ''
as $$
  select private.confirm_attendance(target_event);
$$;

revoke all on function private.confirm_attendance(uuid), public.confirm_attendance(uuid) from public;
grant execute on function private.confirm_attendance(uuid), public.confirm_attendance(uuid) to authenticated;

-- As in 0019, plus who confirmed (managers) and the viewer's own confirmation.
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
