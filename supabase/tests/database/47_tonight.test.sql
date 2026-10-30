begin;
create extension if not exists pgtap with schema extensions;

select plan(22);

-- a, b, c, d share group 5801; x shares nothing; e is in the group but blocked by a.
insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-00000058a001', 'tonight-a@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000058a002', 'tonight-b@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000058a003', 'tonight-c@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000058a004', 'tonight-d@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000058a005', 'tonight-e@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000058a009', 'tonight-x@test.local', 'authenticated', 'authenticated');

insert into public.profiles (id, username, display_name) values
  ('00000000-0000-0000-0000-00000058a001', 'tonight_a', 'A'),
  ('00000000-0000-0000-0000-00000058a002', 'tonight_b', 'B'),
  ('00000000-0000-0000-0000-00000058a003', 'tonight_c', 'C'),
  ('00000000-0000-0000-0000-00000058a004', 'tonight_d', 'D'),
  ('00000000-0000-0000-0000-00000058a005', 'tonight_e', 'E'),
  ('00000000-0000-0000-0000-00000058a009', 'tonight_x', 'X');

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;

select pg_temp.act('00000000-0000-0000-0000-00000058a001');
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id, province)
values ('00000000-0000-0000-0000-000000005801', 'tonight.test', 'Akşam Yürüyüşçüleri', 'running', 'open',
        '00000000-0000-0000-0000-00000058a001', 34);
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-000000005801', '00000000-0000-0000-0000-00000058a001');
select pg_temp.act('00000000-0000-0000-0000-00000058a002');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-000000005801', '00000000-0000-0000-0000-00000058a002');
select pg_temp.act('00000000-0000-0000-0000-00000058a003');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-000000005801', '00000000-0000-0000-0000-00000058a003');
select pg_temp.act('00000000-0000-0000-0000-00000058a004');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-000000005801', '00000000-0000-0000-0000-00000058a004');
select pg_temp.act('00000000-0000-0000-0000-00000058a005');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-000000005801', '00000000-0000-0000-0000-00000058a005');
select pg_temp.act('00000000-0000-0000-0000-00000058a001');
insert into public.blocks (blocker_id, blocked_id) values ('00000000-0000-0000-0000-00000058a001', '00000000-0000-0000-0000-00000058a005');

-- Everyone says they are free (their own write).
create function pg_temp.free(uid text, note text) returns void language plpgsql as $$
begin
  perform pg_temp.act(uid);
  set local role authenticated;
  insert into public.tonight_status (user_id, note) values (uid::uuid, note);
  reset role;
end;
$$;
select pg_temp.free('00000000-0000-0000-0000-00000058a001', '  kahve  ');
select pg_temp.free('00000000-0000-0000-0000-00000058a002', '');
select pg_temp.free('00000000-0000-0000-0000-00000058a003', '');
select pg_temp.free('00000000-0000-0000-0000-00000058a004', '');
select pg_temp.free('00000000-0000-0000-0000-00000058a005', '');
select pg_temp.free('00000000-0000-0000-0000-00000058a009', '');

-- The status -----------------------------------------------------------------------------------
select is((select note from public.tonight_status where user_id = '00000000-0000-0000-0000-00000058a001'), 'kahve', 'the note is trimmed');
select ok((select until > now() and until <= now() + interval '28 hours' from public.tonight_status
           where user_id = '00000000-0000-0000-0000-00000058a001'), 'the status ends by the next 04:00');

select pg_temp.act('00000000-0000-0000-0000-00000058a002');
set local role authenticated;
select is((select count(*)::int from public.tonight_status where user_id = '00000000-0000-0000-0000-00000058a001'), 1,
  'someone sharing a group sees it');
select is(jsonb_array_length(public.tonight_people()), 4, 'four people share a group with b');
select is(public.tonight_people() -> 0 -> 'groups' ->> 0, 'Akşam Yürüyüşçüleri', 'the shared group is named');
select throws_ok($$ update public.tonight_status set until = now() + interval '9 days'
                    where user_id = '00000000-0000-0000-0000-00000058a002' $$, '42501', null, 'the end cannot be written');
reset role;

select pg_temp.act('00000000-0000-0000-0000-00000058a009');
set local role authenticated;
select is((select count(*)::int from public.tonight_status where user_id <> '00000000-0000-0000-0000-00000058a009'), 0,
  'someone without a shared group sees nobody');
select throws_ok($$ insert into public.tonight_status (user_id) values ('00000000-0000-0000-0000-00000058a001') $$,
  '42501', null, 'nobody says it for someone else');
reset role;

select pg_temp.act('00000000-0000-0000-0000-00000058a001');
set local role authenticated;
select is((select count(*)::int from public.tonight_status where user_id = '00000000-0000-0000-0000-00000058a005'), 0,
  'a block hides the status');
reset role;

set local role anon;
select throws_ok($$ select count(*) from public.tonight_status $$, '42501', null, 'anonymous visitors read nothing');
reset role;

-- The table (the backend writes as the founder) ------------------------------------------------------
select is((select count(*)::int from private.tonight_candidates('00000000-0000-0000-0000-00000058a001')), 3,
  'candidates share a group, are free and not blocked');

