begin;
create extension if not exists pgtap with schema extensions;

select plan(20);

-- h1 owner (manager), h2 and h4 attend, h3 member who did not go.
insert into auth.users (id, email, aud, role)
select ('00000000-0000-0000-0000-0000000f100' || i)::uuid, 'h' || i || '@test.local', 'authenticated', 'authenticated'
from generate_series(1, 4) i;
insert into public.profiles (id, username, display_name)
select ('00000000-0000-0000-0000-0000000f100' || i)::uuid, 'memory_user' || i, 'Anı ' || i
from generate_series(1, 4) i;

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;
create function pg_temp.u(i int) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000000f100' || i)::uuid $$;
create function pg_temp.g() returns uuid language sql as $$ select '00000000-0000-0000-0000-0000000f2001'::uuid $$;
create function pg_temp.e(i int) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000000f300' || i)::uuid $$;
create function pg_temp.post(i int, ev uuid) returns void language sql as $$
  select pg_temp.act(pg_temp.u(i)::text);
  insert into public.posts (author_id, caption, event_id) values (pg_temp.u(i), 'Harika bir gündü', ev);
$$;

select pg_temp.act('00000000-0000-0000-0000-0000000f1001');
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id)
values (pg_temp.g(), 'ani.grubu', 'Anı Grubu', 'hiking', 'open', pg_temp.u(1));
insert into public.group_members (group_id, user_id) values (pg_temp.g(), pg_temp.u(1));
do $$ begin
  for i in 2..4 loop
    perform pg_temp.act(pg_temp.u(i)::text);
    insert into public.group_members (group_id, user_id) values (pg_temp.g(), pg_temp.u(i));
  end loop;
end $$;
select pg_temp.act('00000000-0000-0000-0000-0000000f1001');
insert into public.events (id, group_id, created_by, title, starts_at, location) values
  (pg_temp.e(1), pg_temp.g(), pg_temp.u(1), 'Pazar yürüyüşü', now() + interval '1 day', 'Belgrad'),
  (pg_temp.e(2), pg_temp.g(), pg_temp.u(1), 'Gelecek tur', now() + interval '5 days', 'Polonezköy');
do $$ begin
  for i in 2..4 by 2 loop
    perform pg_temp.act(pg_temp.u(i)::text);
    insert into public.event_attendees (event_id, user_id) values (pg_temp.e(1), pg_temp.u(i));
  end loop;
end $$;

-- Memories ------------------------------------------------------------------------------------------
select throws_ok($$ select pg_temp.post(2, pg_temp.e(1)) $$, 'P0001', 'event_post_forbidden', 'no memories before the event starts');

-- The event took place: started 4 hours ago (no end: two hours).
alter table public.events disable trigger user;
update public.events set starts_at = now() - interval '4 hours' where id = pg_temp.e(1);
alter table public.events enable trigger user;

select throws_ok($$ select pg_temp.post(3, pg_temp.e(1)) $$, 'P0001', 'event_post_forbidden', 'only those who went share memories');
select lives_ok($$ select pg_temp.post(2, pg_temp.e(1)) $$, 'an attendee links a memory');
select lives_ok($$ select pg_temp.post(1, pg_temp.e(1)) $$, 'a manager links a memory');
select pg_temp.act('00000000-0000-0000-0000-0000000f1002');
select throws_ok(
  $$ update public.posts set event_id = pg_temp.e(2) where author_id = pg_temp.u(2) $$,
  'P0001', 'post_immutable', 'the link never changes'
);
set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000f1003');
select is((select count(*)::int from public.event_posts(pg_temp.e(1))), 2, 'members who did not go see the public memories');
select is(private.event_card(e)->>'posts_count', '2', 'the summary counts the memories') from public.events e where e.id = pg_temp.e(1);
reset role;

-- Reviews ---------------------------------------------------------------------------------------------
set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000f1003');
select throws_ok(
  $$ insert into public.event_reviews (event_id, user_id, rating) values (pg_temp.e(1), pg_temp.u(3), 5) $$,
  'P0001', 'review_not_allowed', 'only those who went review'
);
select pg_temp.act('00000000-0000-0000-0000-0000000f1002');
select throws_ok(
  $$ insert into public.event_reviews (event_id, user_id, rating) values (pg_temp.e(1), pg_temp.u(2), 6) $$,
  '23514', null, 'ratings are 1–5'
);
select lives_ok(
  $$ insert into public.event_reviews (event_id, user_id, rating, comment) values (pg_temp.e(1), pg_temp.u(2), 4, '  Rota çok güzeldi  ') $$,
  'an attendee reviews the event'
);
select lives_ok(
  $$ insert into public.event_reviews (event_id, user_id, rating, comment) values (pg_temp.e(1), pg_temp.u(2), 5, 'Rota çok güzeldi')
     on conflict (event_id, user_id) do update set event_id = excluded.event_id, user_id = excluded.user_id,
       rating = excluded.rating, comment = excluded.comment $$,
  'and changes it with the app''s upsert'
);
select throws_ok(
  $$ insert into public.event_reviews (event_id, user_id, rating) values (pg_temp.e(1), pg_temp.u(4), 1) $$,
  '42501', null, 'nobody reviews in someone else''s name'
);
select throws_ok(
  $$ insert into public.event_reviews (event_id, user_id, rating) values (pg_temp.e(2), pg_temp.u(2), 5) $$,
  'P0001', 'review_not_allowed', 'events are reviewed after they end'
);
select pg_temp.act('00000000-0000-0000-0000-0000000f1003');
select is((select count(*)::int from public.event_reviews), 0, 'other members do not read the notes');
select is(public.event_detail(pg_temp.e(1))->>'rating_avg', '5.0', 'but everyone sees the average');
select pg_temp.act('00000000-0000-0000-0000-0000000f1001');
select is(public.event_detail(pg_temp.e(1))->'reviews'->0->>'comment', 'Rota çok güzeldi', 'managers read the notes');
reset role;

-- Review requests and the history --------------------------------------------------------------------
insert into public.notification_preferences (user_id, event_review_requests) values (pg_temp.u(4), false);
select set_config('request.jwt.claims', '', true);
select is(private.send_review_requests(), 1, 'attendees who want it are asked once');
select is(private.send_review_requests(), 0, 'and not again');
select pg_temp.act('00000000-0000-0000-0000-0000000f1001');
select throws_ok(
  $$ update public.events set review_asked_at = null where id = pg_temp.e(1) $$,
  'P0001', 'event_immutable', 'the request mark is the job''s'
);
select is(
  (select array_agg(x->>'title') from jsonb_array_elements(public.group_event_history(pg_temp.g())) x),
  array['Pazar yürüyüşü'],
  'the history lists past events only'
);

select * from finish();
rollback;
