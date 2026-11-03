-- 0074_group_bans_and_call_grants
-- User decisions 2026-11-03 (docs/ARCHITECTURE.md §3e Oylamasız ban, §8c Görüşme yetkisi):
--   1. The owner and Yöneticiler ban without a board vote (members.ban): timed or permanent, optionally marked as
--      illegal activity, which then goes to the platform team as an approved board case does.
--   2. Voice call permission is asked from a group and decided by its owner or Yöneticiler (calls.manage); the platform
--      team no longer decides or sees it.

-- ---------------------------------------------------------------------------
-- Permission catalog (groups)
-- ---------------------------------------------------------------------------
insert into public.group_permissions (slug, description) values
  ('members.ban', 'Kurul oylaması olmadan süreli ya da kalıcı ban'),
  ('calls.manage', 'Üyelerin sesli görüşme taleplerini açma, reddetme ve yetkiyi kapatma');
insert into public.group_role_permissions (role, permission) values
  ('admin', 'members.ban'),
  ('admin', 'calls.manage');

-- ===========================================================================
-- 1. Direct bans (owner: moderation)
-- ===========================================================================
alter table public.moderation_cases add column direct boolean not null default false,
  add constraint moderation_cases_direct_ban check (not direct or sanction = 'ban');

comment on column public.moderation_cases.direct is
  'A ban the owner or a Yönetici applied without a board vote (members.ban); written approved, with no voters.';

-- 0046 definition plus the direct ban: members.ban, outranking the subject, approved at once.
create or replace function private.moderation_cases_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
  subject_rank int;
begin
  if tg_op = 'INSERT' then
    if actor is null or actor is distinct from new.opened_by
       or not private.has_group_permission(new.group_id, 'reports.review')
       or (new.direct and not private.has_group_permission(new.group_id, 'members.ban')) then
      perform private.raise_moderation_rule('case_forbidden');
    end if;
    if not exists (select 1 from public.group_members m where m.group_id = new.group_id and m.user_id = new.subject_id) then
      perform private.raise_moderation_rule('subject_not_member');
    end if;
    subject_rank := private.group_rank(new.group_id, new.subject_id);
    if private.group_rank(new.group_id, actor) <= subject_rank
       or (not new.direct and private.case_decider_rank(new.group_id, new.subject_id) <= subject_rank) then
      perform private.raise_moderation_rule('rank_violation');
    end if;
    new.reason := btrim(new.reason);
    new.threshold := (select g.case_threshold from public.groups g where g.id = new.group_id);
    new.created_at := now();
    if new.direct then
      new.status := 'approved';
      new.voting_ends_at := now();
      new.decided_at := now();
    else
      new.status := 'voting';
      new.voting_ends_at := now() + interval '72 hours';
      new.decided_at := null;
    end if;
    return new;
  end if;

  if tg_op = 'DELETE' then
    if pg_trigger_depth() > 1 then
      return old;
    end if;
    perform private.raise_moderation_rule('case_immutable');
  end if;
  if (new.id, new.group_id, new.subject_id, new.sanction, new.duration_days, new.reason, new.threshold, new.voting_ends_at,
      new.created_at, new.illegal_category, new.direct)
     is distinct from
     (old.id, old.group_id, old.subject_id, old.sanction, old.duration_days, old.reason, old.threshold, old.voting_ends_at,
      old.created_at, old.illegal_category, old.direct)
     or (new.opened_by is distinct from old.opened_by and new.opened_by is not null) then
    perform private.raise_moderation_rule('case_immutable');
  end if;
  if new.status is distinct from old.status then
    if old.status <> 'voting' or new.status is distinct from private.case_outcome(old.id) then
      perform private.raise_moderation_rule('case_not_decided');
    end if;
    new.decided_at := now();
  else
    new.decided_at := old.decided_at;
  end if;
  return new;
end;
$$;

-- A direct ban has no voters and nobody is asked to vote.
create or replace function private.moderation_cases_voters()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.direct then
    return null;
  end if;
  insert into public.case_votes (case_id, voter_id)
  select new.id, r.user_id
  from public.group_member_roles r
  where r.group_id = new.group_id and r.role = 'discipline' and r.user_id <> new.subject_id and private.is_account_active(r.user_id);
  if not found then
    insert into public.case_votes (case_id, voter_id)
    select new.id, g.owner_id from public.groups g where g.id = new.group_id;
  end if;

  insert into public.notifications (recipient_id, actor_id, type, group_id)
  select v.voter_id, new.opened_by, 'case_vote', new.group_id
  from public.case_votes v
  where v.case_id = new.id and v.voter_id <> new.opened_by;
  return null;
