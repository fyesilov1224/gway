begin;
create extension if not exists pgtap with schema extensions;

select plan(8);

-- o owns group 6001; a and b are members; a is muted later. x is a stranger who follows nobody.
insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-00000060a001', 'open-o@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000060a002', 'open-a@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000060a003', 'open-b@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000060a009', 'open-x@test.local', 'authenticated', 'authenticated');
insert into public.profiles (id, username, display_name) values
  ('00000000-0000-0000-0000-00000060a001', 'open_o', 'O'),
  ('00000000-0000-0000-0000-00000060a002', 'open_a', 'A'),
  ('00000000-0000-0000-0000-00000060a003', 'open_b', 'B'),
  ('00000000-0000-0000-0000-00000060a009', 'open_x', 'X');

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;

select pg_temp.act('00000000-0000-0000-0000-00000060a001');
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id)
values ('00000000-0000-0000-0000-000000006001', 'open.rules', 'Açık Kurallar', 'hiking', 'open', '00000000-0000-0000-0000-00000060a001');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-000000006001', '00000000-0000-0000-0000-00000060a001');
select pg_temp.act('00000000-0000-0000-0000-00000060a002');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-000000006001', '00000000-0000-0000-0000-00000060a002');
select pg_temp.act('00000000-0000-0000-0000-00000060a003');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-000000006001', '00000000-0000-0000-0000-00000060a003');

-- Group posts by members (the backend writes as the author) -------------------------------------
select pg_temp.act('00000000-0000-0000-0000-00000060a002');
select lives_ok(
  $$ insert into public.posts (id, author_id, group_id, caption) values
       ('00000000-0000-0000-0000-0000006000f1', '00000000-0000-0000-0000-00000060a002', '00000000-0000-0000-0000-000000006001', 'Pazar yürüyüşü?') $$,
  'a member posts to the group''s feed');
select ok(private.can_manage_post('00000000-0000-0000-0000-0000006000f1'), 'its author manages it');
select pg_temp.act('00000000-0000-0000-0000-00000060a003');
select ok(not private.can_manage_post('00000000-0000-0000-0000-0000006000f1'), 'another member does not');
select pg_temp.act('00000000-0000-0000-0000-00000060a001');
select ok(private.can_manage_post('00000000-0000-0000-0000-0000006000f1'), 'the owner (posts.publish) does');
select pg_temp.act('00000000-0000-0000-0000-00000060a009');
select throws_ok(
  $$ insert into public.posts (author_id, group_id, caption) values
       ('00000000-0000-0000-0000-00000060a009', '00000000-0000-0000-0000-000000006001', 'x') $$,
  'P0001', 'post_forbidden', 'a stranger cannot post to a group');

-- Comments: whoever sees the post ---------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-00000060a002');
insert into public.posts (id, author_id, caption) values ('00000000-0000-0000-0000-0000006000f2', '00000000-0000-0000-0000-00000060a002', 'Kişisel');
select pg_temp.act('00000000-0000-0000-0000-00000060a009');
set local role authenticated;
select lives_ok(
  $$ insert into public.comments (post_id, author_id, body) values
       ('00000000-0000-0000-0000-0000006000f2', '00000000-0000-0000-0000-00000060a009', 'Güzel!') $$,
  'anyone who sees a personal post comments on it');
reset role;
select pg_temp.act('00000000-0000-0000-0000-00000060a002');
update public.posts set comments_disabled = true where id = '00000000-0000-0000-0000-0000006000f2';
select pg_temp.act('00000000-0000-0000-0000-00000060a009');
set local role authenticated;
select throws_ok(
  $$ insert into public.comments (post_id, author_id, body) values
       ('00000000-0000-0000-0000-0000006000f2', '00000000-0000-0000-0000-00000060a009', 'Bir daha') $$,
  'P0001', 'comments_disabled', 'the owner can still turn comments off');
reset role;

-- The free plan ---------------------------------------------------------------------------------
select is((select (max_members, monthly_events)::text from public.plans where slug = 'free'), '(100,4)', 'the free plan: 100 members, 4 events a month');

select * from finish();
rollback;
