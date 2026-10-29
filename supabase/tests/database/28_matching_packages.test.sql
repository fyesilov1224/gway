begin;
create extension if not exists pgtap with schema extensions;

select plan(22);

-- These tests check life without packages; the welcome trial (0050) would open every one.
alter table public.group_members disable trigger group_members_welcome_trial;

-- k1 and k2 match in friend mode; neither has a package yet. a1 is a platform admin who grants packages.
insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-0000000ff001', 'k1@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000ff002', 'k2@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000ff0a1', 'ka@test.local', 'authenticated', 'authenticated');
insert into public.profiles (id, username, display_name) values
  ('00000000-0000-0000-0000-0000000ff001', 'pkg_one', 'Bir'),
  ('00000000-0000-0000-0000-0000000ff002', 'pkg_two', 'İki'),
  ('00000000-0000-0000-0000-0000000ff0a1', 'pkg_admin', 'Yönetici');
insert into public.platform_staff (user_id, role) values ('00000000-0000-0000-0000-0000000ff0a1', 'admin');

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;

select pg_temp.act('00000000-0000-0000-0000-0000000ff001');
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id)
values ('00000000-0000-0000-0000-0000000ff0c1', 'paket.grup', 'Paket Grubu', 'music', 'open', '00000000-0000-0000-0000-0000000ff001');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-0000000ff0c1', '00000000-0000-0000-0000-0000000ff001');
insert into public.match_profiles (user_id, birth_date, gender, province, friend, consent_version)
values ('00000000-0000-0000-0000-0000000ff001', date '1995-05-05', 'woman', 34, true, 'v1');
select pg_temp.act('00000000-0000-0000-0000-0000000ff002');
insert into public.group_follows (user_id, group_id) values ('00000000-0000-0000-0000-0000000ff002', '00000000-0000-0000-0000-0000000ff0c1');
insert into public.match_profiles (user_id, birth_date, gender, province, friend, consent_version)
values ('00000000-0000-0000-0000-0000000ff002', date '1992-02-02', 'man', 34, true, 'v1');
reset role;

insert into public.match_photos (user_id, path, position)
select u::uuid, u || '/' || n || '.jpg', n
from unnest(array['00000000-0000-0000-0000-0000000ff001', '00000000-0000-0000-0000-0000000ff002']) u, generate_series(0, 1) n;
insert into public.match_swipes (swiper_id, target_id, mode, liked) values
  ('00000000-0000-0000-0000-0000000ff001', '00000000-0000-0000-0000-0000000ff002', 'friend', true),
  ('00000000-0000-0000-0000-0000000ff002', '00000000-0000-0000-0000-0000000ff001', 'friend', true);
insert into public.matches (id, user_a, user_b, mode)
values ('00000000-0000-0000-0000-0000000ffd01', '00000000-0000-0000-0000-0000000ff001', '00000000-0000-0000-0000-0000000ff002', 'friend');

-- Free: a match without a face ---------------------------------------------------------------------
select is(
  (select count(*)::int from public.notifications where match_id = '00000000-0000-0000-0000-0000000ffd01' and actor_id <> recipient_id),
  0, 'the match notice names nobody'
);

set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000ff001');
select is((select m - 'matched_at' - 'modes' from public.my_matches() m), '{"locked": true}'::jsonb,
  'a free user sees only that she matched');
select is((select count(*)::int from public.matches), 0, 'and cannot read the pair');
select is((public.match_status())->'features', '[]'::jsonb, 'she has no features');
reset role;
select pg_temp.act('00000000-0000-0000-0000-0000000ff001');
select private.open_direct_conversation('00000000-0000-0000-0000-0000000ff002');
select is(
  private.message_blocker('00000000-0000-0000-0000-0000000ff001',
    (select id from public.conversations where user_a = '00000000-0000-0000-0000-0000000ff001' and user_b = '00000000-0000-0000-0000-0000000ff002')),
  'match_chat_locked', 'writing to a match needs the chat package'
);

-- Packages ---------------------------------------------------------------------
create function pg_temp.grant_package(uid text, plan text) returns void language sql as $$
  select pg_temp.act('00000000-0000-0000-0000-0000000ff0a1');
  insert into public.user_subscriptions (user_id, plan_slug, granted_by, grant_reason, starts_at, ends_at)
  values (uid::uuid, plan, '00000000-0000-0000-0000-0000000ff0a1', 'test', now() - interval '1 minute', now() + interval '1 day');
$$;

select pg_temp.grant_package('00000000-0000-0000-0000-0000000ff001', 'matching_reveal');
select ok(private.has_matching_feature('00000000-0000-0000-0000-0000000ff001', 'reveal'), 'Eşleşmelerim opens reveal');
select ok(not private.has_matching_feature('00000000-0000-0000-0000-0000000ff001', 'chat'), 'but not chat');

