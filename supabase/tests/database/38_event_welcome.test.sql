begin;
create extension if not exists pgtap with schema extensions;

select plan(28);

-- w01 owner, w02 veteran (went to e1), w03 w04 w09 w10 first-timers, w05 member with no history,
-- w06 outsider, w07 platform staff, w08 first-timer who blocked w02.
insert into auth.users (id, email, aud, role)
select ('00000000-0000-0000-0000-0000004800' || lpad(i::text, 2, '0'))::uuid, 'wel' || i || '@test.local', 'authenticated', 'authenticated'
from generate_series(1, 10) i;
insert into public.profiles (id, username, display_name)
select ('00000000-0000-0000-0000-0000004800' || lpad(i::text, 2, '0'))::uuid, 'welcome_user' || lpad(i::text, 2, '0'), 'Karşılama ' || i
from generate_series(1, 10) i;
insert into public.platform_staff (user_id, role) values ('00000000-0000-0000-0000-000000480007', 'support');

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;
create function pg_temp.u(i int) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000004800' || lpad(i::text, 2, '0'))::uuid $$;
create function pg_temp.as_user(i int) returns void language sql as $$ select pg_temp.act(pg_temp.u(i)::text) $$;
create function pg_temp.g() returns uuid language sql as $$ select '00000000-0000-0000-0000-0000004801aa'::uuid $$;
create function pg_temp.e(i int) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000004802e' || i)::uuid $$;
create function pg_temp.notes(i int, kind text) returns int language sql as $$
  select count(*)::int from public.notifications where recipient_id = pg_temp.u(i) and type = kind
$$;

select pg_temp.as_user(1);
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id)
values (pg_temp.g(), 'karsilama', 'Karşılama Grubu', 'hiking', 'open', pg_temp.u(1));
insert into public.group_members (group_id, user_id) values (pg_temp.g(), pg_temp.u(1));
do $$ declare i int; begin
  foreach i in array array[2, 3, 4, 5, 8, 9, 10] loop
    perform pg_temp.as_user(i);
    insert into public.group_members (group_id, user_id) values (pg_temp.g(), pg_temp.u(i));
  end loop;
end $$;
select pg_temp.as_user(8);
insert into public.blocks (blocker_id, blocked_id) values (pg_temp.u(8), pg_temp.u(2));

select pg_temp.as_user(1);
insert into public.events (id, group_id, created_by, title, starts_at, location) values
  (pg_temp.e(1), pg_temp.g(), pg_temp.u(1), 'Geçmiş yürüyüş', now() + interval '1 day', 'Belgrad'),
  (pg_temp.e(2), pg_temp.g(), pg_temp.u(1), 'Pazar yürüyüşü', now() + interval '2 days', 'Polonezköy');
-- A third event this month is over the free plan; the limit is not under test here.
alter table public.events disable trigger user;
insert into public.events (id, group_id, created_by, title, starts_at, location) values
  (pg_temp.e(3), pg_temp.g(), pg_temp.u(1), 'Gelecek ay', now() + interval '20 days', 'Ağva');
alter table public.events enable trigger user;
select pg_temp.as_user(2);
insert into public.event_attendees (event_id, user_id) values (pg_temp.e(1), pg_temp.u(2)), (pg_temp.e(2), pg_temp.u(2));
do $$ declare i int; begin
  foreach i in array array[3, 4, 5, 8, 9, 10] loop
    perform pg_temp.as_user(i);
    insert into public.event_attendees (event_id, user_id) values (pg_temp.e(2), pg_temp.u(i));
  end loop;
end $$;
select pg_temp.as_user(3);
insert into public.event_attendees (event_id, user_id) values (pg_temp.e(3), pg_temp.u(3));
alter table public.events disable trigger user;
update public.events set starts_at = now() - interval '5 days' where id = pg_temp.e(1);
alter table public.events enable trigger user;

-- Greeters ----------------------------------------------------------------------------------------------
select pg_temp.as_user(5);
select throws_ok($$ insert into public.group_greeters (group_id, user_id) values (pg_temp.g(), pg_temp.u(5)) $$,
  'P0001', 'greeter_not_allowed', 'a member who never went cannot greet yet');
select pg_temp.as_user(2);
select lives_ok($$ insert into public.group_greeters (group_id, user_id) values (pg_temp.g(), pg_temp.u(2)) $$,
  'a member who went becomes a greeter');
select pg_temp.as_user(1);
select lives_ok($$ insert into public.group_greeters (group_id, user_id) values (pg_temp.g(), pg_temp.u(1)) $$,
  'the team greets without history');
select pg_temp.as_user(6);
select throws_ok($$ insert into public.group_greeters (group_id, user_id) values (pg_temp.g(), pg_temp.u(2)) $$,
  'P0001', 'greeter_not_allowed', 'nobody signs someone else up');
select is((public.group_welcome(pg_temp.g())->>'greeters')::int, 2, 'everyone sees how many greeters there are');

-- Requests ----------------------------------------------------------------------------------------------
select pg_temp.as_user(3);
select lives_ok($$ insert into public.event_welcomes (event_id, newcomer_id, newcomer_note) values (pg_temp.e(2), pg_temp.u(3), 'Mavi çantalıyım') $$,
  'a first-timer asks to be greeted');
select is(pg_temp.notes(2, 'welcome_requested') + pg_temp.notes(1, 'welcome_requested'), 2, 'every greeter hears about it');
select throws_ok($$ insert into public.event_welcomes (event_id, newcomer_id) values (pg_temp.e(3), pg_temp.u(3)) $$,
  'P0001', 'welcome_already_requested', 'one open request per group');
