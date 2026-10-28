-- 0046: illegal activity cases go to the platform team, and every user accepts the community rules
-- (docs/ARCHITECTURE.md §3e Yasa dışı faaliyet ve platform bildirimi, §3a KVKK; user decision 2026-10-28).

-- ---------------------------------------------------------------------------
-- moderation_cases: the board may mark a ban case as illegal activity
-- ---------------------------------------------------------------------------
alter table public.moderation_cases
  add column illegal_category text check (illegal_category in
    ('violence', 'threat', 'insult', 'hate', 'sexual', 'fraud', 'drugs', 'terror', 'other_crime')),
  add constraint moderation_cases_illegal_ban check (illegal_category is null or sanction = 'ban');

comment on column public.moderation_cases.illegal_category is
  'Set when the case is about illegal activity; an approved case then opens a platform_referrals row.';

create or replace function private.moderation_cases_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
  subject_rank int;
begin
  if tg_op = 'INSERT' then
    if actor is null or actor is distinct from new.opened_by
       or not private.has_group_permission(new.group_id, 'reports.review') then
      perform private.raise_moderation_rule('case_forbidden');
    end if;
    if not exists (select 1 from public.group_members m where m.group_id = new.group_id and m.user_id = new.subject_id) then
      perform private.raise_moderation_rule('subject_not_member');
    end if;
    subject_rank := private.group_rank(new.group_id, new.subject_id);
    if private.group_rank(new.group_id, actor) <= subject_rank
       or private.case_decider_rank(new.group_id, new.subject_id) <= subject_rank then
      perform private.raise_moderation_rule('rank_violation');
    end if;
    new.reason := btrim(new.reason);
    new.threshold := (select g.case_threshold from public.groups g where g.id = new.group_id);
    new.status := 'voting';
    new.voting_ends_at := now() + interval '72 hours';
    new.decided_at := null;
    new.created_at := now();
    return new;
  end if;

  if tg_op = 'DELETE' then
    if pg_trigger_depth() > 1 then
      return old;
    end if;
    perform private.raise_moderation_rule('case_immutable');
  end if;
  if (new.id, new.group_id, new.subject_id, new.sanction, new.duration_days, new.reason, new.threshold, new.voting_ends_at,
      new.created_at, new.illegal_category)
     is distinct from
     (old.id, old.group_id, old.subject_id, old.sanction, old.duration_days, old.reason, old.threshold, old.voting_ends_at,
      old.created_at, old.illegal_category)
     or (new.opened_by is distinct from old.opened_by and new.opened_by is not null) then
    perform private.raise_moderation_rule('case_immutable');
  end if;
  if new.status is distinct from old.status then
    if old.status <> 'voting' or new.status is distinct from private.case_outcome(old.id) then
      perform private.raise_moderation_rule('case_not_decided');
    end if;
    new.decided_at := now();
  else
    new.decided_at := old.decided_at;
  end if;
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- platform_referrals
-- owner: moderation
-- An approved illegal-activity case for the platform team: evidence snapshot, decision, law enforcement.
-- Kept after the person or the group is deleted (legal retention), so the person has no foreign key.
-- ---------------------------------------------------------------------------
create table public.platform_referrals (
  id                      uuid primary key default gen_random_uuid(),
  case_id                 uuid unique references public.moderation_cases (id) on delete set null,
  group_id                uuid references public.groups (id) on delete set null,
  group_name              text not null,
  subject_id              uuid not null,
  subject_username        text,
  category                text not null check (category in
                            ('violence', 'threat', 'insult', 'hate', 'sexual', 'fraud', 'drugs', 'terror', 'other_crime')),
  reason                  text not null,
  evidence                jsonb not null default '[]'::jsonb check (jsonb_typeof(evidence) = 'array'),
  status                  text not null default 'pending' check (status in ('pending', 'banned', 'cleared')),
  ban_until               timestamptz,
  law_enforcement         text not null default 'none' check (law_enforcement in ('none', 'to_notify', 'notified')),
  authorities_note        text check (char_length(authorities_note) between 3 and 1000),
  authorities_notified_at timestamptz,
  decided_by              uuid references public.profiles (id) on delete set null,
  decision_note           text check (char_length(decision_note) between 3 and 1000),
  decided_at              timestamptz,
  created_at              timestamptz not null default now(),
  constraint platform_referrals_decided check ((status = 'pending') = (decided_at is null)),
  constraint platform_referrals_note check ((status = 'pending') = (decision_note is null)),
  constraint platform_referrals_ban_until check (ban_until is null or status = 'banned'),
  constraint platform_referrals_pending_authorities check (status <> 'pending' or law_enforcement = 'none'),
  constraint platform_referrals_notified check ((law_enforcement = 'notified') = (authorities_notified_at is not null))
);