end;
$$;

revoke all on function private.moderation_cases_voters() from public;

-- 0012 definition plus: a direct ban opened later about the same person supersedes the vote (rejected).
create or replace function private.case_outcome(target_case uuid)
returns text
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  c public.moderation_cases;
  total int;
  cast_votes int;
  approvals int;
begin
  select * into c from public.moderation_cases where id = target_case;
  if c.id is null or c.status <> 'voting' then
    return null;
  end if;
  if exists (select 1 from public.moderation_cases d
             where d.group_id = c.group_id and d.subject_id = c.subject_id and d.direct and d.created_at >= c.created_at) then
    return 'rejected';
  end if;
  select count(*), count(v.vote), count(*) filter (where v.vote = 'approve')
  into total, cast_votes, approvals
  from public.case_votes v where v.case_id = target_case;

  if private.meets_threshold(c.threshold, approvals, total) then
    return 'approved';
  end if;
  if cast_votes < total and now() < c.voting_ends_at then
    return null;
  end if;
  if private.meets_threshold(c.threshold, approvals, cast_votes) then
    return 'approved';
  end if;
  return 'rejected';
end;
$$;

revoke all on function private.case_outcome(uuid) from public;
grant execute on function private.case_outcome(uuid) to service_role;

-- The moderation desk (0046 definition plus can_ban and the direct mark of a case).
create or replace function private.group_moderation(target_group uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  with me as (select (select auth.uid()) as uid)
  select case when not private.has_group_permission(target_group, 'reports.review') then null else jsonb_build_object(
    'rank', private.group_rank(target_group, me.uid),
    'is_owner', exists (select 1 from public.groups g where g.id = target_group and g.owner_id = me.uid),
    'can_mute', private.has_group_permission(target_group, 'members.mute'),
    'can_ban', private.has_group_permission(target_group, 'members.ban'),
    'threshold', (select g.case_threshold from public.groups g where g.id = target_group),
    'reports', coalesce((
      select jsonb_agg(x.card order by x.last_at desc)
      from (
        select max(r.created_at) as last_at, jsonb_build_object(
          'id', (array_agg(r.id order by r.created_at desc))[1],
          'target_type', r.target_type,
          'target_id', r.target_id,
          'post_id', (select c.post_id::text from public.comments c
                      where r.target_type = 'comment' and c.id::text = r.target_id),
          'subject', private.person_card(r.subject_id, target_group),
          'excerpt', (array_agg(r.excerpt order by r.created_at desc))[1],
          'reasons', to_jsonb(array_agg(distinct r.reason)),
          'notes', coalesce(to_jsonb((array_agg(r.note order by r.created_at desc) filter (where r.note is not null))[1:5]), '[]'::jsonb),
          'count', count(*),
          'first_at', min(r.created_at),
          'last_at', max(r.created_at)
        ) as card
        from public.reports r
        where r.group_id = target_group and r.status = 'open'
        group by r.target_type, r.target_id, r.subject_id
        order by max(r.created_at) desc
        limit 100
      ) x
    ), '[]'::jsonb),
    'cases', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', c.id,
        'subject', private.person_card(c.subject_id, target_group),
        'opened_by', private.person_card(c.opened_by, target_group),
        'sanction', c.sanction,
        'duration_days', c.duration_days,
        'illegal_category', c.illegal_category,
        'direct', c.direct,
        'reason', c.reason,
        'threshold', c.threshold,
        'status', c.status,
        'voting_ends_at', c.voting_ends_at,
        'decided_at', c.decided_at,
        'created_at', c.created_at,
        'voters', (select count(*) from public.case_votes v where v.case_id = c.id),
        'approvals', (select count(*) from public.case_votes v where v.case_id = c.id and v.vote = 'approve'),
        'rejections', (select count(*) from public.case_votes v where v.case_id = c.id and v.vote = 'reject'),
        'is_voter', exists (select 1 from public.case_votes v where v.case_id = c.id and v.voter_id = me.uid),
        'my_vote', (select v.vote from public.case_votes v where v.case_id = c.id and v.voter_id = me.uid)
      ) order by (c.status = 'voting') desc, c.created_at desc)
      from (select * from public.moderation_cases c0 where c0.group_id = target_group
            order by (c0.status = 'voting') desc, c0.created_at desc limit 50) c
    ), '[]'::jsonb),
    'sanctions', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', s.id,
        'user', private.person_card(s.user_id, target_group),
        'type', s.type,
        'interim', s.interim,
        'starts_at', s.starts_at,
        'ends_at', s.ends_at,
        'lifted_at', s.lifted_at,
        'reason', (select c.reason from public.moderation_cases c where c.id = s.case_id),
        'appeal', (select jsonb_build_object('id', a.id, 'body', a.body, 'handler', a.handler, 'status', a.status,
                                             'decision_note', a.decision_note, 'created_at', a.created_at)
                   from public.sanction_appeals a where a.sanction_id = s.id)
      ) order by s.created_at desc)
      from (select * from public.sanctions s0 where s0.group_id = target_group order by s0.created_at desc limit 50) s
    ), '[]'::jsonb)
  ) end
  from me;
