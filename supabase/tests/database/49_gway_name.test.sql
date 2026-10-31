begin;
create extension if not exists pgtap with schema extensions;

select plan(5);

-- The newest version of every legal text carries the new name ----------------------------------
select is_empty(
  $$ select kind from (
       select distinct on (kind) kind, title, body from public.legal_documents order by kind, version desc
     ) d where d.title like '%GrupX%' or d.body like '%GrupX%' $$,
  'no current legal text names GrupX'
);
select is(
  (select count(*)::int from (
     select distinct on (kind) kind, body from public.legal_documents order by kind, version desc
   ) d where d.body like '%GWAY%'),
  (select count(distinct kind)::int from public.legal_documents),
  'every current legal text names GWAY'
);
select ok(
  (select body from public.legal_documents where kind = 'terms' order by version desc limit 1) like '%GWAY''i kullanarak%',
  'Turkish suffixes follow the new name'
);

-- The old versions users agreed to stay as they were ---------------------------------------------
select ok(
  (select body from public.legal_documents where kind = 'terms' and version = 1) like '%GrupX%',
  'consented versions are not rewritten'
);

-- Both names are reserved ------------------------------------------------------------------------
select is(
  (select array[public.is_username_available('gway'), public.is_username_available('grupx')]),
  array[false, false],
  'gway and grupx are reserved usernames'
);

select * from finish();
rollback;