comment on table public.platform_referrals is
  'owner: moderation. Illegal-activity cases the platform team decides: account ban, paid plans, law enforcement.';

create index platform_referrals_status_idx on public.platform_referrals (status, created_at desc);
create index platform_referrals_subject_idx on public.platform_referrals (subject_id);

alter table public.platform_referrals enable row level security;
revoke all on public.platform_referrals from anon, authenticated;
grant select on public.platform_referrals to authenticated;

create policy platform_referrals_select_staff
  on public.platform_referrals for select to authenticated
  using (private.is_platform_staff(array['admin', 'moderator']));

create function private.platform_referrals_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  c public.moderation_cases;
begin
  if tg_op = 'DELETE' then
    perform private.raise_moderation_rule('referral_immutable');
  end if;

  if tg_op = 'INSERT' then
    select * into c from public.moderation_cases where id = new.case_id;
    if c.id is null or c.status <> 'approved' or c.illegal_category is null
       or (new.group_id, new.subject_id, new.category) is distinct from (c.group_id, c.subject_id, c.illegal_category) then
      perform private.raise_moderation_rule('referral_case_mismatch');
    end if;
    new.reason := c.reason;
    new.status := 'pending';
    new.ban_until := null;
    new.law_enforcement := 'none';
    new.authorities_note := null;
    new.authorities_notified_at := null;
    new.decided_by := null;
    new.decision_note := null;
    new.decided_at := null;
    new.created_at := now();
    return new;
  end if;

  -- Deleting the case, the group or the deciding admin only clears the link.
  if (new.case_id is distinct from old.case_id and new.case_id is not null)
     or (new.group_id is distinct from old.group_id and new.group_id is not null)
     or (new.decided_by is distinct from old.decided_by and new.decided_by is not null and old.status <> 'pending')
     or (new.id, new.group_name, new.subject_id, new.subject_username, new.category, new.reason, new.evidence, new.created_at)
        is distinct from
        (old.id, old.group_name, old.subject_id, old.subject_username, old.category, old.reason, old.evidence, old.created_at) then
    perform private.raise_moderation_rule('referral_immutable');
  end if;

  if (new.status, new.ban_until, new.decision_note, new.decided_at) is distinct from (old.status, old.ban_until, old.decision_note, old.decided_at) then
    if old.status <> 'pending' or new.status = 'pending'
       or not private.is_platform_staff(array['admin']) or new.decided_by is distinct from (select auth.uid())
       or new.law_enforcement not in ('none', 'to_notify') then
      perform private.raise_moderation_rule('referral_decision_invalid');
    end if;
    new.decided_at := now();
    return new;
  end if;

  if (new.law_enforcement, new.authorities_note, new.authorities_notified_at)
     is distinct from (old.law_enforcement, old.authorities_note, old.authorities_notified_at) then
    if old.law_enforcement <> 'to_notify' or new.law_enforcement <> 'notified' or new.authorities_note is null
       or not private.is_platform_staff(array['admin']) then
      perform private.raise_moderation_rule('referral_authorities_invalid');
    end if;
    new.authorities_notified_at := now();
  end if;
  return new;
