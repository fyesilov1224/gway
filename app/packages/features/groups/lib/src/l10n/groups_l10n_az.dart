// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'groups_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Azerbaijani (`az`).
class GroupsL10nAz extends GroupsL10n {
  GroupsL10nAz([String locale = 'az']) : super(locale);

  @override
  String get unsupportedImage =>
      'Bu fayl növü dəstəklənmir. JPEG, PNG və ya WebP seç.';

  @override
  String get joinOpen => 'Sərbəst qoşulma';

  @override
  String get joinOpenHint => 'Hər kəs birbaşa qoşula bilər.';

  @override
  String get joinRequest => 'İstəklə qoşulma';

  @override
  String get joinRequestHint => 'Qoşulma istəklərini idarəçilər təsdiqləyir.';

  @override
  String get joinInvite => 'Dəvətlə qoşulma';

  @override
  String get joinInviteHint => 'Yalnız dəvət edilənlər qoşula bilər.';

  @override
  String get roleOwner => 'Qrup sahibi';

  @override
  String get roleAdmin => 'İdarəçi';

  @override
  String get roleDiscipline => 'İntizam şurası';

  @override
  String get roleModerator => 'Moderator';

  @override
  String get roleMember => 'Üzv';

  @override
  String get handleMin => 'Qrup ünvanı ən azı 3 simvol olmalıdır.';

  @override
  String get handleChars =>
      'Yalnız kiçik hərf, rəqəm, alt xətt və nöqtə istifadə edə bilərsən.';

  @override
  String get handleDots =>
      'Nöqtə ilə başlaya, bitə və ardıcıl işlədilə bilməz.';

  @override
  String get nameMin => 'Qrup adı ən azı 3 simvol olmalıdır.';

  @override
  String nameMax(int max) {
    return 'Qrup adı ən çox $max simvol ola bilər.';
  }

  @override
  String get httpsOnly => 'https:// ilə başlayan ünvan daxil et.';

  @override
  String get createGroup => 'Qrup yarat';

  @override
  String get groupInfo => 'Qrup məlumatları';

  @override
  String get groupInfoHint =>
      'Loqo, örtük, qaydalar və keçidləri qrupu yaratdıqdan sonra əlavə edə bilərsən.';

  @override
  String get groupName => 'Qrup adı';

  @override
  String get about => 'Təqdimat';

  @override
  String get aboutHint => 'Qrupunuz nə edir, kimlər qoşula bilər?';

  @override
  String get joining => 'Qoşulma';

  @override
  String get changeLater => 'Bunu sonra dəyişə bilərsən.';

  @override
  String get createTheGroup => 'Qrupu yarat';

  @override
  String get editGroup => 'Qrupu redaktə et';

  @override
  String get noEditPermission => 'Bu qrupu redaktə etmək icazən yoxdur.';

  @override
  String get backToGroup => 'Qrupa qayıt';

  @override
  String get save => 'Yadda saxla';

  @override
  String get logoAndCover => 'Loqo və örtük';

  @override
  String get imageHint => 'JPEG, PNG və ya WebP · ən çox 5 MB';

  @override
  String get logo => 'Loqo';

  @override
  String get cover => 'Örtük';

  @override
  String groupHandle(String handle) {
    return 'Qrup ünvanı: @$handle';
  }

  @override
  String get rules => 'Qaydalar';

  @override
  String get rulesHint => 'Üzvlərdən gözləntilərin, hər sətrə bir qayda.';

  @override
  String get links => 'Keçidlər';

  @override
  String linksHint(int max) {
    return 'Veb-sayt, sosial media hesabları. Ən çox $max.';
  }

  @override
  String get enterLabel => 'Etiket yaz.';

  @override
  String get label => 'Etiket';

  @override
  String get address => 'Ünvan';

  @override
  String get removeLink => 'Keçidi sil';

  @override
  String get addLink => 'Keçid əlavə et';

  @override
  String get cancel => 'İmtina et';

  @override
  String get saveChanges => 'Dəyişiklikləri yadda saxla';

  @override
  String get deleteGroup => 'Qrupu sil';

  @override
  String get deleteGroupBody =>
      'Qrup, üzvlüklər, rollar, istəklər və dəvətlər həmişəlik silinir. Paketin qalan müddəti geri qaytarılmır.';

  @override
  String deleteGroupNamed(String name) {
    return '$name qrupunu sil';
  }

  @override
  String changeImage(String label) {
    return '$label dəyiş';
  }

  @override
  String addImage(String label) {
    return '$label əlavə et';
  }

  @override
  String get remove => 'Sil';

  @override
  String get deleteForever => 'Qrupu həmişəlik sil';

  @override
  String deleteConfirm(String handle) {
    return 'Bu əməliyyat geri qaytarılmır. Təsdiqləmək üçün qrup ünvanını yaz: $handle';
  }

