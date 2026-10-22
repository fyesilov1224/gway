-- 0025_conversation_manage
-- Phase 15: the chat card says whether the caller may switch the group chat to admins-only.

-- As in 0024, with can_manage (group.edit holders set the admins-only mode).
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
