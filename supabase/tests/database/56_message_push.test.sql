begin;
create extension if not exists pgtap with schema extensions;

select plan(17);

alter table public.group_members disable trigger group_members_welcome_trial;

-- e1 owns the group, e2 and e3 are members; e4 sends e1 a message request; e5 has group message notices off.
insert into auth.users (id, email, aud, role)
select ('00000000-0000-0000-0000-0000000ee10' || i)::uuid, 'e' || i || '@test.local', 'authenticated', 'authenticated'
from generate_series(1, 5) i;
insert into public.profiles (id, username, display_name)
select ('00000000-0000-0000-0000-0000000ee10' || i)::uuid, 'push_msg' || i, 'Mesaj ' || i
from generate_series(1, 5) i;

create function pg_temp.act(uid uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;
create function pg_temp.u(i int) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000000ee10' || i)::uuid $$;
create function pg_temp.grp() returns uuid language sql as $$ select '00000000-0000-0000-0000-0000000ee201'::uuid $$;
create function pg_temp.chat() returns uuid language sql as $$ select id from public.conversations where group_id = pg_temp.grp() $$;
create function pg_temp.send(conv uuid, body text) returns uuid language sql as $$
  insert into public.messages (conversation_id, sender_id, body) values (conv, (select auth.uid()), body) returning id;
$$;
-- Who may message whom (matches, teammates) is tested in 24_messaging; here the guard is off for direct chats.
create function pg_temp.backend_send(conv uuid, sender int, body text) returns void language sql as $$
  insert into public.messages (conversation_id, sender_id, body) values (conv, pg_temp.u(sender), body);
$$;
create function pg_temp.direct(a int, b int) returns uuid language sql as $$
  select id from public.conversations where user_a = least(pg_temp.u(a), pg_temp.u(b)) and user_b = greatest(pg_temp.u(a), pg_temp.u(b));
$$;
create function pg_temp.waiting(i int) returns int language sql as $$
  select count(*)::int from public.notifications where recipient_id = pg_temp.u(i) and type = 'message' and pushed_at is null;
$$;

select pg_temp.act(pg_temp.u(1));
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id)
values (pg_temp.grp(), 'mesaj.zili', 'Mesaj Zili', 'hiking', 'open', pg_temp.u(1));
insert into public.group_members (group_id, user_id) values (pg_temp.grp(), pg_temp.u(1));
do $$ declare i int; begin
  foreach i in array array[2, 3, 5] loop
    perform pg_temp.act(pg_temp.u(i));
    insert into public.group_members (group_id, user_id) values (pg_temp.grp(), pg_temp.u(i));
  end loop;
end $$;
insert into public.notification_preferences (user_id, group_messages) values (pg_temp.u(5), false);

-- Group chat ---------------------------------------------------------------------------------------------
select pg_temp.act(pg_temp.u(2));
select pg_temp.send(pg_temp.chat(), 'Cumartesi kim geliyor?');
select is(pg_temp.waiting(1) + pg_temp.waiting(3), 2, 'a group message rings every member');
select is(pg_temp.waiting(2), 0, 'but not the sender');
select is(pg_temp.waiting(5), 0, 'nor someone who turned group message notices off');

-- A burst stays one notification, carrying the newest message.
select pg_temp.send(pg_temp.chat(), 'Ben varım');
select is(pg_temp.waiting(1), 1, 'a burst from one chat is one notification');
select is(
  (select m.body from public.notifications n join public.messages m on m.id = n.message_id
   where n.recipient_id = pg_temp.u(1) and n.type = 'message' and n.pushed_at is null),
  'Ben varım', 'and it shows the newest message'
);

-- Once pushed, the next message rings again.
update public.notifications set pushed_at = now() where recipient_id = pg_temp.u(1) and type = 'message';
select pg_temp.act(pg_temp.u(3));
select pg_temp.send(pg_temp.chat(), 'Ben de');
select is(pg_temp.waiting(1), 1, 'after the push a new message rings again');

