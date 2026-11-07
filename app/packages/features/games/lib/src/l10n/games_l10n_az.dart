// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'games_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Azerbaijani (`az`).
class GamesL10nAz extends GamesL10n {
  GamesL10nAz([String locale = 'az']) : super(locale);

  @override
  String get chess => 'Şahmat';

  @override
  String get bullet => 'Bullet';

  @override
  String get blitz => 'Blits';

  @override
  String get rapid => 'Rapid';

  @override
  String get white => 'Ağ';

  @override
  String get black => 'Qara';

  @override
  String get colorRandom => 'Təsadüfi';

  @override
  String get endCheckmate => 'Mat';

  @override
  String get endResign => 'Təslim';

  @override
  String get endTimeout => 'Vaxt bitdi';

  @override
  String get endTimeoutDraw => 'Vaxt bitdi, rəqibin mat edəcək fiquru yoxdur';

  @override
  String get endStalemate => 'Pat';

  @override
  String get endInsufficient => 'Kifayət etməyən material';

  @override
  String get endFiftyMoves => '50 gediş qaydası';

  @override
  String get endRepetition => 'Üç dəfə təkrar';

  @override
  String get endAgreement => 'Razılaşma ilə heç-heçə';

  @override
  String get endAborted => 'Ləğv edildi';

  @override
  String get boardLabel => 'Şahmat taxtası';

  @override
  String get promoteTo => 'Piyada nəyə çevrilsin?';

  @override
  String get queen => 'Vəzir';

  @override
  String get rook => 'Top';

  @override
  String get bishop => 'Fil';

  @override
  String get knight => 'At';

  @override
  String get medalGold => 'Qızıl medal';

  @override
  String get medalSilver => 'Gümüş medal';

  @override
  String get medalBronze => 'Bürünc medal';

  @override
  String get youWon => 'Qalib gəldin';

  @override
  String get youLost => 'Uduzdun';

  @override
  String get draw => 'Heç-heçə';

  @override
  String get inProgress => 'Davam edir';

  @override
  String get whiteWon => 'Ağlar qalib gəldi';

  @override
  String get blackWon => 'Qaralar qalib gəldi';

  @override
  String get rated => 'Reytinqli';

  @override
  String get casual => 'Reytinqsiz';

  @override
  String get ratedHint => 'Nəticə Elo reytinqini dəyişir.';

  @override
  String get flipBoard => 'Taxtanı çevir';

  @override
  String get cancel => 'İmtina';

  @override
  String get resign => 'Təslim ol';

  @override
  String get resignTitle => 'Oyundan təslim olursan?';

  @override
  String get resignBody =>
      'Rəqibin qalib gəlir; reytinqli oyunda Elo-n azalır.';

  @override
  String get abort => 'Ləğv et';

  @override
  String get offerDraw => 'Heç-heçə?';

  @override
  String get drawOffered => 'Təklif edildi';

  @override
  String get drawOfferReceived => 'Rəqibin heç-heçə təklif edir.';

  @override
  String get accept => 'Qəbul et';

  @override
  String get decline => 'Rədd et';

  @override
  String get rematch => 'Revanş';

  @override
  String get rematchSent => 'Revanş istəyi göndərildi.';

  @override
  String get newGame => 'Yeni oyun';

  @override
  String newRating(String category, int rating) {
    return '$category reytinqin: $rating';
  }

  @override
  String get deletedPlayer => 'Silinmiş hesab';

  @override
  String get firstMove => 'İlk gediş: 30 san';

  @override
  String get noMovesYet => 'Hələ gediş yoxdur. Ağlar başlayır.';

  @override
  String get watching => 'İzləyirsən';

  @override
  String get quickGame => 'Sürətli oyun';

  @override
  String get quickGameHint => 'Vaxtı seç, reytinqinə yaxın biri ilə eşləş.';

  @override
  String get searching => 'Rəqib axtarılır…';

  @override
  String waitedSeconds(int count) {
    return '$count saniyədir gözləyirsən';
  }

  @override
  String get chessProfile => 'Şahmat profili';

  @override
  String get recentGames => 'Son oyunlar';

  @override
  String get noGamesMine => 'Hələ oyunun yoxdur. İlk oyununu oyna.';

  @override
  String get noGamesTheirs => 'Hələ oyunu yoxdur. İlk oyununa sən dəvət et.';

