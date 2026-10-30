-- 0058: "Bu akşam boşum", the small table and "Yakında başlıyor" (docs/ARCHITECTURE.md §3d, Bu akşam boşum ve küçük
-- masa; Faz 18g). A person says they are free tonight; only people who share a group with them see it. The server
-- proposes a small table of 3–5 such people; once three have joined, the table gets its own chat until the next noon.
-- Nobody's location is used.

-- ---------------------------------------------------------------------------
-- The evening (Turkey time): it runs until 04:00 the next morning.
-- ---------------------------------------------------------------------------
create function private.tonight_evening(at timestamptz default now())
returns date
language sql
stable
set search_path = ''
as $$
  select ((at at time zone 'Europe/Istanbul') - interval '4 hours')::date;
$$;

create function private.tonight_ends(evening date)
returns timestamptz
language sql
stable
set search_path = ''
as $$
  select (evening + interval '1 day 4 hours')::timestamp at time zone 'Europe/Istanbul';
$$;

-- A table's chat stays writable until the next noon.
create function private.tonight_table_closes(evening date)
returns timestamptz
language sql
stable
set search_path = ''
as $$
  select (evening + interval '1 day 12 hours')::timestamp at time zone 'Europe/Istanbul';
$$;

revoke all on function private.tonight_evening(timestamptz), private.tonight_ends(date), private.tonight_table_closes(date) from public;
grant execute on function private.tonight_evening(timestamptz), private.tonight_ends(date), private.tonight_table_closes(date)
  to authenticated, service_role;

-- Two people who are both members of an active group.
create function private.shares_group(a uuid, b uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select a <> b and exists (
    select 1 from public.group_members m1
    join public.group_members m2 on m2.group_id = m1.group_id and m2.user_id = b
    join public.groups g on g.id = m1.group_id and g.status = 'active'
    where m1.user_id = a
  );
$$;

revoke all on function private.shares_group(uuid, uuid) from public;
grant execute on function private.shares_group(uuid, uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- tonight_status
-- owner: events
-- One row per person and evening (kept for the evening counts); the person's own simple write.
-- ---------------------------------------------------------------------------
create table public.tonight_status (
  user_id    uuid not null references public.profiles (id) on delete cascade,
  evening    date not null,
  note       text not null default '' check (char_length(note) <= 80),
  until      timestamptz not null,
  closed_at  timestamptz,
  created_at timestamptz not null default now(),
  primary key (user_id, evening)
);

comment on table public.tonight_status is
  'owner: events. "Bu akşam boşum": seen by people who share a group; ends at 04:00 Turkey time or when closed.';

create index tonight_status_evening_idx on public.tonight_status (evening) where closed_at is null;

create function private.tonight_status_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.evening := private.tonight_evening();
  new.until := private.tonight_ends(new.evening);
  new.note := btrim(new.note);
  if tg_op = 'INSERT' then
    new.created_at := now();
    new.closed_at := case when new.closed_at is null then null else now() end;
  else
    new.user_id := old.user_id;
    new.created_at := old.created_at;
    new.closed_at := case when new.closed_at is null then null else coalesce(old.closed_at, now()) end;
  end if;
  return new;
end;
$$;

create trigger tonight_status_guard
  before insert or update on public.tonight_status
  for each row execute function private.tonight_status_guard();

-- Free right now: open tonight and not closed.
create function private.is_free_tonight(uid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.tonight_status s
    where s.user_id = uid and s.evening = private.tonight_evening() and s.closed_at is null and s.until > now()
  ) and private.is_account_active(uid);
$$;

revoke all on function private.is_free_tonight(uuid) from public;
grant execute on function private.is_free_tonight(uuid) to authenticated, service_role;

alter table public.tonight_status enable row level security;
revoke all on public.tonight_status from anon, authenticated;
grant select, insert (user_id, note, closed_at), update (note, closed_at) on public.tonight_status to authenticated;

create policy tonight_status_select on public.tonight_status for select to authenticated
  using (
    user_id = (select auth.uid())
    or (
      closed_at is null and until > now()
      and private.shares_group(user_id, (select auth.uid()))
      and not private.is_blocked_between(user_id, (select auth.uid()))
      and private.is_account_active(user_id)
    )
  );

create policy tonight_status_insert_own on public.tonight_status for insert to authenticated
  with check (user_id = (select auth.uid()) and (select private.is_account_active(auth.uid())));

create policy tonight_status_update_own on public.tonight_status for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()) and (select private.is_account_active(auth.uid())));

