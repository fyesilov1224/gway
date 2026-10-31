begin;
create extension if not exists pgtap with schema extensions;

select plan(67);

-- p1 public author (group owner), p2 private author, p3 viewer (follows p1, member/follower of the group),
-- p4 blocked by p1, p5 stranger, m1 platform moderator.
insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-0000000cc001', 'p1@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000cc002', 'p2@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000cc003', 'p3@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000cc004', 'p4@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000cc005', 'p5@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000cc0a1', 'm1@test.local', 'authenticated', 'authenticated');
insert into public.platform_staff (user_id, role) values ('00000000-0000-0000-0000-0000000cc0a1', 'moderator');
insert into public.profiles (id, username, display_name, is_private) values
  ('00000000-0000-0000-0000-0000000cc001', 'feed_one', 'One', false),
  ('00000000-0000-0000-0000-0000000cc002', 'feed_two', 'Two', true),
  ('00000000-0000-0000-0000-0000000cc003', 'feed_three', 'Three', false),
  ('00000000-0000-0000-0000-0000000cc004', 'feed_four', 'Four', false),
  ('00000000-0000-0000-0000-0000000cc005', 'feed_five', 'Five', false);

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;

-- Graph: p3 follows p1; p1 blocks p4; p1 owns a group that p3 follows.
select pg_temp.act('00000000-0000-0000-0000-0000000cc003');
insert into public.follows (follower_id, followee_id) values ('00000000-0000-0000-0000-0000000cc003', '00000000-0000-0000-0000-0000000cc001');
select pg_temp.act('00000000-0000-0000-0000-0000000cc001');
insert into public.blocks (blocker_id, blocked_id) values ('00000000-0000-0000-0000-0000000cc001', '00000000-0000-0000-0000-0000000cc004');
insert into public.groups (id, handle, name, category_slug, owner_id)
values ('00000000-0000-0000-0000-0000000ce001', 'akis.grubu', 'Akış Grubu', 'nature', '00000000-0000-0000-0000-0000000cc001');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-0000000ce001', '00000000-0000-0000-0000-0000000cc001');
insert into public.group_follows (user_id, group_id) values ('00000000-0000-0000-0000-0000000cc003', '00000000-0000-0000-0000-0000000ce001');
-- Comments on a personal post take a relation (0034): p3 is p1's teammate, p5 matched with p1.
alter table public.teammates disable trigger teammates_guard;
insert into public.teammates (user_a, user_b) values ('00000000-0000-0000-0000-0000000cc001', '00000000-0000-0000-0000-0000000cc003');
alter table public.teammates enable trigger teammates_guard;
insert into public.matches (user_a, user_b, mode) values ('00000000-0000-0000-0000-0000000cc001', '00000000-0000-0000-0000-0000000cc005', 'friend');

-- Posts (backend writes) -------------------------------------------------------------------
select set_config('request.jwt.claims', '', true);
select throws_ok(
  $$ insert into public.posts (author_id, caption) values ('00000000-0000-0000-0000-0000000cc001', 'x') $$,
  'P0001', 'post_forbidden', 'a post needs its author as actor'
);
select pg_temp.act('00000000-0000-0000-0000-0000000cc003');
select throws_ok(
  $$ insert into public.posts (author_id, caption) values ('00000000-0000-0000-0000-0000000cc001', 'x') $$,
  'P0001', 'post_forbidden', 'nobody posts as someone else'
);
select throws_ok(
  $$ insert into public.posts (author_id, group_id, caption) values ('00000000-0000-0000-0000-0000000cc003', '00000000-0000-0000-0000-0000000ce001', 'x') $$,
  'P0001', 'post_forbidden', 'only publishers post for a group'
);