-- The app never lists them ----------------------------------------------------------------------------------
set local role authenticated;
select pg_temp.act(pg_temp.u(1));
select is((select count(*)::int from public.notifications where type = 'message'), 0, 'message notices are not in the notification list');
select is((select count(*)::int from public.notifications where read_at is null), 0, 'nor in the unread count');
select is(
  (select count(*)::int from public.my_notifications()), 0,
  'nor in my_notifications'
);
reset role;

-- Direct chat ---------------------------------------------------------------------------------------------
alter table public.messages disable trigger messages_guard;
insert into public.conversations (kind, user_a, user_b, created_by)
values ('direct', least(pg_temp.u(1), pg_temp.u(4)), greatest(pg_temp.u(1), pg_temp.u(4)), pg_temp.u(4));
insert into public.conversation_members (conversation_id, user_id, state)
values (pg_temp.direct(1, 4), pg_temp.u(4), 'active'), (pg_temp.direct(1, 4), pg_temp.u(1), 'request');
update public.notifications set pushed_at = now() where recipient_id = pg_temp.u(1);

select pg_temp.backend_send(pg_temp.direct(1, 4), 4, 'Merhaba, tanışabilir miyiz?');
select is(pg_temp.waiting(1), 0, 'a message request does not ring');

update public.conversation_members set state = 'active' where conversation_id = pg_temp.direct(1, 4) and user_id = pg_temp.u(1);
select pg_temp.backend_send(pg_temp.direct(1, 4), 4, 'Teşekkürler!');
select is(pg_temp.waiting(1), 1, 'an accepted chat rings');

-- The two preferences are separate (2026-11-03): direct off keeps group messages ringing, and the other way round.
update public.notifications set pushed_at = now() where recipient_id = pg_temp.u(1);
set local role authenticated;
select pg_temp.act(pg_temp.u(1));
insert into public.notification_preferences (user_id, messages) values (pg_temp.u(1), false)
on conflict (user_id) do update set messages = excluded.messages;
reset role;
select pg_temp.backend_send(pg_temp.direct(1, 4), 4, 'Orada mısın?');
select is(pg_temp.waiting(1), 0, 'with direct message notices off a direct chat does not ring');
select pg_temp.backend_send(pg_temp.chat(), 3, 'Grup için saat 9');
select is(pg_temp.waiting(1), 1, 'but the group chat still rings');

update public.notifications set pushed_at = now() where recipient_id = pg_temp.u(1);
set local role authenticated;
select pg_temp.act(pg_temp.u(1));
update public.notification_preferences set messages = true, group_messages = false where user_id = pg_temp.u(1);
reset role;
select pg_temp.backend_send(pg_temp.chat(), 3, 'Saat 10 oldu');
select is(pg_temp.waiting(1), 0, 'with group message notices off a group chat does not ring');
select pg_temp.backend_send(pg_temp.direct(1, 4), 4, 'Haber ver');
select is(pg_temp.waiting(1), 1, 'but the direct chat still rings');
update public.notification_preferences set group_messages = true where user_id = pg_temp.u(1);
alter table public.messages enable trigger messages_guard;

update public.notifications set pushed_at = now() where recipient_id = pg_temp.u(1);
insert into public.blocks (blocker_id, blocked_id) values (pg_temp.u(1), pg_temp.u(2));
select pg_temp.act(pg_temp.u(2));
select pg_temp.send(pg_temp.chat(), 'Kimse yok mu?');
select is(pg_temp.waiting(1), 0, 'a blocked person does not ring you in a group either');

-- Deleting the chat takes its notices along.
delete from public.conversations where id = pg_temp.direct(1, 4);
select is((select count(*)::int from public.notifications where type = 'message' and conversation_id is null), 0,
  'notices go with their chat');

select * from finish();
rollback;
