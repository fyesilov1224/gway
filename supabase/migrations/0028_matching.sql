-- 0028_matching
-- Phase 15.6a: matching profiles (friend and dating), the pool of people sharing a group,
-- swipes, matches, direct chat between matches, reports of matching profiles and photos.
-- Rules: docs/ARCHITECTURE.md §3g.

-- ---------------------------------------------------------------------------
-- match_profiles, match_photos, match_swipes, matches, matching_settings
-- owner: matching
-- ---------------------------------------------------------------------------
create table public.match_profiles (
  user_id           uuid primary key references public.profiles (id) on delete cascade,
  birth_date        date not null,
  gender            text not null check (gender in ('woman', 'man', 'nonbinary')),
  province          smallint not null check (province between 1 and 81),
  about             text not null default '' check (char_length(about) <= 300),
  job               text not null default '' check (char_length(job) <= 60),
  education         text not null default '' check (char_length(education) <= 60),
  friend            boolean not null default true,
  dating            boolean not null default false,
  interested_in     text[] not null default '{}' check (interested_in <@ array['woman', 'man', 'nonbinary']),
  age_min           smallint not null default 18 check (age_min between 18 and 99),
  age_max           smallint not null default 99 check (age_max between 18 and 99),
  paused            boolean not null default false,
  consent_version   text not null check (char_length(consent_version) between 1 and 20),
  consented_at      timestamptz not null default now(),
  suspended_until   timestamptz,
  suspension_reason text check (char_length(suspension_reason) <= 500),
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  constraint match_profiles_mode check (friend or dating),
  constraint match_profiles_dating check (not dating or cardinality(interested_in) > 0),
  constraint match_profiles_ages check (age_min <= age_max)
);

comment on table public.match_profiles is
  'owner: matching. Opt-in matching profile (18+, explicit consent); the user''s own write, suspension by the platform team.';

create table public.match_photos (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references public.match_profiles (user_id) on delete cascade,
  path       text not null check (char_length(path) <= 200),
  position   smallint not null check (position between 0 and 5),
  created_at timestamptz not null default now(),
  constraint match_photos_folder check (path like user_id::text || '/%'),
  constraint match_photos_position unique (user_id, position) deferrable initially deferred
);

comment on table public.match_photos is 'owner: matching. Up to 6 photos in Storage match-photos; position 0 is the cover.';

create table public.match_swipes (
  swiper_id  uuid not null references public.profiles (id) on delete cascade,
  target_id  uuid not null references public.profiles (id) on delete cascade,
  mode       text not null check (mode in ('friend', 'dating')),
  liked      boolean not null,
  created_at timestamptz not null default now(),
  primary key (swiper_id, target_id, mode),
  constraint match_swipes_not_self check (swiper_id <> target_id)
);

comment on table public.match_swipes is 'owner: matching. Likes and passes; written by the backend (daily like limit).';

create index match_swipes_target_idx on public.match_swipes (target_id, mode) where liked;
create index match_swipes_today_idx on public.match_swipes (swiper_id, created_at desc) where liked;

create table public.matches (
  id         uuid primary key default gen_random_uuid(),
  user_a     uuid not null references public.profiles (id) on delete cascade,
  user_b     uuid not null references public.profiles (id) on delete cascade,
  mode       text not null check (mode in ('friend', 'dating')),
  created_at timestamptz not null default now(),
  ended_at   timestamptz,
  ended_by   uuid references public.profiles (id) on delete set null,
  constraint matches_ordered check (user_a < user_b),
  constraint matches_pair unique (user_a, user_b, mode)
);

comment on table public.matches is
  'owner: matching. Mutual likes, the pair once (smaller id first); written by the backend. An ended match closes their chat.';

create index matches_b_idx on public.matches (user_b);

create table public.matching_settings (
  id               boolean primary key default true check (id),
  daily_free_likes int not null default 10 check (daily_free_likes between 1 and 1000),
  updated_at       timestamptz not null default now()
);

comment on table public.matching_settings is 'owner: matching. One row; changed by the platform team.';

insert into public.matching_settings default values;

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------
create function private.raise_match_rule(code text)
returns void
language plpgsql
set search_path = ''
as $$
begin
  raise exception '%', code using errcode = 'P0001';
end;
$$;

-- Full years on Turkey's calendar.
create function private.match_age(birth date)
returns int
language sql
stable
set search_path = ''
as $$
  select extract(year from age((now() at time zone 'Europe/Istanbul')::date, birth))::int;
