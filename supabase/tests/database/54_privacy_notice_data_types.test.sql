begin;
create extension if not exists pgtap with schema extensions;

select plan(3);

-- The newest privacy notice names what the Play data safety form declares (0066).
create function pg_temp.notice() returns text language sql as $$
  select body from public.legal_documents where kind = 'privacy_notice' order by version desc limit 1
$$;

select ok(pg_temp.notice() like '%telefon numaran%', 'the privacy notice names the phone number');
select ok(pg_temp.notice() like '%yalnızca ülke%' and pg_temp.notice() like '%doğum tarihin%', 'and location (country only) and birth date');
select ok(pg_temp.notice() like '%cihaz jetonu%', 'and the device token');

select finish();
rollback;
