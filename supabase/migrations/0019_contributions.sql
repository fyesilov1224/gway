-- 0019_contributions
-- Phase 11: the roll call (no-shows), contributions computed from the source
-- records, and badges from one catalog. Rules: docs/ARCHITECTURE.md §3d (Katkı ve rozetler).

-- ---------------------------------------------------------------------------
-- Roll call (events)
-- ---------------------------------------------------------------------------
alter table public.event_attendees
  add column no_show_at timestamptz,
  add column no_show_by uuid references public.profiles (id) on delete set null;

comment on column public.event_attendees.no_show_at is
  'Marked by an events.manage holder within 7 days after the end; a no-show does not count as attended.';

-- When the roll call of an event is open: from its end (or start + 2 hours) for 7 days.
create function private.is_roll_open(e public.events)
returns boolean
language sql
stable
set search_path = ''
as $$
  select e.canceled_at is null
     and now() >= coalesce(e.ends_at, e.starts_at + interval '2 hours')
     and now() < coalesce(e.ends_at, e.starts_at + interval '2 hours') + interval '7 days';
$$;

-- Attendance: as in 0014, plus the roll call (only no_show_at changes, by a manager, while open).
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
  return new;
end;
$$;

-- A no-show neither reviews nor shares memories.
create or replace function private.can_review_event(target_event uuid, uid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.events e
    join public.event_attendees a on a.event_id = e.id and a.user_id = uid and a.status = 'going' and a.no_show_at is null
    where e.id = target_event and e.canceled_at is null
      and now() >= coalesce(e.ends_at, e.starts_at + interval '2 hours')
      and now() < coalesce(e.ends_at, e.starts_at + interval '2 hours') + interval '30 days'
  );
$$;

create or replace function private.posts_event_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
  e public.events;
begin
  if tg_op = 'UPDATE' then
    if new.event_id is distinct from old.event_id and pg_trigger_depth() < 2 then
      perform private.raise_feed_rule('post_immutable');
    end if;
    return new;
  end if;
  if new.event_id is null then
    return new;
  end if;
  select * into e from public.events where id = new.event_id;
  if e.id is null or e.canceled_at is not null or e.starts_at > now()
     or not (
       exists (select 1 from public.event_attendees a
               where a.event_id = e.id and a.user_id = actor and a.status = 'going' and a.no_show_at is null)
       or private.has_group_permission(e.group_id, 'events.manage')
     ) then
    perform private.raise_feed_rule('event_post_forbidden');
  end if;
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- Contributions and badges
-- ---------------------------------------------------------------------------

-- The badges and how they are earned; the only place the thresholds live. Category badges
-- ("<Kategori> tutkunu") use the 'category' metric with the category's name.
create function public.badge_catalog()
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
    {"slug": "category", "name": "tutkunu", "metric": "category", "threshold": 5, "description": "Bir kategoride 5 organizasyona katıl (ör. Yürüyüş tutkunu)."}
  ]'::jsonb;
$$;

-- What a person did, counted from the source records; within one group when target_group is set.
create function private.contribution_counts(uid uuid, target_group uuid)
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
    'categories', coalesce((select jsonb_object_agg(category_slug, n) from (
      select category_slug, count(*) as n from attended group by category_slug) c), '{}'::jsonb)
  );
$$;

-- The badges the counts earn, in catalog order; one per category that passes the threshold.
create function private.earned_badges(counts jsonb)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(jsonb_agg(b order by ord), '[]'::jsonb)
  from (
    select jsonb_build_object('slug', c->>'slug', 'name', c->>'name', 'description', c->>'description') as b, n as ord
    from jsonb_array_elements(public.badge_catalog()) with ordinality as x(c, n)
    where c->>'metric' <> 'category' and coalesce((counts->>(c->>'metric'))::int, 0) >= (c->>'threshold')::int
    union all
    select jsonb_build_object('slug', 'category:' || cat.slug, 'name', cat.name || ' tutkunu',
                              'description', cat.name || ' kategorisinde 5 organizasyona katıldı.') as b, 100 + cat.sort_order as ord
    from public.categories cat
    where coalesce((counts->'categories'->>cat.slug)::int, 0) >= (
      select (c->>'threshold')::int from jsonb_array_elements(public.badge_catalog()) c where c->>'metric' = 'category')
  ) earned;
$$;

create function private.user_contributions(target uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select case when not private.can_view_user_content(target) then null else (
    select counts - 'categories' || jsonb_build_object('badges', private.earned_badges(counts))
    from (select private.contribution_counts(target, null) as counts) x
  ) end;
$$;

create function public.user_contributions(target uuid)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.user_contributions(target);
$$;

-- Attendance and organizing within a group, per member who has any; for the member list.
create function private.group_contributions(target_group uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select case when not private.is_group_visible(target_group) then '{}'::jsonb else coalesce((
    select jsonb_object_agg(m.user_id, jsonb_build_object('attended', c->'attended', 'organized', c->'organized'))
    from public.group_members m
    cross join lateral (select private.contribution_counts(m.user_id, target_group) as c) x
    where m.group_id = target_group and ((c->>'attended')::int > 0 or (c->>'organized')::int > 0)
  ), '{}'::jsonb) end;
$$;

create function public.group_contributions(target_group uuid)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.group_contributions(target_group);
$$;

revoke all on function private.is_roll_open(public.events), private.contribution_counts(uuid, uuid), private.earned_badges(jsonb),
  private.user_contributions(uuid), private.group_contributions(uuid) from public;
grant execute on function private.is_roll_open(public.events) to authenticated, service_role;
grant execute on function private.user_contributions(uuid), private.group_contributions(uuid) to authenticated, service_role;
grant execute on function private.contribution_counts(uuid, uuid) to service_role;
revoke all on function public.user_contributions(uuid), public.group_contributions(uuid) from public, anon;
grant execute on function public.user_contributions(uuid), public.group_contributions(uuid) to authenticated;
grant execute on function public.badge_catalog() to anon, authenticated;

-- ---------------------------------------------------------------------------
-- The event page: the roll call for managers while it is open
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
    ), '[]'),
    'can_post', e.canceled_at is null and e.starts_at <= now() and (
      exists (select 1 from public.event_attendees a
              where a.event_id = e.id and a.user_id = (select auth.uid()) and a.status = 'going' and a.no_show_at is null)
      or private.has_group_permission(e.group_id, 'events.manage')),
    'can_review', private.can_review_event(e.id, (select auth.uid())),
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
