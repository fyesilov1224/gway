begin;
create extension if not exists pgtap with schema extensions;

select plan(9);

-- f1 woman looking for men, f2 man looking for women; both follow one group.
insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-0000000ff001', 'fx1@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000ff002', 'fx2@test.local', 'authenticated', 'authenticated');
insert into public.profiles (id, username, display_name) values
  ('00000000-0000-0000-0000-0000000ff001', 'fix_one', 'Bir'),
  ('00000000-0000-0000-0000-0000000ff002', 'fix_two', 'İki');

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;

select pg_temp.act('00000000-0000-0000-0000-0000000ff001');
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id)
values ('00000000-0000-0000-0000-0000000ff0c1', 'fix.grup', 'Düzeltme Grubu', 'music', 'open', '00000000-0000-0000-0000-0000000ff001');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-0000000ff0c1', '00000000-0000-0000-0000-0000000ff001');
insert into public.match_profiles (user_id, birth_date, gender, province, friend, dating, interested_in, consent_version)
values ('00000000-0000-0000-0000-0000000ff001', date '1995-05-05', 'woman', 34, true, true, '{man}', 'v1');

select pg_temp.act('00000000-0000-0000-0000-0000000ff002');
insert into public.group_follows (user_id, group_id) values ('00000000-0000-0000-0000-0000000ff002', '00000000-0000-0000-0000-0000000ff0c1');
insert into public.match_profiles (user_id, birth_date, gender, province, friend, dating, interested_in, consent_version)
values ('00000000-0000-0000-0000-0000000ff002', date '1992-02-02', 'man', 34, true, true, '{woman}', 'v1');
reset role;

insert into public.match_photos (user_id, path, position)
select u::uuid, u || '/' || n || '.jpg', n
from unnest(array['00000000-0000-0000-0000-0000000ff001', '00000000-0000-0000-0000-0000000ff002']) u, generate_series(0, 1) n;

-- The deck rule is not open to users ------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000ff001');
set local role authenticated;
select throws_ok(
  $$ select private.match_in_deck('00000000-0000-0000-0000-0000000ff001', '00000000-0000-0000-0000-0000000ff002', 'dating') $$,
  '42501', null, 'users cannot ask who is in someone''s deck');
reset role;

-- Who is in the deck ------------------------------------------------------------------------
select ok(private.match_in_deck('00000000-0000-0000-0000-0000000ff001', '00000000-0000-0000-0000-0000000ff002', 'dating'),
  'someone not swiped yet is in the deck');

-- The backend writes swipes.
insert into public.match_swipes (swiper_id, target_id, mode, liked, super)
values ('00000000-0000-0000-0000-0000000ff001', '00000000-0000-0000-0000-0000000ff002', 'dating', true, true),
       ('00000000-0000-0000-0000-0000000ff001', '00000000-0000-0000-0000-0000000ff002', 'friend', false, false);

select ok(not private.match_in_deck('00000000-0000-0000-0000-0000000ff001', '00000000-0000-0000-0000-0000000ff002', 'dating'),
  'someone liked is not in the deck again');
select ok(not private.match_in_deck('00000000-0000-0000-0000-0000000ff001', '00000000-0000-0000-0000-0000000ff002', 'friend'),
  'someone passed recently is not in the deck again');
update public.match_swipes set created_at = now() - interval '91 days'
where swiper_id = '00000000-0000-0000-0000-0000000ff001' and mode = 'friend';
select ok(private.match_in_deck('00000000-0000-0000-0000-0000000ff001', '00000000-0000-0000-0000-0000000ff002', 'friend'),
  'a pass is forgotten after 90 days');

-- A super like keeps the free likes ---------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000ff001');
select is(private.match_likes_left(), (select daily_free_likes from public.matching_settings),
  'a super like does not use a free like');

-- "Seni beğenenler" forgets an old pass like the deck does -----------------------------------
insert into public.match_swipes (swiper_id, target_id, mode, liked)
values ('00000000-0000-0000-0000-0000000ff002', '00000000-0000-0000-0000-0000000ff001', 'friend', true);
select is((select count(*)::int from private.match_admirers_of('00000000-0000-0000-0000-0000000ff001', 'friend')), 1,
  'someone passed more than 90 days ago who liked you waits again');

-- A super like's notification goes with its swipe --------------------------------------------
select is((select count(*)::int from public.notifications
           where recipient_id = '00000000-0000-0000-0000-0000000ff002' and type = 'match_super_liked'), 1,
  'a super like tells the person');
delete from public.match_swipes where swiper_id = '00000000-0000-0000-0000-0000000ff001' and mode = 'dating';
select is((select count(*)::int from public.notifications
           where recipient_id = '00000000-0000-0000-0000-0000000ff002' and type = 'match_super_liked'), 0,
  'the notification goes when the super like is deleted');

select * from finish();
rollback;
