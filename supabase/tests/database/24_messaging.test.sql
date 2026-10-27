begin;
create extension if not exists pgtap with schema extensions;

select plan(38);

-- d1 owner of the group, d2 member, d3 member (muted later), d4 stranger, d5 private account, d6 outsider.
insert into auth.users (id, email, aud, role)
select ('00000000-0000-0000-0000-0000000dd10' || i)::uuid, 'd' || i || '@test.local', 'authenticated', 'authenticated'
from generate_series(1, 6) i;
insert into public.profiles (id, username, display_name, is_private)
select ('00000000-0000-0000-0000-0000000dd10' || i)::uuid, 'msg_user' || i, 'Mesaj ' || i, i = 5
from generate_series(1, 6) i;

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;
create function pg_temp.u(i int) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000000dd10' || i)::uuid $$;
create function pg_temp.grp() returns uuid language sql as $$ select '00000000-0000-0000-0000-0000000dd201'::uuid $$;
create function pg_temp.chat() returns uuid language sql as $$ select id from public.conversations where group_id = pg_temp.grp() $$;
create function pg_temp.send(conv uuid, body text) returns uuid language sql as $$
  insert into public.messages (conversation_id, sender_id, body) values (conv, (select auth.uid()), body) returning id;
$$;
create function pg_temp.direct(a int, b int) returns uuid language sql as $$
  select id from public.conversations where user_a = least(pg_temp.u(a), pg_temp.u(b)) and user_b = greatest(pg_temp.u(a), pg_temp.u(b));
$$;
create function pg_temp.state(conv uuid, i int) returns text language sql as $$
  select state from public.conversation_members where conversation_id = conv and user_id = pg_temp.u(i);
$$;

select pg_temp.act('00000000-0000-0000-0000-0000000dd101');
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id)
values (pg_temp.grp(), 'mesaj.grubu', 'Mesaj Grubu', 'hiking', 'open', pg_temp.u(1));
insert into public.group_members (group_id, user_id) values (pg_temp.grp(), pg_temp.u(1));
do $$ begin
  for i in 2..3 loop
    perform pg_temp.act(pg_temp.u(i)::text);
    insert into public.group_members (group_id, user_id) values (pg_temp.grp(), pg_temp.u(i));
  end loop;
end $$;

-- Group chat --------------------------------------------------------------------------------------------
select ok(pg_temp.chat() is not null, 'a new group gets its chat');
select pg_temp.act('00000000-0000-0000-0000-0000000dd102');
select lives_ok($$ select pg_temp.send(pg_temp.chat(), ' Cumartesi kim geliyor? ') $$, 'members write in the group chat');
select is((select body from public.messages where conversation_id = pg_temp.chat()), 'Cumartesi kim geliyor?', 'the text is trimmed');
select throws_ok($$ select pg_temp.send(pg_temp.chat(), '   ') $$, 'P0001', 'message_empty', 'an empty message is refused');
select pg_temp.act('00000000-0000-0000-0000-0000000dd106');
select throws_ok($$ select pg_temp.send(pg_temp.chat(), 'Merhaba') $$, 'P0001', 'message_forbidden', 'outsiders do not write');

set local role authenticated;
select is((select count(*)::int from public.messages where conversation_id = pg_temp.chat()), 0, 'nor read');
select pg_temp.act('00000000-0000-0000-0000-0000000dd103');
select is((select count(*)::int from public.messages where conversation_id = pg_temp.chat()), 1, 'members read the chat');
select throws_ok($$ insert into public.messages (conversation_id, sender_id, body) values (pg_temp.chat(), pg_temp.u(3), 'x') $$,
  '42501', null, 'clients do not write messages directly');
select is(
  (select (c->>'unread')::int from jsonb_array_elements(public.my_conversations()) c where c->>'id' = pg_temp.chat()::text), 1,
  'the new message is unread'
);
select public.mark_conversation_read(pg_temp.chat());
select is(
  (select (c->>'unread')::int from jsonb_array_elements(public.my_conversations()) c where c->>'id' = pg_temp.chat()::text), 0,
  'and read after opening the chat'
);
reset role;

