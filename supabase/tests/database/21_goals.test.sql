begin;
create extension if not exists pgtap with schema extensions;

select plan(22);

-- q1 owner (manager), q2 q3 members who attend, q4 outsider.
insert into auth.users (id, email, aud, role)
select ('00000000-0000-0000-0000-0000000aa10' || i)::uuid, 'q' || i || '@test.local', 'authenticated', 'authenticated'
from generate_series(1, 4) i;
insert into public.profiles (id, username, display_name)
select ('00000000-0000-0000-0000-0000000aa10' || i)::uuid, 'goal_user' || i, 'Hedef ' || i
from generate_series(1, 4) i;

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;
create function pg_temp.u(i int) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000000aa10' || i)::uuid $$;
create function pg_temp.grp() returns uuid language sql as $$ select '00000000-0000-0000-0000-0000000aa201'::uuid $$;
create function pg_temp.goal(i int) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000000aa30' || i)::uuid $$;
create function pg_temp.new_goal(i int, kind text, metric text, target int) returns void language sql as $$
  insert into public.goals (id, group_id, created_by, title, kind, metric, target, starts_at, ends_at)
  values (pg_temp.goal(i), pg_temp.grp(), pg_temp.u(1), 'Hedef ' || i, kind, metric, target, now() - interval '5 days', now() + interval '10 days');
$$;

select pg_temp.act('00000000-0000-0000-0000-0000000aa101');
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id)
values (pg_temp.grp(), 'hedef.grubu', 'Hedef Grubu', 'running', 'open', pg_temp.u(1));
insert into public.group_members (group_id, user_id) values (pg_temp.grp(), pg_temp.u(1));
do $$ begin
  for i in 2..3 loop
    perform pg_temp.act(pg_temp.u(i)::text);
    insert into public.group_members (group_id, user_id) values (pg_temp.grp(), pg_temp.u(i));
  end loop;
end $$;

-- An event that took place two days ago, attended by q2 and q3.
select pg_temp.act('00000000-0000-0000-0000-0000000aa101');
insert into public.events (id, group_id, created_by, title, starts_at, location)
values ('00000000-0000-0000-0000-0000000aa401', pg_temp.grp(), pg_temp.u(1), 'Sahil koşusu', now() + interval '1 day', 'Moda');
do $$ begin
  for i in 2..3 loop
    perform pg_temp.act(pg_temp.u(i)::text);
    insert into public.event_attendees (event_id, user_id) values ('00000000-0000-0000-0000-0000000aa401', pg_temp.u(i));
  end loop;
end $$;
alter table public.events disable trigger user;
update public.events set starts_at = now() - interval '2 days' where id = '00000000-0000-0000-0000-0000000aa401';
alter table public.events enable trigger user;

-- Creating ----------------------------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000aa102');
select throws_ok($$ select pg_temp.new_goal(9, 'group', 'attended', 2) $$, 'P0001', 'goal_forbidden', 'members do not open goals');
select pg_temp.act('00000000-0000-0000-0000-0000000aa101');
select throws_ok(
  $$ insert into public.goals (group_id, created_by, title, kind, metric, target, starts_at, ends_at)
     values (pg_temp.grp(), pg_temp.u(1), 'Uzun hedef', 'group', 'attended', 2, now(), now() + interval '100 days') $$,
  '23514', null, 'a goal lasts at most 92 days'
);
select lives_ok(
  $$ select pg_temp.new_goal(1, 'personal', 'attended', 1), pg_temp.new_goal(2, 'group', 'attended', 2),
            pg_temp.new_goal(3, 'team', 'attended', 2), pg_temp.new_goal(4, 'task', null, null),
            pg_temp.new_goal(5, 'personal', 'memories', 3) $$,
  'a manager opens five goals of every kind'
);
select throws_ok($$ select pg_temp.new_goal(6, 'group', 'organized', 1) $$, 'P0001', 'goal_limit_reached', 'at most five goals run at once');

