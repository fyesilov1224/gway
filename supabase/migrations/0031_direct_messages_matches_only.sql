-- Direct messages only between matches and teammates (docs/ARCHITECTURE.md §3f, user decision 2026-10-26).
-- Following no longer opens a chat, so the paid match chat cannot be bypassed; ending a match also ends the follows.

-- ---------------------------------------------------------------------------
-- Messaging (messaging owns these functions)
-- ---------------------------------------------------------------------------

-- May the signed-in user be shown a way to message other: a match, a teammate, or an earlier conversation to read.
create function private.can_message(other uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select other is not null and other <> (select auth.uid())
    and not private.is_blocked_between((select auth.uid()), other)
    and private.is_account_active(other)
    and (private.are_teammates((select auth.uid()), other)
         or private.are_matched((select auth.uid()), other)
         or exists (select 1 from public.conversations c
                    where c.user_a = least((select auth.uid()), other) and c.user_b = greatest((select auth.uid()), other)));
$$;

create function public.can_message(other uuid)
returns boolean
language sql
stable
security invoker
set search_path = ''
as $$
  select private.can_message(other);
$$;

revoke all on function private.can_message(uuid), public.can_message(uuid) from public;
grant execute on function private.can_message(uuid), public.can_message(uuid) to authenticated;

-- Teammates write; matches write with the chat package; everyone else only reads what is already there.
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
  if not private.are_teammates(uid, peer) then
    if private.match_ended_between(uid, peer) then
      return 'match_ended';
    end if;
    if not private.are_matched(uid, peer) then
      return 'message_not_allowed';
    end if;
    if not private.has_matching_feature(uid, 'chat') then
      return 'match_chat_locked';
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

-- A new conversation only between matches and teammates; an existing one always opens to be read.
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
  matched boolean;
  teammates boolean;
begin
  if actor is null or other is null or actor = other or not private.is_account_active(actor) then
    perform private.raise_message_rule('message_forbidden');
  end if;
  if not exists (select 1 from public.profiles p where p.id = other and private.is_account_active(p.id)) or private.has_blocked(other, actor) then
    perform private.raise_message_rule('message_not_found');
  end if;
  if private.has_blocked(actor, other) then
    perform private.raise_message_rule('blocked');
  end if;
  matched := private.are_matched(actor, other);
  teammates := private.are_teammates(actor, other);

  select c.id into conv from public.conversations c where c.user_a = least(actor, other) and c.user_b = greatest(actor, other);
  if conv is not null then
    if matched or teammates then
      update public.conversation_members set state = 'active' where conversation_id = conv and state <> 'active';
    end if;
    select m.state into other_state from public.conversation_members m where m.conversation_id = conv and m.user_id = other;
    return jsonb_build_object('id', conv, 'state', other_state);
  end if;

  if not teammates and private.match_ended_between(actor, other) then
    perform private.raise_message_rule('match_ended');
  end if;
  if not (matched or teammates) then
    perform private.raise_message_rule('message_not_allowed');
  end if;

  insert into public.conversations (kind, user_a, user_b, created_by)
  values ('direct', least(actor, other), greatest(actor, other), actor)
  returning id into conv;
  insert into public.conversation_members (conversation_id, user_id, state) values (conv, actor, 'active'), (conv, other, 'active');
  return jsonb_build_object('id', conv, 'state', 'active');
end;
$$;

-- ---------------------------------------------------------------------------
-- Social graph (owns follows): an ended match ends the follows between the two.
-- ---------------------------------------------------------------------------
create function private.unfollow_on_match_end()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  -- Nested in this trigger, the follow guards allow the clean-up.
  delete from public.follows
  where (follower_id, followee_id) in ((new.user_a, new.user_b), (new.user_b, new.user_a));
  delete from public.follow_requests
  where (requester_id, target_id) in ((new.user_a, new.user_b), (new.user_b, new.user_a));
  return null;
end;
$$;

revoke all on function private.unfollow_on_match_end() from public;

create trigger unfollow_on_match_end
  after update of ended_at on public.matches
  for each row when (old.ended_at is null and new.ended_at is not null)
  execute function private.unfollow_on_match_end();
