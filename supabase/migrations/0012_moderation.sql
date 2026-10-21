-- 0012_moderation
-- Phase 6: reports, discipline cases with board votes, sanctions (warning,
-- mute, kick, ban), the emergency mute and appeals. Rules: docs/ARCHITECTURE.md §3e.
--
-- Reports and appeals are the user's own simple writes (RLS). Cases, votes,
-- sanctions and decisions are written by the C# API (actor in
-- request.jwt.claims; none for the monitor's system writes). Triggers re-check
-- the rules; bans and mutes are wired into the groups, feed and live triggers.

-- ---------------------------------------------------------------------------
-- Permissions: reports.review, members.mute (owner, Yönetici, Disiplin Kurulu,
-- Moderatör). Voting is the Disiplin Kurulu role, not a permission.
-- ---------------------------------------------------------------------------
insert into public.group_permissions (slug, description) values
  ('reports.review', 'Şikayetleri ön inceleme, şikayet edilen yorumu kaldırma, disiplin dosyası açma'),
  ('members.mute', 'Acil susturma (en çok 24 saat, dosya açılarak)');
insert into public.group_role_permissions (role, permission) values
  ('admin', 'reports.review'),
  ('discipline', 'reports.review'),
  ('moderator', 'reports.review'),
  ('admin', 'members.mute'),
  ('discipline', 'members.mute'),
  ('moderator', 'members.mute');

-- The board's decision threshold (groups owns the table; only the owner changes it).
alter table public.groups add column case_threshold text not null default 'majority'
  check (case_threshold in ('majority', 'two_thirds', 'unanimous'));

-- ---------------------------------------------------------------------------
-- reports, moderation_cases, case_votes, sanctions, sanction_appeals
-- owner: moderation
-- ---------------------------------------------------------------------------
create table public.moderation_cases (
  id             uuid primary key default gen_random_uuid(),
  group_id       uuid not null references public.groups (id) on delete cascade,
  subject_id     uuid not null references public.profiles (id) on delete cascade,
  opened_by      uuid references public.profiles (id) on delete set null,
  sanction       text not null check (sanction in ('warning', 'mute', 'kick', 'ban')),
  duration_days  int,
  reason         text not null check (char_length(btrim(reason)) between 10 and 1000),
  threshold      text not null check (threshold in ('majority', 'two_thirds', 'unanimous')),
  status         text not null default 'voting' check (status in ('voting', 'approved', 'rejected')),
  voting_ends_at timestamptz not null,
  decided_at     timestamptz,
  created_at     timestamptz not null default now(),
  constraint moderation_cases_duration check (
    (sanction = 'mute' and duration_days between 1 and 90)
    or (sanction = 'ban' and (duration_days is null or duration_days between 1 and 365))
    or (sanction in ('warning', 'kick') and duration_days is null)),
  constraint moderation_cases_decided check ((status = 'voting') = (decided_at is null))
);

comment on table public.moderation_cases is
  'owner: moderation. Discipline cases: a proposed sanction the board votes on for 72 hours.';

create unique index moderation_cases_one_open_idx on public.moderation_cases (group_id, subject_id) where status = 'voting';
create index moderation_cases_group_idx on public.moderation_cases (group_id, created_at desc);
create index moderation_cases_due_idx on public.moderation_cases (voting_ends_at) where status = 'voting';

create table public.case_votes (
  case_id  uuid not null references public.moderation_cases (id) on delete cascade,
  voter_id uuid not null references public.profiles (id) on delete cascade,
  vote     text check (vote in ('approve', 'reject')),
  voted_at timestamptz,
  primary key (case_id, voter_id),
  constraint case_votes_consistent check ((vote is null) = (voted_at is null))
);

comment on table public.case_votes is
  'owner: moderation. Voters of a case, fixed when it opens (board members, or the owner without a board).';

create index case_votes_voter_idx on public.case_votes (voter_id);

