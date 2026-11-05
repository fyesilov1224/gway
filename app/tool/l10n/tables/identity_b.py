"""Identity package, part B: legal text translations (docs/ARCHITECTURE.md §11, Hukuki metin çevirileri)."""
PACKAGE = 'identity'
DIR = 'packages/features/identity'


def r(key, tr, en, de, fr, nl, es, pt, it, ru, ar, az, uk, ph=None):
    return (key, ph, tr, en, de, fr, nl, es, pt, it, ru, ar, az, uk)


ROWS = [
    r('legalTranslationNote', 'Bu çeviri bilgi amaçlıdır. Bağlayıcı olan ve onayladığın metin Türkçe asıldır.',
      'This translation is for information. The binding text, and the one you accept, is the Turkish original.',
      'Diese Übersetzung dient nur zur Information. Verbindlich ist das türkische Original; ihm stimmst du zu.',
      "Cette traduction est fournie à titre d'information. Le texte qui fait foi, et que tu acceptes, est l'original turc.",
      'Deze vertaling is ter informatie. Bindend, en waarmee je akkoord gaat, is het Turkse origineel.',
      'Esta traducción es informativa. El texto vinculante, y el que aceptas, es el original en turco.',
      'Esta tradução é informativa. O texto vinculante, e o que você aceita, é o original em turco.',
      "Questa traduzione è informativa. Il testo vincolante, e quello che accetti, è l'originale in turco.",
      'Перевод носит информационный характер. Юридическую силу имеет турецкий оригинал — именно его вы принимаете.',
      'هذه الترجمة للعلم فقط. النص الملزم، والذي توافق عليه، هو الأصل التركي.',
      'Bu tərcümə məlumat xarakterlidir. Bağlayıcı olan və təsdiqlədiyin mətn türkcə orijinaldır.',
      'Переклад має інформаційний характер. Юридичну силу має турецький оригінал — саме його ви приймаєте.'),
    r('legalShowOriginal', 'Türkçe aslını göster', 'Show the Turkish original', 'Türkisches Original anzeigen', "Afficher l'original turc", 'Turks origineel tonen', 'Ver el original en turco',
      'Ver o original em turco', "Mostra l'originale in turco", 'Показать турецкий оригинал', 'عرض الأصل التركي', 'Türkcə orijinalı göstər', 'Показати турецький оригінал'),
    r('legalShowTranslation', 'Çeviriyi göster', 'Show the translation', 'Übersetzung anzeigen', 'Afficher la traduction', 'Vertaling tonen', 'Ver la traducción', 'Ver a tradução',
      'Mostra la traduzione', 'Показать перевод', 'عرض الترجمة', 'Tərcüməni göstər', 'Показати переклад'),
]
SKIP = {row[0] for row in ROWS}
