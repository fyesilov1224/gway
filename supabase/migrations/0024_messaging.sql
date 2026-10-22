-- 0024_messaging
-- Phase 15: direct messages with a request inbox, one chat per group, photos, reports of messages.
-- Rules: docs/ARCHITECTURE.md §3f.

-- ---------------------------------------------------------------------------
-- conversations, conversation_members, messages
-- owner: messaging
-- ---------------------------------------------------------------------------
create table public.conversations (
  id              uuid primary key default gen_random_uuid(),
  kind            text not null check (kind in ('direct', 'group')),
  user_a          uuid references public.profiles (id) on delete cascade,
  user_b          uuid references public.profiles (id) on delete cascade,
  group_id        uuid unique references public.groups (id) on delete cascade,
  created_by      uuid references public.profiles (id) on delete set null,
  admins_only     boolean not null default false,
  created_at      timestamptz not null default now(),
  last_message_at timestamptz,
  constraint conversations_shape check (
    (kind = 'direct' and user_a is not null and user_b is not null and user_a < user_b and group_id is null and not admins_only)
    or (kind = 'group' and group_id is not null and user_a is null and user_b is null)
  ),
  constraint conversations_pair unique (user_a, user_b)
);

comment on table public.conversations is
  'owner: messaging. A direct conversation per pair (smaller id first) or one chat per group; written by the backend.';

create index conversations_created_by_idx on public.conversations (created_by, created_at desc) where kind = 'direct';

create table public.conversation_members (
  conversation_id uuid not null references public.conversations (id) on delete cascade,
  user_id         uuid not null references public.profiles (id) on delete cascade,
  state           text not null default 'active' check (state in ('active', 'request', 'declined')),
  last_read_at    timestamptz,
  created_at      timestamptz not null default now(),
  primary key (conversation_id, user_id)
);

comment on table public.conversation_members is
  'owner: messaging. Direct: both people and their request state. Group: read time only (membership comes from the group).';

create index conversation_members_user_idx on public.conversation_members (user_id);

create table public.messages (
  id              uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations (id) on delete cascade,
  sender_id       uuid not null references public.profiles (id) on delete cascade,
  body            text not null default '' check (char_length(body) <= 2000),
  image_path      text check (char_length(image_path) <= 200),
  created_at      timestamptz not null default now(),
  deleted_at      timestamptz,
  removed_reason  text check (char_length(removed_reason) <= 500)
);

comment on table public.messages is
  'owner: messaging. Deleting keeps the row and clears the content; removed_reason marks a moderator''s removal.';

create index messages_conversation_idx on public.messages (conversation_id, created_at desc);
create index messages_sender_idx on public.messages (sender_id, created_at desc);

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------
create function private.raise_message_rule(code text)
returns void
language plpgsql
set search_path = ''
as $$
begin
  raise exception '%', code using errcode = 'P0001';
end;
$$;

-- Who reads a conversation: the two people of a direct one, the members of the group.
create function private.can_read_conversation_as(uid uuid, conv uuid)
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
    )
  );
$$;