create table public.reports (
  id          uuid primary key default gen_random_uuid(),
  reporter_id uuid references public.profiles (id) on delete set null,
  target_type text not null check (target_type in ('post', 'comment', 'event', 'live_comment', 'user')),
  target_id   text not null check (char_length(target_id) between 1 and 64),
  group_id    uuid references public.groups (id) on delete cascade,
  subject_id  uuid references public.profiles (id) on delete set null,
  reason      text not null check (reason in ('spam', 'harassment', 'hate', 'violence', 'sexual', 'misinformation', 'other')),
  note        text check (char_length(note) <= 500),
  excerpt     text not null default '' check (char_length(excerpt) <= 500),
  status      text not null default 'open' check (status in ('open', 'dismissed', 'actioned')),
  case_id     uuid references public.moderation_cases (id) on delete set null,
  reviewed_by uuid references public.profiles (id) on delete set null,
  reviewed_at timestamptz,
  created_at  timestamptz not null default now(),
  constraint reports_review_consistent check ((status = 'open') = (reviewed_at is null))
);

comment on table public.reports is
  'owner: moderation. Reports; group_id set = the group''s moderation, null = the platform team. excerpt keeps the evidence.';

create unique index reports_one_open_idx on public.reports (reporter_id, target_type, target_id) where status = 'open';
create index reports_group_idx on public.reports (group_id, status, created_at desc) where group_id is not null;
create index reports_status_idx on public.reports (status, created_at desc);
create index reports_target_idx on public.reports (target_type, target_id) where status = 'open';
create index reports_reporter_idx on public.reports (reporter_id, created_at desc);

create table public.sanctions (
  id          uuid primary key default gen_random_uuid(),
  group_id    uuid not null references public.groups (id) on delete cascade,
  user_id     uuid not null references public.profiles (id) on delete cascade,
  case_id     uuid not null references public.moderation_cases (id) on delete cascade,
  type        text not null check (type in ('warning', 'mute', 'kick', 'ban')),
  interim     boolean not null default false,
  starts_at   timestamptz not null default now(),
  ends_at     timestamptz,
  lifted_at   timestamptz,
  lifted_by   uuid references public.profiles (id) on delete set null,
  lift_reason text check (lift_reason in ('decided', 'appeal')),
  created_at  timestamptz not null default now(),
  constraint sanctions_lift_consistent check ((lifted_at is null) = (lift_reason is null)),
  constraint sanctions_interim_mute check (not interim or (type = 'mute' and ends_at is not null))
);

comment on table public.sanctions is
  'owner: moderation. Sanctions of a decided case, or the emergency mute (interim) of an open one.';

create unique index sanctions_one_final_idx on public.sanctions (case_id) where not interim;
create unique index sanctions_one_interim_idx on public.sanctions (case_id) where interim;
create index sanctions_active_idx on public.sanctions (group_id, user_id) where lifted_at is null;
create index sanctions_user_idx on public.sanctions (user_id, created_at desc);

create table public.sanction_appeals (
  id            uuid primary key default gen_random_uuid(),
  sanction_id   uuid not null unique references public.sanctions (id) on delete cascade,
  user_id       uuid not null references public.profiles (id) on delete cascade,
  body          text not null check (char_length(btrim(body)) between 10 and 1000),
  handler       text not null check (handler in ('owner', 'platform')),
  status        text not null default 'pending' check (status in ('pending', 'upheld', 'overturned')),
  decision_note text check (char_length(decision_note) <= 500),
  decided_by    uuid references public.profiles (id) on delete set null,
  decided_at    timestamptz,
  created_at    timestamptz not null default now(),
  constraint sanction_appeals_decided check ((status = 'pending') = (decided_at is null))
);

comment on table public.sanction_appeals is
  'owner: moderation. One appeal per sanction; decided by the owner, or the platform team when the owner took part.';

create index sanction_appeals_handler_idx on public.sanction_appeals (handler, status, created_at desc);

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

-- A running ban: not lifted, permanent or not over yet.
create function private.is_group_banned(target_group uuid, uid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.sanctions s
    where s.group_id = target_group and s.user_id = uid and s.type = 'ban'
      and s.lifted_at is null and (s.ends_at is null or s.ends_at > now())
  );
