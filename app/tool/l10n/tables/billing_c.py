"""Billing package, part C: plan names by slug (the catalog's own names are Turkish; docs/ARCHITECTURE.md §11)."""
PACKAGE = 'billing'
DIR = 'packages/features/billing'


def r(key, tr, en, de, fr, nl, es, pt, it, ru, ar, az, uk, ph=None):
    return (key, ph, tr, en, de, fr, nl, es, pt, it, ru, ar, az, uk)


ROWS = [
    r('planNameFree', 'Ücretsiz', 'Free', 'Kostenlos', 'Gratuit', 'Gratis', 'Gratis', 'Grátis', 'Gratuito', 'Бесплатный', 'مجاني', 'Pulsuz', 'Безкоштовний'),
    r('planNameStarter', 'Başlangıç', 'Starter', 'Starter', 'Découverte', 'Starter', 'Inicial', 'Inicial', 'Base', 'Стартовый', 'المبتدئ', 'Başlanğıc', 'Стартовий'),
    r('planNameCommunity', 'Topluluk', 'Community', 'Community', 'Communauté', 'Community', 'Comunidad', 'Comunidade', 'Community', 'Сообщество', 'المجتمع', 'İcma', 'Спільнота'),
]
SKIP = {row[0] for row in ROWS}
