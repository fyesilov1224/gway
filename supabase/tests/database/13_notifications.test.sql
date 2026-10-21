begin;
create extension if not exists pgtap with schema extensions;

select plan(21);

-- n1 author (public), n2 fan, n3 private, n4 blocked by n1.
insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-0000000dd001', 'n1@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000dd002', 'n2@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000dd003', 'n3@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000dd004', 'n4@test.local', 'authenticated', 'authenticated');
insert into public.profiles (id, username, display_name, is_private) values
  ('00000000-0000-0000-0000-0000000dd001', 'notif_one', 'One', false),
  ('00000000-0000-0000-0000-0000000dd002', 'notif_two', 'Two', false),
  ('00000000-0000-0000-0000-0000000dd003', 'notif_three', 'Three', true),
  ('00000000-0000-0000-0000-0000000dd004', 'notif_four', 'Four', false);

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;

create function pg_temp.count_of(recipient text, kind text) returns int language sql as $$
  select count(*)::int from public.notifications where recipient_id = recipient::uuid and type = kind;
$$;

select pg_temp.act('00000000-0000-0000-0000-0000000dd001');
insert into public.blocks (blocker_id, blocked_id) values ('00000000-0000-0000-0000-0000000dd001', '00000000-0000-0000-0000-0000000dd004');
insert into public.posts (id, author_id, caption) values
  ('00000000-0000-0000-0000-0000000df001', '00000000-0000-0000-0000-0000000dd001', 'Merhaba @notif_two ve @notif_four @kimse_yok');

select is(pg_temp.count_of('00000000-0000-0000-0000-0000000dd002', 'mention'), 1, 'a caption mention notifies the account');
select is(pg_temp.count_of('00000000-0000-0000-0000-0000000dd004', 'mention'), 0, 'but never across a block');

-- Likes ------------------------------------------------------------------------------------------
set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000dd001');
insert into public.post_likes (post_id, user_id) values ('00000000-0000-0000-0000-0000000df001', '00000000-0000-0000-0000-0000000dd001');
select pg_temp.act('00000000-0000-0000-0000-0000000dd002');
insert into public.post_likes (post_id, user_id) values ('00000000-0000-0000-0000-0000000df001', '00000000-0000-0000-0000-0000000dd002');
reset role;
select is(pg_temp.count_of('00000000-0000-0000-0000-0000000dd001', 'like'), 1, 'a like notifies the author, liking your own post does not');
set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000dd002');
delete from public.post_likes where user_id = '00000000-0000-0000-0000-0000000dd002';
reset role;
select is(pg_temp.count_of('00000000-0000-0000-0000-0000000dd001', 'like'), 0, 'unliking takes the notification back');

-- Comments, replies, comment likes, mentions ----------------------------------------------------------
set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000dd002');
insert into public.comments (id, post_id, author_id, body) values
  ('00000000-0000-0000-0000-0000000de001', '00000000-0000-0000-0000-0000000df001', '00000000-0000-0000-0000-0000000dd002', 'Güzel!');
select pg_temp.act('00000000-0000-0000-0000-0000000dd001');
insert into public.comments (id, post_id, author_id, parent_id, body) values
  ('00000000-0000-0000-0000-0000000de002', '00000000-0000-0000-0000-0000000df001', '00000000-0000-0000-0000-0000000dd001',
   '00000000-0000-0000-0000-0000000de001', 'Teşekkürler @notif_three');
insert into public.comment_likes (comment_id, user_id) values ('00000000-0000-0000-0000-0000000de001', '00000000-0000-0000-0000-0000000dd001');
reset role;
select is(pg_temp.count_of('00000000-0000-0000-0000-0000000dd001', 'comment'), 1, 'a comment notifies the post author');
select is(pg_temp.count_of('00000000-0000-0000-0000-0000000dd002', 'reply'), 1, 'a reply notifies the comment author');
select is(pg_temp.count_of('00000000-0000-0000-0000-0000000dd003', 'mention'), 1, 'a comment mention notifies the account');
select is(pg_temp.count_of('00000000-0000-0000-0000-0000000dd002', 'comment_like'), 1, 'a comment like notifies its author');

set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000dd001');
delete from public.comments where id = '00000000-0000-0000-0000-0000000de001';
reset role;
select is(
  (select count(*)::int from public.notifications where comment_id in ('00000000-0000-0000-0000-0000000de001', '00000000-0000-0000-0000-0000000de002')),
  0, 'deleting a comment removes its notifications'
);

-- Follows --------------------------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000dd002');
insert into public.follows (follower_id, followee_id) values ('00000000-0000-0000-0000-0000000dd002', '00000000-0000-0000-0000-0000000dd001');
insert into public.follow_requests (requester_id, target_id) values ('00000000-0000-0000-0000-0000000dd002', '00000000-0000-0000-0000-0000000dd003');
select is(pg_temp.count_of('00000000-0000-0000-0000-0000000dd001', 'follow'), 1, 'a follow notifies');
select is(pg_temp.count_of('00000000-0000-0000-0000-0000000dd003', 'follow_request'), 1, 'a request notifies the private account');

select pg_temp.act('00000000-0000-0000-0000-0000000dd003');
insert into public.follows (follower_id, followee_id) values ('00000000-0000-0000-0000-0000000dd002', '00000000-0000-0000-0000-0000000dd003');
delete from public.follow_requests where requester_id = '00000000-0000-0000-0000-0000000dd002';
select is(pg_temp.count_of('00000000-0000-0000-0000-0000000dd002', 'follow_accepted'), 1, 'accepting tells the requester');
select is(pg_temp.count_of('00000000-0000-0000-0000-0000000dd003', 'follow_request'), 0, 'and clears the request notification');

select pg_temp.act('00000000-0000-0000-0000-0000000dd002');
delete from public.follows where follower_id = '00000000-0000-0000-0000-0000000dd002' and followee_id = '00000000-0000-0000-0000-0000000dd001';
select is(pg_temp.count_of('00000000-0000-0000-0000-0000000dd001', 'follow'), 0, 'unfollowing takes the follow notification back');

-- Access -----------------------------------------------------------------------------------------------
set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000dd001');
select is((select count(*)::int from public.notifications where recipient_id <> '00000000-0000-0000-0000-0000000dd001'), 0,
  'users read only their own notifications');
select is((select x->'actor'->>'username' from public.my_notifications() x where x->>'type' = 'comment'), null,
  'the comment notification left with its comment');
select pg_temp.act('00000000-0000-0000-0000-0000000dd002');
select is((select (x->>'type') || ':' || (x->'actor'->>'username') from public.my_notifications() x limit 1),
  'follow_accepted:notif_three', 'the newest notification comes first with its actor');
select lives_ok($$ update public.notifications set read_at = now() $$, 'users mark notifications read');
select is((select count(*)::int from public.notifications where read_at is null), 0, 'all read');
select throws_ok(
  $$ update public.notifications set type = 'like' $$,
  '42501', null, 'nothing but the read mark is writable'
);
select throws_ok(
  $$ insert into public.notifications (recipient_id, actor_id, type) values
       ('00000000-0000-0000-0000-0000000dd001', '00000000-0000-0000-0000-0000000dd002', 'follow') $$,
  '42501', null, 'clients cannot create notifications'
);
reset role;

select * from finish();
rollback;
