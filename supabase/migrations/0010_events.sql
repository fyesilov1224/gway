-- 0010_events
-- Phase 5: group events (organizasyon) with capacity and a waitlist, fee
-- information, cover images, reminders, and polls (also attached to events).
-- Rules: docs/ARCHITECTURE.md §3d.
--
-- Events, attendance and polls are written by the C# API (actor in
-- request.jwt.claims; none for the reminder job). Votes are the user's own
-- simple writes (RLS). Triggers re-check the rules, decide going or
-- waitlisted, keep the counters and promote the waitlist.

-- ---------------------------------------------------------------------------
-- Permission: events.manage (owner and Yönetici)
-- ---------------------------------------------------------------------------
insert into public.group_permissions (slug, description) values
  ('events.manage', 'Organizasyon oluşturma, düzenleme ve iptal; anket açma, kapatma ve silme');
insert into public.group_role_permissions (role, permission) values ('admin', 'events.manage');

-- ---------------------------------------------------------------------------
-- events, event_attendees
-- owner: events
-- ---------------------------------------------------------------------------
create table public.events (
  id              uuid primary key default gen_random_uuid(),
  group_id        uuid not null references public.groups (id) on delete cascade,
  created_by      uuid references public.profiles (id) on delete set null,
  title           text not null check (char_length(title) between 3 and 100),
  description     text not null default '' check (char_length(description) <= 2000),
  starts_at       timestamptz not null,
  ends_at         timestamptz,
  location        text not null check (char_length(location) between 2 and 200),
  link_url        text check (link_url is null or (link_url ~ '^https?://' and char_length(link_url) <= 300)),
  capacity        int check (capacity between 1 and 10000),
  fee_amount      int check (fee_amount > 0),
  fee_currency    text check (fee_currency in ('TRY', 'USD', 'EUR')),
  fee_note        text check (char_length(fee_note) <= 200),
  cover_path      text check (cover_path is null or cover_path like group_id::text || '/%'),
  going_count     int not null default 0,
  waitlist_count  int not null default 0,
  canceled_at     timestamptz,
  cancel_reason   text check (char_length(cancel_reason) <= 500),
  reminded_day_at timestamptz,
  reminded_hour_at timestamptz,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  constraint events_end_after_start check (ends_at is null or ends_at > starts_at),
  constraint events_fee_consistent check ((fee_amount is null) = (fee_currency is null)),
  constraint events_cancel_consistent check ((canceled_at is null) = (cancel_reason is null))
);

comment on table public.events is
  'owner: events. Group events; public when the group is visible. Counters and reminder marks are kept by triggers and the reminder job.';

create index events_group_idx on public.events (group_id, starts_at);
create index events_upcoming_idx on public.events (starts_at) where canceled_at is null;
create index events_month_idx on public.events (group_id, created_at);

create table public.event_attendees (
  event_id   uuid not null references public.events (id) on delete cascade,
  user_id    uuid not null references public.profiles (id) on delete cascade,
  status     text not null check (status in ('going', 'waitlisted')),
  created_at timestamptz not null default now(),
  primary key (event_id, user_id)
);

comment on table public.event_attendees is
  'owner: events. Going or waitlisted; the trigger decides which and promotes the waitlist in joining order.';

create index event_attendees_waitlist_idx on public.event_attendees (event_id, created_at) where status = 'waitlisted';
create index event_attendees_user_idx on public.event_attendees (user_id);

-- ---------------------------------------------------------------------------
-- polls, poll_options, poll_votes
-- owner: events
-- ---------------------------------------------------------------------------
create table public.polls (
  id              uuid primary key default gen_random_uuid(),
  group_id        uuid not null references public.groups (id) on delete cascade,
  event_id        uuid references public.events (id) on delete cascade,
  created_by      uuid references public.profiles (id) on delete set null,
  question        text not null check (char_length(question) between 3 and 200),
  allows_multiple boolean not null default false,
  is_anonymous    boolean not null default false,
  closes_at       timestamptz,
  closed_at       timestamptz,
  created_at      timestamptz not null default now()
);