select pg_temp.act('00000000-0000-0000-0000-00000058a002');
set local role authenticated;
select throws_ok($$ insert into public.tonight_tables (created_by, evening, closes_at)
                    values ('00000000-0000-0000-0000-00000058a002', current_date, now()) $$,
  '42501', null, 'the app cannot open a table');
reset role;

insert into public.tonight_tables (id, created_by, evening, closes_at)
values ('00000000-0000-0000-0000-0000005800f1', '00000000-0000-0000-0000-00000058a001', private.tonight_evening(),
        private.tonight_table_closes(private.tonight_evening()));
insert into public.tonight_table_invites (table_id, user_id, state) values
  ('00000000-0000-0000-0000-0000005800f1', '00000000-0000-0000-0000-00000058a001', 'accepted'),
  ('00000000-0000-0000-0000-0000005800f1', '00000000-0000-0000-0000-00000058a002', 'pending'),
  ('00000000-0000-0000-0000-0000005800f1', '00000000-0000-0000-0000-00000058a003', 'pending'),
  ('00000000-0000-0000-0000-0000005800f1', '00000000-0000-0000-0000-00000058a004', 'pending');

select is((select count(*)::int from public.notifications where type = 'tonight_table_invite'
           and table_id = '00000000-0000-0000-0000-0000005800f1'), 3, 'the invited are notified');

select pg_temp.act('00000000-0000-0000-0000-00000058a002');
set local role authenticated;
select is((select count(*)::int from public.tonight_table_invites where table_id = '00000000-0000-0000-0000-0000005800f1'), 2,
  'an invitee sees their own invitation and the founder, not the other pending people');
select is((public.my_tonight() #>> '{invites,0,pending}')::int, 3, 'the pending are a count');
reset role;

update public.tonight_table_invites set state = 'accepted'
where table_id = '00000000-0000-0000-0000-0000005800f1' and user_id = '00000000-0000-0000-0000-00000058a002';
select is((select count(*)::int from public.conversations where table_id = '00000000-0000-0000-0000-0000005800f1'), 0,
  'two people are not a table yet');

update public.tonight_table_invites set state = 'accepted'
where table_id = '00000000-0000-0000-0000-0000005800f1' and user_id = '00000000-0000-0000-0000-00000058a003';
select is((select count(*)::int from public.conversation_members m join public.conversations c on c.id = m.conversation_id
           where c.table_id = '00000000-0000-0000-0000-0000005800f1'), 3, 'the third opens the chat for the three');
select is((select count(*)::int from public.notifications where type = 'tonight_table_ready'
           and table_id = '00000000-0000-0000-0000-0000005800f1'), 2, 'the others hear the table is set');

select pg_temp.act('00000000-0000-0000-0000-00000058a004');
set local role authenticated;
select is((select count(*)::int from public.messages m join public.conversations c on c.id = m.conversation_id
           where c.table_id = '00000000-0000-0000-0000-0000005800f1'), 0, 'a pending invitee cannot read the chat');
reset role;

insert into public.tonight_tables (id, created_by, evening, closes_at)
values ('00000000-0000-0000-0000-0000005800f2', '00000000-0000-0000-0000-00000058a004', private.tonight_evening(),
        private.tonight_table_closes(private.tonight_evening()));
select throws_ok($$ insert into public.tonight_table_invites (table_id, user_id, state)
                    values ('00000000-0000-0000-0000-0000005800f2', '00000000-0000-0000-0000-00000058a002', 'accepted') $$,
  'P0001', 'tonight_already_in_table', 'one table per person and evening');

-- Closing ---------------------------------------------------------------------------------------
set local session_replication_role = replica;
update public.tonight_tables set closes_at = now() - interval '1 minute' where id = '00000000-0000-0000-0000-0000005800f1';
set local session_replication_role = origin;
select is(private.message_blocker('00000000-0000-0000-0000-00000058a002',
  (select id from public.conversations where table_id = '00000000-0000-0000-0000-0000005800f1')), 'table_closed',
  'a closed table cannot be written to');

-- Starting soon ---------------------------------------------------------------------------------
set local session_replication_role = replica;
insert into public.events (id, group_id, created_by, title, starts_at, location) values
  ('00000000-0000-0000-0000-0000005800e1', '00000000-0000-0000-0000-000000005801', '00000000-0000-0000-0000-00000058a001',
   'Akşam koşusu', now() + interval '2 hours', 'Sahil'),
  ('00000000-0000-0000-0000-0000005800e2', '00000000-0000-0000-0000-000000005801', '00000000-0000-0000-0000-00000058a001',
   'Yarınki koşu', now() + interval '20 hours', 'Sahil');
set local session_replication_role = origin;

select pg_temp.act('00000000-0000-0000-0000-00000058a002');
set local role authenticated;
select is(public.starting_soon() #>> '{0,title}', 'Akşam koşusu', 'an event in two hours starts soon; tomorrow''s does not');
reset role;

select * from finish();
rollback;
