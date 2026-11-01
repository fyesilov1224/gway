-- 0070_privacy_notice_messages
-- The privacy notice's message paragraph says exactly what happens (user decision, 2026-11-01; docs/ARCHITECTURE.md
-- §3f, Mesaj gizliliği): no tool shows message content to the GWAY team and it does not review it, a reported group
-- chat message goes to that group's moderators, message pushes carry a short text through Firebase, calls and live
-- broadcasts are not recorded, deleted messages leave backups when their period ends, and legal orders are obeyed.
-- Consented versions are frozen (0039), so a new version is published; users accept it at their next sign-in.

insert into public.legal_documents (kind, version, title, audience, body)
select d.kind, d.version + 1, d.title, d.audience,
  replace(d.body,
    'Mesajların ve sesli görüşmelerin: Mesajlarını yalnızca sohbetin katılımcıları okur; platform ekibi özel mesajlarını '
    'okuyamaz. Sesli görüşmeler kaydedilmez ve dinlenemez. Sildiğin mesajın metni ve fotoğrafı silinir, arşivde tutulmaz.',
    'Mesajların ve sesli görüşmelerin: Özel mesajlarını yalnızca sohbetin katılımcıları görür. GWAY ekibinin mesaj içeriğini '
    'görüntüleyebileceği bir araç yoktur ve ekip, şikayet edilen mesajlar dahil özel mesajlarının içeriğini incelemez. '
    'Bir grup sohbetinde şikayet ettiğin mesajın metni, o grubun moderatörlerine kanıt olarak iletilir. Mesaj bildirimleri, '
    'mesajın kısa metnini cihazına ulaştırmak için bildirim altyapısı sağlayıcımız (Google Firebase) üzerinden iletilir; '
    'bunu bildirim tercihlerinden kapatabilirsin. Sesli görüşmeler ve canlı yayınlar kaydedilmez; bir görüşmenin kimle, '
    'ne zaman ve ne kadar sürdüğü yalnızca iki tarafın görebileceği şekilde saklanır. Sildiğin mesajın metni ve fotoğrafı '
    'silinir, arşivde tutulmaz; teknik yedeklerden yedekleme süresi sonunda kendiliğinden düşer. Mahkeme kararı gibi '
    'yasal bir zorunluluk olduğunda, verileri kanunun öngördüğü ölçüde yetkili makamlarla paylaşmak zorunda kalabiliriz.')
from (
  select distinct on (kind) kind, version, title, audience, body
  from public.legal_documents
  where kind = 'privacy_notice'
  order by kind, version desc
) d
where strpos(d.body, 'platform ekibi özel mesajlarını okuyamaz') > 0;