$$;

-- ===========================================================================
-- 2. Voice call permission from a group (owner: live)
-- ===========================================================================
-- Rows the platform granted before keep working (no group). Waiting requests had no group to go to: they go.
delete from public.call_permissions where status = 'requested';

alter table public.call_permissions add column group_id uuid references public.groups (id) on delete cascade;
create index call_permissions_group_idx on public.call_permissions (group_id, status) where group_id is not null;

comment on table public.call_permissions is
  'owner: live. Who may make voice calls: asked from a group by the person, decided by its owner or Yöneticiler (docs/ARCHITECTURE.md §8c).';

-- The person, and the managers of the group the request went to; the platform team no longer.
drop policy call_permissions_select on public.call_permissions;
create policy call_permissions_select on public.call_permissions for select to authenticated
  using (user_id = (select auth.uid())
         or (group_id is not null and (select private.has_group_permission(group_id, 'calls.manage'))));

-- Permission that rests on a suspended group does not count.
create or replace function private.has_call_permission(uid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.call_permissions p
    where p.user_id = uid and p.status = 'active'
      and (p.group_id is null or exists (select 1 from public.groups g where g.id = p.group_id and g.status = 'active'))
  );
$$;

revoke all on function private.has_call_permission(uuid) from public;

-- Second layer for the backend's decisions and the person's request (the actor is auth.uid()).
create function private.call_permissions_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
begin
  -- Written by another trigger (leaving the group).
  if pg_trigger_depth() > 1 then
    return new;
  end if;
  if new.status = 'requested' then
    if actor is null or actor <> new.user_id or new.group_id is null
       or not exists (select 1 from public.group_members m where m.group_id = new.group_id and m.user_id = actor)
       or not exists (select 1 from public.groups g where g.id = new.group_id and g.status = 'active') then
      raise exception 'call_forbidden' using errcode = 'P0001';
    end if;
    return new;
  end if;
  if tg_op <> 'UPDATE' or actor is null or actor = new.user_id or old.group_id is null
     or new.group_id is distinct from old.group_id
     or not private.user_has_group_permission(actor, old.group_id, 'calls.manage')
     or not exists (select 1 from public.group_members m where m.group_id = old.group_id and m.user_id = new.user_id)
     or not (old.status = 'requested' and new.status in ('active', 'declined')
             or old.status = 'active' and new.status = 'revoked') then
    raise exception 'call_forbidden' using errcode = 'P0001';
  end if;
  if new.status in ('declined', 'revoked')
     and private.group_rank(old.group_id, actor) <= private.group_rank(old.group_id, new.user_id) then
    raise exception 'call_rank_violation' using errcode = 'P0001';
  end if;
  new.decided_by := actor;
  new.decided_at := now();
  return new;
end;
$$;

revoke all on function private.call_permissions_guard() from public;

create trigger call_permissions_guard
  before insert or update on public.call_permissions
  for each row execute function private.call_permissions_guard();

