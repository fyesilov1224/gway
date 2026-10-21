begin;
create extension if not exists pgtap with schema extensions;

select plan(58);

-- m1 owner, m2 Yönetici, m3 m4 Disiplin Kurulu, m5 Moderatör, m6 m7 members, m8 outsider, m9 platform admin.
insert into auth.users (id, email, aud, role)
select ('00000000-0000-0000-0000-0000000af00' || i)::uuid, 'm' || i || '@test.local', 'authenticated', 'authenticated'
from generate_series(1, 9) i;
insert into public.profiles (id, username, display_name)
select ('00000000-0000-0000-0000-0000000af00' || i)::uuid, 'mod_user' || i, 'Mod ' || i
from generate_series(1, 9) i;
insert into public.platform_staff (user_id, role) values ('00000000-0000-0000-0000-0000000af009', 'admin');

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;
create function pg_temp.u(i int) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000000af00' || i)::uuid $$;
create function pg_temp.g() returns uuid language sql as $$ select '00000000-0000-0000-0000-0000000ad001'::uuid $$;
create function pg_temp.vote(i int, c text, v text) returns void language sql as $$
  select pg_temp.act(pg_temp.u(i)::text);
  update public.case_votes set vote = v where case_id = c::uuid and voter_id = pg_temp.u(i);
$$;

select pg_temp.act('00000000-0000-0000-0000-0000000af001');
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id)
values (pg_temp.g(), 'disiplin.grubu', 'Disiplin Grubu', 'hiking', 'open', pg_temp.u(1));
insert into public.group_members (group_id, user_id) values (pg_temp.g(), pg_temp.u(1));
do $$ begin
  for i in 2..7 loop
    perform pg_temp.act(pg_temp.u(i)::text);
    insert into public.group_members (group_id, user_id) values (pg_temp.g(), pg_temp.u(i));
  end loop;
end $$;
select pg_temp.act('00000000-0000-0000-0000-0000000af001');
insert into public.group_member_roles (group_id, user_id, role) values
  (pg_temp.g(), pg_temp.u(2), 'admin'),
  (pg_temp.g(), pg_temp.u(3), 'discipline'),
  (pg_temp.g(), pg_temp.u(4), 'discipline'),
  (pg_temp.g(), pg_temp.u(5), 'moderator');
insert into public.posts (id, author_id, group_id, caption)
values ('00000000-0000-0000-0000-0000000ab001', pg_temp.u(1), pg_temp.g(), 'Pazar yürüyüşü');
select pg_temp.act('00000000-0000-0000-0000-0000000af006');
insert into public.comments (id, post_id, author_id, body)
values ('00000000-0000-0000-0000-0000000ac001', '00000000-0000-0000-0000-0000000ab001', pg_temp.u(6), 'Kaba bir yorum');

