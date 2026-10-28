begin;
create extension if not exists pgtap with schema extensions;

select plan(17);

-- League hiking/Ankara (6): ga (owner l01, members l02–l05) and gb (owner l06, member l07).
-- gc: hiking/İstanbul, another league; gd: no province. l08 platform staff, l09 outsider.
insert into auth.users (id, email, aud, role)
select ('00000000-0000-0000-0000-0000004900' || lpad(i::text, 2, '0'))::uuid, 'lig' || i || '@test.local', 'authenticated', 'authenticated'
from generate_series(1, 9) i;
insert into public.profiles (id, username, display_name)
select ('00000000-0000-0000-0000-0000004900' || lpad(i::text, 2, '0'))::uuid, 'league_user' || lpad(i::text, 2, '0'), 'Lig ' || i
from generate_series(1, 9) i;
insert into public.platform_staff (user_id, role) values ('00000000-0000-0000-0000-000000490008', 'moderator');

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;
create function pg_temp.u(i int) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000004900' || lpad(i::text, 2, '0'))::uuid $$;
create function pg_temp.as_user(i int) returns void language sql as $$ select pg_temp.act(pg_temp.u(i)::text) $$;
create function pg_temp.g(c text) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000004901' || c || c)::uuid $$;
create function pg_temp.e(c text) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000004902' || c || c)::uuid $$;
-- The events started three hours ago, so the month is the one they fall in.
create function pg_temp.month() returns date language sql as $$ select private.turkey_month(now() - interval '3 hours') $$;
create function pg_temp.table_() returns jsonb language sql as $$ select public.league_table('hiking', 6::smallint, pg_temp.month()) $$;
create function pg_temp.row_(i int) returns jsonb language sql as $$ select pg_temp.table_()->'rows'->i $$;

create function pg_temp.group_(c text, owner int, province smallint, members int[]) returns void language plpgsql as $$
declare i int;
begin
  perform pg_temp.as_user(owner);
  insert into public.groups (id, handle, name, category_slug, join_policy, owner_id, province)
  values (pg_temp.g(c), 'lig.' || c, 'Lig ' || upper(c), 'hiking', 'open', pg_temp.u(owner), province);
  insert into public.group_members (group_id, user_id) values (pg_temp.g(c), pg_temp.u(owner));
  foreach i in array members loop
    perform pg_temp.as_user(i);
    insert into public.group_members (group_id, user_id) values (pg_temp.g(c), pg_temp.u(i));
  end loop;
  perform pg_temp.as_user(owner);
  insert into public.events (id, group_id, created_by, title, starts_at, location)
  values (pg_temp.e(c), pg_temp.g(c), pg_temp.u(owner), 'Yürüyüş ' || c, now() + interval '1 day', 'Eymir');
  foreach i in array members loop
    perform pg_temp.as_user(i);
    insert into public.event_attendees (event_id, user_id) values (pg_temp.e(c), pg_temp.u(i));
  end loop;
end $$;

select pg_temp.group_('a', 1, 6::smallint, array[2, 3, 4, 5]);
select pg_temp.group_('b', 6, 6::smallint, array[7]);
select pg_temp.group_('c', 9, 34::smallint, array[7]);
select pg_temp.group_('d', 8, null, array[7]);
alter table public.events disable trigger user;
update public.events set starts_at = now() - interval '3 hours' where id in (pg_temp.e('a'), pg_temp.e('b'), pg_temp.e('c'), pg_temp.e('d'));
alter table public.events enable trigger user;
select pg_temp.as_user(2);
insert into public.event_reviews (event_id, user_id, rating) values (pg_temp.e('a'), pg_temp.u(2), 5);
select pg_temp.as_user(3);
insert into public.event_reviews (event_id, user_id, rating) values (pg_temp.e('a'), pg_temp.u(3), 3);

-- Live table ----------------------------------------------------------------------------------------
select pg_temp.as_user(9);
select is(jsonb_array_length(pg_temp.table_()->'rows'), 2, 'a league is one category in one province');
select is(pg_temp.row_(0)->'group'->>'handle', 'lig.a', 'the busiest group leads');
-- 4 attended + an event with 3+ others (5) + one 4–5 star review (1).
select is((pg_temp.row_(0)->>'points')::int, 10, 'attendance, a real event and good reviews add up');
select is((pg_temp.row_(0)->>'held')::int, 1, 'an event with three or more others counts as held');
select is((pg_temp.row_(1)->>'points')::int, 1, 'a small event only counts its people');
select is((pg_temp.table_()->>'finalized')::boolean, false, 'the running season is live');

select pg_temp.as_user(1);
update public.event_attendees set no_show_at = now() where event_id = pg_temp.e('a') and user_id in (pg_temp.u(4), pg_temp.u(5));
select is((pg_temp.row_(0)->>'points')::int, 3, 'no-shows do not count, and two people are not an event');

select is((public.group_league(pg_temp.g('a'))->>'rank')::int, 1, 'the group card shows the place');
select is((public.group_league(pg_temp.g('a'))->>'groups')::int, 2, 'and how many play');
select is(public.group_league(pg_temp.g('d')), null, 'a group without a province plays no league');

-- Exclusion -----------------------------------------------------------------------------------------
select pg_temp.as_user(1);
select throws_ok(
  $$ insert into public.league_exclusions (month, group_id, reason) values (pg_temp.month(), pg_temp.g('b'), 'Sahte katılım') $$,
  'P0001', 'league_forbidden', 'only the platform team excludes');
select pg_temp.as_user(8);
insert into public.league_exclusions (month, group_id, reason) values (pg_temp.month(), pg_temp.g('a'), 'Sahte katılım');
select is(pg_temp.row_(0)->'group'->>'handle', 'lig.b', 'an excluded group leaves the table');
delete from public.league_exclusions where group_id = pg_temp.g('a');

-- Closing the season --------------------------------------------------------------------------------
select ok(private.finalize_league_seasons(now() + interval '45 days') >= 1, 'a season closes eight days after the month');
select is((pg_temp.table_()->>'finalized')::boolean, true, 'a closed season is frozen');
select pg_temp.as_user(1);
update public.event_attendees set no_show_at = null where event_id = pg_temp.e('a') and user_id in (pg_temp.u(4), pg_temp.u(5));
select is((pg_temp.row_(0)->>'points')::int, 3, 'later changes do not move a closed season');
select is((select count(*)::int from public.notifications where type = 'league_result' and group_id = pg_temp.g('a')), 5,
  'every member of a top-three group hears about it');
select pg_temp.as_user(8);
select throws_ok(
  $$ insert into public.league_exclusions (month, group_id, reason) values (pg_temp.month(), pg_temp.g('b'), 'Geç kaldı') $$,
  'P0001', 'league_season_closed', 'a closed season is not changed');

select * from finish();
rollback;
