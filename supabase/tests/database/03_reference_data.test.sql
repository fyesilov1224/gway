begin;
create extension if not exists pgtap with schema extensions;

select plan(7);

-- An unpublished future version must stay hidden.
insert into public.legal_documents (kind, version, title, body, published_at)
values ('terms', 99, 'Gelecek sürüm', 'x', now() + interval '1 day');

set local role anon;

select ok((select count(*) from public.categories) >= 10, 'anon can read categories');
select ok(
  exists (select 1 from public.legal_documents where kind = 'privacy_notice'),
  'anon can read published legal documents'
);
select is_empty(
  $$ select 1 from public.legal_documents where version = 99 $$,
  'unpublished legal documents are hidden'
);
select throws_ok(
  $$ insert into public.categories (slug, name, sort_order) values ('x', 'X', 1) $$,
  '42501', null, 'anon cannot add categories'
);

set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000b1","role":"authenticated"}', true);

select throws_ok(
  $$ update public.categories set name = 'Hack' $$,
  '42501', null, 'users cannot edit categories'
);
select throws_ok(
  $$ insert into public.legal_documents (kind, version, title, body) values ('terms', 2, 't', 'b') $$,
  '42501', null, 'users cannot publish legal documents'
);
select throws_ok(
  $$ delete from public.legal_documents $$,
  '42501', null, 'users cannot delete legal documents'
);

select * from finish();
rollback;
