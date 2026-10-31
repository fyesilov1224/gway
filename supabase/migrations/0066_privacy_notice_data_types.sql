-- 0066_privacy_notice_data_types
-- The privacy notice names every data type the Play data safety form declares (user decision, 2026-10-31;
-- docs/PLAY_STORE.md): phone number, location (country only), birth date, uploaded photos, messages and the
-- notification token. Consented versions are frozen (0039), so a new version is published; users accept it at their
-- next sign-in. Legal review is still pending.

insert into public.legal_documents (kind, version, title, audience, body)
select d.kind, d.version + 1, d.title, d.audience,
  replace(d.body, 'güvenlik amaçlı IP ve oturum kayıtları.',
    'güvenlik amaçlı IP ve oturum kayıtları, doğrulama için telefon numaran, güvenlik için konumun (yalnızca ülke; kesin '
    'konum saklanmaz), 18 yaş kontrolü için doğum tarihin, yüklediğin fotoğraflar, mesajların ve bildirimler için cihaz jetonu.')
from (
  select distinct on (kind) kind, version, title, audience, body
  from public.legal_documents
  where kind = 'privacy_notice'
  order by kind, version desc
) d
where strpos(d.body, 'güvenlik amaçlı IP ve oturum kayıtları.') > 0;