-- Teams ---------------------------------------------------------------------------------------------------
insert into public.goal_teams (id, goal_id, name) values ('00000000-0000-0000-0000-0000000aa501', pg_temp.goal(3), 'Kuzey');
insert into public.goal_team_members (goal_id, team_id, user_id) values
  (pg_temp.goal(3), '00000000-0000-0000-0000-0000000aa501', pg_temp.u(2)),
  (pg_temp.goal(3), '00000000-0000-0000-0000-0000000aa501', pg_temp.u(3));
select throws_ok(
  $$ insert into public.goal_team_members (goal_id, team_id, user_id) values (pg_temp.goal(3), '00000000-0000-0000-0000-0000000aa501', pg_temp.u(4)) $$,
  'P0001', 'goal_team_invalid', 'only members join a team'
);
select pg_temp.act('00000000-0000-0000-0000-0000000aa102');
select throws_ok(
  $$ insert into public.goal_teams (goal_id, name) values (pg_temp.goal(3), 'Güney') $$,
  'P0001', 'goal_forbidden', 'members do not set up teams'
);

-- Progress and completions --------------------------------------------------------------------------------
select is(private.goal_card(g)->>'progress', '1', 'personal progress counts my attendance') from public.goals g where g.id = pg_temp.goal(1);
select is(private.goal_card(g)->>'progress', '2', 'group progress counts everyone') from public.goals g where g.id = pg_temp.goal(2);
select is(private.goal_card(g)->>'my_team', 'Kuzey', 'I see my team') from public.goals g where g.id = pg_temp.goal(3);
select set_config('request.jwt.claims', '', true);
select is(private.record_goal_completions(), 6, 'personal, group and team goals are completed for those who contributed');
select is(private.record_goal_completions(), 0, 'and recorded once');
select is((select count(*)::int from public.notifications where recipient_id = pg_temp.u(2) and type = 'goal_completed'), 3,
  'each completion is announced');

-- Tasks -------------------------------------------------------------------------------------------------
set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000aa102');
select lives_ok(
  $$ insert into public.goal_claims (goal_id, user_id, note) values (pg_temp.goal(4), pg_temp.u(2), ' Yeni üyelere rota anlattım ') $$,
  'a member claims a task'
);
select throws_ok(
  $$ update public.goal_claims set status = 'approved' where goal_id = pg_temp.goal(4) $$,
  '42501', null, 'nobody approves their own claim'
);
select pg_temp.act('00000000-0000-0000-0000-0000000aa104');
select throws_ok(
  $$ insert into public.goal_claims (goal_id, user_id) values (pg_temp.goal(4), pg_temp.u(4)) $$,
  'P0001', 'claim_not_allowed', 'outsiders do not claim tasks'
);
select pg_temp.act('00000000-0000-0000-0000-0000000aa103');
select is((select count(*)::int from public.goal_claims), 0, 'others'' claims are private');
reset role;
select pg_temp.act('00000000-0000-0000-0000-0000000aa101');
select lives_ok(
  $$ update public.goal_claims set status = 'approved' where goal_id = pg_temp.goal(4) and user_id = pg_temp.u(2) $$,
  'a manager approves the claim'
);
select ok(exists (select 1 from public.goal_completions where goal_id = pg_temp.goal(4) and user_id = pg_temp.u(2)), 'the task is completed');
select is(
  (select count(*)::int from jsonb_array_elements(private.user_contributions(pg_temp.u(2))->'badges') b where b->>'name' like 'Hedef: %'),
  4, 'every reached goal is a badge on the profile'
);

-- Changes -----------------------------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000aa102');
select throws_ok($$ update public.goals set canceled_at = now() where id = pg_temp.goal(5) $$, 'P0001', 'goal_forbidden', 'members do not cancel goals');
select pg_temp.act('00000000-0000-0000-0000-0000000aa101');
select throws_ok($$ update public.goals set title = 'Başka' where id = pg_temp.goal(5) $$, 'P0001', 'goal_immutable', 'a goal is not edited');
select lives_ok($$ update public.goals set canceled_at = now() where id = pg_temp.goal(5) $$, 'a manager cancels a goal');

select * from finish();
rollback;
