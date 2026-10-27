begin;
create extension if not exists pgtap with schema extensions;

select plan(6);

-- A published terms v1 that a user consented to, and an unreferenced draft v2.
insert into auth.users (id, email, aud, role) values ('00000000-0000-0000-0000-00000000ee01', 'l1@test.local', 'authenticated', 'authenticated');
insert into public.profiles (id, username, display_name) values ('00000000-0000-0000-0000-00000000ee01', 'legal_one', 'L');
insert into public.legal_documents (kind, version, title, body, audience, published_at) values
  ('terms', 100, 'Koşullar v1', 'eski gövde', 'signup', now() - interval '10 days'),
  ('terms', 101, 'Koşullar v2', 'yeni taslak', 'signup', now() + interval '10 days');
insert into public.consents (user_id, kind, version) values ('00000000-0000-0000-0000-00000000ee01', 'terms', 100);

-- A consented version is frozen -----------------------------------------------------------
select throws_ok(
  $$ update public.legal_documents set body = 'degistirildi' where kind = 'terms' and version = 100 $$,
  'P0001', 'legal_consented_immutable', 'onaylı sürümün gövdesi değiştirilemez');
select throws_ok(
  $$ update public.legal_documents set title = 'baska' where kind = 'terms' and version = 100 $$,
  'P0001', 'legal_consented_immutable', 'onaylı sürümün başlığı değiştirilemez');
-- The foreign key stops the delete first; either error is a refusal.
select throws_ok(
  $$ delete from public.legal_documents where kind = 'terms' and version = 100 $$,
  null, 'onaylı sürüm silinemez');

-- An unreferenced version stays editable and deletable ------------------------------------
select lives_ok(
  $$ update public.legal_documents set body = 'guncellendi', title = 'Koşullar v2b' where kind = 'terms' and version = 101 $$,
  'onaysız taslak düzenlenebilir');
select lives_ok(
  $$ delete from public.legal_documents where kind = 'terms' and version = 101 $$,
  'onaysız taslak silinebilir');

-- Re-publishing the exact same values of a consented version is not a change --------------
select lives_ok(
  $$ update public.legal_documents set body = body where kind = 'terms' and version = 100 $$,
  'onaylı sürümde değişiklik olmayan update geçer');

select * from finish();
rollback;