end;
$$;

create trigger platform_referrals_guard
  before insert or update or delete on public.platform_referrals
  for each row execute function private.platform_referrals_guard();

-- ---------------------------------------------------------------------------
-- Community rules: required from everyone, new and existing (the consent screen asks at the next start)
-- ---------------------------------------------------------------------------
alter table public.legal_documents drop constraint legal_documents_kind_check;
alter table public.legal_documents add constraint legal_documents_kind_check
  check (kind in ('terms', 'privacy_notice', 'explicit_consent', 'distance_sales', 'community_rules'));

-- DRAFT text: must be reviewed by a lawyer before launch.
insert into public.legal_documents (kind, version, title, audience, body) values (
  'community_rules', 1, 'Topluluk Kuralları, Yaptırımlar ve Yasal İşlemler Sözleşmesi', 'signup',
$body$TASLAK — Yayından önce hukuki inceleme gereklidir.

Bu sözleşme, GrupX uygulamasını ve web sitesini (birlikte "Platform") kullanan herkes için geçerlidir. Kullanım Koşulları, KVKK Aydınlatma Metni ve Açık Rıza Metni ile birlikte okunur. Platformu kullanabilmek için bu metni sonuna kadar okuman ve onaylaman gerekir.

1. TANIMLAR
- GrupX: Platformu işleten ve kişisel verilerin veri sorumlusu olan taraf (unvan, adres, MERSİS ve iletişim bilgileri yayından önce eklenecektir).
- Kullanıcı: Platforma kayıt olan ve onu kullanan gerçek kişi. Bu metinde "sen" olarak anılır.
- Grup: Platformda kurulan topluluk sayfası. Her grubun sahibi, yöneticileri, moderatörleri ve disiplin kurulu olabilir.
- Disiplin Kurulu: Grup sahibinin atadığı ve grup içindeki şikayetleri oylayarak karara bağlayan üyeler. Kurul yoksa kararı grup sahibi verir.
- Platform Ekibi: GrupX'in yetkilendirdiği yönetici ve moderatörler.
- İçerik: Gönderi, yorum, fotoğraf, video, grup sohbeti ve birebir mesajlar, canlı yayın konuşmaları ve yorumları, organizasyon ve anket metinleri, profil bilgileri.
- Paralı Üyelik: Kişisel paketler (eşleşme paketleri ve Ekip Arkadaşı gibi) ile grup sahibinin grubu için satın aldığı grup paketleri.

2. SORUMLULUĞUN SANA AİT OLDUĞU
2.1. Platformda paylaştığın her içerikten, gönderdiğin her mesajdan ve Platform aracılığıyla yaptığın her faaliyetten hukuki ve cezai olarak bizzat sen sorumlusun.
2.2. GrupX, 5651 sayılı Kanun kapsamında yer sağlayıcıdır. Kullanıcıların içeriklerini önceden denetlemekle yükümlü değildir. Hukuka aykırı bir içerikten haberdar olduğunda onu kaldırır ve bu sözleşmedeki yaptırımları uygular.
2.3. Hukuka aykırı içeriğin ya da faaliyetin üçüncü kişilere veya GrupX'e verdiği zararlardan sen sorumlusun. GrupX, bu nedenle ödemek zorunda kaldığı tutarları sana rücu edebilir.
2.4. Kanunen sınırlandırılamayan sorumluluklar ve tüketici olarak sahip olduğun yasal haklar saklıdır.

3. YASAKLANAN DAVRANIŞLAR
Uygulama ve grup kuralları ayrıca geçerli olmak üzere, aşağıdakiler her yerde ve her koşulda yasaktır. Platformda gerçekleştirilmesi ya da Platform aracılığıyla hazırlanması da aynı şekilde yasaktır:
a) Şiddet: Bir kişiye ya da topluluğa şiddet uygulamak, şiddete çağırmak, şiddeti övmek ya da organize etmek.
b) Tehdit: Bir kişiyi ya da yakınlarını canına, vücut bütünlüğüne, malvarlığına veya özel hayatına yönelik bir kötülükle tehdit etmek (TCK m.106).
c) Hakaret: Bir kişinin onurunu, şerefini ve saygınlığını rencide edecek söz, yazı, görüntü ya da davranışlar (TCK m.125).
d) Nefret ve ayrımcılık: Dil, ırk, milliyet, renk, cinsiyet, engellilik, siyasi düşünce, felsefi inanç, din, mezhep ve benzeri sebeplerle kin ve düşmanlığa tahrik ya da ayrımcılık (TCK m.122, m.216).
e) Cinsel suçlar: Cinsel taciz, rıza dışı cinsel içerik paylaşımı ve müstehcenlik (TCK m.102, m.105, m.226). Çocukların cinsel istismarına ilişkin her türlü içerik kesinlikle yasaktır ve her zaman yetkili makamlara bildirilir (TCK m.103).
f) Israrlı takip ve özel hayat: Bir kişiyi ısrarla takip etmek, rahatsız etmek, özel hayatın gizliliğini ihlal etmek, kişisel verileri hukuka aykırı olarak ele geçirmek ya da yaymak (TCK m.123/A, m.134, m.135, m.136).
g) Dolandırıcılık: Sahte organizasyon, sahte ücret toplama, kimlik taklidi, oltalama ve benzeri yollarla haksız çıkar sağlamak (TCK m.157, m.158).
h) Uyuşturucu ve silah: Uyuşturucu ya da uyarıcı madde ticareti ve kullanımını özendirme (TCK m.188, m.190), ruhsatsız silah ve patlayıcı ticareti.
i) Terör ve suç örgütü: Terör örgütü propagandası, örgüte üye kazandırma, örgütü övme (3713 sayılı Kanun m.7), suç örgütü faaliyetleri.
j) Diğer suçlar: Kumar, yasa dışı bahis, fikri mülkiyet ihlali ve yürürlükteki mevzuata göre suç teşkil eden diğer her türlü faaliyet.
k) Kötüye kullanım: Spam, sahte hesap, başkası adına hesap, yaptırımı aşmak için yeni hesap açmak, Platformun güvenlik önlemlerini aşmaya çalışmak.

