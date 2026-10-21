begin;
create extension if not exists pgtap with schema extensions;

select plan(37);

-- f1 group owner, f2 plain member, f3 user without groups, s1 platform support.
insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-0000000000f1', 'f1@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000f2', 'f2@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000f3', 'f3@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000a5', 's1@test.local', 'authenticated', 'authenticated');
insert into public.platform_staff (user_id, role) values ('00000000-0000-0000-0000-0000000000a5', 'support');
insert into public.profiles (id, username, display_name) values
  ('00000000-0000-0000-0000-0000000000f1', 'sup_owner', 'Owner'),
  ('00000000-0000-0000-0000-0000000000f2', 'sup_member', 'Member'),
  ('00000000-0000-0000-0000-0000000000f3', 'sup_user', 'User');

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;

select pg_temp.act('00000000-0000-0000-0000-0000000000f1');
insert into public.groups (id, handle, name, category_slug, owner_id)
values ('00000000-0000-0000-0000-00000000e101', 'destek.grup', 'Destek Grubu', 'music', '00000000-0000-0000-0000-0000000000f1');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-00000000e101', '00000000-0000-0000-0000-0000000000f1');
select pg_temp.act('00000000-0000-0000-0000-0000000000f2');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-00000000e101', '00000000-0000-0000-0000-0000000000f2');

-- Opening tickets (clients, RLS) ---------------------------------------------------
set local role anon;
select throws_ok(
  $$ select public.create_support_ticket('00000000-0000-0000-0000-00000000c001', 'problem', 'Giriş olmuyor', 'Detay') $$,
  '42501', null, 'anon cannot open a ticket'
);
reset role;

set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000000f3');
select lives_ok(
  $$ select public.create_support_ticket('00000000-0000-0000-0000-00000000c001', 'problem', '  Fotoğraf yüklenmiyor ', 'Kapak seçince hata veriyor.') $$,
  'a user opens a ticket with its first message'
);
select is(
  (select (status, subject, last_message_by)::text from public.support_tickets where id = '00000000-0000-0000-0000-00000000c001'),
  '(open,"Fotoğraf yüklenmiyor",user)', 'ticket starts open, subject trimmed'
);
select is(
  (select (author_kind, author_id)::text from public.support_messages where ticket_id = '00000000-0000-0000-0000-00000000c001'),
  '(user,00000000-0000-0000-0000-0000000000f3)', 'the author is always the caller'
);
select throws_ok(
  $$ select public.create_support_ticket('00000000-0000-0000-0000-00000000c002', 'request', 'Grubu sil', 'Lütfen',
                                         '00000000-0000-0000-0000-00000000e101') $$,
  '42501', null, 'a user cannot attach a group they do not manage'
);
select throws_ok(
  $$ select public.create_support_ticket('00000000-0000-0000-0000-00000000c002', 'bug', 'Konu', 'Metin') $$,
  '23514', null, 'unknown kind is rejected'
);

select pg_temp.act('00000000-0000-0000-0000-0000000000f2');
select throws_ok(
  $$ select public.create_support_ticket('00000000-0000-0000-0000-00000000c002', 'request', 'Grup adı', 'Değişsin',
                                         '00000000-0000-0000-0000-00000000e101') $$,
  '42501', null, 'a plain member cannot attach the group'
);
select is((select count(*)::int from public.my_managed_groups()), 0, 'a plain member manages no group');

select pg_temp.act('00000000-0000-0000-0000-0000000000f1');
select is((select handle from public.my_managed_groups()), 'destek.grup', 'the owner manages the group');
select lives_ok(
  $$ select public.create_support_ticket('00000000-0000-0000-0000-00000000c003', 'suggestion', 'Takvim görünümü', 'Organizasyonlar için takvim',
                                         '00000000-0000-0000-0000-00000000e101') $$,
  'the owner opens a ticket about their group'
);

-- Reading ----------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000000f2');
select is((select count(*)::int from public.support_tickets), 0, 'others cannot read tickets');
select is((select count(*)::int from public.support_messages), 0, 'others cannot read messages');
select pg_temp.act('00000000-0000-0000-0000-0000000000a5');
select is(
  (select count(*)::int from public.support_tickets where user_id in ('00000000-0000-0000-0000-0000000000f1', '00000000-0000-0000-0000-0000000000f3')),
  2, 'platform staff read every ticket'
);

-- Replying (clients) -----------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000000f2');
select throws_ok(
  $$ insert into public.support_messages (ticket_id, body) values ('00000000-0000-0000-0000-00000000c001', 'araya girdim') $$,
  'P0001', 'ticket_not_found', 'nobody replies to someone else''s ticket (it is not even visible)'
);
select pg_temp.act('00000000-0000-0000-0000-0000000000f3');
select throws_ok(
  $$ insert into public.support_messages (ticket_id, body, author_kind) values ('00000000-0000-0000-0000-00000000c001', 'ben ekibim', 'staff') $$,
  '42501', null, 'a user cannot write as staff'
);
select throws_ok(
  $$ insert into public.support_messages (ticket_id, body, attachments)
     values ('00000000-0000-0000-0000-00000000c001', 'ek', array['00000000-0000-0000-0000-0000000000f1/x.png']) $$,
  'P0001', 'attachment_path_invalid', 'attachments must be the sender''s own ticket files'
);
select lives_ok(
  $$ insert into public.support_messages (ticket_id, body, attachments)
     values ('00000000-0000-0000-0000-00000000c001', 'Ekran görüntüsü ekledim',
             array['00000000-0000-0000-0000-0000000000f3/00000000-0000-0000-0000-00000000c001-1.png']) $$,
  'the sender replies with a screenshot'
);
select throws_ok(
  $$ update public.support_tickets set status = 'closed' where id = '00000000-0000-0000-0000-00000000c001' $$,
  '42501', null, 'a user cannot change the status'
);
select lives_ok(
  $$ update public.support_tickets set user_read_at = now() where id = '00000000-0000-0000-0000-00000000c001' $$,
  'the sender marks replies as read'
);
select throws_ok(
  $$ update public.support_messages set body = 'değişti' where ticket_id = '00000000-0000-0000-0000-00000000c001' $$,
  '42501', null, 'clients cannot edit messages'
);
reset role;

