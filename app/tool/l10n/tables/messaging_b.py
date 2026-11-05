"""Messaging package, part B: the call's automatic key check (docs/ARCHITECTURE.md §8c, Güvenlik kodu)."""
PACKAGE = 'messaging'
DIR = 'packages/features/messaging'


def r(key, tr, en, de, fr, nl, es, pt, it, ru, ar, az, uk, ph=None):
    return (key, ph, tr, en, de, fr, nl, es, pt, it, ru, ar, az, uk)


ROWS = [
    r('callVerifying', 'Şifreleme doğrulanıyor…', 'Verifying encryption…', 'Verschlüsselung wird geprüft …', 'Vérification du chiffrement…',
      'Versleuteling wordt gecontroleerd…', 'Verificando el cifrado…', 'Verificando a criptografia…', 'Verifica della crittografia…',
      'Проверка шифрования…', 'جارٍ التحقق من التشفير…', 'Şifrələmə yoxlanılır…', 'Перевірка шифрування…'),
    r('callSecure', 'Güvenli görüşme', 'Secure call', 'Sicheres Gespräch', 'Appel sécurisé', 'Beveiligd gesprek', 'Llamada segura',
      'Chamada segura', 'Chiamata sicura', 'Защищённый звонок', 'مكالمة آمنة', 'Təhlükəsiz zəng', 'Захищений дзвінок'),
    r('callSecureDetail', 'Uçtan uca şifreli. İki telefonun güvenlik kodu eşleşti, araya kimse girmedi.',
      'End-to-end encrypted. Both phones’ security codes match; nobody is in between.',
      'Ende-zu-Ende-verschlüsselt. Die Sicherheitscodes beider Telefone stimmen überein, niemand hört mit.',
      'Chiffré de bout en bout. Les codes de sécurité des deux téléphones correspondent, personne ne s’est interposé.',
      'End-to-end versleuteld. De beveiligingscodes van beide telefoons komen overeen; niemand zit ertussen.',
      'Cifrado de extremo a extremo. Los códigos de seguridad de ambos teléfonos coinciden; nadie se ha interpuesto.',
      'Criptografia de ponta a ponta. Os códigos de segurança dos dois telefones coincidem; ninguém está no meio.',
      'Crittografia end-to-end. I codici di sicurezza dei due telefoni coincidono: nessuno si è intromesso.',
      'Сквозное шифрование. Коды безопасности обоих телефонов совпали, посторонних нет.',
      'مشفّرة من طرف إلى طرف. تطابق رمزا الأمان على الهاتفين، ولا أحد بينكما.',
      'Uçdan-uca şifrələnib. Hər iki telefonun təhlükəsizlik kodu uyğun gəldi, araya heç kim girmədi.',
      'Наскрізне шифрування. Коди безпеки обох телефонів збіглися, сторонніх немає.'),
    r('callCheckFailed', 'Şifreleme doğrulanamadı: iki telefonun güvenlik kodu eşleşmiyor. Aramayı bitirip yeniden ara.',
      'Encryption could not be verified: the two phones’ security codes don’t match. End the call and call again.',
      'Verschlüsselung nicht bestätigt: Die Sicherheitscodes der Telefone stimmen nicht überein. Beende das Gespräch und rufe erneut an.',
      'Chiffrement non vérifié : les codes de sécurité des deux téléphones ne correspondent pas. Raccroche et rappelle.',
      'Versleuteling niet bevestigd: de beveiligingscodes van de telefoons komen niet overeen. Beëindig het gesprek en bel opnieuw.',
      'No se pudo verificar el cifrado: los códigos de seguridad no coinciden. Cuelga y vuelve a llamar.',
      'Não foi possível verificar a criptografia: os códigos de segurança não coincidem. Encerre e ligue de novo.',
      'Impossibile verificare la crittografia: i codici di sicurezza non coincidono. Chiudi e richiama.',
      'Шифрование не подтверждено: коды безопасности телефонов не совпадают. Завершите звонок и позвоните снова.',
      'تعذّر التحقق من التشفير: رمزا الأمان على الهاتفين غير متطابقين. أنهِ المكالمة واتصل مرة أخرى.',
      'Şifrələmə təsdiqlənmədi: telefonların təhlükəsizlik kodu uyğun gəlmir. Zəngi bitirib yenidən zəng et.',
      'Шифрування не підтверджено: коди безпеки телефонів не збігаються. Завершіть дзвінок і зателефонуйте знову.'),
    r('showSecurityCode', 'Güvenlik kodunu göster', 'Show security code', 'Sicherheitscode anzeigen', 'Afficher le code de sécurité',
      'Beveiligingscode tonen', 'Mostrar código de seguridad', 'Mostrar código de segurança', 'Mostra codice di sicurezza',
      'Показать код безопасности', 'إظهار رمز الأمان', 'Təhlükəsizlik kodunu göstər', 'Показати код безпеки'),
]
SKIP = {row[0] for row in ROWS}
