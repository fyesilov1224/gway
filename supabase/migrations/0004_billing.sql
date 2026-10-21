-- 0004_billing
-- Phase 3: plans and prices, orders, group subscriptions (prepaid timeline),
-- the member limit and the distance sales contract. Rules: docs/ARCHITECTURE.md §7.
--
-- Clients only read these tables. Orders and subscriptions are written by the
-- C# API: checkout as the buyer (request.jwt.claims), payment settlement as the
-- system (no actor), admin actions as the staff member. Triggers guard the
-- invariants a second time.

create extension if not exists btree_gist with schema extensions;

-- ---------------------------------------------------------------------------
-- Permission: billing.manage (owner only, so no role mapping)
-- ---------------------------------------------------------------------------
insert into public.group_permissions (slug, description) values
  ('billing.manage', 'Paket satın alma ve abonelik bilgilerini görme');

-- ---------------------------------------------------------------------------
-- plans, plan_prices
-- owner: billing
-- ---------------------------------------------------------------------------
create table public.plans (
  slug                 text primary key check (slug ~ '^[a-z_]+$'),
  name                 text not null check (char_length(btrim(name)) between 2 and 40),
  tier                 int  not null unique check (tier >= 0),
  max_members          int  not null check (max_members > 0),
  monthly_events       int  not null check (monthly_events >= 0),
  monthly_live_minutes int  not null check (monthly_live_minutes >= 0),
  is_active            boolean not null default true,
  updated_at           timestamptz not null default now(),
  constraint plans_free_is_tier_zero check ((slug = 'free') = (tier = 0))
);

comment on table public.plans is
  'owner: billing. Plan catalog and limits. Limits apply live to every group on the plan.';
comment on column public.plans.tier is 'Higher tier = upgrade. The free plan is tier 0.';
comment on column public.plans.is_active is 'On sale. Groups already on an inactive plan keep it until their period ends.';

create table public.plan_prices (
  plan_slug    text not null references public.plans (slug) on delete cascade,
  currency     text not null check (currency in ('TRY', 'USD')),
  period       text not null check (period in ('month', 'year')),
  amount_minor int  not null check (amount_minor > 0),
  primary key (plan_slug, currency, period),
  constraint plan_prices_not_free check (plan_slug <> 'free')
);

comment on table public.plan_prices is 'owner: billing. List prices in minor units (kuruş, cent). Orders copy the amount.';

insert into public.plans (slug, name, tier, max_members, monthly_events, monthly_live_minutes) values
  ('free',      'Ücretsiz',  0,    50,   2,    60),
  ('starter',   'Başlangıç', 1,   250,  10,   600),
  ('pro',       'Pro',       2,  1000,  40,  3000),
  ('community', 'Topluluk',  3, 10000, 200, 20000);

-- Yearly = 10 × monthly (two months free).
insert into public.plan_prices (plan_slug, currency, period, amount_minor) values
  ('starter',   'TRY', 'month',   24900), ('starter',   'TRY', 'year',   249000),
  ('starter',   'USD', 'month',     999), ('starter',   'USD', 'year',     9990),
  ('pro',       'TRY', 'month',   69900), ('pro',       'TRY', 'year',   699000),
  ('pro',       'USD', 'month',    2499), ('pro',       'USD', 'year',    24990),
  ('community', 'TRY', 'month',  199900), ('community', 'TRY', 'year',  1999000),
  ('community', 'USD', 'month',    6999), ('community', 'USD', 'year',    69990);

-- ---------------------------------------------------------------------------
-- billing_orders
-- owner: billing
-- A financial record: survives the group (set null) and the buyer's account
-- (no foreign key), and is never deleted.
-- ---------------------------------------------------------------------------
create table public.billing_orders (
  id                  uuid primary key default gen_random_uuid(),
  group_id            uuid references public.groups (id) on delete set null,
  group_name          text not null,
  group_handle        text not null,
  buyer_id            uuid not null,
  plan_slug           text not null references public.plans (slug),
  period              text not null check (period in ('month', 'year')),
  provider            text not null check (provider in ('paytr', 'iyzico')),
  country             text check (country ~ '^[A-Z]{2}$'),
  currency            text not null check (currency in ('TRY', 'USD')),
  amount_minor        int  not null check (amount_minor > 0),
  status              text not null default 'pending' check (status in ('pending', 'paid', 'failed', 'refunded')),
  failure_reason      text check (char_length(failure_reason) <= 200),
  billing_details     jsonb not null check (jsonb_typeof(billing_details) = 'object'),
  sales_terms_version int  not null check (sales_terms_version > 0),
  client_ip           inet,
  provider_token      text,
  provider_payment_id text,
  created_at          timestamptz not null default now(),
  paid_at             timestamptz,
  updated_at          timestamptz not null default now(),
  constraint billing_orders_paid_at check ((status in ('paid', 'refunded')) = (paid_at is not null)),
  constraint billing_orders_plan_not_free check (plan_slug <> 'free')
);

