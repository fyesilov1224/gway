-- 0070_remove_message_logs
-- The platform team never reads private messages or listens to calls (user decision, 2026-11-01; docs/ARCHITECTURE.md
-- §3f and §8c). Removes everything the message logs left behind on databases that ran the old 0062:
-- 1. The deleted message archive (with every archived text), its trigger and the admin read functions.
-- 2. Message reports keep no message text for the platform team: a direct message report stores no excerpt, and
--    the text already kept in reports and illegal-activity referrals is cleared.
-- 3. The records of past message log reads are deleted.
-- 4. The privacy notice drops the message review paragraph and says messages are not read.

-- 1 ------------------------------------------------------------------------------------------------------------------
drop trigger if exists messages_archive_deleted on public.messages;
drop function if exists private.archive_deleted_message();
drop function if exists private.purge_message_archive();
drop function if exists private.admin_message_log(uuid, timestamptz, text, int);
drop function if exists private.admin_message_conversations(uuid, uuid, text, int, int);
drop function if exists private.admin_log_conversations_of(uuid);
drop function if exists private.admin_log_profile(uuid);
drop table if exists public.message_deletion_archive;

-- 2 ------------------------------------------------------------------------------------------------------------------
-- As 0028, except that a message keeps its text as evidence only in a group chat, whose moderators read the chat anyway.
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
    select c.group_id, m.sender_id, case when c.group_id is not null then coalesce(nullif(m.body, ''), '[Fotoğraf]') end
    into target_group, subject, excerpt
    from public.messages m join public.conversations c on c.id = m.conversation_id
    where m.id = target_uuid and m.deleted_at is null and private.can_read_conversation(c.id);
  elsif kind = 'match_profile' then
    select null, t.user_id, concat_ws(' · ', p.display_name, nullif(t.job, ''), nullif(t.about, '')) into target_group, subject, excerpt
    from public.match_profiles t join public.profiles p on p.id = t.user_id
    where t.user_id = target_uuid and t.user_id <> (select auth.uid()) and private.can_view_match_profile(t.user_id);
  elsif kind = 'match_photo' then
    select null, f.user_id, f.path into target_group, subject, excerpt
    from public.match_photos f
    where f.id = target_uuid and f.user_id <> (select auth.uid()) and private.can_view_match_profile(f.user_id);
  end if;
  excerpt := left(btrim(coalesce(excerpt, '')), 500);
end;
$$;

-- Reports and referrals are immutable; their guards are paused only for this one-time clean-up.
alter table public.reports disable trigger reports_guard;
update public.reports set excerpt = '' where target_type = 'message' and group_id is null and excerpt <> '';
alter table public.reports enable trigger reports_guard;

alter table public.platform_referrals disable trigger platform_referrals_guard;
update public.platform_referrals r
set evidence = (
  select jsonb_agg(case when e->>'targetType' = 'message' then jsonb_set(e, '{excerpt}', '""'::jsonb) else e end order by i)
  from jsonb_array_elements(r.evidence) with ordinality as x(e, i)
)
where jsonb_typeof(r.evidence) = 'array'
  and exists (select 1 from jsonb_array_elements(r.evidence) e where e->>'targetType' = 'message' and coalesce(e->>'excerpt', '') <> '');
alter table public.platform_referrals enable trigger platform_referrals_guard;

-- 3 ------------------------------------------------------------------------------------------------------------------
alter table public.audit_log disable trigger audit_log_no_update_delete;
delete from public.audit_log where action in ('message.log_searched', 'message.log_viewed', 'message.context_viewed');
alter table public.audit_log enable trigger audit_log_no_update_delete;

-- 4 ------------------------------------------------------------------------------------------------------------------
-- Consented versions are frozen (0039), so a new version is published; users accept it at their next sign-in.
insert into public.legal_documents (kind, version, title, audience, body)
select kind, version + 1, title, audience, new_body
from (
  select d.*, case when strpos(d.stripped, 'Mesajların ve sesli görüşmelerin:') > 0 then d.stripped
    else d.stripped || E'\n\nMesajların ve sesli görüşmelerin: Mesajlarını yalnızca sohbetin katılımcıları okur; platform ekibi '
      'özel mesajlarını okuyamaz. Sesli görüşmeler kaydedilmez ve dinlenemez. Sildiğin mesajın metni ve fotoğrafı silinir, '
      'arşivde tutulmaz.' end as new_body
  from (
    select distinct on (kind) kind, version, title, audience, body,
      replace(body,
        E'\n\nMesajların: Birebir, grup ve masa sohbetlerindeki mesajların (silinen mesajların metni silinmeden itibaren 180 gün dahil) '
        'güvenliğin sağlanması, şikayetlerin ve hukuka aykırı faaliyetlerin incelenmesi ve yasal yükümlülüklerin yerine getirilmesi amacıyla, '
        'meşru menfaat ve hukuki yükümlülük sebeplerine dayanarak yalnızca yetkili platform yöneticisi tarafından incelenebilir. '
        'Her inceleme gerekçesiyle birlikte kayıt altına alınır. Silinen mesajlardaki fotoğraflar saklanmaz.', '') as stripped
    from public.legal_documents
    where kind = 'privacy_notice'
    order by kind, version desc
  ) d
) n
where new_body <> body;