select pg_temp.act('00000000-0000-0000-0000-0000000cc001');
select lives_ok(
  $$ insert into public.posts (id, author_id, caption) values
       ('00000000-0000-0000-0000-0000000cf001', '00000000-0000-0000-0000-0000000cc001', '  Sabah yürüyüşü #Doğa #yuruyus #doğa @feed_three ') $$,
  'an author posts'
);
select is(
  (select array_agg(tag order by tag) from public.post_hashtags where post_id = '00000000-0000-0000-0000-0000000cf001'),
  array['doğa', 'yuruyus'], 'hashtags are extracted, lower case and distinct'
);
select throws_ok(
  $$ insert into public.post_media (post_id, position, kind, path, width, height)
     values ('00000000-0000-0000-0000-0000000cf001', 0, 'image', '00000000-0000-0000-0000-0000000cc003/x.jpg', 1080, 1350) $$,
  'P0001', 'media_forbidden', 'media must come from the author''s folder'
);
select lives_ok(
  $$ insert into public.post_media (post_id, position, kind, path, width, height, thumb_path) values
       ('00000000-0000-0000-0000-0000000cf001', 0, 'image', '00000000-0000-0000-0000-0000000cc001/a.jpg', 1080, 1350,
        '00000000-0000-0000-0000-0000000cc001/a_t.jpg');
     insert into public.post_media (post_id, position, kind, path, width, height, duration_ms, poster_path) values
       ('00000000-0000-0000-0000-0000000cf001', 1, 'video', '00000000-0000-0000-0000-0000000cc001/b.mp4', 1080, 1920, 15000,
        '00000000-0000-0000-0000-0000000cc001/b.jpg') $$,
  'a carousel with a photo and a video'
);
select throws_ok(
  $$ insert into public.post_media (post_id, position, kind, path, width, height, duration_ms)
     values ('00000000-0000-0000-0000-0000000cf001', 2, 'video', '00000000-0000-0000-0000-0000000cc001/c.mp4', 1080, 1920, 61000) $$,
  '23514', null, 'videos are at most 60 seconds'
);
select throws_ok(
  $$ insert into public.post_media (post_id, position, kind, path, width, height, thumb_path)
     values ('00000000-0000-0000-0000-0000000cf001', 2, 'image', '00000000-0000-0000-0000-0000000cc001/d.jpg', 10, 10,
             '00000000-0000-0000-0000-0000000cc003/d_t.jpg') $$,
  'P0001', 'media_forbidden', 'the small copy must come from the author''s folder too'
);
select throws_ok(
  $$ insert into public.post_media (post_id, position, kind, path, width, height, duration_ms, thumb_path)
     values ('00000000-0000-0000-0000-0000000cf001', 2, 'video', '00000000-0000-0000-0000-0000000cc001/e.mp4', 10, 10, 1000,
             '00000000-0000-0000-0000-0000000cc001/e_t.jpg') $$,
  '23514', null, 'only photos have a small copy'
);
select lives_ok(
  $$ insert into public.posts (id, author_id, group_id, caption) values
       ('00000000-0000-0000-0000-0000000cf002', '00000000-0000-0000-0000-0000000cc001', '00000000-0000-0000-0000-0000000ce001', 'Grup duyurusu') $$,
  'a publisher posts for the group'
);
select pg_temp.act('00000000-0000-0000-0000-0000000cc002');
insert into public.posts (id, author_id, caption, hide_like_count) values
  ('00000000-0000-0000-0000-0000000cf003', '00000000-0000-0000-0000-0000000cc002', 'Gizli hesaptan', true);

-- Visibility ----------------------------------------------------------------------------------
select set_config('request.jwt.claims', '', true);
set local role anon;
select is((select count(*)::int from public.posts where id = '00000000-0000-0000-0000-0000000cf001'), 1, 'public posts are public');
select is((select count(*)::int from public.post_media where post_id = '00000000-0000-0000-0000-0000000cf001'), 2, 'and so is their media');
select is((select count(*)::int from public.posts where id = '00000000-0000-0000-0000-0000000cf003'), 0, 'private accounts'' posts are not');
reset role;

set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000cc004');
select is((select count(*)::int from public.posts where author_id = '00000000-0000-0000-0000-0000000cc001' and group_id is null), 0,
  'a blocked user sees none of the blocker''s posts');
