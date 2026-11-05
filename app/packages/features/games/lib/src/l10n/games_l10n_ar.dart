// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'games_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class GamesL10nAr extends GamesL10n {
  GamesL10nAr([String locale = 'ar']) : super(locale);

  @override
  String get chess => 'الشطرنج';

  @override
  String get bullet => 'رصاصي';

  @override
  String get blitz => 'خاطف';

  @override
  String get rapid => 'سريع';

  @override
  String get white => 'الأبيض';

  @override
  String get black => 'الأسود';

  @override
  String get colorRandom => 'عشوائي';

  @override
  String get endCheckmate => 'كش مات';

  @override
  String get endResign => 'استسلام';

  @override
  String get endTimeout => 'انتهى الوقت';

  @override
  String get endTimeoutDraw => 'انتهى الوقت، والخصم لا يستطيع الكش مات';

  @override
  String get endStalemate => 'تعادل بالجمود';

  @override
  String get endInsufficient => 'قطع غير كافية';

  @override
  String get endFiftyMoves => 'قاعدة الخمسين نقلة';

  @override
  String get endRepetition => 'تكرار ثلاثي';

  @override
  String get endAgreement => 'تعادل بالاتفاق';

  @override
  String get endAborted => 'أُلغيت';

  @override
  String get boardLabel => 'رقعة الشطرنج';

  @override
  String get promoteTo => 'رقِّ البيدق إلى';

  @override
  String get queen => 'الوزير';

  @override
  String get rook => 'الرخ';

  @override
  String get bishop => 'الفيل';

  @override
  String get knight => 'الحصان';

  @override
  String get medalGold => 'ميدالية ذهبية';

  @override
  String get medalSilver => 'ميدالية فضية';

  @override
  String get medalBronze => 'ميدالية برونزية';

  @override
  String get youWon => 'فزت';

  @override
  String get youLost => 'خسرت';

  @override
  String get draw => 'تعادل';

  @override
  String get inProgress => 'جارية';

  @override
  String get whiteWon => 'فاز الأبيض';

  @override
  String get blackWon => 'فاز الأسود';

  @override
  String get rated => 'مصنّفة';

  @override
  String get casual => 'ودية';

  @override
  String get ratedHint => 'تغيّر النتيجة تصنيف Elo الخاص بك.';

  @override
  String get flipBoard => 'اقلب الرقعة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get resign => 'استسلم';

  @override
  String get resignTitle => 'الاستسلام في المباراة؟';

  @override
  String get resignBody => 'سيفوز خصمك، وفي المباراة المصنّفة ينخفض تصنيفك.';

  @override
  String get abort => 'إلغاء المباراة';

  @override
  String get offerDraw => 'تعادل؟';

  @override
  String get drawOffered => 'عُرض';

  @override
  String get drawOfferReceived => 'خصمك يعرض التعادل.';

  @override
  String get accept => 'قبول';

  @override
  String get decline => 'رفض';

  @override
  String get rematch => 'مباراة ثأرية';

  @override
  String get rematchSent => 'أُرسل طلب المباراة الثأرية.';

  @override
  String get newGame => 'مباراة جديدة';

  @override
  String newRating(String category, int rating) {
    return 'تصنيفك في $category: $rating';
  }

  @override
  String get deletedPlayer => 'حساب محذوف';

  @override
  String get firstMove => 'النقلة الأولى: 30 ث';

  @override
  String get noMovesYet => 'لا نقلات بعد. يبدأ الأبيض.';

  @override
  String get watching => 'أنت تشاهد';

  @override
  String get quickGame => 'مباراة سريعة';

  @override
  String get quickGameHint => 'اختر الوقت والعب مع شخص قريب من تصنيفك.';

  @override
  String get searching => 'جارٍ البحث عن خصم…';

  @override
  String waitedSeconds(int count) {
    return 'تنتظر منذ $count ثانية';
  }

  @override
  String get chessProfile => 'ملف الشطرنج';

  @override
  String get recentGames => 'آخر المباريات';

  @override
  String get noGamesMine => 'لا مباريات بعد. العب أول مباراة.';

  @override
  String get noGamesTheirs => 'لا مباريات بعد. ادعُه إلى أول مباراة.';

  @override
  String get playNow => 'العب الآن';

  @override
  String get challenge => 'تحدَّ';

  @override
  String get noFlag => 'لم يُختر علم';

  @override
  String get chooseFlag => 'اختر علمك';

  @override
  String get chooseFlagHint => 'يظهر بجانب اسمك في الترتيب.';

  @override
  String get searchCountry => 'ابحث عن بلد';

  @override
  String get flagSaved => 'حُفظ العلم.';

  @override
  String get pickFlagPrompt => 'اختر العلم الذي يظهر معك في الترتيب.';

  @override
  String get suspendedNotice => 'الشطرنج مغلق لهذا الشخص حاليًا.';

  @override
  String get notPlayed => 'لم يُلعب';

  @override
  String gamesCount(int count) {
    return '$count مباراة';
  }

  @override
  String rankShort(int rank) {
    return 'المرتبة $rank';
  }

  @override
  String get leaderboard => 'الترتيب';

  @override
  String leaderboardEmpty(int count) {
    return 'العب $count مباريات مصنّفة في هذه الفئة لتدخل الترتيب.';
  }

  @override
  String record(int wins, int draws, int losses) {
    return '$wins فوز · $draws تعادل · $losses خسارة';
  }

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get invitations => 'الدعوات';

  @override
  String invitesYou(String what) {
    return 'يدعوك إلى مباراة: $what';
  }

  @override
  String wantsRematch(String what) {
    return 'يريد مباراة ثأرية: $what';
  }

  @override
  String waitingFor(String what) {
    return 'بانتظار الرد: $what';
  }

  @override
  String get withdraw => 'سحب';

  @override
  String get gameInProgress => 'لديك مباراة جارية';

  @override
  String get resume => 'متابعة';

  @override
  String get challengeFriend => 'تحدَّ صديقًا';

  @override
  String get challengeSent => 'أُرسلت الدعوة. تبدأ المباراة عند قبولها.';

  @override
  String get challengeTitle => 'ادعُ إلى مباراة';

  @override
  String get changePerson => 'غيّر الشخص';

  @override
  String get searchPerson => 'اسم المستخدم أو الاسم';

  @override
  String get timeControl => 'الوقت';

  @override
  String get yourColor => 'لونك';

  @override
  String get sendChallenge => 'أرسل الدعوة';

  @override
  String get teamMatch => 'مواجهة فرق';

  @override
  String get teamMatches => 'مواجهات الفرق';

  @override
  String get teamMatchesHint =>
      'مواجهات الشطرنج لمجموعاتك؛ تغيّر النتيجة تصنيف المجموعة.';

  @override
  String get noTeamMatches =>
      'لا مواجهات فرق بعد. ادعُ مجموعة أخرى باسم مجموعتك.';

  @override
  String get newTeamMatch => 'نظّم مواجهة';

  @override
  String get newTeamMatchHint =>
      'عندما تقبل المجموعة الأخرى، ترتّب المجموعتان لاعبيهما.';

  @override
  String get yourGroup => 'مجموعتك';

  @override
  String get opponentGroup => 'المجموعة المنافسة';

  @override
  String get searchGroup => 'اسم المجموعة أو معرّفها';

  @override
  String get startsAt => 'البدء';

  @override
  String get sendTeamInvite => 'ادعُ المجموعة';

  @override
  String get boards => 'الرقع';

  @override
  String get boardsShort => 'رقع';

  @override
  String boardsCount(int count) {
    return '$count رقعة';
  }

  @override
  String groupElo(int rating) {
    return 'تصنيف المجموعة $rating';
  }

  @override
  String get versus => 'ضد';

  @override
  String get versusShort => '–';

  @override
  String get teamInvited => 'بانتظار الرد';

  @override
  String get teamAccepted => 'مقبولة';

  @override
  String get teamDeclined => 'مرفوضة';

  @override
  String get teamCanceled => 'أُلغيت';

  @override
  String get teamLive => 'جارية';

  @override
  String get teamFinished => 'انتهت';

  @override
  String teamInviteReceived(String group) {
    return 'تدعو $group مجموعتكم إلى مواجهة فرق.';
  }

  @override
  String get teamAcceptedDone => 'قُبلت المواجهة. رتّبوا لاعبيكم الآن.';

  @override
  String get teamDeclinedDone => 'رُفضت الدعوة.';

  @override
  String get teamCanceledDone => 'أُلغيت المواجهة.';

  @override
  String get callOff => 'ألغِ المواجهة';

  @override
  String get lineupHint => 'تُحسب الرقعة الفارغة عند البدء نقطة للطرف الآخر.';

  @override
  String get lineupSheetHint =>
      'اضغط على الأعضاء لوضعهم بالترتيب؛ الرقعة 1 لأقوى لاعب.';

  @override
  String editLineup(String group) {
    return 'تشكيلة $group';
  }

  @override
  String get saveLineup => 'احفظ التشكيلة';

  @override
  String get emptyBoard => 'فارغة';

  @override
  String ratingGames(int rating, int games) {
    return 'Elo $rating · $games مباراة';
  }

  @override
  String get groupsTab => 'المجموعات';

  @override
  String get groupLeaderboardEmpty =>
      'لم تلعب أي مجموعة مواجهة فرق بعد. كن الأول.';

  @override
  String get backToChess => 'العودة إلى الشطرنج';
}
