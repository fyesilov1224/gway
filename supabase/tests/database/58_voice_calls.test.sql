begin;
create extension if not exists pgtap with schema extensions;

select plan(25);

-- f1 and f2 are matched; f3 is matched with f1 but never asks; f4 is a stranger.
insert into auth.users (id, email, aud, role)
select ('00000000-0000-0000-0000-0000000ff10' || i)::uuid, 'f' || i || '@test.local', 'authenticated', 'authenticated'
from generate_series(1, 4) i;
insert into public.profiles (id, username, display_name)
select ('00000000-0000-0000-0000-0000000ff10' || i)::uuid, 'caller' || i, 'Arayan ' || i
from generate_series(1, 4) i;

create function pg_temp.u(i int) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000000ff10' || i)::uuid $$;
create function pg_temp.act(i int) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', pg_temp.u(i), 'role', 'authenticated')::text, true);
$$;
create function pg_temp.chat(a int, b int) returns uuid language sql as $$
  select id from public.conversations where user_a = least(pg_temp.u(a), pg_temp.u(b)) and user_b = greatest(pg_temp.u(a), pg_temp.u(b));
$$;
create function pg_temp.call_status(i int) returns text language sql as $$
  select status from public.call_permissions where user_id = pg_temp.u(i);
$$;

insert into public.matches (user_a, user_b, mode) values
  (least(pg_temp.u(1), pg_temp.u(2)), greatest(pg_temp.u(1), pg_temp.u(2)), 'friend'),
  (least(pg_temp.u(1), pg_temp.u(3)), greatest(pg_temp.u(1), pg_temp.u(3)), 'friend');
insert into public.conversations (kind, user_a, user_b, created_by) values
  ('direct', least(pg_temp.u(1), pg_temp.u(2)), greatest(pg_temp.u(1), pg_temp.u(2)), pg_temp.u(1)),
  ('direct', least(pg_temp.u(1), pg_temp.u(3)), greatest(pg_temp.u(1), pg_temp.u(3)), pg_temp.u(1));

-- Asking for the feature ----------------------------------------------------------------------------------
set local role authenticated;
select pg_temp.act(1);
select lives_ok($$ select public.request_call_permission('Eşleştiğim kişiyle konuşmak istiyorum') $$, 'a person asks for voice calls');
select is(pg_temp.call_status(1), 'requested', 'the request waits for the platform team');
select throws_ok($$ select public.request_call_permission(null) $$, 'P0001', 'call_permission_exists', 'asking twice changes nothing');
select throws_ok($$ update public.call_permissions set status = 'active' $$, '42501', null, 'nobody grants it to themselves');
select pg_temp.act(4);
select is((select count(*)::int from public.call_permissions), 0, 'others do not see the request');
reset role;

-- Rules ---------------------------------------------------------------------------------------------------
select pg_temp.act(1);
select throws_ok($$ select private.start_call(pg_temp.chat(1, 2)) $$, 'P0001', 'call_no_permission', 'no permission, no call');

update public.call_permissions set status = 'active', decided_at = now() where user_id = pg_temp.u(1);
select throws_ok($$ select private.start_call(pg_temp.chat(1, 2)) $$, 'P0001', 'call_chat_locked',
  'calling needs the Eşleşme Sohbeti package too');

alter table public.user_subscriptions disable trigger user_subscriptions_guard;
insert into public.user_subscriptions (user_id, plan_slug, grant_reason, starts_at, ends_at)
select pg_temp.u(i), 'matching_chat', 'test', now() - interval '1 minute', now() + interval '1 day' from unnest(array[1, 2, 3]) i;
alter table public.user_subscriptions enable trigger user_subscriptions_guard;
select throws_ok($$ select private.start_call(pg_temp.chat(1, 2)) $$, 'P0001', 'call_peer_no_permission',
  'the other person needs permission as well');

insert into public.call_permissions (user_id, status, decided_at) values (pg_temp.u(2), 'active', now());
select is(
  (select count(*)::int from public.notifications where recipient_id = pg_temp.u(2) and type = 'call_permission_granted'), 1,
  'a person hears when the feature is opened for them'
);

