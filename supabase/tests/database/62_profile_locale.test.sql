begin;
create extension if not exists pgtap with schema extensions;

select plan(8);

insert into auth.users (id, email, aud, role)
select ('00000000-0000-0000-0000-00000007900' || i)::uuid, 'locale' || i || '@test.local', 'authenticated', 'authenticated'
from generate_series(1, 3) i;
insert into public.profiles (id, username, display_name)
select ('00000000-0000-0000-0000-00000007900' || i)::uuid, 'locale_user' || i, 'Locale ' || i
from generate_series(1, 2) i;

create function pg_temp.act(uid uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;
create function pg_temp.u(i int) returns uuid language sql as $$ select ('00000000-0000-0000-0000-00000007900' || i)::uuid $$;

select is((select locale from public.profiles where id = pg_temp.u(1)), 'tr', 'a new profile starts in Turkish');

select pg_temp.act(pg_temp.u(1));
set local role authenticated;
select lives_ok($$update public.profiles set locale = 'de' where id = '00000000-0000-0000-0000-000000079001'$$,
  'a person sets their own language');
select throws_ok($$update public.profiles set locale = 'xx' where id = '00000000-0000-0000-0000-000000079001'$$,
  '23514', null, 'only the 12 languages are accepted');
update public.profiles set locale = 'en' where id = pg_temp.u(2);
reset role;

select is((select locale from public.profiles where id = pg_temp.u(1)), 'de', 'their own language is stored');
select is((select locale from public.profiles where id = pg_temp.u(2)), 'tr', 'nobody changes someone else''s language');

set local role anon;
select throws_ok($$update public.profiles set locale = 'en'$$, '42501', null, 'anonymous visitors cannot write it');
reset role;

select pg_temp.act(pg_temp.u(3));
set local role authenticated;
select lives_ok($$insert into public.profiles (id, username, display_name, locale)
  values ('00000000-0000-0000-0000-000000079003', 'locale_user3', 'Locale 3', 'ar')$$, 'a new profile can start in the chosen language');
reset role;
select is((select locale from public.profiles where id = pg_temp.u(3)), 'ar', 'the chosen language is stored at creation');

select * from finish();
rollback;
