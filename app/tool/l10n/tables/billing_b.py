"""Billing package, part B: the translated agreement at checkout (docs/ARCHITECTURE.md §11, Hukuki metin çevirileri)."""
PACKAGE = 'billing'
DIR = 'packages/features/billing'


def r(key, tr, en, de, fr, nl, es, pt, it, ru, ar, az, uk, ph=None):
    return (key, ph, tr, en, de, fr, nl, es, pt, it, ru, ar, az, uk)


ROWS = [
    r('termsTranslationNote', 'Bu çeviri bilgi amaçlıdır. Bağlayıcı olan ve onayladığın sözleşme Türkçe asıldır.',
      'This translation is for information. The binding agreement, and the one you accept, is the Turkish original.',
      'Diese Übersetzung dient nur zur Information. Verbindlich ist der türkische Originalvertrag; ihm stimmst du zu.',
      "Cette traduction est fournie à titre d'information. Le contrat qui fait foi, et que tu acceptes, est l'original turc.",
      'Deze vertaling is ter informatie. Bindend, en waarmee je akkoord gaat, is de Turkse originele overeenkomst.',
      'Esta traducción es informativa. El contrato vinculante, y el que aceptas, es el original en turco.',
      'Esta tradução é informativa. O contrato vinculante, e o que você aceita, é o original em turco.',
      "Questa traduzione è informativa. Il contratto vincolante, e quello che accetti, è l'originale in turco.",
      'Перевод носит информационный характер. Юридическую силу имеет турецкий оригинал договора — именно его вы принимаете.',
      'هذه الترجمة للعلم فقط. العقد الملزم، والذي توافق عليه، هو الأصل التركي.',
      'Bu tərcümə məlumat xarakterlidir. Bağlayıcı olan və təsdiqlədiyin müqavilə türkcə orijinaldır.',
      'Переклад має інформаційний характер. Юридичну силу має турецький оригінал договору — саме його ви приймаєте.'),
    r('showOriginal', 'Türkçe aslını göster', 'Show the Turkish original', 'Türkisches Original anzeigen', "Afficher l'original turc", 'Turks origineel tonen', 'Ver el original en turco',
      'Ver o original em turco', "Mostra l'originale in turco", 'Показать турецкий оригинал', 'عرض الأصل التركي', 'Türkcə orijinalı göstər', 'Показати турецький оригінал'),
    r('showTranslation', 'Çeviriyi göster', 'Show the translation', 'Übersetzung anzeigen', 'Afficher la traduction', 'Vertaling tonen', 'Ver la traducción', 'Ver a tradução',
      'Mostra la traduzione', 'Показать перевод', 'عرض الترجمة', 'Tərcüməni göstər', 'Показати переклад'),
]
SKIP = {row[0] for row in ROWS}