  @override
  String get delete => 'Sil';

  @override
  String get group => 'Qrup';

  @override
  String get share => 'Paylaş';

  @override
  String shareText(String name) {
    return 'GWAY-də $name qrupuna bax:';
  }

  @override
  String get moreOptions => 'Digər seçimlər';

  @override
  String get leaveGroup => 'Qrupdan çıx';

  @override
  String get groupNotFound => 'Bu qrup tapılmadı və ya artıq görünmür.';

  @override
  String get backToGroups => 'Qruplara qayıt';

  @override
  String leaveConfirm(String name) {
    return '$name qrupundan çıxmaq istəyirsən? Qrupda rolun varsa, o da götürülür.';
  }

  @override
  String get leave => 'Çıx';

  @override
  String leftGroup(String name) {
    return '$name qrupundan çıxdın.';
  }

  @override
  String get suspendedNotice =>
      'Bu qrup platforma komandası tərəfindən dayandırılıb. Dayandırma müddətində qrupu yalnız üzvləri görür.';

  @override
  String founded(String date) {
    return 'Yaradılıb: $date';
  }

  @override
  String joinRequestsPending(int count) {
    return '$count qoşulma istəyi təsdiq gözləyir.';
  }

  @override
  String get review => 'Bax';

  @override
  String get requestSent => 'Qoşulma istəyin göndərildi.';

  @override
  String get youAreMember => 'Üzvsən';

  @override
  String get join => 'Qoşul';

  @override
  String joined(String name) {
    return '$name qrupuna qoşuldun.';
  }

  @override
  String get sendJoinRequest => 'Qoşulma istəyi göndər';

  @override
  String get requestSentShort => 'İstək göndərildi';

  @override
  String get withdrawRequest => 'İstəyi geri götür';

  @override
  String get withdrawConfirm => 'Qoşulma istəyini geri götürmək istəyirsən?';

  @override
  String get undo => 'Geri götür';

  @override
  String get requestWithdrawn => 'Qoşulma istəyin geri götürüldü.';

  @override
  String get decline => 'Rədd et';

  @override
  String get inviteDeclined => 'Dəvət rədd edildi.';

  @override
  String get acceptInvite => 'Dəvəti qəbul et';

  @override
  String followOn(String name) {
    return '$name paylaşımları lentində görünəcək.';
  }

  @override
  String get followOff => 'Qrupu izləməyi dayandırdın.';

  @override
  String get following => 'İzləyirsən';

  @override
  String get follow => 'İzlə';

  @override
  String get managementTeam => 'İdarə heyəti';

  @override
  String allMembers(int count) {
    return 'Bütün üzvlər ($count)';
  }

  @override
  String get groups => 'Qruplar';

  @override
  String get discover => 'Kəşf et';

  @override
  String get myGroups => 'Qruplarım';

  @override
  String get plans => 'Paketlər';

  @override
  String get searchHint => 'Qrup adı və ya ünvanı ilə axtar';

  @override
  String get clearSearch => 'Axtarışı təmizlə';

  @override
  String get all => 'Hamısı';

  @override
  String get noMatch => 'Axtarışına uyğun qrup tapılmadı.';

  @override
  String get clearFilters => 'Filtrləri təmizlə';

  @override
  String get noGroupsYet => 'Hələ heç bir qrup yoxdur. İlk qrupu sən qur.';

  @override
  String get showMore => 'Daha çox göstər';

  @override
  String get notJoinedYet => 'Hələ heç bir qrupa qoşulmamısan.';

  @override
  String get discoverGroups => 'Qrupları kəşf et';

  @override
  String get plansHint =>
      'Paketləri qrup sahibləri alır. Qrupunu qurub paketini seçə bilərsən.';

  @override
  String get yourInvitations => 'Dəvətlərin';

  @override
  String get invitationsHint => 'Bu qruplar səni üzv olmağa dəvət etdi.';

  @override
  String invitedBy(String name) {
    return '$name dəvət etdi';
  }

  @override
  String get linkCopied => 'Keçid kopyalandı.';

  @override
  String inviteShareText(String name) {
    return 'GWAY-də $name qrupuna qoşul:';
  }

  @override
  String get revokeLinkTitle => 'Keçid ləğv edilsin?';

  @override
  String get revokeLinkBody =>
      'Bu keçidlə artıq heç kim qoşula bilməz. Qoşulmuş olanlar üzv qalır.';

  @override
  String get revoke => 'Ləğv et';

  @override
  String get inviteLink => 'Dəvət keçidi';

  @override
  String get inviteLinkHint =>
      'WhatsApp və ya Instagram-da paylaş. Keçidi açan şəxs qoşulma növündən asılı olmayaraq birbaşa üzv olur.';