-- Muted members and the admins-only mode.
-- Setup only: sanctions are tested in 16_moderation.
alter table public.moderation_cases disable trigger user;
alter table public.sanctions disable trigger user;
insert into public.moderation_cases (id, group_id, subject_id, sanction, duration_days, reason, threshold, voting_ends_at)
values ('00000000-0000-0000-0000-0000000dd301', pg_temp.grp(), pg_temp.u(3), 'mute', 1, 'Sohbette hakaret etti', 'majority', now() + interval '1 day');
insert into public.sanctions (group_id, user_id, case_id, type, interim, ends_at)
values (pg_temp.grp(), pg_temp.u(3), '00000000-0000-0000-0000-0000000dd301', 'mute', true, now() + interval '1 day');
alter table public.sanctions enable trigger user;
alter table public.moderation_cases enable trigger user;
select pg_temp.act('00000000-0000-0000-0000-0000000dd103');
select throws_ok($$ select pg_temp.send(pg_temp.chat(), 'Selam') $$, 'P0001', 'message_muted', 'a muted member does not write');
select pg_temp.act('00000000-0000-0000-0000-0000000dd102');
select throws_ok($$ update public.conversations set admins_only = true where id = pg_temp.chat() $$, 'P0001', 'message_forbidden',
  'members do not change the chat mode');
select pg_temp.act('00000000-0000-0000-0000-0000000dd101');
update public.conversations set admins_only = true where id = pg_temp.chat();
select lives_ok($$ select pg_temp.send(pg_temp.chat(), 'Duyuru: rota değişti') $$, 'in admins-only mode the owner writes');
select pg_temp.act('00000000-0000-0000-0000-0000000dd102');
select throws_ok($$ select pg_temp.send(pg_temp.chat(), 'Tamam') $$, 'P0001', 'message_admins_only', 'members only read');

-- Deleting.
select pg_temp.act('00000000-0000-0000-0000-0000000dd101');
select throws_ok(
  $$ update public.messages set deleted_at = now() where conversation_id = pg_temp.chat() and sender_id = pg_temp.u(2) $$,
  'P0001', 'message_forbidden', 'nobody deletes someone else''s message'
);
select lives_ok(
  $$ update public.messages set deleted_at = now(), removed_reason = 'Kurallara aykırı' where conversation_id = pg_temp.chat() and sender_id = pg_temp.u(2) $$,
  'a group reviewer removes it'
);
select is((select body from public.messages where conversation_id = pg_temp.chat() and sender_id = pg_temp.u(2)), '', 'the content is cleared');

-- Direct messages: only matches (28_matching_packages) and teammates (§3f) ----------------------------------
insert into public.follows (follower_id, followee_id) values (pg_temp.u(1), pg_temp.u(2));
select pg_temp.act('00000000-0000-0000-0000-0000000dd102');
insert into public.follows (follower_id, followee_id) values (pg_temp.u(2), pg_temp.u(1));
select throws_ok($$ select private.open_direct_conversation(pg_temp.u(1)) $$, 'P0001', 'message_not_allowed',
  'following each other no longer opens a chat');
select throws_ok($$ select private.open_direct_conversation(pg_temp.u(4)) $$, 'P0001', 'message_not_allowed',
  'and a stranger gets no request either');
set local role authenticated;
select is(public.can_message(pg_temp.u(1)), false, 'so the profile shows no message button');
reset role;

-- d2 and d4 become teammates (the accepting flow is tested in 22_teammates).
alter table public.teammates disable trigger teammates_guard;
insert into public.teammates (user_a, user_b) values (pg_temp.u(2), pg_temp.u(4));
alter table public.teammates enable trigger teammates_guard;
select pg_temp.act('00000000-0000-0000-0000-0000000dd102');
select is(private.open_direct_conversation(pg_temp.u(4))->>'state', 'active', 'teammates write directly');
select is(private.open_direct_conversation(pg_temp.u(4))->>'state', 'active', 'and the same conversation again');
set local role authenticated;
select is(public.can_message(pg_temp.u(4)), true, 'the profile offers the chat');
reset role;
select pg_temp.act('00000000-0000-0000-0000-0000000dd102');
select throws_ok($$ select pg_temp.send(pg_temp.direct(2, 4), 'Merhaba') $$, 'P0001', 'teammate_chat_locked',
  'writing to a teammate needs the Ekip Arkadaşı package');
alter table public.user_subscriptions disable trigger user_subscriptions_guard;
insert into public.user_subscriptions (user_id, plan_slug, grant_reason, starts_at, ends_at)
select pg_temp.u(i), 'matching_teammates', 'test', now() - interval '1 minute', now() + interval '1 day' from unnest(array[2, 4]) i;
alter table public.user_subscriptions enable trigger user_subscriptions_guard;
select lives_ok($$ select pg_temp.send(pg_temp.direct(2, 4), 'Merhaba, rotayı paylaşır mısın?') $$, 'one teammate writes');
select pg_temp.act('00000000-0000-0000-0000-0000000dd104');
select lives_ok($$ select pg_temp.send(pg_temp.direct(2, 4), 'Tabii, paylaşırım') $$, 'and the other answers');
set local role authenticated;
select is(
  (select c->>'my_state' from jsonb_array_elements(public.my_conversations()) c where c->>'id' = pg_temp.direct(2, 4)::text), 'active',
  'the chat is in both lists'
);
select public.mark_conversation_read(pg_temp.direct(2, 4));
select pg_temp.act('00000000-0000-0000-0000-0000000dd102');
select isnt(public.conversation_detail(pg_temp.direct(2, 4))->'peer'->>'read_at', null, 'the reader''s receipt shows');
select pg_temp.act('00000000-0000-0000-0000-0000000dd106');
select is(public.conversation_detail(pg_temp.direct(2, 4)), null, 'nobody else sees the conversation');
reset role;

