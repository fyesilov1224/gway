-- 0021_teammates
-- Phase 13: teammate preferences, explainable suggestions, requests and the
-- teammates relation. Rules: docs/ARCHITECTURE.md §3c (Ekip arkadaşı).

-- ---------------------------------------------------------------------------
-- teammate_preferences, teammate_requests, teammates
-- owner: profile
-- ---------------------------------------------------------------------------
create table public.teammate_preferences (
  user_id      uuid primary key references public.profiles (id) on delete cascade,
  looking      boolean not null default false,
  level        text check (level in ('beginner', 'intermediate', 'advanced')),
  availability text[] not null default '{}'
               check (availability <@ array['weekday_morning', 'weekday_evening', 'weekend_morning', 'weekend_afternoon']),
  province     smallint check (province between 1 and 81),
  note         text not null default '' check (char_length(note) <= 140),
  updated_at   timestamptz not null default now()
);

comment on table public.teammate_preferences is
  'owner: profile. The user''s own teammate settings; read only by them (the province is never shown).';

create index teammate_preferences_looking_idx on public.teammate_preferences (user_id) where looking;

create table public.teammate_requests (
  requester_id uuid not null references public.profiles (id) on delete cascade,
  target_id    uuid not null references public.profiles (id) on delete cascade,
  message      text not null default '' check (char_length(message) <= 200),
  created_at   timestamptz not null default now(),
  primary key (requester_id, target_id),
  constraint teammate_requests_not_self check (requester_id <> target_id)
);

comment on table public.teammate_requests is 'owner: profile. Pending teammate requests; written by the backend.';

create index teammate_requests_target_idx on public.teammate_requests (target_id, created_at desc);

create table public.teammates (
  user_a     uuid not null references public.profiles (id) on delete cascade,
  user_b     uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_a, user_b),
  constraint teammates_ordered check (user_a < user_b)
);

comment on table public.teammates is 'owner: profile. Accepted teammates; the pair is stored once, smaller id first.';

create index teammates_b_idx on public.teammates (user_b);