$$;

-- A running mute (final or emergency); mutes always end.
create function private.is_group_muted(target_group uuid, uid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.sanctions s
    where s.group_id = target_group and s.user_id = uid and s.type = 'mute'
      and s.lifted_at is null and s.ends_at > now()
  );
$$;

create function private.meets_threshold(threshold text, approvals int, votes int)
returns boolean
language sql
immutable
set search_path = ''
as $$
  select votes > 0 and case threshold
    when 'two_thirds' then approvals * 3 >= votes * 2
    when 'unanimous' then approvals = votes
    else approvals * 2 > votes
  end;
$$;

-- The decision of an open case right now, or null while it is still open (§3e, Karar):
-- approved as soon as the approvals pass the threshold of all voters; otherwise decided by
-- the cast votes once everyone voted or the 72 hours are over (no votes: rejected).
create function private.case_outcome(target_case uuid)
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

-- Group, accused person and evidence of a report target the caller can see; null subject otherwise.
create function private.report_target(kind text, target text, out target_group uuid, out subject uuid, out excerpt text)
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
  end if;
  excerpt := left(btrim(coalesce(excerpt, '')), 500);
end;
$$;

-- Rank the deciding body needs to outrank: the board (60), or the owner (100) without one.
create function private.case_decider_rank(target_group uuid, subject uuid)
returns int
language sql
stable
security definer
set search_path = ''
as $$
  select case when exists (
    select 1 from public.group_member_roles r
    where r.group_id = target_group and r.role = 'discipline' and r.user_id <> subject and private.is_account_active(r.user_id)
  ) then 60 else 100 end;
$$;

revoke all on function private.is_group_banned(uuid, uuid), private.is_group_muted(uuid, uuid),
  private.meets_threshold(text, int, int), private.case_outcome(uuid), private.report_target(text, text),
  private.case_decider_rank(uuid, uuid) from public;
grant execute on function private.is_group_banned(uuid, uuid), private.is_group_muted(uuid, uuid), private.report_target(text, text)
  to authenticated, service_role;
grant execute on function private.case_outcome(uuid), private.case_decider_rank(uuid, uuid) to service_role;

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------
alter table public.reports enable row level security;
alter table public.moderation_cases enable row level security;
alter table public.case_votes enable row level security;
alter table public.sanctions enable row level security;
alter table public.sanction_appeals enable row level security;

revoke all on public.reports, public.moderation_cases, public.case_votes, public.sanctions, public.sanction_appeals
  from anon, authenticated;
grant select on public.reports, public.sanctions, public.sanction_appeals to authenticated;
grant insert (reporter_id, target_type, target_id, group_id, reason, note) on public.reports to authenticated;
grant insert (sanction_id, user_id, body) on public.sanction_appeals to authenticated;

create policy reports_select_own on public.reports for select to authenticated
  using (reporter_id = (select auth.uid()));
create policy reports_insert_own on public.reports for insert to authenticated
  with check (reporter_id = (select auth.uid()) and (select private.is_account_active(auth.uid())));

create policy sanctions_select_own on public.sanctions for select to authenticated
  using (user_id = (select auth.uid()));

create policy sanction_appeals_select_own on public.sanction_appeals for select to authenticated
  using (user_id = (select auth.uid()));
create policy sanction_appeals_insert_own on public.sanction_appeals for insert to authenticated
  with check (user_id = (select auth.uid()));

-- ---------------------------------------------------------------------------
-- Triggers
-- ---------------------------------------------------------------------------
create function private.raise_moderation_rule(code text)
returns void
language plpgsql
set search_path = ''
as $$
begin
  raise exception '%', code using errcode = 'P0001';
end;
$$;

-- Reports: the reporter's own insert; the target fills group, subject and evidence.
-- Reviews change only the status, by the group's reviewers or the platform team.
create function private.reports_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
  t record;
