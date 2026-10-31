-- Local demo data. Applied by `supabase db reset` (never in production).
-- Every account below uses the password: Demo1234
--
--   demo@gway.test   regular user with a finished profile
--   admin@gway.test  platform admin (use in the admin panel)
--   + a few extra users so the admin list has suspended / pending-deletion rows
--   + groups: demo owns "Doğa Yürüyüşçüleri" (request) with a pending request,
--     is a member of two others and has an invitation waiting; one group is suspended
--   + billing: demo's group is on Başlangıç (paid through PayTR for three months),
--     İstanbul Koşu is on yearly Pro (iyzico, USD), Suluboya's plan ends in a few days,
--     Akustik Geceler has a failed and an abandoned order
--   + support: demo has an answered problem (unread reply) and a request about
--     their group; other accounts have open, resolved and closed messages

create temporary table seed_users (id uuid, email text, username text, display_name text, bio text) on commit drop;

insert into seed_users values
  ('10000000-0000-0000-0000-000000000001', 'demo@gway.test',   'demo',          'Demo Kullanıcı', 'Hafta sonları doğa yürüyüşü, akşamları gitar.'),
  ('10000000-0000-0000-0000-000000000002', 'admin@gway.test',  'gway_ekip',    'GWAY Ekibi',    ''),
  ('10000000-0000-0000-0000-000000000003', 'elif@gway.test',   'elif.kosar',    'Elif Koşar',     'Maraton hazırlığındayım.'),
  ('10000000-0000-0000-0000-000000000004', 'mert@gway.test',   'mert_pedal',    'Mert Pedal',     'Bisikletle şehir turları.'),
  ('10000000-0000-0000-0000-000000000005', 'zeynep@gway.test', 'zeynep.sanat',  'Zeynep Sanat',   'Suluboya ve seramik.'),
  ('10000000-0000-0000-0000-000000000006', 'can@gway.test',    'can_dag',       'Can Dağ',        ''),
  ('10000000-0000-0000-0000-000000000007', 'ayse@gway.test',   'ayse.yildiz',   'Ayşe Yıldız',    'Fotoğraf ve kamp.'),
  ('10000000-0000-0000-0000-000000000008', 'burak@gway.test',  'burak.muzik',   'Burak Akor',     'Akustik gitar, açık mikrofon geceleri.');

insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at, last_sign_in_at,
  confirmation_token, recovery_token, email_change_token_new, email_change
)
select
  '00000000-0000-0000-0000-000000000000', id, 'authenticated', 'authenticated', email,
  extensions.crypt('Demo1234', extensions.gen_salt('bf')), now(),
  '{"provider":"email","providers":["email"]}', '{}', now() - interval '20 days', now(), null,
  '', '', '', ''
from seed_users;

insert into auth.identities (id, user_id, provider_id, provider, identity_data, created_at, updated_at, last_sign_in_at)
select gen_random_uuid(), id, id::text, 'email',
       jsonb_build_object('sub', id::text, 'email', email, 'email_verified', true),
       now(), now(), null
from seed_users;

-- KVKK consents for the latest version of each document.
insert into public.consents (user_id, kind, version)
select u.id, d.kind, d.version
from seed_users u
cross join public.legal_documents d;

-- Every demo account is an adult (18+ limit, docs/ARCHITECTURE.md §3a).
insert into public.birth_dates (user_id, birth_date)
select u.id, date '1995-06-15' from seed_users u;

insert into public.profiles (id, username, display_name, bio)
select id, username, display_name, bio from seed_users;

insert into public.profile_interests (user_id, category_slug) values
  ('10000000-0000-0000-0000-000000000001', 'hiking'),
  ('10000000-0000-0000-0000-000000000001', 'music'),
  ('10000000-0000-0000-0000-000000000001', 'nature'),
  ('10000000-0000-0000-0000-000000000003', 'running'),
  ('10000000-0000-0000-0000-000000000004', 'cycling'),
  ('10000000-0000-0000-0000-000000000005', 'art'),
  ('10000000-0000-0000-0000-000000000005', 'photography');

insert into public.platform_staff (user_id, role)
values ('10000000-0000-0000-0000-000000000002', 'admin');

-- One suspended and one pending-deletion account for the admin panel.
update public.account_status
set status = 'suspended', suspension_reason = 'Demo: spam paylaşımları', suspended_until = now() + interval '7 days'
where user_id = '10000000-0000-0000-0000-000000000006';
update auth.users set banned_until = now() + interval '7 days'
where id = '10000000-0000-0000-0000-000000000006';

update public.account_status
set status = 'pending_deletion', deletion_requested_at = now(), deletion_scheduled_for = now() + interval '30 days'
where user_id = '10000000-0000-0000-0000-000000000004';