-- Reports (the user's own insert through RLS) ---------------------------------------------------
set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000af007');
select lives_ok(
  $$ insert into public.reports (reporter_id, target_type, target_id, reason, note)
     values (pg_temp.u(7), 'comment', '00000000-0000-0000-0000-0000000ac001', 'harassment', '  Hakaret ediyor  ') $$,
  'a member reports a comment'
);
select results_eq(
  $$ select group_id, subject_id, excerpt, note from public.reports where target_id = '00000000-0000-0000-0000-0000000ac001' $$,
  $$ values (pg_temp.g(), pg_temp.u(6), 'Kaba bir yorum'::text, 'Hakaret ediyor'::text) $$,
  'the target fills the group, the accused person and the evidence'
);
select throws_ok(
  $$ insert into public.reports (reporter_id, target_type, target_id, reason)
     values (pg_temp.u(7), 'comment', '00000000-0000-0000-0000-0000000ac001', 'spam') $$,
  '23505', null, 'a target is reported once while the report is open'
);
select throws_ok(
  $$ insert into public.reports (reporter_id, target_type, target_id, reason)
     values (pg_temp.u(7), 'post', '00000000-0000-0000-0000-00000000dead', 'spam') $$,
  'P0001', 'report_target_invalid', 'unknown targets are rejected'
);
select throws_ok(
  $$ insert into public.reports (reporter_id, target_type, target_id, reason)
     values (pg_temp.u(6), 'post', 'kötü', 'spam') $$,
  'P0001', 'report_forbidden', 'nobody reports in another person''s name'
);
select lives_ok(
  $$ insert into public.reports (reporter_id, target_type, target_id, group_id, reason)
     values (pg_temp.u(7), 'user', pg_temp.u(6)::text, pg_temp.g(), 'harassment') $$,
  'a member reports another member from the group'
);
select is((select group_id from public.reports where target_type = 'user' and reporter_id = pg_temp.u(7)), pg_temp.g(),
  'a member reported by a member goes to the group');
select pg_temp.act('00000000-0000-0000-0000-0000000af008');
insert into public.reports (reporter_id, target_type, target_id, group_id, reason)
values (pg_temp.u(8), 'user', pg_temp.u(6)::text, pg_temp.g(), 'spam');
select is((select group_id from public.reports where reporter_id = pg_temp.u(8)), null::uuid,
  'an outsider''s report about a person goes to the platform');
select throws_ok(
  $$ insert into public.reports (reporter_id, target_type, target_id, reason) values (pg_temp.u(8), 'user', pg_temp.u(8)::text, 'spam') $$,
  'P0001', 'report_self', 'nobody reports themselves'
);
select pg_temp.act('00000000-0000-0000-0000-0000000af006');
select is((select count(*)::int from public.reports), 0, 'the accused person does not see reports about them');
select pg_temp.act('00000000-0000-0000-0000-0000000af007');
select is((select count(*)::int from public.reports), 2, 'the reporter sees their own reports');
select throws_ok(
  $$ update public.reports set status = 'dismissed' $$,
  '42501', null, 'clients cannot review reports'
);
select throws_ok($$ select * from public.moderation_cases $$, '42501', null, 'cases are not readable directly');
select throws_ok($$ select * from public.case_votes $$, '42501', null, 'votes are not readable directly');

-- The group's moderation desk -------------------------------------------------------------------
select is(public.group_moderation(pg_temp.g()), null::jsonb, 'members do not see the moderation desk');
select pg_temp.act('00000000-0000-0000-0000-0000000af005');
select is(jsonb_array_length(public.group_moderation(pg_temp.g())->'reports'), 2, 'a moderator sees the open group reports');
select is(
  (select count(*)::int from jsonb_array_elements(public.group_moderation(pg_temp.g())->'reports') r where r ? 'reporter_id' or r ? 'reporter'),
  0, 'reporters stay hidden from the group');
reset role;
set local role anon;
select throws_ok($$ select * from public.reports $$, '42501', null, 'visitors cannot read reports');
reset role;

-- Pre-review (backend writes, actor in the claims) ---------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000af007');
select throws_ok(
  $$ update public.reports set status = 'dismissed' where target_type = 'user' and group_id = pg_temp.g() $$,
  'P0001', 'report_review_forbidden', 'members cannot review reports'
);
select pg_temp.act('00000000-0000-0000-0000-0000000af005');
select lives_ok(
  $$ update public.reports set status = 'dismissed' where target_type = 'user' and group_id = pg_temp.g() $$,
  'a moderator dismisses a group report'
);
select is((select reviewed_by from public.reports where target_type = 'user' and group_id = pg_temp.g()), pg_temp.u(5), 'the reviewer is recorded');
select lives_ok(
  $$ update public.comments set removed_at = now(), removed_reason = 'Hakaret' where id = '00000000-0000-0000-0000-0000000ac001' $$,
  'an outranking reviewer removes a reported comment on a group post'
);
select pg_temp.act('00000000-0000-0000-0000-0000000af007');
select throws_ok(
  $$ update public.comments set removed_at = null, removed_reason = null where id = '00000000-0000-0000-0000-0000000ac001' $$,
  'P0001', 'comment_immutable', 'members cannot remove comments'
);

-- Cases --------------------------------------------------------------------------------------------
select throws_ok(
  $$ insert into public.moderation_cases (group_id, subject_id, opened_by, sanction, reason, threshold, voting_ends_at)
     values (pg_temp.g(), pg_temp.u(6), pg_temp.u(7), 'warning', 'Gruba hakaret etti.', 'majority', now()) $$,
  'P0001', 'case_forbidden', 'members cannot open cases'
);
select pg_temp.act('00000000-0000-0000-0000-0000000af005');
select throws_ok(
  $$ insert into public.moderation_cases (group_id, subject_id, opened_by, sanction, reason, threshold, voting_ends_at)
     values (pg_temp.g(), pg_temp.u(3), pg_temp.u(5), 'warning', 'Kurul üyesi hakkında.', 'majority', now()) $$,
  'P0001', 'rank_violation', 'a moderator cannot open a case about a board member'
);
select pg_temp.act('00000000-0000-0000-0000-0000000af002');
select throws_ok(
  $$ insert into public.moderation_cases (group_id, subject_id, opened_by, sanction, reason, threshold, voting_ends_at)
     values (pg_temp.g(), pg_temp.u(3), pg_temp.u(2), 'warning', 'Kurul üyesi hakkında.', 'majority', now()) $$,
  'P0001', 'rank_violation', 'the board cannot decide about one of its peers'
);
select pg_temp.act('00000000-0000-0000-0000-0000000af005');
select lives_ok(
  $$ insert into public.moderation_cases (id, group_id, subject_id, opened_by, sanction, duration_days, reason, threshold, voting_ends_at)
     values ('00000000-0000-0000-0000-0000000aca01', pg_temp.g(), pg_temp.u(6), pg_temp.u(5), 'ban', 7,
             'Üyelere tekrar tekrar hakaret etti.', 'unanimous', now()) $$,
  'a moderator opens a case about a member'
);
select results_eq(
  $$ select threshold, voting_ends_at - created_at from public.moderation_cases where id = '00000000-0000-0000-0000-0000000aca01' $$,
  $$ values ('majority'::text, interval '72 hours') $$,
  'the threshold comes from the group and voting lasts 72 hours'
);
select results_eq(
  $$ select voter_id from public.case_votes where case_id = '00000000-0000-0000-0000-0000000aca01' order by voter_id $$,
  $$ values (pg_temp.u(3)), (pg_temp.u(4)) $$,
  'the board members are the voters'
);
select is((select count(*)::int from public.notifications where type = 'case_vote' and group_id = pg_temp.g()), 2,
  'voters are asked to vote');
select throws_ok(
  $$ insert into public.moderation_cases (group_id, subject_id, opened_by, sanction, reason, threshold, voting_ends_at)
     values (pg_temp.g(), pg_temp.u(6), pg_temp.u(5), 'warning', 'İkinci bir dosya açılıyor.', 'majority', now()) $$,
  '23505', null, 'one open case per person'
);

-- Emergency mute ---------------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000af007');
select throws_ok(
  $$ insert into public.sanctions (case_id, type, interim) values ('00000000-0000-0000-0000-0000000aca01', 'mute', true) $$,
  'P0001', 'sanction_forbidden', 'members cannot mute'
);
select pg_temp.act('00000000-0000-0000-0000-0000000af005');
select lives_ok(
  $$ insert into public.sanctions (id, case_id, type, interim) values ('00000000-0000-0000-0000-0000000a5a01', '00000000-0000-0000-0000-0000000aca01', 'mute', true) $$,
  'a moderator mutes at once while the case is open'
);
select ok(private.is_group_muted(pg_temp.g(), pg_temp.u(6)), 'the member is muted');
select pg_temp.act('00000000-0000-0000-0000-0000000af006');
select throws_ok(
  $$ insert into public.comments (post_id, author_id, body) values ('00000000-0000-0000-0000-0000000ab001', pg_temp.u(6), 'Yine ben') $$,
  'P0001', 'muted', 'a muted member does not comment on group posts'
);
select pg_temp.act('00000000-0000-0000-0000-0000000af005');
select throws_ok(
  $$ insert into public.sanctions (case_id, type) values ('00000000-0000-0000-0000-0000000aca01', 'ban') $$,
  'P0001', 'sanction_forbidden', 'no sanction before the decision'
);

-- Votes and the decision --------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000af006');
select throws_ok(
  $$ update public.case_votes set vote = 'reject' where voter_id = pg_temp.u(3) $$,
  'P0001', 'vote_forbidden', 'nobody votes for someone else'
);
select pg_temp.vote(3, '00000000-0000-0000-0000-0000000aca01', 'approve');
select is(private.case_outcome('00000000-0000-0000-0000-0000000aca01'), null, 'half of the board is no majority yet');
select throws_ok(
  $$ update public.moderation_cases set status = 'approved' where id = '00000000-0000-0000-0000-0000000aca01' $$,
  'P0001', 'case_not_decided', 'a case is not approved before the votes say so'
);
select pg_temp.vote(4, '00000000-0000-0000-0000-0000000aca01', 'approve');
select is(private.case_outcome('00000000-0000-0000-0000-0000000aca01'), 'approved', 'the board approves');
select lives_ok(
  $$ update public.moderation_cases set status = 'approved' where id = '00000000-0000-0000-0000-0000000aca01';
     update public.sanctions set lifted_at = now(), lift_reason = 'decided' where id = '00000000-0000-0000-0000-0000000a5a01';
     insert into public.sanctions (id, case_id, type) values ('00000000-0000-0000-0000-0000000a5a02', '00000000-0000-0000-0000-0000000aca01', 'ban');
     delete from public.group_members where group_id = pg_temp.g() and user_id = pg_temp.u(6) $$,
  'the decision lifts the emergency mute, bans and removes the member'
);
select is((select ends_at - starts_at from public.sanctions where id = '00000000-0000-0000-0000-0000000a5a02'), interval '7 days',
  'the ban lasts the proposed days');
select ok(private.is_group_banned(pg_temp.g(), pg_temp.u(6)), 'the member is banned');
select is((select count(*)::int from public.notifications where type = 'sanction_applied' and recipient_id = pg_temp.u(6)), 2,
  'the person is told about each sanction');
select throws_ok(
  $$ delete from public.group_members where group_id = pg_temp.g() and user_id = pg_temp.u(7) $$,
  'P0001', 'leave_not_allowed', 'nobody is removed without a sanction'
);
select pg_temp.act('00000000-0000-0000-0000-0000000af006');
select throws_ok(
  $$ insert into public.group_members (group_id, user_id) values (pg_temp.g(), pg_temp.u(6)) $$,
  'P0001', 'banned', 'a banned person cannot join again'
);

-- Appeals -----------------------------------------------------------------------------------------
set local role authenticated;
select throws_ok(
  $$ insert into public.sanction_appeals (sanction_id, user_id, body) values ('00000000-0000-0000-0000-0000000a5a01', pg_temp.u(6), 'Susturma haksızdı bence.') $$,
  'P0001', 'appeal_not_allowed', 'the emergency mute is not appealed'
);
select lives_ok(
  $$ insert into public.sanction_appeals (sanction_id, user_id, body) values ('00000000-0000-0000-0000-0000000a5a02', pg_temp.u(6), 'Yanlış anlaşıldım, özür dilerim.') $$,
  'the person appeals the ban'
);
select is((select handler from public.sanction_appeals where sanction_id = '00000000-0000-0000-0000-0000000a5a02'), 'owner',
  'the owner decides when they took no part');
select is(jsonb_array_length(public.my_sanctions()), 2, 'the person sees their sanctions');
reset role;
select pg_temp.act('00000000-0000-0000-0000-0000000af002');
select throws_ok(
  $$ update public.sanction_appeals set status = 'overturned' where sanction_id = '00000000-0000-0000-0000-0000000a5a02' $$,
  'P0001', 'appeal_forbidden', 'only the owner decides the appeal'
);
select pg_temp.act('00000000-0000-0000-0000-0000000af001');
select lives_ok(
  $$ update public.sanction_appeals set status = 'overturned', decision_note = 'İkinci şans' where sanction_id = '00000000-0000-0000-0000-0000000a5a02';
     update public.sanctions set lifted_at = now(), lift_reason = 'appeal' where id = '00000000-0000-0000-0000-0000000a5a02' $$,
  'the owner overturns the ban'
);
select ok(not private.is_group_banned(pg_temp.g(), pg_temp.u(6)), 'the ban is lifted');

-- The owner's case goes to the platform on appeal; without a board the owner decides -----------
select lives_ok(
  $$ insert into public.moderation_cases (id, group_id, subject_id, opened_by, sanction, reason, threshold, voting_ends_at)
     values ('00000000-0000-0000-0000-0000000aca02', pg_temp.g(), pg_temp.u(7), pg_temp.u(1), 'warning', 'Kurallara uymadı.', 'majority', now()) $$,
  'the owner opens a case'
);
select pg_temp.vote(3, '00000000-0000-0000-0000-0000000aca02', 'approve');
select pg_temp.vote(4, '00000000-0000-0000-0000-0000000aca02', 'approve');
update public.moderation_cases set status = 'approved' where id = '00000000-0000-0000-0000-0000000aca02';
insert into public.sanctions (id, case_id, type) values ('00000000-0000-0000-0000-0000000a5a03', '00000000-0000-0000-0000-0000000aca02', 'warning');
select pg_temp.act('00000000-0000-0000-0000-0000000af007');
insert into public.sanction_appeals (id, sanction_id, user_id, body)
values ('00000000-0000-0000-0000-0000000aa002', '00000000-0000-0000-0000-0000000a5a03', pg_temp.u(7), 'Uyarıyı hak etmedim.');
select is((select handler from public.sanction_appeals where id = '00000000-0000-0000-0000-0000000aa002'), 'platform',
  'the platform decides when the owner opened the case');

select pg_temp.act('00000000-0000-0000-0000-0000000af001');
delete from public.group_member_roles where group_id = pg_temp.g() and role = 'discipline';
select pg_temp.act('00000000-0000-0000-0000-0000000af005');
insert into public.moderation_cases (id, group_id, subject_id, opened_by, sanction, reason, threshold, voting_ends_at)
values ('00000000-0000-0000-0000-0000000aca03', pg_temp.g(), pg_temp.u(7), pg_temp.u(5), 'kick', 'Tekrar kurallara uymadı.', 'majority', now());
select results_eq(
  $$ select voter_id from public.case_votes where case_id = '00000000-0000-0000-0000-0000000aca03' $$,
  $$ values (pg_temp.u(1)) $$,
  'without a board the owner decides alone'
);

-- Settings and thresholds ---------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000af002');
select throws_ok(
  $$ update public.groups set case_threshold = 'unanimous' where id = pg_temp.g() $$,
  'P0001', 'case_threshold_forbidden', 'only the owner sets the threshold'
);
select ok(
  private.meets_threshold('two_thirds', 2, 3) and not private.meets_threshold('majority', 1, 2)
  and private.meets_threshold('unanimous', 3, 3) and not private.meets_threshold('unanimous', 2, 3)
  and not private.meets_threshold('majority', 0, 0),
  'thresholds: two thirds, more than half, all; no votes never pass'
);

select * from finish();
rollback;