comment on table public.billing_orders is
  'owner: billing. Checkout orders. Settled only by verified provider notifications (backend).';
comment on column public.billing_orders.buyer_id is
  'auth.users id. Intentionally no foreign key: invoices are kept after account deletion (VUK).';
comment on column public.billing_orders.billing_details is
  'Invoice details entered at checkout: firstName, lastName, phone, address, city, country.';

create index billing_orders_buyer_idx on public.billing_orders (buyer_id, created_at desc);
create index billing_orders_group_idx on public.billing_orders (group_id, created_at desc);
create index billing_orders_status_idx on public.billing_orders (status, created_at desc);
create index billing_orders_paid_idx on public.billing_orders (paid_at) where paid_at is not null;
create unique index billing_orders_token_idx on public.billing_orders (provider, provider_token) where provider_token is not null;

-- ---------------------------------------------------------------------------
-- group_subscriptions
-- owner: billing
-- Each group's prepaid timeline: non-overlapping [starts_at, ends_at) slices.
-- Cancelling shortens ends_at (to starts_at for slices not started yet).
-- ---------------------------------------------------------------------------
create table public.group_subscriptions (
  id             uuid primary key default gen_random_uuid(),
  group_id       uuid not null references public.groups (id) on delete cascade,
  plan_slug      text not null references public.plans (slug),
  period         text not null check (period in ('month', 'year')),
  order_id       uuid not null unique references public.billing_orders (id),
  starts_at      timestamptz not null,
  ends_at        timestamptz not null,
  credit_seconds bigint not null default 0 check (credit_seconds >= 0),
  canceled_at    timestamptz,
  cancel_reason  text check (cancel_reason in ('upgraded', 'admin')),
  created_at     timestamptz not null default now(),
  constraint group_subscriptions_range check (ends_at >= starts_at),
  constraint group_subscriptions_cancel_consistent check ((canceled_at is null) = (cancel_reason is null)),
  constraint group_subscriptions_no_overlap
    exclude using gist (group_id with =, tstzrange(starts_at, ends_at) with &&)
);

comment on table public.group_subscriptions is
  'owner: billing. Paid plan slices per group. Current plan = slice containing now(), else free.';
comment on column public.group_subscriptions.credit_seconds is
  'Time carried over from replaced slices on an upgrade (already included in ends_at).';

create index group_subscriptions_group_idx on public.group_subscriptions (group_id, ends_at desc);

-- ---------------------------------------------------------------------------
-- Plan helpers
-- ---------------------------------------------------------------------------

-- Plan of the slice that contains now(); 'free' without one.
create function private.group_plan_slug(target_group uuid)
returns text
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(
    (select s.plan_slug from public.group_subscriptions s
     where s.group_id = target_group and s.starts_at <= now() and now() < s.ends_at
     limit 1),
    'free');
$$;

create function private.group_plan_limits(target_group uuid)
returns public.plans
language sql
stable
security definer
set search_path = ''
as $$
  select p.* from public.plans p where p.slug = private.group_plan_slug(target_group);
$$;

revoke all on function private.group_plan_slug(uuid) from public;
revoke all on function private.group_plan_limits(uuid) from public;
grant execute on function private.group_plan_slug(uuid) to authenticated, service_role;
grant execute on function private.group_plan_limits(uuid) to authenticated, service_role;

-- The group's current plan for its members and platform staff (plan card, limits).
-- SECURITY DEFINER because plain members may not read group_subscriptions.
create function private.group_plan_status(target_group uuid)
returns table (
  plan_slug              text,
  plan_name              text,
  tier                   int,
  max_members            int,
  monthly_events         int,
  monthly_live_minutes   int,
  member_count           int,
  current_period_ends_at timestamptz,
  paid_until             timestamptz
)
language sql
stable
security definer
set search_path = ''
as $$
  select p.slug, p.name, p.tier, p.max_members, p.monthly_events, p.monthly_live_minutes, g.member_count,
         (select s.ends_at from public.group_subscriptions s
          where s.group_id = g.id and s.starts_at <= now() and now() < s.ends_at limit 1),
         (select max(s.ends_at) from public.group_subscriptions s
          where s.group_id = g.id and s.ends_at > now() and s.ends_at > s.starts_at)
  from public.groups g
  cross join lateral private.group_plan_limits(g.id) p
  where g.id = target_group
    and (private.is_group_member(g.id) or private.is_platform_staff());