select throws_ok(
  $$ insert into public.post_likes (post_id, user_id) values ('00000000-0000-0000-0000-0000000cf001', '00000000-0000-0000-0000-0000000cc004') $$,
  'P0001', 'blocked', 'nor likes them'
);
select pg_temp.act('00000000-0000-0000-0000-0000000cc003');
select throws_ok(
  $$ insert into public.post_likes (post_id, user_id) values ('00000000-0000-0000-0000-0000000cf003', '00000000-0000-0000-0000-0000000cc003') $$,
  '42501', null, 'nobody likes a post they cannot see'
);

-- Likes, comments, replies, saves ---------------------------------------------------------------------
select lives_ok(
  $$ insert into public.post_likes (post_id, user_id) values ('00000000-0000-0000-0000-0000000cf001', '00000000-0000-0000-0000-0000000cc003') $$,
  'a follower likes a post'
);
select throws_ok(
  $$ insert into public.post_likes (post_id, user_id) values ('00000000-0000-0000-0000-0000000cf001', '00000000-0000-0000-0000-0000000cc005') $$,
  '42501', null, 'nobody likes for someone else'
);
select is((select like_count from public.posts where id = '00000000-0000-0000-0000-0000000cf001'), 1, 'likes are counted');
select lives_ok(
  $$ insert into public.comments (id, post_id, author_id, body) values
       ('00000000-0000-0000-0000-0000000cd001', '00000000-0000-0000-0000-0000000cf001', '00000000-0000-0000-0000-0000000cc003', ' Harika! ') $$,
  'a teammate comments'
);
select throws_ok(
  $$ insert into public.comments (post_id, author_id, body) values
       ('00000000-0000-0000-0000-0000000cf003', '00000000-0000-0000-0000-0000000cc003', 'Merhaba') $$,
  '42501', null, 'nobody comments on a post they cannot see'
);
select pg_temp.act('00000000-0000-0000-0000-0000000cc005');
select lives_ok(
  $$ insert into public.comments (id, post_id, author_id, parent_id, body) values
       ('00000000-0000-0000-0000-0000000cd002', '00000000-0000-0000-0000-0000000cf001', '00000000-0000-0000-0000-0000000cc005',
        '00000000-0000-0000-0000-0000000cd001', 'Katılıyorum') $$,
  'a match replies'
);
select lives_ok(
  $$ insert into public.comments (id, post_id, author_id, parent_id, body) values
       ('00000000-0000-0000-0000-0000000cd003', '00000000-0000-0000-0000-0000000cf001', '00000000-0000-0000-0000-0000000cc005',
        '00000000-0000-0000-0000-0000000cd002', 'Yanıta yanıt') $$,
  'a reply to a reply is accepted'
);
reset role;
select is((select parent_id from public.comments where id = '00000000-0000-0000-0000-0000000cd003'),
  '00000000-0000-0000-0000-0000000cd001'::uuid, 'replies attach to the top-level comment');
select is((select comment_count from public.posts where id = '00000000-0000-0000-0000-0000000cf001'), 3, 'comments and replies are counted');
select is((select body from public.comments where id = '00000000-0000-0000-0000-0000000cd001'), 'Harika!', 'comment text is trimmed');

set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000cc003');
select lives_ok(
  $$ insert into public.comment_likes (comment_id, user_id) values ('00000000-0000-0000-0000-0000000cd002', '00000000-0000-0000-0000-0000000cc003') $$,
  'comments can be liked'
);
select is((select like_count from public.comments where id = '00000000-0000-0000-0000-0000000cd002'), 1, 'comment likes are counted');
select lives_ok(
  $$ insert into public.saved_posts (user_id, post_id) values ('00000000-0000-0000-0000-0000000cc003', '00000000-0000-0000-0000-0000000cf001') $$,
  'a user saves a post'
);
select is((select count(*)::int from public.saved_feed()), 1, 'saved posts are listed for their owner');
select pg_temp.act('00000000-0000-0000-0000-0000000cc005');
select is((select count(*)::int from public.saved_posts), 0, 'saves are private');
select is(
  (select count(*)::int from public.comments where id = '00000000-0000-0000-0000-0000000cd001'), 1, 'comments are visible with the post'
);
delete from public.comments where id = '00000000-0000-0000-0000-0000000cd001';
select is(
  (select count(*)::int from public.comments where id = '00000000-0000-0000-0000-0000000cd001'), 1, 'others cannot delete a comment'
);
select pg_temp.act('00000000-0000-0000-0000-0000000cc001');
select lives_ok(
  $$ delete from public.comments where id = '00000000-0000-0000-0000-0000000cd001' $$,
  'the post author deletes a comment on their post'
);
reset role;
select is((select comment_count from public.posts where id = '00000000-0000-0000-0000-0000000cf001'), 0,
  'a deleted comment takes its replies and their count with it');