-- A chat opened under the old rules (mutual follows) stays readable but closed.
insert into public.conversations (kind, user_a, user_b, created_by)
values ('direct', least(pg_temp.u(1), pg_temp.u(3)), greatest(pg_temp.u(1), pg_temp.u(3)), pg_temp.u(1));
insert into public.conversation_members (conversation_id, user_id, state)
values (pg_temp.direct(1, 3), pg_temp.u(1), 'active'), (pg_temp.direct(1, 3), pg_temp.u(3), 'active');
select pg_temp.act('00000000-0000-0000-0000-0000000dd101');
select throws_ok($$ select pg_temp.send(pg_temp.direct(1, 3), 'Selam') $$, 'P0001', 'message_not_allowed', 'an old chat takes no new messages');
set local role authenticated;
select isnt(public.conversation_detail(pg_temp.direct(1, 3)), null, 'but it can still be read');
reset role;

-- Blocking and limits.
select pg_temp.act('00000000-0000-0000-0000-0000000dd103');
insert into public.blocks (blocker_id, blocked_id) values (pg_temp.u(3), pg_temp.u(1));
select pg_temp.act('00000000-0000-0000-0000-0000000dd101');
select throws_ok($$ select pg_temp.send(pg_temp.direct(1, 3), 'Selam') $$, 'P0001', 'blocked', 'no messages across a block');
reset role;
select pg_temp.act('00000000-0000-0000-0000-0000000dd102');
select throws_ok(
  $$ select pg_temp.send(pg_temp.direct(2, 4), 'mesaj ' || i) from generate_series(1, 31) i $$,
  'P0001', 'message_rate_limited', 'at most 30 messages a minute'
);

-- Reports --------------------------------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000dd102');
insert into public.messages (conversation_id, sender_id, body) values (pg_temp.direct(2, 4), pg_temp.u(2), 'Kaba bir mesaj');
select pg_temp.act('00000000-0000-0000-0000-0000000dd104');
insert into public.reports (reporter_id, target_type, target_id, reason)
select pg_temp.u(4), 'message', id::text, 'harassment' from public.messages where body = 'Kaba bir mesaj';
select is(
  (select row(group_id, subject_id, excerpt)::text from public.reports where target_type = 'message' and reporter_id = pg_temp.u(4)),
  row(null::uuid, pg_temp.u(2), 'Kaba bir mesaj')::text, 'a direct message report goes to the platform with the text as evidence'
);
select pg_temp.act('00000000-0000-0000-0000-0000000dd106');
select throws_ok(
  $$ insert into public.reports (reporter_id, target_type, target_id, reason)
     select pg_temp.u(6), 'message', id::text, 'spam' from public.messages where body = 'Duyuru: rota değişti' $$,
  'P0001', 'report_target_invalid', 'nobody reports a message they cannot read'
);
select pg_temp.act('00000000-0000-0000-0000-0000000dd102');
insert into public.reports (reporter_id, target_type, target_id, reason)
select pg_temp.u(2), 'message', id::text, 'spam' from public.messages where body = 'Duyuru: rota değişti';
select is((select group_id from public.reports where reporter_id = pg_temp.u(2) and target_type = 'message'), pg_temp.grp(),
  'a group chat report goes to the group');

-- Photos -----------------------------------------------------------------------------------------------------
set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000dd103');
select lives_ok(
  $$ insert into storage.objects (bucket_id, name, owner_id) values ('message-images', pg_temp.chat()::text || '/a.jpg', pg_temp.u(3)::text) $$,
  'members upload into their chat''s folder'
);
select pg_temp.act('00000000-0000-0000-0000-0000000dd106');
select throws_ok(
  $$ insert into storage.objects (bucket_id, name, owner_id) values ('message-images', pg_temp.chat()::text || '/b.jpg', pg_temp.u(6)::text) $$,
  '42501', null, 'outsiders do not'
);

select * from finish();
rollback;