begin
  if tg_op = 'INSERT' then
    if actor is null or actor is distinct from new.reporter_id or not private.is_account_active(actor) then
      perform private.raise_moderation_rule('report_forbidden');
    end if;
    if (select count(*) from public.reports r where r.reporter_id = actor and r.created_at > now() - interval '24 hours') >= 20 then
      perform private.raise_moderation_rule('report_rate_limited');
    end if;
    select * into t from private.report_target(new.target_type, new.target_id);
    if t.subject is null then
      perform private.raise_moderation_rule('report_target_invalid');
    end if;
    if t.subject = actor then
      perform private.raise_moderation_rule('report_self');
    end if;
    if new.target_type = 'user' then
      -- A member reported from the group's member list goes to that group.
      if new.group_id is not null and not (
        exists (select 1 from public.group_members m where m.group_id = new.group_id and m.user_id = actor)
        and exists (select 1 from public.group_members m where m.group_id = new.group_id and m.user_id = t.subject)
      ) then
        new.group_id := null;
      end if;
    else
      new.group_id := t.target_group;
    end if;
    new.subject_id := t.subject;
    new.excerpt := t.excerpt;
    new.note := nullif(btrim(new.note), '');
    new.status := 'open';
    new.case_id := null;
    new.reviewed_by := null;
    new.reviewed_at := null;
    new.created_at := now();
    return new;
  end if;

  if pg_trigger_depth() > 1 then
    return coalesce(new, old);
  end if;
  if tg_op = 'DELETE' then
    perform private.raise_moderation_rule('report_immutable');
  end if;
  if (new.reporter_id, new.target_type, new.target_id, new.group_id, new.subject_id, new.reason, new.note, new.excerpt, new.created_at)
     is distinct from
     (old.reporter_id, old.target_type, old.target_id, old.group_id, old.subject_id, old.reason, old.note, old.excerpt, old.created_at)
     or old.status <> 'open' or new.status = 'open' then
    perform private.raise_moderation_rule('report_immutable');
  end if;
  if not (private.is_platform_staff(array['admin', 'moderator'])
          or (old.group_id is not null and private.has_group_permission(old.group_id, 'reports.review'))) then
    perform private.raise_moderation_rule('report_review_forbidden');
  end if;
  new.reviewed_by := actor;
  new.reviewed_at := now();
  return new;
end;
$$;

create trigger reports_guard
  before insert or update or delete on public.reports
  for each row execute function private.reports_guard();

-- Cases: opened by an outranking reports.review holder about a member the deciding body
-- outranks; afterwards only the decision of private.case_outcome may be written.
create function private.moderation_cases_guard()
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
       or not private.has_group_permission(new.group_id, 'reports.review') then
      perform private.raise_moderation_rule('case_forbidden');
    end if;
    if not exists (select 1 from public.group_members m where m.group_id = new.group_id and m.user_id = new.subject_id) then
      perform private.raise_moderation_rule('subject_not_member');
    end if;
    subject_rank := private.group_rank(new.group_id, new.subject_id);
    if private.group_rank(new.group_id, actor) <= subject_rank
       or private.case_decider_rank(new.group_id, new.subject_id) <= subject_rank then
      perform private.raise_moderation_rule('rank_violation');
    end if;
    new.reason := btrim(new.reason);
    new.threshold := (select g.case_threshold from public.groups g where g.id = new.group_id);
    new.status := 'voting';
    new.voting_ends_at := now() + interval '72 hours';
    new.decided_at := null;
    new.created_at := now();
    return new;
  end if;

  if tg_op = 'DELETE' then
    if pg_trigger_depth() > 1 then
      return old;
    end if;
    perform private.raise_moderation_rule('case_immutable');
  end if;
  if (new.id, new.group_id, new.subject_id, new.sanction, new.duration_days, new.reason, new.threshold, new.voting_ends_at, new.created_at)
     is distinct from
     (old.id, old.group_id, old.subject_id, old.sanction, old.duration_days, old.reason, old.threshold, old.voting_ends_at, old.created_at)
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

create trigger moderation_cases_guard
  before insert or update or delete on public.moderation_cases
  for each row execute function private.moderation_cases_guard();

-- The voters of a new case: the board except the subject, or the owner without one.
create function private.moderation_cases_voters()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
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