-- ---------------------------------------------------------------------------
-- tonight_tables, tonight_table_invites
-- owner: events
-- Written by the backend (C#); the invited read their own tables.
-- ---------------------------------------------------------------------------
create table public.tonight_tables (
  id         uuid primary key default gen_random_uuid(),
  created_by uuid not null references public.profiles (id) on delete cascade,
  evening    date not null,
  closes_at  timestamptz not null,
  created_at timestamptz not null default now(),
  unique (created_by, evening)
);

comment on table public.tonight_tables is 'owner: events. A small table of tonight''s free people; written by the backend.';

create table public.tonight_table_invites (
  table_id    uuid not null references public.tonight_tables (id) on delete cascade,
  user_id     uuid not null references public.profiles (id) on delete cascade,
  evening     date not null,
  state       text not null default 'pending' check (state in ('pending', 'accepted', 'declined', 'left')),
  created_at  timestamptz not null default now(),
  answered_at timestamptz,
  primary key (table_id, user_id)
);

comment on table public.tonight_table_invites is
  'owner: events. Who is asked to a table and their answer; one accepted table per person and evening.';

create unique index tonight_table_invites_one_per_evening on public.tonight_table_invites (user_id, evening)
  where state = 'accepted';
create index tonight_table_invites_user_idx on public.tonight_table_invites (user_id, evening);

create function private.raise_tonight_rule(code text)
returns void
language plpgsql
set search_path = ''
as $$
begin
  raise exception '%', code using errcode = 'P0001';
end;
$$;

create function private.tonight_table_invites_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  t public.tonight_tables;
begin
  select * into t from public.tonight_tables where id = new.table_id;
  if t.closes_at <= now() then
    perform private.raise_tonight_rule('tonight_closed');
  end if;
  new.evening := t.evening;
  if tg_op = 'INSERT' then
    new.created_at := now();
    new.answered_at := case when new.state = 'pending' then null else now() end;
  elsif new.state is distinct from old.state then
    new.answered_at := now();
  end if;
  if new.state = 'accepted' and exists (
    select 1 from public.tonight_table_invites i
    where i.user_id = new.user_id and i.evening = t.evening and i.state = 'accepted' and i.table_id <> new.table_id
  ) then
    perform private.raise_tonight_rule('tonight_already_in_table');
  end if;
  return new;
end;
$$;

create trigger tonight_table_invites_guard
  before insert or update on public.tonight_table_invites
  for each row execute function private.tonight_table_invites_guard();

create function private.is_at_table(target_table uuid, uid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (select 1 from public.tonight_table_invites i where i.table_id = target_table and i.user_id = uid);
$$;

revoke all on function private.is_at_table(uuid, uuid) from public;
grant execute on function private.is_at_table(uuid, uuid) to authenticated, service_role;

alter table public.tonight_tables enable row level security;
alter table public.tonight_table_invites enable row level security;
revoke all on public.tonight_tables, public.tonight_table_invites from anon, authenticated;
grant select on public.tonight_tables, public.tonight_table_invites to authenticated;

create policy tonight_tables_select_invited on public.tonight_tables for select to authenticated
  using (private.is_at_table(id, (select auth.uid())));

-- Own invitations; others at the table only once they joined (pending people are not named).
create policy tonight_table_invites_select on public.tonight_table_invites for select to authenticated
  using (
    user_id = (select auth.uid())
    or (state = 'accepted' and private.is_at_table(table_id, (select auth.uid())))
  );

-- ---------------------------------------------------------------------------
-- Candidates: free tonight, sharing a group with the founder, no block, not at another table tonight.
-- More shared groups first, then shared interests; ties at random.
-- ---------------------------------------------------------------------------
create function private.tonight_candidates(founder uuid, max_people integer default 5)
returns setof uuid
language sql
volatile
security definer
set search_path = ''
as $$
  select s.user_id
  from public.tonight_status s
  where s.evening = private.tonight_evening() and s.closed_at is null and s.until > now()
    and s.user_id <> founder
    and private.is_account_active(s.user_id)
    and private.shares_group(founder, s.user_id)
    and not private.is_blocked_between(founder, s.user_id)
    and not exists (select 1 from public.tonight_table_invites i
                    where i.user_id = s.user_id and i.evening = s.evening and i.state = 'accepted')
  order by
    (select count(*) from public.group_members m1
     join public.group_members m2 on m2.group_id = m1.group_id and m2.user_id = s.user_id
     where m1.user_id = founder) desc,
    (select count(*) from public.profile_interests a
     join public.profile_interests b on b.category_slug = a.category_slug and b.user_id = s.user_id
     where a.user_id = founder) desc,
    random()
  limit max_people;
$$;

revoke all on function private.tonight_candidates(uuid, integer) from public;
grant execute on function private.tonight_candidates(uuid, integer) to service_role;

-- ---------------------------------------------------------------------------
-- Notifications (events): the invitation, and "the table is set" when the third person joins.
-- ---------------------------------------------------------------------------
alter table public.notifications add column table_id uuid references public.tonight_tables (id) on delete cascade;

alter table public.notifications drop constraint notifications_type_check;
alter table public.notifications add constraint notifications_type_check
  check (type in ('like', 'comment', 'reply', 'comment_like', 'mention', 'follow', 'follow_request', 'follow_accepted',
                  'live_scheduled', 'live_started', 'event_promoted', 'event_updated', 'event_canceled', 'event_reminder',
                  'case_vote', 'sanction_applied', 'appeal_submitted', 'appeal_decided',
                  'event_approved', 'event_declined', 'event_review', 'goal_completed',
                  'teammate_request', 'teammate_accepted', 'match_created', 'match_super_liked',
                  'welcome_requested', 'welcome_matched', 'welcome_released', 'welcome_withdrawn', 'welcome_thanked',
                  'league_result', 'event_series_limit', 'tonight_table_invite', 'tonight_table_ready'));

create function private.tonight_table_invites_notify()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  founder uuid := (select t.created_by from public.tonight_tables t where t.id = new.table_id);
  joined int;
begin
  if tg_op = 'INSERT' and new.state = 'pending' then
    if private.is_account_active(new.user_id) and not private.is_blocked_between(new.user_id, founder) then
      insert into public.notifications (recipient_id, actor_id, type, table_id)
      values (new.user_id, founder, 'tonight_table_invite', new.table_id);
    end if;
  elsif tg_op = 'UPDATE' and new.state = 'accepted' and old.state <> 'accepted' then
    select count(*) into joined from public.tonight_table_invites i where i.table_id = new.table_id and i.state = 'accepted';
    if joined = 3 then
      insert into public.notifications (recipient_id, actor_id, type, table_id)
      select i.user_id, new.user_id, 'tonight_table_ready', new.table_id
      from public.tonight_table_invites i
      where i.table_id = new.table_id and i.state = 'accepted' and i.user_id <> new.user_id
        and private.is_account_active(i.user_id);
    end if;
  end if;
  return null;
end;
$$;

revoke all on function private.tonight_table_invites_notify() from public;

create trigger tonight_table_invites_notify
  after insert or update on public.tonight_table_invites
  for each row execute function private.tonight_table_invites_notify();

-- ---------------------------------------------------------------------------
-- Messaging: the table's chat (owner: messaging). Opens with the third person; members are those at the table.
-- ---------------------------------------------------------------------------
alter table public.conversations add column table_id uuid unique references public.tonight_tables (id) on delete cascade;
alter table public.conversations drop constraint conversations_kind_check;
alter table public.conversations add constraint conversations_kind_check check (kind in ('direct', 'group', 'table'));
alter table public.conversations drop constraint conversations_shape;
alter table public.conversations add constraint conversations_shape check (
  (kind = 'direct' and user_a is not null and user_b is not null and user_a < user_b and group_id is null and table_id is null
   and not admins_only)
  or (kind = 'group' and group_id is not null and user_a is null and user_b is null and table_id is null)
  or (kind = 'table' and table_id is not null and user_a is null and user_b is null and group_id is null and not admins_only)
);

create function private.sync_table_conversation()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  conv uuid;
begin
  select c.id into conv from public.conversations c where c.table_id = new.table_id;
  if new.state = 'accepted' then
    if conv is null and (select count(*) from public.tonight_table_invites i
                         where i.table_id = new.table_id and i.state = 'accepted') >= 3 then
      insert into public.conversations (kind, table_id, created_by)
      values ('table', new.table_id, (select t.created_by from public.tonight_tables t where t.id = new.table_id))
      returning id into conv;
      insert into public.conversation_members (conversation_id, user_id)
      select conv, i.user_id from public.tonight_table_invites i where i.table_id = new.table_id and i.state = 'accepted'
      on conflict do nothing;
    elsif conv is not null then
      insert into public.conversation_members (conversation_id, user_id) values (conv, new.user_id) on conflict do nothing;
    end if;
  elsif conv is not null and tg_op = 'UPDATE' and old.state = 'accepted' then
    delete from public.conversation_members m where m.conversation_id = conv and m.user_id = new.user_id;
  end if;
  return null;
end;
$$;

revoke all on function private.sync_table_conversation() from public;

create trigger sync_table_conversation
  after insert or update on public.tonight_table_invites
  for each row execute function private.sync_table_conversation();

create or replace function private.can_read_conversation_as(uid uuid, conv uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.conversations c
    where c.id = conv and (
      (c.kind = 'direct' and uid in (c.user_a, c.user_b))
      or (c.kind = 'group' and exists (select 1 from public.group_members m where m.group_id = c.group_id and m.user_id = uid))
      or (c.kind = 'table' and exists (select 1 from public.conversation_members m where m.conversation_id = c.id and m.user_id = uid))
    )
  );
$$;

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
  if c.kind = 'table' then
    if (select t.closes_at from public.tonight_tables t where t.id = c.table_id) <= now() then
      return 'table_closed';
    end if;
    return null;
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
  if not (private.are_teammates(uid, peer) and private.has_matching_feature(uid, 'teammates')) then
    if private.are_matched(uid, peer) then
      if not private.has_matching_feature(uid, 'chat') then
        return 'match_chat_locked';
      end if;
    elsif private.are_teammates(uid, peer) then
      return 'teammate_chat_locked';
    elsif private.match_ended_between(uid, peer) then
      return 'match_ended';
    else
      return 'message_not_allowed';
    end if;
  end if;
  -- An old request still holds until it is answered.
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

create or replace function private.conversation_card(c public.conversations, uid uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  with me as (select * from public.conversation_members m where m.conversation_id = c.id and m.user_id = uid),
  peer as (
    select p.id, p.username, p.display_name, p.avatar_path, m.state, m.last_read_at
    from public.profiles p
    left join public.conversation_members m on m.conversation_id = c.id and m.user_id = p.id
    where c.kind = 'direct' and p.id = private.conversation_peer(c.id, uid)
  ),
  last_message as (
    select m.id, m.sender_id, m.body, m.image_path is not null as has_image, m.created_at, m.deleted_at is not null as deleted
    from public.messages m
    where m.conversation_id = c.id and not private.is_blocked_between(m.sender_id, uid)
    order by m.created_at desc limit 1
  )
  select jsonb_build_object(
    'id', c.id,
    'kind', c.kind,
    'admins_only', c.admins_only,
    'my_state', coalesce((select state from me), 'active'),
    'peer', (select jsonb_build_object('id', id, 'username', username, 'display_name', display_name, 'avatar_path', avatar_path,
                                       'state', state,
                                       -- No read receipts while the other side has not accepted.
                                       'read_at', case when state = 'active' then last_read_at end) from peer),
    'group', case when c.kind = 'group' then (select jsonb_build_object('id', g.id, 'handle', g.handle, 'name', g.name, 'logo_path', g.logo_path)
                                              from public.groups g where g.id = c.group_id) end,
    'table', case when c.kind = 'table' then (
      select jsonb_build_object('id', t.id, 'closes_at', t.closes_at,
                                'members', (select count(*) from public.conversation_members m where m.conversation_id = c.id))
      from public.tonight_tables t where t.id = c.table_id) end,
    'last_message', (select jsonb_build_object('id', id, 'sender_id', sender_id, 'body', body, 'has_image', has_image,
                                               'created_at', created_at, 'deleted', deleted) from last_message),
    'unread', (select count(*) from public.messages m
               where m.conversation_id = c.id and m.sender_id <> uid and m.deleted_at is null
                 and m.created_at > coalesce((select last_read_at from me), '-infinity'::timestamptz)
                 and not private.is_blocked_between(m.sender_id, uid)),
    'blocker', private.message_blocker(uid, c.id),
    'can_manage', c.kind = 'group' and private.user_has_group_permission(uid, c.group_id, 'group.edit')
  );
$$;

create or replace function private.my_conversations()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(jsonb_agg(private.conversation_card(c, (select auth.uid())) order by c.last_message_at desc nulls last), '[]'::jsonb)
  from (
    select c.* from public.conversations c
    join public.conversation_members m on m.conversation_id = c.id and m.user_id = (select auth.uid())
    where c.kind = 'direct' and m.state <> 'declined' and c.last_message_at is not null
      and not private.is_blocked_between(c.user_a, c.user_b)
    union all
    select c.* from public.conversations c
    join public.group_members gm on gm.group_id = c.group_id and gm.user_id = (select auth.uid())
    join public.groups g on g.id = c.group_id and g.status = 'active'
    where c.kind = 'group' and c.last_message_at is not null
    union all
    select c.* from public.conversations c
    join public.conversation_members m on m.conversation_id = c.id and m.user_id = (select auth.uid())
    where c.kind = 'table'
    order by last_message_at desc nulls last
    limit 200
  ) c;
$$;

-- ---------------------------------------------------------------------------
-- Reads for the app
-- ---------------------------------------------------------------------------
-- The people free tonight who share a group with the viewer, with the names of the shared groups.
create function private.tonight_people()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(jsonb_agg(person order by opened desc), '[]'::jsonb)
  from (
    select s.created_at as opened, jsonb_build_object(
      'id', p.id, 'username', p.username, 'display_name', p.display_name, 'avatar_path', p.avatar_path, 'note', s.note,
      'groups', (select coalesce(jsonb_agg(g.name order by g.name), '[]'::jsonb) from (
                   select g.name from public.groups g
                   join public.group_members m1 on m1.group_id = g.id and m1.user_id = (select auth.uid())
                   join public.group_members m2 on m2.group_id = g.id and m2.user_id = p.id
                   where g.status = 'active' order by g.name limit 3) g)) as person
    from public.tonight_status s
    join public.profiles p on p.id = s.user_id
    where s.evening = private.tonight_evening() and s.closed_at is null and s.until > now()
      and private.is_account_active(s.user_id)
      and private.shares_group(s.user_id, (select auth.uid()))
      and not private.is_blocked_between(s.user_id, (select auth.uid()))
    order by s.created_at desc
    limit 50
  ) people;
$$;

create function public.tonight_people()
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.tonight_people();
$$;

-- A table as the viewer sees it: the founder and who joined by name, the pending as a count.
create function private.tonight_table_card(t public.tonight_tables, uid uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'id', t.id,
    'closes_at', t.closes_at,
    'founder', (select jsonb_build_object('id', p.id, 'username', p.username, 'display_name', p.display_name,
                                          'avatar_path', p.avatar_path)
                from public.profiles p where p.id = t.created_by),
    'my_state', (select i.state from public.tonight_table_invites i where i.table_id = t.id and i.user_id = uid),
    'joined', coalesce((select jsonb_agg(jsonb_build_object('id', p.id, 'username', p.username, 'display_name', p.display_name,
                                                            'avatar_path', p.avatar_path) order by i.answered_at)
                        from public.tonight_table_invites i join public.profiles p on p.id = i.user_id
                        where i.table_id = t.id and i.state = 'accepted'), '[]'::jsonb),
    'pending', (select count(*) from public.tonight_table_invites i where i.table_id = t.id and i.state = 'pending'),
    'conversation_id', (select c.id from public.conversations c where c.table_id = t.id)
  );
$$;

-- The viewer's evening: their status, how many are free, their table and open invitations.
create function private.my_tonight()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'status', (select jsonb_build_object('note', s.note, 'until', s.until) from public.tonight_status s
               where s.user_id = (select auth.uid()) and s.evening = private.tonight_evening()
                 and s.closed_at is null and s.until > now()),
    'people', jsonb_array_length(private.tonight_people()),
    'table', (select private.tonight_table_card(t, (select auth.uid())) from public.tonight_tables t
              join public.tonight_table_invites i on i.table_id = t.id
              where i.user_id = (select auth.uid()) and i.evening = private.tonight_evening() and i.state = 'accepted'),
    'invites', coalesce((select jsonb_agg(private.tonight_table_card(t, (select auth.uid())) order by i.created_at desc)
                         from public.tonight_tables t
                         join public.tonight_table_invites i on i.table_id = t.id
                         where i.user_id = (select auth.uid()) and i.evening = private.tonight_evening()
                           and i.state = 'pending' and t.closes_at > now()), '[]'::jsonb)
  );
$$;

create function public.my_tonight()
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.my_tonight();
$$;

-- Events starting in the next 6 hours: the viewer's groups first, then other groups in the provinces of their groups.
create function private.starting_soon()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(jsonb_agg(private.event_card(ev) order by soon.mine desc, ev.starts_at), '[]'::jsonb)
  from (
    select e.id, exists (select 1 from public.group_members m where m.group_id = e.group_id and m.user_id = (select auth.uid())) as mine
    from public.events e
    join public.groups g on g.id = e.group_id and g.status = 'active'
    where e.canceled_at is null and e.starts_at > now() and e.starts_at <= now() + interval '6 hours'
      and (
        exists (select 1 from public.group_members m where m.group_id = e.group_id and m.user_id = (select auth.uid()))
        or g.province in (select mg.province from public.groups mg
                          join public.group_members m on m.group_id = mg.id and m.user_id = (select auth.uid())
                          where mg.province is not null)
      )
    order by mine desc, e.starts_at
    limit 10
  ) soon
  join public.events ev on ev.id = soon.id;
$$;

create function public.starting_soon()
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.starting_soon();
$$;

revoke all on function private.tonight_people(), public.tonight_people(), private.tonight_table_card(public.tonight_tables, uuid),
  private.my_tonight(), public.my_tonight(), private.starting_soon(), public.starting_soon() from public;
grant execute on function private.tonight_people(), public.tonight_people(), private.tonight_table_card(public.tonight_tables, uuid),
  private.my_tonight(), public.my_tonight(), private.starting_soon(), public.starting_soon() to authenticated;
