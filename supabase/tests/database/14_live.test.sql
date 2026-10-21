begin;
create extension if not exists pgtap with schema extensions;

select plan(30);

-- l1 owner, l2 Yönetici (host), l3 Moderatör, l4 member, l5 outsider, l6 platform admin.
insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-0000000ab001', 'l1@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000ab002', 'l2@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000ab003', 'l3@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000ab004', 'l4@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000ab005', 'l5@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000ab006', 'l6@test.local', 'authenticated', 'authenticated');
insert into public.profiles (id, username, display_name) values
  ('00000000-0000-0000-0000-0000000ab001', 'live_owner', 'Owner'),
  ('00000000-0000-0000-0000-0000000ab002', 'live_admin', 'Admin'),
  ('00000000-0000-0000-0000-0000000ab003', 'live_mod', 'Mod'),
  ('00000000-0000-0000-0000-0000000ab004', 'live_member', 'Member'),
  ('00000000-0000-0000-0000-0000000ab005', 'live_outsider', 'Outsider'),
  ('00000000-0000-0000-0000-0000000ab006', 'live_staff', 'Staff');
insert into public.platform_staff (user_id, role) values ('00000000-0000-0000-0000-0000000ab006', 'admin');

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;

select pg_temp.act('00000000-0000-0000-0000-0000000ab001');
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id)
values ('00000000-0000-0000-0000-0000000ac001', 'canli.grup', 'Canlı Grup', 'music', 'open', '00000000-0000-0000-0000-0000000ab001');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-0000000ac001', '00000000-0000-0000-0000-0000000ab001');
select pg_temp.act('00000000-0000-0000-0000-0000000ab002');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-0000000ac001', '00000000-0000-0000-0000-0000000ab002');
select pg_temp.act('00000000-0000-0000-0000-0000000ab003');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-0000000ac001', '00000000-0000-0000-0000-0000000ab003');
select pg_temp.act('00000000-0000-0000-0000-0000000ab004');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-0000000ac001', '00000000-0000-0000-0000-0000000ab004');
select pg_temp.act('00000000-0000-0000-0000-0000000ab001');
insert into public.group_member_roles (group_id, user_id, role) values
  ('00000000-0000-0000-0000-0000000ac001', '00000000-0000-0000-0000-0000000ab002', 'admin'),
  ('00000000-0000-0000-0000-0000000ac001', '00000000-0000-0000-0000-0000000ab003', 'moderator');

-- Starting (backend writes) ---------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000ab004');
select throws_ok(
  $$ insert into public.live_broadcasts (group_id, host_id, title, status)
     values ('00000000-0000-0000-0000-0000000ac001', '00000000-0000-0000-0000-0000000ab004', 'Üye yayını', 'live') $$,
  'P0001', 'live_forbidden', 'members without live.start cannot start a broadcast'
);

select pg_temp.act('00000000-0000-0000-0000-0000000ab006');
update public.plans set monthly_live_minutes = 0 where slug = 'free';
select pg_temp.act('00000000-0000-0000-0000-0000000ab002');
select throws_ok(
  $$ insert into public.live_broadcasts (group_id, host_id, title, status)
     values ('00000000-0000-0000-0000-0000000ac001', '00000000-0000-0000-0000-0000000ab002', 'Akşam sohbeti', 'live') $$,
  'P0001', 'minutes_exhausted', 'no live minutes left, no broadcast'
);
select pg_temp.act('00000000-0000-0000-0000-0000000ab006');
update public.plans set monthly_live_minutes = 60 where slug = 'free';

select pg_temp.act('00000000-0000-0000-0000-0000000ab002');
select lives_ok(
  $$ insert into public.live_broadcasts (id, group_id, host_id, title, status)
     values ('00000000-0000-0000-0000-0000000ad001', '00000000-0000-0000-0000-0000000ac001',
             '00000000-0000-0000-0000-0000000ab002', 'Akşam sohbeti', 'live') $$,
  'a Yönetici starts a broadcast'
);
select isnt((select started_at from public.live_broadcasts where id = '00000000-0000-0000-0000-0000000ad001'), null,
  'the start time is set by the database');
select throws_ok(
  $$ insert into public.live_broadcasts (group_id, host_id, title, status)
     values ('00000000-0000-0000-0000-0000000ac001', '00000000-0000-0000-0000-0000000ab002', 'İkinci', 'live') $$,
  '23505', null, 'a group has one live broadcast at a time'
);
select throws_ok(
  $$ insert into public.live_broadcasts (group_id, host_id, title, status, scheduled_at)
     values ('00000000-0000-0000-0000-0000000ac001', '00000000-0000-0000-0000-0000000ab002', 'Yarın', 'scheduled', now() + interval '1 minute') $$,
  'P0001', 'schedule_invalid', 'a schedule must be at least five minutes ahead'
);
select throws_ok(
  $$ update public.live_broadcasts set title = 'Başka' where id = '00000000-0000-0000-0000-0000000ad001' $$,
  'P0001', 'broadcast_immutable', 'the title does not change'
);

-- Reading --------------------------------------------------------------------------------------------
set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000ab004');
select is((select count(*)::int from public.live_broadcasts), 1, 'members see their group broadcasts');
select is((public.group_live('00000000-0000-0000-0000-0000000ac001'))->'live'->>'title', 'Akşam sohbeti', 'group_live returns the live broadcast');
select is((public.group_live('00000000-0000-0000-0000-0000000ac001'))->>'minutes_left', null, 'minutes only for those who may start');
select pg_temp.act('00000000-0000-0000-0000-0000000ab005');
select is((select count(*)::int from public.live_broadcasts), 0, 'outsiders see no broadcast');
select is((select count(*)::int from public.my_live_broadcasts()), 0, 'nor any on their home');
select throws_ok(
  $$ insert into public.live_broadcasts (group_id, host_id, title, status)
     values ('00000000-0000-0000-0000-0000000ac001', '00000000-0000-0000-0000-0000000ab005', 'Sızma', 'live') $$,
  '42501', null, 'clients cannot write broadcasts'
);