create trigger moderation_cases_voters
  after insert on public.moderation_cases
  for each row execute function private.moderation_cases_voters();

-- Votes: rows come from the case; a voter casts or changes their own vote while it is open.
create function private.case_votes_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
begin
  if pg_trigger_depth() > 1 then
    return coalesce(new, old);
  end if;
  if tg_op <> 'UPDATE' or (new.case_id, new.voter_id) is distinct from (old.case_id, old.voter_id) then
    perform private.raise_moderation_rule('vote_forbidden');
  end if;
  if actor is distinct from old.voter_id or new.vote is null or not private.is_account_active(actor)
     or not exists (
       select 1 from public.moderation_cases c
       join public.group_members m on m.group_id = c.group_id and m.user_id = actor
       where c.id = old.case_id and c.status = 'voting'
     ) then
    perform private.raise_moderation_rule('vote_forbidden');
  end if;
  new.voted_at := now();
  return new;
end;
$$;

create trigger case_votes_guard
  before insert or update or delete on public.case_votes
  for each row execute function private.case_votes_guard();

-- Sanctions: the approved case's sanction, or the emergency mute of an open case by an
-- outranking members.mute holder. Afterwards only lifting (decision or appeal).
create function private.sanctions_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
  c public.moderation_cases;
begin
  if tg_op = 'INSERT' then
    select * into c from public.moderation_cases where id = new.case_id;
    if c.id is null then
      perform private.raise_moderation_rule('sanction_forbidden');
    end if;
    new.group_id := c.group_id;
    new.user_id := c.subject_id;
    new.starts_at := now();
    new.lifted_at := null;
    new.lifted_by := null;
    new.lift_reason := null;
    new.created_at := now();
    if new.interim then
      if c.status <> 'voting' or new.type <> 'mute' or actor is null
         or not private.has_group_permission(c.group_id, 'members.mute')
         or private.group_rank(c.group_id, actor) <= private.group_rank(c.group_id, c.subject_id) then
        perform private.raise_moderation_rule('sanction_forbidden');
      end if;
      new.ends_at := now() + interval '24 hours';
      return new;
    end if;
    if c.status <> 'approved' or new.type is distinct from c.sanction then
      perform private.raise_moderation_rule('sanction_forbidden');
    end if;
    if c.duration_days is null then
      new.ends_at := null;
    else
      new.ends_at := now() + make_interval(days => c.duration_days);
    end if;
    return new;
  end if;

  if tg_op = 'DELETE' then
    if pg_trigger_depth() > 1 then
      return old;
    end if;
    perform private.raise_moderation_rule('sanction_immutable');
  end if;
  if pg_trigger_depth() > 1 and new.lifted_at is not distinct from old.lifted_at then
    return new;
  end if;
  if (new.id, new.group_id, new.user_id, new.case_id, new.type, new.interim, new.starts_at, new.ends_at, new.created_at)
     is distinct from
     (old.id, old.group_id, old.user_id, old.case_id, old.type, old.interim, old.starts_at, old.ends_at, old.created_at)
     or old.lifted_at is not null or new.lifted_at is null then
    perform private.raise_moderation_rule('sanction_immutable');
  end if;
  if not (
    (new.lift_reason = 'decided' and old.interim
     and exists (select 1 from public.moderation_cases c2 where c2.id = old.case_id and c2.status <> 'voting'))
    or (new.lift_reason = 'appeal'
        and exists (select 1 from public.sanction_appeals a where a.sanction_id = old.id and a.status = 'overturned'))
  ) then
    perform private.raise_moderation_rule('sanction_lift_forbidden');
  end if;
  new.lifted_at := now();
  new.lifted_by := actor;
  return new;
end;
$$;

create trigger sanctions_guard
  before insert or update or delete on public.sanctions
  for each row execute function private.sanctions_guard();

-- The person learns about the sanction; the group (shown through its owner) is the sender.
create function private.notify_sanction()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.notifications (recipient_id, actor_id, type, group_id, sanction_id)
  select new.user_id, g.owner_id, 'sanction_applied', new.group_id, new.id
  from public.groups g
  where g.id = new.group_id and private.is_account_active(new.user_id);
  return null;
