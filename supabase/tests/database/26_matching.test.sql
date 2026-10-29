begin;
create extension if not exists pgtap with schema extensions;

select plan(27);

-- These tests check life without packages; the welcome trial (0050) would open every one.
alter table public.group_members disable trigger group_members_welcome_trial;

-- m1 woman looking for men, m2 man looking for women (both in g1), m3 shares no group, m4 is too young.
insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-0000000fb001', 'm1@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000fb002', 'm2@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000fb003', 'm3@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000fb004', 'm4@test.local', 'authenticated', 'authenticated');
insert into public.profiles (id, username, display_name, is_private) values
  ('00000000-0000-0000-0000-0000000fb001', 'match_one', 'Bir', false),
  ('00000000-0000-0000-0000-0000000fb002', 'match_two', 'İki', true),
  ('00000000-0000-0000-0000-0000000fb003', 'match_three', 'Üç', false),
  ('00000000-0000-0000-0000-0000000fb004', 'match_four', 'Dört', false);

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;

select pg_temp.act('00000000-0000-0000-0000-0000000fb001');
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id)
values ('00000000-0000-0000-0000-0000000fc001', 'eslesme.grup', 'Eşleşme Grubu', 'music', 'open', '00000000-0000-0000-0000-0000000fb001');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-0000000fc001', '00000000-0000-0000-0000-0000000fb001');
select pg_temp.act('00000000-0000-0000-0000-0000000fb002');
insert into public.group_follows (user_id, group_id) values ('00000000-0000-0000-0000-0000000fb002', '00000000-0000-0000-0000-0000000fc001');