-- Leaving, kicked or banned: the request goes and the permission closes (no week to wait: nobody decided).
create function private.call_permissions_on_leave()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  delete from public.call_permissions p where p.user_id = old.user_id and p.group_id = old.group_id and p.status = 'requested';
  update public.call_permissions p
  set status = 'revoked', decided_at = now(), decided_by = null, reason = 'Yetkiyi veren gruptan ayrıldın.', updated_at = now()
  where p.user_id = old.user_id and p.group_id = old.group_id and p.status = 'active';
  return null;
end;
$$;

revoke all on function private.call_permissions_on_leave() from public;

create trigger call_permissions_on_leave
  after delete on public.group_members
  for each row execute function private.call_permissions_on_leave();

-- The person asks a group they belong to. Declined or revoked by someone: again after 7 days.
drop function public.request_call_permission(text);
drop function private.request_call_permission(text);

create function private.request_call_permission(target_group uuid, request_note text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  me uuid := (select auth.uid());
  current public.call_permissions;
begin
  if me is null or not private.is_account_active(me) then
    raise exception 'call_forbidden' using errcode = 'P0001';
  end if;
  if target_group is null
     or not exists (select 1 from public.group_members m where m.group_id = target_group and m.user_id = me)
     or not exists (select 1 from public.groups g where g.id = target_group and g.status = 'active') then
    raise exception 'call_group_invalid' using errcode = 'P0001';
  end if;
  if char_length(coalesce(request_note, '')) > 300 then
    raise exception 'call_note_too_long' using errcode = 'P0001';
  end if;
  select * into current from public.call_permissions where user_id = me;
  if found and current.status in ('requested', 'active') then
    raise exception 'call_permission_exists' using errcode = 'P0001';
  end if;
  if found and current.decided_by is not null and current.decided_at > now() - interval '7 days' then
    raise exception 'call_permission_cooldown' using errcode = 'P0001';
  end if;
  insert into public.call_permissions (user_id, group_id, status, note, requested_at, updated_at)
  values (me, target_group, 'requested', nullif(btrim(request_note), ''), now(), now())
  on conflict (user_id) do update
    set group_id = excluded.group_id, status = 'requested', note = excluded.note, requested_at = excluded.requested_at,
        decided_at = null, decided_by = null, reason = null, updated_at = excluded.updated_at;
end;
$$;

create function public.request_call_permission(target_group uuid, request_note text default null)
returns void
language sql
security invoker
set search_path = ''
as $$
  select private.request_call_permission(target_group, request_note);
$$;

revoke all on function private.request_call_permission(uuid, text), public.request_call_permission(uuid, text) from public;
grant execute on function private.request_call_permission(uuid, text), public.request_call_permission(uuid, text) to authenticated;

-- The group's requests and permissions for its managers (person cards with ranks, the caller's rank).
create function private.group_call_permissions(target_group uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select case when not private.has_group_permission(target_group, 'calls.manage') then null else jsonb_build_object(
    'rank', private.group_rank(target_group, (select auth.uid())),
    'items', coalesce((
      select jsonb_agg(jsonb_build_object(
        'person', private.person_card(p.user_id, target_group),
        'status', p.status,
        'note', p.note,
        'requested_at', p.requested_at,
        'decided_at', p.decided_at
      ) order by coalesce(p.requested_at, p.decided_at) desc)
      from public.call_permissions p
      where p.group_id = target_group and p.status in ('requested', 'active')
    ), '[]'::jsonb)
  ) end;
$$;

create function public.group_call_permissions(target_group uuid)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.group_call_permissions(target_group);
$$;

revoke all on function private.group_call_permissions(uuid), public.group_call_permissions(uuid) from public;
grant execute on function private.group_call_permissions(uuid), public.group_call_permissions(uuid) to authenticated;

-- The person sees which group the request went to.
create function public.my_call_permission()
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select jsonb_build_object(
    'status', p.status, 'note', p.note, 'reason', p.reason, 'decided_at', p.decided_at, 'decided_by_person', p.decided_by is not null,
    'group', (select jsonb_build_object('id', g.id, 'handle', g.handle, 'name', g.name) from public.groups g where g.id = p.group_id)
  )
  from public.call_permissions p
  where p.user_id = (select auth.uid());
$$;

revoke all on function public.my_call_permission() from public;
grant execute on function public.my_call_permission() to authenticated;
