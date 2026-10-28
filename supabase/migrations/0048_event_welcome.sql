-- 0048: welcome — a volunteer member greets someone at their first event of a group
-- (docs/ARCHITECTURE.md §3d, Karşılama). Also closes two membership leaks found with it (§3b):
-- the group's contribution list is for its members, and goal badges follow membership privacy.

-- ---------------------------------------------------------------------------
-- Who counts as having been there
-- ---------------------------------------------------------------------------

-- Attended as in the contributions: going, not marked absent, the event ended and was not canceled.
create function private.has_attended_in_group(uid uuid, target_group uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.event_attendees a join public.events e on e.id = a.event_id
    where a.user_id = uid and e.group_id = target_group and a.status = 'going' and a.no_show_at is null
      and e.canceled_at is null and coalesce(e.ends_at, e.starts_at + interval '2 hours') <= now());
$$;

create function private.attended_event(uid uuid, target_event uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.event_attendees a join public.events e on e.id = a.event_id
    where a.user_id = uid and a.event_id = target_event and a.status = 'going' and a.no_show_at is null
      and e.canceled_at is null and coalesce(e.ends_at, e.starts_at + interval '2 hours') <= now());
$$;

create function private.is_going(uid uuid, target_event uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (select 1 from public.event_attendees a where a.event_id = target_event and a.user_id = uid and a.status = 'going');
$$;

revoke all on function private.has_attended_in_group(uuid, uuid), private.attended_event(uuid, uuid), private.is_going(uuid, uuid) from public;
grant execute on function private.has_attended_in_group(uuid, uuid), private.attended_event(uuid, uuid), private.is_going(uuid, uuid)
  to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- Greeters
-- ---------------------------------------------------------------------------
create table public.group_greeters (
  group_id   uuid not null references public.groups (id) on delete cascade,
  user_id    uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (group_id, user_id),
  foreign key (group_id, user_id) references public.group_members (group_id, user_id) on delete cascade
);

comment on table public.group_greeters is
  'owner: events. Members who volunteer to greet first-timers; the member''s own write, eligibility checked by trigger.';

create index group_greeters_user_idx on public.group_greeters (user_id);

create function private.can_greet(uid uuid, target_group uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select private.is_account_active(uid)
     and exists (select 1 from public.group_members m where m.group_id = target_group and m.user_id = uid)
     and exists (select 1 from public.groups g where g.id = target_group and g.status = 'active')
     and (private.is_group_team(target_group, uid) or private.has_attended_in_group(uid, target_group));
$$;

revoke all on function private.can_greet(uuid, uuid) from public;
grant execute on function private.can_greet(uuid, uuid) to authenticated, service_role;

create function private.group_greeters_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    if new.user_id is distinct from (select auth.uid()) or not private.can_greet(new.user_id, new.group_id) then
      raise exception 'greeter_not_allowed' using errcode = 'P0001';
    end if;
    new.created_at := now();
  end if;
  return new;
end;
$$;

create trigger group_greeters_guard
  before insert on public.group_greeters
  for each row execute function private.group_greeters_guard();

alter table public.group_greeters enable row level security;
revoke all on public.group_greeters from anon, authenticated;
grant select, insert, delete on public.group_greeters to authenticated;

create policy group_greeters_select on public.group_greeters for select to authenticated
  using (user_id = (select auth.uid())
         or private.has_group_permission(group_id, 'events.manage')
         or (select private.is_platform_staff()));
create policy group_greeters_insert_own on public.group_greeters for insert to authenticated
  with check (user_id = (select auth.uid()));
create policy group_greeters_delete_own on public.group_greeters for delete to authenticated
  using (user_id = (select auth.uid()));

-- ---------------------------------------------------------------------------
-- Welcome requests
-- ---------------------------------------------------------------------------
create table public.event_welcomes (
  event_id     uuid not null references public.events (id) on delete cascade,
  newcomer_id  uuid not null references public.profiles (id) on delete cascade,
  group_id     uuid not null references public.groups (id) on delete cascade,
  newcomer_note text check (char_length(newcomer_note) between 1 and 200),
  greeter_id   uuid references public.profiles (id) on delete cascade,
  greeter_note text check (char_length(greeter_note) between 3 and 200),
  created_at   timestamptz not null default now(),
  matched_at   timestamptz,
  thanked_at   timestamptz,
  primary key (event_id, newcomer_id),
  constraint event_welcomes_match check ((greeter_id is null) = (greeter_note is null) and (greeter_id is null) = (matched_at is null)),
  constraint event_welcomes_not_self check (greeter_id is distinct from newcomer_id)
);

comment on table public.event_welcomes is
  'owner: events. A first-timer asks to be greeted at an event; a going greeter takes it with a meeting note. Backend writes.';

create index event_welcomes_greeter_idx on public.event_welcomes (greeter_id) where greeter_id is not null;
create index event_welcomes_group_idx on public.event_welcomes (group_id, newcomer_id);

create function private.event_open(target_event uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (select 1 from public.events e where e.id = target_event and e.canceled_at is null and e.starts_at > now());
$$;

revoke all on function private.event_open(uuid) from public;
grant execute on function private.event_open(uuid) to authenticated, service_role;

-- The backend's rules, a second time (actor = auth.uid()). Changes cascaded from another trigger
-- (leaving the event, deleting it) pass.
create function private.event_welcomes_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
  ends timestamptz;
begin
  if pg_trigger_depth() > 1 then
    return coalesce(new, old);
  end if;

  if tg_op = 'INSERT' then
    select e.group_id into new.group_id from public.events e where e.id = new.event_id;
    if actor is distinct from new.newcomer_id or new.greeter_id is not null or new.thanked_at is not null
       or not private.event_open(new.event_id) or not private.is_going(new.newcomer_id, new.event_id)
       or not private.is_account_active(new.newcomer_id) then
      raise exception 'welcome_not_allowed' using errcode = 'P0001';
    end if;
    if private.has_attended_in_group(new.newcomer_id, new.group_id) then
      raise exception 'welcome_not_first_time' using errcode = 'P0001';
    end if;
    if exists (select 1 from public.event_welcomes w where w.group_id = new.group_id and w.newcomer_id = new.newcomer_id
               and private.event_open(w.event_id)) then
      raise exception 'welcome_already_requested' using errcode = 'P0001';
    end if;
    new.created_at := now();
    new.matched_at := null;
    return new;
  end if;

  if tg_op = 'DELETE' then
    if actor is distinct from old.newcomer_id or not private.event_open(old.event_id) then
      raise exception 'welcome_forbidden' using errcode = 'P0001';
    end if;
    return old;
  end if;

  if (new.event_id, new.newcomer_id, new.group_id, new.newcomer_note, new.created_at)
     is distinct from (old.event_id, old.newcomer_id, old.group_id, old.newcomer_note, old.created_at) then
    raise exception 'welcome_forbidden' using errcode = 'P0001';
  end if;

  -- Thanks: the newcomer, once, within 30 days after the end; both attended.
  if new.thanked_at is distinct from old.thanked_at then
    select coalesce(e.ends_at, e.starts_at + interval '2 hours') into ends from public.events e where e.id = new.event_id;
    if old.thanked_at is not null or new.thanked_at is null or actor is distinct from new.newcomer_id
       or new.greeter_id is distinct from old.greeter_id or old.greeter_id is null
       or ends > now() or ends < now() - interval '30 days'
       or not private.attended_event(new.newcomer_id, new.event_id) or not private.attended_event(old.greeter_id, new.event_id) then
      raise exception 'welcome_thanks_not_allowed' using errcode = 'P0001';
    end if;
    new.thanked_at := now();
    return new;
  end if;

  if not private.event_open(new.event_id) then
    raise exception 'welcome_closed' using errcode = 'P0001';
  end if;

  -- Release: the greeter steps back and the request opens again.
  if new.greeter_id is null then
    if old.greeter_id is null or actor is distinct from old.greeter_id then
      raise exception 'welcome_forbidden' using errcode = 'P0001';
    end if;
    new.greeter_note := null;
    new.matched_at := null;
    return new;
  end if;

  -- Take, or change the meeting note.
  if actor is distinct from new.greeter_id or (old.greeter_id is not null and old.greeter_id <> new.greeter_id)
     or not exists (select 1 from public.group_greeters gg where gg.group_id = new.group_id and gg.user_id = actor)
     or not private.can_greet(actor, new.group_id) or not private.is_going(actor, new.event_id)
     or private.is_blocked_between(actor, new.newcomer_id) then
    raise exception 'welcome_take_not_allowed' using errcode = 'P0001';
  end if;
  if old.greeter_id is null then
    if (select count(*) from public.event_welcomes w where w.event_id = new.event_id and w.greeter_id = actor) >= 3 then
      raise exception 'welcome_greeter_full' using errcode = 'P0001';
    end if;
    new.matched_at := now();
  else
    new.matched_at := old.matched_at;
  end if;
  return new;
end;
$$;

create trigger event_welcomes_guard
  before insert or update or delete on public.event_welcomes
  for each row execute function private.event_welcomes_guard();

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
                  'welcome_requested', 'welcome_matched', 'welcome_released', 'welcome_withdrawn', 'welcome_thanked'));

create function private.notify_welcome(recipient uuid, actor uuid, target_event uuid, target_group uuid, kind text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if recipient is null or recipient = actor or not private.is_account_active(recipient)
     or private.is_blocked_between(recipient, actor) then
    return;
  end if;
  insert into public.notifications (recipient_id, actor_id, type, event_id, group_id)
  values (recipient, actor, kind, target_event, target_group);
end;
$$;

revoke all on function private.notify_welcome(uuid, uuid, uuid, uuid, text) from public;

create function private.event_welcomes_notify()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    perform private.notify_welcome(gg.user_id, new.newcomer_id, new.event_id, new.group_id, 'welcome_requested')
    from public.group_greeters gg where gg.group_id = new.group_id;
  elsif tg_op = 'DELETE' then
    if old.greeter_id is not null and exists (select 1 from public.events e where e.id = old.event_id) then
      perform private.notify_welcome(old.greeter_id, old.newcomer_id, old.event_id, old.group_id, 'welcome_withdrawn');
    end if;
  elsif new.thanked_at is not null and old.thanked_at is null then
    perform private.notify_welcome(new.greeter_id, new.newcomer_id, new.event_id, new.group_id, 'welcome_thanked');
  elsif old.greeter_id is null and new.greeter_id is not null then
    perform private.notify_welcome(new.newcomer_id, new.greeter_id, new.event_id, new.group_id, 'welcome_matched');
  elsif old.greeter_id is not null and new.greeter_id is null then
    perform private.notify_welcome(new.newcomer_id, old.greeter_id, new.event_id, new.group_id, 'welcome_released');
  end if;
  return null;
end;
$$;

create trigger event_welcomes_notify
  after insert or update or delete on public.event_welcomes
  for each row execute function private.event_welcomes_notify();

-- Leaving an event drops the newcomer's request and frees the greeter's.
create function private.event_attendees_welcome_cleanup()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  delete from public.event_welcomes where event_id = old.event_id and newcomer_id = old.user_id;
  update public.event_welcomes set greeter_id = null, greeter_note = null, matched_at = null
  where event_id = old.event_id and greeter_id = old.user_id;
  return null;
end;
$$;

create trigger event_attendees_welcome_cleanup
  after delete on public.event_attendees
  for each row execute function private.event_attendees_welcome_cleanup();

alter table public.event_welcomes enable row level security;
revoke all on public.event_welcomes from anon, authenticated;
grant select on public.event_welcomes to authenticated;

create policy event_welcomes_select on public.event_welcomes for select to authenticated
  using (newcomer_id = (select auth.uid())
         or greeter_id = (select auth.uid())
         or (exists (select 1 from public.group_greeters gg where gg.group_id = event_welcomes.group_id and gg.user_id = (select auth.uid()))
             and private.is_going((select auth.uid()), event_id))
         or private.has_group_permission(group_id, 'events.manage')
         or (select private.is_platform_staff()));

-- ---------------------------------------------------------------------------
-- Pages
-- ---------------------------------------------------------------------------

-- The group page: how many greeters (public), and the viewer's own standing.
create function private.group_welcome(target_group uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select case when not private.is_group_visible(target_group) then null else jsonb_build_object(
    'greeters', (select count(*) from public.group_greeters gg
                 where gg.group_id = target_group and private.is_account_active(gg.user_id)),
    'is_greeter', exists (select 1 from public.group_greeters gg where gg.group_id = target_group and gg.user_id = (select auth.uid())),
    'can_greet', coalesce(private.can_greet((select auth.uid()), target_group), false)
  ) end;
$$;

-- The event page's welcome block (docs/ARCHITECTURE.md §3d, Karşılama).
create function private.event_welcome(target_event uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  me uuid := (select auth.uid());
  e public.events;
  is_open boolean;
  has_ended boolean;
  greeter boolean;
  manager boolean;
  mine public.event_welcomes;
begin
  select * into e from public.events where id = target_event;
  if e.id is null or me is null or not private.is_group_visible(e.group_id) then
    return null;
  end if;
  is_open := e.canceled_at is null and e.starts_at > now();
  has_ended := e.canceled_at is null and coalesce(e.ends_at, e.starts_at + interval '2 hours') <= now();
  greeter := exists (select 1 from public.group_greeters gg where gg.group_id = e.group_id and gg.user_id = me);
  manager := private.has_group_permission(e.group_id, 'events.manage');
  select * into mine from public.event_welcomes w where w.event_id = target_event and w.newcomer_id = me;

  return jsonb_build_object(
    'greeters', (select count(*) from public.group_greeters gg where gg.group_id = e.group_id and private.is_account_active(gg.user_id)),
    'can_request', is_open and mine.event_id is null and private.is_going(me, target_event)
                   and not private.has_attended_in_group(me, e.group_id)
                   and not exists (select 1 from public.event_welcomes w where w.group_id = e.group_id and w.newcomer_id = me
                                   and private.event_open(w.event_id)),
    'mine', case when mine.event_id is null then null else jsonb_build_object(
      'note', mine.newcomer_note,
      'greeter', case when mine.greeter_id is null then null else private.person(mine.greeter_id) end,
      'greeter_note', mine.greeter_note,
      'thanked', mine.thanked_at is not null,
      'can_thank', mine.thanked_at is null and mine.greeter_id is not null and has_ended
                   and coalesce(e.ends_at, e.starts_at + interval '2 hours') > now() - interval '30 days'
                   and private.attended_event(me, target_event) and private.attended_event(mine.greeter_id, target_event)
    ) end,
    'is_greeter', greeter,
    'greeting', greeter and is_open and private.is_going(me, target_event),
    'open', case when (greeter and private.is_going(me, target_event)) or manager then coalesce((
      select jsonb_agg(jsonb_build_object('person', private.person(w.newcomer_id), 'note', w.newcomer_note, 'created_at', w.created_at)
                       order by w.created_at)
      from public.event_welcomes w
      where w.event_id = target_event and w.greeter_id is null and private.is_account_active(w.newcomer_id)
        and not private.is_blocked_between(me, w.newcomer_id)), '[]'::jsonb) end,
    'taken', coalesce((
      select jsonb_agg(jsonb_build_object('person', private.person(w.newcomer_id), 'note', w.newcomer_note,
                                          'greeter_note', w.greeter_note, 'thanked', w.thanked_at is not null)
                       order by w.matched_at)
      from public.event_welcomes w where w.event_id = target_event and w.greeter_id = me), '[]'::jsonb),
    'matched', case when manager then (select count(*) from public.event_welcomes w where w.event_id = target_event and w.greeter_id is not null) end
  );
end;
$$;

create function public.group_welcome(target_group uuid)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.group_welcome(target_group);
$$;

create function public.event_welcome(target_event uuid)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.event_welcome(target_event);
$$;

revoke all on function private.group_welcome(uuid), private.event_welcome(uuid) from public;
grant execute on function private.group_welcome(uuid), private.event_welcome(uuid) to authenticated;
revoke all on function public.group_welcome(uuid), public.event_welcome(uuid) from public, anon;
grant execute on function public.group_welcome(uuid), public.event_welcome(uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- Contributions: welcomes count, with three badges
-- ---------------------------------------------------------------------------
create or replace function public.badge_catalog()
returns jsonb
language sql
immutable
set search_path = ''
as $$
  select '[
    {"slug": "first_step", "name": "İlk adım", "metric": "attended", "threshold": 1, "description": "İlk organizasyonuna katıl."},
    {"slug": "regular", "name": "Müdavim", "metric": "attended", "threshold": 10, "description": "10 organizasyona katıl."},
    {"slug": "companion", "name": "Yol arkadaşı", "metric": "attended", "threshold": 25, "description": "25 organizasyona katıl."},
    {"slug": "explorer", "name": "Kâşif", "metric": "groups", "threshold": 3, "description": "3 farklı grubun organizasyonuna katıl."},
    {"slug": "organizer", "name": "Düzenleyici", "metric": "organized", "threshold": 1, "description": "En az 2 kişinin katıldığı bir organizasyon düzenle."},
    {"slug": "master_organizer", "name": "Usta düzenleyici", "metric": "organized", "threshold": 10, "description": "En az 2 kişinin katıldığı 10 organizasyon düzenle."},
    {"slug": "storyteller", "name": "Anı biriktiren", "metric": "memories", "threshold": 5, "description": "Katıldığın organizasyonlara 5 anı ekle."},
    {"slug": "feedback", "name": "Geri bildirimci", "metric": "reviews", "threshold": 5, "description": "Katıldığın 5 organizasyonu değerlendir."},
    {"slug": "door_opener", "name": "Kapı açan", "metric": "welcomed", "threshold": 1, "description": "Bir organizasyonda ilk kez gelen birini karşıla."},
    {"slug": "host", "name": "Ev sahibi", "metric": "welcomed", "threshold": 5, "description": "İlk kez gelen 5 kişiyi karşıla."},
    {"slug": "community_heart", "name": "Topluluğun kalbi", "metric": "welcomed", "threshold": 20, "description": "İlk kez gelen 20 kişiyi karşıla."},
    {"slug": "category", "name": "tutkunu", "metric": "category", "threshold": 5, "description": "Bir kategoride 5 organizasyona katıl (ör. Yürüyüş tutkunu)."}
  ]'::jsonb;
$$;

create or replace function private.contribution_counts(uid uuid, target_group uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  with attended as (
    select e.id, e.group_id, g.category_slug
    from public.event_attendees a
    join public.events e on e.id = a.event_id
    join public.groups g on g.id = e.group_id
    where a.user_id = uid and a.status = 'going' and a.no_show_at is null
      and e.canceled_at is null and coalesce(e.ends_at, e.starts_at + interval '2 hours') <= now()
      and (target_group is null or e.group_id = target_group)
  )
  select jsonb_build_object(
    'attended', (select count(*) from attended),
    'groups', (select count(distinct group_id) from attended),
    'organized', (
      select count(*) from public.events e
      where e.created_by = uid and e.canceled_at is null and coalesce(e.ends_at, e.starts_at + interval '2 hours') <= now()
        and (target_group is null or e.group_id = target_group)
        and (select count(*) from public.event_attendees a
             where a.event_id = e.id and a.status = 'going' and a.no_show_at is null and a.user_id <> uid) >= 2),
    'memories', (
      select count(*) from public.posts p join public.events e on e.id = p.event_id
      where p.author_id = uid and p.removed_at is null and (target_group is null or e.group_id = target_group)),
    'reviews', (
      select count(*) from public.event_reviews r join public.events e on e.id = r.event_id
      where r.user_id = uid and (target_group is null or e.group_id = target_group)),
    'welcomed', (
      select count(*) from public.event_welcomes w join attended a on a.id = w.event_id
      where w.greeter_id = uid and private.attended_event(w.newcomer_id, w.event_id)),
    'categories', coalesce((select jsonb_object_agg(category_slug, n) from (
      select category_slug, count(*) as n from attended group by category_slug) c), '{}'::jsonb)
  );
$$;

-- Goal badges show only the groups whose membership the viewer may see (§3b).
create or replace function private.user_contributions(target uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select case when not private.can_view_user_content(target) then null else (
    select counts - 'categories' || jsonb_build_object('badges', private.earned_badges(counts) || coalesce((
      select jsonb_agg(jsonb_build_object('slug', 'goal:' || g.id, 'name', 'Hedef: ' || g.title,
                                          'description', gr.name || ' grubunun hedefini tamamladı.') order by c.completed_at desc)
      from public.goal_completions c
      join public.goals g on g.id = c.goal_id
      join public.groups gr on gr.id = g.group_id
      where c.user_id = user_contributions.target
        and (user_contributions.target = (select auth.uid()) or private.is_platform_staff()
             or private.is_group_member(g.group_id) or private.is_group_team(g.group_id, user_contributions.target)
             or private.are_groups_public(user_contributions.target))), '[]'::jsonb))
    from (select private.contribution_counts(target, null) as counts) x
  ) end;
$$;

-- A group's per-member numbers name its members: members and platform staff only (§3b).
create or replace function private.group_contributions(target_group uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select case when not (private.is_group_member(target_group) or private.is_platform_staff()) then '{}'::jsonb else coalesce((
    select jsonb_object_agg(m.user_id, jsonb_build_object('attended', c->'attended', 'organized', c->'organized'))
    from public.group_members m
    cross join lateral (select private.contribution_counts(m.user_id, target_group) as c) x
    where m.group_id = target_group and ((c->>'attended')::int > 0 or (c->>'organized')::int > 0)
  ), '{}'::jsonb) end;
$$;