-- Comments ---------------------------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000ab004');
select lives_ok(
  $$ insert into public.live_comments (broadcast_id, user_id, body) values ('00000000-0000-0000-0000-0000000ad001', '00000000-0000-0000-0000-0000000ab004', ' Selam! ') $$,
  'a member comments on the live broadcast'
);
select is((select body from public.live_comments where user_id = '00000000-0000-0000-0000-0000000ab004'), 'Selam!', 'comments are trimmed');
select pg_temp.act('00000000-0000-0000-0000-0000000ab005');
select throws_ok(
  $$ insert into public.live_comments (broadcast_id, user_id, body) values ('00000000-0000-0000-0000-0000000ad001', '00000000-0000-0000-0000-0000000ab005', 'Merhaba') $$,
  '42501', null, 'outsiders cannot comment'
);
select is((select count(*)::int from public.live_comments), 0, 'nor read the comments');
select pg_temp.act('00000000-0000-0000-0000-0000000ab004');
do $$ begin
  for i in 1..19 loop
    insert into public.live_comments (broadcast_id, user_id, body) values ('00000000-0000-0000-0000-0000000ad001', '00000000-0000-0000-0000-0000000ab004', 'Yorum ' || i);
  end loop;
end $$;
select throws_ok(
  $$ insert into public.live_comments (broadcast_id, user_id, body) values ('00000000-0000-0000-0000-0000000ad001', '00000000-0000-0000-0000-0000000ab004', 'Bir tane daha') $$,
  'P0001', 'comment_rate_limited', 'at most 20 comments a minute'
);
reset role;

-- Moderation (backend writes) -----------------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000ab003');
select throws_ok(
  $$ insert into public.live_kicks (broadcast_id, user_id) values ('00000000-0000-0000-0000-0000000ad001', '00000000-0000-0000-0000-0000000ab002') $$,
  'P0001', 'live_forbidden', 'a Moderatör cannot kick the Yönetici host (rank)'
);
select lives_ok(
  $$ insert into public.live_kicks (broadcast_id, user_id) values ('00000000-0000-0000-0000-0000000ad001', '00000000-0000-0000-0000-0000000ab004') $$,
  'a Moderatör kicks a member'
);
select is(private.can_join_live('00000000-0000-0000-0000-0000000ad001', '00000000-0000-0000-0000-0000000ab004'), false,
  'a kicked member cannot rejoin');
select lives_ok(
  $$ delete from public.live_comments where user_id = '00000000-0000-0000-0000-0000000ab004' $$,
  'a Moderatör deletes the comments of a member'
);
select throws_ok(
  $$ update public.live_broadcasts set status = 'ended', end_reason = 'moderator' where id = '00000000-0000-0000-0000-0000000ad001' $$,
  'P0001', 'live_forbidden', 'a Moderatör cannot end the broadcast of a Yönetici'
);

-- Scheduled broadcast, reminder, notification ---------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000ab001');
insert into public.live_broadcasts (id, group_id, host_id, title, status, scheduled_at)
values ('00000000-0000-0000-0000-0000000ad002', '00000000-0000-0000-0000-0000000ac001', '00000000-0000-0000-0000-0000000ab001',
        'Planlı konser', 'scheduled', now() + interval '10 minutes');
set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000ab004');
select lives_ok(
  $$ insert into public.live_reminders (broadcast_id, user_id) values ('00000000-0000-0000-0000-0000000ad002', '00000000-0000-0000-0000-0000000ab004') $$,
  'a member asks for a reminder'
);
select pg_temp.act('00000000-0000-0000-0000-0000000ab005');
select throws_ok(
  $$ insert into public.live_reminders (broadcast_id, user_id) values ('00000000-0000-0000-0000-0000000ad002', '00000000-0000-0000-0000-0000000ab005') $$,
  '42501', null, 'outsiders cannot'
);
reset role;

select pg_temp.act('00000000-0000-0000-0000-0000000ab001');
select lives_ok(
  $$ update public.live_broadcasts set status = 'ended', end_reason = 'moderator' where id = '00000000-0000-0000-0000-0000000ad001' $$,
  'the owner ends the broadcast of a Yönetici'
);
select lives_ok(
  $$ update public.live_broadcasts set status = 'live' where id = '00000000-0000-0000-0000-0000000ad002' $$,
  'the host starts the scheduled broadcast'
);
select is(
  (select count(*)::int from public.notifications where recipient_id = '00000000-0000-0000-0000-0000000ab004' and type = 'live_started'),
  1, 'the reminder becomes a live_started notification'
);
select throws_ok(
  $$ update public.live_broadcasts set status = 'ended', end_reason = 'empty' where id = '00000000-0000-0000-0000-0000000ad002' $$,
  'P0001', 'live_forbidden', 'system reasons are only for the backend monitor'
);
select set_config('request.jwt.claims', '', true);
select lives_ok(
  $$ update public.live_broadcasts set status = 'ended', end_reason = 'empty' where id = '00000000-0000-0000-0000-0000000ad002' $$,
  'the monitor ends an empty room'
);

select * from finish();
rollback;
