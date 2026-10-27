-- 0040_security_verification
-- Faz 15.8 (docs/ARCHITECTURE.md §3h): mandatory location check, country-locked phone verification, a second
-- factor on every new session, and graded sanctions. owner: identity.
--
-- Enforcement lives in the custom access token hook: while enforcement is on, a session that is not verified
-- gets role `unverified` instead of `authenticated`. That role can read only published legal texts, so a
-- modified client cannot reach data, Storage or Realtime. Every table here is backend-only (no client policy).

-- ---------------------------------------------------------------------------
-- unverified role
-- ---------------------------------------------------------------------------
create role unverified nologin noinherit;
grant unverified to authenticator;
grant usage on schema public to unverified;
grant select on public.legal_documents to unverified;
alter policy legal_documents_select_published on public.legal_documents to anon, authenticated, unverified;

-- ---------------------------------------------------------------------------
-- security_settings: one row, the enforcement switch (admin only, through the API)
-- ---------------------------------------------------------------------------
create table public.security_settings (
  id         boolean primary key default true check (id),
  enforce    boolean not null default false,
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users (id) on delete set null
);

comment on table public.security_settings is 'owner: identity. Security verification switch (single row). Backend writes only.';

insert into public.security_settings default values;

-- ---------------------------------------------------------------------------
-- user_security: per-user state
-- ---------------------------------------------------------------------------
create table public.user_security (
  user_id             uuid primary key references auth.users (id) on delete cascade,
  state               text not null default 'ok' check (state in ('ok', 'restricted')),
  -- Country of the last location check (GPS, else IP); the phone must be from here.
  allowed_country     text check (allowed_country ~ '^[A-Z]{2}$'),
  location_checked_at timestamptz,
  -- Set by staff after a review: uncertain signals do not restrict until then.
  exempt_until        timestamptz,
  updated_at          timestamptz not null default now()
);

comment on table public.user_security is 'owner: identity. Security state per user. Backend writes only.';

-- ---------------------------------------------------------------------------
-- phone_verifications: one verified mobile number per account, one account per number
-- ---------------------------------------------------------------------------
create table public.phone_verifications (
  user_id     uuid primary key references auth.users (id) on delete cascade,
  phone       text not null unique check (phone ~ '^\+[1-9][0-9]{6,14}$'),
  country     text not null check (country ~ '^[A-Z]{2}$'),
  verified_at timestamptz not null default now()
);

comment on table public.phone_verifications is 'owner: identity. Verified phone numbers (E.164). Backend writes only.';

-- ---------------------------------------------------------------------------
-- phone_bans: numbers of security-banned accounts; outlive the account (fraud prevention)
-- ---------------------------------------------------------------------------
create table public.phone_bans (
  phone     text primary key check (phone ~ '^\+[1-9][0-9]{6,14}$'),
  user_id   uuid,
  reason    text not null,
  banned_at timestamptz not null default now()
);

comment on table public.phone_bans is 'owner: identity. Numbers that may not verify again. Backend writes only.';

-- ---------------------------------------------------------------------------
-- verified_sessions: Supabase Auth sessions that passed phone verification or the second factor
-- ---------------------------------------------------------------------------
create table public.verified_sessions (
  session_id  uuid primary key references auth.sessions (id) on delete cascade,
  user_id     uuid not null references auth.users (id) on delete cascade,
  method      text not null check (method in ('phone', 'sms', 'totp')),
  verified_at timestamptz not null default now()
);

comment on table public.verified_sessions is 'owner: identity. Sessions that passed verification. Backend writes only.';

create index verified_sessions_user_idx on public.verified_sessions (user_id);

-- ---------------------------------------------------------------------------
-- totp_factors: optional authenticator app (RFC 6238)
-- ---------------------------------------------------------------------------
create table public.totp_factors (
  user_id      uuid primary key references auth.users (id) on delete cascade,
  secret       bytea not null check (octet_length(secret) = 20),
  confirmed_at timestamptz,
  -- Last accepted time step: a code is never accepted twice.
  last_step    bigint,
  created_at   timestamptz not null default now()
);

comment on table public.totp_factors is 'owner: identity. Authenticator app secrets. Backend only, never sent after setup.';

-- ---------------------------------------------------------------------------
-- sms_sends: rate limits and cost tracking (kept 90 days)
-- ---------------------------------------------------------------------------
create table public.sms_sends (
  id      bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  phone   text not null,
  purpose text not null check (purpose in ('phone', 'second_factor')),
  sent_at timestamptz not null default now()
);

comment on table public.sms_sends is 'owner: identity. Verification SMS log (90 days). Backend writes only.';