end;
$$;

revoke all on function private.notify_sanction() from public;

create trigger notify_sanction
  after insert on public.sanctions
  for each row execute function private.notify_sanction();

-- Appeals: once, within 7 days, on the person's own running final sanction. The owner
-- decides unless they opened the case or voted on it; then the platform team does.
create function private.sanction_appeals_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
  s public.sanctions;
  c public.moderation_cases;
  group_owner uuid;
begin
  if tg_op = 'INSERT' then
    select * into s from public.sanctions where id = new.sanction_id;
    if actor is null or actor is distinct from new.user_id or s.id is null or s.user_id <> actor or s.interim
       or s.lifted_at is not null or s.created_at < now() - interval '7 days' or not private.is_account_active(actor) then
      perform private.raise_moderation_rule('appeal_not_allowed');
    end if;
    select * into c from public.moderation_cases where id = s.case_id;
    select g.owner_id into group_owner from public.groups g where g.id = s.group_id;
    if c.opened_by = group_owner or exists (select 1 from public.case_votes v where v.case_id = c.id and v.voter_id = group_owner) then
      new.handler := 'platform';
    else
      new.handler := 'owner';
    end if;
    new.body := btrim(new.body);
    new.status := 'pending';
    new.decision_note := null;
    new.decided_by := null;
    new.decided_at := null;
    new.created_at := now();
    return new;
  end if;

  if tg_op = 'DELETE' then
    if pg_trigger_depth() > 1 then
      return old;
    end if;
    perform private.raise_moderation_rule('appeal_immutable');
  end if;
  if pg_trigger_depth() > 1 and new.status is not distinct from old.status then
    return new;
  end if;
  if (new.id, new.sanction_id, new.user_id, new.body, new.handler, new.created_at)
     is distinct from (old.id, old.sanction_id, old.user_id, old.body, old.handler, old.created_at)
     or old.status <> 'pending' or new.status = 'pending' then
    perform private.raise_moderation_rule('appeal_immutable');
  end if;
  if old.handler = 'platform' then
    if not private.is_platform_staff(array['admin', 'moderator']) then
      perform private.raise_moderation_rule('appeal_forbidden');
    end if;
  elsif actor is null or not private.is_account_active(actor) or not exists (
    select 1 from public.sanctions s2 join public.groups g on g.id = s2.group_id
    where s2.id = old.sanction_id and g.owner_id = actor
  ) then
    perform private.raise_moderation_rule('appeal_forbidden');
  end if;
  new.decision_note := nullif(btrim(new.decision_note), '');
  new.decided_by := actor;
  new.decided_at := now();
  return new;
end;
$$;

create trigger sanction_appeals_guard
  before insert or update or delete on public.sanction_appeals
  for each row execute function private.sanction_appeals_guard();

-- The owner hears about an appeal they decide; the person hears the decision.
create function private.notify_appeal()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    if new.handler = 'owner' then
      insert into public.notifications (recipient_id, actor_id, type, group_id, sanction_id)
      select g.owner_id, new.user_id, 'appeal_submitted', s.group_id, s.id
      from public.sanctions s join public.groups g on g.id = s.group_id
      where s.id = new.sanction_id and private.is_account_active(g.owner_id);
    end if;
  elsif old.status = 'pending' and new.status <> 'pending' then
    insert into public.notifications (recipient_id, actor_id, type, group_id, sanction_id)
    select new.user_id, g.owner_id, 'appeal_decided', s.group_id, s.id
    from public.sanctions s join public.groups g on g.id = s.group_id
    where s.id = new.sanction_id and private.is_account_active(new.user_id);
  end if;
  return null;
end;
$$;

revoke all on function private.notify_appeal() from public;

create trigger notify_appeal
  after insert or update on public.sanction_appeals
  for each row execute function private.notify_appeal();

-- ---------------------------------------------------------------------------
-- Sanctions in the other modules' rules
-- ---------------------------------------------------------------------------

