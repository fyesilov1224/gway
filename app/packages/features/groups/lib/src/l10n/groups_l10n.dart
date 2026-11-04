import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'groups_l10n_ar.dart';
import 'groups_l10n_az.dart';
import 'groups_l10n_de.dart';
import 'groups_l10n_en.dart';
import 'groups_l10n_es.dart';
import 'groups_l10n_fr.dart';
import 'groups_l10n_it.dart';
import 'groups_l10n_nl.dart';
import 'groups_l10n_pt.dart';
import 'groups_l10n_ru.dart';
import 'groups_l10n_tr.dart';
import 'groups_l10n_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of GroupsL10n
/// returned by `GroupsL10n.of(context)`.
///
/// Applications need to include `GroupsL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/groups_l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: GroupsL10n.localizationsDelegates,
///   supportedLocales: GroupsL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the GroupsL10n.supportedLocales
/// property.
abstract class GroupsL10n {
  GroupsL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static GroupsL10n of(BuildContext context) {
    return Localizations.of<GroupsL10n>(context, GroupsL10n)!;
  }

  static const LocalizationsDelegate<GroupsL10n> delegate =
      _GroupsL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('az'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('nl'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr'),
    Locale('uk'),
  ];

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu dosya türü desteklenmiyor. JPEG, PNG veya WebP seç.'**
  String get unsupportedImage;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Serbest katılım'**
  String get joinOpen;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Herkes doğrudan katılabilir.'**
  String get joinOpenHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İstekle katılım'**
  String get joinRequest;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Katılım istekleri yöneticiler tarafından onaylanır.'**
  String get joinRequestHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Davetle katılım'**
  String get joinInvite;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca davet edilen kişiler katılabilir.'**
  String get joinInviteHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup Sahibi'**
  String get roleOwner;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yönetici'**
  String get roleAdmin;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Disiplin Kurulu'**
  String get roleDiscipline;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Moderatör'**
  String get roleModerator;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Üye'**
  String get roleMember;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup adresi en az 3 karakter olmalı.'**
  String get handleMin;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca küçük harf, rakam, alt çizgi ve nokta kullanabilirsin.'**
  String get handleChars;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Nokta ile başlayamaz, bitemez ve art arda kullanılamaz.'**
  String get handleDots;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup adı en az 3 karakter olmalı.'**
  String get nameMin;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup adı en fazla {max} karakter olabilir.'**
  String nameMax(int max);

  ///
  ///
  /// In tr, this message translates to:
  /// **'https:// ile başlayan bir adres gir.'**
  String get httpsOnly;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup oluştur'**
  String get createGroup;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup bilgileri'**
  String get groupInfo;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Logo, kapak, kurallar ve bağlantıları grubu oluşturduktan sonra ekleyebilirsin.'**
  String get groupInfoHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup adı'**
  String get groupName;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tanıtım'**
  String get about;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grubunuz ne yapar, kimler katılabilir?'**
  String get aboutHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Katılım'**
  String get joining;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bunu daha sonra değiştirebilirsin.'**
  String get changeLater;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grubu oluştur'**
  String get createTheGroup;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grubu düzenle'**
  String get editGroup;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu grubu düzenleme yetkin yok.'**
  String get noEditPermission;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gruba dön'**
  String get backToGroup;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Logo ve kapak'**
  String get logoAndCover;

  ///
  ///
  /// In tr, this message translates to:
  /// **'JPEG, PNG veya WebP · en fazla 5 MB'**
  String get imageHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Logo'**
  String get logo;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kapak'**
  String get cover;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup adresi: @{handle}'**
  String groupHandle(String handle);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kurallar'**
  String get rules;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Üyelerden beklentilerin, her satıra bir kural.'**
  String get rulesHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bağlantılar'**
  String get links;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Web sitesi, sosyal medya hesapları. En fazla {max} tane.'**
  String linksHint(int max);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bir etiket yaz.'**
  String get enterLabel;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Etiket'**
  String get label;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Adres'**
  String get address;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bağlantıyı kaldır'**
  String get removeLink;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı ekle'**
  String get addLink;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get cancel;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Değişiklikleri kaydet'**
  String get saveChanges;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grubu sil'**
  String get deleteGroup;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup, üyelikler, roller, istekler ve davetler kalıcı olarak silinir. Paketin kalan süresi iade edilmez.'**
  String get deleteGroupBody;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} grubunu sil'**
  String deleteGroupNamed(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{label} değiştir'**
  String changeImage(String label);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{label} ekle'**
  String addImage(String label);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kaldır'**
  String get remove;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grubu kalıcı olarak sil'**
  String get deleteForever;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem geri alınamaz. Onaylamak için grup adresini yaz: {handle}'**
  String deleteConfirm(String handle);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup'**
  String get group;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get share;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} grubuna GWAY\'de göz at:'**
  String shareText(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Diğer seçenekler'**
  String get moreOptions;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gruptan ayrıl'**
  String get leaveGroup;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu grup bulunamadı ya da artık görünür değil.'**
  String get groupNotFound;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gruplara dön'**
  String get backToGroups;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} grubundan ayrılmak istiyor musun? Grupta bir rolün varsa o da kaldırılır.'**
  String leaveConfirm(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ayrıl'**
  String get leave;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} grubundan ayrıldın.'**
  String leftGroup(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu grup platform ekibi tarafından askıya alındı. Askı sürerken grup yalnızca üyelerine görünür.'**
  String get suspendedNotice;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kuruluş: {date}'**
  String founded(String date);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} katılım isteği onay bekliyor.'**
  String joinRequestsPending(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'İncele'**
  String get review;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Katılım isteğin gönderildi.'**
  String get requestSent;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Üyesin'**
  String get youAreMember;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Katıl'**
  String get join;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} grubuna katıldın.'**
  String joined(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Katılma isteği gönder'**
  String get sendJoinRequest;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İstek gönderildi'**
  String get requestSentShort;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İsteği geri al'**
  String get withdrawRequest;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Katılım isteğini geri almak istiyor musun?'**
  String get withdrawConfirm;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Geri al'**
  String get undo;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Katılım isteğin geri alındı.'**
  String get requestWithdrawn;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Reddet'**
  String get decline;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Davet reddedildi.'**
  String get inviteDeclined;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Daveti kabul et'**
  String get acceptInvite;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} gönderileri akışında görünecek.'**
  String followOn(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grubu takip etmeyi bıraktın.'**
  String get followOff;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Takiptesin'**
  String get following;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Takip et'**
  String get follow;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yönetim ekibi'**
  String get managementTeam;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tüm üyeler ({count})'**
  String allMembers(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gruplar'**
  String get groups;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Keşfet'**
  String get discover;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gruplarım'**
  String get myGroups;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Paketler'**
  String get plans;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup adı veya adresi ile ara'**
  String get searchHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Aramayı temizle'**
  String get clearSearch;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get all;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Aramana uygun grup bulunamadı.'**
  String get noMatch;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Filtreleri temizle'**
  String get clearFilters;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz hiç grup yok. İlk grubu sen kur.'**
  String get noGroupsYet;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Daha fazla göster'**
  String get showMore;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz bir gruba katılmadın.'**
  String get notJoinedYet;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grupları keşfet'**
  String get discoverGroups;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Paketleri grup sahipleri alır. Grubunu kurup paketini seçebilirsin.'**
  String get plansHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Davetlerin'**
  String get yourInvitations;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu gruplar seni üye olmaya davet etti.'**
  String get invitationsHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} davet etti'**
  String invitedBy(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı kopyalandı.'**
  String get linkCopied;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} grubuna GWAY\'de katıl:'**
  String inviteShareText(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı iptal edilsin mi?'**
  String get revokeLinkTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu bağlantıyla artık kimse katılamaz. Katılmış olanlar üye olarak kalır.'**
  String get revokeLinkBody;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İptal et'**
  String get revoke;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Davet bağlantısı'**
  String get inviteLink;

  ///
  ///
  /// In tr, this message translates to:
  /// **'WhatsApp ya da Instagram\'da paylaş. Bağlantıyı açan kişi katılım tipine bakılmadan doğrudan üye olur.'**
  String get inviteLinkHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı oluştur'**
  String get createLink;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{date} tarihine kadar'**
  String validUntil(String date);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} kişi katıldı'**
  String peopleJoined(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} / {max} kişi katıldı'**
  String peopleJoinedOf(int count, int max);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yeni davet bağlantısı'**
  String get newInviteLink;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Geçerlilik süresi'**
  String get validity;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} gün'**
  String days(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kaç kişi katılabilir?'**
  String get howMany;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sınırsız'**
  String get unlimited;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} kişi'**
  String people(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Oluştur ve paylaş'**
  String get createAndShare;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Davet'**
  String get invitation;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu davet bağlantısı artık geçerli değil. Grubun yöneticisinden yeni bir bağlantı isteyebilirsin.'**
  String get linkInvalid;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grubu gör'**
  String get seeGroup;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu gruba davet edildin.'**
  String get invitedToGroup;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gruba katıl'**
  String get joinGroup;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Üyeler'**
  String get members;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İstekler'**
  String get requests;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Davetler'**
  String get invitations;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Roller'**
  String get roles;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Disiplin dosyası aç'**
  String get openCase;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şikayet et'**
  String get report;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Üye listesinin tamamını grubun üyeleri görür. Burada yönetim ekibi ve gruplarını herkese açan {shown} kişi var; grupta toplam {total} üye var.'**
  String membersVisibility(int shown, int total);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} için seçenekler'**
  String optionsFor(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sahipliği devret'**
  String get transferOwnership;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{group} grubunun sahipliği {person} kişisine geçecek. Sen normal üye olarak kalacaksın ve bu işlemi geri alamazsın.'**
  String transferBody(String group, String person);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Devret'**
  String get transfer;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sahiplik {name} kişisine devredildi.'**
  String transferred(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grubu düzenler, katılım isteklerini ve davetleri yönetir.'**
  String get hintAdmin;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şikayet dosyalarını inceler ve yaptırım kararı verir.'**
  String get hintDiscipline;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İçerikleri ve yorumları denetler.'**
  String get hintModerator;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} gruba katıldı.'**
  String personJoined(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'İstek reddedildi.'**
  String get requestDeclined;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen katılım isteği yok.'**
  String get noPendingRequests;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yenile'**
  String get refresh;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Onayla'**
  String get approve;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Davet gönderildi.'**
  String get inviteSent;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adıyla davet et'**
  String get inviteByUsername;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Davet et'**
  String get invite;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen davet yok.'**
  String get noPendingInvites;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} üye'**
  String memberCount(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Askıda'**
  String get suspended;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gruplar'**
  String get groupsSection;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gruplarını yalnızca aynı gruptaki üyeler görür. Ayarlar\'dan herkese açabilirsin.'**
  String get groupsOwnHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca ortak grupların ve yönetim ekibinde olduğu gruplar görünür.'**
  String get groupsOtherHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gösterilecek grup yok.'**
  String get noGroupsToShow;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu grup adresi alınmış. Başka bir tane dene.'**
  String get handleTaken;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup adresi'**
  String get groupAddress;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup sayfanın adresi. Sonradan değiştirilemez.'**
  String get groupAddressHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kullanılabilir'**
  String get available;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Alınmış'**
  String get taken;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Belirtilmedi'**
  String get notSpecified;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İl (isteğe bağlı)'**
  String get provinceOptional;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup haritada bu ilde görünür.'**
  String get provinceHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bir kategori seç.'**
  String get chooseCategory;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kategori'**
  String get category;
}

class _GroupsL10nDelegate extends LocalizationsDelegate<GroupsL10n> {
  const _GroupsL10nDelegate();

  @override
  Future<GroupsL10n> load(Locale locale) {
    return SynchronousFuture<GroupsL10n>(lookupGroupsL10n(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'az',
    'de',
    'en',
    'es',
    'fr',
    'it',
    'nl',
    'pt',
    'ru',
    'tr',
    'uk',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_GroupsL10nDelegate old) => false;
}

GroupsL10n lookupGroupsL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return GroupsL10nAr();
    case 'az':
      return GroupsL10nAz();
    case 'de':
      return GroupsL10nDe();
    case 'en':
      return GroupsL10nEn();
    case 'es':
      return GroupsL10nEs();
    case 'fr':
      return GroupsL10nFr();
    case 'it':
      return GroupsL10nIt();
    case 'nl':
      return GroupsL10nNl();
    case 'pt':
      return GroupsL10nPt();
    case 'ru':
      return GroupsL10nRu();
    case 'tr':
      return GroupsL10nTr();
    case 'uk':
      return GroupsL10nUk();
  }

  throw FlutterError(
    'GroupsL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