-- Hidden like counts --------------------------------------------------------------------------------
set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000cc002');
select is((select (post_card(p)->>'like_count') from public.posts p where id = '00000000-0000-0000-0000-0000000cf003'), '0',
  'the author sees a hidden like count');
select pg_temp.act('00000000-0000-0000-0000-0000000cc003');
select is((select count(*)::int from public.post_by_id('00000000-0000-0000-0000-0000000cf003')), 0, 'non-followers do not get the private post');
reset role;

-- Comments off, edits, removal ------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000cc001');
update public.posts set comments_disabled = true, caption = 'Yeni açıklama #sabah' where id = '00000000-0000-0000-0000-0000000cf001';
select is(
  (select (edited_at is not null, (select array_agg(tag) from public.post_hashtags h where h.post_id = p.id))::text
   from public.posts p where id = '00000000-0000-0000-0000-0000000cf001'),
  '(t,{sabah})', 'an edit marks the post and refreshes hashtags'
);
select pg_temp.act('00000000-0000-0000-0000-0000000cc003');
select throws_ok(
  $$ insert into public.comments (post_id, author_id, body) values ('00000000-0000-0000-0000-0000000cf001', '00000000-0000-0000-0000-0000000cc003', 'kapalı mı?') $$,
  'P0001', 'comments_disabled', 'no comments when they are off'
);
select throws_ok(
  $$ update public.posts set caption = 'el koydum' where id = '00000000-0000-0000-0000-0000000cf001' $$,
  'P0001', 'post_forbidden', 'nobody edits someone else''s post'
);
select throws_ok(
  $$ update public.posts set like_count = 999 where id = '00000000-0000-0000-0000-0000000cf001' $$,
  'P0001', 'post_immutable', 'counters are not writable'
);
select throws_ok(
  $$ update public.posts set removed_at = now(), removed_reason = 'spam' where id = '00000000-0000-0000-0000-0000000cf002' $$,
  'P0001', 'post_removal_forbidden', 'only platform moderators remove posts'
);
select pg_temp.act('00000000-0000-0000-0000-0000000cc0a1');
select lives_ok(
  $$ update public.posts set removed_at = now(), removed_reason = 'Kural ihlali' where id = '00000000-0000-0000-0000-0000000cf002' $$,
  'a platform moderator removes a post'
);
select is((select removed_by from public.posts where id = '00000000-0000-0000-0000-0000000cf002'),
  '00000000-0000-0000-0000-0000000cc0a1'::uuid, 'the remover is recorded');
set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000cc003');
select is((select count(*)::int from public.posts where id = '00000000-0000-0000-0000-0000000cf002'), 0, 'removed posts disappear');
select pg_temp.act('00000000-0000-0000-0000-0000000cc0a1');
select is((select count(*)::int from public.posts where id = '00000000-0000-0000-0000-0000000cf002'), 1, 'staff still see them');
reset role;
select pg_temp.act('00000000-0000-0000-0000-0000000cc0a1');
update public.posts set removed_at = null, removed_reason = null where id = '00000000-0000-0000-0000-0000000cf002';

-- Feeds and search ------------------------------------------------------------------------------------
set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000cc003');
select is(
  (select array_agg(x->>'id' order by x->>'id') from public.home_feed() x),
  array['00000000-0000-0000-0000-0000000cf001', '00000000-0000-0000-0000-0000000cf002'],
  'home feed: followed user and followed group'
);
select is((select count(*)::int from public.explore_posts() x where x->>'id' = '00000000-0000-0000-0000-0000000cf001'), 0,
  'explore skips followed accounts');