4. ŞİKAYET VE İNCELEME SÜRECİ
4.1. Her kullanıcı, kurallara aykırı gördüğü içeriği ya da kişiyi uygulama içinden şikayet edebilir. Şikayet edilen kişi şikayeti ve şikayet edeni görmez.
4.2. Grup içindeki şikayetleri önce grubun moderatörleri ön incelemeden geçirir. Gerekirse bir disiplin dosyası açılır.
4.3. Disiplin dosyasını grubun Disiplin Kurulu 72 saat içinde oylar. Grup ayarına göre salt çoğunluk, üçte iki ya da oybirliği gerekir. Kurul yoksa kararı grup sahibi verir.
4.4. Kurul kararını grup içindeki içeriklere dayanarak verir: gönderiler, yorumlar, grup sohbeti, canlı yayın yorumları ve şikayet edilen içeriklerin şikayet anındaki kopyaları. Kurul birebir (özel) mesajlarını göremez. Özel mesajlarla ilgili şikayetleri yalnızca Platform Ekibi inceler.
4.5. Acil durumlarda (örneğin canlı yayında taciz) moderatör ya da kurul üyesi seni en çok 24 saat susturabilir ve yayından çıkarabilir. Bu durumda dosya kendiliğinden açılır.
4.6. Şikayetler, dosyalar, oylar, kararlar ve yaptırımlar değiştirilemez şekilde kayıt altına alınır.