$$;

-- Shown to others: opted in, not paused or suspended, an adult with an active account and at least 2 photos.
create function private.is_match_profile_live(uid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.match_profiles p
    where p.user_id = uid
      and not p.paused
      and (p.suspended_until is null or p.suspended_until <= now())
      and private.match_age(p.birth_date) >= 18
      and private.is_account_active(uid)
      and (select count(*) from public.match_photos f where f.user_id = uid) >= 2
  );
$$;

-- Active groups both people are members or followers of.
create function private.shared_groups(a uuid, b uuid)
returns setof uuid
language sql
stable
security definer
set search_path = ''
as $$
  with ga as (
    select m.group_id from public.group_members m where m.user_id = a
    union select f.group_id from public.group_follows f where f.user_id = a
  ), gb as (
    select m.group_id from public.group_members m where m.user_id = b
    union select f.group_id from public.group_follows f where f.user_id = b
  )
  select ga.group_id from ga join gb on gb.group_id = ga.group_id
  join public.groups g on g.id = ga.group_id and g.status = 'active';
$$;

-- Whether viewer and target belong in each other's deck for the mode; both directions of every preference.
create function private.match_fits(viewer uuid, target uuid, deck text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select viewer <> target
    and private.is_match_profile_live(viewer)
    and private.is_match_profile_live(target)
    and not private.is_blocked_between(viewer, target)
    and exists (
      select 1 from public.match_profiles v, public.match_profiles t
      where v.user_id = viewer and t.user_id = target
        and case deck
              when 'friend' then v.friend and t.friend
              when 'dating' then v.dating and t.dating
                and t.gender = any (v.interested_in) and v.gender = any (t.interested_in)
                and private.match_age(t.birth_date) between v.age_min and v.age_max
                and private.match_age(v.birth_date) between t.age_min and t.age_max
              else false
            end
    )
    and exists (select 1 from private.shared_groups(viewer, target));
$$;

create function private.are_matched(a uuid, b uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.matches m
    where m.user_a = least(a, b) and m.user_b = greatest(a, b) and m.ended_at is null
  );
$$;

-- A match between them ended and none is running: their chat stays closed.
create function private.match_ended_between(a uuid, b uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select not private.are_matched(a, b) and exists (
    select 1 from public.matches m
    where m.user_a = least(a, b) and m.user_b = greatest(a, b) and m.ended_at is not null
  );
$$;

-- The signed-in user sees target's matching profile and photos: their own, a match, someone in their deck,
-- or the platform team reviewing reports.
create function private.can_view_match_profile(target uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select target = (select auth.uid())
    or (private.are_matched((select auth.uid()), target) and private.is_account_active(target))
    or private.match_fits((select auth.uid()), target, 'friend')
    or private.match_fits((select auth.uid()), target, 'dating')
    or private.is_platform_staff();
$$;

revoke all on function private.raise_match_rule(text), private.match_age(date), private.is_match_profile_live(uuid),
  private.shared_groups(uuid, uuid), private.match_fits(uuid, uuid, text), private.are_matched(uuid, uuid),
  private.match_ended_between(uuid, uuid), private.can_view_match_profile(uuid) from public;
grant execute on function private.raise_match_rule(text), private.match_age(date), private.is_match_profile_live(uuid),
  private.shared_groups(uuid, uuid),
  private.match_fits(uuid, uuid, text), private.are_matched(uuid, uuid), private.match_ended_between(uuid, uuid),
  private.can_view_match_profile(uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------
alter table public.match_profiles enable row level security;
alter table public.match_photos enable row level security;
alter table public.match_swipes enable row level security;
alter table public.matches enable row level security;
alter table public.matching_settings enable row level security;

revoke all on public.match_profiles, public.match_photos, public.match_swipes, public.matches, public.matching_settings
  from anon, authenticated;
grant select on public.match_profiles, public.match_photos, public.match_swipes, public.matches, public.matching_settings
  to authenticated;
grant insert (user_id, birth_date, gender, province, about, job, education, friend, dating, interested_in, age_min, age_max,
              paused, consent_version),
  update (birth_date, gender, province, about, job, education, friend, dating, interested_in, age_min, age_max, paused,
          consent_version)
  on public.match_profiles to authenticated;
grant insert (user_id, path, position), update (position), delete on public.match_photos to authenticated;

create policy match_profiles_select on public.match_profiles for select to authenticated
  using (private.can_view_match_profile(user_id));
create policy match_profiles_insert_own on public.match_profiles for insert to authenticated
  with check (user_id = (select auth.uid()) and (select private.is_account_active(auth.uid())));
create policy match_profiles_update_own on public.match_profiles for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

create policy match_photos_select on public.match_photos for select to authenticated
  using (private.can_view_match_profile(user_id));
create policy match_photos_insert_own on public.match_photos for insert to authenticated
  with check (user_id = (select auth.uid()));
create policy match_photos_update_own on public.match_photos for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy match_photos_delete_own on public.match_photos for delete to authenticated
  using (user_id = (select auth.uid()));

create policy match_swipes_select_own on public.match_swipes for select to authenticated
  using (swiper_id = (select auth.uid()));
create policy matches_select_own on public.matches for select to authenticated
  using ((select auth.uid()) in (user_a, user_b));
create policy matching_settings_select on public.matching_settings for select to authenticated using (true);

-- ---------------------------------------------------------------------------
-- Triggers
-- ---------------------------------------------------------------------------

-- 18+ on the profile's own write; consent renews with its version; the platform's suspension stays as it is.
create function private.match_profiles_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if private.match_age(new.birth_date) < 18 or new.birth_date < date '1900-01-01' then
    perform private.raise_match_rule('match_underage');
  end if;
  if tg_op = 'INSERT' then
    new.consented_at := now();
    new.created_at := now();
  elsif new.consent_version is distinct from old.consent_version then
    new.consented_at := now();
  end if;
  new.updated_at := now();
  return new;
end;
$$;

create trigger match_profiles_guard
  before insert or update on public.match_profiles
  for each row execute function private.match_profiles_guard();

-- ---------------------------------------------------------------------------
-- Storage: match-photos, read only by whoever may see the profile
-- ---------------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types) values
  ('match-photos', 'match-photos', false, 5242880, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

create function private.folder_owner(object_name text)
returns uuid
language sql
immutable
set search_path = ''
as $$
  select case when split_part(object_name, '/', 1) ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
              then split_part(object_name, '/', 1)::uuid end;
$$;

revoke all on function private.folder_owner(text) from public;
grant execute on function private.folder_owner(text) to authenticated, service_role;

create policy match_photos_storage_insert on storage.objects for insert to authenticated
  with check (bucket_id = 'match-photos' and private.folder_owner(name) = (select auth.uid()));
create policy match_photos_storage_delete on storage.objects for delete to authenticated
  using (bucket_id = 'match-photos' and private.folder_owner(name) = (select auth.uid()));
create policy match_photos_storage_select on storage.objects for select to authenticated
  using (bucket_id = 'match-photos' and private.can_view_match_profile(private.folder_owner(name)));

-- ---------------------------------------------------------------------------
-- RPCs
-- ---------------------------------------------------------------------------

-- One person as their card shows them to viewer.
create function private.match_card(viewer uuid, target uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'user_id', t.user_id,
    'display_name', p.display_name,
    'age', private.match_age(t.birth_date),
    'gender', t.gender,
    'province', t.province,
    'about', t.about,
    'job', t.job,
    'education', t.education,
    'photos', coalesce((select jsonb_agg(jsonb_build_object('id', f.id, 'path', f.path) order by f.position)
                        from public.match_photos f where f.user_id = t.user_id), '[]'),
    'interests', coalesce((select jsonb_agg(i.category_slug order by i.category_slug)
                           from public.profile_interests i where i.user_id = t.user_id), '[]'),
    'shared_interests', coalesce((select jsonb_agg(i.category_slug order by i.category_slug)
                                  from public.profile_interests i
                                  join public.profile_interests mine on mine.category_slug = i.category_slug and mine.user_id = viewer
                                  where i.user_id = t.user_id), '[]'),
    'shared_groups', coalesce((select jsonb_agg(jsonb_build_object('name', g.name, 'handle', g.handle) order by g.name)
                               from public.groups g where g.id in (select private.shared_groups(viewer, t.user_id))), '[]')
  )
  from public.match_profiles t
  join public.profiles p on p.id = t.user_id
  where t.user_id = target;
$$;

-- The next people of the signed-in user's deck: most shared groups first.
-- A pass is forgotten after 90 days; a like or a match (even an ended one) is not.
create function private.match_deck(deck text, page_size int)
returns setof jsonb
language sql
stable
security definer
set search_path = ''
as $$
  with me as (select (select auth.uid()) as id),
  pool as (
    select t.user_id, (select count(*) from private.shared_groups(me.id, t.user_id)) as shared, t.updated_at
    from public.match_profiles t, me
    where t.user_id <> me.id
      and private.match_fits(me.id, t.user_id, deck)
      and not exists (
        select 1 from public.match_swipes s
        where s.swiper_id = me.id and s.target_id = t.user_id and s.mode = deck
          and (s.liked or s.created_at > now() - interval '90 days')
      )
      and not exists (
        select 1 from public.matches m
        where m.user_a = least(me.id, t.user_id) and m.user_b = greatest(me.id, t.user_id) and m.mode = deck
      )
  )
  select private.match_card((select id from me), pool.user_id)
  from pool
  order by pool.shared desc, pool.updated_at desc, pool.user_id
  limit least(greatest(page_size, 1), 50);
$$;

create function public.match_deck(deck text, page_size int default 20)
returns setof jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.match_deck(deck, page_size);
$$;

-- The signed-in user's running matches, newest first; the username shows once matched.
create function private.my_matches()
returns setof jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select private.match_card((select auth.uid()), other.id)
    || jsonb_build_object('match_id', m.id, 'mode', m.mode, 'matched_at', m.created_at, 'username', other.username)
  from public.matches m
  cross join lateral (
    select p.id, p.username from public.profiles p
    where p.id = case when m.user_a = (select auth.uid()) then m.user_b else m.user_a end
  ) other
  where (select auth.uid()) in (m.user_a, m.user_b)
    and m.ended_at is null
    and private.is_account_active(other.id)
    and not private.is_blocked_between((select auth.uid()), other.id)
    and exists (select 1 from public.match_profiles t where t.user_id = other.id)
  order by m.created_at desc;
$$;

create function public.my_matches()
returns setof jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.my_matches();
$$;

-- Swaps two of the user's own photos (making a new cover); the position constraint is checked at commit.
create function public.swap_match_photos(first uuid, second uuid)
returns void
language sql
security invoker
set search_path = ''
as $$
  update public.match_photos f set position = o.position
  from public.match_photos o
  where f.id in (first, second) and o.id in (first, second) and o.id <> f.id
    and f.user_id = (select auth.uid()) and o.user_id = f.user_id;
$$;

revoke all on function public.swap_match_photos(uuid, uuid) from public;
grant execute on function public.swap_match_photos(uuid, uuid) to authenticated;

-- Likes left today (Turkey's day) under the free limit.
create function private.match_likes_left()
returns int
language sql
stable
security definer
set search_path = ''
as $$
  select greatest(
    (select s.daily_free_likes from public.matching_settings s)
    - (select count(*)::int from public.match_swipes w
       where w.swiper_id = (select auth.uid()) and w.liked
         and w.created_at >= ((now() at time zone 'Europe/Istanbul')::date)::timestamp at time zone 'Europe/Istanbul'),
    0);
$$;

create function public.match_likes_left()
returns int
language sql
stable
security invoker
set search_path = ''
as $$
  select private.match_likes_left();
$$;

revoke all on function private.match_card(uuid, uuid), private.match_deck(text, int), private.my_matches(),
  private.match_likes_left(), public.match_deck(text, int), public.my_matches(), public.match_likes_left() from public;
-- match_card answers for anyone, so only the definer functions above call it.
grant execute on function private.match_deck(text, int), private.my_matches(),
  private.match_likes_left(), public.match_deck(text, int), public.my_matches(), public.match_likes_left()
  to authenticated;
grant execute on function private.match_likes_left() to service_role;

-- ---------------------------------------------------------------------------
-- Notifications: a new match (notifications owns the table and the preferences)
-- ---------------------------------------------------------------------------
alter table public.notification_preferences add column match_alerts boolean not null default true;
grant insert (match_alerts), update (match_alerts) on public.notification_preferences to authenticated;

alter table public.notifications add column match_id uuid references public.matches (id) on delete cascade;
alter table public.notifications drop constraint notifications_type_check;
alter table public.notifications add constraint notifications_type_check
  check (type in ('like', 'comment', 'reply', 'comment_like', 'mention', 'follow', 'follow_request', 'follow_accepted',
                  'live_scheduled', 'live_started', 'event_promoted', 'event_updated', 'event_canceled', 'event_reminder',
                  'case_vote', 'sanction_applied', 'appeal_submitted', 'appeal_decided',
                  'event_approved', 'event_declined', 'event_review', 'goal_completed',
                  'teammate_request', 'teammate_accepted', 'match_created'));

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
             when 'live_scheduled' then p.live_broadcasts
             when 'live_started' then p.live_broadcasts
             when 'match_created' then p.match_alerts
             else true
           end
    from public.notification_preferences p where p.user_id = uid
  ), true);
$$;

create function private.notify_match_created()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.notifications (recipient_id, actor_id, type, match_id)
  select pair.recipient, pair.actor, 'match_created', new.id
  from (values (new.user_a, new.user_b), (new.user_b, new.user_a)) as pair (recipient, actor)
  where private.wants_notification(pair.recipient, 'match_created');
  return null;
end;
$$;

revoke all on function private.notify_match_created() from public;

create trigger notify_match_created
  after insert on public.matches
  for each row execute function private.notify_match_created();

-- An ended match takes its notifications with it.
create function private.matches_after_end()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  delete from public.notifications where match_id = new.id;
  return null;
end;
$$;

revoke all on function private.matches_after_end() from public;

create trigger matches_after_end
  after update of ended_at on public.matches
  for each row when (old.ended_at is null and new.ended_at is not null)
  execute function private.matches_after_end();

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
    'live_scheduled_at', (select b.scheduled_at from public.live_broadcasts b where b.id = n.live_id),
    'event_id', n.event_id,
    'event_title', (select e.title from public.events e where e.id = n.event_id),
    'event_starts_at', (select e.starts_at from public.events e where e.id = n.event_id),
    'group', (select jsonb_build_object('id', g.id, 'handle', g.handle, 'name', g.name, 'logo_path', g.logo_path)
              from public.groups g where g.id = n.group_id),
    'sanction_type', (select s.type from public.sanctions s where s.id = n.sanction_id),
    'goal_id', n.goal_id,
    'goal_title', (select g.title from public.goals g where g.id = n.goal_id),
    'match_id', n.match_id,
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
-- Messaging between matches (messaging owns these functions)
-- ---------------------------------------------------------------------------

-- As in 0024: a match writes without a request; an ended match closes the chat.
create or replace function private.message_blocker(uid uuid, conv uuid)
returns text
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  c public.conversations;
  peer uuid;
  mine text;
  theirs text;
begin
  select * into c from public.conversations where id = conv;
  if c.id is null or uid is null or not private.is_account_active(uid) or not private.can_read_conversation_as(uid, conv) then
    return 'message_forbidden';
  end if;
  if c.kind = 'group' then
    if (select g.status from public.groups g where g.id = c.group_id) <> 'active' then
      return 'message_forbidden';
    end if;
    if private.is_group_muted(c.group_id, uid) then
      return 'message_muted';
    end if;
    if c.admins_only and not private.user_has_group_permission(uid, c.group_id, 'posts.publish') then
      return 'message_admins_only';
    end if;
    return null;
  end if;
  peer := private.conversation_peer(conv, uid);
  if private.is_blocked_between(uid, peer) then
    return 'blocked';
  end if;
  if not private.is_account_active(peer) then
    return 'message_forbidden';
  end if;
  if private.match_ended_between(uid, peer) then
    return 'match_ended';
  end if;
  if private.are_matched(uid, peer) then
    return null;
  end if;
  select m.state into mine from public.conversation_members m where m.conversation_id = conv and m.user_id = uid;
  select m.state into theirs from public.conversation_members m where m.conversation_id = conv and m.user_id = peer;
  if mine = 'request' then
    return 'message_request_pending';
  end if;
  if theirs = 'declined' then
    return 'message_declined';
  end if;
  return null;
end;
$$;

-- As in 0024: matches open an active chat whatever the privacy, and an earlier request between them is accepted.
create or replace function private.open_direct_conversation(other uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
  conv uuid;
  other_state text;
  other_private boolean;
  matched boolean;
begin
  if actor is null or other is null or actor = other or not private.is_account_active(actor) then
    perform private.raise_message_rule('message_forbidden');
  end if;
  select p.is_private into other_private from public.profiles p where p.id = other and private.is_account_active(p.id);
  if other_private is null or private.has_blocked(other, actor) then
    perform private.raise_message_rule('message_not_found');
  end if;
  if private.has_blocked(actor, other) then
    perform private.raise_message_rule('blocked');
  end if;
  if private.match_ended_between(actor, other) then
    perform private.raise_message_rule('match_ended');
  end if;
  matched := private.are_matched(actor, other);

  select c.id into conv from public.conversations c where c.user_a = least(actor, other) and c.user_b = greatest(actor, other);
  if conv is not null then
    if matched then
      update public.conversation_members set state = 'active' where conversation_id = conv and state <> 'active';
    end if;
    select m.state into other_state from public.conversation_members m where m.conversation_id = conv and m.user_id = other;
    return jsonb_build_object('id', conv, 'state', other_state);
  end if;

  if other_private and not matched and not private.user_follows(actor, other) then
    perform private.raise_message_rule('message_private');
  end if;
  if matched or private.are_teammates(actor, other) or (private.user_follows(actor, other) and private.user_follows(other, actor)) then
    other_state := 'active';
  else
    other_state := 'request';
    if (select count(*) from public.conversations c
        join public.conversation_members m on m.conversation_id = c.id and m.user_id <> actor and m.state = 'request'
        where c.created_by = actor and c.created_at > now() - interval '24 hours') >= 20 then
      perform private.raise_message_rule('message_rate_limited');
    end if;
  end if;

  insert into public.conversations (kind, user_a, user_b, created_by)
  values ('direct', least(actor, other), greatest(actor, other), actor)
  returning id into conv;
  insert into public.conversation_members (conversation_id, user_id, state) values (conv, actor, 'active'), (conv, other, other_state);
  return jsonb_build_object('id', conv, 'state', other_state);
end;
$$;

-- ---------------------------------------------------------------------------
-- Reports of matching profiles and photos (moderation owns reports)
-- ---------------------------------------------------------------------------
alter table public.reports drop constraint reports_target_type_check;
alter table public.reports add constraint reports_target_type_check
  check (target_type in ('post', 'comment', 'event', 'live_comment', 'user', 'message', 'match_profile', 'match_photo'));

-- As in 0024, with matching profiles and photos; both go to the platform team.
create or replace function private.report_target(kind text, target text, out target_group uuid, out subject uuid, out excerpt text)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  target_uuid uuid;
begin
  if kind = 'live_comment' then
    if target !~ '^[0-9]{1,18}$' then
      return;
    end if;
    select b.group_id, c.user_id, c.body into target_group, subject, excerpt
    from public.live_comments c join public.live_broadcasts b on b.id = c.broadcast_id
    where c.id = target::bigint and private.can_view_live(b.id);
    return;
  end if;
  if target !~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' then
    return;
  end if;
  target_uuid := target::uuid;

  if kind = 'post' then
    select p.group_id, coalesce(p.author_id, g.owner_id), p.caption into target_group, subject, excerpt
    from public.posts p left join public.groups g on g.id = p.group_id
    where p.id = target_uuid and p.removed_at is null and private.can_view_post(p.id);
  elsif kind = 'comment' then
    select p.group_id, c.author_id, c.body into target_group, subject, excerpt
    from public.comments c join public.posts p on p.id = c.post_id
    where c.id = target_uuid and c.removed_at is null and private.can_view_post(p.id);
  elsif kind = 'event' then
    select e.group_id, coalesce(e.created_by, g.owner_id), e.title || ' · ' || e.description into target_group, subject, excerpt
    from public.events e join public.groups g on g.id = e.group_id
    where e.id = target_uuid and private.is_group_visible(e.group_id);
  elsif kind = 'user' then
    select null, p.id, '@' || p.username || ' · ' || p.display_name || ' · ' || p.bio into target_group, subject, excerpt
    from public.profiles p
    where p.id = target_uuid and private.is_account_active(p.id);
  elsif kind = 'message' then
    select c.group_id, m.sender_id, nullif(m.body, '') into target_group, subject, excerpt
    from public.messages m join public.conversations c on c.id = m.conversation_id
    where m.id = target_uuid and m.deleted_at is null and private.can_read_conversation(c.id);
    if subject is not null and excerpt is null then
      excerpt := '[Fotoğraf]';
    end if;
  elsif kind = 'match_profile' then
    select null, t.user_id, concat_ws(' · ', p.display_name, nullif(t.job, ''), nullif(t.about, '')) into target_group, subject, excerpt
    from public.match_profiles t join public.profiles p on p.id = t.user_id
    where t.user_id = target_uuid and t.user_id <> (select auth.uid()) and private.can_view_match_profile(t.user_id);
  elsif kind = 'match_photo' then
    select null, f.user_id, f.path into target_group, subject, excerpt
    from public.match_photos f
    where f.id = target_uuid and f.user_id <> (select auth.uid()) and private.can_view_match_profile(f.user_id);
  end if;
  excerpt := left(btrim(coalesce(excerpt, '')), 500);
end;
$$;