  @override
  String get createLink => 'Keçid yarat';

  @override
  String validUntil(String date) {
    return '$date tarixinə qədər';
  }

  @override
  String peopleJoined(int count) {
    return '$count nəfər qoşuldu';
  }

  @override
  String peopleJoinedOf(int count, int max) {
    return '$count / $max nəfər qoşuldu';
  }

  @override
  String get newInviteLink => 'Yeni dəvət keçidi';

  @override
  String get validity => 'Etibarlılıq müddəti';

  @override
  String days(int count) {
    return '$count gün';
  }

  @override
  String get howMany => 'Neçə nəfər qoşula bilər?';

  @override
  String get unlimited => 'Limitsiz';

  @override
  String people(int count) {
    return '$count nəfər';
  }

  @override
  String get createAndShare => 'Yarat və paylaş';

  @override
  String get invitation => 'Dəvət';

  @override
  String get linkInvalid =>
      'Bu dəvət keçidi artıq etibarlı deyil. Qrupun idarəçisindən yeni keçid istəyə bilərsən.';

  @override
  String get seeGroup => 'Qrupa bax';

  @override
  String get invitedToGroup => 'Bu qrupa dəvət olundun.';

  @override
  String get joinGroup => 'Qrupa qoşul';

  @override
  String get members => 'Üzvlər';

  @override
  String get requests => 'İstəklər';

  @override
  String get invitations => 'Dəvətlər';

  @override
  String get roles => 'Rollar';

  @override
  String get openCase => 'İntizam işi aç';

  @override
  String get report => 'Şikayət et';

  @override
  String membersVisibility(int shown, int total) {
    return 'Üzv siyahısının hamısını qrupun üzvləri görür. Burada idarə heyəti və qruplarını hamıya açan $shown nəfər var; qrupda cəmi $total üzv var.';
  }

  @override
  String optionsFor(String name) {
    return '$name üçün seçimlər';
  }

  @override
  String get transferOwnership => 'Sahibliyi təhvil ver';

  @override
  String transferBody(String group, String person) {
    return '$group qrupunun sahibliyi $person şəxsinə keçəcək. Sən adi üzv qalacaqsan və bunu geri qaytara bilməzsən.';
  }

  @override
  String get transfer => 'Təhvil ver';

  @override
  String transferred(String name) {
    return 'Sahiblik $name şəxsinə təhvil verildi.';
  }

  @override
  String get hintAdmin =>
      'Qrupu redaktə edir, qoşulma istəklərini və dəvətləri idarə edir.';

  @override
  String get hintDiscipline =>
      'Şikayət işlərinə baxır və sanksiya qərarı verir.';

  @override
  String get hintModerator => 'Məzmunu və şərhləri yoxlayır.';

  @override
  String personJoined(String name) {
    return '$name qrupa qoşuldu.';
  }

  @override
  String get requestDeclined => 'İstək rədd edildi.';

  @override
  String get noPendingRequests => 'Gözləyən qoşulma istəyi yoxdur.';

  @override
  String get refresh => 'Yenilə';

  @override
  String get approve => 'Təsdiqlə';

  @override
  String get inviteSent => 'Dəvət göndərildi.';

  @override
  String get inviteByUsername => 'İstifadəçi adı ilə dəvət et';

  @override
  String get invite => 'Dəvət et';

  @override
  String get noPendingInvites => 'Gözləyən dəvət yoxdur.';

  @override
  String memberCount(int count) {
    return '$count üzv';
  }

  @override
  String get suspended => 'Dayandırılıb';

  @override
  String get groupsSection => 'Qruplar';

  @override
  String get groupsOwnHint =>
      'Qruplarını yalnız eyni qrupdakı üzvlər görür. Ayarlardan hamıya aça bilərsən.';

  @override
  String get groupsOtherHint =>
      'Yalnız ortaq qruplarınız və idarə heyətində olduğu qruplar görünür.';

  @override
  String get noGroupsToShow => 'Göstəriləcək qrup yoxdur.';

  @override
  String get handleTaken => 'Bu qrup ünvanı götürülüb. Başqasını yoxla.';

  @override
  String get groupAddress => 'Qrup ünvanı';

  @override
  String get groupAddressHint =>
      'Qrup səhifənin ünvanı. Sonradan dəyişdirilə bilməz.';

  @override
  String get available => 'Əlçatandır';

  @override
  String get taken => 'Götürülüb';

  @override
  String get notSpecified => 'Göstərilməyib';

  @override
  String get provinceOptional => 'Əyalət (istəyə bağlı)';

  @override
  String get provinceHint => 'Qrup xəritədə bu əyalətdə görünür.';

  @override
  String get chooseCategory => 'Kateqoriya seç.';

  @override
  String get category => 'Kateqoriya';
}