comment on table public.polls is 'owner: events. Group polls, optionally on an event page. Open until closed_at or closes_at.';

create index polls_group_idx on public.polls (group_id, created_at desc);
create index polls_event_idx on public.polls (event_id) where event_id is not null;

create table public.poll_options (
  id       bigint generated always as identity primary key,
  poll_id  uuid not null references public.polls (id) on delete cascade,
  position smallint not null check (position between 0 and 9),
  label    text not null check (char_length(label) between 1 and 80),
  unique (poll_id, position)
);

comment on table public.poll_options is 'owner: events. Two to ten choices of a poll, fixed once created.';

create table public.poll_votes (
  poll_id    uuid not null references public.polls (id) on delete cascade,
  option_id  bigint not null references public.poll_options (id) on delete cascade,
  user_id    uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (option_id, user_id)
);

comment on table public.poll_votes is 'owner: events. Votes; who voted what is hidden on anonymous polls.';

create index poll_votes_poll_user_idx on public.poll_votes (poll_id, user_id);

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

-- Events the group may still create this calendar month (Turkey time); canceled ones count too.
create function private.group_events_left(target_group uuid)
returns int
language sql
stable
security definer
set search_path = ''
as $$
  select greatest((private.group_plan_limits(target_group)).monthly_events - (
    select count(*)::int from public.events e
    where e.group_id = target_group
      and e.created_at >= (date_trunc('month', now() at time zone 'Europe/Istanbul') at time zone 'Europe/Istanbul')
  ), 0);
$$;

create function private.event_group(target_event uuid)
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select group_id from public.events where id = target_event;
$$;

create function private.poll_group(target_poll uuid)
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select group_id from public.polls where id = target_poll;
$$;

create function private.is_poll_open(p public.polls)
returns boolean
language sql
stable
set search_path = ''
as $$
  select p.closed_at is null and (p.closes_at is null or p.closes_at > now());
$$;