set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000ff001');
select is((select m->>'username' from public.my_matches() m), 'pkg_two', 'with reveal she sees who it is');
select is((select count(*)::int from public.matches), 1, 'and reads the pair');
select is((select count(*)::int from public.match_photos where user_id = '00000000-0000-0000-0000-0000000ff002'), 2, 'and the photos');
select is((public.match_status())->'packages' ? 'matching_reveal', true, 'the status lists the package');
reset role;

select pg_temp.grant_package('00000000-0000-0000-0000-0000000ff001', 'matching_chat');
select is(
  private.message_blocker('00000000-0000-0000-0000-0000000ff001',
    (select id from public.conversations where user_a = '00000000-0000-0000-0000-0000000ff001' and user_b = '00000000-0000-0000-0000-0000000ff002')),
  null, 'with the chat package she writes'
);
select is(
  private.message_blocker('00000000-0000-0000-0000-0000000ff002',
    (select id from public.conversations where user_a = '00000000-0000-0000-0000-0000000ff001' and user_b = '00000000-0000-0000-0000-0000000ff002')),
  'match_chat_locked', 'he still needs his own to answer'
);

select pg_temp.grant_package('00000000-0000-0000-0000-0000000ff002', 'matching_super');
select ok(private.has_matching_feature('00000000-0000-0000-0000-0000000ff002', 'super')
  and not private.has_matching_feature('00000000-0000-0000-0000-0000000ff002', 'boost'), 'each package opens only its feature');
select is(private.match_super_likes_left('00000000-0000-0000-0000-0000000ff002'), 5, 'Süper Beğeni gives five a day');
select pg_temp.grant_package('00000000-0000-0000-0000-0000000ff002', 'matching_premium');
select ok(private.has_matching_feature('00000000-0000-0000-0000-0000000ff002', 'chat')
  and private.has_matching_feature('00000000-0000-0000-0000-0000000ff002', 'boost'), 'Hepsi Bir Arada opens everything');

-- Ending the match ends the follows too ---------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000ff001');
insert into public.follows (follower_id, followee_id) values ('00000000-0000-0000-0000-0000000ff001', '00000000-0000-0000-0000-0000000ff002');
select pg_temp.act('00000000-0000-0000-0000-0000000ff002');
insert into public.follows (follower_id, followee_id) values ('00000000-0000-0000-0000-0000000ff002', '00000000-0000-0000-0000-0000000ff001');
set local role authenticated;
select is(public.can_message('00000000-0000-0000-0000-0000000ff001'), true, 'a match can be messaged');
reset role;

-- Matched as friends and as a couple: one entry with both modes; leaving one keeps the other and the follows.
insert into public.matches (id, user_a, user_b, mode)
values ('00000000-0000-0000-0000-0000000ffd02', '00000000-0000-0000-0000-0000000ff001', '00000000-0000-0000-0000-0000000ff002', 'dating');
set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000ff001');
select is((select array_agg(x->>'mode') from public.my_matches() m, jsonb_array_elements(m->'modes') x), array['friend', 'dating'],
  'two modes with the same person are one entry');
reset role;
update public.matches set ended_at = now(), ended_by = '00000000-0000-0000-0000-0000000ff001'
where id = '00000000-0000-0000-0000-0000000ffd02';
select is((select count(*)::int from public.follows
           where '00000000-0000-0000-0000-0000000ff001' in (follower_id, followee_id)
             and '00000000-0000-0000-0000-0000000ff002' in (follower_id, followee_id)), 2,
  'keeping only the friendship keeps the follows');
select pg_temp.act('00000000-0000-0000-0000-0000000ff001');
select is(
  private.message_blocker('00000000-0000-0000-0000-0000000ff001',
    (select id from public.conversations where user_a = '00000000-0000-0000-0000-0000000ff001' and user_b = '00000000-0000-0000-0000-0000000ff002')),
  null, 'and the chat'
);

update public.matches set ended_at = now(), ended_by = '00000000-0000-0000-0000-0000000ff002'
where id = '00000000-0000-0000-0000-0000000ffd01';
select is((select count(*)::int from public.follows
           where '00000000-0000-0000-0000-0000000ff001' in (follower_id, followee_id)
             and '00000000-0000-0000-0000-0000000ff002' in (follower_id, followee_id)), 0,
  'ending the match ends the follows both ways');
select is(
  private.message_blocker('00000000-0000-0000-0000-0000000ff002',
    (select id from public.conversations where user_a = '00000000-0000-0000-0000-0000000ff001' and user_b = '00000000-0000-0000-0000-0000000ff002')),
  'match_ended', 'and closes the chat'
);

select * from finish();
rollback;