  @override
  String get playNow => 'İndi oyna';

  @override
  String get challenge => 'Dəvət et';

  @override
  String get noFlag => 'Bayraq seçilməyib';

  @override
  String get chooseFlag => 'Bayrağını seç';

  @override
  String get chooseFlagHint => 'Sıralamada adının yanında görünür.';

  @override
  String get searchCountry => 'Ölkə axtar';

  @override
  String get flagSaved => 'Bayrağın yadda saxlanıldı.';

  @override
  String get pickFlagPrompt => 'Sıralamada görünəcək bayrağını seç.';

  @override
  String get suspendedNotice => 'Bu şəxs üçün şahmat hazırda bağlıdır.';

  @override
  String get notPlayed => 'Oynanmayıb';

  @override
  String gamesCount(int count) {
    return '$count oyun';
  }

  @override
  String rankShort(int rank) {
    return '$rank-ci yerdə';
  }

  @override
  String get leaderboard => 'Sıralama';

  @override
  String record(int wins, int draws, int losses) {
    return '${wins}Q · ${draws}H · ${losses}M';
  }

  @override
  String get seeAll => 'Hamısına bax';

  @override
  String get invitations => 'Dəvətlər';

  @override
  String invitesYou(String what) {
    return 'Səni oyuna dəvət edir: $what';
  }

  @override
  String wantsRematch(String what) {
    return 'Revanş istəyir: $what';
  }

  @override
  String waitingFor(String what) {
    return 'Cavab gözlənilir: $what';
  }

  @override
  String get withdraw => 'Geri çək';

  @override
  String get gameInProgress => 'Davam edən oyunun var';

  @override
  String get resume => 'Davam et';

  @override
  String get challengeFriend => 'Dostunu dəvət et';

  @override
  String get challengeSent => 'Dəvət göndərildi. Qəbul edilincə oyun başlayır.';

  @override
  String get challengeTitle => 'Oyuna dəvət et';

  @override
  String get changePerson => 'Şəxsi dəyiş';

  @override
  String get searchPerson => 'İstifadəçi adı və ya ad';

  @override
  String get timeControl => 'Vaxt';

  @override
  String get yourColor => 'Rəngin';

  @override
  String get sendChallenge => 'Dəvəti göndər';

  @override
  String get teamMatch => 'Komanda matçı';

  @override
  String get teamMatches => 'Komanda matçları';

  @override
  String get teamMatchesHint =>
      'Qruplarının şahmat matçları; nəticə qrupun Elo-sunu dəyişir.';

  @override
  String get noTeamMatches =>
      'Hələ komanda matçı yoxdur. Qrupun adına başqa qrupu dəvət et.';

  @override
  String get newTeamMatch => 'Komanda matçı təşkil et';

  @override
  String get newTeamMatchHint =>
      'Qarşı qrupun yöneticisi qəbul edəndə iki qrup da oyunçularını düzür.';

  @override
  String get yourGroup => 'Qrupun';

  @override
  String get opponentGroup => 'Rəqib qrup';

  @override
  String get searchGroup => 'Qrup adı və ya istifadəçi adı';

  @override
  String get startsAt => 'Başlanğıc';

  @override
  String get sendTeamInvite => 'Qrupu dəvət et';

  @override
  String get boards => 'Taxtalar';

  @override
  String get boardsShort => 'taxta';

  @override
  String boardsCount(int count) {
    return '$count taxta';
  }

  @override
  String groupElo(int rating) {
    return 'Qrup Elo $rating';
  }

  @override
  String get versus => 'VS';

  @override
  String get versusShort => '–';

  @override
  String get teamInvited => 'Cavab gözlənilir';

  @override
  String get teamAccepted => 'Qəbul edildi';

  @override
  String get teamDeclined => 'Rədd edildi';

  @override
  String get teamCanceled => 'Ləğv edildi';

  @override
  String get teamLive => 'Oynanılır';

  @override
  String get teamFinished => 'Bitdi';

  @override
  String teamInviteReceived(String group) {
    return '$group qrupunuzu komanda matçına dəvət edir.';
  }

  @override
  String get teamAcceptedDone =>
      'Matç qəbul edildi. İndi oyunçularınızı düzün.';

  @override
  String get teamDeclinedDone => 'Dəvət rədd edildi.';

  @override
  String get teamCanceledDone => 'Matç ləğv edildi.';

