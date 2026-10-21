-- 0020_goals
-- Phase 12: personal, group and team goals measured from verified records,
-- manager-approved tasks, lasting completions with a goal badge.
-- Rules: docs/ARCHITECTURE.md §3d (Hedefler ve görevler).

-- ---------------------------------------------------------------------------
-- goals, goal_teams, goal_team_members, goal_claims, goal_completions
-- owner: events
-- ---------------------------------------------------------------------------
create table public.goals (
  id          uuid primary key default gen_random_uuid(),
  group_id    uuid not null references public.groups (id) on delete cascade,
  created_by  uuid references public.profiles (id) on delete set null,
  title       text not null check (char_length(btrim(title)) between 3 and 80),
  description text not null default '' check (char_length(description) <= 500),
  kind        text not null check (kind in ('personal', 'group', 'team', 'task')),
  metric      text check (metric in ('attended', 'organized', 'memories')),
  target      int check (target between 1 and 1000),
  starts_at   timestamptz not null,
  ends_at     timestamptz not null,
  canceled_at timestamptz,
  created_at  timestamptz not null default now(),
  constraint goals_measure check ((kind = 'task') = (metric is null) and (metric is null) = (target is null)),
  constraint goals_period check (ends_at > starts_at and ends_at - starts_at <= interval '92 days')
);

comment on table public.goals is 'owner: events. Goals of a group; progress is counted from events, attendance and memories.';

create index goals_group_idx on public.goals (group_id, ends_at desc);
create index goals_running_idx on public.goals (ends_at) where canceled_at is null;

create table public.goal_teams (
  id         uuid primary key default gen_random_uuid(),
  goal_id    uuid not null references public.goals (id) on delete cascade,
  name       text not null check (char_length(btrim(name)) between 2 and 40),
  created_at timestamptz not null default now()
);

create index goal_teams_goal_idx on public.goal_teams (goal_id);