-- Groups ---------------------------------------------------------------------
-- Group triggers re-check every write against the acting user (request.jwt.claims),
-- so each block acts as the user who would make that change.
create function pg_temp.act(uid uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid)::text, false);
$$;

-- demo: Doğa Yürüyüşçüleri (request). Zeynep is admin, Elif moderator; Ayşe has a pending request.
select pg_temp.act('10000000-0000-0000-0000-000000000001');
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id, about, rules, links) values (
  '20000000-0000-0000-0000-000000000001', 'doga.yuruyus', 'Doğa Yürüyüşçüleri', 'hiking', 'request',
  '10000000-0000-0000-0000-000000000001',
  'İstanbul çevresinde hafta sonu doğa yürüyüşleri düzenliyoruz. Her seviyeden yürüyüşçüye açığız.',
  E'Rotaya çıkmadan önce ekipmanını kontrol et.\nDoğaya saygılı ol, çöpünü geri getir.\nGrup liderinin talimatlarına uy.',
  '[{"label": "Instagram", "url": "https://instagram.com/doga.yuruyus"}]'
);
insert into public.group_members (group_id, user_id)
values ('20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001');
insert into public.group_invitations (group_id, user_id) values
  ('20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000003'),
  ('20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000005');

select pg_temp.act('10000000-0000-0000-0000-000000000003');
insert into public.group_members (group_id, user_id) values ('20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000003');
delete from public.group_invitations where group_id = '20000000-0000-0000-0000-000000000001' and user_id = '10000000-0000-0000-0000-000000000003';
select pg_temp.act('10000000-0000-0000-0000-000000000005');
insert into public.group_members (group_id, user_id) values ('20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000005');
delete from public.group_invitations where group_id = '20000000-0000-0000-0000-000000000001' and user_id = '10000000-0000-0000-0000-000000000005';
select pg_temp.act('10000000-0000-0000-0000-000000000007');
insert into public.group_join_requests (group_id, user_id) values ('20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000007');

select pg_temp.act('10000000-0000-0000-0000-000000000001');
insert into public.group_member_roles (group_id, user_id, role) values
  ('20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000005', 'admin'),
  ('20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000003', 'moderator');

-- Elif: İstanbul Koşu Kulübü (open). demo and Ayşe joined; demo sits on the discipline board.
select pg_temp.act('10000000-0000-0000-0000-000000000003');
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id, about) values (
  '20000000-0000-0000-0000-000000000002', 'istanbul.kosu', 'İstanbul Koşu Kulübü', 'running', 'open',
  '10000000-0000-0000-0000-000000000003', 'Her pazar sabahı Caddebostan sahilinde 10K koşuyoruz.'
);
insert into public.group_members (group_id, user_id) values ('20000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000003');
select pg_temp.act('10000000-0000-0000-0000-000000000001');
insert into public.group_members (group_id, user_id) values ('20000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001');
select pg_temp.act('10000000-0000-0000-0000-000000000007');
insert into public.group_members (group_id, user_id) values ('20000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000007');
select pg_temp.act('10000000-0000-0000-0000-000000000003');
insert into public.group_member_roles (group_id, user_id, role)
values ('20000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', 'discipline');

-- Burak: Akustik Geceler (invite). demo is a member, Zeynep is invited.
select pg_temp.act('10000000-0000-0000-0000-000000000008');
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id, about) values (
  '20000000-0000-0000-0000-000000000003', 'akustik.geceler', 'Akustik Geceler', 'music', 'invite',
  '10000000-0000-0000-0000-000000000008', 'Ayda bir buluşup akustik dinletiler ve açık mikrofon geceleri yapıyoruz.'
);
insert into public.group_members (group_id, user_id) values ('20000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000008');
insert into public.group_invitations (group_id, user_id) values
  ('20000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000001'),
  ('20000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000005');
select pg_temp.act('10000000-0000-0000-0000-000000000001');
insert into public.group_members (group_id, user_id) values ('20000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000001');
delete from public.group_invitations where group_id = '20000000-0000-0000-0000-000000000003' and user_id = '10000000-0000-0000-0000-000000000001';

-- Zeynep: Suluboya Atölyesi (invite). demo has an invitation waiting.
select pg_temp.act('10000000-0000-0000-0000-000000000005');
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id, about) values (
  '20000000-0000-0000-0000-000000000004', 'suluboya', 'Suluboya Atölyesi', 'art', 'invite',
  '10000000-0000-0000-0000-000000000005', 'Kadıköy''de haftalık suluboya buluşmaları.'
);
insert into public.group_members (group_id, user_id) values ('20000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000005');
insert into public.group_invitations (group_id, user_id) values ('20000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000001');