  @override
  String get callOff => 'Matçı ləğv et';

  @override
  String get lineupHint =>
      'Başlanğıcda boş qalan taxta rəqibə xal kimi yazılır.';

  @override
  String get lineupSheetHint =>
      'Üzvlərə toxunaraq onları sıra ilə taxtalara yerləşdir; 1-ci taxta ən güclü oyunçunundur.';

  @override
  String editLineup(String group) {
    return '$group düzülüşü';
  }

  @override
  String get saveLineup => 'Düzülüşü yadda saxla';

  @override
  String get emptyBoard => 'Boş';

  @override
  String ratingGames(int rating, int games) {
    return 'Elo $rating · $games oyun';
  }

  @override
  String get groupsTab => 'Qruplar';

  @override
  String get groupLeaderboardEmpty =>
      'Hələ heç bir qrup komanda matçı oynamayıb. İlk sənin qrupun olsun.';

  @override
  String get backToChess => 'Şahmata qayıt';

  @override
  String get arena => 'Turnir';

  @override
  String get tournaments => 'Turnirlər';

  @override
  String get tournamentsHint =>
      'Həftəlik və aylıq Arena turnirləri; ilk üçlük medal alır.';

  @override
  String get weeklyArena => 'Həftəlik Arena';

  @override
  String get monthlyArena => 'Aylıq Arena';

  @override
  String get arenaRules =>
      'Arena: vaxt bitənə qədər istədiyin qədər oyna. Qələbə 2, heç-heçə 1 xal; ardıcıl iki qələbədən sonra seriya bitənə qədər xallar ikiqat olur. Bitmədən başlayan oyunlar sayılır.';

  @override
  String get arenaLiveNow => 'İndi oynanılır';

  @override
  String get arenaUpcoming => 'Yaxınlaşan';

  @override
  String get arenaFinished => 'Bitənlər';

  @override
  String get registered => 'Qeydiyyatdasan';

  @override
  String get arenaRegister => 'Qeydiyyatdan keç';

  @override
  String get arenaRegistered =>
      'Qeydiyyatdasan. Turnir başlayanda bildiriş alacaqsan; açan kimi cütləşəcəksən.';

  @override
  String get arenaJoin => 'Qoşul';

  @override
  String get arenaResume => 'Oynamağa davam et';

  @override
  String get arenaPause => 'Fasilə ver';

  @override
  String get arenaWaiting =>
      'Rəqib gözlənilir; xalı yaxın biri boşalanda oyun özü açılacaq.';

  @override
  String get backToGame => 'Oyuna qayıt';

  @override
  String get backToArena => 'Turnirə qayıt';

  @override
  String get backToTeamMatch => 'Komanda matçına qayıt';

  @override
  String arenaStartsIn(String time) {
    return '$time sonra başlayır';
  }

  @override
  String arenaEndsIn(String time) {
    return 'Bitməyə $time';
  }

  @override
  String get arenaLastGames => 'Vaxt bitdi; son oyunlar bitir';

  @override
  String arenaFinishedAt(String time) {
    return 'Bitdi · $time';
  }

  @override
  String hoursMinutes(int hours, int minutes) {
    return '$hours saat $minutes dəq';
  }

  @override
  String minutesLong(int count) {
    return '$count dəqiqə';
  }

  @override
  String playersCount(int count) {
    return '$count oyunçu';
  }

  @override
  String myArenaScore(int points, int games) {
    return '$points xal · $games oyun';
  }

  @override
  String get onFire => 'Seriyada: növbəti nəticə ikiqat xal';

  @override
  String get standings => 'Turnir cədvəli';

  @override
  String get arenaEmpty => 'Hələ qoşulan yoxdur. İlk sən qoşul.';

  @override
  String performance(int value) {
    return 'Performans $value';
  }

  @override
  String get playingNow => 'oynayır';

  @override
  String get arenaMedals => 'Turnir medalları';

  @override
  String medalsSummary(int gold, int silver, int bronze) {
    return 'Medallar: $gold qızıl, $silver gümüş, $bronze bürünc';
  }

  @override
  String get firstMoveTeam => 'İlk gediş: 5 dəq';

  @override
  String get games => 'Oyunlar';

  @override
  String get gamesIntro =>
      'İcmanla oyna: sürətli oyunlar, turnirlər və qruplararası matçlar.';