create function private.are_teammates(a uuid, b uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (select 1 from public.teammates t where t.user_a = least(a, b) and t.user_b = greatest(a, b));
$$;

revoke all on function private.are_teammates(uuid, uuid) from public;
grant execute on function private.are_teammates(uuid, uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------
alter table public.teammate_preferences enable row level security;
alter table public.teammate_requests enable row level security;
alter table public.teammates enable row level security;

revoke all on public.teammate_preferences, public.teammate_requests, public.teammates from anon, authenticated;
grant select on public.teammate_preferences, public.teammate_requests, public.teammates to authenticated;
grant insert (user_id, looking, level, availability, province, note),
  update (user_id, looking, level, availability, province, note) on public.teammate_preferences to authenticated;

create policy teammate_preferences_own on public.teammate_preferences for select to authenticated
  using (user_id = (select auth.uid()));
create policy teammate_preferences_insert_own on public.teammate_preferences for insert to authenticated
  with check (user_id = (select auth.uid()));
create policy teammate_preferences_update_own on public.teammate_preferences for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

create policy teammate_requests_select_party on public.teammate_requests for select to authenticated
  using (requester_id = (select auth.uid()) or target_id = (select auth.uid()));
create policy teammates_select_party on public.teammates for select to authenticated
  using (user_a = (select auth.uid()) or user_b = (select auth.uid()));

-- ---------------------------------------------------------------------------
-- Triggers
-- ---------------------------------------------------------------------------
create function private.raise_profile_rule(code text)
returns void
language plpgsql
set search_path = ''
as $$
begin
  raise exception '%', code using errcode = 'P0001';
end;
$$;

create function private.teammate_preferences_touch()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.note := btrim(new.note);
  new.updated_at := now();
  return new;
end;
$$;

create trigger teammate_preferences_touch
  before insert or update on public.teammate_preferences
  for each row execute function private.teammate_preferences_touch();

-- Requests: from the actor, to someone looking, without a block, at most 20 a day; the target or the
-- requester removes it (a block or an acceptance removes it too).
create function private.teammate_requests_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
begin
  if tg_op = 'INSERT' then
    if actor is null or actor is distinct from new.requester_id or not private.is_account_active(actor)
       or not private.is_account_active(new.target_id) then
      perform private.raise_profile_rule('teammate_forbidden');
    end if;
    if private.is_blocked_between(new.requester_id, new.target_id) then
      perform private.raise_profile_rule('blocked');
    end if;
    if not exists (select 1 from public.teammate_preferences p where p.user_id = new.target_id and p.looking) then
      perform private.raise_profile_rule('teammate_not_looking');
    end if;
    if private.are_teammates(new.requester_id, new.target_id) then
      perform private.raise_profile_rule('already_teammates');
    end if;
    if (select count(*) from public.teammate_requests r
        where r.requester_id = actor and r.created_at > now() - interval '24 hours') >= 20 then
      perform private.raise_profile_rule('teammate_rate_limited');
    end if;
    new.message := btrim(new.message);
    new.created_at := now();
    return new;
  end if;
  if tg_op = 'UPDATE' then
    perform private.raise_profile_rule('teammate_immutable');
  end if;
  if pg_trigger_depth() > 1 or actor in (old.requester_id, old.target_id) then
    return old;
  end if;
  perform private.raise_profile_rule('teammate_forbidden');
  return null;
end;
$$;

create trigger teammate_requests_guard
  before insert or update or delete on public.teammate_requests
  for each row execute function private.teammate_requests_guard();

-- A pair forms only by the target accepting a pending request; either side ends it.
create function private.teammates_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
begin
  if tg_op = 'INSERT' then
    if actor not in (new.user_a, new.user_b) or not exists (
      select 1 from public.teammate_requests r
      where r.target_id = actor and r.requester_id = case when actor = new.user_a then new.user_b else new.user_a end
    ) then
      perform private.raise_profile_rule('teammate_forbidden');
    end if;
    new.created_at := now();
    return new;
  end if;
  if tg_op = 'UPDATE' then
    perform private.raise_profile_rule('teammate_immutable');
  end if;
  if pg_trigger_depth() > 1 or actor in (old.user_a, old.user_b) then
    return old;
  end if;
  perform private.raise_profile_rule('teammate_forbidden');
  return null;
end;
$$;

create trigger teammates_guard
  before insert or update or delete on public.teammates
  for each row execute function private.teammates_guard();

-- A block ends requests both ways and the pair.
create function private.blocks_end_teammates()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  delete from public.teammate_requests
  where (requester_id = new.blocker_id and target_id = new.blocked_id)
     or (requester_id = new.blocked_id and target_id = new.blocker_id);
  delete from public.teammates where user_a = least(new.blocker_id, new.blocked_id) and user_b = greatest(new.blocker_id, new.blocked_id);
  return null;
end;
$$;

revoke all on function private.blocks_end_teammates() from public;

create trigger blocks_end_teammates
  after insert on public.blocks
  for each row execute function private.blocks_end_teammates();

-- ---------------------------------------------------------------------------
-- Notifications (notifications owns the table)
-- ---------------------------------------------------------------------------
alter table public.notifications drop constraint notifications_type_check;
alter table public.notifications add constraint notifications_type_check
  check (type in ('like', 'comment', 'reply', 'comment_like', 'mention', 'follow', 'follow_request', 'follow_accepted',
                  'live_started', 'event_promoted', 'event_updated', 'event_canceled', 'event_reminder',
                  'case_vote', 'sanction_applied', 'appeal_submitted', 'appeal_decided',
                  'event_approved', 'event_declined', 'event_review', 'goal_completed',
                  'teammate_request', 'teammate_accepted'));

create function private.notify_teammate_request()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform private.notify(new.target_id, new.requester_id, 'teammate_request');
  return null;
end;
$$;

create function private.notify_teammate_accepted()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
begin
  -- The one who accepted is the actor; the requester hears about it.
  perform private.notify(case when actor = new.user_a then new.user_b else new.user_a end, actor, 'teammate_accepted');
  delete from public.notifications
  where type = 'teammate_request' and recipient_id = actor and actor_id in (new.user_a, new.user_b);
  return null;
end;
$$;

revoke all on function private.notify_teammate_request(), private.notify_teammate_accepted() from public;

create trigger notify_teammate_request
  after insert on public.teammate_requests
  for each row execute function private.notify_teammate_request();
create trigger notify_teammate_accepted
  after insert on public.teammates
  for each row execute function private.notify_teammate_accepted();

-- ---------------------------------------------------------------------------
-- Suggestions and lists
-- ---------------------------------------------------------------------------

-- People looking for teammates who share something with the caller, with the reasons (§3c, Ekip arkadaşı).
create function private.teammate_suggestions()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  with me as (
    select (select auth.uid()) as uid,
           p.level, coalesce(p.availability, '{}') as availability, p.province
    from (select 1) one
    left join public.teammate_preferences p on p.user_id = (select auth.uid())
  ),
  candidates as (
    select c.user_id, c.level, c.availability, c.province, c.note,
      array(select ci.category_slug from public.profile_interests ci join public.profile_interests mi
            on mi.category_slug = ci.category_slug and mi.user_id = me.uid where ci.user_id = c.user_id) as interests,
      array(select g.name from public.group_members cm join public.group_members mm
            on mm.group_id = cm.group_id and mm.user_id = me.uid
            join public.groups g on g.id = cm.group_id and g.status = 'active'
            where cm.user_id = c.user_id) as groups,
      array(select unnest(c.availability) intersect select unnest(me.availability)) as times,
      me.level = c.level as same_level,
      me.province is not null and me.province = c.province as same_province
    from public.teammate_preferences c
    join public.profiles pr on pr.id = c.user_id
    cross join me
    where me.uid is not null and c.looking and c.user_id <> me.uid and not pr.is_private
      and private.is_account_active(c.user_id)
      and not private.is_blocked_between(c.user_id, me.uid)
      and not private.are_teammates(c.user_id, me.uid)
      and not exists (select 1 from public.teammate_requests r
                      where (r.requester_id = me.uid and r.target_id = c.user_id) or (r.requester_id = c.user_id and r.target_id = me.uid))
  ),
  scored as (
    select *, 3 * cardinality(interests) + 2 * cardinality(groups) + cardinality(times)
              + case when same_level then 2 else 0 end + case when same_province then 3 else 0 end as score
    from candidates
  )
  select coalesce(jsonb_agg(jsonb_build_object(
    'person', jsonb_build_object('id', p.id, 'username', p.username, 'display_name', p.display_name, 'avatar_path', p.avatar_path,
                                 'bio', p.bio),
    'level', s.level,
    'note', s.note,
    'score', s.score,
    'interests', (select coalesce(jsonb_agg(cat.name order by cat.sort_order), '[]'::jsonb) from public.categories cat where cat.slug = any (s.interests)),
    'groups', to_jsonb(s.groups),
    'times', to_jsonb(s.times),
    'same_level', coalesce(s.same_level, false),
    'same_province', s.same_province
  ) order by s.score desc, p.display_name), '[]'::jsonb)
  from (select * from scored where score >= 3 order by score desc limit 30) s
  join public.profiles p on p.id = s.user_id;
$$;

create function public.teammate_suggestions()
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.teammate_suggestions();
$$;

-- The caller's teammates and pending requests both ways.
create function private.my_teammates()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  with me as (select (select auth.uid()) as uid)
  select jsonb_build_object(
    'teammates', coalesce((
      select jsonb_agg(jsonb_build_object('id', p.id, 'username', p.username, 'display_name', p.display_name,
                                          'avatar_path', p.avatar_path, 'since', t.created_at) order by t.created_at desc)
      from public.teammates t, me
      join public.profiles p on true
      where me.uid in (t.user_a, t.user_b) and p.id = case when t.user_a = me.uid then t.user_b else t.user_a end), '[]'::jsonb),
    'incoming', coalesce((
      select jsonb_agg(jsonb_build_object('id', p.id, 'username', p.username, 'display_name', p.display_name,
                                          'avatar_path', p.avatar_path, 'message', r.message, 'created_at', r.created_at)
                       order by r.created_at desc)
      from public.teammate_requests r join public.profiles p on p.id = r.requester_id, me
      where r.target_id = me.uid), '[]'::jsonb),
    'outgoing', coalesce((
      select jsonb_agg(jsonb_build_object('id', p.id, 'username', p.username, 'display_name', p.display_name,
                                          'avatar_path', p.avatar_path, 'message', r.message, 'created_at', r.created_at)
                       order by r.created_at desc)
      from public.teammate_requests r join public.profiles p on p.id = r.target_id, me
      where r.requester_id = me.uid), '[]'::jsonb)
  )
  from me;
$$;

create function public.my_teammates()
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.my_teammates();
$$;

-- What a profile shows: "Ekip arıyor · Orta seviye" and the caller's relation; never the province.
create function private.teammate_status(target uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select case when not private.can_view_user_content(target) then null else jsonb_build_object(
    'looking', coalesce((select p.looking from public.teammate_preferences p where p.user_id = target), false),
    'level', (select p.level from public.teammate_preferences p where p.user_id = target and p.looking),
    'relation', case
      when target = (select auth.uid()) then 'self'
      when private.are_teammates(target, (select auth.uid())) then 'teammates'
      when exists (select 1 from public.teammate_requests r where r.requester_id = (select auth.uid()) and r.target_id = target) then 'requested'
      when exists (select 1 from public.teammate_requests r where r.requester_id = target and r.target_id = (select auth.uid())) then 'incoming'
      else 'none'
    end
  ) end;
$$;

create function public.teammate_status(target uuid)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.teammate_status(target);
$$;

revoke all on function private.teammate_suggestions(), private.my_teammates(), private.teammate_status(uuid) from public;
grant execute on function private.teammate_suggestions(), private.my_teammates(), private.teammate_status(uuid) to authenticated;
revoke all on function public.teammate_suggestions(), public.my_teammates(), public.teammate_status(uuid) from public, anon;
grant execute on function public.teammate_suggestions(), public.my_teammates(), public.teammate_status(uuid) to authenticated;
