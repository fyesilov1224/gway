begin;
create extension if not exists pgtap with schema extensions;

select plan(21);

-- Referrals outlive accounts, so other suites leave rows behind; the checks below count and update every row.
-- The transaction is rolled back.
alter table public.platform_referrals disable trigger user;
delete from public.platform_referrals;
alter table public.platform_referrals enable trigger user;

-- r1 owner, r2 r3 discipline board, r4 subject, r5 member, r6 platform admin, r7 platform support.
insert into auth.users (id, email, aud, role)
select ('00000000-0000-0000-0000-0000004600a' || i)::uuid, 'ref' || i || '@test.local', 'authenticated', 'authenticated'
from generate_series(1, 7) i;
insert into public.profiles (id, username, display_name)
select ('00000000-0000-0000-0000-0000004600a' || i)::uuid, 'ref_user' || i, 'Ref ' || i
from generate_series(1, 7) i;
insert into public.platform_staff (user_id, role) values
  ('00000000-0000-0000-0000-0000004600a6', 'admin'),
  ('00000000-0000-0000-0000-0000004600a7', 'support');

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;
create function pg_temp.u(i int) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000004600a' || i)::uuid $$;
create function pg_temp.g() returns uuid language sql as $$ select '00000000-0000-0000-0000-000000460001'::uuid $$;
create function pg_temp.c() returns uuid language sql as $$ select '00000000-0000-0000-0000-0000004600c1'::uuid $$;

select pg_temp.act(pg_temp.u(1)::text);
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id)
values (pg_temp.g(), 'yasa.disi', 'Yasa Dışı Test', 'hiking', 'open', pg_temp.u(1));
insert into public.group_members (group_id, user_id) values (pg_temp.g(), pg_temp.u(1));
do $$ begin
  for i in 2..5 loop
    perform pg_temp.act(pg_temp.u(i)::text);
    insert into public.group_members (group_id, user_id) values (pg_temp.g(), pg_temp.u(i));
  end loop;
end $$;
select pg_temp.act(pg_temp.u(1)::text);
insert into public.group_member_roles (group_id, user_id, role) values
  (pg_temp.g(), pg_temp.u(2), 'discipline'),
  (pg_temp.g(), pg_temp.u(3), 'discipline');

-- Cases ------------------------------------------------------------------------------------------
select throws_ok(
  $$ insert into public.moderation_cases (group_id, subject_id, opened_by, sanction, reason, threshold, voting_ends_at, illegal_category)
     values (pg_temp.g(), pg_temp.u(4), pg_temp.u(1), 'kick', 'Tehdit içerikli mesajlar attı', 'majority', now(), 'threat') $$,
  '23514', null, 'only a ban case is marked as illegal activity');
select throws_ok(
  $$ insert into public.moderation_cases (group_id, subject_id, opened_by, sanction, reason, threshold, voting_ends_at, illegal_category)
     values (pg_temp.g(), pg_temp.u(4), pg_temp.u(1), 'ban', 'Tehdit içerikli mesajlar attı', 'majority', now(), 'theft') $$,
  '23514', null, 'the category is one of the listed crimes');
select lives_ok(
  $$ insert into public.moderation_cases (id, group_id, subject_id, opened_by, sanction, reason, threshold, voting_ends_at, illegal_category)
     values (pg_temp.c(), pg_temp.g(), pg_temp.u(4), pg_temp.u(1), 'ban', 'Tehdit içerikli mesajlar attı', 'majority', now(), 'threat') $$,
  'the owner opens an illegal-activity ban case');
select throws_ok(
  $$ update public.moderation_cases set illegal_category = null where id = pg_temp.c() $$,
  'P0001', 'case_immutable', 'the illegal-activity mark never changes');
select is(
  (select public.group_moderation(pg_temp.g()) -> 'cases' -> 0 ->> 'illegal_category'),
  'threat', 'the moderation desk shows the illegal-activity mark');

-- Referral opening -------------------------------------------------------------------------------
select throws_ok(
  $$ insert into public.platform_referrals (case_id, group_id, group_name, subject_id, category, reason)
     values (pg_temp.c(), pg_temp.g(), 'Yasa Dışı Test', pg_temp.u(4), 'threat', 'x') $$,
  'P0001', 'referral_case_mismatch', 'a case still voting opens no referral');

