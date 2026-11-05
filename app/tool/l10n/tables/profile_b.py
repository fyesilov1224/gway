"""Profile package, part B: the block confirmation snackbar (docs/ARCHITECTURE.md §11)."""
PACKAGE = 'profile'
DIR = 'packages/features/profile'


def r(key, tr, en, de, fr, nl, es, pt, it, ru, ar, az, uk, ph=None):
    return (key, ph, tr, en, de, fr, nl, es, pt, it, ru, ar, az, uk)


ROWS = [
    r('blockedUser', '{username} engellendi.', '{username} is blocked.', '{username} ist blockiert.', '{username} est bloqué.',
      '{username} is geblokkeerd.', '{username} está bloqueado.', '{username} foi bloqueado.', '{username} è bloccato.',
      '{username} заблокирован(а).', 'تم حظر {username}.', '{username} bloklandı.', '{username} заблоковано.', ph=['username']),
]
SKIP = {row[0] for row in ROWS}
