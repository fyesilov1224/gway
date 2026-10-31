-- 0062_message_logs
-- Message logs for the platform admin (user decision, 2026-10-31; docs/ARCHITECTURE.md §3f, Mesaj kayıtları).
-- 1. Deleted and removed messages keep their text for 180 days in an archive nobody reads through the API.
-- 2. Admin-only read functions: a user's conversations and a conversation's messages (with archived text).
-- 3. The privacy notice is published again with the new processing.

-- 1 ------------------------------------------------------------------------------------------------------------------
create table public.message_deletion_archive (
  message_id  uuid primary key references public.messages (id) on delete cascade,
  body        text not null,
  had_image   boolean not null,
  archived_at timestamptz not null default now(),
  purge_after timestamptz not null
);

comment on table public.message_deletion_archive is
  'owner: messaging. The text of a deleted or removed message, kept 180 days for the platform admin; written by a trigger.';

create index message_deletion_archive_purge_idx on public.message_deletion_archive (purge_after);

alter table public.message_deletion_archive enable row level security;
revoke all on table public.message_deletion_archive from anon, authenticated;

create function private.archive_deleted_message()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if old.body <> '' or old.image_path is not null then
    insert into public.message_deletion_archive (message_id, body, had_image, purge_after)
    values (old.id, old.body, old.image_path is not null, now() + interval '180 days')
    on conflict (message_id) do nothing;
  end if;
  return null;
end;
$$;

revoke all on function private.archive_deleted_message() from public;

-- After the guard: only a deletion the guard allowed is archived.
create trigger messages_archive_deleted
  after update of deleted_at on public.messages
  for each row
  when (old.deleted_at is null and new.deleted_at is not null)
  execute function private.archive_deleted_message();

create function private.purge_message_archive()
returns integer
language sql
security definer
set search_path = ''
as $$
  with gone as (delete from public.message_deletion_archive where purge_after <= now() returning 1)
  select count(*)::int from gone;
$$;

revoke all on function private.purge_message_archive() from public;
grant execute on function private.purge_message_archive() to service_role;