create table public.goal_team_members (
  goal_id uuid not null references public.goals (id) on delete cascade,
  team_id uuid not null references public.goal_teams (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  primary key (goal_id, user_id)
);

comment on table public.goal_team_members is 'owner: events. One team per person and goal.';

create index goal_team_members_team_idx on public.goal_team_members (team_id);

create table public.goal_claims (
  goal_id    uuid not null references public.goals (id) on delete cascade,
  user_id    uuid not null references public.profiles (id) on delete cascade,
  note       text not null default '' check (char_length(note) <= 300),
  status     text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  decided_by uuid references public.profiles (id) on delete set null,
  decided_at timestamptz,
  created_at timestamptz not null default now(),
  primary key (goal_id, user_id),
  constraint goal_claims_decided check ((status = 'pending') = (decided_at is null))
);

comment on table public.goal_claims is 'owner: events. "Yaptım" of a task goal; an events.manage holder approves or rejects it.';

create table public.goal_completions (
  goal_id      uuid not null references public.goals (id) on delete cascade,
  user_id      uuid not null references public.profiles (id) on delete cascade,
  completed_at timestamptz not null default now(),
  primary key (goal_id, user_id)
);

comment on table public.goal_completions is 'owner: events. Lasting record of a reached goal; the goal badge.';

create index goal_completions_user_idx on public.goal_completions (user_id, completed_at desc);

alter table public.notifications add column goal_id uuid references public.goals (id) on delete cascade;
alter table public.notifications drop constraint notifications_type_check;
alter table public.notifications add constraint notifications_type_check
  check (type in ('like', 'comment', 'reply', 'comment_like', 'mention', 'follow', 'follow_request', 'follow_accepted',
                  'live_started', 'event_promoted', 'event_updated', 'event_canceled', 'event_reminder',
                  'case_vote', 'sanction_applied', 'appeal_submitted', 'appeal_decided',
                  'event_approved', 'event_declined', 'event_review', 'goal_completed'));

-- ---------------------------------------------------------------------------
-- Measuring
-- ---------------------------------------------------------------------------

-- The goal's metric counted within its group and period, for the given people (null: everyone).
-- The rules are the contribution rules of Phase 11.
create function private.goal_total(g public.goals, people uuid[])
returns int
language sql
stable
security definer
set search_path = ''
as $$
  select case g.metric
    when 'attended' then (
      select count(*)::int
      from public.event_attendees a join public.events e on e.id = a.event_id
      where e.group_id = g.group_id and e.starts_at >= g.starts_at and e.starts_at < g.ends_at
        and e.canceled_at is null and coalesce(e.ends_at, e.starts_at + interval '2 hours') <= now()
        and a.status = 'going' and a.no_show_at is null
        and (people is null or a.user_id = any (people)))
    when 'organized' then (
      select count(*)::int
      from public.events e
      where e.group_id = g.group_id and e.starts_at >= g.starts_at and e.starts_at < g.ends_at
        and e.canceled_at is null and coalesce(e.ends_at, e.starts_at + interval '2 hours') <= now()
        and (people is null or e.created_by = any (people))
        and (select count(*) from public.event_attendees a
             where a.event_id = e.id and a.status = 'going' and a.no_show_at is null and a.user_id is distinct from e.created_by) >= 2)
    when 'memories' then (
      select count(*)::int
      from public.posts p join public.events e on e.id = p.event_id
      where e.group_id = g.group_id and p.created_at >= g.starts_at and p.created_at < g.ends_at
        and p.removed_at is null and (people is null or p.author_id = any (people)))
    else 0
  end;
$$;

-- The people of uid's team in a team goal (empty without a team).
create function private.goal_team_of(target_goal uuid, uid uuid)
returns uuid[]
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(array_agg(m.user_id), '{}')
  from public.goal_team_members mine
  join public.goal_team_members m on m.team_id = mine.team_id
  where mine.goal_id = target_goal and mine.user_id = uid;
$$;

create function private.is_goal_running(g public.goals)
returns boolean
language sql
stable
set search_path = ''
as $$
  select g.canceled_at is null and g.starts_at <= now() and now() < g.ends_at;
$$;

create function private.notify_goal_completed(target_goal uuid, uid uuid)
returns void
language sql
security definer
set search_path = ''
as $$
  insert into public.notifications (recipient_id, actor_id, type, goal_id, group_id)
  select uid, coalesce(g.created_by, gr.owner_id), 'goal_completed', g.id, g.group_id
  from public.goals g join public.groups gr on gr.id = g.group_id
  where g.id = target_goal and private.is_account_active(uid) and uid <> coalesce(g.created_by, gr.owner_id);
$$;

-- Records who reached the measured goals that are running (or ended within a day); returns how many.
create function private.record_goal_completions()
returns int
language plpgsql
security definer
set search_path = ''
as $$
declare
  g public.goals;
  team record;
  person uuid;
  recorded int := 0;
begin
  for g in
    select * from public.goals
    where kind <> 'task' and canceled_at is null and starts_at <= now() and ends_at > now() - interval '1 day'
  loop
    if g.kind = 'personal' then
      for person in
        insert into public.goal_completions (goal_id, user_id)
        select g.id, m.user_id from public.group_members m
        where m.group_id = g.group_id and private.goal_total(g, array[m.user_id]) >= g.target
        on conflict do nothing
        returning user_id
      loop
        perform private.notify_goal_completed(g.id, person);
        recorded := recorded + 1;
      end loop;
    elsif g.kind = 'group' then
      if private.goal_total(g, null) >= g.target then
        for person in
          insert into public.goal_completions (goal_id, user_id)
          select g.id, m.user_id from public.group_members m
          where m.group_id = g.group_id and private.goal_total(g, array[m.user_id]) > 0
          on conflict do nothing
          returning user_id
        loop
          perform private.notify_goal_completed(g.id, person);
          recorded := recorded + 1;
        end loop;
      end if;
    else
      for team in
        select t.id, array_agg(m.user_id) as people
        from public.goal_teams t join public.goal_team_members m on m.team_id = t.id
        where t.goal_id = g.id
        group by t.id
      loop
        if private.goal_total(g, team.people) >= g.target then
          for person in
            insert into public.goal_completions (goal_id, user_id)
            select g.id, u from unnest(team.people) u
            where private.goal_total(g, array[u]) > 0
            on conflict do nothing
            returning user_id
          loop
            perform private.notify_goal_completed(g.id, person);
            recorded := recorded + 1;
          end loop;
        end if;
      end loop;
    end if;
  end loop;
  return recorded;
end;
$$;

revoke all on function private.goal_total(public.goals, uuid[]), private.goal_team_of(uuid, uuid), private.is_goal_running(public.goals),
  private.notify_goal_completed(uuid, uuid), private.record_goal_completions() from public;
grant execute on function private.is_goal_running(public.goals) to authenticated, service_role;
grant execute on function private.goal_total(public.goals, uuid[]), private.goal_team_of(uuid, uuid), private.record_goal_completions()
  to service_role;

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------
alter table public.goals enable row level security;
alter table public.goal_teams enable row level security;
alter table public.goal_team_members enable row level security;
alter table public.goal_claims enable row level security;
alter table public.goal_completions enable row level security;

revoke all on public.goals, public.goal_teams, public.goal_team_members, public.goal_claims, public.goal_completions
  from anon, authenticated;
grant select on public.goals, public.goal_teams, public.goal_team_members, public.goal_completions to anon, authenticated;
grant select, delete on public.goal_claims to authenticated;
grant insert (goal_id, user_id, note) on public.goal_claims to authenticated;

create policy goals_select_visible on public.goals for select to anon, authenticated
  using (private.is_group_visible(group_id));
create policy goal_teams_select_visible on public.goal_teams for select to anon, authenticated
  using (exists (select 1 from public.goals g where g.id = goal_id and private.is_group_visible(g.group_id)));
create policy goal_team_members_select_visible on public.goal_team_members for select to anon, authenticated
  using (exists (select 1 from public.goals g where g.id = goal_id and private.is_group_visible(g.group_id)));
create policy goal_completions_select_visible on public.goal_completions for select to anon, authenticated
  using (exists (select 1 from public.goals g where g.id = goal_id and private.is_group_visible(g.group_id)));
create policy goal_claims_select_own_or_manager on public.goal_claims for select to authenticated
  using (user_id = (select auth.uid())
         or exists (select 1 from public.goals g where g.id = goal_id and private.has_group_permission(g.group_id, 'events.manage')));
create policy goal_claims_insert_own on public.goal_claims for insert to authenticated
  with check (user_id = (select auth.uid()));
create policy goal_claims_delete_own on public.goal_claims for delete to authenticated
  using (user_id = (select auth.uid()) and status <> 'approved');

-- ---------------------------------------------------------------------------
-- Triggers
-- ---------------------------------------------------------------------------

-- Goals: opened by events.manage holders, at most 5 running per group; afterwards only canceled.
create function private.goals_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
begin
  if tg_op = 'DELETE' then
    if pg_trigger_depth() > 1 or not exists (select 1 from public.groups g where g.id = old.group_id) then
      return old;
    end if;
    perform private.raise_event_rule('goal_immutable');
  end if;
  if tg_op = 'INSERT' then
    if actor is null or actor is distinct from new.created_by or not private.has_group_permission(new.group_id, 'events.manage') then
      perform private.raise_event_rule('goal_forbidden');
    end if;
    if new.ends_at <= now() then
      perform private.raise_event_rule('goal_period_invalid');
    end if;
    perform 1 from public.groups where id = new.group_id for update;
    if (select count(*) from public.goals g where g.group_id = new.group_id and g.canceled_at is null and g.ends_at > now()) >= 5 then
      perform private.raise_event_rule('goal_limit_reached');
    end if;
    new.title := btrim(new.title);
    new.description := btrim(new.description);
    new.canceled_at := null;
    new.created_at := now();
    return new;
  end if;
  if pg_trigger_depth() > 1 and (new.created_by is distinct from old.created_by) then
    return new;
  end if;
  if (new.id, new.group_id, new.title, new.description, new.kind, new.metric, new.target, new.starts_at, new.ends_at, new.created_at)
     is distinct from
     (old.id, old.group_id, old.title, old.description, old.kind, old.metric, old.target, old.starts_at, old.ends_at, old.created_at)
     or old.canceled_at is not null or new.canceled_at is null then
    perform private.raise_event_rule('goal_immutable');
  end if;
  if not (private.has_group_permission(old.group_id, 'events.manage') or private.is_platform_staff(array['admin', 'moderator'])) then
    perform private.raise_event_rule('goal_forbidden');
  end if;
  new.canceled_at := now();
  return new;
end;
$$;

create trigger goals_guard
  before insert or update or delete on public.goals
  for each row execute function private.goals_guard();

-- Teams and their members: set up by events.manage holders while a team goal runs or is upcoming.
create function private.goal_teams_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  g public.goals;
  r record;
begin
  if pg_trigger_depth() > 1 then
    return coalesce(new, old);
  end if;
  if tg_op = 'INSERT' then
    r := new;
  else
    r := old;
  end if;
  select * into g from public.goals where id = r.goal_id;
  if g.kind <> 'team' or g.canceled_at is not null or g.ends_at <= now()
     or not private.has_group_permission(g.group_id, 'events.manage') then
    perform private.raise_event_rule('goal_forbidden');
  end if;
  if tg_table_name = 'goal_team_members' and tg_op = 'INSERT' then
    if not exists (select 1 from public.group_members m where m.group_id = g.group_id and m.user_id = new.user_id)
       or not exists (select 1 from public.goal_teams t where t.id = new.team_id and t.goal_id = new.goal_id) then
      perform private.raise_event_rule('goal_team_invalid');
    end if;
  end if;
  if tg_op = 'INSERT' and tg_table_name = 'goal_teams' then
    new.name := btrim(new.name);
    new.created_at := now();
  end if;
  if tg_op = 'UPDATE' then
    perform private.raise_event_rule('goal_immutable');
  end if;
  return coalesce(new, old);
end;
$$;

create trigger goal_teams_guard
  before insert or update or delete on public.goal_teams
  for each row execute function private.goal_teams_guard();
create trigger goal_team_members_guard
  before insert or update or delete on public.goal_team_members
  for each row execute function private.goal_teams_guard();

-- Claims: the member's own "Yaptım" on a running task goal; a manager approves or rejects it.
create function private.goal_claims_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
  g public.goals;
begin
  if pg_trigger_depth() > 1 then
    return coalesce(new, old);
  end if;
  if tg_op = 'INSERT' then
    select * into g from public.goals where id = new.goal_id;
    if actor is null or actor is distinct from new.user_id or g.kind <> 'task' or not private.is_goal_running(g)
       or not exists (select 1 from public.group_members m where m.group_id = g.group_id and m.user_id = actor) then
      perform private.raise_event_rule('claim_not_allowed');
    end if;
    new.note := btrim(new.note);
    new.status := 'pending';
    new.decided_by := null;
    new.decided_at := null;
    new.created_at := now();
    return new;
  end if;
  if tg_op = 'DELETE' then
    if actor = old.user_id and old.status <> 'approved' then
      return old;
    end if;
    perform private.raise_event_rule('claim_forbidden');
  end if;
  select * into g from public.goals where id = old.goal_id;
  if (new.goal_id, new.user_id, new.note, new.created_at) is distinct from (old.goal_id, old.user_id, old.note, old.created_at)
     or old.status <> 'pending' or new.status = 'pending' or g.canceled_at is not null
     or not private.has_group_permission(g.group_id, 'events.manage') then
    perform private.raise_event_rule('claim_forbidden');
  end if;
  new.decided_by := actor;
  new.decided_at := now();
  return new;
end;
$$;

create trigger goal_claims_guard
  before insert or update or delete on public.goal_claims
  for each row execute function private.goal_claims_guard();

-- An approved claim completes the task at once.
create function private.goal_claims_complete()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.goal_completions (goal_id, user_id) values (new.goal_id, new.user_id) on conflict do nothing;
  if found then
    perform private.notify_goal_completed(new.goal_id, new.user_id);
  end if;
  return null;
end;
$$;

revoke all on function private.goal_claims_complete() from public;

create trigger goal_claims_complete
  after update of status on public.goal_claims
  for each row when (new.status = 'approved' and old.status <> 'approved')
  execute function private.goal_claims_complete();

-- ---------------------------------------------------------------------------
-- RPCs
-- ---------------------------------------------------------------------------

-- A goal as the screens show it, with the caller's progress: their own, the group's, their team's, or their task claim.
create function private.goal_card(g public.goals)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  with me as (select (select auth.uid()) as uid)
  select jsonb_build_object(
    'id', g.id,
    'group', jsonb_build_object('id', gr.id, 'handle', gr.handle, 'name', gr.name, 'logo_path', gr.logo_path),
    'title', g.title,
    'description', g.description,
    'kind', g.kind,
    'metric', g.metric,
    'target', coalesce(g.target, 1),
    'starts_at', g.starts_at,
    'ends_at', g.ends_at,
    'canceled_at', g.canceled_at,
    'progress', case g.kind
                  when 'personal' then case when me.uid is null then 0 else private.goal_total(g, array[me.uid]) end
                  when 'group' then private.goal_total(g, null)
                  when 'team' then case when cardinality(private.goal_team_of(g.id, me.uid)) = 0 then 0
                                        else private.goal_total(g, private.goal_team_of(g.id, me.uid)) end
                  else (select count(*)::int from public.goal_claims c where c.goal_id = g.id and c.user_id = me.uid and c.status = 'approved')
                end,
    'my_team', (select t.name from public.goal_team_members m join public.goal_teams t on t.id = m.team_id
                where m.goal_id = g.id and m.user_id = me.uid),
    'my_claim', (select c.status from public.goal_claims c where c.goal_id = g.id and c.user_id = me.uid),
    'completed', exists (select 1 from public.goal_completions c where c.goal_id = g.id and c.user_id = me.uid),
    'completions', (select count(*) from public.goal_completions c where c.goal_id = g.id),
    'can_manage', private.has_group_permission(g.group_id, 'events.manage')
  )
  from public.groups gr, me
  where gr.id = g.group_id;
$$;

create function public.group_goals(target_group uuid)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select coalesce(jsonb_agg(private.goal_card(g) order by (g.canceled_at is null and g.ends_at > now()) desc, g.ends_at desc), '[]'::jsonb)
  from (
    select * from public.goals
    where group_id = target_group and (canceled_at is null and ends_at > now() - interval '30 days')
    order by ends_at desc limit 20
  ) g;
$$;

create function private.person(uid uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object('id', p.id, 'username', p.username, 'display_name', p.display_name, 'avatar_path', p.avatar_path)
  from public.profiles p where p.id = uid;
$$;

create function private.goal_detail(target_goal uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select case when not private.is_group_visible(g.group_id) then null else private.goal_card(g) || jsonb_build_object(
    'teams', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', t.id,
        'name', t.name,
        'progress', private.goal_total(g, (select array_agg(m.user_id) from public.goal_team_members m where m.team_id = t.id)),
        'members', (select coalesce(jsonb_agg(private.person(m.user_id)), '[]'::jsonb) from public.goal_team_members m where m.team_id = t.id)
      ) order by t.created_at)
      from public.goal_teams t where t.goal_id = g.id), '[]'::jsonb),
    'claims', case when private.has_group_permission(g.group_id, 'events.manage') then coalesce((
      select jsonb_agg(private.person(c.user_id) || jsonb_build_object('note', c.note, 'created_at', c.created_at) order by c.created_at)
      from public.goal_claims c where c.goal_id = g.id and c.status = 'pending'), '[]'::jsonb) end,
    'completers', coalesce((
      select jsonb_agg(private.person(c.user_id) order by c.completed_at)
      from (select * from public.goal_completions where goal_id = g.id order by completed_at limit 50) c), '[]'::jsonb),
    'members', case when private.has_group_permission(g.group_id, 'events.manage') and g.kind = 'team' then coalesce((
      select jsonb_agg(private.person(m.user_id) order by p.display_name)
      from public.group_members m join public.profiles p on p.id = m.user_id
      where m.group_id = g.group_id
        and not exists (select 1 from public.goal_team_members tm where tm.goal_id = g.id and tm.user_id = m.user_id)), '[]'::jsonb) end
  ) end
  from public.goals g where g.id = target_goal;
$$;

create function public.goal_detail(target_goal uuid)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.goal_detail(target_goal);
$$;

revoke all on function private.goal_card(public.goals), private.person(uuid), private.goal_detail(uuid) from public;
grant execute on function private.goal_card(public.goals), private.goal_detail(uuid) to anon, authenticated;
grant execute on function public.group_goals(uuid), public.goal_detail(uuid) to anon, authenticated;

-- The profile's badges include the goals the person reached.
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
      where c.user_id = user_contributions.target), '[]'::jsonb))
    from (select private.contribution_counts(target, null) as counts) x
  ) end;
$$;

-- Notifications also carry the goal's title.
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
    'group', (select jsonb_build_object('id', g.id, 'handle', g.handle, 'name', g.name, 'logo_path', g.logo_path)
              from public.groups g where g.id = n.group_id),
    'sanction_type', (select s.type from public.sanctions s where s.id = n.sanction_id),
    'goal_id', n.goal_id,
    'goal_title', (select g.title from public.goals g where g.id = n.goal_id),
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
