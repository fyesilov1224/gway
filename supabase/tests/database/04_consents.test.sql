begin;
create extension if not exists pgtap with schema extensions;

select plan(10);

insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-0000000000b1', 'u1@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000b2', 'u2@test.local', 'authenticated', 'authenticated');

insert into public.consents (user_id, kind, version)
values ('00000000-0000-0000-0000-0000000000b2', 'terms', 1);

set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000b1","role":"authenticated"}', true);

select is(
  (select array_agg(kind order by kind) from public.pending_legal_documents()),
  array['community_rules', 'explicit_consent', 'privacy_notice', 'terms'],
  'new user has all four documents pending'
);

select lives_ok(
  $$ insert into public.consents (user_id, kind, version) values
       ('00000000-0000-0000-0000-0000000000b1', 'terms', 1),
       ('00000000-0000-0000-0000-0000000000b1', 'privacy_notice', 1),
       ('00000000-0000-0000-0000-0000000000b1', 'explicit_consent', 1),
       ('00000000-0000-0000-0000-0000000000b1', 'community_rules', 1) $$,
  'user can record their own consents'
);

select is_empty(
  $$ select * from public.pending_legal_documents() $$,
  'nothing pending after accepting the latest versions'
);

select is(
  (select count(*)::int from public.consents),
  4,
  'user sees only their own consents'
);

select throws_ok(
  $$ insert into public.consents (user_id, kind, version)
     values ('00000000-0000-0000-0000-0000000000b2', 'privacy_notice', 1) $$,
  '42501', null, 'user cannot consent on behalf of someone else'
);

select throws_ok(
  $$ insert into public.consents (user_id, kind, version, accepted_at)
     values ('00000000-0000-0000-0000-0000000000b1', 'terms', 1, '2000-01-01') $$,
  '42501', null, 'user cannot backdate accepted_at'
);

select throws_ok(
  $$ update public.consents set version = 1 $$,
  '42501', null, 'consents cannot be updated'
);

select throws_ok(
  $$ delete from public.consents $$,
  '42501', null, 'consents cannot be deleted'
);

-- A new published version becomes pending again.
reset role;
insert into public.legal_documents (kind, version, title, body)
values ('privacy_notice', 2, 'KVKK Aydınlatma Metni', 'Yeni sürüm');
set local role authenticated;

select results_eq(
  $$ select kind, version from public.pending_legal_documents() $$,
  $$ values ('privacy_notice'::text, 2) $$,
  'a new document version must be accepted again'
);

set local role anon;
select throws_ok(
  $$ select * from public.consents $$,
  '42501', null, 'anon cannot read consents'
);

select * from finish();
rollback;
