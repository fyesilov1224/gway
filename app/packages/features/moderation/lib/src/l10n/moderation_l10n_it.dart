// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'moderation_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class ModerationL10nIt extends ModerationL10n {
  ModerationL10nIt([String locale = 'it']) : super(locale);

  @override
  String get ruleRateLimited =>
      'Oggi hai inviato troppe segnalazioni. Riprova domani.';

  @override
  String get ruleTargetInvalid =>
      'Questo contenuto non esiste più o non puoi vederlo.';

  @override
  String get ruleSelf => 'Non puoi segnalare te stesso o i tuoi contenuti.';

  @override
  String get ruleAppealNotAllowed =>
      'Non è più possibile fare ricorso contro questa sanzione.';

  @override
  String get ruleDuplicate => 'L\'hai già segnalato; è in revisione.';

  @override
  String get deletedAccount => 'Account eliminato';

  @override
  String get reasonSpam => 'Spam o ingannevole';

  @override
  String get reasonHarassment => 'Molestie o bullismo';

  @override
  String get reasonHate => 'Incitamento all\'odio';

  @override
  String get reasonViolence => 'Violenza o minacce';

  @override
  String get reasonSexual => 'Contenuti sessuali';

  @override
  String get reasonMisinformation => 'Informazioni false';

  @override
  String get reasonOther => 'Altro';

  @override
  String get sanctionWarning => 'Avvertimento';

  @override
  String get sanctionMute => 'Silenziamento';

  @override
  String get sanctionKick => 'Rimozione dal gruppo';

  @override
  String get sanctionBan => 'Ban';

  @override
  String get illegalViolence => 'Violenza';

  @override
  String get illegalThreat => 'Minaccia';

  @override
  String get illegalInsult => 'Ingiuria';

  @override
  String get illegalHate => 'Incitamento all\'odio';

  @override
  String get illegalSexual => 'Abuso sessuale';

  @override
  String get illegalFraud => 'Frode';

  @override
  String get illegalDrugs => 'Droga';

  @override
  String get illegalTerror => 'Terrorismo';

  @override
  String get illegalOther => 'Altro reato';

  @override
  String muteDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Silenziato $days giorni',
      one: 'Silenziato 1 giorno',
    );
    return '$_temp0';
  }

  @override
  String banDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Ban di $days giorni',
      one: 'Ban di 1 giorno',
    );
    return '$_temp0';
  }

  @override
  String get permanentBan => 'Ban permanente';

  @override
  String get thresholdMajority => 'Maggioranza semplice';

  @override
  String get thresholdMajorityText => 'Più della metà dei voti';

  @override
  String get thresholdTwoThirds => 'Due terzi';

  @override
  String get thresholdTwoThirdsText => 'Almeno due terzi dei voti';

  @override
  String get thresholdUnanimous => 'Unanimità';

  @override
  String get thresholdUnanimousText => 'Tutti i voti';

  @override
  String get targetPost => 'Post';

  @override
  String get targetComment => 'Commento';

  @override
  String get targetEvent => 'Evento';

  @override
  String get targetLiveComment => 'Commento in diretta';

  @override
  String get targetMessage => 'Messaggio della chat di gruppo';

  @override
  String get targetMember => 'Membro';

  @override
  String get appealPending => 'In attesa di decisione';

  @override
  String get appealUpheld => 'Sanzione confermata';

  @override
  String get appealOverturned => 'Sanzione revocata';

  @override
  String get banApplied => 'Ban applicato.';

  @override
  String get banAppliedSuspended =>
      'Ban applicato. L\'account della persona è sospeso fino alla revisione della piattaforma.';

  @override
  String get caseOpened => 'Pratica aperta. Il consiglio voterà entro 72 ore.';

  @override
  String get openCaseTitle => 'Apri una pratica disciplinare';

  @override
  String caseAboutNow(String name) {
    return 'Riguarda $name. Il ban si applica subito, senza voto del consiglio.';
  }

  @override
  String caseAboutVote(String name) {
    return 'Riguarda $name. Il consiglio di disciplina vota la tua proposta entro 72 ore.';
  }

  @override
  String get proposedSanction => 'Sanzione proposta';

  @override
  String get duration => 'Durata';

  @override
  String get permanent => 'Permanente';

  @override
  String get permanentLower => 'permanente';

  @override
  String days(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days giorni',
      one: '1 giorno',
    );
    return '$_temp0';
  }

  @override
  String get applyNow => 'Applica subito, senza voto';

  @override
  String get applyNowHint =>
      'Banna senza attendere il consiglio. La persona può fare ricorso entro 7 giorni.';

  @override
  String get illegalActivity => 'Attività illegale';

  @override
  String get illegalHintNow =>
      'Applicato il ban, la pratica passa al team della piattaforma e l\'account viene sospeso fino alla revisione. Questo contrassegno non si può modificare.';

  @override
  String get illegalHintVote =>
      'Se il consiglio approva, la pratica passa al team della piattaforma e l\'account viene sospeso fino alla revisione. Questo contrassegno non si può modificare.';

  @override
  String get reason => 'Motivo';

  @override
  String get reasonHintNow =>
      'Cos\'è successo? La persona e chi esamina il ricorso vedranno questo testo.';

  @override
  String get reasonHintVote =>
      'Cos\'è successo? Il consiglio voterà in base a questo testo.';

  @override
  String get reasonMin10 => 'Il motivo deve avere almeno 10 caratteri.';

  @override
  String get muteNow => 'Silenzia subito (24 ore)';

  @override
  String get muteNowHint =>
      'Finché il consiglio non decide, non può commentare né parlare in diretta.';

  @override
  String get ban => 'Banna';

  @override
  String get openCase => 'Apri pratica';

  @override
  String leftDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days giorni',
      one: '1 giorno',
    );
    return '$_temp0';
  }

  @override
  String leftDaysHours(int days, int hours) {
    return '$days g $hours h';
  }

  @override
  String leftHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours ore',
      one: '1 ora',
    );
    return '$_temp0';
  }

  @override
  String get leftFewMinutes => 'pochi minuti';

  @override
  String minChars(int min) {
    return 'Scrivi almeno $min caratteri.';
  }

  @override
  String get cancel => 'Annulla';

  @override
  String get threshold => 'Soglia di decisione del consiglio';

  @override
  String thresholdChanged(String threshold) {
    return 'La soglia ora è «$threshold». Vale per le nuove pratiche.';
  }

  @override
  String moderationOf(String group) {
    return 'Moderazione · $group';
  }

  @override
  String get reports => 'Segnalazioni';

  @override
  String reportsCount(int count) {
    return 'Segnalazioni ($count)';
  }

  @override
  String get cases => 'Pratiche';

  @override
  String casesCount(int count) {
    return 'Pratiche ($count)';
  }

  @override
  String get sanctions => 'Sanzioni';

  @override
  String sanctionsCount(int count) {
    return 'Sanzioni ($count)';
  }

  @override
  String get moderationTeamOnly =>
      'Solo il proprietario e il team di moderazione vedono la moderazione di questo gruppo.';

  @override
  String get goBack => 'Torna indietro';

  @override
  String get noReports =>
      'Nessuna segnalazione aperta. Qui arrivano quelle dei membri.';

  @override
  String get refresh => 'Aggiorna';

  @override
  String get removeContent => 'Rimuovi contenuto';

  @override
  String get remove => 'Rimuovi';

  @override
  String get contentRemoved => 'Contenuto rimosso.';

  @override
  String reportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count segnalazioni',
      one: '1 segnalazione',
    );
    return '$_temp0';
  }

  @override
  String get view => 'Visualizza';

  @override
  String get reportDismissed => 'Segnalazione respinta.';

  @override
  String get dismiss => 'Respingi';

  @override
  String get openCaseShort => 'Apri pratica';

  @override
  String get rankOnlyDismiss =>
      'Il grado di questa persona non è inferiore al tuo: puoi solo respingere.';

  @override
  String get noCases =>
      'Ancora nessuna pratica disciplinare. Si aprono da una segnalazione o dalla pagina membri.';

  @override
  String get voteApproved =>
      'Il tuo voto è stato salvato. Il consiglio ha approvato la sanzione, che è stata applicata.';

  @override
  String get voteRejected =>
      'Il tuo voto è stato salvato. Il consiglio ha respinto la sanzione.';

  @override
  String get voteSaved =>
      'Il tuo voto è stato salvato. Puoi cambiarlo fino alla decisione.';

  @override
  String get statusVoting => 'In votazione';

  @override
  String get statusApproved => 'Approvato';

  @override
  String get statusRejected => 'Respinto';

  @override
  String proposed(String sanction) {
    return 'Proposta: $sanction';
  }

  @override
  String get directBan => 'Ban senza voto';

  @override
  String illegalLabel(String category) {
    return 'Attività illegale: $category';
  }

  @override
  String tally(int approvals, int rejections, int voters) {
    return '$approvals favorevoli · $rejections contrari · $voters votanti';
  }

  @override
  String votingEndsIn(String time) {
    return 'La votazione termina tra $time';
  }

  @override
  String bannedBy(String name) {
    return 'Bannato da: $name';
  }

  @override
  String openedBy(String name) {
    return 'Aperta da: $name';
  }

  @override
  String get approve => 'Approva';

  @override
  String get reject => 'Respingi';

  @override
  String get noSanctions =>
      'Ancora nessuna sanzione. Qui compaiono quelle approvate e i ricorsi.';

  @override
  String get liftSanction => 'Revoca la sanzione';

  @override
  String get keepSanction => 'Mantieni la sanzione';

  @override
  String get noteToPerson => 'Nota per la persona (facoltativa)';

  @override
  String get liftedNotified =>
      'Sanzione revocata; la persona è stata avvisata.';

  @override
  String get appealRejectedNotified =>
      'Ricorso respinto; la persona è stata avvisata.';

  @override
  String get lifted => 'Revocata';

  @override
  String get interimMute => 'Silenziamento urgente';

  @override
  String get running => 'In corso';

  @override
  String get applied => 'Applicata';

  @override
  String get interimUntilDecision =>
      'Silenziamento urgente · fino alla decisione del consiglio';

  @override
  String until(String date) {
    return 'fino al $date';
  }

  @override
  String appealLine(String status) {
    return 'Ricorso · $status';
  }

  @override
  String noteLine(String note) {
    return 'Nota: $note';
  }

  @override
  String get ownerParty =>
      'Il proprietario è parte della pratica: il ricorso lo esamina il team della piattaforma.';

  @override
  String get keep => 'Mantieni';

  @override
  String casesAwaitingVote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pratiche attendono il tuo voto',
      one: '1 pratica attende il tuo voto',
    );
    return '$_temp0';
  }

  @override
  String appealsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ricorsi',
      one: '1 ricorso',
    );
    return '$_temp0';
  }

  @override
  String get moderation => 'Moderazione';

  @override
  String get noWork => 'Niente in sospeso';

  @override
  String get mySanctions => 'Le mie sanzioni';

  @override
  String get noMySanctions =>
      'Non hai sanzioni in nessun gruppo. Grazie per rispettare le regole della community.';

  @override
  String get interimEnded => 'Silenziamento urgente terminato';

  @override
  String interimLatest(String date) {
    return 'Silenziamento urgente · fino alla decisione del consiglio, al più tardi il $date';
  }

  @override
  String untilCap(String date) {
    return 'Fino al $date';
  }

  @override
  String get ended => 'Terminata';

  @override
  String get appeal => 'Fai ricorso';

  @override
  String get appealHint => 'Perché pensi che sia ingiusto?';

  @override
  String get send => 'Invia';

  @override
  String get appealSent =>
      'Il ricorso è stato inviato. Riceverai una notifica alla decisione.';

  @override
  String reasonLine(String reason) {
    return 'Motivo: $reason';
  }

  @override
  String yourAppealLine(String status) {
    return 'Il tuo ricorso · $status';
  }

  @override
  String get appealOnce => 'Puoi fare ricorso una volta entro 7 giorni.';

  @override
  String get reportPost => 'Segnala post';

  @override
  String get reportComment => 'Segnala commento';

  @override
  String get reportEvent => 'Segnala evento';

  @override
  String get reportMessage => 'Segnala messaggio';

  @override
  String get reportMatchProfile => 'Segnala profilo match';

  @override
  String get reportPhoto => 'Segnala foto';

  @override
  String get reportUser => 'Segnala utente';

  @override
  String get reportReceived =>
      'Abbiamo ricevuto la segnalazione. La esamineremo e agiremo; la tua identità non viene mostrata alla persona segnalata.';

  @override
  String get whyReport => 'Perché lo segnali?';

  @override
  String get detailsOptional => 'Dettagli (facoltativi)';

  @override
  String get detailsHint => 'Descrivi in breve cos\'è successo.';

  @override
  String get report => 'Segnala';
}