-- An event notification; the actor is the creator (or the owner once the creator is gone).
create function private.notify_event(recipient uuid, target_event uuid, kind text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not private.is_account_active(recipient) then
    return;
  end if;
  insert into public.notifications (recipient_id, actor_id, type, event_id)
  select recipient, coalesce(e.created_by, g.owner_id), kind, e.id
  from public.events e join public.groups g on g.id = e.group_id
  where e.id = target_event;
end;
$$;

-- Moves the oldest waitlisted people to going while there is room.
create function private.promote_waitlist(target_event uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  e public.events;
  next_user uuid;
begin
  loop
    select * into e from public.events where id = target_event for update;
    if e.id is null or e.canceled_at is not null or e.starts_at <= now()
       or (e.capacity is not null and e.going_count >= e.capacity) then
      return;
    end if;
    select a.user_id into next_user from public.event_attendees a
    where a.event_id = target_event and a.status = 'waitlisted'
    order by a.created_at, a.user_id limit 1;
    if next_user is null then
      return;
    end if;
    update public.event_attendees set status = 'going' where event_id = target_event and user_id = next_user;
    perform private.notify_event(next_user, target_event, 'event_promoted');
  end loop;
end;
$$;

revoke all on function private.group_events_left(uuid), private.event_group(uuid), private.poll_group(uuid),
  private.is_poll_open(public.polls), private.notify_event(uuid, uuid, text), private.promote_waitlist(uuid) from public;
grant execute on function private.group_events_left(uuid), private.event_group(uuid), private.poll_group(uuid),
  private.is_poll_open(public.polls) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------
alter table public.events enable row level security;
alter table public.event_attendees enable row level security;
alter table public.polls enable row level security;
alter table public.poll_options enable row level security;
alter table public.poll_votes enable row level security;

revoke all on public.events, public.event_attendees, public.polls, public.poll_options, public.poll_votes from anon, authenticated;
grant select on public.events to anon, authenticated;
grant select on public.event_attendees, public.polls, public.poll_options, public.poll_votes to authenticated;
grant insert (poll_id, option_id, user_id), delete on public.poll_votes to authenticated;

create policy events_select_visible on public.events for select to anon, authenticated
  using (private.is_group_visible(group_id));

create policy event_attendees_select_members on public.event_attendees for select to authenticated
  using (
    user_id = (select auth.uid())
    or private.is_group_member(private.event_group(event_id))
    or (select private.is_platform_staff())
  );

create policy polls_select_members on public.polls for select to authenticated
  using (private.is_group_member(group_id) or (select private.is_platform_staff()));

create policy poll_options_select_members on public.poll_options for select to authenticated
  using (private.is_group_member(private.poll_group(poll_id)) or (select private.is_platform_staff()));

create policy poll_votes_select on public.poll_votes for select to authenticated
  using (
    user_id = (select auth.uid())
    or exists (
      select 1 from public.polls p
      where p.id = poll_id and not p.is_anonymous and private.is_group_member(p.group_id)
    )
  );

create policy poll_votes_insert_own on public.poll_votes for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and (select private.is_account_active(auth.uid()))
    and exists (
      select 1 from public.polls p
      where p.id = poll_id and private.is_poll_open(p) and private.is_group_member(p.group_id)
    )
  );

create policy poll_votes_delete_own on public.poll_votes for delete to authenticated
  using (
    user_id = (select auth.uid())
    and exists (select 1 from public.polls p where p.id = poll_id and private.is_poll_open(p))
  );

-- ---------------------------------------------------------------------------
-- Storage: event-images
-- owner: events
-- Public read; events.manage holders write inside <group_id>/.
-- ---------------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types) values
  ('event-images', 'event-images', true, 5242880, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

create policy event_images_select_public
  on storage.objects for select to anon, authenticated
  using (bucket_id = 'event-images');

create policy event_images_insert_manager
  on storage.objects for insert to authenticated
  with check (bucket_id = 'event-images' and private.has_group_permission(private.group_id_from_path(name), 'events.manage'));

create policy event_images_update_manager
  on storage.objects for update to authenticated
  using (bucket_id = 'event-images' and private.has_group_permission(private.group_id_from_path(name), 'events.manage'))
  with check (bucket_id = 'event-images' and private.has_group_permission(private.group_id_from_path(name), 'events.manage'));

create policy event_images_delete_manager
  on storage.objects for delete to authenticated
  using (bucket_id = 'event-images' and private.has_group_permission(private.group_id_from_path(name), 'events.manage'));

-- ---------------------------------------------------------------------------
-- Triggers
-- ---------------------------------------------------------------------------
create function private.raise_event_rule(code text)
returns void
language plpgsql
set search_path = ''
as $$
begin
  raise exception '%', code using errcode = 'P0001';
end;
$$;

-- Events: created and edited by events.manage holders; canceled by them or platform staff.
-- Counters change through the attendee triggers; reminder marks only without an actor (the job).
create function private.events_guard()
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
      new.fee_amount, new.fee_currency, new.fee_note, new.cover_path)
     is distinct from
     (old.title, old.description, old.starts_at, old.ends_at, old.location, old.link_url, old.capacity,
      old.fee_amount, old.fee_currency, old.fee_note, old.cover_path) then
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
    new.updated_at := now();
  end if;
  return new;
end;
$$;

create trigger events_guard
  before insert or update or delete on public.events
  for each row execute function private.events_guard();

-- After an edit or cancellation: tell the people concerned; more room promotes the waitlist.
create function private.events_after_update()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  person uuid;
begin
  if new.canceled_at is not null and old.canceled_at is null then
    for person in select a.user_id from public.event_attendees a where a.event_id = new.id loop
      perform private.notify_event(person, new.id, 'event_canceled');
    end loop;
    return null;
  end if;
  if (new.starts_at, new.location) is distinct from (old.starts_at, old.location) then
    for person in select a.user_id from public.event_attendees a where a.event_id = new.id and a.status = 'going' loop
      perform private.notify_event(person, new.id, 'event_updated');
    end loop;
  end if;
  if new.capacity is distinct from old.capacity then
    perform private.promote_waitlist(new.id);
  end if;
  return null;
