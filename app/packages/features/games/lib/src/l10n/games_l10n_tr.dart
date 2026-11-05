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
}