  @override
  String get chessCardText =>
      'Elo reytinqi, həftəlik və aylıq turnirlər, qruplararası komanda matçları və medallar.';

  @override
  String get playChess => 'Şahmat oyna';

  @override
  String blitzRating(int rating) {
    return 'Blits $rating';
  }

  @override
  String nextArena(String time) {
    return 'Növbəti turnir: $time';
  }

  @override
  String invitesWaiting(int count) {
    return '$count dəvət gözləyir';
  }

  @override
  String get playOnline => 'Onlayn oyna';

  @override
  String findOpponent(String tc) {
    return 'Rəqib tap · $tc';
  }

  @override
  String get challengeFriendHint => 'Vaxtı və rəngi sən seç';

  @override
  String get leaderboardHint => 'Elo sıralaması və medallar';

  @override
  String openTeamMatches(int count) {
    return '$count açıq matç';
  }

  @override
  String get appearance => 'Taxta və fiqurlar';

  @override
  String get boardTheme => 'Taxta';

  @override
  String get pieceSet => 'Fiqurlar';

  @override
  String get boardWood => 'Taxta';

  @override
  String get boardGreen => 'Yaşıl';

  @override
  String get boardBlue => 'Mavi';

  @override
  String get boardSlate => 'Boz';

  @override
  String get boardLilac => 'GWAY bənövşəyi';

  @override
  String get piecesClassic => 'Klassik';

  @override
  String get piecesCeltic => 'Kelt';

  @override
  String get piecesSpatial => 'Kosmos';

  @override
  String get piecesFantasy => 'Fantastik';

  @override
  String get piecesModern => 'Müasir';

  @override
  String get piecesWarm => 'İsti';

  @override
  String get firstPosition => 'Başlanğıc';

  @override
  String get previousMove => 'Əvvəlki gediş';

  @override
  String get nextMove => 'Növbəti gediş';

  @override
  String get lastPosition => 'Son vəziyyət';

  @override
  String get backToLive => 'Canlıya qayıt';

  @override
  String pointsShort(int points) {
    return '$points xal';
  }

