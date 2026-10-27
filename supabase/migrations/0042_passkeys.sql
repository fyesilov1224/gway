-- 0042_passkeys
-- Passkeys (WebAuthn) as a second factor (docs/ARCHITECTURE.md §3h, Parmak izi). owner: identity.
-- Backend only: RLS on, no client policy, like the rest of the security tables.

create table public.passkeys (
  -- WebAuthn credential id.
  id           bytea primary key check (octet_length(id) between 16 and 1023),
  user_id      uuid not null references auth.users (id) on delete cascade,
  public_key   bytea not null,
  sign_count   bigint not null default 0 check (sign_count >= 0),
  transports   text[] not null default '{}',
  aaguid       uuid,
  name         text not null check (char_length(name) between 1 and 60),
  created_at   timestamptz not null default now(),
  last_used_at timestamptz
);

comment on table public.passkeys is 'owner: identity. Registered passkeys (public keys only). Backend writes only.';

create index passkeys_user_idx on public.passkeys (user_id);

-- One pending challenge per user and purpose; single use, five minutes.
create table public.webauthn_challenges (
  user_id    uuid not null references auth.users (id) on delete cascade,
  purpose    text not null check (purpose in ('register', 'assert')),
  options    text not null,
  expires_at timestamptz not null,
  primary key (user_id, purpose)
);

comment on table public.webauthn_challenges is 'owner: identity. Pending WebAuthn options. Backend writes only.';

alter table public.passkeys enable row level security;
alter table public.webauthn_challenges enable row level security;
revoke all on public.passkeys, public.webauthn_challenges from anon, authenticated;

alter table public.verified_sessions drop constraint verified_sessions_method_check;
alter table public.verified_sessions add constraint verified_sessions_method_check
  check (method in ('phone', 'sms', 'totp', 'passkey'));
