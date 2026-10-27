begin;
create extension if not exists pgtap with schema extensions;

select plan(5);

-- u1 posts publicly, u2 reacts the way the app does (PostgREST upsert), u3 has a private post u2 cannot see.
insert into auth.users (id, email, aud, role)
select ('00000000-0000-0000-0000-0000000ec10' || i)::uuid, 'up' || i || '@test.local', 'authenticated', 'authenticated'
from generate_series(1, 3) i;
insert into public.profiles (id, username, display_name, is_private)
select ('00000000-0000-0000-0000-0000000ec10' || i)::uuid, 'upsert_user' || i, 'Upsert ' || i, i = 3
from generate_series(1, 3) i;

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;

-- Posts are written by the backend as their author.
select pg_temp.act('00000000-0000-0000-0000-0000000ec101');
insert into public.posts (id, author_id, caption) values ('00000000-0000-0000-0000-0000000ed001', '00000000-0000-0000-0000-0000000ec101', 'Açık');
select pg_temp.act('00000000-0000-0000-0000-0000000ec103');
insert into public.posts (id, author_id, caption) values ('00000000-0000-0000-0000-0000000ed002', '00000000-0000-0000-0000-0000000ec103', 'Gizli');

-- What the app sends: upsert(onConflict: 'post_id,user_id').
create function pg_temp.react(post text, emoji text) returns void language sql as $$
  insert into public.post_reactions (post_id, user_id, emoji) values (post::uuid, '00000000-0000-0000-0000-0000000ec102', emoji)
  on conflict (post_id, user_id) do update set post_id = excluded.post_id, user_id = excluded.user_id, emoji = excluded.emoji;
$$;

set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000ec102');
select lives_ok($$ select pg_temp.react('00000000-0000-0000-0000-0000000ed001', '🔥') $$, 'the app''s upsert leaves a reaction');
select lives_ok($$ select pg_temp.react('00000000-0000-0000-0000-0000000ed001', '😍') $$, 'and changes it');
select is((select emoji from public.post_reactions where post_id = '00000000-0000-0000-0000-0000000ed001'), '😍', 'one reaction, the new emoji');
select throws_ok($$ select pg_temp.react('00000000-0000-0000-0000-0000000ed002', '🔥') $$,
  '42501', null, 'still not on a post the person cannot see');
select throws_ok(
  $$ update public.post_reactions set post_id = '00000000-0000-0000-0000-0000000ed002'
     where post_id = '00000000-0000-0000-0000-0000000ed001' and user_id = '00000000-0000-0000-0000-0000000ec102' $$,
  'P0001', 'reaction_immutable', 'a reaction does not move to another post');

select * from finish();
rollback;