select pg_temp.as_user(2);
select throws_ok($$ insert into public.event_welcomes (event_id, newcomer_id) values (pg_temp.e(2), pg_temp.u(2)) $$,
  'P0001', 'welcome_not_first_time', 'someone who went before is not a first-timer');
select pg_temp.as_user(6);
select throws_ok($$ insert into public.event_welcomes (event_id, newcomer_id) values (pg_temp.e(2), pg_temp.u(6)) $$,
  'P0001', 'welcome_not_allowed', 'only people going ask');
do $$ declare i int; begin
  foreach i in array array[4, 8, 9, 10] loop
    perform pg_temp.as_user(i);
    insert into public.event_welcomes (event_id, newcomer_id) values (pg_temp.e(2), pg_temp.u(i));
  end loop;
end $$;

set local role authenticated;
select pg_temp.as_user(2);
select is((select count(*)::int from public.event_welcomes where event_id = pg_temp.e(2)), 5, 'a going greeter sees the requests');
select pg_temp.as_user(5);
select is((select count(*)::int from public.event_welcomes where event_id = pg_temp.e(2)), 0, 'other members do not');
reset role;

-- Taking ------------------------------------------------------------------------------------------------
select pg_temp.as_user(5);
select throws_ok($$ update public.event_welcomes set greeter_id = pg_temp.u(5), greeter_note = 'Girişte'
                    where event_id = pg_temp.e(2) and newcomer_id = pg_temp.u(3) $$,
  'P0001', 'welcome_take_not_allowed', 'only greeters take a request');
select pg_temp.as_user(2);
select lives_ok($$ update public.event_welcomes set greeter_id = pg_temp.u(2), greeter_note = 'Girişteki kafe, 08:45'
                   where event_id = pg_temp.e(2) and newcomer_id = pg_temp.u(3) $$,
  'a greeter takes a request with a meeting note');
select is(pg_temp.notes(3, 'welcome_matched'), 1, 'the first-timer hears who greets them');
select pg_temp.as_user(3);
select is(public.event_welcome(pg_temp.e(2))->'mine'->'greeter'->>'username', 'welcome_user02', 'the event page names the greeter');
select pg_temp.as_user(2);
select throws_ok($$ update public.event_welcomes set greeter_id = pg_temp.u(2), greeter_note = 'Girişte'
                    where event_id = pg_temp.e(2) and newcomer_id = pg_temp.u(8) $$,
  'P0001', 'welcome_take_not_allowed', 'a block keeps them apart');
update public.event_welcomes set greeter_id = pg_temp.u(2), greeter_note = 'Girişte' where event_id = pg_temp.e(2) and newcomer_id = pg_temp.u(4);
update public.event_welcomes set greeter_id = pg_temp.u(2), greeter_note = 'Girişte' where event_id = pg_temp.e(2) and newcomer_id = pg_temp.u(9);
select throws_ok($$ update public.event_welcomes set greeter_id = pg_temp.u(2), greeter_note = 'Girişte'
                    where event_id = pg_temp.e(2) and newcomer_id = pg_temp.u(10) $$,
  'P0001', 'welcome_greeter_full', 'a greeter takes at most three people');

-- Stepping back -----------------------------------------------------------------------------------------
update public.event_welcomes set greeter_id = null where event_id = pg_temp.e(2) and newcomer_id = pg_temp.u(4);
select is(pg_temp.notes(4, 'welcome_released'), 1, 'a released first-timer is told');
update public.event_welcomes set greeter_id = pg_temp.u(2), greeter_note = 'Otoparkta' where event_id = pg_temp.e(2) and newcomer_id = pg_temp.u(4);

select pg_temp.as_user(3);
delete from public.event_attendees where event_id = pg_temp.e(2) and user_id = pg_temp.u(3);
select is((select count(*)::int from public.event_welcomes where newcomer_id = pg_temp.u(3)), 0, 'leaving the event drops the request');
select is(pg_temp.notes(2, 'welcome_withdrawn'), 1, 'and tells the greeter');

-- Thanks and the badge ----------------------------------------------------------------------------------
select pg_temp.as_user(4);
select throws_ok($$ update public.event_welcomes set thanked_at = now() where event_id = pg_temp.e(2) and newcomer_id = pg_temp.u(4) $$,
  'P0001', 'welcome_thanks_not_allowed', 'thanks come after the event');
alter table public.events disable trigger user;
update public.events set starts_at = now() - interval '1 day' where id = pg_temp.e(2);
alter table public.events enable trigger user;
select lives_ok($$ update public.event_welcomes set thanked_at = now() where event_id = pg_temp.e(2) and newcomer_id = pg_temp.u(4) $$,
  'the first-timer thanks their greeter');
select is(pg_temp.notes(2, 'welcome_thanked'), 1, 'the greeter hears the thanks');
select is((private.contribution_counts(pg_temp.u(2), null)->>'welcomed')::int, 2, 'each greeted first-timer who came counts');
select ok(private.earned_badges(private.contribution_counts(pg_temp.u(2), null)) @> '[{"slug": "door_opener"}]',
  'the first welcome earns "Kapı açan"');

-- Privacy fix: per-member numbers are for members ------------------------------------------------------
select pg_temp.as_user(6);
select is(public.group_contributions(pg_temp.g()), '{}'::jsonb, 'outsiders get no per-member numbers');

set local role anon;
select throws_ok($$ select public.event_welcome('00000000-0000-0000-0000-0000004802e2') $$, '42501', null, 'visitors cannot read welcomes');
reset role;

select * from finish();
rollback;