-- groups: a running ban keeps the person out (join, request, invitation).
create function private.reject_banned()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if private.is_group_banned(new.group_id, new.user_id) then
    perform private.raise_group_rule('banned');
  end if;
  return new;
end;
$$;

create trigger group_members_banned
  before insert on public.group_members
  for each row execute function private.reject_banned();
create trigger group_join_requests_banned
  before insert on public.group_join_requests
  for each row execute function private.reject_banned();
create trigger group_invitations_banned
  before insert on public.group_invitations
  for each row execute function private.reject_banned();

-- groups: the board's threshold is the owner's setting.
create function private.groups_case_threshold_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if not private.has_group_permission(old.id, 'roles.assign') then
    perform private.raise_group_rule('case_threshold_forbidden');
  end if;
  return new;
end;
$$;

create trigger groups_case_threshold_guard
  before update of case_threshold on public.groups
  for each row when (old.case_threshold is distinct from new.case_threshold)
  execute function private.groups_case_threshold_guard();

-- groups: others leave a group only through a kick or ban sanction of the same transaction.
create or replace function private.group_members_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
  g public.groups;
begin
  if tg_op = 'INSERT' then
    select * into g from public.groups where id = new.group_id;
    if actor is null or g.id is null then
      perform private.raise_group_rule('join_not_allowed');
    end if;
    if g.status <> 'active' then
      perform private.raise_group_rule('group_not_active');
    end if;
    if not private.is_account_active(new.user_id) then
      perform private.raise_group_rule('account_not_active');
    end if;

    if new.user_id = g.owner_id then
      -- The owner joins their own group while creating it.
      if actor <> g.owner_id then
        perform private.raise_group_rule('join_not_allowed');
      end if;
    elsif actor = new.user_id then
      if g.join_policy <> 'open' and not exists (
        select 1 from public.group_invitations i where i.group_id = new.group_id and i.user_id = new.user_id
      ) then
        perform private.raise_group_rule('join_not_allowed');
      end if;
    elsif not (
      private.has_group_permission(new.group_id, 'members.approve')
      and exists (select 1 from public.group_join_requests r where r.group_id = new.group_id and r.user_id = new.user_id)
    ) then
      perform private.raise_group_rule('join_not_allowed');
    end if;

    new.joined_at := now();
    return new;
  end if;

  -- Cascades from a deleted group or profile are always allowed.
  if not exists (select 1 from public.groups g2 where g2.id = old.group_id)
     or not exists (select 1 from public.profiles p where p.id = old.user_id) then
    return old;
  end if;
  if exists (select 1 from public.groups g2 where g2.id = old.group_id and g2.owner_id = old.user_id) then
    perform private.raise_group_rule('owner_cannot_leave');
  end if;
  -- Removing other members is a sanction (§3e): kick or ban inserted in this transaction.
  if actor is distinct from old.user_id and not exists (
    select 1 from public.sanctions s
    where s.group_id = old.group_id and s.user_id = old.user_id and s.type in ('kick', 'ban')
      and not s.interim and s.created_at = now()
  ) then
    perform private.raise_group_rule('leave_not_allowed');
  end if;
  return old;
end;
$$;

-- feed: a muted member does not comment on the group's posts.
create function private.comments_reject_muted()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if private.is_group_muted((select p.group_id from public.posts p where p.id = new.post_id), new.author_id) then
    perform private.raise_feed_rule('muted');
  end if;
  return new;
end;
$$;

create trigger comments_reject_muted
  before insert on public.comments
  for each row execute function private.comments_reject_muted();

-- feed: comments are removed by the platform team, or on a group post by an outranking
-- reports.review holder of the group (§3e, Ön inceleme).
create or replace function private.comments_before_update()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
  target_group uuid;
