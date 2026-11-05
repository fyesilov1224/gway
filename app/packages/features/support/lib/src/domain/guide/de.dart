import '../guide.dart';

// German translation of tr.dart; keep chapters, topics, steps and notes in step with it.

const guideDe = <GuideChapter>[
  GuideChapter(
    id: 'start',
    title: 'Erste Schritte',
    summary: 'Registrierung, Anmeldung, Bestätigung und Orientierung in der App.',
    topics: [
      GuideTopic(
        'Was ist GWAY?',
        intro: 'GWAY ist eine soziale Plattform, die Gemeinschaften aller Art zusammenbringt: Wandern, Laufen, Radfahren, Musik, '
            'Natur, Sport, Kunst und mehr. Du trittst Gruppen bei, gehst zu Events, unterhältst dich in Live-Audio-Räumen '
            'und lernst neue Leute kennen.',
        notes: [
          'GWAY steht Personen ab 18 Jahren offen.',
          'Die App läuft auf dem Handy (Android, iOS) und im Webbrowser; dein Konto ist überall dasselbe.',
        ],
      ),
      GuideTopic(
        'Ein Konto erstellen',
        steps: [
          'Tippe auf dem Anmeldebildschirm auf „Registrieren“.',
          'Gib deine E-Mail-Adresse und ein Passwort ein. Du kannst dich auch mit Google oder Apple registrieren.',
          'Wenn du dich per E-Mail registriert hast, tippe auf den Bestätigungslink in deinem Posteingang. Ohne bestätigte E-Mail ist keine Anmeldung möglich.',
          'Nach der Anmeldung führt dich die App nacheinander durch die Sicherheitsprüfung, die Zustimmung zu den rechtlichen Dokumenten, dein Geburtsdatum und die Profilerstellung.',
        ],
        tip: 'Ist die Bestätigungs-E-Mail nicht angekommen, sieh im Spam-Ordner nach.',
      ),
      GuideTopic(
        'Ich habe mein Passwort vergessen',
        steps: [
          'Tippe auf dem Anmeldebildschirm auf „Passwort vergessen“.',
          'Gib die E-Mail-Adresse deines Kontos ein.',
          'Lege mit dem Link in der E-Mail ein neues Passwort fest.',
        ],
      ),
      GuideTopic(
        'Sicherheitsprüfung: Standort, Telefon und zweiter Schritt',
        intro: 'Um Fake-Konten zu verhindern, kann die App diese Schritte von dir verlangen.',
        steps: [
          'Standort: Die App fragt nach der Standortberechtigung. Ohne sie öffnet sich die App nicht; du siehst einen Bildschirm, der zu den Einstellungen führt. '
              'Dein Standort dient nur der Kontosicherheit und wird niemandem gezeigt.',
          'Telefon: Du gibst eine Nummer aus dem Land ein, in dem du bist, und den Code aus der SMS. Das passiert einmal; eine Nummer kann nur für ein Konto verwendet werden.',
          'Zweiter Schritt: Bei jeder neuen Anmeldung kommt ein SMS-Code an deine registrierte Nummer. Hast du eine Authenticator-App oder einen Fingerabdruck eingerichtet, nutzt du diese.',
        ],
        tip: 'Nimmst du nach der Telefonbestätigung den Vorschlag „Fingerabdruck hinzufügen“ oder „Google Authenticator hinzufügen“ an, geht die nächste Anmeldung schneller. SMS bleibt als Reserve.',
      ),
      GuideTopic(
        'Rechtliche Dokumente und Geburtsdatum',
        intro: 'Du musst den Nutzungsbedingungen, der Datenschutzinformation, der ausdrücklichen Einwilligung und den Community-Richtlinien zustimmen.',
        steps: [
          'Öffne jedes Dokument und scrolle bis zum Ende. Erst danach lässt sich das Kästchen ankreuzen.',
          'Tippe am Ende des Dokuments auf „Gelesen und akzeptiert“.',
          'Gib dein Geburtsdatum ein. Es wird niemandem gezeigt und kann später nicht geändert werden; hast du dich vertippt, schreib dem Support-Team.',
        ],
        notes: ['Erscheint eine neue Version eines Dokuments, bittet dich die App erneut um Zustimmung.'],
      ),
      GuideTopic(
        'Dein Profil erstellen',
        steps: [
          'Wähle einen Nutzernamen: 3–30 Zeichen; Kleinbuchstaben, Ziffern, Unterstrich und Punkt sind erlaubt.',
          'Füge deinen Anzeigenamen und ein Profilfoto hinzu.',
          'Wähle deine Interessen (höchstens 10). Gruppen und Vorschläge richten sich danach.',
        ],
        notes: ['Deinen Nutzernamen kannst du alle 30 Tage einmal ändern.'],
      ),
      GuideTopic(
        'Dich in der App zurechtfinden',
        intro: 'Die Leiste unten hat vier Tabs und in der Mitte eine „+“-Taste.',
        notes: [
          'Heute: Live-Übertragungen von jetzt, bald startende Events und Beiträge der Leute, denen du folgst. Oben rechts sind Suchen, Benachrichtigungen und Nachrichten.',
          'Gruppen: Gruppen suchen und entdecken. Oben rechts sind Gruppenliga und Karte.',
          'Kalender: Events, an denen du teilnimmst, und Events deiner Gruppen.',
          'Ich: dein eigenes Profil. Oben rechts sind Benachrichtigungen, Gespeichert, Matching, Teammitglieder finden, Jahresrückblick und Einstellungen.',
          'Die „+“-Taste: Heute Abend, Demnächst sowie Beitrag, Story und Gruppe erstellen.',
          'Auf großen Bildschirmen (Web, Tablet) sind dieselben Bereiche im Menü links, darunter die Gruppen, in denen du Mitglied bist.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'profile',
    title: 'Profil und Folgen',
    summary: 'Profil bearbeiten, Privatsphäre, Folgen, Blockieren, Abzeichen.',
    topics: [
      GuideTopic(
        'Mein Profil bearbeiten',
        steps: [
          'Tippe im Tab Ich oben rechts auf Einstellungen, dann auf „Profil bearbeiten“.',
          'Ändere Profilfoto, Titelbild, Anzeigenamen, Bio und Interessen.',
          'Speichern.',
        ],
        notes: ['Bilder dürfen höchstens 5 MB groß sein (JPEG, PNG oder WebP).'],
      ),
      GuideTopic(
        'Privates Konto',
        intro: 'Ist Einstellungen → „Privates Konto“ aktiv, sehen nur Follower, die du bestätigt hast, deine Beiträge und Storys.',
        notes: [
          'Bei einem privaten Konto senden Leute, die dir folgen möchten, eine Anfrage; du bestätigst oder lehnst sie oben auf dem Benachrichtigungsbildschirm ab. Abgelehnte erfahren nichts davon.',
          'Machst du dein Konto wieder öffentlich, werden offene Anfragen automatisch bestätigt.',
        ],
      ),
      GuideTopic(
        'Meine Gruppen im Profil zeigen',
        intro: 'Einstellungen → „Meine Gruppen im Profil zeigen“ ist standardmäßig aus.',
        notes: [
          'Solange es aus ist, sehen nur die Mitglieder einer Gruppe, dass du dort Mitglied bist. Ein Admin einer anderen Gruppe sieht nicht, in welchen Gruppen du bist.',
          'Schaltest du es ein, sind deine Mitgliedschaften in deinem Profil für alle sichtbar.',
          'Gruppen, in deren Leitung du bist (Inhaber:in, Admin, Gremium, Moderation), sind immer öffentlich.',
        ],
      ),
      GuideTopic(
        'Folgen und Freunde',
        steps: [
          'Tippe in einem Profil auf „Folgen“. Ist das Konto privat, geht eine Anfrage raus; nach der Annahme folgst du.',
          'Tippe erneut auf dieselbe Taste, um nicht mehr zu folgen oder die Anfrage zurückzuziehen.',
        ],
        notes: [
          'Folgt ihr euch gegenseitig, steht im Profil „Freund“.',
          'Du kannst jemanden, der dir folgt, aus deiner Follower-Liste entfernen.',
          'Folgen erlaubt keine Nachrichten; Direktnachrichten gibt es zwischen Matches und Teammitgliedern.',
          'Du kannst auch Gruppen folgen; Beiträge von Gruppen, in denen du bist, erscheinen ohnehin in deinem Feed.',
        ],
      ),
      GuideTopic(
        'Jemanden blockieren',
        steps: [
          'Öffne im Profil der Person oben rechts das Menü „Weitere Optionen“.',
          'Tippe auf „Blockieren“.',
        ],
        notes: [
          'Folgen und Anfragen in beide Richtungen werden gelöscht. Ihr seht gegenseitig keine Profile, Beiträge und Kommentare mehr; ihr könnt euch nicht schreiben und nicht erwähnen.',
          'Die blockierte Person erscheint auch nicht mehr in deinem Matching-Stapel und in Teamvorschlägen.',
          'Blockierte Personen findest du unter Einstellungen → „Blockierte Konten“; dort hebst du die Blockierung auf. Danach kommt das Folgen nicht automatisch zurück.',
        ],
      ),
      GuideTopic(
        'Beiträge und Abzeichen',
        intro: 'Die Beiträge in deinem Profil zählen, was du im echten Leben tust; Likes, Follower und Beitragszahlen zählen nicht.',
        notes: [
          'Teilnahme: beendete Events, an denen du teilgenommen hast und nicht als „nicht erschienen“ markiert wurdest.',
          'Organisation: Events, die du erstellt hast und an denen außer dir mindestens 2 Personen teilgenommen haben.',
          'Erinnerung: Beiträge, die du mit einem Event verknüpft geteilt hast.',
          'Beispiele für Abzeichen: Erster Schritt (1 Teilnahme), Stammgast (10), Weggefährte (25), Entdecker (3 verschiedene Gruppen), Organisator, Erinnerungssammler, Feedbackgeber, „<Kategorie>-Fan“, Willkommens- und Handschlag-Abzeichen sowie erreichte Ziele.',
          'Es gibt keine Ranglisten und keine „Besten“-Listen.',
        ],
      ),
      GuideTopic(
        'Gespeichert und Story-Archiv',
        notes: [
          'Um einen Beitrag zu speichern, tippe auf das Speichern-Symbol auf seiner Karte. Gespeichertes siehst nur du: Ich → Gespeichert oder Einstellungen → Gespeichert.',
          'Abgelaufene Storys werden nicht gelöscht, sie bleiben unter Einstellungen → „Story-Archiv“.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'feed',
    title: 'Heute, Beiträge und Storys',
    summary: 'Teilen, Likes, Kommentare, Entdecken und Suche.',
    topics: [
      GuideTopic(
        'Der Bildschirm Heute',
        notes: [
          'Ganz oben „Jetzt live“: Live-Übertragungen in deinen Gruppen. Tippe auf die Karte, um beizutreten.',
          'Danach „Startet bald“: Events in den nächsten Stunden; zuerst die deiner Gruppen, dann die in den Provinzen deiner Gruppen.',
          'Darunter der Feed: deine Beiträge, Beiträge von Leuten, denen du folgst, und von Gruppen, denen du folgst oder in denen du bist, neueste zuerst.',
          'Zum Aktualisieren ziehst du den Bildschirm nach unten.',
        ],
      ),
      GuideTopic(
        'Einen Beitrag teilen',
        steps: [
          'Tippe unten auf die „+“-Taste, dann auf „Beitrag“.',
          'Wähle bis zu 10 Fotos oder Videos. Ein Video darf höchstens 60 Sekunden lang und 50 MB groß sein.',
          'Wähle für Fotos das Seitenverhältnis (Original, 1:1, 4:5, 1,91:1) und passe den Ausschnitt an.',
          'Schreib eine Beschreibung. Du kannst #Hashtags hinzufügen und jemanden mit @Nutzername erwähnen.',
          'Schalte bei Bedarf Kommentare aus oder blende die Like-Zahl aus, dann teile.',
        ],
        notes: [
          'Standortdaten deiner Fotos werden vor dem Hochladen entfernt.',
          'Du kannst einen Beitrag später bearbeiten; nur Beschreibung und Optionen ändern sich. Löschst du ihn, werden auch seine Medien gelöscht.',
          'Um in einer Gruppe zu posten, teile über die Gruppenseite. Jedes Mitglied kann posten; stummgeschaltete Mitglieder nicht.',
        ],
      ),
      GuideTopic(
        'Likes, Reaktionen und Kommentare',
        notes: [
          'Du kannst einen Beitrag liken oder mit 😍 😂 😮 👏 🔥 🙏 reagieren. Deine Reaktion kannst du ändern oder zurücknehmen.',
          'Wer einen Beitrag sehen kann, kann kommentieren – außer die Autorin oder der Autor hat Kommentare ausgeschaltet.',
          'Du kannst auf Kommentare antworten und Kommentare liken. Antworten haben nur eine Ebene.',
          'Deine eigenen Kommentare und Kommentare unter deinen Beiträgen löschst du selbst. Bei Gruppenbeiträgen können auch Inhaber:in und Admins der Gruppe Kommentare löschen.',
        ],
      ),
      GuideTopic(
        'Eine Story teilen',
        steps: [
          'Tippe auf „+“ → „Story“.',
          'Wähle ein Foto oder ein Video bis 60 Sekunden und teile es.',
        ],
        notes: [
          'Eine Story ist 24 Stunden sichtbar und wandert dann in dein Archiv.',
          'Wer deine Story gesehen hat, siehst nur du.',
          'Füge Storys zu Highlights hinzu, damit sie dauerhaft in deinem Profil bleiben.',
        ],
      ),
      GuideTopic(
        'Entdecken und Suche',
        steps: [
          'Tippe oben rechts auf dem Bildschirm Heute auf Suchen.',
          'Suche nach Personen oder #Hashtags. Für Gruppen nutzt du den Tab Gruppen.',
        ],
        notes: [
          'Entdecken zeigt die Beiträge der letzten zwei Wochen mit der meisten Interaktion aus öffentlichen Konten und Gruppen, denen du nicht folgst.',
          'Du kannst den Link zu einem Beitrag teilen; wer ihn öffnet, sieht ihn, wenn er dazu berechtigt ist.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'groups',
    title: 'Gruppen',
    summary: 'Gruppen finden, beitreten, Rollen und die Gruppenseite.',
    topics: [
      GuideTopic(
        'Eine Gruppe finden',
        notes: [
          'Suche im Tab Gruppen nach Namen oder wähle eine Kategorie.',
          'Mit der Taste Karte oben rechts siehst du Gruppen und Events in deiner Nähe auf der Karte.',
          'Mit der Gruppenliga siehst du die Gruppen mit den besten Events in deiner Kategorie und Provinz.',
          'Jede aktive Gruppe hat eine öffentliche Seite; geheime Gruppen gibt es nicht.',
        ],
      ),
      GuideTopic(
        'Einer Gruppe beitreten',
        intro: 'Die Beitrittsart der Gruppe steht auf der Taste:',
        notes: [
          'Offen: Tippe auf „Beitreten“ und du bist sofort Mitglied.',
          'Auf Anfrage: Du sendest eine Anfrage; ein Admin der Gruppe bestätigt sie. Du kannst sie zurückziehen.',
          'Auf Einladung: Ein Admin lädt dich über deinen Nutzernamen ein; du nimmst auf dem Benachrichtigungsbildschirm an oder lehnst ab.',
          'Einladungslink: Öffne den Link, den du bekommen hast, und tippe auf „Gruppe beitreten“ – dann bist du Mitglied, egal welche Beitrittsart gilt.',
          'Ist das Mitgliederlimit des Gruppenpakets erreicht, kann niemand Neues beitreten.',
        ],
        tip: 'Wenn du deiner ersten Gruppe beitrittst, bekommst du einmalig 30 Tage lang das persönliche Paket „Alles in einem“ zum Testen (Matching- und Teamfunktionen).',
      ),
      GuideTopic(
        'Eine Gruppe verlassen',
        steps: [
          'Tippe auf der Gruppenseite auf die Mitgliedschaftstaste.',
          'Wähle „Gruppe verlassen“.',
        ],
        notes: [
          'Deine Rollen werden gelöscht und deine Teilnahme an kommenden Events der Gruppe entfällt.',
          'Inhaber:innen können die Gruppe nicht verlassen; zuerst muss die Inhaberschaft übertragen werden.',
        ],
      ),
      GuideTopic(
        'Was steht auf einer Gruppenseite?',
        notes: [
          'Titelbild, Logo, Beschreibung, Regeln, Links, Provinz und Kategorie.',
          'Live-Karte: laufende und geplante Übertragungen.',
          'Events, „Wie war’s?“-Bewertungen und die Durchschnittsbewertung der Gruppe.',
          'Umfragen, Ziele, Ligakarte und Gruppenbeiträge.',
          'Mitglieder: Das Leitungsteam ist öffentlich; die ganze Mitgliederliste sehen nur Mitglieder der Gruppe.',
          'Gruppenchat: Jede Gruppe hat einen einzigen Chat, den nur Mitglieder lesen und schreiben.',
        ],
      ),
      GuideTopic(
        'Rollen in der Gruppe',
        intro: 'Ein Mitglied kann mehrere Rollen haben. Die Zahl in Klammern ist der Rang.',
        notes: [
          'Inhaber:in (100): alles, Zahlung und Rollenvergabe.',
          'Admin (80): Inhalte, Events, Umfragen, Mitglieder bestätigen und einladen, Live-Übertragungen, Sperren ohne Abstimmung, Anfragen für Sprachanrufe.',
          'Disziplinargremium (60): stimmt über Disziplinarfälle ab; prüft Meldungen, Sofort-Stummschaltung, Live-Moderation.',
          'Moderation (50): Vorprüfung von Meldungen, Sofort-Stummschaltung, Live-Moderation.',
          'Mitglied (10): teilnehmen, posten, Live-Übertragungen beitreten.',
          'Rangregel: Niemand kann jemanden mit gleichem oder höherem Rang sanktionieren. Inhaber:innen können nicht gesperrt werden.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'group-admin',
    title: 'Gruppe gründen und leiten',
    summary: 'Für Inhaber:innen und Admins: Gruppe, Einladungen, Rollen, Pakete, Ziele.',
    topics: [
      GuideTopic(
        'Eine Gruppe gründen',
        steps: [
          'Tippe auf „+“ → „Gruppe“.',
          'Gib den Namen (3–60 Zeichen) und die Adresse ein. Die Adresse ist der Link der Seite (/g/adresse) und kann später nicht geändert werden.',
          'Wähle Kategorie und Provinz. Die Provinz wird für Karte und Gruppenliga gebraucht.',
          'Wähle die Beitrittsart: offen, auf Anfrage oder auf Einladung.',
          'Füge Logo, Titelbild, Beschreibung, Regeln und bis zu 5 Links hinzu.',
        ],
        notes: ['Wer die Gruppe gründet, ist Inhaber:in. Außerdem bekommt die Gruppe ihren eigenen Chat.'],
      ),
      GuideTopic(
        'Mitglieder aufnehmen und einladen',
        notes: [
          'In einer Gruppe mit Anfragen bestätigst oder lehnst du offene Anfragen auf der Gruppenseite ab (Inhaber:in und Admins).',
          'Du kannst Einladungen per Nutzername senden. Eine Gruppe kann in 24 Stunden höchstens 50 Einladungen senden; zurückgezogene zählen mit.',
          'Eine Einladung kannst du zurückziehen, solange sie nicht angenommen ist.',
        ],
      ),
      GuideTopic(
        'Einladungslink',
        intro: 'Der einfachste Weg, deine Gruppe aus WhatsApp oder Instagram herüberzuholen.',
        steps: [
          'Öffne auf der Gruppenseite den Bereich „Einladungslink“.',
          'Wähle die Gültigkeit (1, 7 oder 30 Tage); optional eine Nutzungsgrenze (1–1000 Personen).',
          'Teile den Link. Wer ihn öffnet, sich anmeldet und auf „Gruppe beitreten“ tippt, wird Mitglied.',
        ],
        notes: [
          'Eine Gruppe kann gleichzeitig höchstens 20 gültige Links haben.',
          'Du kannst einen Link jederzeit widerrufen; das lässt sich nicht rückgängig machen, du erstellst einfach einen neuen.',
          'Auf WhatsApp zeigt ein geteilter Link eine Vorschau mit Namen und Bild der Gruppe.',
        ],
      ),
      GuideTopic(
        'Rollen vergeben und Inhaberschaft übertragen',
        notes: [
          'Rollen vergibt und entzieht nur die Inhaberin oder der Inhaber: Admin, Disziplinargremium, Moderation. Rollen gehen nur an Mitglieder.',
          'Du kannst die Inhaberschaft an ein aktives Mitglied übertragen. Du bleibst normales Mitglied; die neue Inhaberin bzw. der neue Inhaber kann dir eine Rolle geben.',
          'Nur Inhaber:innen können die Gruppe löschen. Das Löschen ist endgültig.',
          'Solange du Inhaber:in einer Gruppe bist, kannst du dein Konto nicht löschen; übertrage zuerst die Inhaberschaft oder lösche die Gruppe.',
        ],
      ),
      GuideTopic(
        'Gruppenpakete',
        intro: 'Das Paket legt die maximale Mitgliederzahl, die monatlichen Events und die monatlichen Live-Minuten der Gruppe fest.',
        steps: [
          'Öffne auf der Gruppenseite die Karte „Paket“; dort siehst du aktuelles Paket, Limits und Nutzung.',
          'Kaufe das Paket im Web. Die mobile App zeigt nur den Paketstatus.',
        ],
        notes: [
          'Eine Gruppe ohne Abo nutzt die Limits des kostenlosen Pakets.',
          'Pakete sind im Voraus bezahlt (monatlich oder jährlich); es gibt keine automatische Verlängerung und keine gespeicherte Karte.',
          'Beim Upgrade wird deine Restzeit auf das neue Paket übertragen. Verlängerst du dasselbe Paket, wird die Zeit hinten angehängt.',
          'Zahlungen aus der Türkei laufen über PayTR in TL, aus dem Ausland über iyzico in USD.',
          'Ist das Mitgliederlimit erreicht, bleiben die Mitglieder, aber niemand Neues kann beitreten.',
          'Aktuelle Preise und Limits stehen auf dem Paketbildschirm. Das Paket kauft die Inhaberin oder der Inhaber.',
        ],
      ),
      GuideTopic(
        'Ziele und Aufgaben',
        intro: 'Vereint die Gruppe um ein gemeinsames Ziel. Ziele legen Inhaber:in und Admins an; die Belohnung ist ein Abzeichen, kein Geld und keine Punkte.',
        notes: [
          'Persönliches Ziel: Jedes Mitglied bekommt ein Abzeichen, wenn es seine eigene Zahl erreicht.',
          'Gruppenziel: Erreicht die Summe der Gruppe das Ziel, bekommen alle, die beigetragen haben, ein Abzeichen.',
          'Teamziel: Es werden Teams gebildet, gezählt wird die Summe pro Team.',
          'Aufgabe: Das Mitglied tippt auf „Erledigt“ und schreibt eine kurze Notiz; bestätigt ein Admin, gibt es ein Abzeichen.',
          'Gezählt werden: Teilnahme, Organisation oder Erinnerungen. Den Fortschritt berechnet der Server.',
        ],
      ),
      GuideTopic(
        'Den Gruppenchat verwalten',
        notes: [
          'Du kannst den Gruppenchat so einstellen, dass nur Admins schreiben (wie ein Ankündigungskanal).',
          'Wird eine unpassende Nachricht gemeldet, landet sie in der Moderation der Gruppe; Berechtigte können sie entfernen.',
        ],
      ),
      GuideTopic(
        'Anfragen für Sprachanrufe beantworten',
        intro: 'Mitglieder beantragen die Berechtigung für Einzel-Sprachanrufe bei der Gruppe. Die Anfragen sehen Inhaber:in und Admins.',
        steps: [
          'Öffne auf der Gruppenseite „Anfragen für Sprachanrufe“.',
          'Schalte die Anfrage frei oder lehne sie mit Begründung ab.',
          'Eine erteilte Berechtigung kannst du jederzeit mit Begründung wieder ausschalten.',
        ],
        notes: ['Verlässt die Person die Gruppe, wird sie entfernt oder gesperrt, endet die Berechtigung automatisch.'],
      ),
    ],
  ),
  GuideChapter(
    id: 'events',
    title: 'Events',
    summary: 'Teilnahme, Warteliste, Willkommen, Handschlag, Bewertung.',
    topics: [
      GuideTopic(
        'An einem Event teilnehmen',
        steps: [
          'Öffne die Seite des Events (über die Gruppenseite, Heute, den Kalender oder die Karte).',
          'Lies Datum, Ort, Gebühreninfo, Teilnahmebedingungen und die benötigte Ausrüstung.',
          'Tippe auf „Teilnehmen“. Ist kein Platz frei, steht dort „Auf die Warteliste“.',
        ],
        notes: [
          'Events sieht jede:r, teilnehmen können nur Mitglieder der Gruppe.',
          'Stehst du auf der Warteliste, rückst du nach, sobald jemand absagt, und bekommst eine Benachrichtigung.',
          'Bei Events mit Freigabe steht „Teilnahme anfragen“; du nimmst teil, sobald die Organisation zustimmt.',
          'Zum Absagen tippst du auf „Absagen“; dein Platz geht an die erste Person auf der Warteliste.',
          'Nach dem Start des Events ist keine Anmeldung mehr möglich.',
        ],
      ),
      GuideTopic(
        'Teilnahmegebühr',
        intro: 'Die Gebühr wird nur zur Information angezeigt. GWAY nimmt keine Zahlungen an; du zahlst den Veranstaltenden so, wie sie es angeben (z. B. bar vor Ort).',
      ),
      GuideTopic(
        'Zum Kalender hinzufügen und Route',
        notes: [
          '„Zum Kalender hinzufügen“ trägt das Event in die Kalender-App deines Handys ein.',
          'Ist ein Treffpunkt markiert, öffnet „Route“ unter der kleinen Karte die Karten-App deines Geräts.',
        ],
      ),
      GuideTopic(
        'Zwei Events zur selben Zeit',
        intro: 'Hast du zur Zeit eines Events, an dem du teilnimmst, noch ein anderes Event, fragt dich die App, ob du beim anderen absagen und deinen Platz freigeben möchtest. Du entscheidest; nichts wird automatisch abgesagt.',
      ),
      GuideTopic(
        'Die Frage „Kommst du?“',
        intro: 'Weniger als 24 Stunden vor Beginn bekommst du eine Erinnerung und auf der Eventseite erscheint die Karte „Kommst du?“.',
        notes: [
          '„Ja, ich komme“: Die Organisation sieht, dass du kommst.',
          '„Ich kann nicht“: Du sagst ab; dein Platz geht an die erste Person auf der Warteliste.',
          'Antwortest du nicht, wirst du nicht von der Liste gestrichen.',
        ],
      ),
      GuideTopic(
        'Willkommen: wenn du zum ersten Mal kommst',
        intro: 'Gehst du zum ersten Mal zu einem Event einer Gruppe, kann dich ein freiwilliges Mitglied der Gruppe in Empfang nehmen.',
        steps: [
          'Melde dich zum Event an.',
          'Tippe im Willkommensbereich der Seite auf „Ich möchte empfangen werden“; optional schreibst du, woran man dich erkennt (z. B. „Ich trage eine rote Jacke“).',
          'Übernimmt jemand deine Anfrage, bekommst du den Treffpunkt (z. B. „Vor dem Café am Eingang, 08:45“) als Benachrichtigung.',
          'Nach dem Event kannst du dich bei der Person bedanken.',
        ],
        notes: [
          'Um selbst zu empfangen, melde dich zum Event an; offene Anfragen siehst du im Willkommensbereich. Pro Event kannst du bis zu 3 Personen empfangen.',
          'Willkommens-Abzeichen: Türöffner (1), Gastgeber (5), Herz der Community (20).',
        ],
      ),
      GuideTopic(
        'Überraschungsort',
        intro: 'Bei manchen Events ist der Ort eine Überraschung. Auf der Seite stehen nur ein Hinweis (z. B. „In Kadıköy, am Meer“) und wann der Ort verraten wird.',
        notes: [
          'Zur angegebenen Zeit wird der Ort den Teilnehmenden per Benachrichtigung verraten.',
          'Wer auf der Warteliste steht oder nicht teilnimmt, sieht den Ort nicht. Meldest du dich später an und die Zeit ist schon vorbei, siehst du ihn sofort.',
        ],
      ),
      GuideTopic(
        'Handschlag: Leute speichern, die du kennengelernt hast',
        intro: 'Zwei Teilnehmende desselben Events scannen gegenseitig ihren QR-Code und speichern so, dass sie sich kennengelernt haben.',
        steps: [
          'Von 1 Stunde vor Beginn bis 6 Stunden nach Ende erscheint auf der Seite die Karte „Handschlag“.',
          'Zeig deinen Code oder scanne den Code der anderen Person mit der Kamera. Ohne Kamera tippst du den 6-stelligen Code ein.',
        ],
        notes: [
          'Der Code ändert sich alle 3 Minuten; ein Foto davon nützt später nichts.',
          'Wen du kennengelernt hast, siehst nur du: Ich → Jahresrückblick → Leute, die ich getroffen habe. Im Profil steht nur die Anzahl.',
          'Ein Handschlag erlaubt keine Nachrichten.',
        ],
      ),
      GuideTopic(
        'Nach dem Event',
        notes: [
          'Danach bekommst du eine Bitte um Bewertung; vergib 1–5 Sterne. Die Bewertung der Gruppe ist der Durchschnitt dieser Bewertungen.',
          'Mit einem Beitrag, der mit dem Event verknüpft ist, fügst du deine Erinnerung hinzu; Erinnerungen zählen für Abzeichen und Ziele.',
          'Hast du teilgenommen, erscheint die Karte „Ich war auch dabei“; du kannst sie als Bild in eine Instagram-Story oder auf WhatsApp teilen. Auf der Karte sind keine Namen oder Gesichter anderer Teilnehmender.',
          'Vergangene Events der Gruppe findest du auf der Gruppenseite.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'event-admin',
    title: 'Events und Umfragen organisieren',
    summary: 'Für Inhaber:innen und Admins: Erstellen, Wiederholen, Freigabe, Absage, Umfrage.',
    topics: [
      GuideTopic(
        'Ein Event erstellen',
        steps: [
          'Tippe auf der Gruppenseite auf „Event erstellen“.',
          'Gib Titelbild, Titel, Beschreibung, Beginn und optional das Ende ein. Der Beginn muss mindestens 15 Minuten und höchstens 1 Jahr in der Zukunft liegen.',
          'Trag den Ort ein; optional markierst du den Treffpunkt mit einer Nadel auf der Karte oder fügst einen Online-Link hinzu.',
          'Füge Kapazität (leer lassen für unbegrenzt), Gebühreninfo, Teilnahmebedingungen und Ausrüstungsliste hinzu.',
          'Schalte bei Bedarf „Teilnahme mit Freigabe“ ein und speichere.',
        ],
        notes: [
          'Das Formular zeigt, wie viele Events dir diesen Monat noch bleiben. Abgesagte Events zählen zum Monatslimit deines Pakets.',
          'Das Formular zeigt auch, wie viele Events andere Gruppen derselben Kategorie an diesem Tag in deiner Provinz haben; du kannst das Datum ändern.',
        ],
      ),
      GuideTopic(
        'Wiederkehrendes Event',
        intro: 'Beim Erstellen wählst du unter „Wiederholen“ „Jede Woche“ oder „Alle zwei Wochen“ und startest so eine Serie (optional mit Enddatum, höchstens 1 Jahr).',
        notes: [
          'Eine Serie hält immer die nächsten 4 Wochen offen. Jeder Termin hat eigene Teilnehmende und eine eigene Warteliste.',
          'Bearbeitest du den letzten Termin, richten sich später geöffnete Termine danach.',
          'Mit „Wiederholung stoppen“ im Eventmenü beendest du die Serie; bereits geöffnete Termine bleiben, du kannst sie einzeln absagen.',
          'Ist das Monatslimit erreicht, öffnet sich der Termin nicht und du bekommst eine Benachrichtigung; wird das Limit frei, öffnet er sich.',
        ],
      ),
      GuideTopic(
        'Einen Überraschungsort einrichten',
        steps: [
          'Schalte im Formular „Überraschungsort“ ein.',
          'Schreib im Feld „Ort“ einen Hinweis; den echten Ort und Treffpunkt gibst du separat ein.',
          'Wähle, wann er verraten wird: 1, 3, 6, 12 oder 24 Stunden vor Beginn.',
        ],
        notes: ['Schaltest du die Überraschung aus, wird der geheime Ort gelöscht und „Ort“ wird zum normalen Ort.'],
      ),
      GuideTopic(
        'Teilnehmende verwalten',
        notes: [
          'Bei Teilnahme mit Freigabe bestätigst oder lehnst du offene Anfragen ab.',
          'In der Teilnehmerliste siehst du, wer „Kommst du?“ bestätigt hat.',
          'Nach dem Event markierst du Abwesende als „nicht erschienen“; Markierte zählen nicht als Teilnahme.',
          'Bearbeiten: Titel, Beschreibung, Zeit, Ort, Kapazität, Gebühr und Titelbild können sich ändern. Ändern sich Zeit oder Ort, werden die Teilnehmenden benachrichtigt. Die Kapazität kann nicht unter die Zahl der Angemeldeten sinken.',
          'Absage: Du sagst mit Begründung ab; Angemeldete und Wartende werden benachrichtigt. Vergangene Events können nicht bearbeitet werden.',
        ],
      ),
      GuideTopic(
        'Umfragen erstellen und abstimmen',
        steps: [
          'Tippe auf der Gruppenseite auf „Umfrage erstellen“ (Inhaber:in und Admins).',
          'Schreib die Frage und 2–10 Antwortmöglichkeiten.',
          'Optional erlaubst du Mehrfachauswahl, machst die Umfrage anonym, legst ein Ende fest oder verknüpfst sie mit einem Event.',
        ],
        notes: [
          'Umfragen und Ergebnisse sehen nur Mitglieder der Gruppe.',
          'Bei einer anonymen Umfrage sieht niemand, wer wofür gestimmt hat – auch nicht, wer sie erstellt hat.',
          'Ist eine Umfrage geschlossen, kann nicht mehr abgestimmt werden, die Ergebnisse bleiben. Berechtigte können eine Umfrage vorzeitig schließen oder löschen.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'calendar',
    title: 'Kalender, Heute Abend und Entdecken',
    summary: 'Kalender, Heute Abend frei, kleiner Tisch, Karte, Liga, Jahresrückblick.',
    topics: [
      GuideTopic(
        'Mein Kalender',
        notes: [
          'Der Tab Kalender zeigt Events, an denen du teilnimmst, auf deren Freigabe du wartest oder für die du auf der Warteliste stehst.',
          'Schaltest du „Events meiner Gruppen“ ein, siehst du auch alle Events deiner Gruppen.',
          'Du wechselst zwischen Tages-, Wochen- und Monatsansicht.',
          'Zeitlich überschneidende Events werden markiert.',
          'Über die Gruppenseite öffnest du auch den Kalender dieser Gruppe.',
        ],
      ),
      GuideTopic(
        'Heute Abend frei',
        steps: [
          'Tippe auf „+“ → „Heute Abend“.',
          'Schalte „Heute Abend frei“ ein; optional schreibst du eine kurze Notiz (z. B. „Kaffee, kleiner Spaziergang“).',
        ],
        notes: [
          'Deinen Status sehen nur Leute, die mindestens eine Gruppe mit dir teilen.',
          'Der Status schaltet sich um 04:00 Uhr automatisch aus; du kannst ihn auch jederzeit selbst ausschalten.',
        ],
      ),
      GuideTopic(
        'Kleiner Tisch',
        intro: 'Plant ein kleines Treffen mit Leuten, die heute Abend frei sind.',
        steps: [
          'Tippe auf der Seite „Heute Abend“ auf „Kleinen Tisch planen“.',
          'Die App wählt 3–5 Leute aus, die heute Abend frei sind und Gruppen mit dir teilen, und lädt sie ein.',
          'Mit denen, die annehmen, schreibst du im Chat des Tisches.',
        ],
        notes: [
          'Es müssen mindestens 2 Personen einladbar sein; sonst steht auf der Karte, wie viele noch fehlen.',
          'Pro Abend kannst du nur einem Tisch beitreten.',
          'Der Tisch schließt am nächsten Tag um 12:00 Uhr; der Chat bleibt lesbar, aber man kann nicht mehr schreiben.',
        ],
      ),
      GuideTopic(
        'Entdecken mit der Karte',
        steps: [
          'Tippe im Tab Gruppen oben rechts auf Karte.',
          'Verschiebe die Karte; filtere nach Kategorie, Zeit (heute, 7 Tage) und Entfernung von der Kartenmitte (5–50 km).',
          'Wähle die Karten- oder Listenansicht.',
        ],
        notes: [
          'Auf der Karte erscheinen nur kommende Events und aktive Gruppen. Dein Standort wird auf der Karte nicht verwendet und niemandem gezeigt.',
          'Ist die Karte vorübergehend aus, steht oben „Die Karte ist gerade nicht verfügbar.“',
        ],
      ),
      GuideTopic(
        'Gruppenliga',
        intro: 'Gruppen derselben Kategorie und Provinz sammeln jeden Monat Punkte mit guten Events.',
        notes: [
          'Punkte: jede teilnehmende Person, jedes Event mit mindestens 3 Teilnehmenden, jedes Willkommen und jede 4–5-Sterne-Bewertung.',
          'Bei Gleichstand liegt die Gruppe mit weniger Mitgliedern vorn.',
          'Zum Monatsende werden die Mitglieder der Top-3-Gruppen benachrichtigt; die Platzierungen stehen auf der Ligakarte der Gruppenseite.',
        ],
      ),
      GuideTopic(
        'Jahresrückblick und meine Entdeckerkarte',
        steps: [
          'Tippe im Tab Ich oben rechts auf Jahresrückblick.',
          'Wähle „Jahresrückblick“, „Meine Entdeckerkarte“ oder „Leute, die ich getroffen habe“.',
        ],
        notes: [
          'Jahresrückblick: Zahl deiner Events, Stunden insgesamt, besuchte Gruppen, Provinzen und Kategorien. Du kannst ihn als Story-Karte teilen.',
          'Meine Entdeckerkarte: Die Provinzen deiner Events füllen sich auf der Türkeikarte („7 / 81 Provinzen entdeckt“).',
          'Diese Seiten siehst nur du; niemand sonst, solange du sie nicht teilst.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'live',
    title: 'Live-Audio',
    summary: 'Beitreten, sprechen, Reaktionen, Übertragung starten und leiten.',
    topics: [
      GuideTopic(
        'Einer Übertragung beitreten',
        steps: [
          'Tippe auf die Karte „Jetzt live“ unter Heute, auf die Live-Karte der Gruppenseite oder auf die Benachrichtigung.',
          'Sobald du verbunden bist, siehst du, wer auf der Bühne ist und wer zuhört.',
        ],
        notes: ['Nur Mitglieder der Gruppe können beitreten. Wer aus einer Übertragung entfernt wurde, kommt nicht wieder hinein.'],
      ),
      GuideTopic(
        'Während der Übertragung in der App unterwegs',
        intro: 'Die Zurück-Taste oder der Pfeil nach unten oben links beendet die Übertragung für dich nicht; der Bildschirm wird kleiner und der Ton läuft weiter.',
        notes: [
          'Oben auf jeder Seite erscheint der Streifen „Du bist live“. Tippe darauf, um zurückzukehren.',
          'Bist du auf der Bühne, kannst du dein Mikro auch über den Streifen aus- und einschalten.',
          'Zum Verlassen tippst du im Übertragungsbildschirm auf „Verlassen“. Trittst du einer anderen Übertragung bei, verlässt du die vorherige.',
        ],
      ),
      GuideTopic(
        'Sprechen: Hand heben und Bühne',
        steps: [
          'Als Zuhörer:in hebst du mit der ✋-Taste die Hand.',
          'Holt dich ein Host auf die Bühne, erscheint deine Mikrotaste; tippe darauf und sprich.',
          'Um die Bühne selbst zu verlassen, tippe auf „Bühne verlassen“.',
        ],
        notes: [
          'Hat ein Host dein Mikro stummgeschaltet, kannst du es nicht selbst einschalten; nur ein Host kann es wieder freigeben.',
          'Um das Foto der sprechenden Person leuchtet ein Rand.',
        ],
      ),
      GuideTopic(
        'Reaktionen und Kommentare',
        notes: [
          'Mit der Reaktionstaste sendest du ❤️ 👏 😂 🔥 😮 🙌; sie fliegen über den Bildschirm und werden nicht gespeichert.',
          'Mit der Kommentartaste schreibst du Kommentare. Kommentare bleiben im Verlauf der Übertragung.',
          'Halte deinen eigenen Kommentar gedrückt, um ihn zu löschen; Kommentare anderer kannst du melden.',
        ],
      ),
      GuideTopic(
        'Eine Übertragung starten',
        intro: 'Inhaber:in und Admins der Gruppe starten Übertragungen.',
        steps: [
          'Tippe auf der Live-Karte der Gruppenseite auf „Übertragung starten“.',
          'Gib einen Titel ein. Starte sofort oder plane einen späteren Termin.',
        ],
        notes: [
          'Eine Gruppe kann gleichzeitig eine Live-Übertragung und bis zu fünf geplante haben.',
          'Eine geplante Übertragung erscheint auf der Gruppenseite als „Demnächst“; Mitglieder tippen auf „Erinnern“. Der Host kann sie höchstens 15 Minuten vor dem geplanten Zeitpunkt starten.',
          'Live-Minuten hängen vom Gruppenpaket ab; der Startbildschirm zeigt die verbleibenden Minuten. Sind sie aufgebraucht, endet die Übertragung automatisch.',
          'Verlässt der Host die Übertragung und kommt nicht innerhalb von 2 Minuten zurück, endet sie automatisch.',
        ],
      ),
      GuideTopic(
        'Eine Übertragung leiten',
        intro: 'Hosts sind die Person, die gestartet hat, und das Moderationsteam der Gruppe.',
        notes: [
          'Tippe auf eine Person, um sie auf die Bühne zu holen, herunterzunehmen oder ihr Mikro aus- und einzuschalten.',
          '„Aus Übertragung entfernen“: Die Person kann dieser Übertragung nicht wieder beitreten.',
          'Gehobene Hände siehst du ganz oben auf der Karte „hat die Hand gehoben“.',
          '„Übertragung für alle beenden“ findest du im Menü oben rechts.',
          'Auf der Bühne sind inklusive Host höchstens 10 Personen. Auch hier gilt die Rangregel.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'messages',
    title: 'Nachrichten und Sprachanrufe',
    summary: 'Mit wem du schreiben kannst, Gruppenchat, Privatsphäre, Sprachanrufe.',
    topics: [
      GuideTopic(
        'Wem kann ich schreiben?',
        notes: [
          'Direktnachrichten gibt es nur mit deinen Matches und Teammitgliedern. Folgen erlaubt keine Nachrichten.',
          'Um einem Match zu schreiben, brauchst du das Paket Match-Chat; für Teammitglieder das Paket Teammitglied. Empfangene Nachrichten zu lesen ist kostenlos.',
          'Gruppenchats sind kostenlos; alle Mitglieder der Gruppe können schreiben.',
          'Der Nachrichtenbildschirm liegt hinter der Taste Nachrichten oben rechts unter Heute. Die Zahl ungelesener Nachrichten steht auf der Taste.',
        ],
      ),
      GuideTopic(
        'Nachrichten schreiben und löschen',
        notes: [
          'Du kannst Text (höchstens 2.000 Zeichen) und ein Foto senden.',
          'Während eine Nachricht gesendet wird, steht dort „Wird gesendet…“. Scheitert das Senden, kommt der Text mit dem Grund zurück ins Feld.',
          'In einem Einzelchat steht „Gesehen“, sobald die andere Person gelesen hat.',
          'Eigene Nachrichten kannst du für alle löschen; an ihrer Stelle steht „Diese Nachricht wurde gelöscht“ und der Inhalt wird vollständig entfernt.',
        ],
      ),
      GuideTopic(
        'Privatsphäre von Nachrichten',
        intro: 'Das GWAY-Plattform-Team kann deine privaten Nachrichten nicht lesen, deine Sprachanrufe nicht mithören und nicht sehen, wer wen angerufen hat.',
        notes: [
          'Du kannst eine Nachricht melden. Meldungen zu Direktnachrichten gehen an das Plattform-Team, zu Gruppenchat-Nachrichten an die Moderation der Gruppe.',
          'Das Disziplinargremium einer Gruppe kann deine Direktnachrichten nicht sehen.',
        ],
      ),
      GuideTopic(
        'Berechtigung für Sprachanrufe erhalten',
        intro: 'Einzel-Sprachanrufe stehen nicht allen offen; die Berechtigung erteilen Inhaber:in oder ein Admin einer Gruppe, in der du Mitglied bist.',
        steps: [
          'Öffne Einstellungen → „Sprachanrufe“.',
          'Wähle eine deiner Gruppen, schreib optional eine kurze Notiz und stelle die Anfrage.',
          'Deinen Status siehst du auf demselben Bildschirm: in Prüfung, aktiv oder aus (mit Begründung). Die Entscheidung kommt auch als Benachrichtigung.',
        ],
        notes: ['Verlässt du die Gruppe, die die Berechtigung erteilt hat, endet sie.'],
      ),
      GuideTopic(
        'Einen Sprachanruf starten',
        steps: [
          'Öffne den Chat mit deinem Match oder Teammitglied.',
          'Tippe oben rechts auf „Sprachanruf“.',
        ],
        notes: [
          'Beide brauchen die Anrufberechtigung und denselben Paketzugang wie für den Chat. Kannst du nicht anrufen, steht der Grund anstelle der Taste.',
          'Ein Anruf, der nicht innerhalb von 30 Sekunden angenommen wird, gilt als verpasst. Ein Anruf dauert höchstens 60 Minuten.',
          'Anrufe werden nie aufgezeichnet und sind Ende-zu-Ende-verschlüsselt. Ist der 12-stellige Sicherheitscode bei euch beiden gleich, hört niemand mit.',
          'Du kannst immer nur einen Anruf gleichzeitig führen; wer besetzt ist, kann nicht angerufen werden.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'matching',
    title: 'Matching und Teammitglieder',
    summary: 'Freundschaft und Dating, persönliche Pakete, Teammitglieder finden.',
    topics: [
      GuideTopic(
        'Wie funktioniert Matching?',
        intro: 'Matching hilft dir, unter Leuten mit gemeinsamen Gruppen Freundschaften oder eine Beziehung zu finden. Es nutzt ein eigenes Matching-Profil; solange du es nicht aktivierst, sieht dich dort niemand.',
        steps: [
          'Tippe im Tab Ich oben rechts auf Matching (auf großen Bildschirmen im Menü links).',
          'Erstelle dein Matching-Profil: Freundschaft, Dating oder beides; 2–6 Fotos, Geburtsdatum, Geschlecht, Provinz, „Über mich“.',
          'Wähle im Dating die gesuchten Geschlechter und einen Altersbereich.',
          'Gib deine ausdrückliche Einwilligung.',
        ],
        notes: [
          'In deinem Stapel erscheinen nur Personen, die mindestens eine Gruppe mit dir teilen und denselben Modus aktiviert haben.',
          'Im Dating müssen eure Vorlieben gegenseitig passen.',
          'Als Standort wird nur deine Provinz verwendet.',
        ],
      ),
      GuideTopic(
        'Swipen und matchen',
        notes: [
          'Nach rechts wischen: Like. Nach links: überspringen. Nach oben: Super-Like. Die Tasten unten tun dasselbe.',
          'Tippe auf die Ränder der Karte, um die Fotos zu wechseln; die „i“-Taste öffnet das ganze Profil.',
          'Mögt ihr euch im selben Modus gegenseitig, habt ihr ein Match und werdet benachrichtigt.',
          'Deine kostenlosen Likes und Super-Likes pro Tag stehen auf dem Matching-Bildschirm.',
          'Wen du übersprungen hast, kann nach 90 Tagen wieder vorgeschlagen werden.',
        ],
      ),
      GuideTopic(
        'Persönliche Pakete',
        intro: 'Jede Funktion wird als eigenes Paket verkauft; du nimmst nur, was du willst.',
        notes: [
          'Meine Matches: sehen, mit wem du ein Match hast. Ohne Paket weißt du, dass es ein Match gibt, aber die Person bleibt verborgen.',
          'Match-Chat: deinen Matches schreiben.',
          'Wer dich mag: die Liste der Leute, die dich geliked haben.',
          'Unbegrenzte Likes: unbegrenzte Likes, Rückgängig und Filter.',
          'Super-Like und Boost: mehr Super-Likes und einmal am Tag ganz oben in den Stapeln.',
          'Teammitglied: der Teambereich und Nachrichten an Teammitglieder.',
          'Alles in einem: alles.',
          'Pakete sind im Voraus bezahlt, verlängern sich nicht automatisch und werden im Web gekauft. Die Preise stehen unter Matching → Pakete.',
        ],
      ),
      GuideTopic(
        'Matches beenden, pausieren, löschen',
        notes: [
          'Beendest du ein Match, schließt euer Chat, das gegenseitige Folgen endet und ihr erscheint nicht mehr in den Stapeln des anderen.',
          'Habt ihr in beiden Modi ein Match, kannst du „Nur Freundschaft“ oder „Nur Dating“ wählen.',
          'Pausierst du dein Profil, stoppen Stapel und Likes; bestehende Matches bleiben.',
          'Alle Matching-Daten (Profil, Fotos, Likes, Matches) kannst du mit einem Tipp löschen.',
          'Matching-Profile und Fotos kannst du melden.',
        ],
      ),
      GuideTopic(
        'Teammitglieder finden',
        intro: 'Finde Leute, mit denen du trainierst, wanderst oder auf der Bühne stehst.',
        steps: [
          'Schalte unter Einstellungen → „Teammitglieder-Einstellungen“ „Ich suche ein Team“ ein.',
          'Wähle Aktivitäten, Niveau, Ziele, Häufigkeit, passende Zeiten und optional deine Provinz.',
          'Mit „Teammitglieder finden“ im Tab Ich siehst du Vorschläge. Bei jedem steht der Grund (gemeinsame Aktivität, gemeinsame Gruppe, gleiche Provinz…).',
          'Sende eine Anfrage (mit einer Nachricht bis 200 Zeichen). Nimmt die andere Person an, seid ihr Teammitglieder.',
        ],
        notes: [
          'Deine Provinz wird nur für die Vorschläge verwendet und erscheint nicht im Profil.',
          'Du kannst pro Tag höchstens 20 Anfragen senden und derselben Person eine Anfrage pro Tag.',
          'Der Teambereich braucht das Paket Teammitglied.',
          'Beide Seiten können die Teamverbindung jederzeit beenden.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'notifications',
    title: 'Benachrichtigungen',
    summary: 'Arten, Einstellungen und Push-Benachrichtigungen.',
    topics: [
      GuideTopic(
        'Der Benachrichtigungsbildschirm',
        notes: [
          'Du öffnest ihn mit der Glocke oben rechts unter Heute; die Zahl ungelesener Benachrichtigungen steht auf der Taste.',
          'Benachrichtigungen sind nach Heute / Diese Woche / Früher gruppiert; offene Folgeanfragen stehen ganz oben.',
          'Tippe auf eine Benachrichtigung, um die zugehörige Seite zu öffnen.',
        ],
      ),
      GuideTopic(
        'Benachrichtigungseinstellungen',
        steps: ['Öffne Einstellungen → „Benachrichtigungseinstellungen“.', 'Schalte aus, was du nicht möchtest.'],
        notes: [
          'Ausschaltbar sind: Event-Erinnerungen, Event-Änderungen und -Absagen, Bewertungsanfragen, Live-Benachrichtigungen, persönliche Nachrichten, Gruppennachrichten und Matching-Benachrichtigungen.',
          'Benachrichtigungen, die dich direkt betreffen – etwa Teilnahmefreigabe, Nachrücken oder Sanktionen –, lassen sich nicht ausschalten.',
        ],
      ),
      GuideTopic(
        'Push-Benachrichtigungen kommen nicht an',
        steps: [
          'Die App fragt beim ersten Start nach der Berechtigung; hast du sie nicht erteilt, schalte sie in den Handy-Einstellungen → Apps → GWAY → Benachrichtigungen ein.',
          'Prüfe unter Android, ob die Kanäle „Nachrichten“, „Sprachanrufe“ und „Benachrichtigungen“ aktiv sind.',
          'Prüfe die Benachrichtigungseinstellungen in der App.',
        ],
        notes: ['Ist das Handy stumm, ertönt kein Ton.'],
      ),
    ],
  ),
  GuideChapter(
    id: 'safety',
    title: 'Sicherheit, Meldungen und Sanktionen',
    summary: 'Melden, Gruppensanktionen, Einspruch, zweistufige Bestätigung.',
    topics: [
      GuideTopic(
        'Etwas melden',
        steps: [
          'Öffne das Menü des Beitrags, Kommentars, Events, Live-Kommentars, der Nachricht oder des Profils.',
          'Tippe auf „Melden“, wähle einen Grund und schreib optional eine kurze Beschreibung.',
        ],
        notes: [
          'Die gemeldete Person sieht weder die Meldung noch dich. Auch die Admins der Gruppe sehen nicht, wer gemeldet hat.',
          'Meldungen zu einer Gruppe gehen an deren Moderation, alle anderen an das Plattform-Team.',
          'Dich selbst oder eigene Inhalte kannst du nicht melden; denselben Inhalt meldest du einmal, solange die Meldung offen ist.',
        ],
      ),
      GuideTopic(
        'Gruppensanktionen',
        notes: [
          'Verwarnung: Sie wird vermerkt, du bekommst eine Benachrichtigung.',
          'Stummschaltung (1–90 Tage): Du kannst in der Gruppe nicht posten, nicht kommentieren und nicht im Gruppenchat schreiben; bei Live-Übertragungen hörst du nur zu.',
          'Entfernung: Du wirst aus der Gruppe entfernt; später kannst du wieder beitreten.',
          'Sperre (befristet oder dauerhaft): Solange sie gilt, kannst du nicht beitreten, keine Anfrage senden und keine Einladung erhalten.',
          'Deine Sanktionen stehen unter Einstellungen → „Meine Gruppensanktionen“.',
        ],
      ),
      GuideTopic(
        'Gegen eine Sanktion Einspruch einlegen',
        steps: [
          'Öffne Einstellungen → „Meine Gruppensanktionen“.',
          'Tippe neben der Sanktion auf „Einspruch einlegen“ und schreib deine Begründung (10–1000 Zeichen).',
        ],
        notes: [
          'Gegen jede Sanktion kannst du innerhalb von 7 Tagen einmal Einspruch einlegen. Gegen eine Sofort-Stummschaltung nicht.',
          'Über den Einspruch entscheidet die Inhaberin oder der Inhaber; ist sie oder er am Fall beteiligt, entscheidet das Plattform-Team.',
          'Bis zur Entscheidung gilt die Sanktion weiter. Die Entscheidung bekommst du als Benachrichtigung.',
        ],
      ),
      GuideTopic(
        'Kontosperrung und Ausschluss',
        notes: [
          'Das Plattform-Team kann ein Konto, das gegen die Regeln verstößt, sperren oder schließen. Dann zeigt dir die App den Grund und das Enddatum.',
          'Während der Sperre ist dein Profil sichtbar, deine Inhalte aber verborgen; ein dauerhaft geschlossenes Konto erscheint nirgends.',
          'Wird per Gruppenentscheid eine illegale Aktivität (etwa Gewalt, Drohung, Betrug) markiert, wird das Konto bis zur Prüfung durch die Plattform gesperrt.',
          'Glaubst du an einen Fehler, schreib dem Support-Team.',
        ],
      ),
      GuideTopic(
        'Zweistufige Bestätigung',
        steps: [
          'Öffne Einstellungen → „Zweistufige Bestätigung“.',
          'Füge eine Authenticator-App hinzu (z. B. Google Authenticator) oder richte im Web die Anmeldung per Fingerabdruck und Gesichtserkennung ein.',
        ],
        notes: ['Die eingerichtete Methode steht bei späteren Anmeldungen an erster Stelle; SMS bleibt immer als Reserve.'],
      ),
    ],
  ),
  GuideChapter(
    id: 'moderation',
    title: 'Gruppenmoderation',
    summary: 'Für Berechtigte: Meldungen prüfen, Disziplinarfälle, Abstimmung, Sperre.',
    topics: [
      GuideTopic(
        'Der Moderationsbildschirm',
        intro: 'Die Moderationskarte auf der Gruppenseite zeigt die Zahl offener Aufgaben. Inhaber:in, Admins, Gremiumsmitglieder und Moderation sehen sie.',
        notes: [
          'Meldungen: Meldungen zum selben Inhalt werden in einer Zeile gebündelt. Ablehnen, Inhalt entfernen oder Fall eröffnen.',
          'Fälle: Fälle in der Abstimmung, verbleibende Zeit und Stimmen; gib deine Stimme ab.',
          'Sanktionen und Einsprüche: Hier entscheidet die Inhaberin oder der Inhaber über Einsprüche.',
        ],
      ),
      GuideTopic(
        'Disziplinarfall und Abstimmung',
        steps: [
          'Wähle bei einer Meldung oder im Mitgliedermenü der Mitgliederseite „Disziplinarfall eröffnen“.',
          'Wähle die vorgeschlagene Sanktion (Verwarnung, Stummschaltung, Entfernung, Sperre) und ihre Dauer und schreib die Begründung.',
          'Im Notfall kreuzt du „Sofort stummschalten (24 Stunden)“ an; die Person ist bis zur Entscheidung stummgeschaltet.',
        ],
        notes: [
          'Die Mitglieder des Disziplinargremiums stimmen innerhalb von 72 Stunden ab. Hat die Gruppe kein Gremium, entscheidet die Inhaberin oder der Inhaber allein.',
          'Die Entscheidungsschwelle ist standardmäßig die einfache Mehrheit; in den Einstellungen des Moderationsbildschirms sind auch zwei Drittel oder Einstimmigkeit möglich.',
          'Ist die Schwelle erreicht, wird der Fall sofort bestätigt und die Sanktion verhängt. Stimmt niemand ab, wird der Fall abgelehnt.',
          'Zu einer Person kann es nur einen offenen Fall gleichzeitig geben. Die Rangregel gilt.',
        ],
      ),
      GuideTopic(
        'Sperre ohne Abstimmung',
        intro: 'Inhaber:in und Admins können jemanden sperren, ohne auf das Gremium zu warten.',
        steps: [
          'Wähle unter „Disziplinarfall eröffnen“ als Sanktion die Sperre.',
          'Kreuze „Sofort ohne Abstimmung“ an.',
          'Gib die Dauer (1–365 Tage oder dauerhaft) und die Begründung ein.',
        ],
        notes: [
          'Ein Admin kann keinen anderen Admin und nicht die Inhaberin bzw. den Inhaber sperren.',
          'Handelt es sich um eine Straftat, markiere sie als „illegale Aktivität“ und wähle die Kategorie; das Konto der Person wird bis zur Prüfung durch die Plattform gesperrt.',
          'Die Person kann innerhalb von 7 Tagen Einspruch einlegen.',
        ],
      ),
      GuideTopic(
        'Sofortmaßnahmen in einer Live-Übertragung',
        intro: 'Bei Belästigung während einer Übertragung schaltet ein Host das Mikro der Person sofort stumm oder entfernt sie aus der Übertragung. Danach kann bei Bedarf ein Disziplinarfall eröffnet werden.',
      ),
    ],
  ),
  GuideChapter(
    id: 'account',
    title: 'Konto, Privatsphäre und Support',
    summary: 'Rechtliche Dokumente, deine Daten, Konto löschen, Abmelden, Support.',
    topics: [
      GuideTopic(
        'Wie werden meine Daten geschützt?',
        notes: [
          'Dein Standort dient nur der Kontosicherheit; er erscheint weder auf der Karte noch in deinem Profil.',
          'Dein Geburtsdatum wird niemandem gezeigt.',
          'Deine privaten Nachrichten kann das Plattform-Team nicht lesen.',
          'Die Dokumente, denen du zugestimmt hast, findest du unter Einstellungen → „Rechtliche Dokumente“.',
        ],
      ),
      GuideTopic(
        'Mein Konto löschen',
        steps: [
          'Öffne Einstellungen → „Konto löschen“.',
          'Bestätige das Löschen.',
        ],
        notes: [
          'Dein Profil ist für andere sofort verborgen. Innerhalb von 30 Tagen kannst du dich anmelden und „Löschen rückgängig machen“ wählen.',
          'Nach 30 Tagen werden dein Konto, deine Beiträge, Nachrichten und Dateien endgültig gelöscht.',
          'Bist du Inhaber:in einer Gruppe, musst du zuerst die Inhaberschaft übertragen oder die Gruppe löschen.',
        ],
      ),
      GuideTopic(
        'Abmelden',
        intro: 'Tippe ganz unten in den Einstellungen auf „Abmelden“. Das Handy, auf dem du dich abmeldest, bekommt keine Benachrichtigungen mehr.',
      ),
      GuideTopic(
        'Dem Support-Team schreiben',
        steps: [
          'Öffne Einstellungen → „Support und Feedback“.',
          'Tippe auf „Neue Nachricht“ und wähle die Art: Problem (etwas funktioniert nicht), Anliegen (eine Aktion für dein Konto, deine Gruppe oder Zahlung), Wunsch (neue Funktion oder Vorschlag).',
          'Schreib Betreff und Beschreibung; du kannst bis zu 3 Bilder anhängen.',
        ],
        notes: [
          'Kommt eine Antwort, steht in der Zeile in den Einstellungen „neue Antwort“. Status einer Nachricht: Neu, In Bearbeitung, Gelöst, Geschlossen.',
          'Bist du Admin einer Gruppe, kannst du über die Gruppenseite auch eine Nachricht für diese Gruppe eröffnen.',
        ],
      ),
    ],
  ),
];