create index sms_sends_user_idx on public.sms_sends (user_id, sent_at);
create index sms_sends_phone_idx on public.sms_sends (phone, sent_at);
create index sms_sends_sent_idx on public.sms_sends (sent_at);

-- ---------------------------------------------------------------------------
-- location_checks: derived countries and flags only, never coordinates (kept 90 days)
-- ---------------------------------------------------------------------------
create table public.location_checks (
  id            bigint generated always as identity primary key,
  user_id       uuid not null references auth.users (id) on delete cascade,
  checked_at    timestamptz not null default now(),
  platform      text not null check (platform in ('android', 'ios', 'web')),
  gps_country   text check (gps_country ~ '^[A-Z]{2}$'),
  ip_country    text check (ip_country ~ '^[A-Z]{2}$'),
  sim_country   text check (sim_country ~ '^[A-Z]{2}$'),
  phone_country text check (phone_country ~ '^[A-Z]{2}$'),
  accuracy_m    real,
  is_mocked     boolean not null,
  vpn           boolean not null,
  -- e.g. {mock_location, ip_mismatch}
  signals       text[] not null default '{}',
  verdict       text not null check (verdict in ('ok', 'restricted', 'banned'))
);

comment on table public.location_checks is 'owner: identity. Location check results (90 days). Backend writes only.';

create index location_checks_user_idx on public.location_checks (user_id, checked_at desc);
create index location_checks_checked_idx on public.location_checks (checked_at);

-- ---------------------------------------------------------------------------
-- security_reviews: uncertain signals wait here for staff
-- ---------------------------------------------------------------------------
create table public.security_reviews (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users (id) on delete cascade,
  signals     text[] not null check (cardinality(signals) > 0),
  check_id    bigint references public.location_checks (id) on delete set null,
  status      text not null default 'open' check (status in ('open', 'approved', 'banned')),
  opened_at   timestamptz not null default now(),
  resolved_at timestamptz,
  resolved_by uuid references auth.users (id) on delete set null,
  note        text check (char_length(note) <= 1000),
  constraint security_reviews_resolution_consistent check ((status = 'open') = (resolved_at is null))
);

comment on table public.security_reviews is 'owner: identity. Security reviews of restricted accounts. Backend writes only.';

create unique index security_reviews_one_open_idx on public.security_reviews (user_id) where status = 'open';
create index security_reviews_status_idx on public.security_reviews (status, opened_at desc);

-- ---------------------------------------------------------------------------
-- RLS: on everywhere, no client access at all
-- ---------------------------------------------------------------------------
alter table public.security_settings enable row level security;
alter table public.user_security enable row level security;
alter table public.phone_verifications enable row level security;
alter table public.phone_bans enable row level security;
alter table public.verified_sessions enable row level security;
alter table public.totp_factors enable row level security;
alter table public.sms_sends enable row level security;
alter table public.location_checks enable row level security;
alter table public.security_reviews enable row level security;

revoke all on public.security_settings, public.user_security, public.phone_verifications, public.phone_bans,
  public.verified_sessions, public.totp_factors, public.sms_sends, public.location_checks, public.security_reviews
  from anon, authenticated;

-- ---------------------------------------------------------------------------
-- private.is_session_verified: the one definition of a verified session (hook and API both use it)
-- ---------------------------------------------------------------------------
create function private.is_session_verified(uid uuid, sid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select sid is not null
    and exists (select 1 from public.verified_sessions v where v.session_id = sid and v.user_id = uid)
    and exists (select 1 from public.phone_verifications p where p.user_id = uid)
    and exists (
      select 1 from public.user_security s
      where s.user_id = uid and s.state = 'ok' and s.location_checked_at > now() - interval '24 hours'
    );
$$;

revoke all on function private.is_session_verified(uuid, uuid) from public, anon, authenticated;

-- ---------------------------------------------------------------------------
-- private.custom_access_token_hook (config.toml [auth.hook.custom_access_token])
-- ---------------------------------------------------------------------------
create function private.custom_access_token_hook(event jsonb)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  uid uuid := (event ->> 'user_id')::uuid;
  sid uuid := nullif(event -> 'claims' ->> 'session_id', '')::uuid;
begin
  if not coalesce((select s.enforce from public.security_settings s), false) then
    return event;
  end if;
  if private.is_session_verified(uid, sid) then
    return event;
  end if;
  return jsonb_set(event, '{claims,role}', '"unverified"');
end;
$$;

revoke all on function private.custom_access_token_hook(jsonb) from public, anon, authenticated;
grant usage on schema private to supabase_auth_admin;
grant execute on function private.custom_access_token_hook(jsonb) to supabase_auth_admin;
