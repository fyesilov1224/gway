import 'guide.dart';

// The text follows docs/ARCHITECTURE.md; change both together. Values the platform team can change from the
// admin panel (prices, free daily likes) are not written here: the guide points to the screen that shows them.

const guideChapters = <GuideChapter>[
  GuideChapter(
    id: 'start',
    title: 'İlk adımlar',
    summary: 'Hesap açma, giriş, doğrulama ve uygulamada gezinme.',
    topics: [
      GuideTopic(
        'GWAY nedir?',
        intro: 'GWAY; yürüyüş, koşu, bisiklet, müzik, doğa, spor, sanat gibi her türden topluluğu bir araya getiren '
            'sosyal bir platformdur. Gruplara katılır, organizasyonlara gider, canlı sesli yayınlarda sohbet eder, '
            'yeni insanlarla tanışırsın.',
        notes: [
          'GWAY 18 yaş ve üstüne açıktır.',
          'Uygulama telefonda (Android, iOS) ve web tarayıcısında çalışır; hesabın her yerde aynıdır.',
        ],
      ),
      GuideTopic(
        'Hesap açmak',
        steps: [
          'Giriş ekranında "Kayıt ol"a dokun.',
          'E-posta adresini ve şifreni yaz. Google ya da Apple ile de kayıt olabilirsin.',
          'E-postayla kayıt olduysan gelen kutuna giden doğrulama bağlantısına dokun. E-posta doğrulanmadan giriş yapılamaz.',
          'Giriş yaptıktan sonra uygulama seni sırayla güvenlik doğrulaması, hukuki metinlerin onayı, doğum tarihi ve profil oluşturma adımlarından geçirir.',
        ],
        tip: 'Doğrulama e-postası gelmediyse gereksiz (spam) klasörüne bak.',
      ),
      GuideTopic(
        'Şifremi unuttum',
        steps: [
          'Giriş ekranında "Şifremi unuttum"a dokun.',
          'Hesabının e-posta adresini yaz.',
          'Gelen e-postadaki bağlantıyla yeni şifreni belirle.',
        ],
      ),
      GuideTopic(
        'Güvenlik doğrulaması: konum, telefon ve ikinci adım',
        intro: 'Sahte hesapları önlemek için uygulama senden bu adımları isteyebilir.',
        steps: [
          'Konum: uygulama konum izni ister. İzin vermezsen uygulama açılmaz; ayarlara giden bir ekran görürsün. '
              'Konumun yalnızca hesap güvenliği için kullanılır, kimseye gösterilmez.',
          'Telefon: bulunduğun ülkenin numarasını yazarsın, gelen SMS kodunu girersin. Bu bir kez yapılır; bir numara yalnızca bir hesapta kullanılabilir.',
          'İkinci adım: her yeni girişte kayıtlı numarana SMS kodu gelir. Doğrulama uygulaması ya da parmak izi kurduysan onu kullanırsın.',
        ],
        tip: 'Telefonu doğruladıktan sonra çıkan "Parmak izi ekle" ya da "Google Authenticator ekle" önerisini kabul edersen sonraki girişler daha hızlı olur. SMS yedek olarak kalır.',
      ),
      GuideTopic(
        'Hukuki metinler ve doğum tarihi',
        intro: 'Kullanım koşulları, aydınlatma metni, açık rıza ve Topluluk Kuralları metinlerini onaylaman gerekir.',
        steps: [
          'Her metni aç ve sonuna kadar kaydır. Metin okunmadan onay kutusu işaretlenmez.',
          'Metnin sonundaki "Okudum, onaylıyorum"a dokun.',
          'Doğum tarihini gir. Bu tarih kimseye gösterilmez ve sonradan değiştirilemez; hatalı girdiysen destek ekibine yaz.',
        ],
        notes: ['Bir metnin yeni sürümü yayınlanınca uygulama onu yeniden onaylamanı ister.'],
      ),
      GuideTopic(
        'Profilini oluşturmak',
        steps: [
          'Kullanıcı adını seç: 3–30 karakter; küçük harf, rakam, alt çizgi ve nokta kullanılabilir.',
          'Görünen adını ve profil fotoğrafını ekle.',
          'İlgi alanlarını seç (en fazla 10). Gruplar ve öneriler bunlara göre gelir.',
        ],
        notes: ['Kullanıcı adını sonradan 30 günde bir değiştirebilirsin.'],
      ),
      GuideTopic(
        'Uygulamada gezinmek',
        intro: 'Alttaki çubukta dört sekme ve ortada "+" düğmesi vardır.',
        notes: [
          'Bugün: şu an canlı olan yayınlar, yakında başlayan organizasyonlar ve takip ettiklerinin paylaşımları. Sağ üstte Ara, Bildirimler ve Mesajlar düğmeleri bulunur.',
          'Gruplar: grup arama ve keşfetme. Sağ üstte Gruplar Ligi ve Harita düğmeleri vardır.',
          'Takvim: katıldığın ve gruplarının organizasyonları.',
          'Ben: kendi profilin. Sağ üstte Bildirimler, Kaydedilenler, Eşleşme, Ekip arkadaşı bul, Yılın özeti ve Ayarlar bulunur.',
          '"+" düğmesi: Bu akşam, Yaklaşanlar, gönderi, hikâye ve grup oluşturma.',
          'Geniş ekranda (web, tablet) aynı bölümler soldaki menüdedir; altında üyesi olduğun gruplar listelenir.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'profile',
    title: 'Profil ve takip',
    summary: 'Profilini düzenleme, gizlilik, takip, engelleme, rozetler.',
    topics: [
      GuideTopic(
        'Profilimi düzenlemek',
        steps: [
          'Ben sekmesinde sağ üstteki Ayarlar düğmesine, sonra "Profili düzenle"ye dokun.',
          'Profil fotoğrafını, kapak görselini, görünen adını, biyografini ve ilgi alanlarını değiştir.',
          'Kaydet.',
        ],
        notes: ['Görseller en fazla 5 MB olabilir (JPEG, PNG ya da WebP).'],
      ),
      GuideTopic(
        'Gizli hesap',
        intro: 'Ayarlar → "Gizli hesap" açıkken gönderilerini ve hikâyelerini yalnızca onayladığın takipçiler görür.',
        notes: [
          'Gizli hesapta seni takip etmek isteyenler istek gönderir; Bildirimler ekranının en üstünde onaylar ya da reddedersin. Reddedilen kişiye haber verilmez.',
          'Hesabını yeniden herkese açtığında bekleyen istekler kendiliğinden onaylanır.',
        ],
      ),
      GuideTopic(
        'Gruplarımı profilimde göstermek',
        intro: 'Ayarlar → "Gruplarımı profilimde göster" varsayılan olarak kapalıdır.',
        notes: [
          'Kapalıyken bir gruptaki üyeliğini yalnızca o grubun üyeleri görür. Başka bir grubun yöneticisi hangi gruplarda olduğunu göremez.',
          'Açarsan üyeliklerin profilinde herkese görünür.',
          'Yönetim ekibinde olduğun gruplar (sahip, yönetici, kurul, moderatör) her zaman herkese açıktır.',
        ],
      ),
      GuideTopic(
        'Takip etmek ve arkadaşlar',
        steps: [
          'Bir profilde "Takip et"e dokun. Hesap gizliyse istek gider, kabul edilince takip başlar.',
          'Takibi bırakmak ya da isteği geri almak için aynı düğmeye yeniden dokun.',
        ],
        notes: [
          'Birbirinizi takip ediyorsanız profilde "Arkadaş" yazar.',
          'Seni takip eden birini takipçi listenden çıkarabilirsin.',
          'Takip etmek mesaj hakkı vermez; birebir mesaj eşleşmeler ve ekip arkadaşları arasındadır.',
          'Grupları da takip edebilirsin; üyesi olduğun grupların paylaşımları zaten akışına düşer.',
        ],
      ),
      GuideTopic(
        'Birini engellemek',
        steps: [
          'Kişinin profilinde sağ üstteki "Diğer seçenekler" menüsünü aç.',
          '"Engelle"ye dokun.',
        ],
        notes: [
          'İki yöndeki takip ve istekler silinir. Birbirinizin profilini, gönderilerini ve yorumlarını görmezsiniz; mesaj yazamaz, birbirinizden bahsedemezsiniz.',
          'Engellenen kişi eşleşme destende ve ekip arkadaşı önerilerinde de çıkmaz.',
          'Engellediklerini Ayarlar → "Engellenen hesaplar"da görür, oradan engeli kaldırırsın. Engel kalkınca takip kendiliğinden geri gelmez.',
        ],
      ),
      GuideTopic(
        'Katkılar ve rozetler',
        intro: 'Profilindeki katkılar gerçek hayatta yaptıklarından hesaplanır; beğeni, takipçi ya da gönderi sayısı sayılmaz.',
        notes: [
          'Katılım: katıldığın ve "gelmedi" işaretlenmediğin, bitmiş organizasyonlar.',
          'Düzenleme: senin oluşturduğun ve senin dışında en az 2 kişinin katıldığı organizasyonlar.',
          'Anı: bir organizasyona bağlı paylaştığın gönderiler.',
          'Rozet örnekleri: İlk adım (1 katılım), Müdavim (10), Yol arkadaşı (25), Kâşif (3 farklı grup), Düzenleyici, Anı biriktiren, Geri bildirimci, "<kategori> tutkunu", karşılama ve el sıkış rozetleri, tamamladığın hedefler.',
          'Sıralama ya da "en iyiler" listesi yoktur.',
        ],
      ),
      GuideTopic(
        'Kaydedilenler ve hikâye arşivi',
        notes: [
          'Bir gönderiyi kaydetmek için kartındaki kaydet işaretine dokun. Kaydettiklerini yalnızca sen görürsün: Ben → Kaydedilenler ya da Ayarlar → Kaydedilenler.',
          'Süresi dolan hikâyelerin silinmez, Ayarlar → "Hikaye arşivi"nde kalır.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'feed',
    title: 'Bugün, gönderi ve hikâye',
    summary: 'Paylaşım yapma, beğeni, yorum, keşfet ve arama.',
    topics: [
      GuideTopic(
        'Bugün ekranı',
        notes: [
          'En üstte "Şimdi canlı": gruplarındaki canlı yayınlar. Karta dokununca yayına girersin.',
          'Ardından "Yakında başlıyor": önümüzdeki saatlerde başlayan organizasyonlar; önce kendi gruplarınınkiler, sonra gruplarının illerindekiler.',
          'Altta akış: kendi paylaşımların, takip ettiğin kişilerin ve takip ettiğin ya da üyesi olduğun grupların paylaşımları, en yeniden eskiye.',
          'Ekranı aşağı çekerek yenilersin.',
        ],
      ),
      GuideTopic(
        'Gönderi paylaşmak',
        steps: [
          'Alttaki "+" düğmesine, sonra "Gönderi"ye dokun.',
          'En fazla 10 fotoğraf ya da video seç. Video en fazla 60 saniye ve 50 MB olabilir.',
          'Fotoğraflar için oranı seç (Orijinal, 1:1, 4:5, 1.91:1) ve kadrajı ayarla.',
          'Açıklama yaz. #etiket ekleyebilir, @kullanıcıadı ile birinden bahsedebilirsin.',
          'İstersen yorumları kapat ya da beğeni sayısını gizle, sonra paylaş.',
        ],
        notes: [
          'Fotoğrafların konum bilgisi yüklenmeden önce silinir.',
          'Gönderiyi sonradan düzenleyebilirsin; yalnızca açıklama ve seçenekler değişir. Silersen medyası da silinir.',
          'Bir gruba paylaşmak için grup sayfasından paylaş. Grubun her üyesi paylaşabilir; susturulan üye paylaşamaz.',
        ],
      ),
      GuideTopic(
        'Beğeni, tepki ve yorum',
        notes: [
          'Gönderiyi beğenebilir ya da 😍 😂 😮 👏 🔥 🙏 emojilerinden biriyle tepki bırakabilirsin. Tepkini değiştirebilir ya da geri alabilirsin.',
          'Gönderiyi görebilen herkes yorum yazar; yazar yorumları kapattıysa yazılamaz.',
          'Bir yoruma yanıt verebilir, yorumu beğenebilirsin. Yanıtlar tek seviyedir.',
          'Kendi yorumunu sen, kendi gönderindeki yorumları da sen silersin. Grup gönderisindeki yorumları grubun sahibi ve yöneticileri de siler.',
        ],
      ),
      GuideTopic(
        'Hikâye paylaşmak',
        steps: [
          '"+" → "Hikâye"ye dokun.',
          'Fotoğraf ya da en fazla 60 saniyelik video seç ve paylaş.',
        ],
        notes: [
          'Hikâye 24 saat görünür, sonra arşivine geçer.',
          'Hikâyeni kimlerin gördüğünü yalnızca sen görürsün.',
          'Hikâyelerini öne çıkanlara ekleyerek profilinde kalıcı gösterebilirsin.',
        ],
      ),
      GuideTopic(
        'Keşfet ve arama',
        steps: [
          'Bugün ekranının sağ üstündeki Ara düğmesine dokun.',
          'Kişi ya da #etiket ara. Grup aramak için Gruplar sekmesini kullan.',
        ],
        notes: [
          'Keşfet; son iki haftanın, takip etmediğin herkese açık hesaplarından ve gruplarından en çok etkileşim alan paylaşımlarını gösterir.',
          'Bir gönderinin bağlantısını paylaşabilirsin; açan kişi onu görme hakkı varsa görür.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'groups',
    title: 'Gruplar',
    summary: 'Grup bulma, katılma, roller ve grup sayfası.',
    topics: [
      GuideTopic(
        'Grup bulmak',
        notes: [
          'Gruplar sekmesinde ada göre ara ya da kategori seç.',
          'Sağ üstteki Harita düğmesiyle çevrendeki grupları ve organizasyonları haritada gör.',
          'Gruplar Ligi düğmesiyle kategorinde ve ilinde en iyi organizasyonları yapan grupları gör.',
          'Bütün aktif grupların sayfası herkese açıktır; gizli grup yoktur.',
        ],
      ),
      GuideTopic(
        'Gruba katılmak',
        intro: 'Grubun katılım tipi düğmede yazar:',
        notes: [
          'Serbest: "Katıl"a dokununca hemen üye olursun.',
          'İstekle: istek gönderirsin; grubun yöneticisi onaylar. İsteğini geri alabilirsin.',
          'Davetle: yönetici seni kullanıcı adınla davet eder; Bildirimler ekranında kabul ya da reddedersin.',
          'Davet bağlantısı: sana gönderilen bağlantıyı açıp "Gruba katıl" dersen katılım tipi ne olursa olsun üye olursun.',
          'Grup paketinin üye sınırı dolduysa yeni üye alınamaz.',
        ],
        tip: 'İlk gruba katıldığında sana bir kez 30 günlük "Hepsi Bir Arada" kişisel paket denemesi tanımlanır (eşleşme ve ekip arkadaşı özellikleri).',
      ),
      GuideTopic(
        'Gruptan ayrılmak',
        steps: [
          'Grup sayfasında üyelik düğmesine dokun.',
          '"Gruptan ayrıl"ı seç.',
        ],
        notes: [
          'Rollerin silinir ve grubun gelecek organizasyonlarındaki katılımın düşer.',
          'Grup sahibi gruptan ayrılamaz; önce sahipliği devretmesi gerekir.',
        ],
      ),
      GuideTopic(
        'Grup sayfasında neler var?',
        notes: [
          'Kapak, logo, tanıtım, kurallar, bağlantılar, il ve kategori.',
          'Canlı yayın kartı: süren ve planlı yayınlar.',
          'Organizasyonlar, "Nasıldı?" değerlendirmeleri ve grubun ortalama puanı.',
          'Anketler, hedefler, lig kartı ve grup paylaşımları.',
          'Üyeler: yönetim ekibi herkese açıktır; üye listesinin tamamını yalnızca grubun üyeleri görür.',
          'Grup sohbeti: her grubun tek bir sohbeti vardır, yalnızca üyeler okur ve yazar.',
        ],
      ),
      GuideTopic(
        'Grup içi roller',
        intro: 'Bir üyenin birden fazla rolü olabilir. Parantez içindeki sayı rütbedir.',
        notes: [
          'Grup Sahibi (100): her şey, ödeme ve rol atama.',
          'Yönetici (80): içerik, organizasyon, anket, üye onayı ve davet, canlı yayın, oylamasız ban, sesli görüşme talepleri.',
          'Disiplin Kurulu (60): disiplin dosyalarına oy verir; şikayet inceleme, acil susturma, canlı yayın moderasyonu.',
          'Moderatör (50): şikayet ön incelemesi, acil susturma, canlı yayın moderasyonu.',
          'Üye (10): katılım, paylaşım, canlı yayına katılma.',
          'Rütbe kuralı: kimse kendisiyle eşit ya da daha yüksek rütbeli birine yaptırım uygulayamaz. Grup sahibi banlanamaz.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'group-admin',
    title: 'Grup kurma ve yönetme',
    summary: 'Sahipler ve yöneticiler için: grup, davet, roller, paketler, hedefler.',
    topics: [
      GuideTopic(
        'Grup kurmak',
        steps: [
          '"+" → "Grup"a dokun.',
          'Grubun adını (3–60 karakter) ve adresini yaz. Adres sayfanın bağlantısıdır (/g/adres) ve sonradan değişmez.',
          'Kategoriyi ve ili seç. İl, harita ve Gruplar Ligi için gereklidir.',
          'Katılım tipini seç: serbest, istekle ya da davetle.',
          'Logo, kapak, tanıtım, kurallar ve en fazla 5 bağlantı ekle.',
        ],
        notes: ['Grubu kuran kişi grup sahibidir. Ayrıca grubun kendi sohbeti de açılır.'],
      ),
      GuideTopic(
        'Üye kabul etmek ve davet etmek',
        notes: [
          'İstekle katılan grupta bekleyen istekleri grup sayfasında onaylar ya da reddedersin (sahip ve yönetici).',
          'Kullanıcı adıyla davet gönderebilirsin. Bir grup 24 saatte en fazla 50 davet gönderir; geri alınan davetler de sayılır.',
          'Gönderdiğin daveti kabul edilene kadar geri alabilirsin.',
        ],
      ),
      GuideTopic(
        'Davet bağlantısı',
        intro: 'Grubunu WhatsApp ya da Instagram\'dan taşımanın en kolay yolu.',
        steps: [
          'Grup sayfasında "Davet bağlantısı" bölümünü aç.',
          'Süreyi seç (1, 7 ya da 30 gün); istersen kullanım sınırı koy (1–1000 kişi).',
          'Bağlantıyı paylaş. Açan kişi giriş yapıp "Gruba katıl" dediğinde üye olur.',
        ],
        notes: [
          'Bir grubun aynı anda en fazla 20 geçerli bağlantısı olur.',
          'Bağlantıyı istediğin an iptal edebilirsin; iptal geri alınmaz, yenisini üretirsin.',
          'Paylaşılan bağlantı WhatsApp\'ta grubun adı ve görseliyle önizlenir.',
        ],
      ),
      GuideTopic(
        'Rol vermek ve sahipliği devretmek',
        notes: [
          'Rolleri yalnızca grup sahibi verir ve alır: Yönetici, Disiplin Kurulu, Moderatör. Rol yalnızca üyeye verilir.',
          'Sahipliği aktif bir üyeye devredebilirsin. Sen normal üye olarak kalırsın; yeni sahip istersen sana rol verir.',
          'Grubu yalnızca sahibi siler. Silme kalıcıdır.',
          'Grup sahibiyken hesabını silemezsin; önce sahipliği devret ya da grubu sil.',
        ],
      ),
      GuideTopic(
        'Grup paketleri',
        intro: 'Paket; grubun en fazla üye sayısını, aylık organizasyon sayısını ve aylık canlı yayın dakikasını belirler.',
        steps: [
          'Grup sayfasındaki "Paket" kartını aç; mevcut paketini, limitlerini ve kullanımını gör.',
          'Paketi web\'den satın al. Mobil uygulama yalnızca paket durumunu gösterir.',
        ],
        notes: [
          'Aboneliği olmayan grup ücretsiz paketin limitlerini kullanır.',
          'Paketler ön ödemelidir (aylık ya da yıllık); otomatik yenileme yoktur, kart saklanmaz.',
          'Üst pakete geçince kalan süren yeni pakete aktarılır. Aynı paketi yenilersen süre sona eklenir.',
          'Türkiye\'den ödemeler PayTR ile TL, yurt dışından iyzico ile USD olarak alınır.',
          'Üye sınırı dolarsa mevcut üyeler kalır, yeni üye alınamaz.',
          'Güncel fiyatlar ve limitler paket ekranında yazar. Paketi sahip satın alır.',
        ],
      ),
      GuideTopic(
        'Hedefler ve görevler',
        intro: 'Grubu ortak bir amaç etrafında toplar. Hedefleri sahip ve yöneticiler açar; ödül rozettir, para ya da puan yoktur.',
        notes: [
          'Kişisel hedef: her üye kendi sayısına ulaşınca rozet alır.',
          'Grup hedefi: grubun toplamı hedefe ulaşınca katkısı olan herkes rozet alır.',
          'Takım hedefi: takımlar kurulur, takımın toplamı sayılır.',
          'Görev: üye "Yaptım" der, kısa not ekler; yönetici onaylarsa rozet verilir.',
          'Sayılanlar: katılım, düzenleme ya da anı. İlerlemeyi sunucu hesaplar.',
        ],
      ),
      GuideTopic(
        'Grup sohbetini yönetmek',
        notes: [
          'Grup sohbetini yalnızca yöneticilerin yazabileceği şekilde ayarlayabilirsin (duyuru kanalı gibi).',
          'Uygunsuz bir mesaj şikayet edilirse grubun moderasyon ekranına düşer; yetkili kaldırabilir.',
        ],
      ),
      GuideTopic(
        'Sesli görüşme taleplerini yanıtlamak',
        intro: 'Üyeler birebir sesli görüşme yetkisini gruptan ister. Talepleri grup sahibi ve yöneticiler görür.',
        steps: [
          'Grup sayfasında "Sesli görüşme talepleri"ni aç.',
          'Talebi aç ya da gerekçe yazarak reddet.',
          'Açtığın bir yetkiyi gerekçe yazarak istediğin an kapatabilirsin.',
        ],
        notes: ['Kişi gruptan ayrılırsa, çıkarılırsa ya da banlanırsa yetkisi kendiliğinden kapanır.'],
      ),
    ],
  ),
  GuideChapter(
    id: 'events',
    title: 'Organizasyonlar',
    summary: 'Katılma, bekleme listesi, karşılama, el sıkış, değerlendirme.',
    topics: [
      GuideTopic(
        'Organizasyona katılmak',
        steps: [
          'Organizasyonun sayfasını aç (grup sayfasından, Bugün ekranından, takvimden ya da haritadan).',
          'Tarih, yer, ücret bilgisi, katılım koşulları ve gerekli ekipmanı oku.',
          '"Katıl"a dokun. Yer kalmadıysa "Bekleme listesine gir" yazar.',
        ],
        notes: [
          'Organizasyonları herkes görür, yalnızca grubun üyeleri katılır.',
          'Bekleme listesindeysen biri vazgeçince sıran gelir ve bildirim alırsın.',
          'Onaylı katılımlı organizasyonda "Katılım isteği gönder" yazar; organizatör onaylayınca katılırsın.',
          'Vazgeçmek için "Vazgeç"e dokun; yerin bekleme listesindeki ilk kişiye geçer.',
          'Organizasyon başladıktan sonra katılım kapanır.',
        ],
      ),
      GuideTopic(
        'Katılım ücreti',
        intro: 'Ücret yalnızca bilgi olarak gösterilir. GWAY ödeme almaz; ücret organizasyon sahibine, belirttiği şekilde (ör. yerinde nakit) ödenir.',
      ),
      GuideTopic(
        'Takvime ekle ve yol tarifi',
        notes: [
          '"Takvime ekle" organizasyonu telefonunun takvim uygulamasına ekler.',
          'Buluşma noktası işaretlenmişse sayfadaki küçük haritanın altındaki "Yol tarifi" cihazının harita uygulamasını açar.',
        ],
      ),
      GuideTopic(
        'Aynı saatte iki organizasyon',
        intro: 'Katıldığın bir organizasyonun saatinde başka bir organizasyonun varsa uygulama sana diğerinden vazgeçip yerini boşaltmak isteyip istemediğini sorar. Seçim senindir; hiçbir şey kendiliğinden iptal edilmez.',
      ),
      GuideTopic(
        '"Geliyor musun?" teyidi',
        intro: 'Başlangıca 24 saatten az kala sana hatırlatma gelir ve organizasyon sayfasında "Geliyor musun?" kartı çıkar.',
        notes: [
          '"Evet, geliyorum": organizatör geleceğini görür.',
          '"Gelemiyorum": katılımdan vazgeçersin; yerin bekleme listesindeki ilk kişiye geçer.',
          'Yanıt vermezsen listeden çıkarılmazsın.',
        ],
      ),
      GuideTopic(
        'Karşılama: ilk kez gidiyorsan',
        intro: 'Bir grubun organizasyonuna ilk kez gidiyorsan grubun gönüllü bir üyesi seni karşılayabilir.',
        steps: [
          'Organizasyona katıl.',
          'Sayfadaki karşılama bölümünde "Karşılanmak istiyorum"a dokun; istersen kendini tarif eden bir not yaz (ör. "Kırmızı montluyum").',
          'Bir karşılayıcı isteği üstlenince buluşma notunu (ör. "Girişteki kafenin önü, 08:45") bildirim olarak alırsın.',
          'Organizasyondan sonra karşılayıcına teşekkür edebilirsin.',
        ],
        notes: [
          'Karşılayıcı olmak için organizasyona katıl; açık istekleri karşılama bölümünde görürsün. Bir organizasyonda en fazla 3 kişiyi karşılayabilirsin.',
          'Karşılama rozetleri: Kapı açan (1), Ev sahibi (5), Topluluğun kalbi (20).',
        ],
      ),
      GuideTopic(
        'Sürpriz mekan',
        intro: 'Bazı organizasyonlarda mekan sürprizdir. Sayfada yalnızca bir ipucu (ör. "Kadıköy\'de, deniz kenarında") ve mekanın ne zaman açıklanacağı yazar.',
        notes: [
          'Mekan, açıklanma zamanında katılanlara bildirimle açıklanır.',
          'Bekleme listesindekiler ve katılmayanlar mekanı görmez. Sonradan katılırsan ve zaman geçtiyse hemen görürsün.',
        ],
      ),
      GuideTopic(
        'El sıkış: tanıştığın kişileri kaydet',
        intro: 'Aynı organizasyona katılan iki kişi birbirinin QR kodunu okutarak tanıştıklarını kaydeder.',
        steps: [
          'Organizasyon başlamadan 1 saat önceden bitişinden 6 saat sonrasına kadar sayfada "El sıkış" kartı görünür.',
          'Kodunu göster ya da karşındakinin kodunu kamerayla okut. Kamera yoksa 6 karakterlik kodu yaz.',
        ],
        notes: [
          'Kod 3 dakikada bir yenilenir; fotoğrafı sonradan işe yaramaz.',
          'Tanıştıklarını yalnızca sen görürsün: Ben → Yılın özeti düğmesi → Tanıştıklarım. Profilinde yalnızca sayı görünür.',
          'El sıkış mesaj hakkı vermez.',
        ],
      ),
      GuideTopic(
        'Organizasyondan sonra',
        notes: [
          'Bittikten sonra sana değerlendirme isteği gelir; 1–5 yıldız ver. Grubun puanı bu değerlendirmelerin ortalamasıdır.',
          'Organizasyona bağlı gönderi paylaşarak anını ekleyebilirsin; anılar rozet ve hedeflere sayılır.',
          'Katıldıysan sayfada "Ben de oradaydım" kartı çıkar; görsel olarak Instagram hikâyesine ya da WhatsApp\'a paylaşabilirsin. Kartta başka katılımcının adı ya da yüzü yoktur.',
          'Grubun geçmiş organizasyonlarını grup sayfasından görebilirsin.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'event-admin',
    title: 'Organizasyon ve anket düzenlemek',
    summary: 'Sahipler ve yöneticiler için: oluşturma, tekrar, onay, iptal, anket.',
    topics: [
      GuideTopic(
        'Organizasyon oluşturmak',
        steps: [
          'Grup sayfasında "Organizasyon oluştur"a dokun.',
          'Kapak, başlık, açıklama, başlangıç ve isteğe bağlı bitiş zamanını gir. Başlangıç en az 15 dakika, en fazla 1 yıl ileride olmalıdır.',
          'Yeri yaz, istersen haritada iğneyle buluşma noktasını ya da çevrim içi bağlantıyı ekle.',
          'Kapasite (boş bırakırsan sınırsız), katılım ücreti bilgisi, katılım koşulları ve ekipman listesini ekle.',
          'Gerekirse "Katılım onayla olsun"u aç ve kaydet.',
        ],
        notes: [
          'Form bu ay kalan organizasyon hakkını gösterir. Paketinin aylık sınırına iptal edilen organizasyonlar da sayılır.',
          'Form, seçtiğin gün ilindeki aynı kategoriden başka grupların kaç organizasyonu olduğunu da gösterir; istersen tarihi değiştirirsin.',
        ],
      ),
      GuideTopic(
        'Tekrarlayan organizasyon',
        intro: 'Oluştururken "Tekrar" bölümünde "Her hafta" ya da "İki haftada bir" seçerek tekrarlanan bir seri açarsın (isteğe bağlı bitiş tarihiyle, en fazla 1 yıl).',
        notes: [
          'Seri her zaman önümüzdeki 4 haftayı açık tutar. Her tarihin kendi katılımcıları ve bekleme listesi vardır.',
          'Son tarihi düzenlersen sonra açılacak tarihler de ona göre açılır.',
          'Organizasyon menüsündeki "Tekrarı durdur" ile seriyi durdurabilirsin; açılmış tarihler kalır, istersen tek tek iptal edersin.',
          'Aylık sınır dolarsa tarih açılmaz, sana bildirim gelir; sınır açılınca tarih açılır.',
        ],
      ),
      GuideTopic(
        'Sürpriz mekan ayarlamak',
        steps: [
          'Formda "Sürpriz mekan"ı aç.',
          '"Yer" alanına ipucu yaz; gerçek mekanı ve buluşma noktasını ayrı gir.',
          'Açıklanma zamanını seç: başlangıçtan 1, 3, 6, 12 ya da 24 saat önce.',
        ],
        notes: ['Sürprizi kapatırsan gizli mekan silinir ve "Yer" normal yer olur.'],
      ),
      GuideTopic(
        'Katılımcıları yönetmek',
        notes: [
          'Onaylı katılımda bekleyen istekleri onaylar ya da reddedersin.',
          'Katılımcı listesinde "Geliyor musun?" teyidini kimin verdiğini görürsün.',
          'Organizasyondan sonra gelmeyenleri "gelmedi" olarak işaretlersin; işaretlenenler katılmış sayılmaz.',
          'Düzenleme: başlık, açıklama, zaman, yer, kapasite, ücret ve kapak değişebilir. Zaman ya da yer değişirse katılanlara bildirim gider. Kapasite katılan sayısının altına inemez.',
          'İptal: gerekçe yazarak iptal edersin; katılanlara ve bekleyenlere bildirim gider. Geçmiş organizasyon düzenlenemez.',
        ],
      ),
      GuideTopic(
        'Anket açmak ve oy vermek',
        steps: [
          'Grup sayfasında "Anket aç"a dokun (sahip ve yöneticiler).',
          'Soruyu ve 2–10 seçeneği yaz.',
          'İstersen çoklu seçime izin ver, anketi gizli yap, bitiş zamanı koy ya da bir organizasyona bağla.',
        ],
        notes: [
          'Anketleri ve sonuçları yalnızca grubun üyeleri görür.',
          'Gizli ankette kimin neye oy verdiğini kimse göremez, anketi açan da.',
          'Anket kapanınca oy verilemez, sonuçlar kalır. Yetkili anketi erken kapatabilir ya da silebilir.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'calendar',
    title: 'Takvim, Bu akşam ve keşif',
    summary: 'Takvim, Bu akşam boşum, küçük masa, harita, lig, yılın özeti.',
    topics: [
      GuideTopic(
        'Takvimim',
        notes: [
          'Takvim sekmesi katıldığın, onay beklediğin ve bekleme listesinde olduğun organizasyonları gösterir.',
          '"Gruplarımın organizasyonları"nı açarsan üyesi olduğun grupların bütün organizasyonları da gelir.',
          'Gün, hafta ve ay görünümü arasında geçersin.',
          'Zamanı çakışan organizasyonlar işaretlenir.',
          'Grup sayfasından o grubun takvimini de açabilirsin.',
        ],
      ),
      GuideTopic(
        'Bu akşam boşum',
        steps: [
          '"+" → "Bu akşam"a dokun.',
          '"Bu akşam boşum"u aç; istersen kısa bir not yaz (ör. "kahve, kısa yürüyüş").',
        ],
        notes: [
          'Durumunu yalnızca seninle en az bir grubu paylaşanlar görür.',
          'Durum gece 04:00\'te kendiliğinden kapanır; istediğin an kendin de kapatırsın.',
        ],
      ),
      GuideTopic(
        'Küçük masa',
        intro: 'Bu akşam boş olanlarla küçük bir buluşma kurar.',
        steps: [
          '"Bu akşam" sayfasında "Küçük masa kur"a dokun.',
          'Uygulama ortak gruplarınız olan, bu akşam boş 3–5 kişiyi seçip davet eder.',
          'Kabul edenlerle masanın sohbetinde yazışırsınız.',
        ],
        notes: [
          'Masa için çağrılabilecek en az 2 kişi olmalıdır; yoksa kart kaç kişi daha gerektiğini yazar.',
          'Bir gecede yalnızca bir masaya katılabilirsin.',
          'Masa ertesi gün 12:00\'de kapanır; sohbet okunur ama yazılamaz.',
        ],
      ),
      GuideTopic(
        'Harita ile keşif',
        steps: [
          'Gruplar sekmesinde sağ üstteki Harita düğmesine dokun.',
          'Haritayı kaydır; kategoriye, zamana (bugün, 7 gün) ve haritanın ortasından mesafeye (5–50 km) göre süz.',
          'Harita ya da liste görünümünü seç.',
        ],
        notes: [
          'Haritada yalnızca gelecekteki organizasyonlar ve aktif gruplar görünür. Senin konumun haritada kullanılmaz ve kimseye gösterilmez.',
          'Harita geçici olarak kapalıysa üstünde "Harita şu anda kullanılamıyor." yazar.',
        ],
      ),
      GuideTopic(
        'Gruplar Ligi',
        intro: 'Aynı kategori ve ildeki gruplar her ay iyi organizasyon yaparak puan toplar.',
        notes: [
          'Puanlar: katılan her kişi, en az 3 kişinin katıldığı her organizasyon, her karşılama ve her 4–5 yıldızlı değerlendirme.',
          'Eşitlikte üye sayısı az olan grup öndedir.',
          'Ay kapanınca ilk üçe giren grupların üyelerine bildirim gider; grup sayfasındaki lig kartında dereceler görünür.',
        ],
      ),
      GuideTopic(
        'Yılın özeti ve keşif haritam',
        steps: [
          'Ben sekmesinde sağ üstteki Yılın özeti düğmesine dokun.',
          '"Yılın özeti", "Keşif haritam" ya da "Tanıştıklarım"ı seç.',
        ],
        notes: [
          'Yılın özeti: katıldığın organizasyon sayısı, toplam saat, gittiğin gruplar, iller ve kategoriler. Hikâye kartı olarak paylaşabilirsin.',
          'Keşif haritam: katıldığın organizasyonların illeri Türkiye haritasında dolar ("7 / 81 ili keşfettim").',
          'Bu sayfaları yalnızca sen görürsün; sen paylaşmadıkça kimse göremez.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'live',
    title: 'Canlı sesli yayın',
    summary: 'Yayına katılma, konuşma, tepkiler, yayın başlatma ve yönetme.',
    topics: [
      GuideTopic(
        'Yayına katılmak',
        steps: [
          'Bugün ekranındaki "Şimdi canlı" kartına, grup sayfasındaki yayın kartına ya da yayın bildirimine dokun.',
          'Yayına bağlanınca sahnedekileri ve dinleyicileri görürsün.',
        ],
        notes: ['Yalnızca grubun üyeleri katılır. Yayından çıkarılan kişi o yayına bir daha giremez.'],
      ),
      GuideTopic(
        'Yayındayken uygulamada gezinmek',
        intro: 'Geri tuşuna ya da sol üstteki aşağı oka basmak seni yayından çıkarmaz; yayın ekranı küçülür ve ses sürer.',
        notes: [
          'Her sayfanın üstünde "Canlı yayındasın" şeridi görünür. Şeride dokununca yayına dönersin.',
          'Sahnedeysen mikrofonunu şeritten de kapatıp açabilirsin.',
          'Yayından çıkmak için yayın ekranındaki "Ayrıl"a bas. Başka bir yayına girersen öncekinden çıkarsın.',
        ],
      ),
      GuideTopic(
        'Konuşmak: el kaldırma ve sahne',
        steps: [
          'Dinleyiciysen ✋ düğmesiyle elini kaldır.',
          'Yayın yöneticisi seni sahneye alınca mikrofon düğmen çıkar; dokunarak aç ve konuş.',
          'Sahneden kendin inmek için "Sahneden in"e dokun.',
        ],
        notes: [
          'Mikrofonunu yönetici kapattıysa sen açamazsın; yalnızca yönetici yeniden açar.',
          'Konuşanın fotoğrafının çevresi renklenir.',
        ],
      ),
      GuideTopic(
        'Tepkiler ve yorumlar',
        notes: [
          'Tepkiler düğmesiyle ❤️ 👏 😂 🔥 😮 🙌 gönder; ekranda uçarak görünür ve saklanmaz.',
          'Yorumlar düğmesiyle yazılı yorum yazarsın. Yorumlar yayının kaydıyla birlikte kalır.',
          'Kendi yorumunu basılı tutup silebilirsin; başkasının yorumunu şikayet edebilirsin.',
        ],
      ),
      GuideTopic(
        'Yayın başlatmak',
        intro: 'Grup sahibi ve yöneticiler yayın başlatır.',
        steps: [
          'Grup sayfasındaki canlı yayın kartında "Yayın başlat"a dokun.',
          'Başlığı yaz. Hemen başlat ya da ileri bir tarihe planla.',
        ],
        notes: [
          'Bir grupta aynı anda bir canlı yayın ve en fazla beş planlı yayın olur.',
          'Planlı yayın grup sayfasında "Yaklaşan" olarak görünür; üyeler "Hatırlat" der. Planlı yayını sunucu planlanan zamandan en çok 15 dakika önce başlatabilir.',
          'Yayın dakikası grubun paketine bağlıdır; başlatma ekranı kalan dakikayı gösterir. Dakika dolunca yayın kendiliğinden biter.',
          'Sunucu yayından ayrılırsa ve 2 dakika içinde dönmezse yayın kendiliğinden biter.',
        ],
      ),
      GuideTopic(
        'Yayını yönetmek',
        intro: 'Yayını başlatan kişi ve grubun moderasyon yetkilileri yayın yöneticisidir.',
        notes: [
          'Bir kişiye dokunarak sahneye alır, sahneden indirir, mikrofonunu kapatır ya da açarsın.',
          '"Yayından çıkar": kişi bu yayına bir daha giremez.',
          'Kaldırılan elleri en üstteki "el kaldırdı" kartında görürsün.',
          'Sağ üstteki menüden "Yayını herkes için bitir".',
          'Sahnede sunucu dahil en fazla 10 kişi olur. Rütbe kuralı burada da geçerlidir.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'messages',
    title: 'Mesajlar ve sesli görüşme',
    summary: 'Kimlerle yazışılır, grup sohbeti, mesaj gizliliği, sesli arama.',
    topics: [
      GuideTopic(
        'Kimlerle mesajlaşabilirim?',
        notes: [
          'Birebir mesaj yalnızca eşleştiğin kişilerle ve ekip arkadaşlarınla açıktır. Takip mesaj hakkı vermez.',
          'Eşleştiğin kişiye yazmak Eşleşme Sohbeti paketi, ekip arkadaşına yazmak Ekip Arkadaşı paketi ister. Gelen mesajları okumak ücretsizdir.',
          'Grup sohbetleri ücretsizdir; grubun bütün üyeleri yazar.',
          'Mesajlar ekranı Bugün\'ün sağ üstündeki Mesajlar düğmesindedir. Okunmamış mesaj sayısı düğmede görünür.',
        ],
      ),
      GuideTopic(
        'Mesaj yazmak ve silmek',
        notes: [
          'Metin (en fazla 2.000 karakter) ve bir fotoğraf gönderebilirsin.',
          'Mesaj gönderilirken "Gönderiliyor…" yazar. Gönderilemezse metin kutuya geri döner ve nedeni yazar.',
          'Birebir sohbette karşı taraf okuyunca "Görüldü" yazar.',
          'Kendi mesajını herkesten silebilirsin; mesajın yerinde "Bu mesaj silindi" yazar ve içeriği tamamen silinir.',
        ],
      ),
      GuideTopic(
        'Mesaj gizliliği',
        intro: 'GWAY platform ekibi özel mesajlarını okuyamaz, sesli görüşmeni dinleyemez ve kimin kimi aradığını göremez.',
        notes: [
          'Bir mesajı şikayet edebilirsin. Birebir mesaj şikayeti platform ekibine, grup sohbeti mesajı şikayeti grubun moderasyonuna gider.',
          'Grup disiplin kurulu birebir mesajlarını göremez.',
        ],
      ),
      GuideTopic(
        'Sesli görüşme yetkisi almak',
        intro: 'Birebir sesli görüşme herkese açık değildir; yetkiyi üyesi olduğun bir grubun sahibi ya da yöneticisi verir.',
        steps: [
          'Ayarlar → "Sesli görüşme"yi aç.',
          'Üyesi olduğun bir grubu seç, istersen kısa bir not yaz ve talep et.',
          'Durumunu aynı ekranda görürsün: inceleniyor, açık ya da kapalı (gerekçesiyle). Karar bildirim olarak da gelir.',
        ],
        notes: ['Yetkiyi veren gruptan ayrılırsan yetkin kapanır.'],
      ),
      GuideTopic(
        'Sesli aramak',
        steps: [
          'Eşleştiğin kişiyle ya da ekip arkadaşınla sohbeti aç.',
          'Sağ üstteki "Sesli ara" düğmesine dokun.',
        ],
        notes: [
          'İki tarafın da görüşme yetkisi açık olmalı ve sohbetteki gibi paket hakkı bulunmalıdır. Arayamıyorsan düğmenin yerinde nedeni yazar.',
          '30 saniyede açılmayan arama cevapsız olur. Görüşme en fazla 60 dakika sürer.',
          'Görüşme kaydedilmez ve uçtan uca şifrelidir. Ekrandaki 12 haneli güvenlik kodu ikinizde aynıysa araya kimse girmemiştir.',
          'Aynı anda tek görüşme yapılır; meşgul olan aranamaz.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'matching',
    title: 'Eşleşme ve ekip arkadaşı',
    summary: 'Arkadaş ve sevgili eşleşmesi, kişisel paketler, ekip arkadaşı bulma.',
    topics: [
      GuideTopic(
        'Eşleşme nasıl çalışır?',
        intro: 'Eşleşme, ortak grupların olan kişilerden arkadaş ya da sevgili bulmanı sağlar. Ayrı bir eşleşme profiliyle çalışır; sen açmadıkça kimse seni orada görmez.',
        steps: [
          'Ben sekmesinde sağ üstteki Eşleşme düğmesine dokun (geniş ekranda soldaki menüde).',
          'Eşleşme profilini oluştur: Arkadaş, Sevgili ya da ikisi; 2–6 fotoğraf, doğum tarihi, cinsiyet, il, "hakkımda".',
          'Sevgili modunda aradığın cinsiyetleri ve yaş aralığını seç.',
          'Açık rızayı onayla.',
        ],
        notes: [
          'Destende yalnızca seninle en az bir ortak grubu olan, aynı modu açmış kişiler çıkar.',
          'Sevgili modunda ikinizin de tercihi birbirine uymalıdır.',
          'Konum olarak yalnızca ilin kullanılır.',
        ],
      ),
      GuideTopic(
        'Kaydırmak ve eşleşmek',
        notes: [
          'Sağa kaydır: beğen. Sola: geç. Yukarı: süper beğen. Alttaki düğmeler de aynı işi yapar.',
          'Kartın kenarlarına dokununca fotoğraflar geçer; "i" düğmesi profilin tamamını açar.',
          'İkiniz de birbirinizi aynı modda beğenirseniz eşleşirsiniz ve bildirim gelir.',
          'Günlük ücretsiz beğeni ve süper beğeni hakkın eşleşme ekranında yazar.',
          'Geçtiğin kişi 90 gün sonra yeniden önerilebilir.',
        ],
      ),
      GuideTopic(
        'Kişisel paketler',
        intro: 'Her özellik ayrı bir paket olarak satılır; yalnızca istediğini alırsın.',
        notes: [
          'Eşleşmelerim: kiminle eşleştiğini görmek. Paketsiz eşleştiğini bilirsin ama kişi gizli kalır.',
          'Eşleşme Sohbeti: eşleştiklerine yazmak.',
          'Seni Beğenenler: seni beğenenlerin listesi.',
          'Sınırsız Beğeni: sınırsız beğeni, geri al ve filtreler.',
          'Süper Beğeni ve Öne Çık: daha fazla süper beğeni, günde bir kez destelerin başında görünmek.',
          'Ekip Arkadaşı: ekip arkadaşı bölümü ve ekip arkadaşına yazmak.',
          'Hepsi Bir Arada: hepsi.',
          'Paketler ön ödemelidir, otomatik yenilenmez ve web\'den satın alınır. Fiyatlar Eşleşme → Paketler ekranında yazar.',
        ],
      ),
      GuideTopic(
        'Eşleşmeyi bitirmek, duraklatmak, silmek',
        notes: [
          'Eşleşmeyi bitirirsen sohbetiniz kapanır, karşılıklı takip kalkar ve birbirinizin destesine çıkmazsınız.',
          'İki modda da eşleştiyseniz "Yalnızca arkadaş kal" ya da "Yalnızca sevgili kal" diyebilirsin.',
          'Profilini duraklatırsan desten ve beğeniler durur, mevcut eşleşmeler kalır.',
          'Eşleşme verilerinin tamamını (profil, fotoğraflar, beğeniler, eşleşmeler) tek dokunuşla silebilirsin.',
          'Eşleşme profilini ve fotoğrafları şikayet edebilirsin.',
        ],
      ),
      GuideTopic(
        'Ekip arkadaşı bulmak',
        intro: 'Antrenman, yürüyüş ya da sahne için birlikte hareket edeceğin kişileri bulursun.',
        steps: [
          'Ayarlar → "Ekip arkadaşı tercihleri"nde "Ekip arıyorum"u aç.',
          'Aktiviteleri, seviyeni, hedeflerini, sıklığını, uygun zamanlarını ve istersen ilini seç.',
          'Ben sekmesinde "Ekip arkadaşı bul" düğmesiyle önerileri gör. Her önerinin nedeni yazar (ortak aktivite, ortak grup, aynı il…).',
          'İstek gönder (en fazla 200 karakterlik mesajla). Karşı taraf kabul edince ekip arkadaşı olursunuz.',
        ],
        notes: [
          'İlin yalnızca eşleştirmede kullanılır, profilinde görünmez.',
          'Günde en fazla 20 istek gönderebilir, aynı kişiye günde bir istek atabilirsin.',
          'Ekip arkadaşı bölümü Ekip Arkadaşı paketi ister.',
          'Ekip arkadaşlığını iki taraf da istediği an bitirebilir.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'notifications',
    title: 'Bildirimler',
    summary: 'Bildirim türleri, tercihler ve telefon bildirimleri.',
    topics: [
      GuideTopic(
        'Bildirimler ekranı',
        notes: [
          'Bugün\'ün sağ üstündeki zil düğmesiyle açılır; okunmamış sayısı düğmede görünür.',
          'Bildirimler Bugün / Bu hafta / Daha önce diye gruplanır; bekleyen takip istekleri en üsttedir.',
          'Bildirime dokununca ilgili sayfa açılır.',
        ],
      ),
      GuideTopic(
        'Bildirim tercihleri',
        steps: ['Ayarlar → "Bildirim tercihleri"ni aç.', 'Kapatmak istediklerini kapat.'],
        notes: [
          'Kapatılabilenler: organizasyon hatırlatmaları, organizasyon değişikliği ve iptali, değerlendirme istekleri, canlı yayın bildirimleri, kişisel mesajlar, grup mesajları, eşleşme bildirimleri.',
          'Katılım onayı, sıranın gelmesi, yaptırım gibi seni doğrudan ilgilendiren bildirimler kapatılamaz.',
        ],
      ),
      GuideTopic(
        'Telefon bildirimleri gelmiyor',
        steps: [
          'Uygulama ilk açılışta bildirim izni ister; vermediysen telefonun Ayarlar → Uygulamalar → GWAY → Bildirimler bölümünden aç.',
          'Android\'de "Mesajlar", "Sesli aramalar" ve "Bildirimler" kanallarının açık olduğunu kontrol et.',
          'Uygulama içindeki bildirim tercihlerini kontrol et.',
        ],
        notes: ['Telefon sessiz moddaysa bildirim sesi çalmaz.'],
      ),
    ],
  ),
  GuideChapter(
    id: 'safety',
    title: 'Güvenlik, şikayet ve yaptırımlar',
    summary: 'Şikayet etme, grup yaptırımları, itiraz, iki adımlı doğrulama.',
    topics: [
      GuideTopic(
        'Şikayet etmek',
        steps: [
          'Gönderinin, yorumun, organizasyonun, yayın yorumunun, mesajın ya da profilin menüsünü aç.',
          '"Şikayet et"e dokun, sebebi seç ve istersen kısa bir açıklama yaz.',
        ],
        notes: [
          'Şikayet ettiğin kişi şikayeti ve seni görmez. Grubun yöneticileri de kimin şikayet ettiğini görmez.',
          'Grupla ilgili şikayet grubun moderasyonuna, diğerleri platform ekibine gider.',
          'Kendini ya da kendi içeriğini şikayet edemezsin; aynı içeriği açıkken bir kez şikayet edebilirsin.',
        ],
      ),
      GuideTopic(
        'Grup yaptırımları',
        notes: [
          'Uyarı: kayda geçer, sana bildirim gelir.',
          'Susturma (1–90 gün): grupta paylaşım ve yorum yapamaz, grup sohbetine yazamazsın; canlı yayında yalnızca dinlersin.',
          'Çıkarma: gruptan çıkarılırsın; sonra yeniden katılabilirsin.',
          'Ban (süreli ya da kalıcı): süresince gruba katılamaz, istek gönderemez, davet alamazsın.',
          'Yaptırımların Ayarlar → "Grup yaptırımlarım"da görünür.',
        ],
      ),
      GuideTopic(
        'Yaptırıma itiraz etmek',
        steps: [
          'Ayarlar → "Grup yaptırımlarım"ı aç.',
          'Yaptırımın yanındaki "İtiraz et"e dokun ve gerekçeni yaz (10–1000 karakter).',
        ],
        notes: [
          'Her yaptırıma 7 gün içinde bir kez itiraz edebilirsin. Acil susturmaya itiraz edilmez.',
          'İtirazı grup sahibi karara bağlar; sahip dosyada taraf ise platform ekibi karar verir.',
          'Karar bekleniyorken yaptırım sürer. Karar sana bildirimle gelir.',
        ],
      ),
      GuideTopic(
        'Hesap askısı ve ban',
        notes: [
          'Platform ekibi kurallara aykırı bir hesabı askıya alabilir ya da kapatabilir. Bu durumda uygulama sana gerekçeyi ve bitiş tarihini gösterir.',
          'Askı süresince profilin görünür ama içeriğin gizlenir; kalıcı kapatılan hesap hiçbir yerde görünmez.',
          'Yasa dışı faaliyet (şiddet, tehdit, dolandırıcılık gibi) grup kararıyla işaretlenirse hesap platform incelemesine kadar askıya alınır.',
          'Bir yanlışlık olduğunu düşünüyorsan destek ekibine yaz.',
        ],
      ),
      GuideTopic(
        'İki adımlı doğrulama',
        steps: [
          'Ayarlar → "İki adımlı doğrulama"yı aç.',
          'Doğrulama uygulaması (ör. Google Authenticator) ekle ya da web\'de parmak izi ve yüz tanıma ile giriş kur.',
        ],
        notes: ['Kurduğun yöntem sonraki girişlerde ilk sıradadır; SMS her zaman yedek olarak kalır.'],
      ),
    ],
  ),
  GuideChapter(
    id: 'moderation',
    title: 'Grup moderasyonu',
    summary: 'Yetkililer için: şikayet inceleme, disiplin dosyası, oylama, ban.',
    topics: [
      GuideTopic(
        'Moderasyon ekranı',
        intro: 'Grup sayfasındaki moderasyon kartı bekleyen işlerin sayısını gösterir. Sahip, yöneticiler, kurul üyeleri ve moderatörler görür.',
        notes: [
          'Şikayetler: aynı içeriğin şikayetleri tek satırda toplanır. Reddet, İçeriği kaldır ya da Dosya aç.',
          'Dosyalar: oylamadaki dosyalar, kalan süre ve oy sayıları; oy ver.',
          'Yaptırımlar ve itirazlar: sahip itirazları buradan karara bağlar.',
        ],
      ),
      GuideTopic(
        'Disiplin dosyası ve oylama',
        steps: [
          'Bir şikayetten ya da üyeler sayfasındaki üye menüsünden "Disiplin dosyası aç"ı seç.',
          'Önerilen yaptırımı (uyarı, susturma, çıkarma, ban) ve süresini seç, gerekçeyi yaz.',
          'Acil durumda "Hemen sustur (24 saat)"i işaretle; kişi karar çıkana kadar susturulur.',
        ],
        notes: [
          'Disiplin Kurulu üyeleri 72 saat içinde oy verir. Kurulu olmayan grupta sahip tek başına karar verir.',
          'Karar eşiği varsayılan olarak salt çoğunluktur; sahip moderasyon ekranının ayarından üçte iki ya da oybirliği seçebilir.',
          'Eşik geçilince dosya hemen onaylanır ve yaptırım uygulanır. Oy verilmezse dosya reddedilir.',
          'Bir kişi hakkında aynı anda tek açık dosya olur. Rütbe kuralı uygulanır.',
        ],
      ),
      GuideTopic(
        'Oylamasız ban',
        intro: 'Grup sahibi ve yöneticiler kurulu beklemeden bir kişiyi banlayabilir.',
        steps: [
          '"Disiplin dosyası aç"ta yaptırım olarak ban seç.',
          '"Oylamasız, hemen uygula"yı işaretle.',
          'Süreyi (1–365 gün ya da kalıcı) ve gerekçeyi gir.',
        ],
        notes: [
          'Yönetici başka bir yöneticiyi ve sahibi banlayamaz.',
          'Suç teşkil eden bir durumsa "yasa dışı faaliyet" olarak işaretle ve kategorisini seç; kişinin hesabı platform incelemesine kadar askıya alınır.',
          'Kişi 7 gün içinde itiraz edebilir.',
        ],
      ),
      GuideTopic(
        'Canlı yayında acil müdahale',
        intro: 'Yayında taciz gibi bir durumda yayın yöneticisi kişinin mikrofonunu hemen kapatır ya da onu yayından çıkarır. Ardından gerekirse disiplin dosyası açılır.',
      ),
    ],
  ),
  GuideChapter(
    id: 'account',
    title: 'Hesap, gizlilik ve destek',
    summary: 'Hukuki metinler, verilerin, hesap silme, çıkış, destek.',
    topics: [
      GuideTopic(
        'Verilerim nasıl korunuyor?',
        notes: [
          'Konumun yalnızca hesap güvenliği için kullanılır; haritada ya da profilinde gösterilmez.',
          'Doğum tarihin kimseye gösterilmez.',
          'Özel mesajların platform ekibi tarafından okunamaz.',
          'Onayladığın metinler Ayarlar → "Hukuki metinler"de durur.',
        ],
      ),
      GuideTopic(
        'Hesabımı silmek',
        steps: [
          'Ayarlar → "Hesabı sil"i aç.',
          'Silmeyi onayla.',
        ],
        notes: [
          'Profilin başkalarına hemen gizlenir. 30 gün içinde giriş yapıp "silmeyi geri al" diyebilirsin.',
          '30 gün sonra hesabın, gönderilerin, mesajların ve dosyaların kalıcı olarak silinir.',
          'Bir grubun sahibiysen önce sahipliği devretmen ya da grubu silmen gerekir.',
        ],
      ),
      GuideTopic(
        'Çıkış yapmak',
        intro: 'Ayarlar\'ın en altındaki "Çıkış yap"a dokun. Çıkış yaptığın telefona artık bildirim gelmez.',
      ),
      GuideTopic(
        'Destek ekibine yazmak',
        steps: [
          'Ayarlar → "Destek ve geri bildirim"i aç.',
          '"Yeni mesaj"a dokun ve türü seç: Sorun (bir şey çalışmıyor), Talep (hesabın, grubun ya da ödemen için işlem), İstek (yeni özellik ya da öneri).',
          'Konuyu ve açıklamayı yaz; en fazla 3 görsel ekleyebilirsin.',
        ],
        notes: [
          'Yanıt gelince Ayarlar\'daki satırda "yeni yanıt" yazar. Mesajın durumu: Yeni, İnceleniyor, Çözüldü, Kapatıldı.',
          'Grup yöneticisiysen grup sayfasından o grup için de mesaj açabilirsin.',
        ],
      ),
    ],
  ),
];