end;
$$;

create trigger events_after_update
  after update of canceled_at, starts_at, location, capacity on public.events
  for each row when (pg_trigger_depth() < 2)
  execute function private.events_after_update();

-- Attendance: the joiner (actor) joins a future event of their group; the trigger picks going or waitlisted.
create function private.event_attendees_guard()
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
    new.status := case when e.capacity is null or e.going_count < e.capacity then 'going' else 'waitlisted' end;
    new.created_at := now();
    return new;
  end if;
  if pg_trigger_depth() > 1 then
    return coalesce(new, old);
  end if;
  if tg_op = 'DELETE' and actor = old.user_id then
    return old;
  end if;
  perform private.raise_event_rule('attendance_forbidden');
  return null;
end;
$$;

create trigger event_attendees_guard
  before insert or update or delete on public.event_attendees
  for each row execute function private.event_attendees_guard();

-- Counters, and a freed seat goes to the waitlist.
create function private.event_attendees_count()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op in ('DELETE', 'UPDATE') then
    update public.events set
      going_count = going_count - (old.status = 'going')::int,
      waitlist_count = waitlist_count - (old.status = 'waitlisted')::int
    where id = old.event_id;
  end if;
  if tg_op in ('INSERT', 'UPDATE') then
    update public.events set
      going_count = going_count + (new.status = 'going')::int,
      waitlist_count = waitlist_count + (new.status = 'waitlisted')::int
    where id = new.event_id;
  end if;
  if tg_op = 'DELETE' and old.status = 'going' then
    perform private.promote_waitlist(old.event_id);
  end if;
  return null;
end;
$$;

create trigger event_attendees_count
  after insert or update or delete on public.event_attendees
  for each row execute function private.event_attendees_count();

-- Leaving a group drops the person from its upcoming events.
create function private.group_members_leave_events()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  delete from public.event_attendees a
  using public.events e
  where a.event_id = e.id and e.group_id = old.group_id and a.user_id = old.user_id and e.starts_at > now();
  return null;
end;
$$;

create trigger group_members_leave_events
  after delete on public.group_members
  for each row execute function private.group_members_leave_events();

-- Polls: opened, closed and deleted by events.manage holders.
create function private.polls_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
begin
  if tg_op = 'DELETE' then
    if pg_trigger_depth() > 1 or not exists (select 1 from public.groups g where g.id = old.group_id)
       or private.has_group_permission(old.group_id, 'events.manage') then
      return old;
    end if;
    perform private.raise_event_rule('poll_forbidden');
  end if;
  if tg_op = 'INSERT' then
    if actor is null or actor is distinct from new.created_by or not private.has_group_permission(new.group_id, 'events.manage') then
      perform private.raise_event_rule('poll_forbidden');
    end if;
    if new.event_id is not null and private.event_group(new.event_id) is distinct from new.group_id then
      perform private.raise_event_rule('poll_event_mismatch');
    end if;
    if new.closes_at is not null and (new.closes_at < now() + interval '4 minutes' or new.closes_at > now() + interval '90 days') then
      perform private.raise_event_rule('poll_time_invalid');
    end if;
    new.question := btrim(new.question);
    new.closed_at := null;
    new.created_at := now();
    return new;
  end if;
  if pg_trigger_depth() > 1 and new.created_by is null then
    return new;
  end if;
  if (new.id, new.group_id, new.event_id, new.created_by, new.question, new.allows_multiple, new.is_anonymous, new.closes_at, new.created_at)
     is distinct from
     (old.id, old.group_id, old.event_id, old.created_by, old.question, old.allows_multiple, old.is_anonymous, old.closes_at, old.created_at)
     or old.closed_at is not null or new.closed_at is null then
    perform private.raise_event_rule('poll_immutable');
  end if;
  if not private.has_group_permission(old.group_id, 'events.manage') then
    perform private.raise_event_rule('poll_forbidden');
  end if;
  new.closed_at := now();
  return new;
