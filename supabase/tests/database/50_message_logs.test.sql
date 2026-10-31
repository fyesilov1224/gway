begin;
create extension if not exists pgtap with schema extensions;

select plan(24);

alter table public.group_members disable trigger group_members_welcome_trial;

-- l1 group owner, l2 member, l3 platform admin, l4 platform moderator, l5 stranger.
insert into auth.users (id, email, aud, role)
select ('00000000-0000-0000-0000-0000000ee10' || i)::uuid, 'l' || i || '@test.local', 'authenticated', 'authenticated'
from generate_series(1, 5) i;
insert into public.profiles (id, username, display_name)
select ('00000000-0000-0000-0000-0000000ee10' || i)::uuid, 'log_user' || i, 'Kayıt ' || i
from generate_series(1, 5) i;
insert into public.platform_staff (user_id, role) values
  ('00000000-0000-0000-0000-0000000ee103', 'admin'),
  ('00000000-0000-0000-0000-0000000ee104', 'moderator');

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;
create function pg_temp.u(i int) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000000ee10' || i)::uuid $$;
create function pg_temp.grp() returns uuid language sql as $$ select '00000000-0000-0000-0000-0000000ee201'::uuid $$;
create function pg_temp.chat() returns uuid language sql as $$ select id from public.conversations where group_id = pg_temp.grp() $$;
create function pg_temp.direct() returns uuid language sql as $$
  select id from public.conversations where user_a = least(pg_temp.u(1), pg_temp.u(5)) and user_b = greatest(pg_temp.u(1), pg_temp.u(5));
$$;
create function pg_temp.send(conv uuid, body text) returns uuid language sql as $$
  insert into public.messages (conversation_id, sender_id, body) values (conv, (select auth.uid()), body) returning id;
$$;

select pg_temp.act('00000000-0000-0000-0000-0000000ee101');
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id)
values (pg_temp.grp(), 'kayit.grubu', 'Kayıt Grubu', 'hiking', 'open', pg_temp.u(1));
insert into public.group_members (group_id, user_id) values (pg_temp.grp(), pg_temp.u(1));
select pg_temp.act('00000000-0000-0000-0000-0000000ee102');
insert into public.group_members (group_id, user_id) values (pg_temp.grp(), pg_temp.u(2));

select pg_temp.act('00000000-0000-0000-0000-0000000ee101');
select pg_temp.send(pg_temp.chat(), 'Cumartesi buluşuyoruz');
select pg_temp.act('00000000-0000-0000-0000-0000000ee102');
create temp table sent as select pg_temp.send(pg_temp.chat(), 'Gizli plan burada') as id;
select pg_temp.send(pg_temp.chat(), 'Tamam');

-- A direct chat between l1 and l5 (setup only: direct rules are tested in 24_messaging).
reset role;
insert into public.conversations (kind, user_a, user_b, created_by)
values ('direct', least(pg_temp.u(1), pg_temp.u(5)), greatest(pg_temp.u(1), pg_temp.u(5)), pg_temp.u(1));
alter table public.messages disable trigger messages_guard;
insert into public.messages (conversation_id, sender_id, body) values (pg_temp.direct(), pg_temp.u(5), 'Özel selam');
alter table public.messages enable trigger messages_guard;

-- The archive -----------------------------------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000ee102');
update public.messages set deleted_at = now() where id = (select id from sent);
select is((select body from public.messages where id = (select id from sent)), '', 'the deleted message is cleared for everyone');
select is((select body from public.message_deletion_archive where message_id = (select id from sent)), 'Gizli plan burada',
  'its text is archived');
select ok((select purge_after between now() + interval '179 days' and now() + interval '181 days'
           from public.message_deletion_archive where message_id = (select id from sent)), 'for 180 days');

select pg_temp.act('00000000-0000-0000-0000-0000000ee101');
select throws_ok($$ update public.messages set deleted_at = now() where sender_id = pg_temp.u(2) and body = 'Tamam' $$,
  'P0001', 'message_forbidden', 'a refused deletion archives nothing');
select is((select count(*)::int from public.message_deletion_archive a join public.messages m on m.id = a.message_id
           where m.conversation_id = pg_temp.chat()), 1, 'only the allowed deletion is archived');