create function private.can_read_conversation(conv uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select private.can_read_conversation_as((select auth.uid()), conv);
$$;

create function private.conversation_peer(conv uuid, uid uuid)
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select case when c.user_a = uid then c.user_b else c.user_a end
  from public.conversations c where c.id = conv and c.kind = 'direct';
$$;

-- Messaging rules for a write by uid; the reason a message cannot be sent, or null.
create function private.message_blocker(uid uuid, conv uuid)
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

revoke all on function private.can_read_conversation_as(uuid, uuid), private.can_read_conversation(uuid),
  private.conversation_peer(uuid, uuid), private.message_blocker(uuid, uuid) from public;
grant execute on function private.can_read_conversation_as(uuid, uuid), private.can_read_conversation(uuid),
  private.conversation_peer(uuid, uuid), private.message_blocker(uuid, uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------
alter table public.conversations enable row level security;
alter table public.conversation_members enable row level security;
alter table public.messages enable row level security;

revoke all on public.conversations, public.conversation_members, public.messages from anon, authenticated;
grant select on public.conversations, public.conversation_members, public.messages to authenticated;

create policy conversations_select_readers on public.conversations for select to authenticated
  using (private.can_read_conversation(id));

-- Own rows; in a direct conversation also the other person's (read time for "Görüldü").
create policy conversation_members_select on public.conversation_members for select to authenticated
  using (
    user_id = (select auth.uid())
    or exists (select 1 from public.conversations c
               where c.id = conversation_id and c.kind = 'direct' and (select auth.uid()) in (c.user_a, c.user_b))
  );

create policy messages_select_readers on public.messages for select to authenticated
  using (private.can_read_conversation(conversation_id) and not private.is_blocked_between(sender_id, (select auth.uid())));

-- ---------------------------------------------------------------------------
-- Triggers
-- ---------------------------------------------------------------------------

-- Conversations: created by the backend or the group trigger; only the group chat mode changes.
create function private.conversations_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    new.created_at := now();
    new.last_message_at := null;
    return new;
  end if;
  if tg_op = 'DELETE' then
    return old;
  end if;
  if pg_trigger_depth() > 1 then
    return new;
  end if;
  if (new.id, new.kind, new.user_a, new.user_b, new.group_id, new.created_by, new.created_at)
     is distinct from (old.id, old.kind, old.user_a, old.user_b, old.group_id, old.created_by, old.created_at)
     or new.last_message_at is distinct from old.last_message_at then
    perform private.raise_message_rule('conversation_immutable');
  end if;
  if new.admins_only is distinct from old.admins_only and not private.has_group_permission(old.group_id, 'group.edit') then
    perform private.raise_message_rule('message_forbidden');
  end if;
  return new;
end;
$$;

create trigger conversations_guard
  before insert or update or delete on public.conversations
  for each row execute function private.conversations_guard();

create function private.create_group_conversation()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.conversations (kind, group_id) values ('group', new.id);
  return null;
end;
$$;

revoke all on function private.create_group_conversation() from public;

create trigger create_group_conversation
  after insert on public.groups
  for each row execute function private.create_group_conversation();

insert into public.conversations (kind, group_id) select 'group', g.id from public.groups g;

-- Members: a request state changes only by its owner (accept or decline); the read time by its owner.
create function private.conversation_members_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
begin
  if pg_trigger_depth() > 1 or tg_op = 'DELETE' then
    return coalesce(new, old);
  end if;
  if tg_op = 'INSERT' then
    if not private.can_read_conversation_as(new.user_id, new.conversation_id) then
      perform private.raise_message_rule('message_forbidden');
    end if;
    new.created_at := now();
    return new;
  end if;
  if (new.conversation_id, new.user_id, new.created_at) is distinct from (old.conversation_id, old.user_id, old.created_at) then
    perform private.raise_message_rule('message_forbidden');
  end if;
  if (new.state, new.last_read_at) is distinct from (old.state, old.last_read_at) and actor is distinct from old.user_id then
    perform private.raise_message_rule('message_forbidden');
  end if;
  return new;
end;
$$;

create trigger conversation_members_guard
  before insert or update or delete on public.conversation_members
  for each row execute function private.conversation_members_guard();

-- Messages: the sender's own write under the messaging rules; deleting clears the content.
create function private.messages_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
  blocker text;
  chat public.conversations;
begin
  if tg_op = 'INSERT' then
    if actor is null or actor is distinct from new.sender_id then
      perform private.raise_message_rule('message_forbidden');
    end if;
    blocker := private.message_blocker(actor, new.conversation_id);
    if blocker is not null then
      perform private.raise_message_rule(blocker);
    end if;
    if (select count(*) from public.messages m where m.sender_id = actor and m.created_at > now() - interval '1 minute') >= 30 then
      perform private.raise_message_rule('message_rate_limited');
    end if;
    new.body := btrim(new.body);
    if new.body = '' and new.image_path is null then
      perform private.raise_message_rule('message_empty');
    end if;
    if new.image_path is not null and not starts_with(new.image_path, new.conversation_id::text || '/') then
      perform private.raise_message_rule('message_image_invalid');
    end if;
    new.created_at := now();
    new.deleted_at := null;
    new.removed_reason := null;
    return new;
  end if;

  if tg_op = 'DELETE' then
    if pg_trigger_depth() > 1 then
      return old;
    end if;
    perform private.raise_message_rule('message_immutable');
  end if;

  if pg_trigger_depth() > 1 then
    return new;
  end if;
  if (new.id, new.conversation_id, new.sender_id, new.created_at) is distinct from (old.id, old.conversation_id, old.sender_id, old.created_at)
     or old.deleted_at is not null or new.deleted_at is null then
    perform private.raise_message_rule('message_immutable');
  end if;
  select * into chat from public.conversations where id = old.conversation_id;
  if new.removed_reason is null then
    if actor is distinct from old.sender_id then
      perform private.raise_message_rule('message_forbidden');
    end if;
  elsif not (private.is_platform_staff(array['admin', 'moderator'])
             or (chat.kind = 'group' and private.has_group_permission(chat.group_id, 'reports.review'))) then
    perform private.raise_message_rule('message_forbidden');
  end if;
  new.body := '';
  new.image_path := null;
  new.deleted_at := now();
  return new;
end;
$$;

create trigger messages_guard
  before insert or update or delete on public.messages
  for each row execute function private.messages_guard();

-- After a message: the chat moves up, the sender has read it, and someone who had declined reopens it.
create function private.messages_after_insert()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.conversations set last_message_at = new.created_at where id = new.conversation_id;
  insert into public.conversation_members (conversation_id, user_id, last_read_at)
  values (new.conversation_id, new.sender_id, new.created_at)
  on conflict (conversation_id, user_id) do update
    set last_read_at = excluded.last_read_at,
        state = case when public.conversation_members.state = 'declined' then 'active' else public.conversation_members.state end;
  return null;
end;
$$;

revoke all on function private.messages_after_insert() from public;

create trigger messages_after_insert
  after insert on public.messages
  for each row execute function private.messages_after_insert();

-- ---------------------------------------------------------------------------
-- Direct conversations and requests (called by the backend as the actor)
-- ---------------------------------------------------------------------------

-- Finds or opens the conversation with another person; the other side is a request unless they are
-- teammates or follow each other.
create function private.open_direct_conversation(other uuid)
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

  select c.id into conv from public.conversations c where c.user_a = least(actor, other) and c.user_b = greatest(actor, other);
  if conv is not null then
    select m.state into other_state from public.conversation_members m where m.conversation_id = conv and m.user_id = other;
    return jsonb_build_object('id', conv, 'state', other_state);
  end if;

  if other_private and not private.user_follows(actor, other) then
    perform private.raise_message_rule('message_private');
  end if;
  if private.are_teammates(actor, other) or (private.user_follows(actor, other) and private.user_follows(other, actor)) then
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

-- The recipient accepts or declines a request.
create function private.answer_message_request(conv uuid, accept boolean)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.conversation_members
  set state = case when accept then 'active' else 'declined' end,
      last_read_at = case when accept then now() else last_read_at end
  where conversation_id = conv and user_id = (select auth.uid()) and state = 'request';
  if not found then
    perform private.raise_message_rule('message_no_request');
  end if;
end;
$$;

revoke all on function private.open_direct_conversation(uuid), private.answer_message_request(uuid, boolean) from public;
grant execute on function private.open_direct_conversation(uuid), private.answer_message_request(uuid, boolean) to service_role;

-- ---------------------------------------------------------------------------
-- Reads
-- ---------------------------------------------------------------------------

-- The caller's own read time (own simple write).
create function private.mark_conversation_read(conv uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
begin
  if actor is null or not private.can_read_conversation(conv) then
    return;
  end if;
  insert into public.conversation_members (conversation_id, user_id, last_read_at)
  values (conv, actor, now())
  on conflict (conversation_id, user_id) do update set last_read_at = now()
    where public.conversation_members.state <> 'request';
end;
$$;

create function public.mark_conversation_read(conv uuid)
returns void
language sql
security invoker
set search_path = ''
as $$
  select private.mark_conversation_read(conv);
$$;

-- One conversation as the list and the chat header show it.
create function private.conversation_card(c public.conversations, uid uuid)
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
    'last_message', (select jsonb_build_object('id', id, 'sender_id', sender_id, 'body', body, 'has_image', has_image,
                                               'created_at', created_at, 'deleted', deleted) from last_message),
    'unread', (select count(*) from public.messages m
               where m.conversation_id = c.id and m.sender_id <> uid and m.deleted_at is null
                 and m.created_at > coalesce((select last_read_at from me), '-infinity'::timestamptz)
                 and not private.is_blocked_between(m.sender_id, uid)),
    'blocker', private.message_blocker(uid, c.id)
  );
$$;

-- The caller's conversations: direct ones (not declined, not with blocked people) and group chats with messages.
create function private.my_conversations()
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
    order by last_message_at desc nulls last
    limit 200
  ) c;
$$;

create function public.my_conversations()
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.my_conversations();
$$;

create function private.conversation_detail(conv uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select private.conversation_card(c, (select auth.uid()))
  from public.conversations c
  where c.id = conv and private.can_read_conversation(c.id);
$$;

create function public.conversation_detail(conv uuid)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.conversation_detail(conv);
$$;

-- A group's chat id, for the group page.
create function public.group_conversation(target_group uuid)
returns uuid
language sql
stable
security invoker
set search_path = ''
as $$
  select c.id from public.conversations c where c.group_id = target_group and private.can_read_conversation(c.id);
$$;

revoke all on function private.mark_conversation_read(uuid), private.conversation_card(public.conversations, uuid),
  private.my_conversations(), private.conversation_detail(uuid) from public;
grant execute on function private.mark_conversation_read(uuid), private.conversation_card(public.conversations, uuid),
  private.my_conversations(), private.conversation_detail(uuid) to authenticated;
revoke all on function public.mark_conversation_read(uuid), public.my_conversations(), public.conversation_detail(uuid),
  public.group_conversation(uuid) from public, anon;
grant execute on function public.mark_conversation_read(uuid), public.my_conversations(), public.conversation_detail(uuid),
  public.group_conversation(uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- Photos
-- ---------------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types) values
  ('message-images', 'message-images', false, 5242880, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

create function private.folder_conversation(object_name text)
returns uuid
language sql
immutable
set search_path = ''
as $$
  select case when (storage.foldername(object_name))[1] ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
              then ((storage.foldername(object_name))[1])::uuid end;
$$;

grant execute on function private.folder_conversation(text) to authenticated;

create policy message_images_select_readers
  on storage.objects for select to authenticated
  using (bucket_id = 'message-images' and private.can_read_conversation(private.folder_conversation(name)));

create policy message_images_insert_readers
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'message-images'
    and private.can_read_conversation(private.folder_conversation(name))
    and (select private.is_account_active(auth.uid()))
  );

-- ---------------------------------------------------------------------------
-- Reports of messages (moderation owns reports)
-- ---------------------------------------------------------------------------
alter table public.reports drop constraint reports_target_type_check;
alter table public.reports add constraint reports_target_type_check
  check (target_type in ('post', 'comment', 'event', 'live_comment', 'user', 'message'));

-- As in 0012, with messages: a group chat's message goes to the group, a direct one to the platform.
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
  end if;
  excerpt := left(btrim(coalesce(excerpt, '')), 500);
end;
$$;

-- ---------------------------------------------------------------------------
-- Realtime
-- ---------------------------------------------------------------------------
alter publication supabase_realtime add table public.messages, public.conversation_members;