select pg_temp.act('00000000-0000-0000-0000-0000000cc005');
select is((select count(*)::int from public.explore_posts() x where x->>'id' = '00000000-0000-0000-0000-0000000cf001'), 1,
  'explore shows public posts to strangers');
select is((select count(*)::int from public.hashtag_posts('Sabah')), 1, 'hashtag pages are case-insensitive');
select is((select tag from public.search_hashtags('#sab')), 'sabah', 'hashtag search by prefix');
select is((select username from public.search_profiles('@feed_o')), 'feed_one', 'account search by username prefix');
select is((select count(*)::int from public.user_posts('00000000-0000-0000-0000-0000000cc001')), 1, 'profile grid has personal posts only');
select is((select count(*)::int from public.group_posts('00000000-0000-0000-0000-0000000ce001')), 1, 'group page has the group''s posts');
select is((select post_count from public.profile_social('00000000-0000-0000-0000-0000000cc002')), 1::bigint,
  'counts are public even for private accounts');

-- Stories -------------------------------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000cc001');
select throws_ok(
  $$ insert into public.stories (id, author_id, kind, path, width, height)
     values (gen_random_uuid(), '00000000-0000-0000-0000-0000000cc001', 'image', '00000000-0000-0000-0000-0000000cc003/s.jpg', 1080, 1920) $$,
  '23514', null, 'stories come from the author''s folder'
);
select lives_ok(
  $$ insert into public.stories (id, author_id, kind, path, width, height)
     values ('00000000-0000-0000-0000-0000000cb001', '00000000-0000-0000-0000-0000000cc001', 'image', '00000000-0000-0000-0000-0000000cc001/s.jpg', 1080, 1920) $$,
  'a user shares a story'
);
select pg_temp.act('00000000-0000-0000-0000-0000000cc003');
select is((select (story_count, has_unseen)::text from public.story_tray() where user_id = '00000000-0000-0000-0000-0000000cc001'),
  '(1,t)', 'followers see it in the tray as unseen');
select lives_ok(
  $$ insert into public.story_views (story_id, viewer_id) values ('00000000-0000-0000-0000-0000000cb001', '00000000-0000-0000-0000-0000000cc003') $$,
  'a follower views the story'
);
select is((select has_unseen from public.story_tray() where user_id = '00000000-0000-0000-0000-0000000cc001'), false, 'then it is seen');
select pg_temp.act('00000000-0000-0000-0000-0000000cc005');
select is((select count(*)::int from public.story_views), 0, 'viewers are visible to the author only');
select pg_temp.act('00000000-0000-0000-0000-0000000cc001');
select is((select count(*)::int from public.story_views), 1, 'the author sees who viewed');
reset role;
update public.stories set expires_at = now() - interval '1 minute' where id = '00000000-0000-0000-0000-0000000cb001';
set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000cc003');
select is((select count(*)::int from public.stories where id = '00000000-0000-0000-0000-0000000cb001'), 0, 'expired stories disappear');
select pg_temp.act('00000000-0000-0000-0000-0000000cc001');
select lives_ok(
  $$ insert into public.highlights (id, owner_id, title) values ('00000000-0000-0000-0000-0000000ca001', '00000000-0000-0000-0000-0000000cc001', 'Yürüyüşler');
     insert into public.highlight_stories (highlight_id, story_id) values ('00000000-0000-0000-0000-0000000ca001', '00000000-0000-0000-0000-0000000cb001') $$,
  'the author keeps the archived story in a highlight'
);
select pg_temp.act('00000000-0000-0000-0000-0000000cc003');
select is((select count(*)::int from public.stories where id = '00000000-0000-0000-0000-0000000cb001'), 1, 'highlighted stories stay visible');
reset role;

-- Account deletion removes personal posts ----------------------------------------------------------------
delete from auth.users where id = '00000000-0000-0000-0000-0000000cc002';
select is((select count(*)::int from public.posts where id = '00000000-0000-0000-0000-0000000cf003'), 0, 'personal posts go with the account');

select * from finish();
rollback;