end;
$$;

create trigger polls_guard
  before insert or update or delete on public.polls
  for each row execute function private.polls_guard();

-- Options are written with their poll and never change.
create function private.poll_options_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    if not private.has_group_permission(private.poll_group(new.poll_id), 'events.manage')
       or exists (select 1 from public.poll_votes v where v.poll_id = new.poll_id) then
      perform private.raise_event_rule('poll_forbidden');
    end if;
    new.label := btrim(new.label);
    return new;
  end if;
  if tg_op = 'DELETE' and pg_trigger_depth() > 1 then
    return old;
  end if;
  perform private.raise_event_rule('poll_immutable');
  return null;
end;
$$;

create trigger poll_options_guard
  before insert or update or delete on public.poll_options
  for each row execute function private.poll_options_guard();

-- Votes: the option belongs to the poll; one vote unless the poll allows several.
create function private.poll_votes_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if not exists (select 1 from public.poll_options o where o.id = new.option_id and o.poll_id = new.poll_id) then
    perform private.raise_event_rule('poll_option_invalid');
  end if;
  if not (select p.allows_multiple from public.polls p where p.id = new.poll_id)
     and exists (select 1 from public.poll_votes v where v.poll_id = new.poll_id and v.user_id = new.user_id) then
    perform private.raise_event_rule('poll_single_choice');
  end if;
  new.created_at := now();
  return new;
end;
$$;

create trigger poll_votes_guard
  before insert on public.poll_votes
  for each row execute function private.poll_votes_guard();

-- ---------------------------------------------------------------------------
-- Reminders (called by the backend job; system writes)
-- ---------------------------------------------------------------------------
create function private.send_event_reminders()
returns int
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
    where canceled_at is null and starts_at > now()
      and ((reminded_hour_at is null and starts_at <= now() + interval '1 hour')
        or (reminded_day_at is null and starts_at > now() + interval '1 hour' and starts_at <= now() + interval '24 hours'))
    for update skip locked
  loop
    for person in select a.user_id from public.event_attendees a where a.event_id = e.id and a.status = 'going' loop
      perform private.notify_event(person, e.id, 'event_reminder');
      sent := sent + 1;
    end loop;
    if e.starts_at <= now() + interval '1 hour' then
      update public.events set reminded_hour_at = now(), reminded_day_at = coalesce(reminded_day_at, now()) where id = e.id;
    else
      update public.events set reminded_day_at = now() where id = e.id;
    end if;
  end loop;
  return sent;
end;
$$;

revoke all on function private.send_event_reminders() from public;
grant execute on function private.send_event_reminders() to service_role;

-- ---------------------------------------------------------------------------
-- Notifications (notifications owns the table)
-- ---------------------------------------------------------------------------
alter table public.notifications add column event_id uuid references public.events (id) on delete cascade;
alter table public.notifications drop constraint notifications_type_check;
alter table public.notifications add constraint notifications_type_check
  check (type in ('like', 'comment', 'reply', 'comment_like', 'mention', 'follow', 'follow_request', 'follow_accepted',
                  'live_started', 'event_promoted', 'event_updated', 'event_canceled', 'event_reminder'));