  @override
  String mindColorWord(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'red_m': 'qırmızı',
      'red_f': 'qırmızı',
      'red_n': 'qırmızı',
      'blue_m': 'mavi',
      'blue_f': 'mavi',
      'blue_n': 'mavi',
      'green_m': 'yaşıl',
      'green_f': 'yaşıl',
      'green_n': 'yaşıl',
      'yellow_m': 'sarı',
      'yellow_f': 'sarı',
      'yellow_n': 'sarı',
      'purple_m': 'bənövşəyi',
      'purple_f': 'bənövşəyi',
      'purple_n': 'bənövşəyi',
      'orange_m': 'narıncı',
      'orange_f': 'narıncı',
      'orange_n': 'narıncı',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String mindPatternWord(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'solid_m': 'düz',
      'solid_f': 'düz',
      'solid_n': 'düz',
      'striped_m': 'zolaqlı',
      'striped_f': 'zolaqlı',
      'striped_n': 'zolaqlı',
      'dotted_m': 'xallı',
      'dotted_f': 'xallı',
      'dotted_n': 'xallı',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String mindShapeWord(String shape) {
    String _temp0 = intl.Intl.selectLogic(shape, {
      'circle': 'dairə',
      'square': 'kvadrat',
      'triangle': 'üçbucaq',
      'star': 'ulduz',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String mindShapeGender(String shape) {
    String _temp0 = intl.Intl.selectLogic(shape, {
      'circle': 'm',
      'square': 'm',
      'triangle': 'm',
      'star': 'm',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String mindFigure(String color, String pattern, String shape) {
    return '$color $pattern $shape';
  }

  @override
  String get mindDuel => 'Zehin Dueli';

  @override
  String get mindCardText =>
      'Riyaziyyat, diqqət, yaddaş və refleks suallarında canlı duel. Elo reytinqi, sıralama və medallar.';

  @override
  String get mindPlay => 'Duelə başla';

  @override
  String mindBestRating(int rating, int length) {
    return 'Elo $rating · $length sual';
  }

  @override
  String mindQuestions(int count) {
    return '$count sual';
  }

  @override
  String get mindHowMany => 'Neçə sual?';

  @override
  String mindRatingAt(int count) {
    return '$count sualda reytinqin';
  }

  @override
  String get mindFindOpponent => 'Rəqib tap';

  @override
  String get mindSuspended => 'Hazırda oyun oynaya bilməzsən.';

  @override
  String get mindActive => 'Davam edən duelin var';

  @override
  String get mindProfile => 'Duel profili';

  @override
  String get mindHowTo => 'Necə oynanılır';

  @override
  String get mindRecent => 'Son duellər';

  @override
  String get mindNoMatchesMine => 'Hələ duelin yoxdur. İlk rəqibini tap.';

  @override
  String get mindNoMatchesTheirs => 'Hələ dueli yoxdur. İlk sən dəvət et.';

  @override
  String mindLeaderboardEmpty(int count) {
    return 'Sıralamaya düşmək üçün bu sual sayında $count reytinqli duel oyna.';
  }

  @override
  String get mindChallengeTitle => 'Duelə dəvət et';

  @override
  String get mindChallengeSent =>
      'Dəvət göndərildi. Qəbul edəndə duel başlayır.';

  @override
  String get mindKindMath => 'Riyaziyyat';

  @override
  String get mindKindAttention => 'Diqqət';

  @override
  String get mindKindMemory => 'Yaddaş';

  @override
  String get mindKindReflex => 'Refleks';

  @override
  String get mindKindMathHint =>
      'Dörd əməl, əməl ardıcıllığı ilə. Doğru cavabı seç.';

  @override
  String get mindKindAttentionHint =>
      'Yazının rənginə yox, təsvir etdiyi fiqura bax.';

  @override
  String get mindKindMemoryHint =>
      'Rəngli hərf və rəqəmləri ardıcıllıqla və rəngləri ilə yadda saxla.';

  @override
  String get mindKindReflexHint =>
      'Hədəf görünən kimi ona toxun. Erkən və ya səhv toxunuş xal itirir.';

  @override
  String get mindScoringHint =>
      'Doğru və sürətli cavab daha çox xal gətirir. Cəmi yüksək olan qalib gəlir.';

  @override
  String get mindYou => 'Sən';

  @override
  String get mindOpponent => 'Rəqib';

  @override
  String mindProgress(String who, int done, int total) {
    return '$who: $done/$total sual';
  }

  @override
  String mindQuestionOf(int n, int total) {
    return '$n/$total';
  }

  @override
  String get mindGetReady => 'Hazır ol';

  @override
  String get mindYouFinished => 'Bitirdin!';

  @override
  String mindOpponentAt(int done, int total) {
    return 'Rəqibin $done/$total sualdadır. Bitirəndə nəticə çıxacaq.';
  }

  @override
  String get mindMathPrompt => 'Nəticə neçədir?';

  @override
  String get mindAttentionPrompt => 'Təsvir olunan fiquru seç';

  @override
  String get mindMemoryLook => 'Ardıcıllığı və rəngləri yadda saxla';

  @override
  String get mindMemoryPick => 'Eyni ardıcıllıqla və rənglərlə seç';

  @override
  String mindCharLabel(String char, String color) {
    return '$color $char';
  }

  @override
  String get mindUndo => 'Geri al';

  @override
  String get mindReflexTarget => 'Hədəf';

  @override
  String get mindReflexWait => 'Gözlə…';

  @override
  String get mindReflexTap => 'İndi toxun!';

  @override
  String mindRight(int points) {
    return 'Doğru · +$points';
  }

  @override
  String mindPartly(int points) {
    return 'Qismən doğru · +$points';
  }

  @override
  String get mindWrong => 'Səhv';

  @override
  String mindWrongPenalty(int points) {
    return 'Səhv · −$points';
  }

  @override
  String mindTooEarly(int points) {
    return 'Erkən toxundun · −$points';
  }

  @override
  String get mindResignTitle => 'Dueldən çəkil?';

  @override
  String get mindResignBody =>
      'Rəqibin qalib gəlir; reytinqli dueldə Elo xalın düşür.';

  @override
  String get mindFinished => 'Duel bitdi';

  @override
  String get mindEndCompleted => 'Bütün suallar cavablandı';

  @override
  String get mindEndTime => 'Vaxt bitdi';

  @override
  String mindNewRating(int rating) {
    return 'Yeni reytinqin $rating';
  }

  @override
  String get mindNewDuel => 'Yeni duel';

  @override
  String get mindBackHome => 'Duellərə qayıt';

  @override
  String get mindTeamMatches => 'Qrup duelləri';

  @override
  String get mindTeamMatchesHint =>
      'Qruplarının başqa qruplarla duelləri; nəticə qrupun duel Elo xalını dəyişir.';

  @override
  String get mindNoTeamMatches =>
      'Hələ qrup dueli yoxdur. Qrupun adından başqa qrupu dəvət et.';

  @override
  String get mindNewTeamMatch => 'Qrup dueli təşkil et';

  @override
  String get mindNewTeamHint =>
      'Qarşı qrup qəbul edəndə hər iki qrup oyunçularını sıralayır. Başlanğıcda hər sıradakı iki nəfər eyni anda duel edir.';

  @override
  String get mindTeamMatch => 'Qrup dueli';

  @override
  String get mindSeats => 'Sıralar';

  @override
  String mindSeatsCount(int count) {
    return '$count sıra';
  }

  @override
  String get mindLineupHint =>
      'Başlanğıcda boş qalan sıra rəqibə xal kimi yazılır. İlk sual üçün 5 dəqiqə gözlənilir.';

  @override
  String get mindGroupLeaderboardEmpty =>
      'Hələ heç bir qrup qrup dueli oynamayıb. İlkini qrupun təşkil etsin.';

  @override
  String get mindTournaments => 'Turnirlər';

  @override
  String get mindTournamentsHint =>
      'Hər şənbə 21:00 həftəlik (10 sual), ayın son şənbəsi 19:00 aylıq (20 sual); ilk üç medal alır.';

  @override
  String get mindNoTournaments => 'Yaxınlaşan turnir yoxdur.';

  @override
  String get piecesPro => 'Pro';

  @override
  String get piecesPaper => 'Kağız';

  @override
  String get levelTitle => 'Şahmat səviyyəni seç';

  @override
  String get levelBody =>
      'Reytinqin seçdiyin səviyyədən başlayır və ilk oyunlarda real gücünə tez uyğunlaşır.';

  @override
  String get levelPrompt => 'İlk reytinqli oyundan əvvəl bir dəfə seçilir.';

  @override
  String get levelNew => 'Yeni başlayan';

  @override
  String get levelNewHint => 'Fiqurların necə gediş etdiyini öyrənirəm.';

  @override
  String get levelBeginner => 'Başlanğıc';

  @override
  String get levelBeginnerHint => 'Qaydaları bilirəm, arabir oynayıram.';

  @override
  String get levelIntermediate => 'Orta';

  @override
  String get levelIntermediateHint =>
      'Müntəzəm oynayıram, əsas taktikaları bilirəm.';

  @override
  String get levelAdvanced => 'İrəli';

  @override
  String get levelAdvancedHint => 'Debüt və endşpil biliyim yaxşıdır.';

  @override
  String get levelMaster => 'Usta';

  @override
  String get levelMasterHint => 'Turnirlərdə oynayıram.';

  @override
  String get levelNote => 'Reytinqli oyundan sonra səviyyə dəyişdirilə bilməz.';

  @override
  String levelSaved(int rating) {
    return 'Səviyyən yadda saxlanıldı: $rating reytinqlə başlayırsan.';
  }

  @override
  String get leaderboardNoGames =>
      'Bu növdə hələ reytinqli oyun yoxdur. İlk oyunu sən oyna.';

  @override
  String get leaderboardSettling =>
      'Reytinqlər ilk oyunlarda oturur; ilk yerlər tezliklə burada görünəcək.';

  @override
  String get provisionalPlayers => 'Reytinqi oturan oyunçular';

  @override
  String get provisionalPlayersHint =>
      'Müvəqqəti reytinq (?); bir neçə oyundan sonra sıralamaya düşür.';

  @override
  String get provisionalShort => 'Müvəqqəti';

  @override
  String get yourPlace => 'Sənin yerin';

  @override
  String get columnPlayer => 'Oyunçu';

  @override
  String get column30Days => '30 gün';

  @override
  String get columnRating => 'Reytinq';

  @override
  String winRate(int percent) {
    return '%$percent xal';
  }

  @override
  String peakRating(int rating) {
    return 'Ən yüksək $rating';
  }

  @override
  String get ratingSystemNote =>
      'Reytinqlər Glicko-2 sistemi ilə hesablanır. \"?\" reytinqin hələ oturmadığını göstərir.';
}