5. YAPTIRIMLAR
5.1. Grup içinde uygulanabilecek yaptırımlar:
- uyarı;
- susturma (1–90 gün): yorum yapamaz, canlı yayında konuşamazsın;
- gruptan çıkarma;
- gruptan süreli (1–365 gün) ya da kalıcı ban.
5.2. Platform genelinde uygulanabilecek yaptırımlar:
- içeriğin kaldırılması;
- hesabın inceleme süresince askıya alınması;
- hesabın süreli (en çok 10 yıl) ya da kalıcı olarak kapatılması (ban);
- sahibi olduğun grupların askıya alınması.
5.3. Kendinle eşit ya da daha yüksek rütbeli birine yaptırım uygulanamaz. Grup sahibi kendi grubunda banlanamaz. Bu kural Platform Ekibinin yaptırımlarını sınırlamaz.
5.4. Hesabın kapatılmışken yeni hesap açman yasaktır. Tespit edilirse yeni hesap da aynı süreyle kapatılır.

6. YASA DIŞI FAALİYET BİLDİRİMİ VE PLATFORM İNCELEMESİ
6.1. Disiplin Kurulu, 3. maddede sayılan yasa dışı bir faaliyeti tespit ettiğinde dosyayı "yasa dışı faaliyet" olarak işaretleyerek ban önerebilir.
6.2. Kurul bu dosyayı onaylarsa üç şey aynı anda olur: gruptan banlanırsın, hesabın Platform Ekibinin incelemesine kadar derhal askıya alınır ve dosya kanıtlarıyla birlikte Platform Ekibine iletilir. Askı süresince giriş yapamazsın.
6.3. Platform Ekibi dosyayı ve kanıtları inceler. Sonunda ya hesabını süreli ya da kalıcı olarak kapatır ya da temize çıkarır ve askıyı kaldırır.
6.4. Kurul ve grup yöneticileri bu yetkiyi yalnızca iyi niyetle ve somut kanıta dayanarak kullanabilir. Yetkiyi kötüye kullananlara da bu sözleşmedeki yaptırımlar uygulanır.

7. KOLLUK KUVVETLERİ VE ADLİ MAKAMLARLA İŞBİRLİĞİ
7.1. Bir faaliyet suç şüphesi doğuruyorsa GrupX şu bilgileri yetkili makamlarla paylaşabilir: hesap bilgilerin, iletişim bilgilerin, IP ve erişim kayıtların, ilgili içeriklerin kopyaları, şikayet, dosya ve karar kayıtları.
7.2. Paylaşılabilecek makamlar: kolluk kuvvetleri (Emniyet, Jandarma), Cumhuriyet Başsavcılıkları, mahkemeler ve diğer yetkili kamu kurumları.
7.3. Paylaşım şu durumlarda yapılır: kanunun öngördüğü durumlar (KVKK m.8/2, m.28; 5651 sayılı Kanun), yetkili makamların talebi, ya da bir kişinin hayatı veya vücut bütünlüğü için acil tehlike bulunması. Çocukların cinsel istismarı, terör ve hayati tehlike içeren durumlar Platform Ekibince kendiliğinden bildirilir.
7.4. Bu bildirimi ve veri aktarımını yalnızca GrupX yapar. Grup sahipleri, yöneticileri ve kurul üyeleri senin verilerini kimseye aktaramaz. Sen ya da başka bir kullanıcı ayrıca şikayette bulunma hakkına her zaman sahipsiniz.
7.5. GrupX, 5651 sayılı Kanun ve ilgili mevzuat gereğince trafik bilgilerini (IP adresi, bağlantı zamanı ve benzeri) kanunda öngörülen süre boyunca saklar.

