"""Matching: enum labels and package texts become getters; mode-dependent sentences get their own keys."""
import pathlib, sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))
from dartedit import edit  # noqa: E402

app = pathlib.Path(__file__).resolve().parents[3]
src = app / 'packages/features/matching/lib/src'
edit(str(src / 'domain/matching.dart'), [
    ("""  friend('friend', 'Arkadaş'),
  dating('dating', 'Sevgili');

  const MatchMode(this.code, this.label);

  final String code;
  final String label;""", """  friend('friend'),
  dating('dating');

  const MatchMode(this.code);

  final String code;

  String get label => switch (this) {
        friend => matchingL10n.modeFriend,
        dating => matchingL10n.modeDating,
      };"""),
    ("""  woman('woman', 'Kadın'),
  man('man', 'Erkek'),
  nonbinary('nonbinary', 'İkili olmayan');

  const MatchGender(this.code, this.label);

  final String code;
  final String label;""", """  woman('woman'),
  man('man'),
  nonbinary('nonbinary');

  const MatchGender(this.code);

  final String code;

  String get label => switch (this) {
        woman => matchingL10n.genderWoman,
        man => matchingL10n.genderMan,
        nonbinary => matchingL10n.genderNonbinary,
      };"""),
    ("""        1 => 'Ortak grup: ${sharedGroups.first.name}',
        final n => 'Ortak: ${sharedGroups.first.name} ve ${n - 1} grup daha',""",
     """        1 => matchingL10n.sharedGroup(sharedGroups.first.name),
        final n => matchingL10n.sharedGroupsMore(sharedGroups.first.name, n - 1),"""),
    ("""  reveal('matching_reveal', 'Eşleşmelerim', 'Kiminle eşleştiğini gör: ad, fotoğraflar ve profil.', {MatchFeature.reveal}),
  chat('matching_chat', 'Eşleşme Sohbeti', 'Eşleştiklerine yaz. Eşleşmelerini görmeyi de içerir.', {MatchFeature.chat, MatchFeature.reveal}),
  admirers('matching_admirers', 'Seni Beğenenler', 'Seni kimlerin beğendiğini gör, beğenerek anında eşleş.', {MatchFeature.admirers}),
  unlimited('matching_unlimited', 'Sınırsız Beğeni', 'Günlük beğeni sınırı kalkar; geri al ve filtreler de açılır.', {MatchFeature.unlimited}),
  superLike('matching_super', 'Süper Beğeni', 'Günde 5 süper beğeni; seni süper beğendiğin kişi destesinde ilk görür.', {MatchFeature.superLike}),
  boost('matching_boost', 'Öne Çık', 'Günde bir kez 30 dakika ortak gruplarındaki destelerin en başında görün.', {MatchFeature.boost}),
  teammates('matching_teammates', 'Ekip Arkadaşı', 'Ekip arkadaşı isteği gönder ve ekip arkadaşlarınla yazış.', {MatchFeature.teammates}),
  all('matching_premium', 'Hepsi Bir Arada', 'Bütün paketler tek pakette, ayrı ayrı almaktan çok daha uygun.', {...MatchFeature.values});

  const MatchPackage(this.slug, this.title, this.description, this.features);

  final String slug;
  final String title;
  final String description;""", """  reveal('matching_reveal', {MatchFeature.reveal}),
  chat('matching_chat', {MatchFeature.chat, MatchFeature.reveal}),
  admirers('matching_admirers', {MatchFeature.admirers}),
  unlimited('matching_unlimited', {MatchFeature.unlimited}),
  superLike('matching_super', {MatchFeature.superLike}),
  boost('matching_boost', {MatchFeature.boost}),
  teammates('matching_teammates', {MatchFeature.teammates}),
  all('matching_premium', {...MatchFeature.values});

  const MatchPackage(this.slug, this.features);

  final String slug;

  String get title => switch (this) {
        reveal => matchingL10n.pkgReveal,
        chat => matchingL10n.pkgChat,
        admirers => matchingL10n.pkgAdmirers,
        unlimited => matchingL10n.pkgUnlimited,
        superLike => matchingL10n.pkgSuper,
        boost => matchingL10n.pkgBoost,
        teammates => matchingL10n.pkgTeammates,
        all => matchingL10n.pkgAll,
      };

  String get description => switch (this) {
        reveal => matchingL10n.pkgRevealText,
        chat => matchingL10n.pkgChatText,
        admirers => matchingL10n.pkgAdmirersText,
        unlimited => matchingL10n.pkgUnlimitedText,
        superLike => matchingL10n.pkgSuperText,
        boost => matchingL10n.pkgBoostText,
        teammates => matchingL10n.pkgTeammatesText,
        all => matchingL10n.pkgAllText,
      };"""),
], ['../l10n.dart'])

edit(str(src / 'presentation/matches_screen.dart'), [
    ("""        final sure = await confirmMatchAction(
          context,
          title: 'Yalnızca ${keep.label.toLowerCase()} kal',
          message: '${card.displayName} ile ${drop.label.toLowerCase()} eşleşmeniz ikiniz için de biter; '
              '${keep.label.toLowerCase()} olarak eşleşmeniz ve sohbetiniz sürer.',""",
     """        final l = matchingL10n;
        final friend = keep == MatchMode.friend;
        final sure = await confirmMatchAction(
          context,
          title: friend ? l.keepFriend : l.keepDating,
          message: friend ? l.keepFriendBody(card.displayName) : l.keepDatingBody(card.displayName),"""),
    ("""          Ok() => 'Artık yalnızca ${keep.label.toLowerCase()} olarak eşleşiksiniz.',""",
     """          Ok() => friend ? l.keptFriend : l.keptDating,"""),
], ['../l10n.dart'])
print('matching structure done')
