begin;
create extension if not exists pgtap with schema extensions;

select plan(29);

-- t1 looks for teammates, t2 t3 look too, t4 is private, t5 does not look.
insert into auth.users (id, email, aud, role)
select ('00000000-0000-0000-0000-0000000bb10' || i)::uuid, 't' || i || '@test.local', 'authenticated', 'authenticated'
from generate_series(1, 5) i;
insert into public.profiles (id, username, display_name, is_private)
select ('00000000-0000-0000-0000-0000000bb10' || i)::uuid, 'team_user' || i, 'Ekip ' || i, i = 4
from generate_series(1, 5) i;
insert into public.profile_interests (user_id, category_slug)
select ('00000000-0000-0000-0000-0000000bb10' || i)::uuid, 'hiking' from generate_series(1, 5) i;

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;
create function pg_temp.u(i int) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000000bb10' || i)::uuid $$;

set local role authenticated;

-- Preferences ---------------------------------------------------------------------------------------------
do $$ begin
  for i in 1..4 loop
    perform pg_temp.act(pg_temp.u(i)::text);
    insert into public.teammate_preferences (user_id, looking, level, availability, province, note)
    values (pg_temp.u(i), true, 'intermediate', array['weekend_morning'], case when i = 3 then 6 else 34 end, ' Hafta sonu yürüyüşü ');
  end loop;
end $$;
select pg_temp.act('00000000-0000-0000-0000-0000000bb101');
select is((select note from public.teammate_preferences), 'Hafta sonu yürüyüşü', 'the note is trimmed');
select is((select count(*)::int from public.teammate_preferences), 1, 'others'' preferences (and provinces) are private');
select throws_ok(
  $$ insert into public.teammate_preferences (user_id, looking) values (pg_temp.u(5), true) $$,
  '42501', null, 'nobody writes someone else''s preferences'
);
select throws_ok(
  $$ update public.teammate_preferences set availability = array['midnight'] where user_id = pg_temp.u(1) $$,
  '23514', null, 'only known time slots'
);
select throws_ok(
  $$ update public.teammate_preferences set province = 82 where user_id = pg_temp.u(1) $$,
  '23514', null, 'only the 81 provinces'
);

-- Suggestions ---------------------------------------------------------------------------------------------
select is(
  (select array_agg(s->'person'->>'username' order by s->'person'->>'username') from jsonb_array_elements(public.teammate_suggestions()) s
   where s->'person'->>'username' like 'team_user%'),
  array['team_user2', 'team_user3'], 'people looking who share something; private and not-looking accounts never appear'
);
select is(
  (select (s->>'score')::int from jsonb_array_elements(public.teammate_suggestions()) s where s->'person'->>'username' = 'team_user2'),
  9, 'shared interest, province, level and slot add up'
);
select is(
  (select s->>'same_province' from jsonb_array_elements(public.teammate_suggestions()) s where s->'person'->>'username' = 'team_user3'),
  'false', 'a different province is not a reason'
);
select ok(
  (select bool_and(not s ? 'province') from jsonb_array_elements(public.teammate_suggestions()) s),
  'the province itself is never returned'
);
select is(public.teammate_status(pg_temp.u(2))->>'level', 'intermediate', 'the profile shows looking and the level');
select ok(not (public.teammate_status(pg_temp.u(2)) ? 'province'), 'but not the province');