select pg_temp.act(pg_temp.u(2)::text);
update public.case_votes set vote = 'approve' where case_id = pg_temp.c() and voter_id = pg_temp.u(2);
select pg_temp.act(pg_temp.u(3)::text);
update public.case_votes set vote = 'approve' where case_id = pg_temp.c() and voter_id = pg_temp.u(3);
update public.moderation_cases set status = 'approved' where id = pg_temp.c();

select throws_ok(
  $$ insert into public.platform_referrals (case_id, group_id, group_name, subject_id, category, reason)
     values (pg_temp.c(), pg_temp.g(), 'Yasa Dışı Test', pg_temp.u(5), 'threat', 'x') $$,
  'P0001', 'referral_case_mismatch', 'the referral names the case''s person');
select lives_ok(
  $$ insert into public.platform_referrals (id, case_id, group_id, group_name, subject_id, subject_username, category, reason, evidence, status)
     values ('00000000-0000-0000-0000-0000004600f1', pg_temp.c(), pg_temp.g(), 'Yasa Dışı Test', pg_temp.u(4), 'ref_user4', 'threat',
             'üzerine yazılır', '[{"excerpt":"seni bulacağım"}]', 'banned') $$,
  'an approved illegal-activity case opens a referral');
select is(
  (select (status, reason, law_enforcement)::text from public.platform_referrals where id = '00000000-0000-0000-0000-0000004600f1'),
  '(pending,"Tehdit içerikli mesajlar attı",none)', 'a new referral is pending with the board''s reason');

-- Access -----------------------------------------------------------------------------------------
set local role authenticated;
select pg_temp.act(pg_temp.u(1)::text);
select is((select count(*)::int from public.platform_referrals), 0, 'the group owner cannot read referrals');
select pg_temp.act(pg_temp.u(4)::text);
select is((select count(*)::int from public.platform_referrals), 0, 'the person cannot read their referral');
select pg_temp.act(pg_temp.u(7)::text);
select is((select count(*)::int from public.platform_referrals), 0, 'support staff cannot read referrals');
select pg_temp.act(pg_temp.u(6)::text);
select is((select count(*)::int from public.platform_referrals), 1, 'a platform admin reads referrals');
select throws_ok(
  $$ update public.platform_referrals set status = 'cleared', decision_note = 'Temiz', decided_by = pg_temp.u(6) $$,
  '42501', null, 'clients never write referrals, even staff');
reset role;

-- Decision and authorities ---------------------------------------------------------------------
select pg_temp.act(pg_temp.u(2)::text);
select throws_ok(
  $$ update public.platform_referrals set status = 'banned', decision_note = 'Kurul banladı', decided_by = pg_temp.u(2) $$,
  'P0001', 'referral_decision_invalid', 'a board member cannot decide the referral');
insert into public.platform_staff (user_id, role) values (pg_temp.u(5), 'moderator');
select pg_temp.act(pg_temp.u(5)::text);
select throws_ok(
  $$ update public.platform_referrals set status = 'cleared', decision_note = 'Temiz', decided_by = pg_temp.u(5) $$,
  'P0001', 'referral_decision_invalid', 'a platform moderator reads but does not decide');
select pg_temp.act(pg_temp.u(6)::text);
select throws_ok(
  $$ update public.platform_referrals set evidence = '[]' $$,
  'P0001', 'referral_immutable', 'the evidence never changes');
select lives_ok(
  $$ update public.platform_referrals
     set status = 'banned', ban_until = null, law_enforcement = 'to_notify', decision_note = 'Tehdit kanıtlandı', decided_by = pg_temp.u(6) $$,
  'a platform admin bans permanently and marks it for the authorities');
select throws_ok(
  $$ update public.platform_referrals set status = 'cleared' $$,
  'P0001', 'referral_decision_invalid', 'a decision is final');
select lives_ok(
  $$ update public.platform_referrals set law_enforcement = 'notified', authorities_note = 'Kadıköy Emniyet, evrak 2026/123' $$,
  'the team records the notification to the authorities');

-- The person's account going away keeps the referral and its evidence.
delete from auth.users where id = pg_temp.u(4);
select is(
  (select (subject_username, evidence ->> 0 is not null, authorities_notified_at is not null)::text from public.platform_referrals),
  '(ref_user4,t,t)', 'a deleted account leaves the referral and its evidence');

select * from finish();
rollback;