-- Ayşe: Pedal Kadıköy (open), suspended by the platform admin.
select pg_temp.act('10000000-0000-0000-0000-000000000007');
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id, about) values (
  '20000000-0000-0000-0000-000000000005', 'pedal.kadikoy', 'Pedal Kadıköy', 'cycling', 'open',
  '10000000-0000-0000-0000-000000000007', 'Kadıköy''den sahil boyunca akşam sürüşleri.'
);
insert into public.group_members (group_id, user_id) values ('20000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000007');
select pg_temp.act('10000000-0000-0000-0000-000000000002');
update public.groups set status = 'suspended', suspended_at = now(), suspension_reason = 'Demo: sahte etkinlik ilanları'
where id = '20000000-0000-0000-0000-000000000005';

-- Billing --------------------------------------------------------------------
-- Orders are opened as their buyer (the trigger checks billing.manage and the
-- list price), then settled as the payment notification would.
create function pg_temp.paid_order(
  order_id uuid, target_group uuid, buyer uuid, plan text, period text, provider text, country text,
  currency text, amount int, paid timestamptz, starts timestamptz, ends timestamptz
) returns void language plpgsql as $$
declare
  subscription uuid;
begin
  perform pg_temp.act(buyer);
  insert into public.billing_orders (id, group_id, group_name, group_handle, buyer_id, plan_slug, period, provider,
                                     country, currency, amount_minor, billing_details, sales_terms_version,
                                     provider_token, created_at)
  select order_id, g.id, g.name, g.handle, buyer, plan, period, provider, country, currency, amount,
         jsonb_build_object('firstName', p.display_name, 'lastName', 'Demo', 'phone', '+90 555 000 00 00',
                            'address', 'Moda Caddesi No: 1', 'city', 'İstanbul', 'country', 'Türkiye'),
         1, 'demo-' || order_id, paid - interval '2 minutes'
  from public.groups g, public.profiles p
  where g.id = target_group and p.id = buyer;
  update public.billing_orders set status = 'paid', paid_at = paid, provider_payment_id = 'demo-pay-' || left(order_id::text, 8)
  where id = order_id;
  insert into public.group_subscriptions (group_id, plan_slug, period, order_id, starts_at, ends_at, created_at)
  values (target_group, plan, period, order_id, starts, ends, paid)
  returning id into subscription;
  insert into public.audit_log (occurred_at, actor_kind, action, target_type, target_id, group_id, data)
  values (paid, 'system', 'subscription.activated', 'subscription', subscription::text, target_group,
          jsonb_build_object('plan', plan, 'period', period, 'orderId', order_id, 'amountMinor', amount, 'currency', currency));
end;
$$;

-- demo: three consecutive monthly Başlangıç periods; the current one ends in about 20 days.
select pg_temp.paid_order('30000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001',
  '10000000-0000-0000-0000-000000000001', 'starter', 'month', 'paytr', 'TR', 'TRY', 24900,
  now() - interval '2 months 10 days', now() - interval '2 months 10 days', now() - interval '1 month 10 days');
select pg_temp.paid_order('30000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001',
  '10000000-0000-0000-0000-000000000001', 'starter', 'month', 'paytr', 'TR', 'TRY', 24900,
  now() - interval '1 month 12 days', now() - interval '1 month 10 days', now() - interval '10 days');
select pg_temp.paid_order('30000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000001',
  '10000000-0000-0000-0000-000000000001', 'starter', 'month', 'paytr', 'TR', 'TRY', 24900,
  now() - interval '10 days', now() - interval '10 days', now() - interval '10 days' + interval '1 month');

-- Elif: yearly Pro, paid from abroad through iyzico in USD.
select pg_temp.paid_order('30000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000002',
  '10000000-0000-0000-0000-000000000003', 'pro', 'year', 'iyzico', 'DE', 'USD', 24990,
  now() - interval '45 days', now() - interval '45 days', now() - interval '45 days' + interval '1 year');

-- Zeynep: monthly Başlangıç that ends in four days (renewal reminder).
select pg_temp.paid_order('30000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000004',
  '10000000-0000-0000-0000-000000000005', 'starter', 'month', 'paytr', 'TR', 'TRY', 24900,
  now() + interval '4 days' - interval '1 month', now() + interval '4 days' - interval '1 month', now() + interval '4 days');

-- Burak: a declined card two days ago and a checkout left open three hours ago.
select pg_temp.act('10000000-0000-0000-0000-000000000008');
insert into public.billing_orders (id, group_id, group_name, group_handle, buyer_id, plan_slug, period, provider,
                                   country, currency, amount_minor, billing_details, sales_terms_version, created_at)