-- A call ------------------------------------------------------------------------------------------------
select lives_ok($$ select private.start_call(pg_temp.chat(1, 2)) $$, 'two matched people with permission call');
select is((select status from public.calls where caller_id = pg_temp.u(1)), 'ringing', 'the call rings');
select is(
  (select count(*)::int from public.notifications where recipient_id = pg_temp.u(2) and type = 'call_incoming' and call_id is not null), 1,
  'the callee''s phone is rung'
);
select throws_ok($$ select private.start_call(pg_temp.chat(1, 2)) $$, 'P0001', 'call_busy', 'one call at a time');

set local role authenticated;
select pg_temp.act(2);
select is((select count(*)::int from public.calls), 1, 'the callee sees the call');
select is((select count(*)::int from public.notifications where type = 'call_incoming'), 0, 'the ringing push is not in the list');
select pg_temp.act(4);
select is((select count(*)::int from public.calls), 0, 'strangers do not');
reset role;
insert into public.platform_staff (user_id, role) values (pg_temp.u(4), 'admin');
set local role authenticated;
select pg_temp.act(4);
select is((select count(*)::int from public.calls), 0, 'nor does the platform team');
reset role;

-- Not answered: a missed call, which opens the chat.
update public.calls set status = 'missed', ended_at = now(), end_reason = 'missed' where caller_id = pg_temp.u(1);
set local role authenticated;
select pg_temp.act(2);
select is(
  (select n->>'conversation_id' from public.my_notifications() n where n->>'type' = 'call_missed'),
  pg_temp.chat(1, 2)::text, 'a missed call is listed and leads to the chat'
);
reset role;

-- Without a match, and after being declined ----------------------------------------------------------------
update public.matches set ended_at = now() where user_b = greatest(pg_temp.u(1), pg_temp.u(2)) and user_a = least(pg_temp.u(1), pg_temp.u(2));
select pg_temp.act(1);
select throws_ok($$ select private.start_call(pg_temp.chat(1, 2)) $$, 'P0001', 'call_not_matched',
  'only matched people and teammates call');

-- Teammates (0072): they call with the Ekip Arkadaşı package instead of Eşleşme Sohbeti.
alter table public.teammates disable trigger teammates_guard;
insert into public.teammates (user_a, user_b) values (least(pg_temp.u(1), pg_temp.u(2)), greatest(pg_temp.u(1), pg_temp.u(2)));
alter table public.teammates enable trigger teammates_guard;
select throws_ok($$ select private.start_call(pg_temp.chat(1, 2)) $$, 'P0001', 'call_teammate_locked',
  'teammates need the Ekip Arkadaşı package to call');
alter table public.user_subscriptions disable trigger user_subscriptions_guard;
insert into public.user_subscriptions (user_id, plan_slug, grant_reason, starts_at, ends_at)
values (pg_temp.u(1), 'matching_teammates', 'test', now() - interval '1 minute', now() + interval '1 day');
alter table public.user_subscriptions enable trigger user_subscriptions_guard;
select throws_ok($$ select private.start_call(pg_temp.chat(1, 2)) $$, 'P0001', 'call_peer_teammate_locked',
  'and so does the teammate they call');
alter table public.user_subscriptions disable trigger user_subscriptions_guard;
insert into public.user_subscriptions (user_id, plan_slug, grant_reason, starts_at, ends_at)
values (pg_temp.u(2), 'matching_teammates', 'test', now() - interval '1 minute', now() + interval '1 day');
alter table public.user_subscriptions enable trigger user_subscriptions_guard;
select lives_ok($$ select private.start_call(pg_temp.chat(1, 2)) $$, 'two teammates with permission and the package call');
select is((select count(*)::int from public.calls where caller_id = pg_temp.u(1) and status = 'ringing'), 1, 'the teammate''s phone rings');

insert into public.call_permissions (user_id, status, decided_at, reason) values (pg_temp.u(3), 'declined', now(), 'Şimdilik değil');
set local role authenticated;
select pg_temp.act(3);
select throws_ok($$ select public.request_call_permission(null) $$, 'P0001', 'call_permission_cooldown',
  'a declined person asks again only after a week');
reset role;
select is(
  (select count(*)::int from public.notifications where recipient_id = pg_temp.u(3) and type = 'call_permission_declined'), 1,
  'and hears that it was declined'
);

select * from finish();
rollback;
