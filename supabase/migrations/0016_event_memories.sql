-- 0016_event_memories
-- Phase 10: posts linked to an event (memories), reviews by attendees after the
-- end, the review request notification, event summaries and the group's history.
-- Rules: docs/ARCHITECTURE.md §3d (Organizasyon sonrası).

-- ---------------------------------------------------------------------------
-- posts.event_id (feed owns posts)
-- ---------------------------------------------------------------------------
alter table public.posts add column event_id uuid references public.events (id) on delete set null;
comment on column public.posts.event_id is 'A memory of this event; set at creation by an attendee or an events.manage holder.';
create index posts_event_idx on public.posts (event_id, created_at desc) where event_id is not null;

-- Who may link a post to an event, once it started: those who went, or its managers. The link never changes.
create function private.posts_event_guard()
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
       exists (select 1 from public.event_attendees a where a.event_id = e.id and a.user_id = actor and a.status = 'going')
       or private.has_group_permission(e.group_id, 'events.manage')
     ) then
    perform private.raise_feed_rule('event_post_forbidden');
  end if;
  return new;
end;
$$;

create trigger posts_event_guard
  before insert or update of event_id on public.posts
  for each row execute function private.posts_event_guard();

-- The card also names the event of a memory.
create or replace function public.post_card(p public.posts)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select jsonb_build_object(
    'id', p.id,
    'caption', p.caption,
    'created_at', p.created_at,
    'edited_at', p.edited_at,
    'comments_disabled', p.comments_disabled,
    'hide_like_count', p.hide_like_count,
    'like_count', case when p.hide_like_count and not private.can_manage_post(p.id) then null else p.like_count end,
    'comment_count', p.comment_count,
    'removed_at', p.removed_at,
    'author', (select jsonb_build_object('id', a.id, 'username', a.username, 'display_name', a.display_name,
                                         'avatar_path', a.avatar_path)
               from public.profiles a where a.id = p.author_id),
    'group', (select jsonb_build_object('id', g.id, 'handle', g.handle, 'name', g.name, 'logo_path', g.logo_path)
              from public.groups g where g.id = p.group_id),
    'event', (select jsonb_build_object('id', e.id, 'title', e.title) from public.events e where e.id = p.event_id),
    'media', coalesce((select jsonb_agg(jsonb_build_object('kind', m.kind, 'path', m.path, 'width', m.width, 'height', m.height,
                                                           'duration_ms', m.duration_ms, 'poster_path', m.poster_path,
                                                           'thumb_path', m.thumb_path)
                                        order by m.position)
                       from public.post_media m where m.post_id = p.id), '[]'::jsonb),
    'liked', exists (select 1 from public.post_likes l where l.post_id = p.id and l.user_id = (select auth.uid())),
    'saved', exists (select 1 from public.saved_posts s where s.post_id = p.id and s.user_id = (select auth.uid())),
    'can_manage', private.can_manage_post(p.id)
  );
$$;

-- Memories of an event the viewer may see (RLS on posts), newest first.
create function public.event_posts(target_event uuid, before_at timestamptz default null, before_id uuid default null,
                                   page_size int default 30)
returns setof jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select public.post_card(p)
  from public.posts p
  where p.event_id = target_event
    and (before_at is null or (p.created_at, p.id) < (before_at, before_id))
    and not private.is_blocked_between(p.author_id, (select auth.uid()))
  order by p.created_at desc, p.id desc
  limit least(greatest(page_size, 1), 60);
$$;

-- ---------------------------------------------------------------------------
-- event_reviews
-- owner: events
-- ---------------------------------------------------------------------------
create table public.event_reviews (
  event_id   uuid not null references public.events (id) on delete cascade,
  user_id    uuid not null references public.profiles (id) on delete cascade,
  rating     smallint not null check (rating between 1 and 5),
  comment    text not null default '' check (char_length(comment) <= 500),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (event_id, user_id)
);

comment on table public.event_reviews is
  'owner: events. 1–5 stars from attendees after the end; notes are for the reviewer and the event''s managers only.';

alter table public.events add column review_asked_at timestamptz;

-- The window in which an attendee may review: from the end (or start + 2 hours) for 30 days.
create function private.can_review_event(target_event uuid, uid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.events e
    join public.event_attendees a on a.event_id = e.id and a.user_id = uid and a.status = 'going'
    where e.id = target_event and e.canceled_at is null
      and now() >= coalesce(e.ends_at, e.starts_at + interval '2 hours')
      and now() < coalesce(e.ends_at, e.starts_at + interval '2 hours') + interval '30 days'
  );
$$;

revoke all on function private.can_review_event(uuid, uuid) from public;
grant execute on function private.can_review_event(uuid, uuid) to authenticated, service_role;

alter table public.event_reviews enable row level security;
revoke all on public.event_reviews from anon, authenticated;
grant select, delete on public.event_reviews to authenticated;
grant insert (event_id, user_id, rating, comment), update (rating, comment) on public.event_reviews to authenticated;