values
  ('30000000-0000-0000-0000-000000000006', '20000000-0000-0000-0000-000000000003', 'Akustik Geceler', 'akustik.geceler',
   '10000000-0000-0000-0000-000000000008', 'pro', 'month', 'paytr', 'TR', 'TRY', 69900,
   '{"firstName":"Burak","lastName":"Akor","phone":"+90 555 111 11 11","address":"Caferağa Mah. 2","city":"İstanbul","country":"Türkiye"}',
   1, now() - interval '2 days'),
  ('30000000-0000-0000-0000-000000000007', '20000000-0000-0000-0000-000000000003', 'Akustik Geceler', 'akustik.geceler',
   '10000000-0000-0000-0000-000000000008', 'starter', 'month', 'paytr', 'TR', 'TRY', 24900,
   '{"firstName":"Burak","lastName":"Akor","phone":"+90 555 111 11 11","address":"Caferağa Mah. 2","city":"İstanbul","country":"Türkiye"}',
   1, now() - interval '3 hours');
update public.billing_orders set status = 'failed', failure_reason = 'paytr:6'
where id = '30000000-0000-0000-0000-000000000006';

-- Support ----------------------------------------------------------------------
-- Users open tickets through the RPC (as themselves); the platform admin answers.
select pg_temp.act('10000000-0000-0000-0000-000000000001');
select public.create_support_ticket('40000000-0000-0000-0000-000000000001', 'problem',
  'Kapak fotoğrafı yüklenirken hata', 'Profilime kapak fotoğrafı seçince "Bir şeyler ters gitti" uyarısı çıkıyor. Telefonum Android.');
select public.create_support_ticket('40000000-0000-0000-0000-000000000002', 'request',
  'Grup adresini değiştirmek istiyorum', 'Doğa Yürüyüşçüleri için @doga.istanbul adresini kullanmak istiyoruz. Mümkün mü?',
  '20000000-0000-0000-0000-000000000001');

select pg_temp.act('10000000-0000-0000-0000-000000000005');
select public.create_support_ticket('40000000-0000-0000-0000-000000000003', 'suggestion',
  'Organizasyonlar için takvim görünümü', 'Atölyelerimizi aylık takvimde görebilmek çok işimize yarar.',
  '20000000-0000-0000-0000-000000000004');

select pg_temp.act('10000000-0000-0000-0000-000000000008');
select public.create_support_ticket('40000000-0000-0000-0000-000000000004', 'problem',
  'Ödeme sayfası açılmadı', 'Pro paketini almak istedim ama kartım reddedildi. Tekrar denemem gerekir mi?',
  '20000000-0000-0000-0000-000000000003');

select pg_temp.act('10000000-0000-0000-0000-000000000003');
select public.create_support_ticket('40000000-0000-0000-0000-000000000005', 'request',
  'E-posta adresimi değiştirmek istiyorum', 'Yeni iş e-postamı kullanmak istiyorum.');

select pg_temp.act('10000000-0000-0000-0000-000000000002');
insert into public.support_messages (ticket_id, author_kind, body) values
  ('40000000-0000-0000-0000-000000000001', 'staff',
   'Merhaba, bildirdiğin için teşekkürler. Sorunu inceliyoruz; görselin 5 MB''tan küçük ve JPEG/PNG olduğundan emin olabilir misin?'),
  ('40000000-0000-0000-0000-000000000003', 'staff',
   'Harika bir öneri! Takvim görünümünü organizasyonlar özelliğiyle birlikte planlıyoruz.'),
  ('40000000-0000-0000-0000-000000000005', 'staff',
   'E-posta adresini Ayarlar > Hesap üzerinden kendin değiştirebilirsin. Başka bir sorun olursa yeni mesaj açabilirsin.');
update public.support_tickets set status = 'resolved' where id = '40000000-0000-0000-0000-000000000003';
update public.support_tickets set status = 'closed' where id = '40000000-0000-0000-0000-000000000005';
-- Everything above happens in one transaction (same now()); make the reply to demo unread.
update public.support_tickets set user_read_at = now() - interval '1 hour' where id = '40000000-0000-0000-0000-000000000001';

-- Follows -------------------------------------------------------------------------
-- demo and Elif follow each other (friends); demo follows Burak; Zeynep is private
-- with requests waiting from demo and Ayşe.
update public.profiles set is_private = true where id = '10000000-0000-0000-0000-000000000005';
select pg_temp.act('10000000-0000-0000-0000-000000000001');
insert into public.follows (follower_id, followee_id) values
  ('10000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000003'),
  ('10000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000008');
insert into public.follow_requests (requester_id, target_id) values
  ('10000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000005');
select pg_temp.act('10000000-0000-0000-0000-000000000003');
insert into public.follows (follower_id, followee_id) values
  ('10000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000001');
select pg_temp.act('10000000-0000-0000-0000-000000000007');
insert into public.follow_requests (requester_id, target_id) values
  ('10000000-0000-0000-0000-000000000007', '10000000-0000-0000-0000-000000000005');

select set_config('request.jwt.claims', '', false);
