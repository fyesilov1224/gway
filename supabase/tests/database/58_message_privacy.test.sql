begin;
create extension if not exists pgtap with schema extensions;

select plan(9);

-- Nobody on the platform team reads private messages (0070; docs/ARCHITECTURE.md §3f).
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
select ok(pg_temp.notice() like '%platform ekibi özel mesajlarını okuyamaz%', 'the privacy notice says messages are not read');
select ok(pg_temp.notice() like '%Sesli görüşmeler kaydedilmez%', 'and calls are not recorded');
select ok(pg_temp.notice() not like '%platform yöneticisi tarafından incelenebilir%', 'the message review paragraph is gone');

select finish();
rollback;
