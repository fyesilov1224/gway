-- Every table in public must have RLS enabled (default deny).
begin;
create extension if not exists pgtap with schema extensions;

select plan(2);

select is(
  (
    select coalesce(array_agg(c.relname::text order by c.relname), '{}')
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relkind in ('r', 'p')
      and not c.relrowsecurity
  ),
  '{}'::text[],
  'all public tables have RLS enabled'
);

select is(
  (
    select coalesce(array_agg(p.proname::text order by p.proname), '{}')
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.prosecdef
  ),
  '{}'::text[],
  'no SECURITY DEFINER functions in the exposed public schema'
);

select * from finish();
rollback;
