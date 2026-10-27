-- Security verification (docs/ARCHITECTURE.md §3h): backend-only tables, the unverified role and the token hook.
begin;
create extension if not exists pgtap with schema extensions;

select plan(18);

insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-00000000ff01', 's1@test.local', 'authenticated', 'authenticated');
insert into auth.sessions (id, user_id, created_at, updated_at) values
  ('00000000-0000-0000-0000-00000000ff51', '00000000-0000-0000-0000-00000000ff01', now(), now());

create function pg_temp.role_for(sid text) returns text language sql as $$
  select private.custom_access_token_hook(jsonb_build_object(
    'user_id', '00000000-0000-0000-0000-00000000ff01',
    'claims', jsonb_build_object('role', 'authenticated', 'session_id', sid))) #>> '{claims,role}';
$$;

-- The hook ----------------------------------------------------------------------------------
select is(pg_temp.role_for('00000000-0000-0000-0000-00000000ff51'), 'authenticated', 'zorlama kapalıyken rol değişmez');

update public.security_settings set enforce = true;
select is(pg_temp.role_for('00000000-0000-0000-0000-00000000ff51'), 'unverified', 'doğrulanmamış oturum unverified olur');

insert into public.phone_verifications (user_id, phone, country) values ('00000000-0000-0000-0000-00000000ff01', '+905320000001', 'TR');
insert into public.user_security (user_id, allowed_country, location_checked_at) values ('00000000-0000-0000-0000-00000000ff01', 'TR', now());
insert into public.verified_sessions (session_id, user_id, method) values
  ('00000000-0000-0000-0000-00000000ff51', '00000000-0000-0000-0000-00000000ff01', 'phone');
select is(pg_temp.role_for('00000000-0000-0000-0000-00000000ff51'), 'authenticated', 'doğrulanmış oturum authenticated kalır');
select is(pg_temp.role_for('00000000-0000-0000-0000-00000000ff99'), 'unverified', 'başka bir oturum doğrulanmış sayılmaz');
select is(pg_temp.role_for(''), 'unverified', 'oturumsuz token doğrulanmış sayılmaz');

update public.user_security set location_checked_at = now() - interval '25 hours';
select is(pg_temp.role_for('00000000-0000-0000-0000-00000000ff51'), 'unverified', '24 saati geçen konum doğrulamayı düşürür');

update public.user_security set location_checked_at = now(), state = 'restricted';
select is(pg_temp.role_for('00000000-0000-0000-0000-00000000ff51'), 'unverified', 'kısıtlı hesap doğrulanmış sayılmaz');
update public.user_security set state = 'ok';

delete from auth.sessions where id = '00000000-0000-0000-0000-00000000ff51';
select is((select count(*)::int from public.verified_sessions), 0, 'oturum silinince doğrulaması da silinir');

select ok(has_function_privilege('supabase_auth_admin', 'private.custom_access_token_hook(jsonb)', 'execute'), 'Auth hook''u çağırabilir');
select ok(not has_function_privilege('authenticated', 'private.custom_access_token_hook(jsonb)', 'execute'), 'istemci hook''u çağıramaz');
select ok(not has_function_privilege('authenticated', 'private.is_session_verified(uuid, uuid)', 'execute'), 'istemci doğrulama fonksiyonunu çağıramaz');

-- Clients never touch the security tables -----------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000ff01","role":"authenticated"}', true);

select throws_ok($$ select * from public.phone_verifications $$, '42501', null, 'kullanıcı kendi numarasını bile doğrudan okuyamaz');
select throws_ok($$ select * from public.security_settings $$, '42501', null, 'kullanıcı zorlama ayarını okuyamaz');
select throws_ok($$ update public.user_security set state = 'ok' $$, '42501', null, 'kullanıcı kendi kısıtlamasını kaldıramaz');
select throws_ok($$ insert into public.verified_sessions (session_id, user_id, method) values (gen_random_uuid(), auth.uid(), 'sms') $$,
  '42501', null, 'kullanıcı oturumunu kendisi doğrulayamaz');
select throws_ok($$ select * from public.totp_factors $$, '42501', null, 'kullanıcı TOTP anahtarını okuyamaz');

-- The unverified role reads published legal texts and nothing else -----------------------------
-- (It cannot even see the pgTAP functions, so this is checked from outside the role.)
reset role;
select ok(
  has_table_privilege('unverified', 'public.legal_documents', 'select')
    and exists (select 1 from pg_policies where tablename = 'legal_documents' and 'unverified' = any(roles)),
  'unverified hukuki metinleri okur');
select is(
  (select count(*)::int from information_schema.role_table_grants
   where grantee = 'unverified' and not (table_schema = 'public' and table_name = 'legal_documents')),
  0, 'unverified başka hiçbir tabloya erişemez');
select * from finish();
rollback;
