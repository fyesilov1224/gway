// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'games_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class GamesL10nTr extends GamesL10n {
  GamesL10nTr([String locale = 'tr']) : super(locale);

  @override
  String get chess => 'Satranç';

  @override
  String get bullet => 'Bullet';

  @override
  String get blitz => 'Blitz';

  @override
  String get rapid => 'Rapid';

  @override
  String get white => 'Beyaz';

  @override
  String get black => 'Siyah';

  @override
  String get colorRandom => 'Rastgele';

  @override
  String get endCheckmate => 'Mat';

  @override
  String get endResign => 'Terk';

  @override
  String get endTimeout => 'Süre bitti';

  @override
  String get endTimeoutDraw => 'Süre bitti, rakibin mat edecek taşı yok';

  @override
  String get endStalemate => 'Pat';

  @override
  String get endInsufficient => 'Yetersiz materyal';

  @override
  String get endFiftyMoves => '50 hamle kuralı';

  @override
  String get endRepetition => 'Üç kez tekrar';

  @override
  String get endAgreement => 'Anlaşmalı beraberlik';

  @override
  String get endAborted => 'İptal edildi';

  @override
  String get boardLabel => 'Satranç tahtası';

  @override
  String get promoteTo => 'Piyon neye dönüşsün?';

  @override
  String get queen => 'Vezir';

  @override
  String get rook => 'Kale';

  @override
  String get bishop => 'Fil';

  @override
  String get knight => 'At';

  @override
  String get medalGold => 'Altın madalya';

  @override
  String get medalSilver => 'Gümüş madalya';

  @override
  String get medalBronze => 'Bronz madalya';

  @override
  String get youWon => 'Kazandın';

  @override
  String get youLost => 'Kaybettin';

  @override
  String get draw => 'Berabere';

  @override
  String get inProgress => 'Sürüyor';

  @override
  String get whiteWon => 'Beyaz kazandı';

  @override
  String get blackWon => 'Siyah kazandı';

  @override
  String get rated => 'Puanlı';

  @override
  String get casual => 'Puansız';

  @override
  String get ratedHint => 'Sonuç Elo puanını değiştirir.';

  @override
  String get flipBoard => 'Tahtayı çevir';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get resign => 'Terk et';

  @override
  String get resignTitle => 'Oyunu terk et?';

  @override
  String get resignBody => 'Rakibin kazanır; puanlı oyunda Elo puanın düşer.';

  @override
  String get abort => 'İptal et';

  @override
  String get offerDraw => 'Berabere?';

  @override
  String get drawOffered => 'Teklif edildi';

  @override
  String get drawOfferReceived => 'Rakibin beraberlik teklif ediyor.';

  @override
  String get accept => 'Kabul et';

  @override
  String get decline => 'Reddet';

  @override
  String get rematch => 'Rövanş';

  @override
  String get rematchSent => 'Rövanş isteği gönderildi.';

  @override
  String get newGame => 'Yeni oyun';

  @override
  String newRating(String category, int rating) {
    return '$category puanın: $rating';
  }

  @override
  String get deletedPlayer => 'Silinmiş hesap';

  @override
  String get firstMove => 'İlk hamle: 30 sn';

  @override
  String get noMovesYet => 'Henüz hamle yok. Beyaz başlar.';

  @override
  String get watching => 'İzliyorsun';

  @override
  String get quickGame => 'Hızlı oyun';

  @override
  String get quickGameHint => 'Süreyi seç, sana yakın puanda biriyle eşleş.';

  @override
  String get searching => 'Rakip aranıyor…';

  @override
  String waitedSeconds(int count) {
    return '$count saniyedir bekliyorsun';
  }

  @override
  String get chessProfile => 'Satranç profili';

  @override
  String get recentGames => 'Son oyunlar';

  @override
  String get noGamesMine => 'Henüz oyunun yok. İlk oyununu oyna.';

  @override
  String get noGamesTheirs => 'Henüz oyunu yok. İlk oyununa sen davet et.';

  @override
  String get playNow => 'Hemen oyna';

  @override
  String get challenge => 'Davet et';

  @override
  String get noFlag => 'Bayrak seçilmedi';

  @override
  String get chooseFlag => 'Bayrağını seç';

  @override
  String get chooseFlagHint => 'Sıralamada adının yanında görünür.';

  @override
  String get searchCountry => 'Ülke ara';

  @override
  String get flagSaved => 'Bayrağın kaydedildi.';

  @override
  String get pickFlagPrompt => 'Sıralamada görünecek bayrağını seç.';

  @override
  String get suspendedNotice => 'Satranç oynaması şu anda kapalı.';

  @override
  String get notPlayed => 'Oynanmadı';

  @override
  String gamesCount(int count) {
    return '$count oyun';
  }

  @override
  String rankShort(int rank) {
    return '$rank. sırada';
  }

  @override
  String get leaderboard => 'Sıralama';

  @override
  String leaderboardEmpty(int count) {
    return 'Sıralamaya girmek için bu türde $count puanlı oyun oyna.';
  }

  @override
  String record(int wins, int draws, int losses) {
    return '${wins}G · ${draws}B · ${losses}M';
  }

  @override
  String get seeAll => 'Tümünü gör';

  @override
  String get invitations => 'Davetler';

  @override
  String invitesYou(String what) {
    return 'Seni oyuna davet ediyor: $what';
  }

  @override
  String wantsRematch(String what) {
    return 'Rövanş istiyor: $what';
  }

  @override
  String waitingFor(String what) {
    return 'Yanıt bekleniyor: $what';
  }

  @override
  String get withdraw => 'Geri çek';

  @override
  String get gameInProgress => 'Süren oyunun var';

  @override
  String get resume => 'Devam et';

  @override
  String get challengeFriend => 'Bir arkadaşını davet et';

  @override
  String get challengeSent => 'Davet gönderildi. Kabul edince oyun başlar.';

  @override
  String get challengeTitle => 'Oyuna davet et';

  @override
  String get changePerson => 'Kişiyi değiştir';

  @override
  String get searchPerson => 'Kullanıcı adı ya da isim';

  @override
  String get timeControl => 'Süre';

  @override
  String get yourColor => 'Rengin';

  @override
  String get sendChallenge => 'Daveti gönder';

  @override
  String get teamMatch => 'Takım maçı';

  @override
  String get teamMatches => 'Takım maçları';

  @override
  String get teamMatchesHint =>
      'Gruplarının satranç maçları; sonuç grup Elo puanını değiştirir.';

  @override
  String get noTeamMatches =>
      'Henüz takım maçı yok. Grubun adına başka bir grubu davet et.';

  @override
  String get newTeamMatch => 'Takım maçı düzenle';

  @override
  String get newTeamMatchHint =>
      'Karşı grubun yöneticisi kabul edince iki grup da tahtalara oyuncularını dizer.';

  @override
  String get yourGroup => 'Grubun';

  @override
  String get opponentGroup => 'Rakip grup';

  @override
  String get searchGroup => 'Grup adı ya da kullanıcı adı';

  @override
  String get startsAt => 'Başlangıç';

  @override
  String get sendTeamInvite => 'Grubu davet et';

  @override
  String get boards => 'Tahtalar';

  @override
  String get boardsShort => 'tahta';

  @override
  String boardsCount(int count) {
    return '$count tahta';
  }

  @override
  String groupElo(int rating) {
    return 'Grup Elo $rating';
  }

  @override
  String get versus => 'VS';

  @override
  String get versusShort => '–';

  @override
  String get teamInvited => 'Yanıt bekleniyor';

  @override
  String get teamAccepted => 'Kabul edildi';

  @override
  String get teamDeclined => 'Reddedildi';

  @override
  String get teamCanceled => 'İptal edildi';

  @override
  String get teamLive => 'Oynanıyor';

  @override
  String get teamFinished => 'Bitti';

  @override
  String teamInviteReceived(String group) {
    return '$group grubunuzu takım maçına davet ediyor.';
  }

  @override
  String get teamAcceptedDone =>
      'Maç kabul edildi. Şimdi oyuncularınızı dizin.';

  @override
  String get teamDeclinedDone => 'Davet reddedildi.';

  @override
  String get teamCanceledDone => 'Maç iptal edildi.';

  @override
  String get callOff => 'Maçı iptal et';

  @override
  String get lineupHint =>
      'Başlangıçta boş kalan tahta rakibe puan olarak yazılır.';

  @override
  String get lineupSheetHint =>
      'Üyelere dokunarak sırayla tahtalara yerleştir; 1. tahta en güçlü oyuncunundur.';

  @override
  String editLineup(String group) {
    return '$group dizilişi';
  }

  @override
  String get saveLineup => 'Dizilişi kaydet';

  @override
  String get emptyBoard => 'Boş';

  @override
  String ratingGames(int rating, int games) {
    return 'Elo $rating · $games oyun';
  }

  @override
  String get groupsTab => 'Gruplar';

  @override
  String get groupLeaderboardEmpty =>
      'Henüz takım maçı oynayan grup yok. İlk maçı grubun düzenlesin.';

  @override
  String get backToChess => 'Satranca dön';

  @override
  String get arena => 'Turnuva';

  @override
  String get tournaments => 'Turnuvalar';

  @override
  String get tournamentsHint =>
      'Haftalık ve aylık Arena turnuvaları; ilk üç madalya alır.';

  @override
  String get weeklyArena => 'Haftalık Arena';

  @override
  String get monthlyArena => 'Aylık Arena';

  @override
  String get arenaRules =>
      'Arena: süre boyunca istediğin kadar oyna. Kazanma 2, beraberlik 1 puan; üst üste iki galibiyetten sonra seri bitene kadar puanlar ikiye katlanır. Bitmeden başlayan oyunlar sayılır.';

  @override
  String get arenaLiveNow => 'Şimdi oynanıyor';

  @override
  String get arenaUpcoming => 'Yaklaşan';

  @override
  String get arenaFinished => 'Bitenler';

  @override
  String get registered => 'Kayıtlısın';

  @override
  String get arenaRegister => 'Kayıt ol';

  @override
  String get arenaRegistered =>
      'Kayıtlısın. Turnuva başlayınca bildirim alırsın; açınca hemen eşleşirsin.';

  @override
  String get arenaJoin => 'Katıl';

  @override
  String get arenaResume => 'Oynamaya devam et';

  @override
  String get arenaPause => 'Ara ver';

  @override
  String get arenaWaiting =>
      'Rakip bekleniyor; puanı yakın biri boşalınca oyun kendiliğinden açılır.';

  @override
  String get backToGame => 'Oyuna dön';

  @override
  String get backToArena => 'Turnuvaya dön';

  @override
  String get backToTeamMatch => 'Takım maçına dön';

  @override
  String arenaStartsIn(String time) {
    return '$time sonra başlıyor';
  }

  @override
  String arenaEndsIn(String time) {
    return 'Bitişe $time';
  }

  @override
  String get arenaLastGames => 'Süre doldu; son oyunlar bitiyor';

  @override
  String arenaFinishedAt(String time) {
    return 'Bitti · $time';
  }

  @override
  String hoursMinutes(int hours, int minutes) {
    return '$hours sa $minutes dk';
  }

  @override
  String minutesLong(int count) {
    return '$count dakika';
  }

  @override
  String playersCount(int count) {
    return '$count oyuncu';
  }

  @override
  String myArenaScore(int points, int games) {
    return '$points puan · $games oyun';
  }

  @override
  String get onFire => 'Seride: sonraki sonuç iki kat puan';

  @override
  String get standings => 'Puan durumu';

  @override
  String get arenaEmpty => 'Henüz katılan yok. İlk sen katıl.';

  @override
  String performance(int value) {
    return 'Performans $value';
  }

  @override
  String get playingNow => 'oynuyor';

  @override
  String get arenaMedals => 'Turnuva madalyaları';

  @override
  String medalsSummary(int gold, int silver, int bronze) {
    return 'Turnuva madalyaları: $gold altın, $silver gümüş, $bronze bronz';
  }

  @override
  String get firstMoveTeam => 'İlk hamle: 5 dk';

  @override
  String get games => 'Oyunlar';

  @override
  String get gamesIntro =>
      'Topluluğunla oyna: hızlı oyunlar, turnuvalar ve gruplar arası maçlar.';

  @override
  String get chessCardText =>
      'Elo puanı, haftalık ve aylık turnuvalar, gruplar arası takım maçları ve madalyalar.';

  @override
  String get playChess => 'Satranç oyna';

  @override
  String blitzRating(int rating) {
    return 'Blitz $rating';
  }

  @override
  String nextArena(String time) {
    return 'Sıradaki turnuva: $time';
  }

  @override
  String invitesWaiting(int count) {
    return '$count davet bekliyor';
  }

  @override
  String get playOnline => 'Çevrimiçi oyna';

  @override
  String findOpponent(String tc) {
    return 'Rakip bul · $tc';
  }

  @override
  String get challengeFriendHint => 'Süreyi ve rengi sen seç';

  @override
  String get leaderboardHint => 'Elo sıralaması ve madalyalar';

  @override
  String openTeamMatches(int count) {
    return '$count açık maç';
  }

  @override
  String get appearance => 'Tahta ve taşlar';

  @override
  String get boardTheme => 'Tahta';

  @override
  String get pieceSet => 'Taşlar';

  @override
  String get boardWood => 'Ahşap';

  @override
  String get boardGreen => 'Yeşil';

  @override
  String get boardBlue => 'Mavi';

  @override
  String get boardSlate => 'Gri';

  @override
  String get boardLilac => 'GWAY moru';

  @override
  String get piecesClassic => 'Klasik';

  @override
  String get piecesCeltic => 'Kelt';

  @override
  String get piecesSpatial => 'Uzay';

  @override
  String get piecesFantasy => 'Fantastik';

  @override
  String get piecesModern => 'Modern';

  @override
  String get piecesWarm => 'Sıcak';

  @override
  String get firstPosition => 'Başlangıç';

  @override
  String get previousMove => 'Önceki hamle';

  @override
  String get nextMove => 'Sonraki hamle';

  @override
  String get lastPosition => 'Son konum';

  @override
  String get backToLive => 'Canlıya dön';

  @override
  String pointsShort(int points) {
    return '$points puan';
  }

  @override
  String mindColorWord(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'red_m': 'kırmızı',
      'red_f': 'kırmızı',
      'red_n': 'kırmızı',
      'blue_m': 'mavi',
      'blue_f': 'mavi',
      'blue_n': 'mavi',
      'green_m': 'yeşil',
      'green_f': 'yeşil',
      'green_n': 'yeşil',
      'yellow_m': 'sarı',
      'yellow_f': 'sarı',
      'yellow_n': 'sarı',
      'purple_m': 'mor',
      'purple_f': 'mor',
      'purple_n': 'mor',
      'orange_m': 'turuncu',
      'orange_f': 'turuncu',
      'orange_n': 'turuncu',
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
      'striped_m': 'çizgili',
      'striped_f': 'çizgili',
      'striped_n': 'çizgili',
      'dotted_m': 'noktalı',
      'dotted_f': 'noktalı',
      'dotted_n': 'noktalı',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String mindShapeWord(String shape) {
    String _temp0 = intl.Intl.selectLogic(shape, {
      'circle': 'yuvarlak',
      'square': 'kare',
      'triangle': 'üçgen',
      'star': 'yıldız',
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
  String get mindDuel => 'Zihin Düellosu';

  @override
  String get mindCardText =>
      'Matematik, dikkat, hafıza ve refleks sorularında canlı düello. Elo puanı, sıralama ve madalyalar.';

  @override
  String get mindPlay => 'Düelloya başla';

  @override
  String mindBestRating(int rating, int length) {
    return 'Elo $rating · $length soru';
  }

  @override
  String mindQuestions(int count) {
    return '$count soru';
  }

  @override
  String get mindHowMany => 'Kaç soru?';

  @override
  String mindRatingAt(int count) {
    return '$count soruda puanın';
  }

  @override
  String get mindFindOpponent => 'Rakip bul';

  @override
  String get mindSuspended => 'Oyun oynaman şu anda kapalı.';

  @override
  String get mindActive => 'Süren bir düellon var';

  @override
  String get mindProfile => 'Düello profili';

  @override
  String get mindHowTo => 'Nasıl oynanır';

  @override
  String get mindRecent => 'Son düellolar';

  @override
  String get mindNoMatchesMine => 'Henüz düellon yok. İlk rakibini bul.';

  @override
  String get mindNoMatchesTheirs =>
      'Henüz düellosu yok. İlk düellosuna sen davet et.';

  @override
  String mindLeaderboardEmpty(int count) {
    return 'Sıralamaya girmek için bu soru sayısında $count puanlı düello oyna.';
  }

  @override
  String get mindChallengeTitle => 'Düelloya davet et';

  @override
  String get mindChallengeSent =>
      'Davet gönderildi. Kabul edince düello başlar.';

  @override
  String get mindKindMath => 'Matematik';

  @override
  String get mindKindAttention => 'Dikkat';

  @override
  String get mindKindMemory => 'Hafıza';

  @override
  String get mindKindReflex => 'Refleks';

  @override
  String get mindKindMathHint =>
      'Dört işlem, işlem önceliğiyle. Doğru sonucu seç.';

  @override
  String get mindKindAttentionHint =>
      'Yazının rengine değil, anlattığı şekle bak.';

  @override
  String get mindKindMemoryHint =>
      'Renkli harf ve rakamları sırasıyla ve renkleriyle hatırla.';

  @override
  String get mindKindReflexHint =>
      'Hedef belirince ona ilk sen dokun. Erken ya da yanlış dokunuş puan kaybettirir.';

  @override
  String get mindScoringHint =>
      'Doğru ve hızlı cevap daha çok puan getirir. Toplam puanı yüksek olan kazanır.';

  @override
  String get mindYou => 'Sen';

  @override
  String get mindOpponent => 'Rakip';

  @override
  String mindProgress(String who, int done, int total) {
    return '$who: $done/$total soru';
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
    return 'Rakibin $done/$total. soruda. Bitirince sonuç çıkar.';
  }

  @override
  String get mindMathPrompt => 'Sonuç kaç?';

  @override
  String get mindAttentionPrompt => 'Yazının anlattığı şekli seç';

  @override
  String get mindMemoryLook => 'Sırayı ve renkleri aklında tut';

  @override
  String get mindMemoryPick => 'Aynı sırayla ve renkleriyle seç';

  @override
  String mindCharLabel(String char, String color) {
    return '$color $char';
  }

  @override
  String get mindUndo => 'Geri al';

  @override
  String get mindReflexTarget => 'Hedef';

  @override
  String get mindReflexWait => 'Bekle…';

  @override
  String get mindReflexTap => 'Şimdi dokun!';

  @override
  String mindRight(int points) {
    return 'Doğru · +$points';
  }

  @override
  String mindPartly(int points) {
    return 'Kısmen doğru · +$points';
  }

  @override
  String get mindWrong => 'Yanlış';

  @override
  String mindWrongPenalty(int points) {
    return 'Yanlış · −$points';
  }

  @override
  String mindTooEarly(int points) {
    return 'Erken dokundun · −$points';
  }

  @override
  String get mindResignTitle => 'Düellodan çekil?';

  @override
  String get mindResignBody =>
      'Rakibin kazanır; puanlı düelloda Elo puanın düşer.';

  @override
  String get mindFinished => 'Düello bitti';

  @override
  String get mindEndCompleted => 'Bütün sorular cevaplandı';

  @override
  String get mindEndTime => 'Süre doldu';

  @override
  String mindNewRating(int rating) {
    return 'Yeni puanın $rating';
  }

  @override
  String get mindNewDuel => 'Yeni düello';

  @override
  String get mindBackHome => 'Düello sayfasına dön';

  @override
  String get mindTeamMatches => 'Grup düelloları';

  @override
  String get mindTeamMatchesHint =>
      'Grubunun başka gruplarla düelloları; sonuç grubun düello Elo puanını değiştirir.';

  @override
  String get mindNoTeamMatches =>
      'Henüz grup düellosu yok. Grubun adına başka bir grubu davet et.';

  @override
  String get mindNewTeamMatch => 'Grup düellosu düzenle';

  @override
  String get mindNewTeamHint =>
      'Karşı grubun yöneticisi kabul edince iki grup da oyuncularını sıralar. Başlangıçta her sıradaki iki kişi aynı anda düello eder.';

  @override
  String get mindTeamMatch => 'Grup düellosu';

  @override
  String get mindSeats => 'Sıralar';

  @override
  String mindSeatsCount(int count) {
    return '$count sıra';
  }

  @override
  String get mindLineupHint =>
      'Başlangıçta boş kalan sıra rakibe puan olarak yazılır. Grup düellosunda ilk soru için 5 dakika beklenir.';

  @override
  String get mindGroupLeaderboardEmpty =>
      'Henüz grup düellosu oynayan grup yok. İlk düelloyu grubun düzenlesin.';
}
