begin;
create extension if not exists pgtap with schema extensions;

select plan(10);

insert into auth.users (id, email, aud, role)
select ('00000000-0000-0000-0000-0000000fe10' || i)::uuid, 'presence' || i || '@test.local', 'authenticated', 'authenticated'
from generate_series(1, 2) i;

create function pg_temp.act(uid uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;
create function pg_temp.u(i int) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000000fe10' || i)::uuid $$;

select ok((select relrowsecurity from pg_class where oid = 'public.user_presence'::regclass), 'RLS is on');

set local role anon;
select throws_ok('select public.touch_presence(''web'')', '42501', null, 'anonymous visitors cannot report presence');
reset role;

select pg_temp.act(pg_temp.u(1));
set local role authenticated;
select lives_ok('select public.touch_presence(''android'')', 'a signed-in person reports their own presence');
select throws_ok('select public.touch_presence(''desktop'')', '22023', null, 'unknown platforms are refused');
select is_empty('select * from public.user_presence', 'nobody reads the table directly, not even their own row');
select throws_ok(
  $$insert into public.user_presence (user_id, platform) values ('00000000-0000-0000-0000-0000000fe102', 'web')$$,
  '42501', null, 'nobody writes rows for someone else');
update public.user_presence set platform = 'web';
reset role;

select is((select platform from public.user_presence where user_id = pg_temp.u(1)), 'android', 'the beat is stored; a direct update changed nothing');
select is((select count(*)::int from public.user_presence where user_id = pg_temp.u(2)), 0, 'the other person has no row');

set local role authenticated;
select public.leave_presence();
reset role;
select isnt((select left_at from public.user_presence where user_id = pg_temp.u(1)), null, 'leaving marks the person offline');

set local role authenticated;
select public.touch_presence('web');
reset role;
select is((select left_at from public.user_presence where user_id = pg_temp.u(1)), null, 'coming back marks them online again');

select * from finish();
rollback;
