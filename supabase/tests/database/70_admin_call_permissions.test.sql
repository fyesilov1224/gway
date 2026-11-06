begin;
create extension if not exists pgtap with schema extensions;

select plan(12);

-- s1 admin, s2 support, s3 moderator; p4 p5 people.
insert into auth.users (id, email, aud, role)
select ('00000000-0000-0000-0000-0000000ac00' || i)::uuid, 'ac' || i || '@test.local', 'authenticated', 'authenticated'
from generate_series(1, 5) i;
insert into public.profiles (id, username, display_name)
select ('00000000-0000-0000-0000-0000000ac00' || i)::uuid, 'adm_call' || i, 'Adm ' || i
from generate_series(1, 5) i;
insert into public.platform_staff (user_id, role) values
  ('00000000-0000-0000-0000-0000000ac001', 'admin'),
  ('00000000-0000-0000-0000-0000000ac002', 'support'),
  ('00000000-0000-0000-0000-0000000ac003', 'moderator');

create function pg_temp.act(i int) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', ('00000000-0000-0000-0000-0000000ac00' || i), 'role', 'authenticated')::text, true);
$$;
create function pg_temp.u(i int) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000000ac00' || i)::uuid $$;

-- A waiting request of p5, written as the person's own request would be (its group rules are tested in 59).
set local session_replication_role = replica;
insert into public.call_permissions (user_id, status, note, requested_at) values (pg_temp.u(5), 'requested', 'Lütfen', now());
set local session_replication_role = origin;

-- The admin opens it for someone who never asked; the decision is the admin's.
select pg_temp.act(1);
select lives_ok($$ insert into public.call_permissions (user_id, status) values (pg_temp.u(4), 'active') $$,
  'an admin opens voice calls for a person directly');
select is((select decided_by from public.call_permissions where user_id = pg_temp.u(4)), pg_temp.u(1), 'the decision names the admin');
select throws_ok($$ insert into public.call_permissions (user_id, status) values (pg_temp.u(1), 'active') $$, 'P0001', 'call_forbidden',
  'not on their own permission');
select lives_ok($$ update public.call_permissions set status = 'revoked', reason = 'Kötüye kullanım' where user_id = pg_temp.u(4) $$,
  'an admin closes it');
select lives_ok($$ update public.call_permissions set status = 'active', reason = null where user_id = pg_temp.u(4) $$,
  'and opens it again');
select throws_ok($$ update public.call_permissions set status = 'declined' where user_id = pg_temp.u(4) $$, 'P0001', 'call_forbidden',
  'an open permission is closed, not declined');

-- Support declines a waiting request.
select pg_temp.act(2);
select lives_ok($$ update public.call_permissions set status = 'declined', reason = 'Eksik bilgi' where user_id = pg_temp.u(5) $$,
  'support declines a waiting request');
select is((select decided_by from public.call_permissions where user_id = pg_temp.u(5)), pg_temp.u(2), 'the decision names support');
select throws_ok($$ insert into public.call_permissions (user_id, status) values (pg_temp.u(3), 'declined') $$, 'P0001', 'call_forbidden',
  'a new row is only ever an opened permission');

-- A moderator sees the panel but decides nothing; nor does anyone else.
select pg_temp.act(3);
select throws_ok($$ update public.call_permissions set status = 'revoked', reason = 'x' where user_id = pg_temp.u(4) $$, 'P0001', 'call_forbidden',
  'a moderator cannot close it');
select pg_temp.act(5);
select throws_ok($$ update public.call_permissions set status = 'revoked', reason = 'x' where user_id = pg_temp.u(4) $$, 'P0001', 'call_forbidden',
  'a person cannot close someone else''s');

-- The panel reads through the backend: under RLS staff still see only their own row.
select pg_temp.act(1);
set local role authenticated;
select is((select count(*)::int from public.call_permissions where user_id in (pg_temp.u(4), pg_temp.u(5))), 0,
  'the platform team does not read the table directly');
reset role;

select * from finish();
rollback;