8. PARALI ÜYELİKLERE ETKİSİ
8.1. Hesabın bu sözleşmenin ihlali nedeniyle Platform Ekibince süreli ya da kalıcı olarak kapatılırsa:
- kişisel paketlerin (eşleşme paketleri, Ekip Arkadaşı ve benzeri) kapatma anında iptal edilir;
- sahibi olduğun gruplar askıya alınır ve bu grupların paketleri kapatma anında iptal edilir;
- kalan süre için iade yapılmaz, ödenen bedel geri ödenmez.
8.2. Hesabın 6.2 uyarınca incelemeye kadar askıya alındığında paketlerin hemen iptal edilmez. İnceleme sonunda hesabın kapatılırsa 8.1 uygulanır.
8.3. Yalnızca bir gruptan banlanman ya da çıkarılman paralı üyeliklerini etkilemez.
8.4. Platform Ekibi seni temize çıkarırsa ya da itirazın kabul edilirse, kapatma nedeniyle iptal edilen kullanılmamış süre için iade ya da süre telafisi değerlendirilir.
8.5. Bu madde, Mesafeli Satış Sözleşmesi ile birlikte uygulanır. Bir çelişki olursa ihlal hâlleri için bu madde geçerlidir; kanundan doğan tüketici hakların saklıdır.

9. GRUP SAHİPLERİ, YÖNETİCİLER VE KURUL ÜYELERİ
9.1. Grup sahipleri ve atadıkları yöneticiler, moderatörler ve kurul üyeleri, grubun kurallara uygun işlemesinden sorumludur.
9.2. Bu kişiler yetkilerini tarafsız, iyi niyetli ve kanıta dayalı kullanır. Kişisel husumet, ayrımcılık ya da baskı amacıyla yaptırım uygulayamaz.
9.3. Kendi grubunda yasa dışı faaliyete göz yuman ya da bunu organize eden grup sahibinin grubu askıya alınabilir. Hesabına da 5. ve 8. maddeler uygulanır.

10. İTİRAZ
10.1. Grup yaptırımlarına, kararın sana bildirilmesinden itibaren 7 gün içinde uygulama içinden (Ayarlar → Yaptırımlarım) itiraz edebilirsin. Acil susturmaya itiraz edilmez.
10.2. Hesabın askıya alındığında ya da kapatıldığında giriş yapamayacağın için itirazını 30 gün içinde GrupX destek adresine e-postayla iletebilirsin. Adres yayından önce eklenecektir. E-postanda kullanıcı adını ve itiraz gerekçeni yaz.
10.3. İtiraz incelenirken yaptırım sürer. İtiraz sonucu sana e-postayla bildirilir.

11. HESAP SİLME VE VERİLERİN SAKLANMASI
11.1. Hesabını her zaman silebilirsin. Ancak hakkında açılmış bir yasa dışı faaliyet bildirimi, ilgili kanıtlar ve kararlar şu amaçlarla saklanır: hukuki yükümlülüklerin yerine getirilmesi, olası adli süreçler ve bir hakkın tesisi, kullanılması veya korunması (KVKK m.5/2-ç ve e). Saklama süresi, yasal süreler ve olası uyuşmazlık süreleri boyuncadır.
11.2. Hesap silmek, uygulanmış bir yaptırımı ya da başlamış bir yasal süreci ortadan kaldırmaz.

12. DEĞİŞİKLİKLER
GrupX bu sözleşmeyi güncelleyebilir. Yeni sürüm yayınlandığında Platformu kullanmaya devam edebilmek için yeni metni okuyup onaylaman istenir. Onayladığın her sürüm, onay zamanıyla birlikte kayıt altında tutulur.

13. ONAY
Onay kutusunu işaretleyip devam ettiğinde şunları kabul etmiş olursun:
- bu sözleşmeyi sonuna kadar okuduğunu ve anladığını;
- uygulama ve grup kurallarına aykırı ya da yasa dışı her türlü içerik ve faaliyetin sorumluluğunun sana ait olduğunu;
- bu durumlarda hesabının gerekçesiyle birlikte süreli ya da kalıcı olarak kapatılabileceğini;
- paralı üyeliklerinin iadesiz iptal edilebileceğini;
- gerekli hâllerde bilgilerinin kolluk kuvvetleri ve adli makamlarla paylaşılabileceğini.$body$
);