-- 2 ------------------------------------------------------------------------------------------------------------------
create function private.admin_log_profile(uid uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select case when p.id is null then null else
    jsonb_build_object('id', p.id, 'username', p.username, 'display_name', p.display_name, 'avatar_path', p.avatar_path) end
  from (select uid) x left join public.profiles p on p.id = x.uid;
$$;

revoke all on function private.admin_log_profile(uuid) from public;

-- The conversations a person is in: direct ones, chats of groups they are in or wrote to, tables they sat at.
create function private.admin_log_conversations_of(uid uuid)
returns setof uuid
language sql
stable
security definer
set search_path = ''
as $$
  select c.id from public.conversations c where c.kind = 'direct' and uid in (c.user_a, c.user_b)
  union
  select cm.conversation_id from public.conversation_members cm where cm.user_id = uid
  union
  select c.id from public.conversations c join public.group_members gm on gm.group_id = c.group_id and gm.user_id = uid
  union
  select distinct m.conversation_id from public.messages m where m.sender_id = uid;
$$;

revoke all on function private.admin_log_conversations_of(uuid) from public;

create function private.admin_message_conversations(target uuid, other uuid, kind_filter text, lim int, skip int)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  result jsonb;
begin
  if not private.is_platform_staff(array['admin']) then
    raise exception 'message_log_forbidden';
  end if;

  with ids as (
    select id from private.admin_log_conversations_of(target) id
    intersect
    select id from private.admin_log_conversations_of(coalesce(other, target)) id
  ),
  convs as (
    select c.*,
      (select count(*) from public.messages m where m.conversation_id = c.id) as total,
      (select count(*) from public.messages m where m.conversation_id = c.id and m.sender_id = target) as by_target,
      (select count(*) from public.messages m where m.conversation_id = c.id and m.deleted_at is not null) as deleted
    from public.conversations c
    join ids on ids.id = c.id
    where kind_filter is null or c.kind = kind_filter
  )
  select jsonb_build_object(
    'total', (select count(*) from convs),
    'items', coalesce((
      select jsonb_agg(item order by sort_at desc nulls last, id)
      from (
        select r.id, coalesce(r.last_message_at, r.created_at) as sort_at,
          jsonb_build_object(
            'id', r.id,
            'kind', r.kind,
            'created_at', r.created_at,
            'last_message_at', r.last_message_at,
            'message_count', r.total,
            'target_message_count', r.by_target,
            'deleted_count', r.deleted,
            'peer', case when r.kind = 'direct'
              then private.admin_log_profile(case when r.user_a = target then r.user_b else r.user_a end) end,
            'group', case when r.kind = 'group' then (
              select jsonb_build_object('id', g.id, 'handle', g.handle, 'name', g.name, 'logo_path', g.logo_path)
              from public.groups g where g.id = r.group_id) end,
            'table_evening', case when r.kind = 'table' then (select t.evening from public.tonight_tables t where t.id = r.table_id) end
          ) as item
        from convs r
        order by sort_at desc nulls last, r.id
        limit lim offset skip
      ) page
    ), '[]'::jsonb)
  ) into result;
  return result;
end;
$$;

revoke all on function private.admin_message_conversations(uuid, uuid, text, int, int) from public;
grant execute on function private.admin_message_conversations(uuid, uuid, text, int, int) to service_role;

-- Newest first (the caller reverses), lim + 1 rows to tell whether older ones exist.
create function private.admin_message_log(conv uuid, before_at timestamptz, search text, lim int)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  c public.conversations;
  needle text := nullif(lower(btrim(coalesce(search, ''))), '');
begin
  if not private.is_platform_staff(array['admin']) then
    raise exception 'message_log_forbidden';
  end if;
  select * into c from public.conversations where id = conv;
  if not found then
    return null;
  end if;

  return jsonb_build_object(
    'conversation', jsonb_build_object(
      'id', c.id,
      'kind', c.kind,
      'created_at', c.created_at,
      'last_message_at', c.last_message_at,
      'message_count', (select count(*) from public.messages m where m.conversation_id = c.id),
      'group', case when c.kind = 'group' then (
        select jsonb_build_object('id', g.id, 'handle', g.handle, 'name', g.name, 'logo_path', g.logo_path)
        from public.groups g where g.id = c.group_id) end,
      'table_evening', case when c.kind = 'table' then (select t.evening from public.tonight_tables t where t.id = c.table_id) end,
      'participants', coalesce((
        select jsonb_agg(private.admin_log_profile(u) order by u)
        from (
          select c.user_a as u where c.kind = 'direct'
          union select c.user_b where c.kind = 'direct'
          union select cm.user_id from public.conversation_members cm where c.kind = 'table' and cm.conversation_id = c.id
          union select gm.user_id from public.group_members gm where c.kind = 'group' and gm.group_id = c.group_id
        ) people
        where u is not null
      ), '[]'::jsonb)
    ),
    'messages', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', m.id,
        'sender', private.admin_log_profile(m.sender_id),
        'body', case when m.deleted_at is null then m.body else coalesce(a.body, '') end,
        'image_path', m.image_path,
        'had_image', coalesce(a.had_image, false),
        'archived', a.message_id is not null,
        'created_at', m.created_at,
        'deleted_at', m.deleted_at,
        'removed_reason', m.removed_reason,
        'purge_after', a.purge_after
      ) order by m.created_at desc, m.id)
      from (
        select m.* from public.messages m
        left join public.message_deletion_archive a on a.message_id = m.id
        where m.conversation_id = c.id
          and (before_at is null or m.created_at < before_at)
          and (needle is null or strpos(lower(case when m.deleted_at is null then m.body else coalesce(a.body, '') end), needle) > 0)
        order by m.created_at desc, m.id
        limit lim + 1
      ) m
      left join public.message_deletion_archive a on a.message_id = m.id
    ), '[]'::jsonb)
  );
end;
$$;

revoke all on function private.admin_message_log(uuid, timestamptz, text, int) from public;
grant execute on function private.admin_message_log(uuid, timestamptz, text, int) to service_role;

-- 3 ------------------------------------------------------------------------------------------------------------------
insert into public.legal_documents (kind, version, title, audience, body)
select d.kind, d.version + 1, d.title, d.audience,
  d.body || E'\n\nMesajların: Birebir, grup ve masa sohbetlerindeki mesajların (silinen mesajların metni silinmeden itibaren 180 gün dahil) '
    'güvenliğin sağlanması, şikayetlerin ve hukuka aykırı faaliyetlerin incelenmesi ve yasal yükümlülüklerin yerine getirilmesi amacıyla, '
    'meşru menfaat ve hukuki yükümlülük sebeplerine dayanarak yalnızca yetkili platform yöneticisi tarafından incelenebilir. '
    'Her inceleme gerekçesiyle birlikte kayıt altına alınır. Silinen mesajlardaki fotoğraflar saklanmaz.'
from (
  select distinct on (kind) kind, version, title, audience, body
  from public.legal_documents
  where kind = 'privacy_notice'
  order by kind, version desc
) d;