-- Profiles (the users' own writes) ---------------------------------------------------------------------
set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000fb004');
select throws_ok(
  $$ insert into public.match_profiles (user_id, birth_date, gender, province, consent_version)
     values ('00000000-0000-0000-0000-0000000fb004', current_date - interval '17 years', 'man', 34, 'v1') $$,
  'P0001', 'match_underage', 'nobody under 18 opens a matching profile'
);

select pg_temp.act('00000000-0000-0000-0000-0000000fb001');
select lives_ok(
  $$ insert into public.match_profiles (user_id, birth_date, gender, province, about, friend, dating, interested_in, consent_version)
     values ('00000000-0000-0000-0000-0000000fb001', date '1995-05-05', 'woman', 34, 'Gitar ve kamp.', true, true, '{man}', 'v1') $$,
  'an adult opens a matching profile with consent'
);
select throws_ok(
  $$ update public.match_profiles set suspended_until = null, suspension_reason = 'x' where user_id = '00000000-0000-0000-0000-0000000fb001' $$,
  '42501', null, 'the suspension is only the platform team''s'
);
select throws_ok(
  $$ insert into public.match_profiles (user_id, birth_date, gender, province, consent_version)
     values ('00000000-0000-0000-0000-0000000fb003', date '1990-01-01', 'man', 6, 'v1') $$,
  '42501', null, 'nobody opens a profile for someone else'
);
insert into public.match_photos (user_id, path, position) values
  ('00000000-0000-0000-0000-0000000fb001', '00000000-0000-0000-0000-0000000fb001/a.jpg', 0),
  ('00000000-0000-0000-0000-0000000fb001', '00000000-0000-0000-0000-0000000fb001/b.jpg', 1);

select pg_temp.act('00000000-0000-0000-0000-0000000fb002');
insert into public.match_profiles (user_id, birth_date, gender, province, friend, dating, interested_in, consent_version)
values ('00000000-0000-0000-0000-0000000fb002', date '1992-02-02', 'man', 34, true, true, '{woman}', 'v1');
select is((select count(*)::int from public.match_profiles where user_id = '00000000-0000-0000-0000-0000000fb001'), 0,
  'with one photo of his own, he does not see her yet');
insert into public.match_photos (user_id, path, position) values
  ('00000000-0000-0000-0000-0000000fb002', '00000000-0000-0000-0000-0000000fb002/a.jpg', 0),
  ('00000000-0000-0000-0000-0000000fb002', '00000000-0000-0000-0000-0000000fb002/b.jpg', 1);
select throws_ok(
  $$ insert into public.match_photos (user_id, path, position)
     values ('00000000-0000-0000-0000-0000000fb002', '00000000-0000-0000-0000-0000000fb001/x.jpg', 2) $$,
  '23514', null, 'photos stay in the owner''s folder'
);

select pg_temp.act('00000000-0000-0000-0000-0000000fb003');
insert into public.match_profiles (user_id, birth_date, gender, province, friend, dating, interested_in, consent_version)
values ('00000000-0000-0000-0000-0000000fb003', date '1993-03-03', 'man', 6, true, true, '{woman}', 'v1');
insert into public.match_photos (user_id, path, position) values
  ('00000000-0000-0000-0000-0000000fb003', '00000000-0000-0000-0000-0000000fb003/a.jpg', 0),
  ('00000000-0000-0000-0000-0000000fb003', '00000000-0000-0000-0000-0000000fb003/b.jpg', 1);

-- Pool and deck ---------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000fb002');
select is((select count(*)::int from public.match_photos where user_id = '00000000-0000-0000-0000-0000000fb001'), 2,
  'sharing a group, he sees her photos');
select is((select d->>'display_name' from public.match_deck('dating') d), 'Bir', 'she is in his dating deck');
select is((select d->'shared_groups'->0->>'name' from public.match_deck('friend') d), 'Eşleşme Grubu', 'the card names the shared group');
select is((select d->>'username' from public.match_deck('friend') d), null, 'the card has no username before a match');

select pg_temp.act('00000000-0000-0000-0000-0000000fb003');
select is((select count(*)::int from public.match_profiles where user_id <> '00000000-0000-0000-0000-0000000fb003'), 0,
  'without a shared group nobody is visible');
select is((select count(*)::int from public.match_deck('friend')), 0, 'and the deck is empty');

select pg_temp.act('00000000-0000-0000-0000-0000000fb001');
update public.match_profiles set interested_in = '{woman}' where user_id = '00000000-0000-0000-0000-0000000fb001';
select is((select count(*)::int from public.match_deck('dating')), 0, 'dating needs both preferences to fit');
select is((select count(*)::int from public.match_deck('friend')), 1, 'friends still see each other');
update public.match_profiles set interested_in = '{man}' where user_id = '00000000-0000-0000-0000-0000000fb001';
select is(public.match_likes_left(), 10, 'ten free likes a day');

select throws_ok(
  $$ insert into public.match_swipes (swiper_id, target_id, mode, liked)
     values ('00000000-0000-0000-0000-0000000fb001', '00000000-0000-0000-0000-0000000fb002', 'dating', true) $$,
  '42501', null, 'swipes are written only by the backend'
);
reset role;

-- A match (the backend writes) ---------------------------------------------------------------------
insert into public.match_swipes (swiper_id, target_id, mode, liked) values
  ('00000000-0000-0000-0000-0000000fb001', '00000000-0000-0000-0000-0000000fb002', 'dating', true),
  ('00000000-0000-0000-0000-0000000fb002', '00000000-0000-0000-0000-0000000fb001', 'dating', true);
insert into public.matches (id, user_a, user_b, mode)
values ('00000000-0000-0000-0000-0000000fd001', '00000000-0000-0000-0000-0000000fb001', '00000000-0000-0000-0000-0000000fb002', 'dating');
select is(
  (select count(*)::int from public.notifications where match_id = '00000000-0000-0000-0000-0000000fd001' and type = 'match_created'),
  2, 'both hear of the match'
);

set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000fb001');
select is(public.match_likes_left(), 9, 'a like counts against the day');
select is((select count(*)::int from public.match_deck('dating')), 0, 'a match leaves the deck');
select is((select (m->>'locked')::boolean from public.my_matches() m), true, 'without a package the match is locked (28_matching_packages)');
select pg_temp.act('00000000-0000-0000-0000-0000000fb003');
select is((select count(*)::int from public.matches), 0, 'others do not see the match');
reset role;

-- Chat between matches: no request even with a private profile ---------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000fb001');
select is(
  (private.open_direct_conversation('00000000-0000-0000-0000-0000000fb002'))->>'state', 'active',
  'a match opens an active chat although the profile is private'
);
select is(
  private.message_blocker('00000000-0000-0000-0000-0000000fb001',
    (select id from public.conversations where user_a = '00000000-0000-0000-0000-0000000fb001' and user_b = '00000000-0000-0000-0000-0000000fb002')),
  'match_chat_locked', 'writing to a match needs the chat package (28_matching_packages)'
);

-- Reports ---------------------------------------------------------------------
set local role authenticated;
select lives_ok(
  $$ insert into public.reports (reporter_id, target_type, target_id, reason)
     values ('00000000-0000-0000-0000-0000000fb001', 'match_profile', '00000000-0000-0000-0000-0000000fb002', 'harassment') $$,
  'a match can be reported to the platform team'
);
select pg_temp.act('00000000-0000-0000-0000-0000000fb003');
select throws_ok(
  $$ insert into public.reports (reporter_id, target_type, target_id, reason)
     values ('00000000-0000-0000-0000-0000000fb003', 'match_profile', '00000000-0000-0000-0000-0000000fb001', 'spam') $$,
  'P0001', 'report_target_invalid', 'nobody reports a profile they cannot see'
);
reset role;

-- Ending the match closes the chat ---------------------------------------------------------------------
update public.matches set ended_at = now(), ended_by = '00000000-0000-0000-0000-0000000fb002'
where id = '00000000-0000-0000-0000-0000000fd001';
select is(
  private.message_blocker('00000000-0000-0000-0000-0000000fb001',
    (select id from public.conversations where user_a = '00000000-0000-0000-0000-0000000fb001' and user_b = '00000000-0000-0000-0000-0000000fb002')),
  'match_ended', 'an ended match closes their chat'
);
select is((select count(*)::int from public.notifications where type = 'match_created' and match_id = '00000000-0000-0000-0000-0000000fd001'),
  0, 'and takes its notifications');

select * from finish();
rollback;
