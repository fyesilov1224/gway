begin;
create extension if not exists pgtap with schema extensions;

select plan(17);

-- b1 owner (organizes), b2 b3 b4 attend, b5 member who did not go.
insert into auth.users (id, email, aud, role)
select ('00000000-0000-0000-0000-0000000ba00' || i)::uuid, 'b' || i || '@test.local', 'authenticated', 'authenticated'
from generate_series(1, 5) i;
insert into public.profiles (id, username, display_name)
select ('00000000-0000-0000-0000-0000000ba00' || i)::uuid, 'badge_user' || i, 'Rozet ' || i
from generate_series(1, 5) i;

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;
create function pg_temp.u(i int) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000000ba00' || i)::uuid $$;
create function pg_temp.g() returns uuid language sql as $$ select '00000000-0000-0000-0000-0000000bb001'::uuid $$;
create function pg_temp.e(i int) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000000be00' || i)::uuid $$;
create function pg_temp.counts(i int) returns jsonb language sql as $$ select private.contribution_counts(pg_temp.u(i), null) $$;

select pg_temp.act('00000000-0000-0000-0000-0000000ba001');
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id)
values (pg_temp.g(), 'rozet.grubu', 'Rozet Grubu', 'hiking', 'open', pg_temp.u(1));
insert into public.group_members (group_id, user_id) values (pg_temp.g(), pg_temp.u(1));
do $$ begin
  for i in 2..5 loop
    perform pg_temp.act(pg_temp.u(i)::text);
    insert into public.group_members (group_id, user_id) values (pg_temp.g(), pg_temp.u(i));
  end loop;
end $$;
select pg_temp.act('00000000-0000-0000-0000-0000000ba001');
insert into public.events (id, group_id, created_by, title, starts_at, location) values
  (pg_temp.e(1), pg_temp.g(), pg_temp.u(1), 'Geçen haftaki yürüyüş', now() + interval '1 day', 'Belgrad'),
  (pg_temp.e(2), pg_temp.g(), pg_temp.u(1), 'Gelecek yürüyüş', now() + interval '3 days', 'Polonezköy');
do $$ begin
  for i in 2..4 loop
    perform pg_temp.act(pg_temp.u(i)::text);
    insert into public.event_attendees (event_id, user_id) values (pg_temp.e(1), pg_temp.u(i)), (pg_temp.e(2), pg_temp.u(i));
  end loop;
end $$;

select is((pg_temp.counts(2)->>'attended')::int, 0, 'an event counts once it has ended');

-- The first event took place three days ago.
alter table public.events disable trigger user;
update public.events set starts_at = now() - interval '3 days' where id = pg_temp.e(1);
alter table public.events enable trigger user;

-- Roll call ---------------------------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000ba002');
select throws_ok(
  $$ update public.event_attendees set no_show_at = now() where event_id = pg_temp.e(1) and user_id = pg_temp.u(4) $$,
  'P0001', 'attendance_forbidden', 'members do not take the roll'
);
select pg_temp.act('00000000-0000-0000-0000-0000000ba001');
select throws_ok(
  $$ update public.event_attendees set no_show_at = now() where event_id = pg_temp.e(2) and user_id = pg_temp.u(4) $$,
  'P0001', 'roll_closed', 'the roll opens when the event ends'
);
select lives_ok(
  $$ update public.event_attendees set no_show_at = now() where event_id = pg_temp.e(1) and user_id = pg_temp.u(4) $$,
  'the organizer marks a no-show'
);
select is((select no_show_by from public.event_attendees where event_id = pg_temp.e(1) and user_id = pg_temp.u(4)), pg_temp.u(1),
  'who marked it is kept');
select is(jsonb_array_length(public.event_detail(pg_temp.e(1))->'roll'), 3, 'managers see the roll while it is open');
select pg_temp.act('00000000-0000-0000-0000-0000000ba004');
select throws_ok(
  $$ insert into public.event_reviews (event_id, user_id, rating) values (pg_temp.e(1), pg_temp.u(4), 5) $$,
  'P0001', 'review_not_allowed', 'a no-show does not review'
);
select is(public.event_detail(pg_temp.e(1))->'roll', 'null'::jsonb, 'members do not see the roll');

-- Counts and badges -----------------------------------------------------------------------------------
select is((pg_temp.counts(2)->>'attended')::int, 1, 'an attendee counts the event');
select is((pg_temp.counts(4)->>'attended')::int, 0, 'a no-show does not');
select is((pg_temp.counts(1)->>'organized')::int, 1, 'two people came: the organizer counts it');
select pg_temp.act('00000000-0000-0000-0000-0000000ba003');
select throws_ok(
  $$ update public.event_attendees set no_show_at = null, created_at = now() where event_id = pg_temp.e(1) and user_id = pg_temp.u(3) $$,
  'P0001', 'attendance_forbidden', 'members cannot touch their own attendance'
);
select is(
  (select array_agg(b->>'slug') from jsonb_array_elements(private.earned_badges(pg_temp.counts(1))) b),
  array['organizer'],
  'the organizer earns Düzenleyici'
);
select is(
  (select array_agg(b->>'name') from jsonb_array_elements(private.earned_badges('{"attended": 10, "groups": 3, "categories": {"hiking": 5}}')) b),
  array['İlk adım', 'Müdavim', 'Kâşif', 'Yürüyüş tutkunu'],
  'thresholds and category badges come from the catalog'
);

-- Visibility ---------------------------------------------------------------------------------------------
update public.profiles set is_private = true where id = pg_temp.u(2);
set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000ba005');
select is(public.user_contributions(pg_temp.u(2)), null, 'a private account''s contributions stay private');
select is(public.user_contributions(pg_temp.u(3))->'badges'->0->>'name', 'İlk adım', 'others'' badges are visible');
select is((public.group_contributions(pg_temp.g())->pg_temp.u(2)::text->>'attended')::int, 1, 'the member list shows attendance in the group');
reset role;

select * from finish();
rollback;