set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000ee103');
select throws_ok($$ select * from public.message_deletion_archive $$, '42501', null, 'clients do not read the archive, not even admins');
select throws_ok($$ select private.admin_message_log(pg_temp.chat(), null, null, 50) $$, '42501', null,
  'clients do not call the log functions');
reset role;
select ok((select relrowsecurity from pg_class where oid = 'public.message_deletion_archive'::regclass), 'the archive has RLS');
select is_empty($$ select 1 from pg_policies where tablename = 'message_deletion_archive' $$, 'and no policies');

-- Only the platform admin ------------------------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000ee104');
select throws_ok($$ select private.admin_message_conversations(pg_temp.u(1), null, null, 20, 0) $$, 'P0001', 'message_log_forbidden',
  'moderators do not search the logs');
select throws_ok($$ select private.admin_message_log(pg_temp.chat(), null, null, 50) $$, 'P0001', 'message_log_forbidden',
  'nor open them');
select pg_temp.act('00000000-0000-0000-0000-0000000ee102');
select throws_ok($$ select private.admin_message_log(pg_temp.chat(), null, null, 50) $$, 'P0001', 'message_log_forbidden',
  'nor do members');

select pg_temp.act('00000000-0000-0000-0000-0000000ee103');
select is((private.admin_message_conversations(pg_temp.u(1), null, null, 20, 0)->>'total')::int, 2,
  'a person''s conversations: the group chat and the direct one');
select is((private.admin_message_conversations(pg_temp.u(1), pg_temp.u(5), null, 20, 0)->>'total')::int, 1,
  'with a second person only the shared ones');
select is(private.admin_message_conversations(pg_temp.u(1), pg_temp.u(5), null, 20, 0)->'items'->0->'peer'->>'username', 'log_user5',
  'direct rows name the other person');
select is((private.admin_message_conversations(pg_temp.u(1), null, 'group', 20, 0)->'items'->0->>'deleted_count')::int, 1,
  'the kind filter and the deleted count');

select is(jsonb_array_length(private.admin_message_log(pg_temp.chat(), null, null, 50)->'messages'), 3, 'every message of the chat');
select is(
  (select m->>'body' from jsonb_array_elements(private.admin_message_log(pg_temp.chat(), null, null, 50)->'messages') m
   where (m->>'archived')::boolean),
  'Gizli plan burada', 'deleted messages show their archived text');
select is(jsonb_array_length(private.admin_message_log(pg_temp.chat(), null, 'gizli', 50)->'messages'), 1,
  'text search covers archived text, case-insensitively');
select is(jsonb_array_length(private.admin_message_log(pg_temp.chat(), null, null, 50)->'conversation'->'participants'), 2,
  'the header lists the participants');

-- Purge and account deletion ---------------------------------------------------------------------------------------
reset role;
update public.message_deletion_archive set purge_after = now() - interval '1 minute';
select private.purge_message_archive();
select is_empty($$ select 1 from public.message_deletion_archive a join public.messages m on m.id = a.message_id
                   where m.conversation_id = pg_temp.chat() $$, 'expired archive rows are purged');

select pg_temp.act('00000000-0000-0000-0000-0000000ee102');
update public.messages set deleted_at = now() where sender_id = pg_temp.u(2) and body = 'Tamam';
select is((select count(*)::int from public.message_deletion_archive a join public.messages m on m.id = a.message_id
           where m.sender_id = pg_temp.u(2)), 1, 'a new deletion is archived');
reset role;
create temp table archived as select a.message_id from public.message_deletion_archive a join public.messages m on m.id = a.message_id
  where m.sender_id = pg_temp.u(2);
delete from auth.users where id = pg_temp.u(2);
select is_empty($$ select 1 from public.message_deletion_archive where message_id in (select message_id from archived) $$,
  'deleting the account deletes its archived texts');
select ok((select body from public.legal_documents where kind = 'privacy_notice' order by version desc limit 1)
          like '%yalnızca yetkili platform yöneticisi%', 'the privacy notice names the message review');

select finish();
rollback;