begin
  if pg_trigger_depth() > 1 then
    return new;
  end if;
  if (new.id, new.post_id, new.author_id, new.parent_id, new.body, new.created_at, new.like_count)
     is distinct from (old.id, old.post_id, old.author_id, old.parent_id, old.body, old.created_at, old.like_count) then
    perform private.raise_feed_rule('comment_immutable');
  end if;
  select p.group_id into target_group from public.posts p where p.id = old.post_id;
  if not (
    private.is_platform_staff(array['admin', 'moderator'])
    or (target_group is not null
        and private.has_group_permission(target_group, 'reports.review')
        and private.group_rank(target_group, actor) > private.group_rank(target_group, old.author_id))
  ) then
    perform private.raise_feed_rule('comment_immutable');
  end if;
  new.removed_by := actor;
  return new;
end;
$$;

-- live: a muted member listens only; no written comments.
create function private.live_comments_reject_muted()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if private.is_group_muted((select b.group_id from public.live_broadcasts b where b.id = new.broadcast_id), new.user_id) then
    perform private.raise_live_rule('muted');
  end if;
  return new;
end;
$$;

create trigger live_comments_reject_muted
  before insert on public.live_comments
  for each row execute function private.live_comments_reject_muted();

-- ---------------------------------------------------------------------------
-- Notifications (notifications owns the table)
-- ---------------------------------------------------------------------------
alter table public.notifications add column group_id uuid references public.groups (id) on delete cascade;
alter table public.notifications add column sanction_id uuid references public.sanctions (id) on delete cascade;
alter table public.notifications drop constraint notifications_type_check;
alter table public.notifications add constraint notifications_type_check
  check (type in ('like', 'comment', 'reply', 'comment_like', 'mention', 'follow', 'follow_request', 'follow_accepted',
                  'live_started', 'event_promoted', 'event_updated', 'event_canceled', 'event_reminder',
                  'case_vote', 'sanction_applied', 'appeal_submitted', 'appeal_decided'));

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
-- RPCs (security invoker wrappers of private definers, §6)
-- ---------------------------------------------------------------------------
create function private.person_card(uid uuid, target_group uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object('id', p.id, 'username', p.username, 'display_name', p.display_name, 'avatar_path', p.avatar_path,
                            'rank', private.group_rank(target_group, p.id))
  from public.profiles p where p.id = uid;
$$;

-- The group's moderation desk for reports.review holders: open reports grouped by target
-- (without reporters), cases, recent sanctions with appeals, and what the caller may do.
create function private.group_moderation(target_group uuid)
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

create function public.group_moderation(target_group uuid)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.group_moderation(target_group);
$$;

-- The caller's sanctions in every group, with the case's reason and the appeal.
create function private.my_sanctions()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(jsonb_agg(jsonb_build_object(
    'id', s.id,
    'group', jsonb_build_object('id', g.id, 'handle', g.handle, 'name', g.name, 'logo_path', g.logo_path),
    'type', s.type,
    'interim', s.interim,
    'starts_at', s.starts_at,
    'ends_at', s.ends_at,
    'lifted_at', s.lifted_at,
    'lift_reason', s.lift_reason,
    'reason', c.reason,
    'can_appeal', not s.interim and s.lifted_at is null and s.created_at > now() - interval '7 days'
                  and not exists (select 1 from public.sanction_appeals a where a.sanction_id = s.id),
    'appeal', (select jsonb_build_object('id', a.id, 'body', a.body, 'status', a.status, 'decision_note', a.decision_note,
                                         'created_at', a.created_at, 'decided_at', a.decided_at)
               from public.sanction_appeals a where a.sanction_id = s.id)
  ) order by s.created_at desc), '[]'::jsonb)
  from public.sanctions s
  join public.groups g on g.id = s.group_id
  join public.moderation_cases c on c.id = s.case_id
  where s.user_id = (select auth.uid());
$$;

create function public.my_sanctions()
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.my_sanctions();
$$;

revoke all on function private.person_card(uuid, uuid), private.group_moderation(uuid), private.my_sanctions() from public;
grant execute on function private.group_moderation(uuid), private.my_sanctions() to authenticated;
revoke all on function public.group_moderation(uuid), public.my_sanctions() from public, anon;
grant execute on function public.group_moderation(uuid), public.my_sanctions() to authenticated;
