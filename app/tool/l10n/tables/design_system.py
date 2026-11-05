PACKAGE = 'design_system'
DIR = 'packages/design_system'

KEYS = [
    ('loadingLabel', 'Screen reader label of a busy button', ['label']),
    ('previous', 'Scroll a chip rail back', None),
    ('next', 'Scroll a chip rail forward', None),
    ('coverPhoto', 'Screen reader label of a cover image', None),
    ('retry', 'Error state action', None),
    ('liveBroadcast', 'Screen reader label of the live badge', None),
    ('liveBadge', 'Short upper-case live badge text', None),
]

T = {
    'tr': ['{label}, yükleniyor', 'Öncekiler', 'Sonrakiler', 'Kapak fotoğrafı', 'Tekrar dene', 'Canlı yayın', 'CANLI'],
    'en': ['{label}, loading', 'Previous', 'Next', 'Cover photo', 'Try again', 'Live broadcast', 'LIVE'],
    'de': ['{label}, wird geladen', 'Zurück', 'Weiter', 'Titelbild', 'Erneut versuchen', 'Livestream', 'LIVE'],
    'fr': ['{label}, chargement', 'Précédents', 'Suivants', 'Photo de couverture', 'Réessayer', 'Diffusion en direct', 'DIRECT'],
    'nl': ['{label}, wordt geladen', 'Vorige', 'Volgende', 'Omslagfoto', 'Opnieuw proberen', 'Livestream', 'LIVE'],
    'es': ['{label}, cargando', 'Anteriores', 'Siguientes', 'Foto de portada', 'Reintentar', 'Transmisión en directo', 'EN VIVO'],
    'pt': ['{label}, carregando', 'Anteriores', 'Próximos', 'Foto de capa', 'Tentar novamente', 'Transmissão ao vivo', 'AO VIVO'],
    'it': ['{label}, caricamento', 'Precedenti', 'Successivi', 'Foto di copertina', 'Riprova', 'Diretta', 'LIVE'],
    'ru': ['{label}, загрузка', 'Назад', 'Далее', 'Обложка', 'Повторить', 'Прямой эфир', 'ЭФИР'],
    'ar': ['{label}، جارٍ التحميل', 'السابق', 'التالي', 'صورة الغلاف', 'إعادة المحاولة', 'بث مباشر', 'مباشر'],
    'az': ['{label}, yüklənir', 'Əvvəlkilər', 'Sonrakılar', 'Örtük şəkli', 'Yenidən cəhd et', 'Canlı yayım', 'CANLI'],
    'uk': ['{label}, завантаження', 'Назад', 'Далі', 'Обкладинка', 'Повторити', 'Пряма трансляція', 'НАЖИВО'],
}