$$;

revoke all on function private.group_plan_status(uuid) from public;
grant execute on function private.group_plan_status(uuid) to authenticated, service_role;

-- RPC: see private.group_plan_status. Empty for non-members.
create function public.group_plan(target_group uuid)
returns table (
  plan_slug              text,
  plan_name              text,
  tier                   int,
  max_members            int,
  monthly_events         int,
  monthly_live_minutes   int,
  member_count           int,
  current_period_ends_at timestamptz,
  paid_until             timestamptz
)
language sql
stable
security invoker
set search_path = ''
as $$
  select * from private.group_plan_status(target_group);
$$;

revoke all on function public.group_plan(uuid) from public, anon;
grant execute on function public.group_plan(uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- RLS: clients read, never write
-- ---------------------------------------------------------------------------
alter table public.plans enable row level security;
alter table public.plan_prices enable row level security;
alter table public.billing_orders enable row level security;
alter table public.group_subscriptions enable row level security;

revoke all on public.plans, public.plan_prices, public.billing_orders, public.group_subscriptions from anon, authenticated;
grant select on public.plans, public.plan_prices to anon, authenticated;
grant select on public.billing_orders, public.group_subscriptions to authenticated;

create policy plans_select_all on public.plans for select to anon, authenticated using (true);
create policy plan_prices_select_all on public.plan_prices for select to anon, authenticated using (true);

create policy billing_orders_select_buyer_or_staff
  on public.billing_orders for select to authenticated
  using (buyer_id = (select auth.uid()) or (select private.is_platform_staff()));

create policy group_subscriptions_select_manager_or_staff
  on public.group_subscriptions for select to authenticated
  using ((select private.has_group_permission(group_id, 'billing.manage')) or (select private.is_platform_staff()));

-- ---------------------------------------------------------------------------
-- Triggers: second enforcement
-- ---------------------------------------------------------------------------

-- Plans and prices change only on behalf of a platform admin. New plans come with migrations.
create function private.plans_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'DELETE' then
    perform private.raise_group_rule('plan_delete_forbidden');
  end if;
  if not private.is_platform_staff(array['admin']) then
    perform private.raise_group_rule('plan_update_forbidden');
  end if;
  if (new.slug, new.tier) is distinct from (old.slug, old.tier) then
    perform private.raise_group_rule('plan_identity_immutable');
  end if;
  new.name := btrim(new.name);
  -- The free plan is the fallback for every group; it is never "off sale".
  if new.slug = 'free' then
    new.is_active := true;
  end if;
  new.updated_at := now();
  return new;
end;
$$;

create trigger plans_guard
  before update or delete on public.plans
  for each row execute function private.plans_guard();

create function private.plan_prices_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'DELETE' then
    if not exists (select 1 from public.plans p where p.slug = old.plan_slug) then
      return old;
    end if;
    perform private.raise_group_rule('price_delete_forbidden');
  end if;
  if not private.is_platform_staff(array['admin']) then
    perform private.raise_group_rule('plan_update_forbidden');
  end if;
  if (new.plan_slug, new.currency, new.period) is distinct from (old.plan_slug, old.currency, old.period) then
    perform private.raise_group_rule('price_identity_immutable');
  end if;
  return new;
end;
$$;

create trigger plan_prices_guard
  before update or delete on public.plan_prices
  for each row execute function private.plan_prices_guard();

-- Orders: opened by the owner at the list price, then only status moves.
create function private.billing_orders_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
begin
  if tg_op = 'DELETE' then
    perform private.raise_group_rule('order_delete_forbidden');
  end if;

  if tg_op = 'INSERT' then
    if actor is null or actor is distinct from new.buyer_id
       or not private.user_has_group_permission(actor, new.group_id, 'billing.manage') then
      perform private.raise_group_rule('order_forbidden');
    end if;
    if new.status <> 'pending' or new.paid_at is not null or new.provider_payment_id is not null then
      perform private.raise_group_rule('order_must_start_pending');
    end if;
    if not exists (
      select 1 from public.plans p
      join public.plan_prices pp on pp.plan_slug = p.slug
      where p.slug = new.plan_slug and p.is_active
        and pp.currency = new.currency and pp.period = new.period and pp.amount_minor = new.amount_minor
    ) then
      perform private.raise_group_rule('order_price_mismatch');
    end if;
    new.updated_at := now();
    return new;
  end if;

  if (new.id, new.buyer_id, new.plan_slug, new.period, new.provider, new.country, new.currency, new.amount_minor,
      new.billing_details, new.sales_terms_version, new.client_ip, new.group_name, new.group_handle, new.created_at)
     is distinct from
     (old.id, old.buyer_id, old.plan_slug, old.period, old.provider, old.country, old.currency, old.amount_minor,
      old.billing_details, old.sales_terms_version, old.client_ip, old.group_name, old.group_handle, old.created_at) then
    perform private.raise_group_rule('order_immutable');
  end if;
  -- group_id only goes to null, through the foreign key when the group is deleted.
  if new.group_id is distinct from old.group_id and new.group_id is not null then
    perform private.raise_group_rule('order_immutable');
  end if;
  if new.provider_token is distinct from old.provider_token and old.provider_token is not null then
    perform private.raise_group_rule('order_immutable');
  end if;

  if new.status is distinct from old.status then
    if not (
      (old.status = 'pending' and new.status in ('paid', 'failed'))
      or (old.status = 'failed' and new.status = 'paid')
      or (old.status = 'paid' and new.status = 'refunded' and private.is_platform_staff(array['admin']))
    ) then
      perform private.raise_group_rule('order_status_invalid');
    end if;
    if new.status = 'paid' then
      new.paid_at := coalesce(new.paid_at, now());
      new.failure_reason := null;
    end if;
  elsif new.paid_at is distinct from old.paid_at then
    perform private.raise_group_rule('order_immutable');
  end if;

  new.updated_at := now();
  return new;
end;
$$;

create trigger billing_orders_guard
  before insert or update or delete on public.billing_orders
  for each row execute function private.billing_orders_guard();

-- Subscriptions: opened only by their paid order, then only shortened (cancel).
create function private.group_subscriptions_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'DELETE' then
    -- Cascade from a deleted group.
    if not exists (select 1 from public.groups g where g.id = old.group_id) then
      return old;
    end if;
    perform private.raise_group_rule('subscription_delete_forbidden');
  end if;

  if tg_op = 'INSERT' then
    if not exists (
      select 1 from public.billing_orders o
      where o.id = new.order_id and o.status = 'paid' and o.group_id = new.group_id
        and o.plan_slug = new.plan_slug and o.period = new.period
    ) then
      perform private.raise_group_rule('subscription_order_mismatch');
    end if;
    if new.ends_at <= new.starts_at or new.canceled_at is not null then
      perform private.raise_group_rule('subscription_invalid');
    end if;
    return new;
  end if;

  if (new.id, new.group_id, new.plan_slug, new.period, new.order_id, new.starts_at, new.credit_seconds, new.created_at)
     is distinct from
     (old.id, old.group_id, old.plan_slug, old.period, old.order_id, old.starts_at, old.credit_seconds, old.created_at) then
    perform private.raise_group_rule('subscription_immutable');
  end if;
  if old.canceled_at is not null or new.canceled_at is null or new.ends_at > old.ends_at then
    perform private.raise_group_rule('subscription_cancel_invalid');
  end if;
  if new.cancel_reason = 'admin' and not private.is_platform_staff(array['admin']) then
    perform private.raise_group_rule('subscription_cancel_forbidden');
  end if;
  return new;
end;
$$;

create trigger group_subscriptions_guard
  before insert or update or delete on public.group_subscriptions
  for each row execute function private.group_subscriptions_guard();

-- Member limit: second check of the API's limit check. The owner joining their
-- new group is never blocked. Locking the group serializes concurrent joins.
create function private.group_members_plan_limit()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  g public.groups;
begin
  select * into g from public.groups where id = new.group_id for update;
  if g.id is not null and new.user_id <> g.owner_id
     and g.member_count >= (private.group_plan_limits(g.id)).max_members then
    perform private.raise_group_rule('member_limit_reached');
  end if;
  return new;
end;
$$;

-- Fires after group_members_guard (trigger names run alphabetically).
create trigger group_members_plan_limit
  before insert on public.group_members
  for each row execute function private.group_members_plan_limit();

-- ---------------------------------------------------------------------------
-- Distance sales contract (accepted at checkout, not at sign-up)
-- legal_documents is owned by identity; this adds the purchase audience.
-- ---------------------------------------------------------------------------
alter table public.legal_documents
  add column audience text not null default 'signup' check (audience in ('signup', 'purchase'));

alter table public.legal_documents drop constraint legal_documents_kind_check;
alter table public.legal_documents add constraint legal_documents_kind_check
  check (kind in ('terms', 'privacy_notice', 'explicit_consent', 'distance_sales'));
alter table public.legal_documents add constraint legal_documents_audience_by_kind
  check ((kind = 'distance_sales') = (audience = 'purchase'));

comment on column public.legal_documents.audience is
  'signup: required before using the app; purchase: accepted at checkout and stored on the order.';

create or replace function public.pending_legal_documents()
returns setof public.legal_documents
language sql
stable
security invoker
set search_path = ''
as $$
  select d.*
  from public.legal_documents d
  where d.audience = 'signup'
    and d.published_at <= now()
    and d.version = (
      select max(l.version) from public.legal_documents l
      where l.kind = d.kind and l.published_at <= now()
    )
    and not exists (
      select 1 from public.consents c
      where c.user_id = (select auth.uid()) and c.kind = d.kind and c.version = d.version
    )
  order by d.kind;
$$;

-- DRAFT text: must be reviewed by a lawyer before launch.
insert into public.legal_documents (kind, version, title, audience, body) values
(
  'distance_sales', 1, 'Ön Bilgilendirme Formu ve Mesafeli Satış Sözleşmesi', 'purchase',
  E'TASLAK — Hukuki inceleme gereklidir.\n\n'
  '1. Taraflar\n'
  'Satıcı: GrupX (unvan, adres, MERSİS ve iletişim bilgileri yayından önce eklenecektir).\n'
  'Alıcı: Satın alma sırasında fatura bilgilerini giren GrupX kullanıcısı.\n\n'
  '2. Konu\n'
  'Bu sözleşme, alıcının yönettiği grup için seçtiği GrupX paketinin, seçilen dönem (aylık ya da yıllık) boyunca kullanımına ilişkindir. Paketin adı, limitleri (üye sayısı, aylık organizasyon sayısı, aylık canlı yayın dakikası), dönemi, başlangıç ve tahmini bitiş tarihi ile vergiler dahil toplam bedeli ödeme ekranında gösterilir.\n\n'
  '3. Ödeme\n'
  'Bedel tek seferde ödenir. Ödeme, Türkiye''den yapılan alışverişlerde PayTR, diğer ülkelerden yapılan alışverişlerde iyzico aracılığıyla alınır. Kart bilgileri GrupX tarafından görülmez ve saklanmaz. Otomatik yenileme yoktur; dönem bitince grup ücretsiz pakete döner.\n\n'
  '4. İfa\n'
  'Paket, ödemenin ödeme kuruluşu tarafından onaylanmasıyla birlikte elektronik ortamda anında kullanıma açılır. Daha üst bir pakete geçişte mevcut paketin kalan süresi, paket fiyatlarıyla oranlanarak yeni pakete eklenir. Aynı pakete ya da daha alt bir pakete geçiş mevcut dönemin sonunda başlar.\n\n'
  '5. Cayma hakkı\n'
  'Mesafeli Sözleşmeler Yönetmeliği''nin 15. maddesi uyarınca, elektronik ortamda anında ifa edilen hizmetlerde cayma hakkı bulunmamaktadır. Alıcı, paketin ödeme onayıyla birlikte kullanıma açılacağını ve bu nedenle cayma hakkının olmadığını kabul eder.\n\n'
  '6. Grubun silinmesi ve sahiplik devri\n'
  'Paket gruba aittir. Sahiplik devredildiğinde paket grupla birlikte kalır. Grup silinirse kalan süre için iade yapılmaz.\n\n'
  '7. Kişisel veriler\n'
  'Fatura bilgileri yalnızca ödemenin alınması, faturalandırma ve yasal saklama yükümlülükleri için işlenir. Ayrıntılar KVKK Aydınlatma Metni''ndedir.\n\n'
  '8. Uyuşmazlık\n'
  'Uyuşmazlıklarda, Ticaret Bakanlığı''nca ilan edilen parasal sınırlar dahilinde alıcının yerleşim yerindeki Tüketici Hakem Heyetleri ve Tüketici Mahkemeleri yetkilidir.'
);
