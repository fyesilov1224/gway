begin;
create extension if not exists pgtap with schema extensions;

select plan(12);

-- Nobody on the platform team reads private messages (0069; docs/ARCHITECTURE.md §3f).
select hasnt_table('public', 'message_deletion_archive', 'deleted message texts are not archived');
select hasnt_trigger('public', 'messages', 'messages_archive_deleted', 'deleting a message archives nothing');
select hasnt_function('private', 'admin_message_log', 'there is no way to read a conversation as staff');
select hasnt_function('private', 'admin_message_conversations', 'nor to list a person''s conversations');
select hasnt_function('private', 'purge_message_archive', 'and no archive to purge');
select is(
  (select count(*)::int from public.audit_log where action in ('message.log_searched', 'message.log_viewed', 'message.context_viewed')),
  0, 'no message log reads are on record'
);

create function pg_temp.notice() returns text language sql as $$
  select body from public.legal_documents where kind = 'privacy_notice' order by version desc limit 1
$$;
select ok(pg_temp.notice() like '%ekip, şikayet edilen mesajlar dahil özel mesajlarının içeriğini incelemez%',
  'the privacy notice says the team does not review messages (0070)');
select ok(pg_temp.notice() like '%Google Firebase%' and pg_temp.notice() like '%grubun moderatörlerine%',
  'and names the push provider and group moderators');
select ok(pg_temp.notice() like '%Sesli görüşmeler ve canlı yayınlar kaydedilmez%', 'calls and broadcasts are not recorded');
select ok(pg_temp.notice() like '%yedekleme süresi sonunda%' and pg_temp.notice() like '%yasal bir zorunluluk%',
  'backups and legal orders are disclosed');
select ok(pg_temp.notice() not like '%okuyamaz%', 'the absolute "cannot read" claim is gone');
select ok(pg_temp.notice() not like '%platform yöneticisi tarafından incelenebilir%', 'the message review paragraph is gone');

select finish();
rollback;