create or replace function public.my_notifications(before_id bigint default null, page_size int default 30)
returns setof jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select jsonb_build_object(
    'id', n.id,
    'type', n.type,
    'created_at', n.created_at,
    'read', n.read_at is not null,
    'actor', jsonb_build_object('id', a.id, 'username', a.username, 'display_name', a.display_name, 'avatar_path', a.avatar_path),
    'post_id', n.post_id,
    'post_thumb', (select coalesce(m.thumb_path, m.poster_path, m.path) from public.post_media m
                   where m.post_id = n.post_id order by m.position limit 1),
    'post_thumb_kind', (select m.kind from public.post_media m where m.post_id = n.post_id order by m.position limit 1),
    'comment', (select left(c.body, 120) from public.comments c where c.id = n.comment_id),
    'live_id', n.live_id,
    'live_title', (select b.title from public.live_broadcasts b where b.id = n.live_id),
    'event_id', n.event_id,
    'event_title', (select e.title from public.events e where e.id = n.event_id),
    'event_starts_at', (select e.starts_at from public.events e where e.id = n.event_id),
    'i_follow', private.user_follows((select auth.uid()), n.actor_id),
    'requested', exists (select 1 from public.follow_requests r
                         where r.requester_id = (select auth.uid()) and r.target_id = n.actor_id)
  )
  from public.notifications n
  join public.profiles a on a.id = n.actor_id
  where n.recipient_id = (select auth.uid()) and (before_id is null or n.id < before_id)
  order by n.id desc
  limit least(greatest(page_size, 1), 60);
$$;

-- ---------------------------------------------------------------------------
-- RPCs
-- ---------------------------------------------------------------------------

-- An event as the screens show it, with the caller's attendance and waitlist place.
create function private.event_card(e public.events)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'id', e.id,
    'group', jsonb_build_object('id', g.id, 'handle', g.handle, 'name', g.name, 'logo_path', g.logo_path),
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
  where g.id = e.group_id;
$$;

revoke all on function private.event_card(public.events) from public;
grant execute on function private.event_card(public.events) to anon, authenticated;

-- A group's upcoming events (canceled ones too until they pass) and, for managers, events left this month.
create function public.group_events(target_group uuid)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select jsonb_build_object(
    'events', coalesce((select jsonb_agg(private.event_card(e) order by e.starts_at)
                        from public.events e where e.group_id = target_group and e.starts_at > now()), '[]'),
    'events_left', case when private.has_group_permission(target_group, 'events.manage')
                        then private.group_events_left(target_group) end
  );
$$;

create function public.event_detail(target_event uuid)
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
      join public.profiles p on p.id = a.user_id), '[]') end
  )
  from public.events e where e.id = target_event;
$$;

-- Polls of a group (or of one event) with results; members and staff only. Anonymous polls never reveal voters.
create function public.group_polls(target_group uuid, target_event uuid default null)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select case when not (private.is_group_member(target_group) or private.is_platform_staff()) then '[]'::jsonb else coalesce((
    select jsonb_agg(jsonb_build_object(
      'id', p.id,
      'event_id', p.event_id,
      'question', p.question,
      'allows_multiple', p.allows_multiple,
      'is_anonymous', p.is_anonymous,
      'closes_at', p.closes_at,
      'is_open', private.is_poll_open(p),
      'created_at', p.created_at,
      'voters', (select count(distinct v.user_id) from public.poll_votes v where v.poll_id = p.id),
      'options', (select jsonb_agg(jsonb_build_object(
                    'id', o.id,
                    'label', o.label,
                    'votes', (select count(*) from public.poll_votes v where v.option_id = o.id),
                    'mine', exists (select 1 from public.poll_votes v where v.option_id = o.id and v.user_id = (select auth.uid()))
                  ) order by o.position) from public.poll_options o where o.poll_id = p.id)
    ) order by private.is_poll_open(p) desc, p.created_at desc)
    from (select * from public.polls
          where group_id = target_group
            and (target_event is null or event_id = target_event)
          order by created_at desc limit 20) p
  ), '[]') end;
$$;

revoke all on function public.group_events(uuid), public.event_detail(uuid), public.group_polls(uuid, uuid) from public;
grant execute on function public.group_events(uuid), public.event_detail(uuid) to anon, authenticated;
grant execute on function public.group_polls(uuid, uuid) to authenticated;
grant execute on function private.group_events_left(uuid) to authenticated;

-- Event pages and polls follow changes live (RLS applies to Realtime).
alter publication supabase_realtime add table public.events, public.poll_votes;