-- The moderation desk shows the illegal-activity mark of a case (0012 definition plus illegal_category).
create or replace function private.group_moderation(target_group uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  with me as (select (select auth.uid()) as uid)
  select case when not private.has_group_permission(target_group, 'reports.review') then null else jsonb_build_object(
    'rank', private.group_rank(target_group, me.uid),
    'is_owner', exists (select 1 from public.groups g where g.id = target_group and g.owner_id = me.uid),
    'can_mute', private.has_group_permission(target_group, 'members.mute'),
    'threshold', (select g.case_threshold from public.groups g where g.id = target_group),
    'reports', coalesce((
      select jsonb_agg(x.card order by x.last_at desc)
      from (
        select max(r.created_at) as last_at, jsonb_build_object(
          'id', (array_agg(r.id order by r.created_at desc))[1],
          'target_type', r.target_type,
          'target_id', r.target_id,
          'post_id', (select c.post_id::text from public.comments c
                      where r.target_type = 'comment' and c.id::text = r.target_id),
          'subject', private.person_card(r.subject_id, target_group),
          'excerpt', (array_agg(r.excerpt order by r.created_at desc))[1],
          'reasons', to_jsonb(array_agg(distinct r.reason)),
          'notes', coalesce(to_jsonb((array_agg(r.note order by r.created_at desc) filter (where r.note is not null))[1:5]), '[]'::jsonb),
          'count', count(*),
          'first_at', min(r.created_at),
          'last_at', max(r.created_at)
        ) as card
        from public.reports r
        where r.group_id = target_group and r.status = 'open'
        group by r.target_type, r.target_id, r.subject_id
        order by max(r.created_at) desc
        limit 100
      ) x
    ), '[]'::jsonb),
    'cases', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', c.id,
        'subject', private.person_card(c.subject_id, target_group),
        'opened_by', private.person_card(c.opened_by, target_group),
        'sanction', c.sanction,
        'duration_days', c.duration_days,
        'illegal_category', c.illegal_category,
        'reason', c.reason,
        'threshold', c.threshold,
        'status', c.status,
        'voting_ends_at', c.voting_ends_at,
        'decided_at', c.decided_at,
        'created_at', c.created_at,
        'voters', (select count(*) from public.case_votes v where v.case_id = c.id),
        'approvals', (select count(*) from public.case_votes v where v.case_id = c.id and v.vote = 'approve'),
        'rejections', (select count(*) from public.case_votes v where v.case_id = c.id and v.vote = 'reject'),
        'is_voter', exists (select 1 from public.case_votes v where v.case_id = c.id and v.voter_id = me.uid),
        'my_vote', (select v.vote from public.case_votes v where v.case_id = c.id and v.voter_id = me.uid)
      ) order by (c.status = 'voting') desc, c.created_at desc)
      from (select * from public.moderation_cases c0 where c0.group_id = target_group
            order by (c0.status = 'voting') desc, c0.created_at desc limit 50) c
    ), '[]'::jsonb),
    'sanctions', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', s.id,
        'user', private.person_card(s.user_id, target_group),
        'type', s.type,
        'interim', s.interim,
        'starts_at', s.starts_at,
        'ends_at', s.ends_at,
        'lifted_at', s.lifted_at,
        'reason', (select c.reason from public.moderation_cases c where c.id = s.case_id),
        'appeal', (select jsonb_build_object('id', a.id, 'body', a.body, 'handler', a.handler, 'status', a.status,
                                             'decision_note', a.decision_note, 'created_at', a.created_at)
                   from public.sanction_appeals a where a.sanction_id = s.id)
      ) order by s.created_at desc)
      from (select * from public.sanctions s0 where s0.group_id = target_group order by s0.created_at desc limit 50) s
    ), '[]'::jsonb)
  ) end
  from me;
$$;
