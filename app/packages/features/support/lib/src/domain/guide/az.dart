import '../guide.dart';

// Azerbaijani translation of tr.dart; keep chapters, topics, steps and notes in step with it.

const guideAz = <GuideChapter>[
  GuideChapter(
    id: 'start',
    title: 'İlk addımlar',
    summary: 'Hesab açmaq, giriş, təsdiq və tətbiqdə hərəkət.',
    topics: [
      GuideTopic(
        'GWAY nədir?',
        intro: 'GWAY yürüş, qaçış, velosiped, musiqi, təbiət, idman, incəsənət kimi hər növ icmanı bir araya gətirən '
            'sosial platformadır. Qruplara qoşulur, tədbirlərə gedir, canlı səsli yayımlarda söhbət edir, '
            'yeni insanlarla tanış olursan.',
        notes: [
          'GWAY 18 yaş və yuxarı üçün açıqdır.',
          'Tətbiq telefonda (Android, iOS) və veb brauzerdə işləyir; hesabın hər yerdə eynidir.',
        ],
      ),
      GuideTopic(
        'Hesab açmaq',
        steps: [
          'Giriş ekranında "Qeydiyyatdan keç"ə toxun.',
          'E-poçt ünvanını və şifrəni yaz. Google və ya Apple ilə də qeydiyyatdan keçə bilərsən.',
          'E-poçtla qeydiyyatdan keçmisənsə, gələn qutuna göndərilən təsdiq linkinə toxun. E-poçt təsdiqlənmədən giriş etmək olmur.',
          'Girişdən sonra tətbiq səni ardıcıl olaraq təhlükəsizlik təsdiqindən, hüquqi mətnlərin təsdiqindən, doğum tarixindən və profil yaratmaq addımlarından keçirir.',
        ],
        tip: 'Təsdiq məktubu gəlməyibsə, spam qovluğuna bax.',
      ),
      GuideTopic(
        'Şifrəmi unutdum',
        steps: [
          'Giriş ekranında "Şifrəmi unutdum"a toxun.',
          'Hesabının e-poçt ünvanını yaz.',
          'Gələn məktubdakı linklə yeni şifrəni təyin et.',
        ],
      ),
      GuideTopic(
        'Təhlükəsizlik təsdiqi: məkan, telefon və ikinci addım',
        intro: 'Saxta hesabların qarşısını almaq üçün tətbiq səndən bu addımları istəyə bilər.',
        steps: [
          'Məkan: tətbiq məkan icazəsi istəyir. İcazə verməsən, tətbiq açılmır; ayarlara aparan ekran görürsən. '
              'Məkanın yalnız hesab təhlükəsizliyi üçün istifadə olunur, heç kimə göstərilmir.',
          'Telefon: olduğun ölkənin nömrəsini yazırsan, gələn SMS kodunu daxil edirsən. Bu bir dəfə edilir; bir nömrə yalnız bir hesabda istifadə oluna bilər.',
          'İkinci addım: hər yeni girişdə qeydiyyatlı nömrənə SMS kodu gəlir. Təsdiq tətbiqi və ya barmaq izi qurmusansa, onu istifadə edirsən.',
        ],
        tip: 'Telefonu təsdiqlədikdən sonra çıxan "Barmaq izi əlavə et" və ya "Google Authenticator əlavə et" təklifini qəbul etsən, sonrakı girişlər daha sürətli olar. SMS ehtiyat kimi qalır.',
      ),
      GuideTopic(
        'Hüquqi mətnlər və doğum tarixi',
        intro: 'İstifadə şərtlərini, məlumatlandırma mətnini, açıq razılığı və İcma Qaydalarını təsdiqləməlisən.',
        steps: [
          'Hər mətni aç və sonuna qədər sürüşdür. Mətn oxunmadan təsdiq qutusu işarələnmir.',
          'Mətnin sonundakı "Oxudum, təsdiqləyirəm"ə toxun.',
          'Doğum tarixini daxil et. Bu tarix heç kimə göstərilmir və sonradan dəyişdirilmir; səhv daxil etmisənsə, dəstək komandasına yaz.',
        ],
        notes: ['Bir mətnin yeni versiyası dərc olunanda tətbiq onu yenidən təsdiqləməyini istəyir.'],
      ),
      GuideTopic(
        'Profilini yaratmaq',
        steps: [
          'İstifadəçi adını seç: 3–30 simvol; kiçik hərf, rəqəm, alt xətt və nöqtə istifadə oluna bilər.',
          'Görünən adını və profil şəklini əlavə et.',
          'Maraq sahələrini seç (ən çox 10). Qruplar və təkliflər bunlara görə gəlir.',
        ],
        notes: ['İstifadəçi adını sonradan 30 gündə bir dəfə dəyişə bilərsən.'],
      ),
      GuideTopic(
        'Tətbiqdə hərəkət etmək',
        intro: 'Aşağıdakı paneldə dörd bölmə və ortada "+" düyməsi var.',
        notes: [
          'Bu gün: hazırda canlı olan yayımlar, tezliklə başlayan tədbirlər və izlədiklərinin paylaşımları. Sağ yuxarıda Axtar, Bildirişlər və Mesajlar düymələri var.',
          'Qruplar: qrup axtarmaq və kəşf etmək. Sağ yuxarıda Qruplar Liqası və Xəritə düymələri var.',
          'Təqvim: qatıldığın və qruplarının tədbirləri.',
          'Mən: öz profilin. Sağ yuxarıda Bildirişlər, Saxlanılanlar, Uyğunlaşma, Komanda yoldaşı tap, İlin xülasəsi və Ayarlar var.',
          '"+" düyməsi: Bu axşam, Yaxınlaşanlar, paylaşım, hekayə və qrup yaratmaq.',
          'Geniş ekranda (veb, planşet) eyni bölmələr soldakı menyudadır; altında üzvü olduğun qruplar sıralanır.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'profile',
    title: 'Profil və izləmə',
    summary: 'Profili redaktə, məxfilik, izləmə, bloklama, nişanlar.',
    topics: [
      GuideTopic(
        'Profilimi redaktə etmək',
        steps: [
          'Mən bölməsində sağ yuxarıdakı Ayarlar düyməsinə, sonra "Profili redaktə et"ə toxun.',
          'Profil şəklini, üz qabığı şəklini, görünən adını, bioqrafiyanı və maraq sahələrini dəyiş.',
          'Yadda saxla.',
        ],
        notes: ['Şəkillər ən çox 5 MB ola bilər (JPEG, PNG və ya WebP).'],
      ),
      GuideTopic(
        'Gizli hesab',
        intro: 'Ayarlar → "Gizli hesab" açıq olanda paylaşımlarını və hekayələrini yalnız təsdiqlədiyin izləyicilər görür.',
        notes: [
          'Gizli hesabda səni izləmək istəyənlər istək göndərir; Bildirişlər ekranının ən yuxarısında qəbul və ya rədd edirsən. Rədd edilən şəxsə xəbər verilmir.',
          'Hesabını yenidən hamıya açanda gözləyən istəklər avtomatik qəbul olunur.',
        ],
      ),
      GuideTopic(
        'Qruplarımı profilimdə göstərmək',
        intro: 'Ayarlar → "Qruplarımı profilimdə göstər" standart olaraq bağlıdır.',
        notes: [
          'Bağlı olanda bir qrupdakı üzvlüyünü yalnız o qrupun üzvləri görür. Başqa qrupun idarəçisi hansı qruplarda olduğunu görə bilməz.',
          'Açsan, üzvlüklərin profilində hamıya görünür.',
          'İdarə komandasında olduğun qruplar (sahib, idarəçi, şura, moderator) həmişə hamıya açıqdır.',
        ],
      ),
      GuideTopic(
        'İzləmək və dostlar',
        steps: [
          'Profildə "İzlə"yə toxun. Hesab gizlidirsə istək gedir, qəbul ediləndə izləmə başlayır.',
          'İzləməni dayandırmaq və ya istəyi geri götürmək üçün eyni düyməyə yenidən toxun.',
        ],
        notes: [
          'Bir-birinizi izləyirsinizsə, profildə "Dost" yazılır.',
          'Səni izləyən birini izləyici siyahından çıxara bilərsən.',
          'İzləmək mesaj hüququ vermir; birbaşa mesaj uyğunlaşanlar və komanda yoldaşları arasındadır.',
          'Qrupları da izləyə bilərsən; üzvü olduğun qrupların paylaşımları onsuz da axınına düşür.',
        ],
      ),
      GuideTopic(
        'Birini bloklamaq',
        steps: [
          'Şəxsin profilində sağ yuxarıdakı "Digər seçimlər" menyusunu aç.',
          '"Blokla"ya toxun.',
        ],
        notes: [
          'İki istiqamətdəki izləmə və istəklər silinir. Bir-birinizin profilini, paylaşımlarını və şərhlərini görmürsünüz; mesaj yaza, bir-birinizi qeyd edə bilməzsiniz.',
          'Bloklanan şəxs uyğunlaşma destəndə və komanda yoldaşı təkliflərində də çıxmır.',
          'Blokladıqlarını Ayarlar → "Bloklanmış hesablar"da görür, oradan bloku götürürsən. Blok götürüləndə izləmə özbaşına geri qayıtmır.',
        ],
      ),
      GuideTopic(
        'Töhfələr və nişanlar',
        intro: 'Profilindəki töhfələr real həyatda etdiklərindən hesablanır; bəyənmə, izləyici və paylaşım sayı nəzərə alınmır.',
        notes: [
          'İştirak: qatıldığın və "gəlmədi" işarələnmədiyin, bitmiş tədbirlər.',
          'Təşkilatçılıq: sənin yaratdığın və səndən başqa ən azı 2 nəfərin qatıldığı tədbirlər.',
          'Xatirə: bir tədbirə bağlı paylaşdığın paylaşımlar.',
          'Nişan nümunələri: İlk addım (1 iştirak), Daimi qonaq (10), Yol yoldaşı (25), Kəşfiyyatçı (3 fərqli qrup), Təşkilatçı, Xatirə toplayan, Rəy verən, "<kateqoriya> həvəskarı", qarşılama və əl sıxma nişanları, tamamladığın hədəflər.',
          'Reytinq və ya "ən yaxşılar" siyahısı yoxdur.',
        ],
      ),
      GuideTopic(
        'Saxlanılanlar və hekayə arxivi',
        notes: [
          'Paylaşımı saxlamaq üçün kartındakı saxla işarəsinə toxun. Saxladıqlarını yalnız sən görürsən: Mən → Saxlanılanlar və ya Ayarlar → Saxlanılanlar.',
          'Müddəti bitən hekayələrin silinmir, Ayarlar → "Hekayə arxivi"ndə qalır.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'feed',
    title: 'Bu gün, paylaşım və hekayə',
    summary: 'Paylaşmaq, bəyənmə, şərh, kəşf və axtarış.',
    topics: [
      GuideTopic(
        'Bu gün ekranı',
        notes: [
          'Ən yuxarıda "İndi canlı": qruplarındakı canlı yayımlar. Karta toxunanda yayına qoşulursan.',
          'Sonra "Tezliklə başlayır": yaxın saatlarda başlayan tədbirlər; əvvəl öz qruplarınınkılar, sonra qruplarının illərindəkilər.',
          'Aşağıda axın: öz paylaşımların, izlədiyin insanların və izlədiyin və ya üzvü olduğun qrupların paylaşımları, ən yenidən köhnəyə.',
          'Ekranı aşağı çəkərək yeniləyirsən.',
        ],
      ),
      GuideTopic(
        'Paylaşım etmək',
        steps: [
          'Aşağıdakı "+" düyməsinə, sonra "Paylaşım"a toxun.',
          'Ən çox 10 şəkil və ya video seç. Video ən çox 60 saniyə və 50 MB ola bilər.',
          'Şəkillər üçün nisbəti seç (Orijinal, 1:1, 4:5, 1.91:1) və kadrı tənzimlə.',
          'Açıqlama yaz. #teq əlavə edə, @istifadəçiadı ilə birini qeyd edə bilərsən.',
          'İstəsən şərhləri bağla və ya bəyənmə sayını gizlət, sonra paylaş.',
        ],
        notes: [
          'Şəkillərinin məkan məlumatı yüklənmədən əvvəl silinir.',
          'Paylaşımı sonradan redaktə edə bilərsən; yalnız açıqlama və seçimlər dəyişir. Silsən, mediası da silinir.',
          'Qrupa paylaşmaq üçün qrup səhifəsindən paylaş. Qrupun hər üzvü paylaşa bilər; səsi bağlanan üzv paylaşa bilməz.',
        ],
      ),
      GuideTopic(
        'Bəyənmə, reaksiya və şərh',
        notes: [
          'Paylaşımı bəyənə və ya 😍 😂 😮 👏 🔥 🙏 emojilərindən biri ilə reaksiya bildirə bilərsən. Reaksiyanı dəyişə və ya geri götürə bilərsən.',
          'Paylaşımı görə bilən hər kəs şərh yazır; müəllif şərhləri bağlayıbsa yazılmır.',
          'Şərhə cavab verə, şərhi bəyənə bilərsən. Cavablar tək səviyyəlidir.',
          'Öz şərhini sən, öz paylaşımındakı şərhləri də sən silirsən. Qrup paylaşımındakı şərhləri qrupun sahibi və idarəçiləri də silir.',
        ],
      ),
      GuideTopic(
        'Hekayə paylaşmaq',
        steps: [
          '"+" → "Hekayə"yə toxun.',
          'Şəkil və ya ən çox 60 saniyəlik video seç və paylaş.',
        ],
        notes: [
          'Hekayə 24 saat görünür, sonra arxivinə keçir.',
          'Hekayəni kimlərin gördüyünü yalnız sən görürsən.',
          'Hekayələrini önə çıxanlara əlavə edərək profilində qalıcı göstərə bilərsən.',
        ],
      ),
      GuideTopic(
        'Kəşf və axtarış',
        steps: [
          'Bu gün ekranının sağ yuxarısındakı Axtar düyməsinə toxun.',
          'İnsan və ya #teq axtar. Qrup axtarmaq üçün Qruplar bölməsindən istifadə et.',
        ],
        notes: [
          'Kəşf son iki həftənin, izləmədiyin hamıya açıq hesab və qruplarından ən çox qarşılıqlı əlaqə alan paylaşımlarını göstərir.',
          'Paylaşımın linkini paylaşa bilərsən; açan şəxs onu görmək hüququ varsa görür.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'groups',
    title: 'Qruplar',
    summary: 'Qrup tapmaq, qoşulmaq, rollar və qrup səhifəsi.',
    topics: [
      GuideTopic(
        'Qrup tapmaq',
        notes: [
          'Qruplar bölməsində ada görə axtar və ya kateqoriya seç.',
          'Sağ yuxarıdakı Xəritə düyməsi ilə ətrafındakı qrupları və tədbirləri xəritədə gör.',
          'Qruplar Liqası düyməsi ilə kateqoriyanda və ilində ən yaxşı tədbirləri keçirən qrupları gör.',
          'Bütün aktiv qrupların səhifəsi hamıya açıqdır; gizli qrup yoxdur.',
        ],
      ),
      GuideTopic(
        'Qrupa qoşulmaq',
        intro: 'Qrupun qoşulma növü düymədə yazılır:',
        notes: [
          'Sərbəst: "Qoşul"a toxunanda dərhal üzv olursan.',
          'İstəklə: istək göndərirsən; qrupun idarəçisi təsdiqləyir. İstəyini geri götürə bilərsən.',
          'Dəvətlə: idarəçi səni istifadəçi adınla dəvət edir; Bildirişlər ekranında qəbul və ya rədd edirsən.',
          'Dəvət linki: sənə göndərilən linki açıb "Qrupa qoşul" desən, qoşulma növü nə olursa olsun üzv olursan.',
          'Qrup paketinin üzv limiti dolubsa yeni üzv qəbul olunmur.',
        ],
        tip: 'İlk qrupa qoşulanda sənə bir dəfə 30 günlük "Hamısı Bir Yerdə" şəxsi paket sınağı verilir (uyğunlaşma və komanda yoldaşı xüsusiyyətləri).',
      ),
      GuideTopic(
        'Qrupdan çıxmaq',
        steps: [
          'Qrup səhifəsində üzvlük düyməsinə toxun.',
          '"Qrupdan çıx"ı seç.',
        ],
        notes: [
          'Rolların silinir və qrupun gələcək tədbirlərindəki iştirakın ləğv olunur.',
          'Qrup sahibi qrupdan çıxa bilməz; əvvəlcə sahibliyi təhvil verməlidir.',
        ],
      ),
      GuideTopic(
        'Qrup səhifəsində nələr var?',
        notes: [
          'Üz qabığı, loqo, təqdimat, qaydalar, linklər, il və kateqoriya.',
          'Canlı yayım kartı: davam edən və planlaşdırılan yayımlar.',
          'Tədbirlər, "Necə idi?" dəyərləndirmələri və qrupun orta balı.',
          'Sorğular, hədəflər, liqa kartı və qrup paylaşımları.',
          'Üzvlər: idarə komandası hamıya açıqdır; üzv siyahısının tamamını yalnız qrupun üzvləri görür.',
          'Qrup söhbəti: hər qrupun tək söhbəti var, yalnız üzvlər oxuyur və yazır.',
        ],
      ),
      GuideTopic(
        'Qrupdaxili rollar',
        intro: 'Bir üzvün birdən çox rolu ola bilər. Mötərizədəki rəqəm rütbədir.',
        notes: [
          'Qrup Sahibi (100): hər şey, ödəniş və rol təyini.',
          'İdarəçi (80): məzmun, tədbir, sorğu, üzv təsdiqi və dəvəti, canlı yayım, səsverməsiz ban, səsli zəng tələbləri.',
          'İntizam Şurası (60): intizam dosyələrinə səs verir; şikayətə baxış, təcili səssizləşdirmə, canlı yayım moderasiyası.',
          'Moderator (50): şikayətə ilkin baxış, təcili səssizləşdirmə, canlı yayım moderasiyası.',
          'Üzv (10): iştirak, paylaşım, canlı yayına qoşulma.',
          'Rütbə qaydası: heç kim özü ilə bərabər və ya daha yüksək rütbəli birinə sanksiya tətbiq edə bilməz. Qrup sahibi banlana bilməz.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'group-admin',
    title: 'Qrup yaratmaq və idarə etmək',
    summary: 'Sahiblər və idarəçilər üçün: qrup, dəvət, rollar, paketlər, hədəflər.',
    topics: [
      GuideTopic(
        'Qrup yaratmaq',
        steps: [
          '"+" → "Qrup"a toxun.',
          'Qrupun adını (3–60 simvol) və ünvanını yaz. Ünvan səhifənin linkidir (/g/unvan) və sonradan dəyişmir.',
          'Kateqoriyanı və ili seç. İl xəritə və Qruplar Liqası üçün lazımdır.',
          'Qoşulma növünü seç: sərbəst, istəklə və ya dəvətlə.',
          'Loqo, üz qabığı, təqdimat, qaydalar və ən çox 5 link əlavə et.',
        ],
        notes: ['Qrupu yaradan şəxs qrup sahibidir. Bundan əlavə, qrupun öz söhbəti də açılır.'],
      ),
      GuideTopic(
        'Üzv qəbul etmək və dəvət etmək',
        notes: [
          'İstəklə qoşulan qrupda gözləyən istəkləri qrup səhifəsində qəbul və ya rədd edirsən (sahib və idarəçi).',
          'İstifadəçi adı ilə dəvət göndərə bilərsən. Bir qrup 24 saatda ən çox 50 dəvət göndərir; geri götürülən dəvətlər də sayılır.',
          'Göndərdiyin dəvəti qəbul olunana qədər geri götürə bilərsən.',
        ],
      ),
      GuideTopic(
        'Dəvət linki',
        intro: 'Qrupunu WhatsApp və ya Instagramdan köçürməyin ən asan yolu.',
        steps: [
          'Qrup səhifəsində "Dəvət linki" bölməsini aç.',
          'Müddəti seç (1, 7 və ya 30 gün); istəsən istifadə limiti qoy (1–1000 nəfər).',
          'Linki paylaş. Açan şəxs giriş edib "Qrupa qoşul" deyəndə üzv olur.',
        ],
        notes: [
          'Bir qrupun eyni vaxtda ən çox 20 keçərli linki olur.',
          'Linki istədiyin an ləğv edə bilərsən; ləğv geri qaytarılmır, yenisini yaradırsan.',
          'Paylaşılan link WhatsAppda qrupun adı və şəkli ilə önizlənir.',
        ],
      ),
      GuideTopic(
        'Rol vermək və sahibliyi təhvil vermək',
        notes: [
          'Rolları yalnız qrup sahibi verir və alır: İdarəçi, İntizam Şurası, Moderator. Rol yalnız üzvə verilir.',
          'Sahibliyi aktiv üzvə təhvil verə bilərsən. Sən adi üzv kimi qalırsan; yeni sahib istəsə sənə rol verir.',
          'Qrupu yalnız sahibi silir. Silmə qalıcıdır.',
          'Qrup sahibi olanda hesabını silə bilməzsən; əvvəlcə sahibliyi təhvil ver və ya qrupu sil.',
        ],
      ),
      GuideTopic(
        'Qrup paketləri',
        intro: 'Paket qrupun ən çox üzv sayını, aylıq tədbir sayını və aylıq canlı yayım dəqiqəsini müəyyən edir.',
        steps: [
          'Qrup səhifəsindəki "Paket" kartını aç; cari paketini, limitlərini və istifadəni gör.',
          'Paketi vebdən satın al. Mobil tətbiq yalnız paket statusunu göstərir.',
        ],
        notes: [
          'Abunəliyi olmayan qrup pulsuz paketin limitlərindən istifadə edir.',
          'Paketlər öncədən ödənişlidir (aylıq və ya illik); avtomatik yenilənmə yoxdur, kart saxlanılmır.',
          'Üst paketə keçəndə qalan müddətin yeni paketə köçürülür. Eyni paketi yeniləsən, müddət sona əlavə olunur.',
          'Türkiyədən ödənişlər PayTR ilə TL, xaricdən iyzico ilə USD kimi alınır.',
          'Üzv limiti dolsa, mövcud üzvlər qalır, yeni üzv qəbul olunmur.',
          'Cari qiymətlər və limitlər paket ekranında yazılır. Paketi sahib satın alır.',
        ],
      ),
      GuideTopic(
        'Hədəflər və tapşırıqlar',
        intro: 'Qrupu ortaq məqsəd ətrafında birləşdirir. Hədəfləri sahib və idarəçilər açır; mükafat nişandır, pul və ya xal yoxdur.',
        notes: [
          'Şəxsi hədəf: hər üzv öz sayına çatanda nişan alır.',
          'Qrup hədəfi: qrupun cəmi hədəfə çatanda töhfəsi olan hər kəs nişan alır.',
          'Komanda hədəfi: komandalar qurulur, komandanın cəmi sayılır.',
          'Tapşırıq: üzv "Etdim" deyir, qısa qeyd əlavə edir; idarəçi təsdiqləsə nişan verilir.',
          'Sayılanlar: iştirak, təşkilatçılıq və ya xatirə. İrəliləyişi server hesablayır.',
        ],
      ),
      GuideTopic(
        'Qrup söhbətini idarə etmək',
        notes: [
          'Qrup söhbətini yalnız idarəçilərin yaza biləcəyi şəkildə tənzimləyə bilərsən (elan kanalı kimi).',
          'Uyğunsuz mesajdan şikayət edilsə, qrupun moderasiya ekranına düşür; səlahiyyətli şəxs onu götürə bilər.',
        ],
      ),
      GuideTopic(
        'Səsli zəng tələblərinə cavab vermək',
        intro: 'Üzvlər birbaşa səsli zəng yetkisini qrupdan istəyir. Tələbləri qrup sahibi və idarəçilər görür.',
        steps: [
          'Qrup səhifəsində "Səsli zəng tələbləri"ni aç.',
          'Tələbi aç və ya səbəb yazaraq rədd et.',
          'Açdığın yetkini səbəb yazaraq istədiyin an bağlaya bilərsən.',
        ],
        notes: ['Şəxs qrupdan çıxsa, çıxarılsa və ya banlansa, yetkisi özbaşına bağlanır.'],
      ),
    ],
  ),
  GuideChapter(
    id: 'events',
    title: 'Tədbirlər',
    summary: 'Qatılmaq, gözləmə siyahısı, qarşılama, əl sıxma, dəyərləndirmə.',
    topics: [
      GuideTopic(
        'Tədbirə qatılmaq',
        steps: [
          'Tədbirin səhifəsini aç (qrup səhifəsindən, Bu gün ekranından, təqvimdən və ya xəritədən).',
          'Tarixi, yeri, ödəniş məlumatını, iştirak şərtlərini və lazım olan avadanlığı oxu.',
          '"Qatıl"a toxun. Yer qalmayıbsa "Gözləmə siyahısına yazıl" yazılır.',
        ],
        notes: [
          'Tədbirləri hamı görür, yalnız qrupun üzvləri qatılır.',
          'Gözləmə siyahısındasansa, biri imtina edəndə sıran çatır və bildiriş alırsan.',
          'Təsdiqli iştiraklı tədbirdə "İştirak istəyi göndər" yazılır; təşkilatçı təsdiqləyəndə qatılırsan.',
          'İmtina etmək üçün "İmtina et"ə toxun; yerin gözləmə siyahısındakı ilk şəxsə keçir.',
          'Tədbir başladıqdan sonra iştirak bağlanır.',
        ],
      ),
      GuideTopic(
        'İştirak haqqı',
        intro: 'Haqq yalnız məlumat kimi göstərilir. GWAY ödəniş almır; haqq tədbir sahibinə onun göstərdiyi qaydada (məs. yerində nağd) ödənilir.',
      ),
      GuideTopic(
        'Təqvimə əlavə et və marşrut',
        notes: [
          '"Təqvimə əlavə et" tədbiri telefonunun təqvim tətbiqinə əlavə edir.',
          'Görüş nöqtəsi işarələnibsə, səhifədəki kiçik xəritənin altındakı "Marşrut" cihazının xəritə tətbiqini açır.',
        ],
      ),
      GuideTopic(
        'Eyni saatda iki tədbir',
        intro: 'Qatıldığın tədbirin saatında başqa tədbirin varsa, tətbiq səndən digərindən imtina edib yerini boşaltmaq istəyib-istəmədiyini soruşur. Seçim sənindir; heç nə özbaşına ləğv olunmur.',
      ),
      GuideTopic(
        '"Gəlirsən?" təsdiqi',
        intro: 'Başlanğıca 24 saatdan az qalanda sənə xatırlatma gəlir və tədbir səhifəsində "Gəlirsən?" kartı çıxır.',
        notes: [
          '"Bəli, gəlirəm": təşkilatçı gələcəyini görür.',
          '"Gələ bilmirəm": iştirakdan imtina edirsən; yerin gözləmə siyahısındakı ilk şəxsə keçir.',
          'Cavab verməsən siyahıdan çıxarılmırsan.',
        ],
      ),
      GuideTopic(
        'Qarşılama: ilk dəfə gedirsənsə',
        intro: 'Bir qrupun tədbirinə ilk dəfə gedirsənsə, qrupun könüllü üzvü səni qarşılaya bilər.',
        steps: [
          'Tədbirə qatıl.',
          'Səhifədəki qarşılama bölməsində "Qarşılanmaq istəyirəm"ə toxun; istəsən özünü təsvir edən qeyd yaz (məs. "Qırmızı gödəkçədəyəm").',
          'Qarşılayan istəyi üstlənəndə görüş qeydini (məs. "Girişdəki kafenin önü, 08:45") bildiriş kimi alırsan.',
          'Tədbirdən sonra qarşılayana təşəkkür edə bilərsən.',
        ],
        notes: [
          'Qarşılayan olmaq üçün tədbirə qatıl; açıq istəkləri qarşılama bölməsində görürsən. Bir tədbirdə ən çox 3 nəfəri qarşılaya bilərsən.',
          'Qarşılama nişanları: Qapı açan (1), Ev sahibi (5), İcmanın ürəyi (20).',
        ],
      ),
      GuideTopic(
        'Sürpriz məkan',
        intro: 'Bəzi tədbirlərdə məkan sürprizdir. Səhifədə yalnız ipucu (məs. "Kadıköydə, dəniz kənarında") və məkanın nə vaxt açıqlanacağı yazılır.',
        notes: [
          'Məkan açıqlanma vaxtında qatılanlara bildirişlə açıqlanır.',
          'Gözləmə siyahısındakılar və qatılmayanlar məkanı görmür. Sonradan qatılsan və vaxt keçibsə, dərhal görürsən.',
        ],
      ),
      GuideTopic(
        'Əl sıxma: tanış olduğun insanları qeyd et',
        intro: 'Eyni tədbirə qatılan iki nəfər bir-birinin QR kodunu oxudaraq tanış olduqlarını qeyd edir.',
        steps: [
          'Tədbir başlamazdan 1 saat əvvəldən bitdikdən 6 saat sonraya qədər səhifədə "Əl sıxma" kartı görünür.',
          'Kodunu göstər və ya qarşındakının kodunu kamera ilə oxut. Kamera yoxdursa, 6 simvollu kodu yaz.',
        ],
        notes: [
          'Kod 3 dəqiqədən bir yenilənir; şəkli sonradan işə yaramır.',
          'Tanış olduqlarını yalnız sən görürsən: Mən → İlin xülasəsi düyməsi → Tanış olduqlarım. Profilində yalnız say görünür.',
          'Əl sıxma mesaj hüququ vermir.',
        ],
      ),
      GuideTopic(
        'Tədbirdən sonra',
        notes: [
          'Bitdikdən sonra sənə dəyərləndirmə istəyi gəlir; 1–5 ulduz ver. Qrupun balı bu dəyərləndirmələrin ortalamasıdır.',
          'Tədbirə bağlı paylaşım edərək xatirəni əlavə edə bilərsən; xatirələr nişan və hədəflərə sayılır.',
          'Qatılmısansa səhifədə "Mən də orada idim" kartı çıxır; şəkil kimi Instagram hekayəsinə və ya WhatsAppa paylaşa bilərsən. Kartda başqa iştirakçının adı və ya üzü yoxdur.',
          'Qrupun keçmiş tədbirlərini qrup səhifəsindən görə bilərsən.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'event-admin',
    title: 'Tədbir və sorğu təşkil etmək',
    summary: 'Sahiblər və idarəçilər üçün: yaratmaq, təkrar, təsdiq, ləğv, sorğu.',
    topics: [
      GuideTopic(
        'Tədbir yaratmaq',
        steps: [
          'Qrup səhifəsində "Tədbir yarat"a toxun.',
          'Üz qabığı, başlıq, açıqlama, başlanğıc və istəyə bağlı bitmə vaxtını daxil et. Başlanğıc ən azı 15 dəqiqə, ən çox 1 il sonra olmalıdır.',
          'Yeri yaz, istəsən xəritədə sancaqla görüş nöqtəsini və ya onlayn linki əlavə et.',
          'Tutum (boş buraxsan limitsiz), iştirak haqqı məlumatı, iştirak şərtləri və avadanlıq siyahısını əlavə et.',
          'Lazımdırsa "İştirak təsdiqlə olsun"u aç və yadda saxla.',
        ],
        notes: [
          'Forma bu ay qalan tədbir haqqını göstərir. Paketinin aylıq limitinə ləğv edilən tədbirlər də sayılır.',
          'Forma seçdiyin gün ilindəki eyni kateqoriyadan başqa qrupların neçə tədbiri olduğunu da göstərir; istəsən tarixi dəyişirsən.',
        ],
      ),
      GuideTopic(
        'Təkrarlanan tədbir',
        intro: 'Yaradarkən "Təkrar" bölməsində "Hər həftə" və ya "İki həftədən bir" seçərək təkrarlanan seriya açırsan (istəyə bağlı bitmə tarixi ilə, ən çox 1 il).',
        notes: [
          'Seriya həmişə qarşıdakı 4 həftəni açıq saxlayır. Hər tarixin öz iştirakçıları və gözləmə siyahısı var.',
          'Son tarixi redaktə etsən, sonra açılacaq tarixlər də ona görə açılır.',
          'Tədbir menyusundakı "Təkrarı dayandır" ilə seriyanı dayandıra bilərsən; açılmış tarixlər qalır, istəsən tək-tək ləğv edirsən.',
          'Aylıq limit dolsa tarix açılmır, sənə bildiriş gəlir; limit açılanda tarix açılır.',
        ],
      ),
      GuideTopic(
        'Sürpriz məkan tənzimləmək',
        steps: [
          'Formada "Sürpriz məkan"ı aç.',
          '"Yer" sahəsinə ipucu yaz; əsl məkanı və görüş nöqtəsini ayrıca daxil et.',
          'Açıqlanma vaxtını seç: başlanğıcdan 1, 3, 6, 12 və ya 24 saat əvvəl.',
        ],
        notes: ['Sürprizi bağlasan, gizli məkan silinir və "Yer" adi yer olur.'],
      ),
      GuideTopic(
        'İştirakçıları idarə etmək',
        notes: [
          'Təsdiqli iştirakda gözləyən istəkləri qəbul və ya rədd edirsən.',
          'İştirakçı siyahısında "Gəlirsən?" təsdiqini kimin verdiyini görürsən.',
          'Tədbirdən sonra gəlməyənləri "gəlmədi" kimi işarələyirsən; işarələnənlər qatılmış sayılmır.',
          'Redaktə: başlıq, açıqlama, vaxt, yer, tutum, haqq və üz qabığı dəyişə bilər. Vaxt və ya yer dəyişsə qatılanlara bildiriş gedir. Tutum qatılanların sayından aşağı düşə bilməz.',
          'Ləğv: səbəb yazaraq ləğv edirsən; qatılanlara və gözləyənlərə bildiriş gedir. Keçmiş tədbir redaktə olunmur.',
        ],
      ),
      GuideTopic(
        'Sorğu açmaq və səs vermək',
        steps: [
          'Qrup səhifəsində "Sorğu aç"a toxun (sahib və idarəçilər).',
          'Sualı və 2–10 seçimi yaz.',
          'İstəsən çoxlu seçimə icazə ver, sorğunu gizli et, bitmə vaxtı qoy və ya tədbirə bağla.',
        ],
        notes: [
          'Sorğuları və nəticələri yalnız qrupun üzvləri görür.',
          'Gizli sorğuda kimin nəyə səs verdiyini heç kim, sorğunu açan da görə bilməz.',
          'Sorğu bağlananda səs vermək olmur, nəticələr qalır. Səlahiyyətli şəxs sorğunu tez bağlaya və ya silə bilər.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'calendar',
    title: 'Təqvim, Bu axşam və kəşf',
    summary: 'Təqvim, Bu axşam boşam, kiçik masa, xəritə, liqa, ilin xülasəsi.',
    topics: [
      GuideTopic(
        'Təqvimim',
        notes: [
          'Təqvim bölməsi qatıldığın, təsdiq gözlədiyin və gözləmə siyahısında olduğun tədbirləri göstərir.',
          '"Qruplarımın tədbirləri"ni açsan, üzvü olduğun qrupların bütün tədbirləri də gəlir.',
          'Gün, həftə və ay görünüşü arasında keçirsən.',
          'Vaxtı üst-üstə düşən tədbirlər işarələnir.',
          'Qrup səhifəsindən o qrupun təqvimini də aça bilərsən.',
        ],
      ),
      GuideTopic(
        'Bu axşam boşam',
        steps: [
          '"+" → "Bu axşam"a toxun.',
          '"Bu axşam boşam"ı aç; istəsən qısa qeyd yaz (məs. "qəhvə, qısa gəzinti").',
        ],
        notes: [
          'Statusunu yalnız səninlə ən azı bir qrupu paylaşanlar görür.',
          'Status gecə 04:00-da özbaşına bağlanır; istədiyin an özün də bağlayırsan.',
        ],
      ),
      GuideTopic(
        'Kiçik masa',
        intro: 'Bu axşam boş olanlarla kiçik görüş qurur.',
        steps: [
          '"Bu axşam" səhifəsində "Kiçik masa qur"a toxun.',
          'Tətbiq ortaq qruplarınız olan, bu axşam boş 3–5 nəfəri seçib dəvət edir.',
          'Qəbul edənlərlə masanın söhbətində yazışırsınız.',
        ],
        notes: [
          'Masa üçün çağırıla biləcək ən azı 2 nəfər olmalıdır; yoxdursa kart daha neçə nəfər lazım olduğunu yazır.',
          'Bir gecədə yalnız bir masaya qoşula bilərsən.',
          'Masa ertəsi gün 12:00-da bağlanır; söhbət oxunur, amma yazılmır.',
        ],
      ),
      GuideTopic(
        'Xəritə ilə kəşf',
        steps: [
          'Qruplar bölməsində sağ yuxarıdakı Xəritə düyməsinə toxun.',
          'Xəritəni sürüşdür; kateqoriyaya, vaxta (bu gün, 7 gün) və xəritənin ortasından məsafəyə (5–50 km) görə süz.',
          'Xəritə və ya siyahı görünüşünü seç.',
        ],
        notes: [
          'Xəritədə yalnız gələcək tədbirlər və aktiv qruplar görünür. Sənin məkanın xəritədə istifadə olunmur və heç kimə göstərilmir.',
          'Xəritə müvəqqəti bağlıdırsa, üstündə "Xəritə hazırda əlçatan deyil." yazılır.',
        ],
      ),
      GuideTopic(
        'Qruplar Liqası',
        intro: 'Eyni kateqoriya və ildəki qruplar hər ay yaxşı tədbir keçirərək xal toplayır.',
        notes: [
          'Xallar: qatılan hər şəxs, ən azı 3 nəfərin qatıldığı hər tədbir, hər qarşılama və hər 4–5 ulduzlu dəyərləndirmə.',
          'Bərabərlikdə üzv sayı az olan qrup öndədir.',
          'Ay bağlananda ilk üçə girən qrupların üzvlərinə bildiriş gedir; qrup səhifəsindəki liqa kartında yerlər görünür.',
        ],
      ),
      GuideTopic(
        'İlin xülasəsi və kəşf xəritəm',
        steps: [
          'Mən bölməsində sağ yuxarıdakı İlin xülasəsi düyməsinə toxun.',
          '"İlin xülasəsi", "Kəşf xəritəm" və ya "Tanış olduqlarım"ı seç.',
        ],
        notes: [
          'İlin xülasəsi: qatıldığın tədbir sayı, ümumi saat, getdiyin qruplar, illər və kateqoriyalar. Hekayə kartı kimi paylaşa bilərsən.',
          'Kəşf xəritəm: qatıldığın tədbirlərin illəri Türkiyə xəritəsində dolur ("7 / 81 ili kəşf etdim").',
          'Bu səhifələri yalnız sən görürsən; sən paylaşmasan heç kim görə bilməz.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'live',
    title: 'Canlı səsli yayım',
    summary: 'Yayına qoşulmaq, danışmaq, reaksiyalar, yayım başlatmaq və idarə etmək.',
    topics: [
      GuideTopic(
        'Yayına qoşulmaq',
        steps: [
          'Bu gün ekranındakı "İndi canlı" kartına, qrup səhifəsindəki yayım kartına və ya yayım bildirişinə toxun.',
          'Yayına qoşulanda səhnədəkiləri və dinləyiciləri görürsən.',
        ],
        notes: ['Yalnız qrupun üzvləri qoşulur. Yayından çıxarılan şəxs o yayına bir daha girə bilməz.'],
      ),
      GuideTopic(
        'Yayında olarkən tətbiqdə hərəkət',
        intro: 'Geri düyməsinə və ya sol yuxarıdakı aşağı oxa basmaq səni yayından çıxarmır; yayım ekranı kiçilir və səs davam edir.',
        notes: [
          'Hər səhifənin üstündə "Canlı yayımdasan" zolağı görünür. Zolağa toxunanda yayına qayıdırsan.',
          'Səhnədəsənsə mikrofonunu zolaqdan da bağlayıb aça bilərsən.',
          'Yayından çıxmaq üçün yayım ekranındakı "Ayrıl"a bas. Başqa yayına girsən əvvəlkindən çıxırsan.',
        ],
      ),
      GuideTopic(
        'Danışmaq: əl qaldırma və səhnə',
        steps: [
          'Dinləyicisənsə ✋ düyməsi ilə əlini qaldır.',
          'Yayım idarəçisi səni səhnəyə alanda mikrofon düymən çıxır; toxunaraq aç və danış.',
          'Səhnədən özün enmək üçün "Səhnədən en"ə toxun.',
        ],
        notes: [
          'Mikrofonunu idarəçi bağlayıbsa, sən aça bilməzsən; yalnız idarəçi yenidən açır.',
          'Danışanın şəklinin ətrafı rənglənir.',
        ],
      ),
      GuideTopic(
        'Reaksiyalar və şərhlər',
        notes: [
          'Reaksiyalar düyməsi ilə ❤️ 👏 😂 🔥 😮 🙌 göndər; ekranda uçaraq görünür və saxlanılmır.',
          'Şərhlər düyməsi ilə yazılı şərh yazırsan. Şərhlər yayımın qeydi ilə birlikdə qalır.',
          'Öz şərhini basılı saxlayıb silə bilərsən; başqasının şərhindən şikayət edə bilərsən.',
        ],
      ),
      GuideTopic(
        'Yayım başlatmaq',
        intro: 'Qrup sahibi və idarəçilər yayım başladır.',
        steps: [
          'Qrup səhifəsindəki canlı yayım kartında "Yayım başlat"a toxun.',
          'Başlığı yaz. Dərhal başlat və ya irəli tarixə planla.',
        ],
        notes: [
          'Bir qrupda eyni vaxtda bir canlı yayım və ən çox beş planlı yayım olur.',
          'Planlı yayım qrup səhifəsində "Yaxınlaşan" kimi görünür; üzvlər "Xatırlat" deyir. Planlı yayımı aparıcı planlanan vaxtdan ən çox 15 dəqiqə əvvəl başlada bilər.',
          'Yayım dəqiqəsi qrupun paketinə bağlıdır; başlatma ekranı qalan dəqiqəni göstərir. Dəqiqə dolanda yayım özbaşına bitir.',
          'Aparıcı yayından ayrılsa və 2 dəqiqə ərzində qayıtmasa, yayım özbaşına bitir.',
        ],
      ),
      GuideTopic(
        'Yayımı idarə etmək',
        intro: 'Yayımı başladan şəxs və qrupun moderasiya səlahiyyətliləri yayım idarəçisidir.',
        notes: [
          'Bir şəxsə toxunaraq səhnəyə alır, səhnədən endirir, mikrofonunu bağlayır və ya açırsan.',
          '"Yayından çıxar": şəxs bu yayına bir daha girə bilməz.',
          'Qaldırılan əlləri ən yuxarıdakı "əl qaldırdı" kartında görürsən.',
          'Sağ yuxarıdakı menyudan "Yayımı hamı üçün bitir".',
          'Səhnədə aparıcı daxil ən çox 10 nəfər olur. Rütbə qaydası burada da keçərlidir.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'messages',
    title: 'Mesajlar və səsli zəng',
    summary: 'Kimlərlə yazışılır, qrup söhbəti, mesaj məxfiliyi, səsli zəng.',
    topics: [
      GuideTopic(
        'Kimlərlə mesajlaşa bilərəm?',
        notes: [
          'Birbaşa mesaj yalnız uyğunlaşdığın insanlarla və komanda yoldaşlarınla açıqdır. İzləmə mesaj hüququ vermir.',
          'Uyğunlaşdığın şəxsə yazmaq Uyğunluq Söhbəti paketi, komanda yoldaşına yazmaq Komanda Yoldaşı paketi tələb edir. Gələn mesajları oxumaq pulsuzdur.',
          'Qrup söhbətləri pulsuzdur; qrupun bütün üzvləri yazır.',
          'Mesajlar ekranı Bu günün sağ yuxarısındakı Mesajlar düyməsindədir. Oxunmamış mesaj sayı düymədə görünür.',
        ],
      ),
      GuideTopic(
        'Mesaj yazmaq və silmək',
        notes: [
          'Mətn (ən çox 2.000 simvol) və bir şəkil göndərə bilərsən.',
          'Mesaj göndərilərkən "Göndərilir…" yazılır. Göndərilməsə mətn qutuya geri qayıdır və səbəbi yazılır.',
          'Birbaşa söhbətdə qarşı tərəf oxuyanda "Görüldü" yazılır.',
          'Öz mesajını hamıdan silə bilərsən; mesajın yerində "Bu mesaj silindi" yazılır və məzmunu tamamilə silinir.',
        ],
      ),
      GuideTopic(
        'Mesaj məxfiliyi',
        intro: 'GWAY platforma komandası şəxsi mesajlarını oxuya, səsli zəngini dinləyə və kimin kimə zəng etdiyini görə bilməz.',
        notes: [
          'Mesajdan şikayət edə bilərsən. Birbaşa mesaj şikayəti platforma komandasına, qrup söhbəti mesajı şikayəti qrupun moderasiyasına gedir.',
          'Qrupun intizam şurası birbaşa mesajlarını görə bilməz.',
        ],
      ),
      GuideTopic(
        'Səsli zəng yetkisi almaq',
        intro: 'Birbaşa səsli zəng hamıya açıq deyil; yetkini üzvü olduğun qrupun sahibi və ya idarəçisi verir.',
        steps: [
          'Ayarlar → "Səsli zəng"i aç.',
          'Üzvü olduğun qrupu seç, istəsən qısa qeyd yaz və tələb et.',
          'Statusunu eyni ekranda görürsən: baxılır, açıq və ya bağlı (səbəbi ilə). Qərar bildiriş kimi də gəlir.',
        ],
        notes: ['Yetkini verən qrupdan çıxsan, yetkin bağlanır.'],
      ),
      GuideTopic(
        'Səsli zəng etmək',
        steps: [
          'Uyğunlaşdığın şəxslə və ya komanda yoldaşınla söhbəti aç.',
          'Sağ yuxarıdakı "Səsli zəng" düyməsinə toxun.',
        ],
        notes: [
          'İki tərəfin də zəng yetkisi açıq olmalı və söhbətdəki kimi paket haqqı olmalıdır. Zəng edə bilmirsənsə düymənin yerində səbəb yazılır.',
          '30 saniyədə açılmayan zəng buraxılmış olur. Zəng ən çox 60 dəqiqə çəkir.',
          'Zəng yazılmır və ucdan-uca şifrələnir. Ekrandakı 12 rəqəmli təhlükəsizlik kodu ikinizdə eynidirsə, araya heç kim girməyib.',
          'Eyni anda tək zəng edilir; məşğul olan şəxsə zəng etmək olmur.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'matching',
    title: 'Uyğunlaşma və komanda yoldaşı',
    summary: 'Dost və sevgili uyğunlaşması, şəxsi paketlər, komanda yoldaşı tapmaq.',
    topics: [
      GuideTopic(
        'Uyğunlaşma necə işləyir?',
        intro: 'Uyğunlaşma ortaq qrupların olan insanlardan dost və ya sevgili tapmağa imkan verir. Ayrıca uyğunluq profili ilə işləyir; sən açmasan heç kim səni orada görmür.',
        steps: [
          'Mən bölməsində sağ yuxarıdakı Uyğunlaşma düyməsinə toxun (geniş ekranda soldakı menyuda).',
          'Uyğunluq profilini yarat: Dost, Sevgili və ya ikisi; 2–6 şəkil, doğum tarixi, cins, il, "haqqımda".',
          'Sevgili rejimində axtardığın cinsləri və yaş aralığını seç.',
          'Açıq razılığı təsdiqlə.',
        ],
        notes: [
          'Destəndə yalnız səninlə ən azı bir ortaq qrupu olan, eyni rejimi açmış insanlar çıxır.',
          'Sevgili rejimində ikinizin də seçimi bir-birinə uyğun olmalıdır.',
          'Məkan kimi yalnız ilin istifadə olunur.',
        ],
      ),
      GuideTopic(
        'Sürüşdürmək və uyğunlaşmaq',
        notes: [
          'Sağa sürüşdür: bəyən. Sola: keç. Yuxarı: super bəyən. Aşağıdakı düymələr də eyni işi görür.',
          'Kartın kənarlarına toxunanda şəkillər dəyişir; "i" düyməsi profilin tamamını açır.',
          'İkiniz də bir-birinizi eyni rejimdə bəyənsəniz, uyğunlaşırsınız və bildiriş gəlir.',
          'Gündəlik pulsuz bəyənmə və super bəyənmə haqqın uyğunlaşma ekranında yazılır.',
          'Keçdiyin şəxs 90 gün sonra yenidən təklif oluna bilər.',
        ],
      ),
      GuideTopic(
        'Şəxsi paketlər',
        intro: 'Hər xüsusiyyət ayrıca paket kimi satılır; yalnız istədiyini alırsan.',
        notes: [
          'Uyğunluqlarım: kiminlə uyğunlaşdığını görmək. Paketsiz uyğunlaşdığını bilirsən, amma şəxs gizli qalır.',
          'Uyğunluq Söhbəti: uyğunlaşdıqlarına yazmaq.',
          'Səni Bəyənənlər: səni bəyənənlərin siyahısı.',
          'Limitsiz Bəyənmə: limitsiz bəyənmə, geri al və filtrlər.',
          'Super Bəyənmə və Önə Çıx: daha çox super bəyənmə, gündə bir dəfə destələrin başında görünmək.',
          'Komanda Yoldaşı: komanda yoldaşı bölməsi və komanda yoldaşına yazmaq.',
          'Hamısı Bir Yerdə: hamısı.',
          'Paketlər öncədən ödənişlidir, avtomatik yenilənmir və vebdən satın alınır. Qiymətlər Uyğunlaşma → Paketlər ekranında yazılır.',
        ],
      ),
      GuideTopic(
        'Uyğunluğu bitirmək, dayandırmaq, silmək',
        notes: [
          'Uyğunluğu bitirsən, söhbətiniz bağlanır, qarşılıqlı izləmə götürülür və bir-birinizin destəsinə çıxmırsınız.',
          'İki rejimdə də uyğunlaşmısınızsa "Yalnız dost qal" və ya "Yalnız sevgili qal" deyə bilərsən.',
          'Profilini dayandırsan, destən və bəyənmələr dayanır, mövcud uyğunluqlar qalır.',
          'Uyğunluq məlumatlarının hamısını (profil, şəkillər, bəyənmələr, uyğunluqlar) bir toxunuşla silə bilərsən.',
          'Uyğunluq profilindən və şəkillərindən şikayət edə bilərsən.',
        ],
      ),
      GuideTopic(
        'Komanda yoldaşı tapmaq',
        intro: 'Məşq, yürüş və ya səhnə üçün birlikdə hərəkət edəcəyin insanları tapırsan.',
        steps: [
          'Ayarlar → "Komanda yoldaşı seçimləri"ndə "Komanda axtarıram"ı aç.',
          'Fəaliyyətləri, səviyyəni, hədəflərini, tezliyini, uyğun vaxtlarını və istəsən ilini seç.',
          'Mən bölməsində "Komanda yoldaşı tap" düyməsi ilə təklifləri gör. Hər təklifin səbəbi yazılır (ortaq fəaliyyət, ortaq qrup, eyni il…).',
          'İstək göndər (ən çox 200 simvollu mesajla). Qarşı tərəf qəbul edəndə komanda yoldaşı olursunuz.',
        ],
        notes: [
          'İlin yalnız uyğunlaşdırmada istifadə olunur, profilində görünmür.',
          'Gündə ən çox 20 istək göndərə, eyni şəxsə gündə bir istək ata bilərsən.',
          'Komanda yoldaşı bölməsi Komanda Yoldaşı paketi tələb edir.',
          'Komanda yoldaşlığını iki tərəf də istədiyi an bitirə bilər.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'notifications',
    title: 'Bildirişlər',
    summary: 'Bildiriş növləri, seçimlər və telefon bildirişləri.',
    topics: [
      GuideTopic(
        'Bildirişlər ekranı',
        notes: [
          'Bu günün sağ yuxarısındakı zəng düyməsi ilə açılır; oxunmamış sayı düymədə görünür.',
          'Bildirişlər Bu gün / Bu həftə / Daha əvvəl kimi qruplaşdırılır; gözləyən izləmə istəkləri ən yuxarıdadır.',
          'Bildirişə toxunanda əlaqəli səhifə açılır.',
        ],
      ),
      GuideTopic(
        'Bildiriş seçimləri',
        steps: ['Ayarlar → "Bildiriş seçimləri"ni aç.', 'Bağlamaq istədiklərini bağla.'],
        notes: [
          'Bağlana bilənlər: tədbir xatırlatmaları, tədbir dəyişikliyi və ləğvi, dəyərləndirmə istəkləri, canlı yayım bildirişləri, şəxsi mesajlar, qrup mesajları, uyğunluq bildirişləri.',
          'İştirak təsdiqi, sıranın çatması, sanksiya kimi səni birbaşa maraqlandıran bildirişlər bağlanmır.',
        ],
      ),
      GuideTopic(
        'Telefon bildirişləri gəlmir',
        steps: [
          'Tətbiq ilk açılışda bildiriş icazəsi istəyir; verməmisənsə, telefonun Ayarlar → Tətbiqlər → GWAY → Bildirişlər bölməsindən aç.',
          'Androiddə "Mesajlar", "Səsli zənglər" və "Bildirişlər" kanallarının açıq olduğunu yoxla.',
          'Tətbiqdaxili bildiriş seçimlərini yoxla.',
        ],
        notes: ['Telefon səssiz rejimdədirsə bildiriş səsi çalmır.'],
      ),
    ],
  ),
  GuideChapter(
    id: 'safety',
    title: 'Təhlükəsizlik, şikayət və sanksiyalar',
    summary: 'Şikayət etmək, qrup sanksiyaları, etiraz, iki addımlı təsdiq.',
    topics: [
      GuideTopic(
        'Şikayət etmək',
        steps: [
          'Paylaşımın, şərhin, tədbirin, yayım şərhinin, mesajın və ya profilin menyusunu aç.',
          '"Şikayət et"ə toxun, səbəbi seç və istəsən qısa izah yaz.',
        ],
        notes: [
          'Şikayət etdiyin şəxs şikayəti və səni görmür. Qrupun idarəçiləri də kimin şikayət etdiyini görmür.',
          'Qrupla bağlı şikayət qrupun moderasiyasına, digərləri platforma komandasına gedir.',
          'Özündən və ya öz məzmunundan şikayət edə bilməzsən; eyni məzmundan açıq olduğu müddətdə bir dəfə şikayət edə bilərsən.',
        ],
      ),
      GuideTopic(
        'Qrup sanksiyaları',
        notes: [
          'Xəbərdarlıq: qeydə alınır, sənə bildiriş gəlir.',
          'Səssizləşdirmə (1–90 gün): qrupda paylaşım və şərh edə, qrup söhbətinə yaza bilməzsən; canlı yayımda yalnız dinləyirsən.',
          'Çıxarma: qrupdan çıxarılırsan; sonra yenidən qoşula bilərsən.',
          'Ban (müddətli və ya daimi): müddət ərzində qrupa qoşula, istək göndərə, dəvət ala bilməzsən.',
          'Sanksiyaların Ayarlar → "Qrup sanksiyalarım"da görünür.',
        ],
      ),
      GuideTopic(
        'Sanksiyaya etiraz etmək',
        steps: [
          'Ayarlar → "Qrup sanksiyalarım"ı aç.',
          'Sanksiyanın yanındakı "Etiraz et"ə toxun və səbəbini yaz (10–1000 simvol).',
        ],
        notes: [
          'Hər sanksiyaya 7 gün ərzində bir dəfə etiraz edə bilərsən. Təcili səssizləşdirməyə etiraz edilmir.',
          'Etirazı qrup sahibi qərara bağlayır; sahib dosyədə tərəfdirsə platforma komandası qərar verir.',
          'Qərar gözlənilərkən sanksiya davam edir. Qərar sənə bildirişlə gəlir.',
        ],
      ),
      GuideTopic(
        'Hesabın dayandırılması və ban',
        notes: [
          'Platforma komandası qaydalara zidd hesabı dayandıra və ya bağlaya bilər. Bu halda tətbiq sənə səbəbi və bitmə tarixini göstərir.',
          'Dayandırma müddətində profilin görünür, amma məzmunun gizlədilir; daimi bağlanan hesab heç yerdə görünmür.',
          'Qanunsuz fəaliyyət (zorakılıq, təhdid, fırıldaqçılıq kimi) qrup qərarı ilə işarələnsə, hesab platforma baxana qədər dayandırılır.',
          'Səhv olduğunu düşünürsənsə dəstək komandasına yaz.',
        ],
      ),
      GuideTopic(
        'İki addımlı təsdiq',
        steps: [
          'Ayarlar → "İki addımlı təsdiq"i aç.',
          'Təsdiq tətbiqi (məs. Google Authenticator) əlavə et və ya vebdə barmaq izi və üz tanıma ilə giriş qur.',
        ],
        notes: ['Qurduğun üsul sonrakı girişlərdə birinci sıradadır; SMS həmişə ehtiyat kimi qalır.'],
      ),
    ],
  ),
  GuideChapter(
    id: 'moderation',
    title: 'Qrup moderasiyası',
    summary: 'Səlahiyyətlilər üçün: şikayətə baxış, intizam dosyəsi, səsvermə, ban.',
    topics: [
      GuideTopic(
        'Moderasiya ekranı',
        intro: 'Qrup səhifəsindəki moderasiya kartı gözləyən işlərin sayını göstərir. Sahib, idarəçilər, şura üzvləri və moderatorlar görür.',
        notes: [
          'Şikayətlər: eyni məzmunun şikayətləri tək sətirdə toplanır. Rədd et, Məzmunu götür və ya Dosyə aç.',
          'Dosyələr: səsvermədəki dosyələr, qalan müddət və səs sayları; səs ver.',
          'Sanksiyalar və etirazlar: sahib etirazları buradan qərara bağlayır.',
        ],
      ),
      GuideTopic(
        'İntizam dosyəsi və səsvermə',
        steps: [
          'Şikayətdən və ya üzvlər səhifəsindəki üzv menyusundan "İntizam dosyəsi aç"ı seç.',
          'Təklif olunan sanksiyanı (xəbərdarlıq, səssizləşdirmə, çıxarma, ban) və müddətini seç, səbəbi yaz.',
          'Təcili halda "Dərhal səssizləşdir (24 saat)"ı işarələ; şəxs qərar çıxana qədər səssizləşdirilir.',
        ],
        notes: [
          'İntizam Şurası üzvləri 72 saat ərzində səs verir. Şurası olmayan qrupda sahib tək qərar verir.',
          'Qərar həddi standart olaraq sadə çoxluqdur; sahib moderasiya ekranının ayarından üçdə iki və ya yekdillik seçə bilər.',
          'Hədd keçiləndə dosyə dərhal təsdiqlənir və sanksiya tətbiq olunur. Səs verilməsə dosyə rədd edilir.',
          'Bir şəxs haqqında eyni anda tək açıq dosyə olur. Rütbə qaydası tətbiq olunur.',
        ],
      ),
      GuideTopic(
        'Səsverməsiz ban',
        intro: 'Qrup sahibi və idarəçilər şuranı gözləmədən birini banlaya bilər.',
        steps: [
          '"İntizam dosyəsi aç"da sanksiya kimi ban seç.',
          '"Səsverməsiz, dərhal tətbiq et"i işarələ.',
          'Müddəti (1–365 gün və ya daimi) və səbəbi daxil et.',
        ],
        notes: [
          'İdarəçi başqa idarəçini və sahibi banlaya bilməz.',
          'Cinayət tərkibli haldırsa "qanunsuz fəaliyyət" kimi işarələ və kateqoriyasını seç; şəxsin hesabı platforma baxana qədər dayandırılır.',
          'Şəxs 7 gün ərzində etiraz edə bilər.',
        ],
      ),
      GuideTopic(
        'Canlı yayımda təcili müdaxilə',
        intro: 'Yayımda təqib kimi halda yayım idarəçisi şəxsin mikrofonunu dərhal bağlayır və ya onu yayından çıxarır. Sonra lazım gələrsə intizam dosyəsi açılır.',
      ),
    ],
  ),
  GuideChapter(
    id: 'account',
    title: 'Hesab, məxfilik və dəstək',
    summary: 'Hüquqi mətnlər, məlumatların, hesab silmə, çıxış, dəstək.',
    topics: [
      GuideTopic(
        'Məlumatlarım necə qorunur?',
        notes: [
          'Məkanın yalnız hesab təhlükəsizliyi üçün istifadə olunur; xəritədə və ya profilində göstərilmir.',
          'Doğum tarixin heç kimə göstərilmir.',
          'Şəxsi mesajların platforma komandası tərəfindən oxuna bilməz.',
          'Təsdiqlədiyin mətnlər Ayarlar → "Hüquqi mətnlər"dədir.',
        ],
      ),
      GuideTopic(
        'Hesabımı silmək',
        steps: [
          'Ayarlar → "Hesabı sil"i aç.',
          'Silməni təsdiqlə.',
        ],
        notes: [
          'Profilin başqalarından dərhal gizlədilir. 30 gün ərzində giriş edib "silməni geri al" deyə bilərsən.',
          '30 gün sonra hesabın, paylaşımların, mesajların və faylların qalıcı olaraq silinir.',
          'Bir qrupun sahibisənsə, əvvəlcə sahibliyi təhvil verməli və ya qrupu silməlisən.',
        ],
      ),
      GuideTopic(
        'Çıxış etmək',
        intro: 'Ayarların ən aşağısındakı "Çıxış et"ə toxun. Çıxış etdiyin telefona artıq bildiriş gəlmir.',
      ),
      GuideTopic(
        'Dəstək komandasına yazmaq',
        steps: [
          'Ayarlar → "Dəstək və rəy"i aç.',
          '"Yeni mesaj"a toxun və növü seç: Problem (nəsə işləmir), Tələb (hesabın, qrupun və ya ödənişin üçün əməliyyat), Təklif (yeni xüsusiyyət və ya fikir).',
          'Mövzunu və izahı yaz; ən çox 3 şəkil əlavə edə bilərsən.',
        ],
        notes: [
          'Cavab gələndə Ayarlardakı sətirdə "yeni cavab" yazılır. Mesajın statusu: Yeni, Baxılır, Həll edildi, Bağlandı.',
          'Qrup idarəçisisənsə, qrup səhifəsindən o qrup üçün də mesaj aça bilərsən.',
        ],
      ),
    ],
  ),
];
