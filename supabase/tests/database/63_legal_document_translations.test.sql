begin;
create extension if not exists pgtap with schema extensions;

select plan(7);

insert into auth.users (id, email, aud, role)
values ('00000000-0000-0000-0000-000000080001', 'translations@test.local', 'authenticated', 'authenticated');

insert into public.legal_documents (kind, version, title, body, published_at)
values ('terms', 900, 'Deneme koşulları', 'Yayında olan deneme metni gövdesi.', now() - interval '1 day'),
       ('terms', 901, 'Taslak koşullar', 'Henüz yayımlanmamış taslak metin gövdesi.', now() + interval '1 day');
insert into public.legal_document_translations (kind, version, language, title, body)
values ('terms', 900, 'en', 'Trial terms', 'The body of the published trial text.'),
       ('terms', 901, 'en', 'Draft terms', 'The body of a draft text not yet published.');

select ok((select relrowsecurity from pg_class where oid = 'public.legal_document_translations'::regclass), 'RLS is on');

set local role anon;
select results_eq($$select title from public.legal_document_translations where version in (900, 901)$$,
  array['Trial terms'], 'visitors read translations of published versions only');
select throws_ok($$insert into public.legal_document_translations (kind, version, language, title, body)
  values ('terms', 900, 'de', 'Probebedingungen', 'Der Text der veröffentlichten Probe.')$$, '42501', null, 'visitors cannot write');
reset role;

select set_config('request.jwt.claims', json_build_object('sub', '00000000-0000-0000-0000-000000080001', 'role', 'authenticated')::text, true);
set local role authenticated;
select results_eq($$select title from public.legal_document_translations where version in (900, 901)$$,
  array['Trial terms'], 'signed-in people read the same');
select throws_ok($$update public.legal_document_translations set title = 'Changed' where version = 900$$, '42501', null,
  'signed-in people cannot change a translation');
reset role;

select throws_ok($$insert into public.legal_document_translations (kind, version, language, title, body)
  values ('terms', 900, 'tr', 'Türkçe çeviri', 'Türkçe asıl metindir, çevirisi olmaz.')$$, '23514', null, 'Turkish is the original, not a translation');

delete from public.legal_documents where kind = 'terms' and version = 901;
select is((select count(*)::int from public.legal_document_translations where version = 901), 0, 'deleting a version deletes its translations');

select * from finish();
rollback;
