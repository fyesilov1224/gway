// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'support_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class SupportL10nIt extends SupportL10n {
  SupportL10nIt([String locale = 'it']) : super(locale);

  @override
  String get ruleTicketRate =>
      'Oggi hai aperto troppi messaggi. Riprova domani o rispondi in quelli aperti.';

  @override
  String get ruleReplyRate =>
      'Hai scritto troppe risposte in poco tempo. Aspetta un po’ e riprova.';

  @override
  String get ticketClosed =>
      'Questo messaggio è chiuso. Aprine uno nuovo per continuare.';

  @override
  String get unsupportedImage =>
      'Questo tipo di file non è supportato. Scegli JPEG, PNG o WebP.';

  @override
  String get kindProblem => 'Problema';

  @override
  String get kindProblemText => 'Qualcosa è rotto o non funziona.';

  @override
  String get kindRequest => 'Richiesta';

  @override
  String get kindRequestText =>
      'Chiedi un intervento per account, gruppo o pagamento.';

  @override
  String get kindSuggestion => 'Suggerimento';

  @override
  String get kindSuggestionText => 'Condividi un’idea o un suggerimento.';

  @override
  String get statusOpen => 'Nuovo';

  @override
  String get statusInProgress => 'In lavorazione';

  @override
  String get statusResolved => 'Risolto';

  @override
  String get statusClosed => 'Chiuso';

  @override
  String get guide => 'Guida';

  @override
  String get guideSearchHint =>
      'Cerca nella guida: es. link di invito, password';

  @override
  String get clearSearch => 'Cancella ricerca';

  @override
  String get guideIntro =>
      'Spiega ogni parte di GWAY passo dopo passo. Scegli un capitolo o cerca qui sopra.';

  @override
  String get noHits =>
      'Nessun risultato. Prova un’altra parola o scrivi al supporto.';

  @override
  String get writeSupport => 'Scrivi al supporto';

  @override
  String hitsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count argomenti trovati',
      one: '1 argomento trovato',
    );
    return '$_temp0';
  }

  @override
  String chapterSemantics(String title, String summary, int count) {
    return '$title. $summary $count argomenti.';
  }

  @override
  String topicCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count argomenti',
      one: '1 argomento',
    );
    return '$_temp0';
  }

  @override
  String get chapterNotFound => 'Capitolo non trovato.';

  @override
  String get backToGuide => 'Torna alla guida';

  @override
  String get notSolved => 'Problema non risolto?';

  @override
  String get notSolvedHint =>
      'Scrivi al team della piattaforma; la risposta sarà in Impostazioni → Supporto e feedback.';

  @override
  String get nextChapter => 'Capitolo successivo';

  @override
  String get sent => 'Il messaggio è stato inviato al team della piattaforma.';

  @override
  String get newMessage => 'Nuovo messaggio';

  @override
  String get aboutWhat => 'Di cosa vuoi scrivere?';

  @override
  String get pickKind => 'Scegli un tipo.';

  @override
  String get relatedGroup => 'Gruppo interessato (facoltativo)';

  @override
  String get noGroup => 'Non riguarda un gruppo';

  @override
  String get subject => 'Oggetto';

  @override
  String get subjectRequired => 'Scrivi un oggetto breve.';

  @override
  String get description => 'Descrizione';

  @override
  String get descriptionHint =>
      'Cos\'è successo e cosa ti aspettavi? Più dettagli, aiuto più rapido.';

  @override
  String get descriptionRequired => 'Descrivi in breve cos\'è successo.';

  @override
  String get send => 'Invia';

  @override
  String get supportTitle => 'Supporto e feedback';

  @override
  String get emptyIntro =>
      'Puoi scrivere al team della piattaforma per un problema, una richiesta o un suggerimento.';

  @override
  String get listIntro =>
      'I tuoi messaggi vanno al team della piattaforma; segui qui risposte e stato.';

  @override
  String get newReply => 'Nuova risposta';

  @override
  String get message => 'Messaggio';

  @override
  String get notFound => 'Messaggio non trovato.';

  @override
  String get goBack => 'Torna indietro';

  @override
  String get team => 'Team GWAY';

  @override
  String get you => 'Tu';

  @override
  String get addScreenshot => 'Aggiungi screenshot';

  @override
  String get writeReply => 'Scrivi una risposta';

  @override
  String get removeImage => 'Rimuovi immagine';

  @override
  String screenshots(int count, int max) {
    return 'Screenshot ($count/$max)';
  }

  @override
  String get enlargeScreenshot => 'Ingrandisci screenshot';
}