-- Staff replies and status (backend, actor in claims) ------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-0000000000f2');
select throws_ok(
  $$ insert into public.support_messages (ticket_id, body, author_kind) values ('00000000-0000-0000-0000-00000000c001', 'yanıt', 'staff') $$,
  'P0001', 'staff_reply_forbidden', 'only platform staff reply as staff'
);
select throws_ok(
  $$ update public.support_tickets set status = 'resolved' where id = '00000000-0000-0000-0000-00000000c001' $$,
  'P0001', 'ticket_status_forbidden', 'only platform staff change the status'
);

select pg_temp.act('00000000-0000-0000-0000-0000000000a5');
select lives_ok(
  $$ insert into public.support_messages (ticket_id, body, author_kind) values ('00000000-0000-0000-0000-00000000c001', 'İnceliyoruz.', 'staff') $$,
  'platform staff reply'
);
select is(
  (select (status, last_message_by)::text from public.support_tickets where id = '00000000-0000-0000-0000-00000000c001'),
  '(in_progress,staff)', 'the first staff reply moves the ticket to in progress'
);
select is(
  (select author_id from public.support_messages where ticket_id = '00000000-0000-0000-0000-00000000c001' and author_kind = 'staff'),
  '00000000-0000-0000-0000-0000000000a5'::uuid, 'staff replies record the staff member'
);
select lives_ok(
  $$ update public.support_tickets set status = 'resolved' where id = '00000000-0000-0000-0000-00000000c001' $$,
  'platform staff resolve a ticket'
);

set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000000f3');
select lives_ok(
  $$ insert into public.support_messages (ticket_id, body) values ('00000000-0000-0000-0000-00000000c001', 'Hâlâ olmuyor.') $$,
  'the sender answers a resolved ticket'
);
select is(
  (select status from public.support_tickets where id = '00000000-0000-0000-0000-00000000c001'), 'open',
  'an answer reopens a resolved ticket'
);
reset role;

select pg_temp.act('00000000-0000-0000-0000-0000000000a5');
update public.support_tickets set status = 'closed' where id = '00000000-0000-0000-0000-00000000c001';
set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000000f3');
select throws_ok(
  $$ insert into public.support_messages (ticket_id, body) values ('00000000-0000-0000-0000-00000000c001', 'bir şey daha') $$,
  'P0001', 'ticket_closed', 'closed tickets take no replies'
);

-- Abuse limit: five tickets a day ----------------------------------------------------------------
select lives_ok(
  $$ select public.create_support_ticket(gen_random_uuid(), 'request', 'Talep ' || i, 'Metin') from generate_series(2, 5) i $$,
  'up to five tickets a day'
);
select throws_ok(
  $$ select public.create_support_ticket(gen_random_uuid(), 'request', 'Altıncı', 'Metin') $$,
  'P0001', 'ticket_rate_limited', 'the sixth ticket of the day is refused'
);
reset role;

-- Storage ------------------------------------------------------------------------------------------
select is((select public from storage.buckets where id = 'support-attachments'), false, 'attachments are private');

set local role authenticated;
select pg_temp.act('00000000-0000-0000-0000-0000000000f3');
select lives_ok(
  $$ insert into storage.objects (bucket_id, name, owner_id)
     values ('support-attachments', '00000000-0000-0000-0000-0000000000f3/00000000-0000-0000-0000-00000000c001-1.png', '00000000-0000-0000-0000-0000000000f3') $$,
  'the sender uploads into their own folder'
);
select throws_ok(
  $$ insert into storage.objects (bucket_id, name, owner_id)
     values ('support-attachments', '00000000-0000-0000-0000-0000000000f1/x-1.png', '00000000-0000-0000-0000-0000000000f3') $$,
  '42501', null, 'nobody uploads into someone else''s folder'
);
select pg_temp.act('00000000-0000-0000-0000-0000000000f2');
select is((select count(*)::int from storage.objects where bucket_id = 'support-attachments'), 0, 'others cannot see attachments');
select pg_temp.act('00000000-0000-0000-0000-0000000000a5');
select is((select count(*)::int from storage.objects where bucket_id = 'support-attachments'
           and name like '00000000-0000-0000-0000-0000000000f3/%'), 1, 'platform staff see attachments');
reset role;

-- Deleting the account removes the tickets --------------------------------------------------------
delete from auth.users where id = '00000000-0000-0000-0000-0000000000f3';
select is(
  (select count(*)::int from public.support_tickets where user_id = '00000000-0000-0000-0000-0000000000f3'), 0,
  'tickets go with the account'
);

select * from finish();
rollback;
