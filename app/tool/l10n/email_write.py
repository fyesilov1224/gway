"""Writes the sign-in e-mail templates in 12 languages to supabase/templates (docs/ARCHITECTURE.md §11, Sunucu).

Usage: python tool/l10n/email_write.py

The template picks the language from the account's metadata (`locale`, written by the app); without it Turkish.
"""
import html, pathlib

repo = pathlib.Path(__file__).resolve().parents[3]
langs = ['tr', 'en', 'de', 'fr', 'nl', 'es', 'pt', 'it', 'ru', 'ar', 'az', 'uk']

# Per template: (heading, sentence, button, note), one tuple per language in `langs` order.
TEMPLATES = {
    'confirmation': [
        ("GWAY'e hoş geldin", 'Hesabını açmak için e-posta adresini doğrula.', 'E-postamı doğrula', 'Bu hesabı sen açmadıysan bu e-postayı yok sayabilirsin.'),
        ('Welcome to GWAY', 'Verify your email address to open your account.', 'Verify my email', "If you didn't create this account, you can ignore this email."),
        ('Willkommen bei GWAY', 'Bestätige deine E-Mail-Adresse, um dein Konto zu eröffnen.', 'E-Mail bestätigen', 'Wenn du dieses Konto nicht erstellt hast, ignoriere diese E-Mail.'),
        ('Bienvenue sur GWAY', 'Confirme ton adresse e-mail pour ouvrir ton compte.', 'Confirmer mon e-mail', "Si tu n'as pas créé ce compte, ignore cet e-mail."),
        ('Welkom bij GWAY', 'Bevestig je e-mailadres om je account te openen.', 'Mijn e-mail bevestigen', 'Heb je dit account niet gemaakt? Negeer deze e-mail dan.'),
        ('Te damos la bienvenida a GWAY', 'Verifica tu correo para abrir tu cuenta.', 'Verificar mi correo', 'Si no creaste esta cuenta, ignora este correo.'),
        ('Boas-vindas ao GWAY', 'Confirme seu e-mail para abrir sua conta.', 'Confirmar meu e-mail', 'Se você não criou esta conta, ignore este e-mail.'),
        ('Benvenuto su GWAY', 'Conferma il tuo indirizzo email per aprire l’account.', 'Conferma la mia email', 'Se non hai creato tu questo account, ignora questa email.'),
        ('Добро пожаловать в GWAY', 'Подтвердите адрес почты, чтобы открыть аккаунт.', 'Подтвердить почту', 'Если вы не создавали аккаунт, просто проигнорируйте письмо.'),
        ('مرحبًا بك في GWAY', 'أكّد بريدك الإلكتروني لفتح حسابك.', 'تأكيد بريدي', 'إن لم تنشئ هذا الحساب فتجاهل هذه الرسالة.'),
        ('GWAY-ə xoş gəldin', 'Hesabını açmaq üçün e-poçt ünvanını təsdiqlə.', 'E-poçtumu təsdiqlə', 'Bu hesabı sən açmamısansa, bu e-poçtu nəzərə alma.'),
        ('Ласкаво просимо до GWAY', 'Підтвердьте адресу пошти, щоб відкрити обліковий запис.', 'Підтвердити пошту', 'Якщо ви не створювали обліковий запис, просто проігноруйте лист.'),
    ],
    'recovery': [
        ('Şifreni yenile', 'Yeni bir şifre belirlemek için aşağıdaki bağlantıyı kullan.', 'Yeni şifre belirle', 'Bu isteği sen yapmadıysan bu e-postayı yok sayabilirsin; şifren değişmez.'),
        ('Reset your password', 'Use the link below to set a new password.', 'Set a new password', "If you didn't ask for this, ignore this email; your password won't change."),
        ('Passwort zurücksetzen', 'Lege über den Link unten ein neues Passwort fest.', 'Neues Passwort festlegen', 'Wenn du das nicht angefordert hast, ignoriere diese E-Mail; dein Passwort bleibt.'),
        ('Réinitialise ton mot de passe', 'Utilise le lien ci-dessous pour choisir un nouveau mot de passe.', 'Choisir un nouveau mot de passe', "Si tu n'as rien demandé, ignore cet e-mail ; ton mot de passe ne change pas."),
        ('Stel je wachtwoord opnieuw in', 'Gebruik de link hieronder om een nieuw wachtwoord in te stellen.', 'Nieuw wachtwoord instellen', 'Heb je dit niet gevraagd? Negeer deze e-mail; je wachtwoord blijft hetzelfde.'),
        ('Restablece tu contraseña', 'Usa el enlace de abajo para crear una contraseña nueva.', 'Crear contraseña nueva', 'Si no lo pediste, ignora este correo; tu contraseña no cambiará.'),
        ('Redefina sua senha', 'Use o link abaixo para criar uma nova senha.', 'Criar nova senha', 'Se você não pediu isso, ignore este e-mail; sua senha não muda.'),
        ('Reimposta la password', 'Usa il link qui sotto per impostare una nuova password.', 'Imposta nuova password', 'Se non l’hai chiesto tu, ignora questa email; la password non cambia.'),
        ('Сброс пароля', 'Перейдите по ссылке ниже, чтобы задать новый пароль.', 'Задать новый пароль', 'Если вы не запрашивали сброс, проигнорируйте письмо — пароль не изменится.'),
        ('إعادة تعيين كلمة المرور', 'استخدم الرابط أدناه لتعيين كلمة مرور جديدة.', 'تعيين كلمة مرور جديدة', 'إن لم تطلب ذلك فتجاهل هذه الرسالة؛ لن تتغير كلمة مرورك.'),
        ('Şifrəni yenilə', 'Yeni şifrə təyin etmək üçün aşağıdakı linkdən istifadə et.', 'Yeni şifrə təyin et', 'Bu istəyi sən etməmisənsə, bu e-poçtu nəzərə alma; şifrən dəyişmir.'),
        ('Скидання пароля', 'Перейдіть за посиланням нижче, щоб задати новий пароль.', 'Задати новий пароль', 'Якщо ви не запитували скидання, проігноруйте лист — пароль не зміниться.'),
    ],
    'email_change': [
        ('E-posta değişikliğini onayla', 'Hesabının e-posta adresini değiştirmek için onayla.', 'Değişikliği onayla', 'Bu isteği sen yapmadıysan destek ekibine yaz.'),
        ('Confirm your email change', "Confirm to change your account's email address.", 'Confirm the change', "If you didn't ask for this, write to the support team."),
        ('E-Mail-Änderung bestätigen', 'Bestätige, um die E-Mail-Adresse deines Kontos zu ändern.', 'Änderung bestätigen', 'Wenn du das nicht angefordert hast, schreib dem Support.'),
        ("Confirme le changement d'e-mail", "Confirme pour changer l'adresse e-mail de ton compte.", 'Confirmer le changement', "Si tu n'as rien demandé, écris à l'assistance."),
        ('Bevestig je e-mailwijziging', 'Bevestig om het e-mailadres van je account te wijzigen.', 'Wijziging bevestigen', 'Heb je dit niet gevraagd? Schrijf dan support.'),
        ('Confirma el cambio de correo', 'Confirma para cambiar el correo de tu cuenta.', 'Confirmar el cambio', 'Si no lo pediste, escribe a soporte.'),
        ('Confirme a troca de e-mail', 'Confirme para trocar o e-mail da sua conta.', 'Confirmar a troca', 'Se você não pediu isso, escreva para o suporte.'),
        ("Conferma il cambio di email", "Conferma per cambiare l'indirizzo email dell'account.", 'Conferma il cambio', 'Se non l’hai chiesto tu, scrivi al supporto.'),
        ('Подтвердите смену почты', 'Подтвердите, чтобы изменить адрес почты аккаунта.', 'Подтвердить смену', 'Если вы этого не запрашивали, напишите в поддержку.'),
        ('أكّد تغيير البريد الإلكتروني', 'أكّد لتغيير البريد الإلكتروني لحسابك.', 'تأكيد التغيير', 'إن لم تطلب ذلك فراسل فريق الدعم.'),
        ('E-poçt dəyişikliyini təsdiqlə', 'Hesabının e-poçt ünvanını dəyişmək üçün təsdiqlə.', 'Dəyişikliyi təsdiqlə', 'Bu istəyi sən etməmisənsə, dəstək komandasına yaz.'),
        ('Підтвердьте зміну пошти', 'Підтвердьте, щоб змінити адресу пошти облікового запису.', 'Підтвердити зміну', 'Якщо ви цього не запитували, напишіть у підтримку.'),
    ],
}


