begin;
create extension if not exists pgtap with schema extensions;

select plan(6);

insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-0000000000b1', 'u1@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000b2', 'u2@test.local', 'authenticated', 'authenticated');

update public.account_status set status = 'suspended', suspension_reason = 'test'
where user_id = '00000000-0000-0000-0000-0000000000b2';

select is(
  (select public from storage.buckets where id = 'avatars'),
  true, 'avatars bucket is public'
);
select is(
  (select file_size_limit from storage.buckets where id = 'covers'),
  5242880::bigint, 'covers are limited to 5 MB'
);

set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000b1","role":"authenticated"}', true);

select lives_ok(
  $$ insert into storage.objects (bucket_id, name, owner_id)
     values ('avatars', '00000000-0000-0000-0000-0000000000b1/avatar.jpg', '00000000-0000-0000-0000-0000000000b1') $$,
  'user can upload into their own folder'
);
select throws_ok(
  $$ insert into storage.objects (bucket_id, name, owner_id)
     values ('avatars', '00000000-0000-0000-0000-0000000000b2/avatar.jpg', '00000000-0000-0000-0000-0000000000b1') $$,
  '42501', null, 'user cannot upload into someone else''s folder'
);
select throws_ok(
  $$ insert into storage.objects (bucket_id, name, owner_id)
     values ('covers', 'cover.jpg', '00000000-0000-0000-0000-0000000000b1') $$,
  '42501', null, 'upload outside any user folder is rejected'
);

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000b2","role":"authenticated"}', true);
select throws_ok(
  $$ insert into storage.objects (bucket_id, name, owner_id)
     values ('avatars', '00000000-0000-0000-0000-0000000000b2/avatar.jpg', '00000000-0000-0000-0000-0000000000b2') $$,
  '42501', null, 'suspended user cannot upload'
);

select * from finish();
rollback;
