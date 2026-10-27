-- 0044_review_exemption
-- Store review accounts skip security verification (docs/ARCHITECTURE.md §3h, İnceleme hesabı muafiyeti).
-- owner: identity. Set only by platform admins through the API; every change is audited there.

alter table public.user_security
  add column review_exempt boolean not null default false;

comment on column public.user_security.review_exempt is
  'Store review account: location, phone and second factor are not required. Admin only, audited.';

-- The one definition of a verified session, now with the exemption. Everything else is unchanged.
create or replace function private.is_session_verified(uid uuid, sid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select sid is not null
    and (
      exists (select 1 from public.user_security s where s.user_id = uid and s.review_exempt)
      or (
        exists (select 1 from public.verified_sessions v where v.session_id = sid and v.user_id = uid)
        and exists (select 1 from public.phone_verifications p where p.user_id = uid)
        and exists (
          select 1 from public.user_security s
          where s.user_id = uid and s.state = 'ok' and s.location_checked_at > now() - interval '24 hours'
        )
      )
    );
$$;
