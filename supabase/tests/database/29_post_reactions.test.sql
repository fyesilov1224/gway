begin;
create extension if not exists pgtap with schema extensions;

select plan(11);

-- r1 posts publicly; r2 is a stranger; r3 is r1's teammate; r4 is private and posts too.
insert into auth.users (id, email, aud, role)
select ('00000000-0000-0000-0000-0000000ea10' || i)::uuid, 'r' || i || '@test.local', 'authenticated', 'authenticated'
from generate_series(1, 4) i;
insert into public.profiles (id, username, display_name, is_private)
select ('00000000-0000-0000-0000-0000000ea10' || i)::uuid, 'react_user' || i, 'Tepki ' || i, i = 4
from generate_series(1, 4) i;
alter table public.teammates disable trigger teammates_guard;
insert into public.teammates (user_a, user_b) values ('00000000-0000-0000-0000-0000000ea101', '00000000-0000-0000-0000-0000000ea103');
alter table public.teammates enable trigger teammates_guard;

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;
create function pg_temp.card(post text) returns jsonb language sql as $$
  select public.post_card(p) from public.posts p where p.id = post::uuid;
$$;

-- Posts are written by the backend as their author.
select pg_temp.act('00000000-0000-0000-0000-0000000ea101');
insert into public.posts (id, author_id, caption) values ('00000000-0000-0000-0000-0000000eb001', '00000000-0000-0000-0000-0000000ea101', 'Gün batımı');
select pg_temp.act('00000000-0000-0000-0000-0000000ea104');
insert into public.posts (id, author_id, caption) values ('00000000-0000-0000-0000-0000000eb002', '00000000-0000-0000-0000-0000000ea104', 'Gizli');

set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000ea102');
select is((pg_temp.card('00000000-0000-0000-0000-0000000eb001'))->>'can_comment', 'false', 'a stranger may not comment');
select lives_ok(
  $$ insert into public.post_reactions (post_id, user_id, emoji) values ('00000000-0000-0000-0000-0000000eb001', '00000000-0000-0000-0000-0000000ea102', '🔥') $$,
  'but leaves an emoji'
);
select throws_ok(
  $$ insert into public.post_reactions (post_id, user_id, emoji) values ('00000000-0000-0000-0000-0000000eb001', '00000000-0000-0000-0000-0000000ea102', '😂') $$,
  '23505', null, 'one reaction per person'
);
select lives_ok(
  $$ update public.post_reactions set emoji = '😂' where post_id = '00000000-0000-0000-0000-0000000eb001' and user_id = '00000000-0000-0000-0000-0000000ea102' $$,
  'which can be changed'
);
select throws_ok(
  $$ update public.post_reactions set emoji = 'abc' where post_id = '00000000-0000-0000-0000-0000000eb001' and user_id = '00000000-0000-0000-0000-0000000ea102' $$,
  '23514', null, 'only the offered emojis'
);
select throws_ok(
  $$ insert into public.post_reactions (post_id, user_id, emoji) values ('00000000-0000-0000-0000-0000000eb001', '00000000-0000-0000-0000-0000000ea103', '👏') $$,
  '42501', null, 'nobody reacts for someone else'
);
select throws_ok(
  $$ insert into public.post_reactions (post_id, user_id, emoji) values ('00000000-0000-0000-0000-0000000eb002', '00000000-0000-0000-0000-0000000ea102', '👏') $$,
  '42501', null, 'nor on a post they cannot see'
);

select pg_temp.act('00000000-0000-0000-0000-0000000ea103');
select is((pg_temp.card('00000000-0000-0000-0000-0000000eb001'))->>'can_comment', 'true', 'a teammate may comment');
insert into public.post_reactions (post_id, user_id, emoji) values ('00000000-0000-0000-0000-0000000eb001', '00000000-0000-0000-0000-0000000ea103', '😂');
select is((pg_temp.card('00000000-0000-0000-0000-0000000eb001'))->'reactions', '{"😂": 2}'::jsonb, 'the card counts the reactions');
select is((pg_temp.card('00000000-0000-0000-0000-0000000eb001'))->>'my_reaction', '😂', 'and shows the viewer''s own');
delete from public.post_reactions where post_id = '00000000-0000-0000-0000-0000000eb001';
select is((pg_temp.card('00000000-0000-0000-0000-0000000eb001'))->'reactions', '{"😂": 1}'::jsonb, 'each person removes only their own');

select * from finish();
rollback;