-- Requests (written by the backend as the actor) ------------------------------------------------------------
select throws_ok(
  $$ insert into public.teammate_requests (requester_id, target_id) values (pg_temp.u(1), pg_temp.u(2)) $$,
  '42501', null, 'clients do not write requests directly'
);
reset role;
select lives_ok(
  $$ insert into public.teammate_requests (requester_id, target_id, message) values (pg_temp.u(1), pg_temp.u(2), ' Cumartesi Belgrad? ') $$,
  'a request goes to someone looking'
);
select throws_ok(
  $$ insert into public.teammate_requests (requester_id, target_id) values (pg_temp.u(1), pg_temp.u(5)) $$,
  'P0001', 'teammate_not_looking', 'not to someone who is not looking'
);
select throws_ok(
  $$ insert into public.teammate_requests (requester_id, target_id) values (pg_temp.u(3), pg_temp.u(2)) $$,
  'P0001', 'teammate_forbidden', 'nobody requests on someone else''s behalf'
);
select throws_ok(
  $$ insert into public.teammates (user_a, user_b) values (pg_temp.u(1), pg_temp.u(2)) $$,
  'P0001', 'teammate_forbidden', 'the requester cannot accept their own request'
);
set local role authenticated;
select is(public.teammate_status(pg_temp.u(2))->>'relation', 'requested', 'the requester sees the pending request');
select is(
  (select count(*)::int from jsonb_array_elements(public.teammate_suggestions()) s where s->'person'->>'username' like 'team_user%'), 1,
  'and the person leaves the suggestions'
);
select pg_temp.act('00000000-0000-0000-0000-0000000bb103');
select is((select count(*)::int from public.teammate_requests), 0, 'others'' requests are private');

-- Accepting -----------------------------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000bb102');
select is(public.my_teammates()->'incoming'->0->>'message', 'Cumartesi Belgrad?', 'the target sees the request with its message');
reset role;
select lives_ok(
  $$ insert into public.teammates (user_a, user_b) values (pg_temp.u(1), pg_temp.u(2));
     delete from public.teammate_requests where requester_id = pg_temp.u(1) and target_id = pg_temp.u(2) $$,
  'the target accepts'
);
select is(
  (select count(*)::int from public.notifications where recipient_id = pg_temp.u(1) and type = 'teammate_accepted'), 1,
  'the requester hears about it'
);
select pg_temp.act('00000000-0000-0000-0000-0000000bb101');
select throws_ok(
  $$ insert into public.teammate_requests (requester_id, target_id) values (pg_temp.u(1), pg_temp.u(2)) $$,
  'P0001', 'already_teammates', 'no second request'
);
set local role authenticated;
select is(public.my_teammates()->'teammates'->0->>'username', 'team_user2', 'both sides see the teammate');

-- Withdrawing and asking again (0022) ---------------------------------------------------------------------
reset role;
select pg_temp.act('00000000-0000-0000-0000-0000000bb103');
insert into public.teammate_requests (requester_id, target_id) values (pg_temp.u(3), pg_temp.u(1));
select pg_temp.act('00000000-0000-0000-0000-0000000bb101');
delete from public.teammate_requests where requester_id = pg_temp.u(3) and target_id = pg_temp.u(1);
select is(
  (select count(*)::int from public.notifications where recipient_id = pg_temp.u(1) and type = 'teammate_request'), 0,
  'a declined request takes its notification with it'
);
select pg_temp.act('00000000-0000-0000-0000-0000000bb103');
select throws_ok(
  $$ insert into public.teammate_requests (requester_id, target_id) values (pg_temp.u(3), pg_temp.u(1)) $$,
  'P0001', 'teammate_recently_asked', 'the same person is asked at most once a day'
);
insert into public.teammate_request_log (requester_id, target_id) select pg_temp.u(3), pg_temp.u(4) from generate_series(1, 19);
select throws_ok(
  $$ insert into public.teammate_requests (requester_id, target_id) values (pg_temp.u(3), pg_temp.u(2)) $$,
  'P0001', 'teammate_rate_limited', 'withdrawn requests still count toward the daily limit'
);
set local role authenticated;
select throws_ok($$ select * from public.teammate_request_log $$, '42501', null, 'the request log is not readable');

-- Blocking ------------------------------------------------------------------------------------------------
reset role;
select pg_temp.act('00000000-0000-0000-0000-0000000bb101');
insert into public.blocks (blocker_id, blocked_id) values (pg_temp.u(1), pg_temp.u(2));
set local role authenticated;
select is(jsonb_array_length(public.my_teammates()->'teammates'), 0, 'a block ends the pair');

select * from finish();
rollback;