create policy event_reviews_select_own_or_manager on public.event_reviews for select to authenticated
  using (user_id = (select auth.uid()) or private.has_group_permission(private.event_group(event_id), 'events.manage'));
create policy event_reviews_insert_own on public.event_reviews for insert to authenticated
  with check (user_id = (select auth.uid()));
create policy event_reviews_update_own on public.event_reviews for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy event_reviews_delete_own on public.event_reviews for delete to authenticated
  using (user_id = (select auth.uid()));

create function private.event_reviews_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if (new.event_id, new.user_id) is distinct from (coalesce(old.event_id, new.event_id), coalesce(old.user_id, new.user_id))
     or not private.can_review_event(new.event_id, new.user_id) then
    perform private.raise_event_rule('review_not_allowed');
  end if;
  new.comment := btrim(new.comment);
  if tg_op = 'INSERT' then
    new.created_at := now();
  else
    new.created_at := old.created_at;
  end if;
  new.updated_at := now();
  return new;
end;
$$;

create trigger event_reviews_guard
  before insert or update on public.event_reviews
  for each row execute function private.event_reviews_guard();

-- The review request mark is the job's alone.
create function private.events_review_mark_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if (select auth.uid()) is not null then
    perform private.raise_event_rule('event_immutable');
  end if;
  return new;
end;
$$;

create trigger events_review_mark_guard
  before update of review_asked_at on public.events
  for each row when (old.review_asked_at is distinct from new.review_asked_at)
  execute function private.events_review_mark_guard();

-- ---------------------------------------------------------------------------
-- Review requests (notifications owns the table and the preferences)
-- ---------------------------------------------------------------------------
alter table public.notification_preferences add column event_review_requests boolean not null default true;
grant insert (event_review_requests), update (event_review_requests) on public.notification_preferences to authenticated;

alter table public.notifications drop constraint notifications_type_check;
alter table public.notifications add constraint notifications_type_check
  check (type in ('like', 'comment', 'reply', 'comment_like', 'mention', 'follow', 'follow_request', 'follow_accepted',
                  'live_started', 'event_promoted', 'event_updated', 'event_canceled', 'event_reminder',
                  'case_vote', 'sanction_applied', 'appeal_submitted', 'appeal_decided',
                  'event_approved', 'event_declined', 'event_review'));

create or replace function private.wants_notification(uid uuid, kind text)
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
             when 'event_review' then p.event_review_requests
             else true
           end
    from public.notification_preferences p where p.user_id = uid
  ), true);
$$;

-- Asks the attendees of events that ended within the last day to review them; returns how many were asked.
create function private.send_review_requests()
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
    where canceled_at is null and review_asked_at is null
      and coalesce(ends_at, starts_at + interval '2 hours') <= now()
      and coalesce(ends_at, starts_at + interval '2 hours') > now() - interval '1 day'
    for update skip locked
  loop
    for person in select a.user_id from public.event_attendees a where a.event_id = e.id and a.status = 'going' loop
      perform private.notify_event(person, e.id, 'event_review');
      sent := sent + 1;
    end loop;
    update public.events set review_asked_at = now() where id = e.id;
  end loop;
  return sent;
end;
$$;

revoke all on function private.send_review_requests() from public;
grant execute on function private.send_review_requests() to service_role;

-- ---------------------------------------------------------------------------
-- Summaries
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
      exists (select 1 from public.event_attendees a where a.event_id = e.id and a.user_id = (select auth.uid()) and a.status = 'going')
      or private.has_group_permission(e.group_id, 'events.manage')),
    'can_review', private.can_review_event(e.id, (select auth.uid())),
    'my_review', (select jsonb_build_object('rating', r.rating, 'comment', r.comment)
                  from public.event_reviews r where r.event_id = e.id and r.user_id = (select auth.uid())),
    'reviews', case when private.has_group_permission(e.group_id, 'events.manage') then coalesce((
      select jsonb_agg(jsonb_build_object('id', p.id, 'username', p.username, 'display_name', p.display_name,
                                          'avatar_path', p.avatar_path, 'rating', r.rating, 'comment', r.comment,
                                          'updated_at', r.updated_at) order by r.updated_at desc)
      from public.event_reviews r join public.profiles p on p.id = r.user_id
      where r.event_id = e.id), '[]') end
  )
  from public.events e where e.id = target_event;
$$;

-- The group's past events with their summaries, newest first; keyset by start.
create function public.group_event_history(target_group uuid, before_at timestamptz default null, page_size int default 20)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select coalesce(jsonb_agg(private.event_card(e) order by e.starts_at desc), '[]'::jsonb)
  from (
    select * from public.events
    where group_id = target_group and starts_at <= now() and (before_at is null or starts_at < before_at)
    order by starts_at desc
    limit least(greatest(page_size, 1), 50)
  ) e;
$$;
