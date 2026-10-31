-- 0061: the platform is renamed from GrupX to GWAY (user decision, 2026-10-31; docs/ARCHITECTURE.md §3a KVKK).
-- 1. Legal texts are frozen once consented (0039), and the party they name changed, so the newest version of every
--    kind that still says GrupX is published again as max+1 with the new name. Users accept the new versions at
--    their next sign-in (pending_legal_documents); purchases ask for the new sales contract.
-- 2. "gway" becomes a reserved username and group handle; "grupx" stays reserved so nobody can pose as the old brand.

-- 1 ------------------------------------------------------------------------------------------------------------------
-- Turkish suffixes follow the new sound: GrupX'te -> GWAY'de, GrupX'ten -> GWAY'den; 'e, 'i, 'in stay.
create function private.gway_name(t text)
returns text
language sql
immutable
set search_path = ''
as $$
  select replace(replace(replace(t, 'GrupX''ten', 'GWAY''den'), 'GrupX''te', 'GWAY''de'), 'GrupX', 'GWAY');
$$;

insert into public.legal_documents (kind, version, title, audience, body)
select d.kind, d.version + 1, private.gway_name(d.title), d.audience, private.gway_name(d.body)
from (
  select distinct on (kind) kind, version, title, audience, body
  from public.legal_documents
  order by kind, version desc
) d
where d.title like '%GrupX%' or d.body like '%GrupX%';

drop function private.gway_name(text);

-- 2 ------------------------------------------------------------------------------------------------------------------
create or replace function private.reserved_usernames()
returns text[]
language sql
immutable
set search_path = ''
as $$
  select array[
    'admin', 'administrator', 'root', 'system', 'gway', 'grupx', 'grup', 'destek', 'support',
    'yardim', 'help', 'yonetim', 'yonetici', 'moderator', 'mod', 'staff', 'ekip',
    'official', 'resmi', 'api', 'www', 'mail', 'null', 'undefined', 'me', 'settings',
    'ayarlar', 'profil', 'profile', 'login', 'giris', 'kayit', 'signup', 'explore', 'kesfet'
  ];
$$;
