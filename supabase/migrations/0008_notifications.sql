-- 0008_notifications
-- Phase 4: in-app notifications. Rows are created by triggers on the feed and
-- profile tables (likes, comments, replies, comment likes, mentions, follows,
-- follow requests) and removed again when the cause is undone.
-- Rules: docs/ARCHITECTURE.md §3c.

-- ---------------------------------------------------------------------------
-- notifications
-- owner: notifications
-- ---------------------------------------------------------------------------
create table public.notifications (
  id           bigint generated always as identity primary key,
  recipient_id uuid not null references public.profiles (id) on delete cascade,
  actor_id     uuid not null references public.profiles (id) on delete cascade,
  type         text not null check (type in ('like', 'comment', 'reply', 'comment_like', 'mention',
                                            'follow', 'follow_request', 'follow_accepted')),
  post_id      uuid references public.posts (id) on delete cascade,
  comment_id   uuid references public.comments (id) on delete cascade,
  created_at   timestamptz not null default now(),
  read_at      timestamptz
);
create index notifications_recipient_idx on public.notifications (recipient_id, created_at desc);
create index notifications_unread_idx on public.notifications (recipient_id) where read_at is null;
comment on table public.notifications is
  'owner: notifications. In-app notifications; written by triggers only. Push delivery comes later from these rows.';

alter table public.notifications enable row level security;
revoke all on public.notifications from anon, authenticated;
grant select, delete on public.notifications to authenticated;
grant update (read_at) on public.notifications to authenticated;

create policy notifications_select_own on public.notifications for select to authenticated
  using (recipient_id = (select auth.uid()));
create policy notifications_update_own on public.notifications for update to authenticated
  using (recipient_id = (select auth.uid())) with check (recipient_id = (select auth.uid()));
create policy notifications_delete_own on public.notifications for delete to authenticated
  using (recipient_id = (select auth.uid()));

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

-- Inserts unless it would notify yourself, a blocked pair or an inactive account.
create function private.notify(recipient uuid, actor uuid, kind text, post uuid default null, comment uuid default null)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if recipient is null or actor is null or recipient = actor
     or private.is_blocked_between(recipient, actor)
     or not private.is_account_active(recipient) then
    return;
  end if;
  insert into public.notifications (recipient_id, actor_id, type, post_id, comment_id)
  values (recipient, actor, kind, post, comment);
end;
$$;

-- Accounts named with @username in a text (at most 20).
create function private.mentioned_users(body text)
returns setof uuid
language sql
stable
security definer
set search_path = ''
as $$
  select p.id
  from public.profiles p
  where p.username in (select distinct lower(m[1]) from regexp_matches(body, '@([A-Za-z0-9_.]{3,30})', 'g') m)
  limit 20;
$$;

revoke all on function private.notify(uuid, uuid, text, uuid, uuid), private.mentioned_users(text) from public;

-- ---------------------------------------------------------------------------
-- Triggers on feed tables
-- ---------------------------------------------------------------------------
create function private.notify_post_like()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    perform private.notify((select author_id from public.posts where id = new.post_id), new.user_id, 'like', new.post_id);
  else
    delete from public.notifications where type = 'like' and actor_id = old.user_id and post_id = old.post_id;
  end if;
  return null;
end;
$$;

create trigger notify_post_like
  after insert or delete on public.post_likes
  for each row execute function private.notify_post_like();

create function private.notify_comment()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  post_author uuid := (select author_id from public.posts where id = new.post_id);
  parent_author uuid;
  mentioned uuid;
begin
  if tg_op = 'UPDATE' then
    -- Removed by the platform team: its notifications go too.
    if new.removed_at is not null and old.removed_at is null then
      delete from public.notifications where comment_id = new.id;
    end if;
    return null;
  end if;

  if new.parent_id is not null then
    parent_author := (select author_id from public.comments where id = new.parent_id);
    perform private.notify(parent_author, new.author_id, 'reply', new.post_id, new.id);
  end if;
  if post_author is distinct from parent_author then
    perform private.notify(post_author, new.author_id, 'comment', new.post_id, new.id);
  end if;
  for mentioned in select private.mentioned_users(new.body) loop
    if mentioned is distinct from post_author and mentioned is distinct from parent_author then
      perform private.notify(mentioned, new.author_id, 'mention', new.post_id, new.id);
    end if;
  end loop;
  return null;
end;
$$;

create trigger notify_comment
  after insert or update of removed_at on public.comments
  for each row execute function private.notify_comment();

create function private.notify_comment_like()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    perform private.notify(
      (select author_id from public.comments where id = new.comment_id), new.user_id, 'comment_like',
      (select post_id from public.comments where id = new.comment_id), new.comment_id);
  else
    delete from public.notifications where type = 'comment_like' and actor_id = old.user_id and comment_id = old.comment_id;
  end if;
  return null;
end;
$$;

create trigger notify_comment_like
  after insert or delete on public.comment_likes
  for each row execute function private.notify_comment_like();

-- Mentions in a new caption; a removed post takes its notifications with it.
create function private.notify_post()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  mentioned uuid;
begin
  if tg_op = 'UPDATE' then
    if new.removed_at is not null and old.removed_at is null then
      delete from public.notifications where post_id = new.id;
    end if;
    return null;
  end if;
  for mentioned in select private.mentioned_users(new.caption) loop
    perform private.notify(mentioned, new.author_id, 'mention', new.id);
  end loop;
  return null;
end;
$$;

create trigger notify_post
  after insert or update of removed_at on public.posts
  for each row execute function private.notify_post();

-- ---------------------------------------------------------------------------
-- Triggers on profile tables
-- ---------------------------------------------------------------------------
create function private.notify_follow()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'DELETE' then
    delete from public.notifications
    where type in ('follow', 'follow_accepted')
      and ((actor_id = old.follower_id and recipient_id = old.followee_id)
        or (actor_id = old.followee_id and recipient_id = old.follower_id));
    return null;
  end if;
  -- Accepting a request: the request still exists while the follow is inserted.
  if exists (select 1 from public.follow_requests r where r.requester_id = new.follower_id and r.target_id = new.followee_id) then
    perform private.notify(new.follower_id, new.followee_id, 'follow_accepted');
  end if;
  perform private.notify(new.followee_id, new.follower_id, 'follow');
  return null;
end;
$$;

create trigger notify_follow
  after insert or delete on public.follows
  for each row execute function private.notify_follow();

create function private.notify_follow_request()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    perform private.notify(new.target_id, new.requester_id, 'follow_request');
  else
    delete from public.notifications
    where type = 'follow_request' and actor_id = old.requester_id and recipient_id = old.target_id;
  end if;
  return null;
end;
$$;

create trigger notify_follow_request
  after insert or delete on public.follow_requests
  for each row execute function private.notify_follow_request();

-- ---------------------------------------------------------------------------
-- RPC: the signed-in user's notifications with what the screen needs
-- ---------------------------------------------------------------------------
create function public.my_notifications(before_id bigint default null, page_size int default 30)
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

revoke all on function public.my_notifications(bigint, int) from public;
grant execute on function public.my_notifications(bigint, int) to authenticated;

-- Live unread badge: clients subscribe to their own inserts (RLS applies to Realtime).
alter publication supabase_realtime add table public.notifications;