def body(lang, heading, sentence, button, note):
    e = html.escape
    rtl = ' dir="rtl"' if lang == 'ar' else ''
    return (f'<div lang="{lang}"{rtl} style="font-family:sans-serif;color:#1F2033;max-width:480px;margin:0 auto;padding:24px">\n'
            f'  <h2 style="font-size:20px">{e(heading)}</h2>\n'
            f'  <p style="color:#5C5F77">{e(sentence)}</p>\n'
            f'  <p><a href="{{{{ .ConfirmationURL }}}}" style="display:inline-block;background:#6E56CF;color:#FFFFFF;padding:12px 20px;'
            f'border-radius:12px;text-decoration:none">{e(button)}</a></p>\n'
            f'  <p style="color:#5C5F77;font-size:13px">{e(note)}</p>\n'
            f'</div>\n')


out = repo / 'supabase' / 'templates'
out.mkdir(exist_ok=True)
for name, rows in TEMPLATES.items():
    assert len(rows) == len(langs), name
    parts = ['{{ $l := or .Data.locale "tr" }}\n']
    for i, (lang, row) in enumerate(zip(langs[1:], rows[1:])):
        parts.append(('{{ if' if i == 0 else '{{ else if') + f' eq $l "{lang}" }}}}\n' + body(lang, *row))
    parts.append('{{ else }}\n' + body('tr', *rows[0]) + '{{ end }}\n')
    (out / f'{name}.html').write_text(''.join(parts), encoding='utf-8', newline='\n')
print('templates:', ', '.join(TEMPLATES))
