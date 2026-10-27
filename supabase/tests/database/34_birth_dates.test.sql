-- 18+ age limit (docs/ARCHITECTURE.md §3a, Yaş sınırı).
begin;
create extension if not exists pgtap with schema extensions;

select plan(8);

insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-00000000bd01', 'b1@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000000bd02', 'b2@test.local', 'authenticated', 'authenticated');
insert into public.birth_dates (user_id, birth_date) values ('00000000-0000-0000-0000-00000000bd02', '1990-05-05');

set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000bd01","role":"authenticated"}', true);

select throws_ok(
  $$ insert into public.birth_dates (birth_date) values ((now() at time zone 'Europe/Istanbul')::date - interval '17 years') $$,
  'P0001', 'birth_date_under_18', '18 yaşından küçük kaydedilemez');
select throws_ok(
  $$ insert into public.birth_dates (birth_date) values ('1899-12-31') $$,
  'P0001', 'birth_date_invalid', '1900 öncesi tarih geçersiz');
select lives_ok(
  $$ insert into public.birth_dates (birth_date) values ('2000-01-01') $$,
  'kullanıcı kendi doğum tarihini bir kez ekler');
select throws_ok(
  $$ insert into public.birth_dates (user_id, birth_date) values ('00000000-0000-0000-0000-00000000bd02', '2000-01-01') $$,
  '42501', null, 'başkası adına eklenemez');
select is((select count(*)::int from public.birth_dates), 1, 'yalnızca kendi satırını görür');
select throws_ok(
  $$ update public.birth_dates set birth_date = '1995-01-01' $$,
  '42501', null, 'kullanıcı tarihini değiştiremez');
select throws_ok($$ delete from public.birth_dates $$, '42501', null, 'kullanıcı tarihini silemez');

reset role;
set local role anon;
select throws_ok($$ select * from public.birth_dates $$, '42501', null, 'anonim okuyamaz');

reset role;
select * from finish();
rollback;
