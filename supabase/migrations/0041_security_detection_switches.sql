-- 0041_security_detection_switches
-- Detection switches for security verification and installed VPN apps (docs/ARCHITECTURE.md §3h, Tespit anahtarları).
-- owner: identity. Backend writes only; no client access changes.

alter table public.security_settings
  add column detect_vpn            boolean not null default true,
  add column warn_installed_vpn    boolean not null default true,
  add column detect_phone_mismatch boolean not null default true;

-- Package names of apps offering android.net.VpnService on the device (Android only), kept like the rest of the check.
alter table public.location_checks
  add column vpn_apps text[] not null default '{}' check (cardinality(vpn_apps) <= 20);
