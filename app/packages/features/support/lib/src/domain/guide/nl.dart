import '../guide.dart';

// Dutch translation of tr.dart; keep chapters, topics, steps and notes in step with it.

const guideNl = <GuideChapter>[
  GuideChapter(
    id: 'start',
    title: 'Aan de slag',
    summary: 'Registreren, inloggen, verificatie en je weg vinden in de app.',
    topics: [
      GuideTopic(
        'Wat is GWAY?',
        intro: 'GWAY is een sociaal platform dat allerlei gemeenschappen samenbrengt: wandelen, hardlopen, fietsen, muziek, '
            'natuur, sport, kunst en meer. Je wordt lid van groepen, gaat naar evenementen, praat mee in live audioruimtes '
            'en leert nieuwe mensen kennen.',
        notes: [
          'GWAY is toegankelijk voor iedereen vanaf 18 jaar.',
          'De app werkt op je telefoon (Android, iOS) en in een webbrowser; je account is overal hetzelfde.',
        ],
      ),
      GuideTopic(
        'Een account maken',
        steps: [
          'Tik op het inlogscherm op ‘Registreren’.',
          'Vul je e-mailadres en een wachtwoord in. Je kunt je ook registreren met Google of Apple.',
          'Heb je je met e-mail geregistreerd, tik dan op de verificatielink in je inbox. Zonder geverifieerd e-mailadres kun je niet inloggen.',
          'Na het inloggen leidt de app je langs de beveiligingsverificatie, het accepteren van de juridische documenten, je geboortedatum en het maken van je profiel.',
        ],
        tip: 'Is de verificatiemail niet aangekomen? Kijk in je spammap.',
      ),
      GuideTopic(
        'Ik ben mijn wachtwoord vergeten',
        steps: [
          'Tik op het inlogscherm op ‘Wachtwoord vergeten’.',
          'Vul het e-mailadres van je account in.',
          'Stel een nieuw wachtwoord in via de link in de e-mail.',
        ],
      ),
      GuideTopic(
        'Beveiligingsverificatie: locatie, telefoon en tweede stap',
        intro: 'Om nepaccounts te voorkomen kan de app je om deze stappen vragen.',
        steps: [
          'Locatie: de app vraagt om locatietoestemming. Zonder toestemming opent de app niet en zie je een scherm dat naar je instellingen leidt. '
              'Je locatie wordt alleen gebruikt voor accountbeveiliging en aan niemand getoond.',
          'Telefoon: je vult een nummer in uit het land waar je bent en voert de sms-code in. Dit doe je één keer; een nummer kan maar bij één account horen.',
          'Tweede stap: bij elke nieuwe login krijg je een sms-code op je geregistreerde nummer. Heb je een authenticator-app of vingerafdruk ingesteld, dan gebruik je die.',
        ],
        tip: 'Accepteer na de telefoonverificatie de suggestie ‘Vingerafdruk toevoegen’ of ‘Google Authenticator toevoegen’, dan gaat inloggen voortaan sneller. Sms blijft de reserve.',
      ),
      GuideTopic(
        'Juridische documenten en geboortedatum',
        intro: 'Je moet akkoord gaan met de gebruiksvoorwaarden, de privacyverklaring, de uitdrukkelijke toestemming en de communityregels.',
        steps: [
          'Open elk document en scrol tot het einde. Pas dan kun je het vakje aanvinken.',
          'Tik onderaan het document op ‘Gelezen en akkoord’.',
          'Vul je geboortedatum in. Die wordt aan niemand getoond en kan later niet worden gewijzigd; vergist? Schrijf het supportteam.',
        ],
        notes: ['Verschijnt er een nieuwe versie van een document, dan vraagt de app je opnieuw om akkoord.'],
      ),
      GuideTopic(
        'Je profiel maken',
        steps: [
          'Kies een gebruikersnaam: 3–30 tekens; kleine letters, cijfers, liggend streepje en punt zijn toegestaan.',
          'Voeg je weergavenaam en profielfoto toe.',
          'Kies je interesses (maximaal 10). Groepen en suggesties zijn daarop gebaseerd.',
        ],
        notes: ['Je gebruikersnaam kun je eens per 30 dagen wijzigen.'],
      ),
      GuideTopic(
        'Je weg vinden in de app',
        intro: 'De balk onderaan heeft vier tabbladen en in het midden een ‘+’-knop.',
        notes: [
          'Vandaag: live-uitzendingen van nu, evenementen die binnenkort beginnen en berichten van mensen die je volgt. Rechtsboven staan Zoeken, Meldingen en Berichten.',
          'Groepen: groepen zoeken en ontdekken. Rechtsboven staan Groepencompetitie en Kaart.',
          'Agenda: evenementen waaraan je meedoet en die van je groepen.',
          'Ik: je eigen profiel. Rechtsboven staan Meldingen, Opgeslagen, Matchen, Teamgenoten vinden, Jaaroverzicht en Instellingen.',
          'De ‘+’-knop: Vanavond, Binnenkort, en een bericht, verhaal of groep maken.',
          'Op grote schermen (web, tablet) staan dezelfde onderdelen in het menu links, met daaronder de groepen waarvan je lid bent.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'profile',
    title: 'Profiel en volgen',
    summary: 'Profiel bewerken, privacy, volgen, blokkeren, badges.',
    topics: [
      GuideTopic(
        'Mijn profiel bewerken',
        steps: [
          'Tik in het tabblad Ik rechtsboven op Instellingen en daarna op ‘Profiel bewerken’.',
          'Wijzig je profielfoto, omslagfoto, weergavenaam, bio en interesses.',
          'Opslaan.',
        ],
        notes: ['Afbeeldingen mogen maximaal 5 MB zijn (JPEG, PNG of WebP).'],
      ),
      GuideTopic(
        'Privéaccount',
        intro: 'Staat Instellingen → ‘Privéaccount’ aan, dan zien alleen volgers die je hebt goedgekeurd je berichten en verhalen.',
        notes: [
          'Bij een privéaccount sturen mensen die je willen volgen een verzoek; je keurt het goed of wijst het af bovenaan het scherm Meldingen. Afgewezen mensen krijgen geen bericht.',
          'Maak je je account weer openbaar, dan worden openstaande verzoeken automatisch goedgekeurd.',
        ],
      ),
      GuideTopic(
        'Mijn groepen op mijn profiel tonen',
        intro: 'Instellingen → ‘Mijn groepen op mijn profiel tonen’ staat standaard uit.',
        notes: [
          'Zolang het uit staat, zien alleen leden van een groep dat je daar lid bent. Een beheerder van een andere groep ziet niet in welke groepen je zit.',
          'Zet je het aan, dan zijn je lidmaatschappen voor iedereen zichtbaar op je profiel.',
          'Groepen waarin je in het beheerteam zit (eigenaar, beheerder, commissie, moderator) zijn altijd openbaar.',
        ],
      ),
      GuideTopic(
        'Volgen en vrienden',
        steps: [
          'Tik op een profiel op ‘Volgen’. Is het account privé, dan gaat er een verzoek uit; na acceptatie volg je.',
          'Tik nog eens op dezelfde knop om te ontvolgen of je verzoek in te trekken.',
        ],
        notes: [
          'Volgen jullie elkaar, dan staat er ‘Vriend’ op het profiel.',
          'Je kunt iemand die jou volgt uit je volgerslijst verwijderen.',
          'Volgen geeft geen recht om berichten te sturen; privéberichten zijn tussen matches en teamgenoten.',
          'Je kunt ook groepen volgen; berichten van groepen waarvan je lid bent komen al in je feed.',
        ],
      ),
      GuideTopic(
        'Iemand blokkeren',
        steps: [
          'Open op het profiel van de persoon rechtsboven het menu ‘Meer opties’.',
          'Tik op ‘Blokkeren’.',
        ],
        notes: [
          'Volgrelaties en verzoeken in beide richtingen worden verwijderd. Jullie zien elkaars profiel, berichten en reacties niet meer; jullie kunnen elkaar niet schrijven of noemen.',
          'De geblokkeerde persoon verschijnt ook niet meer in je matchstapel of bij teamgenootsuggesties.',
          'Wie je hebt geblokkeerd zie je in Instellingen → ‘Geblokkeerde accounts’; daar hef je de blokkade op. Volgen komt daarna niet vanzelf terug.',
        ],
      ),
      GuideTopic(
        'Bijdragen en badges',
        intro: 'De bijdragen op je profiel tellen wat je in het echte leven doet; likes, volgers en aantallen berichten tellen niet.',
        notes: [
          'Deelname: afgelopen evenementen waaraan je meedeed zonder ‘niet gekomen’-markering.',
          'Organiseren: evenementen die jij maakte en waaraan naast jou minstens 2 mensen meededen.',
          'Herinnering: berichten die je deelde gekoppeld aan een evenement.',
          'Voorbeelden van badges: Eerste stap (1 deelname), Vaste gast (10), Reisgenoot (25), Ontdekker (3 verschillende groepen), Organisator, Herinneringsverzamelaar, Feedbackgever, ‘<categorie>-fan’, welkoms- en handdrukbadges en behaalde doelen.',
          'Er zijn geen ranglijsten of ‘beste’-lijsten.',
        ],
      ),
      GuideTopic(
        'Opgeslagen en verhalenarchief',
        notes: [
          'Tik op het bewaarpictogram op de kaart om een bericht op te slaan. Alleen jij ziet wat je hebt opgeslagen: Ik → Opgeslagen of Instellingen → Opgeslagen.',
          'Verlopen verhalen worden niet verwijderd; ze blijven in Instellingen → ‘Verhalenarchief’.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'feed',
    title: 'Vandaag, berichten en verhalen',
    summary: 'Delen, likes, reacties, ontdekken en zoeken.',
    topics: [
      GuideTopic(
        'Het scherm Vandaag',
        notes: [
          'Bovenaan ‘Nu live’: live-uitzendingen in je groepen. Tik op een kaart om mee te doen.',
          'Daarna ‘Begint binnenkort’: evenementen in de komende uren; eerst die van je eigen groepen, dan die in de provincies van je groepen.',
          'Daaronder de feed: je eigen berichten, die van mensen die je volgt en van groepen die je volgt of waarvan je lid bent, nieuwste eerst.',
          'Trek het scherm omlaag om te vernieuwen.',
        ],
      ),
      GuideTopic(
        'Een bericht delen',
        steps: [
          'Tik onderaan op de ‘+’-knop en daarna op ‘Bericht’.',
          'Kies maximaal 10 foto’s of video’s. Een video mag maximaal 60 seconden en 50 MB zijn.',
          'Kies voor foto’s de verhouding (Origineel, 1:1, 4:5, 1,91:1) en pas de uitsnede aan.',
          'Schrijf een beschrijving. Je kunt #hashtags toevoegen en iemand noemen met @gebruikersnaam.',
          'Zet eventueel reacties uit of verberg het aantal likes, en deel.',
        ],
        notes: [
          'Locatiegegevens van je foto’s worden vóór het uploaden verwijderd.',
          'Je kunt een bericht later bewerken; alleen de beschrijving en opties veranderen. Verwijder je het, dan worden de media ook verwijderd.',
          'Om in een groep te posten, deel je vanaf de groepspagina. Elk lid kan posten; gedempte leden niet.',
        ],
      ),
      GuideTopic(
        'Likes, reacties en emoji’s',
        notes: [
          'Je kunt een bericht liken of reageren met 😍 😂 😮 👏 🔥 🙏. Je reactie kun je wijzigen of intrekken.',
          'Iedereen die een bericht kan zien, kan reageren, tenzij de maker reacties heeft uitgezet.',
          'Je kunt op een reactie antwoorden en reacties liken. Antwoorden gaan één niveau diep.',
          'Je eigen reacties en reacties op je eigen berichten verwijder je zelf. Bij groepsberichten kunnen de eigenaar en beheerders van de groep ook reacties verwijderen.',
        ],
      ),
      GuideTopic(
        'Een verhaal delen',
        steps: [
          'Tik op ‘+’ → ‘Verhaal’.',
          'Kies een foto of een video van maximaal 60 seconden en deel.',
        ],
        notes: [
          'Een verhaal is 24 uur zichtbaar en gaat daarna naar je archief.',
          'Alleen jij ziet wie je verhaal heeft bekeken.',
          'Voeg verhalen toe aan je hoogtepunten om ze op je profiel te houden.',
        ],
      ),
      GuideTopic(
        'Ontdekken en zoeken',
        steps: [
          'Tik rechtsboven op het scherm Vandaag op Zoeken.',
          'Zoek naar mensen of #hashtags. Gebruik het tabblad Groepen om groepen te zoeken.',
        ],
        notes: [
          'Ontdekken toont de berichten met de meeste interactie van de afgelopen twee weken, van openbare accounts en groepen die je niet volgt.',
          'Je kunt de link naar een bericht delen; wie hem opent ziet het als diegene er toegang toe heeft.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'groups',
    title: 'Groepen',
    summary: 'Groepen vinden en lid worden, rollen en de groepspagina.',
    topics: [
      GuideTopic(
        'Een groep vinden',
        notes: [
          'Zoek in het tabblad Groepen op naam of kies een categorie.',
          'Met de knop Kaart rechtsboven zie je groepen en evenementen bij jou in de buurt op de kaart.',
          'Met de Groepencompetitie zie je welke groepen de beste evenementen organiseren in je categorie en provincie.',
          'Elke actieve groep heeft een openbare pagina; geheime groepen bestaan niet.',
        ],
      ),
      GuideTopic(
        'Lid worden van een groep',
        intro: 'Het type lidmaatschap van de groep staat op de knop:',
        notes: [
          'Open: tik op ‘Lid worden’ en je bent meteen lid.',
          'Op verzoek: je stuurt een verzoek; een beheerder van de groep keurt het goed. Je kunt je verzoek intrekken.',
          'Op uitnodiging: een beheerder nodigt je uit via je gebruikersnaam; je accepteert of weigert op het scherm Meldingen.',
          'Uitnodigingslink: open de link die je kreeg en tik op ‘Lid worden van de groep’; dan word je lid, welk type de groep ook heeft.',
          'Is de ledenlimiet van het groepspakket bereikt, dan kunnen er geen nieuwe leden bij.',
        ],
        tip: 'Word je voor het eerst lid van een groep, dan krijg je één keer een proefperiode van 30 dagen van het persoonlijke pakket ‘Alles-in-één’ (match- en teamgenootfuncties).',
      ),
      GuideTopic(
        'Een groep verlaten',
        steps: [
          'Tik op de groepspagina op de lidmaatschapsknop.',
          'Kies ‘Groep verlaten’.',
        ],
        notes: [
          'Je rollen worden verwijderd en je deelname aan komende evenementen van de groep vervalt.',
          'De eigenaar kan de groep niet verlaten; eerst moet het eigendom worden overgedragen.',
        ],
      ),
      GuideTopic(
        'Wat staat er op een groepspagina?',
        notes: [
          'Omslag, logo, beschrijving, regels, links, provincie en categorie.',
          'Livekaart: lopende en geplande uitzendingen.',
          'Evenementen, ‘Hoe was het?’-beoordelingen en de gemiddelde score van de groep.',
          'Peilingen, doelen, de competitiekaart en groepsberichten.',
          'Leden: het beheerteam is openbaar; de volledige ledenlijst zien alleen leden van de groep.',
          'Groepschat: elke groep heeft één chat die alleen leden kunnen lezen en waarin alleen leden schrijven.',
        ],
      ),
      GuideTopic(
        'Rollen in een groep',
        intro: 'Een lid kan meerdere rollen hebben. Het getal tussen haakjes is de rang.',
        notes: [
          'Groepseigenaar (100): alles, betaling en rollen toekennen.',
          'Beheerder (80): inhoud, evenementen, peilingen, leden goedkeuren en uitnodigen, live-uitzendingen, ban zonder stemming, verzoeken voor spraakoproepen.',
          'Tuchtcommissie (60): stemt over tuchtdossiers; meldingen beoordelen, noodmute, livemoderatie.',
          'Moderator (50): eerste beoordeling van meldingen, noodmute, livemoderatie.',
          'Lid (10): deelnemen, posten, meedoen aan live-uitzendingen.',
          'Rangregel: niemand kan iemand met een gelijke of hogere rang een sanctie geven. De eigenaar kan niet worden geband.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'group-admin',
    title: 'Een groep oprichten en beheren',
    summary: 'Voor eigenaren en beheerders: groep, uitnodigingen, rollen, pakketten, doelen.',
    topics: [
      GuideTopic(
        'Een groep oprichten',
        steps: [
          'Tik op ‘+’ → ‘Groep’.',
          'Vul de naam (3–60 tekens) en het adres van de groep in. Het adres is de link van de pagina (/g/adres) en kan later niet worden gewijzigd.',
          'Kies de categorie en de provincie. De provincie is nodig voor de kaart en de Groepencompetitie.',
          'Kies het type lidmaatschap: open, op verzoek of op uitnodiging.',
          'Voeg logo, omslag, beschrijving, regels en maximaal 5 links toe.',
        ],
        notes: ['Wie de groep opricht, is de eigenaar. De groep krijgt ook een eigen chat.'],
      ),
      GuideTopic(
        'Leden toelaten en uitnodigen',
        notes: [
          'In een groep op verzoek keur je openstaande verzoeken goed of af op de groepspagina (eigenaar en beheerders).',
          'Je kunt uitnodigingen sturen via gebruikersnaam. Een groep kan in 24 uur maximaal 50 uitnodigingen sturen; ingetrokken uitnodigingen tellen mee.',
          'Je kunt een uitnodiging intrekken zolang die niet is geaccepteerd.',
        ],
      ),
      GuideTopic(
        'Uitnodigingslink',
        intro: 'De makkelijkste manier om je groep over te halen van WhatsApp of Instagram.',
        steps: [
          'Open op de groepspagina het onderdeel ‘Uitnodigingslink’.',
          'Kies de geldigheid (1, 7 of 30 dagen); stel eventueel een gebruikslimiet in (1–1000 mensen).',
          'Deel de link. Wie hem opent, inlogt en op ‘Lid worden van de groep’ tikt, wordt lid.',
        ],
        notes: [
          'Een groep kan tegelijk maximaal 20 geldige links hebben.',
          'Je kunt een link altijd intrekken; dat is niet terug te draaien, je maakt gewoon een nieuwe.',
          'Op WhatsApp toont een gedeelde link een voorbeeld met de naam en afbeelding van de groep.',
        ],
      ),
      GuideTopic(
        'Rollen toekennen en eigendom overdragen',
        notes: [
          'Alleen de eigenaar kent rollen toe en neemt ze af: Beheerder, Tuchtcommissie, Moderator. Een rol gaat alleen naar een lid.',
          'Je kunt het eigendom overdragen aan een actief lid. Jij blijft gewoon lid; de nieuwe eigenaar kan je een rol geven.',
          'Alleen de eigenaar kan de groep verwijderen. Verwijderen is definitief.',
          'Zolang je eigenaar van een groep bent, kun je je account niet verwijderen; draag eerst het eigendom over of verwijder de groep.',
        ],
      ),
      GuideTopic(
        'Groepspakketten',
        intro: 'Het pakket bepaalt het maximale aantal leden, het aantal evenementen per maand en de liveminuten per maand.',
        steps: [
          'Open op de groepspagina de kaart ‘Pakket’ om het huidige pakket, de limieten en het gebruik te zien.',
          'Koop het pakket op het web. De mobiele app toont alleen de pakketstatus.',
        ],
        notes: [
          'Een groep zonder abonnement gebruikt de limieten van het gratis pakket.',
          'Pakketten worden vooruitbetaald (per maand of jaar); er is geen automatische verlenging en er wordt geen kaart opgeslagen.',
          'Bij een upgrade gaat je resterende tijd mee naar het nieuwe pakket. Verleng je hetzelfde pakket, dan komt de tijd erachteraan.',
          'Betalingen vanuit Turkije gaan via PayTR in TL, vanuit het buitenland via iyzico in USD.',
          'Is de ledenlimiet bereikt, dan blijven bestaande leden, maar kunnen er geen nieuwe bij.',
          'Actuele prijzen en limieten staan op het pakketscherm. De eigenaar koopt het pakket.',
        ],
      ),
      GuideTopic(
        'Doelen en taken',
        intro: 'Brengt de groep samen rond een gedeeld doel. De eigenaar en beheerders maken doelen; de beloning is een badge, geen geld of punten.',
        notes: [
          'Persoonlijk doel: elk lid krijgt een badge als het zijn eigen aantal haalt.',
          'Groepsdoel: haalt het totaal van de groep het doel, dan krijgt iedereen die bijdroeg een badge.',
          'Teamdoel: er worden teams gevormd en het totaal per team telt.',
          'Taak: het lid tikt op ‘Gedaan’ en voegt een korte notitie toe; keurt een beheerder het goed, dan volgt een badge.',
          'Wat telt: deelname, organiseren of herinneringen. De server berekent de voortgang.',
        ],
      ),
      GuideTopic(
        'De groepschat beheren',
        notes: [
          'Je kunt de groepschat zo instellen dat alleen beheerders schrijven (zoals een aankondigingskanaal).',
          'Wordt een ongepast bericht gemeld, dan komt het in het moderatiescherm van de groep; een bevoegde persoon kan het verwijderen.',
        ],
      ),
      GuideTopic(
        'Verzoeken voor spraakoproepen beantwoorden',
        intro: 'Leden vragen de groep om toestemming voor één-op-één spraakoproepen. De eigenaar en beheerders zien de verzoeken.',
        steps: [
          'Open op de groepspagina ‘Verzoeken voor spraakoproepen’.',
          'Zet het verzoek aan of weiger het met een reden.',
          'Een gegeven toestemming kun je altijd met een reden weer uitzetten.',
        ],
        notes: ['Verlaat de persoon de groep, of wordt die verwijderd of geband, dan vervalt de toestemming automatisch.'],
      ),
    ],
  ),
  GuideChapter(
    id: 'events',
    title: 'Evenementen',
    summary: 'Meedoen, wachtlijst, welkom, handdruk, beoordeling.',
    topics: [
      GuideTopic(
        'Meedoen aan een evenement',
        steps: [
          'Open de pagina van het evenement (via de groepspagina, Vandaag, de agenda of de kaart).',
          'Lees de datum, plaats, kosteninformatie, deelnamevoorwaarden en benodigde uitrusting.',
          'Tik op ‘Meedoen’. Is het vol, dan staat er ‘Op de wachtlijst’.',
        ],
        notes: [
          'Iedereen ziet evenementen, maar alleen leden van de groep kunnen meedoen.',
          'Sta je op de wachtlijst, dan ben je aan de beurt als iemand afzegt en krijg je een melding.',
          'Bij evenementen met goedkeuring staat er ‘Deelnameverzoek sturen’; je doet mee zodra de organisator het goedkeurt.',
          'Om af te zeggen tik je op ‘Afzeggen’; je plek gaat naar de eerste op de wachtlijst.',
          'Na de start van het evenement sluit de aanmelding.',
        ],
      ),
      GuideTopic(
        'Deelnamekosten',
        intro: 'De kosten worden alleen ter informatie getoond. GWAY neemt geen betalingen aan; je betaalt de organisator zoals die aangeeft (bijvoorbeeld contant ter plekke).',
      ),
      GuideTopic(
        'Toevoegen aan agenda en route',
        notes: [
          '‘Toevoegen aan agenda’ zet het evenement in de agenda-app van je telefoon.',
          'Is er een ontmoetingspunt gemarkeerd, dan opent ‘Route’ onder de kleine kaart de kaarten-app van je toestel.',
        ],
      ),
      GuideTopic(
        'Twee evenementen tegelijk',
        intro: 'Heb je op het tijdstip van een evenement waaraan je meedoet nog een ander evenement, dan vraagt de app of je je bij het andere wilt afmelden om je plek vrij te maken. Jij kiest; niets wordt automatisch geannuleerd.',
      ),
      GuideTopic(
        'De vraag ‘Kom je?’',
        intro: 'Minder dan 24 uur voor de start krijg je een herinnering en verschijnt de kaart ‘Kom je?’ op de evenementpagina.',
        notes: [
          '‘Ja, ik kom’: de organisator ziet dat je komt.',
          '‘Ik kan niet’: je zegt af; je plek gaat naar de eerste op de wachtlijst.',
          'Antwoord je niet, dan word je niet van de lijst gehaald.',
        ],
      ),
      GuideTopic(
        'Welkom: als je voor het eerst komt',
        intro: 'Ga je voor het eerst naar een evenement van een groep, dan kan een vrijwillig lid van de groep je verwelkomen.',
        steps: [
          'Meld je aan voor het evenement.',
          'Tik in het welkomstonderdeel van de pagina op ‘Ik wil verwelkomd worden’; schrijf eventueel hoe je te herkennen bent (bv. ‘Ik draag een rode jas’).',
          'Neemt iemand je verzoek aan, dan krijg je het ontmoetingspunt (bv. ‘Voor het café bij de ingang, 08:45’) als melding.',
          'Na het evenement kun je je verwelkomer bedanken.',
        ],
        notes: [
          'Wil je zelf verwelkomen, meld je dan aan voor het evenement; open verzoeken zie je in het welkomstonderdeel. Per evenement kun je maximaal 3 mensen verwelkomen.',
          'Welkomstbadges: Deuropener (1), Gastheer (5), Hart van de community (20).',
        ],
      ),
      GuideTopic(
        'Verrassingslocatie',
        intro: 'Bij sommige evenementen is de locatie een verrassing. Op de pagina staat alleen een hint (bv. ‘In Kadıköy, aan zee’) en wanneer de locatie bekend wordt.',
        notes: [
          'Op dat moment krijgen de deelnemers de locatie via een melding.',
          'Wie op de wachtlijst staat of niet meedoet, ziet de locatie niet. Meld je je later aan en is het tijdstip al voorbij, dan zie je hem meteen.',
        ],
      ),
      GuideTopic(
        'Handdruk: mensen bewaren die je ontmoette',
        intro: 'Twee deelnemers aan hetzelfde evenement scannen elkaars QR-code om vast te leggen dat ze elkaar hebben ontmoet.',
        steps: [
          'Van 1 uur voor de start tot 6 uur na het einde staat de kaart ‘Handdruk’ op de pagina.',
          'Laat je code zien of scan de code van de ander met de camera. Zonder camera typ je de code van 6 tekens.',
        ],
        notes: [
          'De code verandert elke 3 minuten; een foto ervan heeft later geen zin.',
          'Alleen jij ziet wie je ontmoette: Ik → Jaaroverzicht → Mensen die ik ontmoette. Op je profiel staat alleen het aantal.',
          'Een handdruk geeft geen recht om berichten te sturen.',
        ],
      ),
      GuideTopic(
        'Na het evenement',
        notes: [
          'Na afloop krijg je een verzoek om te beoordelen; geef 1–5 sterren. De score van de groep is het gemiddelde van die beoordelingen.',
          'Voeg je herinnering toe met een bericht gekoppeld aan het evenement; herinneringen tellen voor badges en doelen.',
          'Was je erbij, dan verschijnt de kaart ‘Ik was er ook bij’; je kunt hem als afbeelding delen in een Instagram-verhaal of op WhatsApp. Op de kaart staan geen namen of gezichten van andere deelnemers.',
          'Eerdere evenementen van de groep zie je op de groepspagina.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'event-admin',
    title: 'Evenementen en peilingen organiseren',
    summary: 'Voor eigenaren en beheerders: maken, herhalen, goedkeuren, annuleren, peiling.',
    topics: [
      GuideTopic(
        'Een evenement maken',
        steps: [
          'Tik op de groepspagina op ‘Evenement maken’.',
          'Vul omslag, titel, beschrijving, begintijd en eventueel eindtijd in. De start moet minstens 15 minuten en hoogstens 1 jaar in de toekomst liggen.',
          'Vul de plaats in; markeer eventueel het ontmoetingspunt met een speld op de kaart of voeg een onlinelink toe.',
          'Voeg capaciteit (leeg = onbeperkt), kosteninformatie, deelnamevoorwaarden en uitrustingslijst toe.',
          'Zet zo nodig ‘Deelname met goedkeuring’ aan en sla op.',
        ],
        notes: [
          'Het formulier toont hoeveel evenementen je deze maand nog hebt. Geannuleerde evenementen tellen mee voor de maandlimiet van je pakket.',
          'Het formulier toont ook hoeveel evenementen andere groepen uit dezelfde categorie die dag in je provincie hebben; je kunt de datum wijzigen.',
        ],
      ),
      GuideTopic(
        'Terugkerend evenement',
        intro: 'Kies bij het maken onder ‘Herhalen’ voor ‘Elke week’ of ‘Om de twee weken’ om een reeks te starten (met optionele einddatum, maximaal 1 jaar).',
        notes: [
          'Een reeks houdt altijd de komende 4 weken open. Elke datum heeft eigen deelnemers en een eigen wachtlijst.',
          'Bewerk je de laatste datum, dan volgen later geopende data die.',
          'Met ‘Herhalen stoppen’ in het evenementmenu stop je de reeks; al geopende data blijven, je kunt ze een voor een annuleren.',
          'Is de maandlimiet bereikt, dan opent de datum niet en krijg je een melding; komt er ruimte, dan opent hij.',
        ],
      ),
      GuideTopic(
        'Een verrassingslocatie instellen',
        steps: [
          'Zet in het formulier ‘Verrassingslocatie’ aan.',
          'Schrijf in het veld ‘Plaats’ een hint; vul de echte locatie en het ontmoetingspunt apart in.',
          'Kies wanneer hij bekend wordt: 1, 3, 6, 12 of 24 uur voor de start.',
        ],
        notes: ['Zet je de verrassing uit, dan wordt de geheime locatie verwijderd en wordt ‘Plaats’ de gewone plaats.'],
      ),
      GuideTopic(
        'Deelnemers beheren',
        notes: [
          'Bij deelname met goedkeuring keur je openstaande verzoeken goed of af.',
          'In de deelnemerslijst zie je wie ‘Kom je?’ heeft bevestigd.',
          'Na het evenement markeer je wie niet kwam als ‘niet gekomen’; die tellen niet als deelname.',
          'Bewerken: titel, beschrijving, tijd, plaats, capaciteit, kosten en omslag kunnen veranderen. Veranderen tijd of plaats, dan krijgen deelnemers een melding. De capaciteit kan niet onder het aantal aanmeldingen.',
          'Annuleren: je annuleert met een reden; deelnemers en wachtenden krijgen een melding. Afgelopen evenementen kun je niet bewerken.',
        ],
      ),
      GuideTopic(
        'Een peiling maken en stemmen',
        steps: [
          'Tik op de groepspagina op ‘Peiling maken’ (eigenaar en beheerders).',
          'Schrijf de vraag en 2–10 opties.',
          'Sta eventueel meerdere keuzes toe, maak de peiling anoniem, stel een eindtijd in of koppel hem aan een evenement.',
        ],
        notes: [
          'Peilingen en uitslagen zien alleen leden van de groep.',
          'Bij een anonieme peiling ziet niemand wie waarop stemde, ook de maker niet.',
          'Is een peiling gesloten, dan kan er niet meer gestemd worden; de uitslag blijft. Een bevoegde persoon kan een peiling eerder sluiten of verwijderen.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'calendar',
    title: 'Agenda, Vanavond en ontdekken',
    summary: 'Agenda, Vanavond vrij, kleine tafel, kaart, competitie, jaaroverzicht.',
    topics: [
      GuideTopic(
        'Mijn agenda',
        notes: [
          'Het tabblad Agenda toont evenementen waaraan je meedoet, waarvoor je op goedkeuring wacht of waarvoor je op de wachtlijst staat.',
          'Zet ‘Evenementen van mijn groepen’ aan om ook alle evenementen van je groepen te zien.',
          'Wissel tussen dag-, week- en maandweergave.',
          'Evenementen die elkaar overlappen worden gemarkeerd.',
          'Via de groepspagina open je ook de agenda van die groep.',
        ],
      ),
      GuideTopic(
        'Vanavond vrij',
        steps: [
          'Tik op ‘+’ → ‘Vanavond’.',
          'Zet ‘Vanavond vrij’ aan; schrijf eventueel een korte notitie (bv. ‘koffie, korte wandeling’).',
        ],
        notes: [
          'Je status zien alleen mensen die minstens één groep met je delen.',
          'De status gaat om 04:00 vanzelf uit; je kunt hem ook altijd zelf uitzetten.',
        ],
      ),
      GuideTopic(
        'Kleine tafel',
        intro: 'Regelt een kleine afspraak met mensen die vanavond vrij zijn.',
        steps: [
          'Tik op de pagina ‘Vanavond’ op ‘Kleine tafel maken’.',
          'De app kiest 3–5 mensen die vanavond vrij zijn en groepen met je delen, en nodigt ze uit.',
          'Met wie accepteert chat je in de chat van de tafel.',
        ],
        notes: [
          'Er moeten minstens 2 mensen uit te nodigen zijn; anders staat op de kaart hoeveel er nog nodig zijn.',
          'Je kunt per avond maar aan één tafel meedoen.',
          'De tafel sluit de volgende dag om 12:00; de chat blijft leesbaar, maar je kunt niet meer schrijven.',
        ],
      ),
      GuideTopic(
        'Ontdekken met de kaart',
        steps: [
          'Tik in het tabblad Groepen rechtsboven op Kaart.',
          'Verschuif de kaart; filter op categorie, tijd (vandaag, 7 dagen) en afstand tot het midden van de kaart (5–50 km).',
          'Kies kaart- of lijstweergave.',
        ],
        notes: [
          'Op de kaart staan alleen komende evenementen en actieve groepen. Je eigen locatie wordt op de kaart niet gebruikt en aan niemand getoond.',
          'Is de kaart tijdelijk uit, dan staat erboven ‘De kaart is nu niet beschikbaar.’',
        ],
      ),
      GuideTopic(
        'Groepencompetitie',
        intro: 'Groepen in dezelfde categorie en provincie verdienen elke maand punten met goede evenementen.',
        notes: [
          'Punten: elke deelnemer, elk evenement met minstens 3 deelnemers, elk welkom en elke beoordeling van 4–5 sterren.',
          'Bij gelijke stand gaat de groep met minder leden voor.',
          'Aan het eind van de maand krijgen leden van de top drie een melding; de plaatsen staan op de competitiekaart van de groepspagina.',
        ],
      ),
      GuideTopic(
        'Jaaroverzicht en mijn ontdekkingskaart',
        steps: [
          'Tik in het tabblad Ik rechtsboven op Jaaroverzicht.',
          'Kies ‘Jaaroverzicht’, ‘Mijn ontdekkingskaart’ of ‘Mensen die ik ontmoette’.',
        ],
        notes: [
          'Jaaroverzicht: hoeveel evenementen, het totaal aantal uren, de groepen, provincies en categorieën. Je kunt het als verhaalkaart delen.',
          'Mijn ontdekkingskaart: de provincies van je evenementen kleuren in op de kaart van Turkije (‘7 / 81 provincies ontdekt’).',
          'Deze pagina’s zie alleen jij; niemand anders, tenzij je ze deelt.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'live',
    title: 'Live audio',
    summary: 'Meedoen, spreken, reacties, een uitzending starten en leiden.',
    topics: [
      GuideTopic(
        'Meedoen aan een uitzending',
        steps: [
          'Tik op de kaart ‘Nu live’ op Vandaag, op de livekaart van de groepspagina of op de melding.',
          'Eenmaal verbonden zie je wie op het podium staat en wie luistert.',
        ],
        notes: ['Alleen leden van de groep kunnen meedoen. Wie uit een uitzending is verwijderd, kan er niet meer in.'],
      ),
      GuideTopic(
        'De app gebruiken tijdens een uitzending',
        intro: 'De terugknop of de pijl omlaag linksboven haalt je niet uit de uitzending; het scherm wordt kleiner en het geluid gaat door.',
        notes: [
          'Bovenaan elke pagina verschijnt de balk ‘Je bent live’. Tik erop om terug te gaan naar de uitzending.',
          'Sta je op het podium, dan kun je je microfoon ook via de balk aan- en uitzetten.',
          'Om te vertrekken tik je op ‘Verlaten’ in het uitzendscherm. Doe je mee aan een andere uitzending, dan verlaat je de vorige.',
        ],
      ),
      GuideTopic(
        'Spreken: hand opsteken en podium',
        steps: [
          'Luister je, steek dan je hand op met de ✋-knop.',
          'Haalt een host je op het podium, dan verschijnt je microfoonknop; tik erop en spreek.',
          'Om zelf van het podium te gaan, tik je op ‘Van podium af’.',
        ],
        notes: [
          'Heeft een host je microfoon gedempt, dan kun je die niet zelf aanzetten; alleen een host kan dat weer doen.',
          'Rond de foto van wie spreekt licht een rand op.',
        ],
      ),
      GuideTopic(
        'Reacties en opmerkingen',
        notes: [
          'Met de reactieknop stuur je ❤️ 👏 😂 🔥 😮 🙌; ze zweven over het scherm en worden niet bewaard.',
          'Met de reactieknop voor tekst schrijf je een opmerking. Opmerkingen blijven bij de registratie van de uitzending.',
          'Houd je eigen opmerking ingedrukt om haar te verwijderen; die van anderen kun je melden.',
        ],
      ),
      GuideTopic(
        'Een uitzending starten',
        intro: 'De eigenaar en beheerders van de groep starten uitzendingen.',
        steps: [
          'Tik op de livekaart van de groepspagina op ‘Uitzending starten’.',
          'Schrijf een titel. Start meteen of plan voor later.',
        ],
        notes: [
          'Een groep kan tegelijk één live-uitzending en maximaal vijf geplande hebben.',
          'Een geplande uitzending staat als ‘Binnenkort’ op de groepspagina; leden tikken op ‘Herinneren’. De host kan haar hoogstens 15 minuten vóór het geplande tijdstip starten.',
          'Liveminuten hangen af van het groepspakket; het startscherm toont de resterende minuten. Zijn ze op, dan stopt de uitzending vanzelf.',
          'Verlaat de host de uitzending en komt die niet binnen 2 minuten terug, dan stopt de uitzending vanzelf.',
        ],
      ),
      GuideTopic(
        'Een uitzending leiden',
        intro: 'Hosts zijn degene die de uitzending startte en het moderatieteam van de groep.',
        notes: [
          'Tik op iemand om diegene op of van het podium te halen, of de microfoon te dempen of aan te zetten.',
          '‘Uit uitzending verwijderen’: de persoon kan niet meer terug in deze uitzending.',
          'Opgestoken handen zie je bovenaan op de kaart ‘stak een hand op’.',
          '‘Uitzending voor iedereen beëindigen’ staat in het menu rechtsboven.',
          'Op het podium staan maximaal 10 mensen, de host meegerekend. Ook hier geldt de rangregel.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'messages',
    title: 'Berichten en spraakoproepen',
    summary: 'Met wie je kunt chatten, groepschat, privacy van berichten, spraakoproepen.',
    topics: [
      GuideTopic(
        'Met wie kan ik berichten sturen?',
        notes: [
          'Privéberichten zijn alleen mogelijk met je matches en teamgenoten. Volgen geeft geen recht om berichten te sturen.',
          'Een match schrijven vraagt het pakket Matchchat, een teamgenoot schrijven het pakket Teamgenoot. Ontvangen berichten lezen is gratis.',
          'Groepschats zijn gratis; alle leden van de groep kunnen schrijven.',
          'Het scherm Berichten zit achter de knop Berichten rechtsboven op Vandaag. Het aantal ongelezen berichten staat op de knop.',
        ],
      ),
      GuideTopic(
        'Berichten schrijven en verwijderen',
        notes: [
          'Je kunt tekst (maximaal 2.000 tekens) en een foto sturen.',
          'Tijdens het versturen staat er ‘Versturen…’. Lukt het niet, dan komt de tekst met de reden terug in het vak.',
          'In een één-op-één-chat staat ‘Gezien’ zodra de ander het heeft gelezen.',
          'Je kunt je eigen bericht voor iedereen verwijderen; op die plek staat dan ‘Dit bericht is verwijderd’ en de inhoud is helemaal weg.',
        ],
      ),
      GuideTopic(
        'Privacy van berichten',
        intro: 'Het GWAY-platformteam kan je privéberichten niet lezen, je spraakoproepen niet afluisteren en niet zien wie wie heeft gebeld.',
        notes: [
          'Je kunt een bericht melden. Meldingen over privéberichten gaan naar het platformteam, over groepschatberichten naar de moderatie van de groep.',
          'De tuchtcommissie van een groep kan je privéberichten niet zien.',
        ],
      ),
      GuideTopic(
        'Toestemming voor spraakoproepen krijgen',
        intro: 'Eén-op-één spraakoproepen zijn niet voor iedereen; de eigenaar of een beheerder van een groep waarvan je lid bent geeft toestemming.',
        steps: [
          'Open Instellingen → ‘Spraakoproepen’.',
          'Kies een groep waarvan je lid bent, schrijf eventueel een korte notitie en dien het verzoek in.',
          'Je status zie je op hetzelfde scherm: in behandeling, aan of uit (met reden). De beslissing komt ook als melding.',
        ],
        notes: ['Verlaat je de groep die toestemming gaf, dan vervalt die.'],
      ),
      GuideTopic(
        'Een spraakoproep doen',
        steps: [
          'Open de chat met je match of teamgenoot.',
          'Tik rechtsboven op ‘Spraakoproep’.',
        ],
        notes: [
          'Jullie hebben allebei oproeptoestemming nodig en dezelfde pakkettoegang als voor de chat. Kun je niet bellen, dan staat de reden op de plek van de knop.',
          'Een oproep die niet binnen 30 seconden wordt opgenomen, wordt gemist. Een gesprek duurt maximaal 60 minuten.',
          'Gesprekken worden nooit opgenomen en zijn end-to-end versleuteld. Is de beveiligingscode van 12 cijfers bij jullie allebei gelijk, dan luistert niemand mee.',
          'Je kunt maar één gesprek tegelijk voeren; wie in gesprek is, kun je niet bellen.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'matching',
    title: 'Matchen en teamgenoten',
    summary: 'Vriendschap en daten, persoonlijke pakketten, teamgenoten vinden.',
    topics: [
      GuideTopic(
        'Hoe werkt matchen?',
        intro: 'Matchen helpt je vrienden of een partner te vinden onder mensen met wie je groepen deelt. Het werkt met een apart matchprofiel; zolang je het niet aanzet, ziet niemand je daar.',
        steps: [
          'Tik in het tabblad Ik rechtsboven op Matchen (op grote schermen in het menu links).',
          'Maak je matchprofiel: Vriendschap, Daten of beide; 2–6 foto’s, geboortedatum, gender, provincie, ‘over mij’.',
          'Kies bij Daten de genders die je zoekt en een leeftijdsbereik.',
          'Geef je uitdrukkelijke toestemming.',
        ],
        notes: [
          'In je stapel verschijnen alleen mensen die minstens één groep met je delen en dezelfde modus aanzetten.',
          'Bij Daten moeten jullie voorkeuren wederzijds kloppen.',
          'Als locatie wordt alleen je provincie gebruikt.',
        ],
      ),
      GuideTopic(
        'Swipen en matchen',
        notes: [
          'Naar rechts swipen: liken. Naar links: overslaan. Omhoog: superlike. De knoppen onderaan doen hetzelfde.',
          'Tik op de randen van de kaart om van foto te wisselen; de ‘i’-knop opent het hele profiel.',
          'Liken jullie elkaar in dezelfde modus, dan is het een match en krijg je een melding.',
          'Je gratis likes en superlikes per dag staan op het matchscherm.',
          'Wie je oversloeg, kan na 90 dagen opnieuw worden voorgesteld.',
        ],
      ),
      GuideTopic(
        'Persoonlijke pakketten',
        intro: 'Elke functie wordt als apart pakket verkocht; je neemt alleen wat je wilt.',
        notes: [
          'Mijn matches: zien met wie je matchte. Zonder pakket weet je dat er een match is, maar blijft de persoon verborgen.',
          'Matchchat: je matches schrijven.',
          'Wie jou leuk vindt: de lijst van mensen die jou liketen.',
          'Onbeperkt liken: onbeperkt liken, terugdraaien en filters.',
          'Superlike en Boost: meer superlikes, en één keer per dag bovenaan de stapels staan.',
          'Teamgenoot: het teamgenotenonderdeel en teamgenoten schrijven.',
          'Alles-in-één: alles.',
          'Pakketten worden vooruitbetaald, verlengen niet automatisch en koop je op het web. De prijzen staan in Matchen → Pakketten.',
        ],
      ),
      GuideTopic(
        'Matches beëindigen, pauzeren, verwijderen',
        notes: [
          'Beëindig je een match, dan sluit jullie chat, stopt het wederzijds volgen en verschijnen jullie niet meer in elkaars stapel.',
          'Matchten jullie in beide modi, dan kun je kiezen voor ‘Alleen vrienden blijven’ of ‘Alleen daten’.',
          'Pauzeer je je profiel, dan stoppen je stapel en likes; bestaande matches blijven.',
          'Al je matchgegevens (profiel, foto’s, likes, matches) verwijder je met één tik.',
          'Matchprofielen en foto’s kun je melden.',
        ],
      ),
      GuideTopic(
        'Teamgenoten vinden',
        intro: 'Vind mensen om mee te trainen, te wandelen of op te treden.',
        steps: [
          'Zet in Instellingen → ‘Voorkeuren voor teamgenoten’ ‘Ik zoek een team’ aan.',
          'Kies je activiteiten, niveau, doelen, frequentie, beschikbare tijden en eventueel je provincie.',
          'Met de knop ‘Teamgenoten vinden’ in het tabblad Ik zie je suggesties. Bij elke staat waarom (gedeelde activiteit, gedeelde groep, dezelfde provincie…).',
          'Stuur een verzoek (met een bericht van maximaal 200 tekens). Accepteert de ander, dan zijn jullie teamgenoten.',
        ],
        notes: [
          'Je provincie wordt alleen voor de suggesties gebruikt en staat niet op je profiel.',
          'Je kunt maximaal 20 verzoeken per dag sturen, en één per dag naar dezelfde persoon.',
          'Het teamgenotenonderdeel vraagt het pakket Teamgenoot.',
          'Beide kanten kunnen het teamgenootschap altijd beëindigen.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'notifications',
    title: 'Meldingen',
    summary: 'Soorten meldingen, voorkeuren en pushmeldingen.',
    topics: [
      GuideTopic(
        'Het scherm Meldingen',
        notes: [
          'Je opent het met de bel rechtsboven op Vandaag; het aantal ongelezen meldingen staat op de knop.',
          'Meldingen zijn gegroepeerd in Vandaag / Deze week / Eerder; openstaande volgverzoeken staan bovenaan.',
          'Tik op een melding om de bijbehorende pagina te openen.',
        ],
      ),
      GuideTopic(
        'Meldingsvoorkeuren',
        steps: ['Open Instellingen → ‘Meldingsvoorkeuren’.', 'Zet uit wat je niet wilt.'],
        notes: [
          'Uit te zetten: herinneringen voor evenementen, wijzigingen en annuleringen, beoordelingsverzoeken, livemeldingen, persoonlijke berichten, groepsberichten en matchmeldingen.',
          'Meldingen die jou direct aangaan, zoals een goedkeuring, je beurt op de wachtlijst of sancties, kun je niet uitzetten.',
        ],
      ),
      GuideTopic(
        'Pushmeldingen komen niet binnen',
        steps: [
          'De app vraagt bij de eerste keer openen om toestemming; heb je die niet gegeven, zet hem dan aan via Instellingen van je telefoon → Apps → GWAY → Meldingen.',
          'Controleer op Android of de kanalen ‘Berichten’, ‘Spraakoproepen’ en ‘Meldingen’ aan staan.',
          'Controleer de meldingsvoorkeuren in de app.',
        ],
        notes: ['Staat je telefoon op stil, dan maken meldingen geen geluid.'],
      ),
    ],
  ),
  GuideChapter(
    id: 'safety',
    title: 'Veiligheid, meldingen en sancties',
    summary: 'Melden, groepssancties, bezwaar, verificatie in twee stappen.',
    topics: [
      GuideTopic(
        'Iets melden',
        steps: [
          'Open het menu van het bericht, de reactie, het evenement, de livereactie, het chatbericht of het profiel.',
          'Tik op ‘Melden’, kies een reden en schrijf eventueel een korte toelichting.',
        ],
        notes: [
          'De gemelde persoon ziet de melding en jou niet. Ook de beheerders van de groep zien niet wie meldde.',
          'Meldingen over een groep gaan naar de moderatie van die groep, de rest naar het platformteam.',
          'Jezelf of je eigen inhoud kun je niet melden; dezelfde inhoud meld je één keer zolang de melding openstaat.',
        ],
      ),
      GuideTopic(
        'Groepssancties',
        notes: [
          'Waarschuwing: die wordt vastgelegd en je krijgt een melding.',
          'Dempen (1–90 dagen): je kunt in de groep niet posten of reageren en niet in de groepschat schrijven; bij live-uitzendingen luister je alleen.',
          'Verwijdering: je wordt uit de groep verwijderd; later kun je weer lid worden.',
          'Ban (tijdelijk of permanent): zolang die geldt, kun je geen lid worden, geen verzoek sturen en geen uitnodiging krijgen.',
          'Je sancties staan in Instellingen → ‘Mijn groepssancties’.',
        ],
      ),
      GuideTopic(
        'Bezwaar maken tegen een sanctie',
        steps: [
          'Open Instellingen → ‘Mijn groepssancties’.',
          'Tik naast de sanctie op ‘Bezwaar maken’ en schrijf je redenen (10–1000 tekens).',
        ],
        notes: [
          'Tegen elke sanctie kun je binnen 7 dagen één keer bezwaar maken. Tegen een noodmute niet.',
          'De groepseigenaar beslist over het bezwaar; is de eigenaar partij in het dossier, dan beslist het platformteam.',
          'Tot de beslissing blijft de sanctie gelden. De beslissing krijg je als melding.',
        ],
      ),
      GuideTopic(
        'Accountschorsing en ban',
        notes: [
          'Het platformteam kan een account dat de regels overtreedt schorsen of sluiten. De app toont je dan de reden en de einddatum.',
          'Tijdens de schorsing is je profiel zichtbaar maar je inhoud verborgen; een definitief gesloten account verschijnt nergens.',
          'Wordt per groepsbesluit illegale activiteit (zoals geweld, bedreiging, fraude) gemarkeerd, dan wordt het account geschorst tot het platform het bekijkt.',
          'Denk je dat er een vergissing is, schrijf dan het supportteam.',
        ],
      ),
      GuideTopic(
        'Verificatie in twee stappen',
        steps: [
          'Open Instellingen → ‘Verificatie in twee stappen’.',
          'Voeg een authenticator-app toe (bv. Google Authenticator) of stel op het web inloggen met vingerafdruk en gezichtsherkenning in.',
        ],
        notes: ['De ingestelde methode komt bij volgende logins eerst; sms blijft altijd als reserve.'],
      ),
    ],
  ),
  GuideChapter(
    id: 'moderation',
    title: 'Groepsmoderatie',
    summary: 'Voor bevoegden: meldingen beoordelen, tuchtdossier, stemming, ban.',
    topics: [
      GuideTopic(
        'Het moderatiescherm',
        intro: 'De moderatiekaart op de groepspagina toont het aantal openstaande taken. De eigenaar, beheerders, commissieleden en moderators zien hem.',
        notes: [
          'Meldingen: meldingen over dezelfde inhoud staan samen op één regel. Afwijzen, Inhoud verwijderen of Dossier openen.',
          'Dossiers: dossiers in stemming, resterende tijd en aantal stemmen; breng je stem uit.',
          'Sancties en bezwaren: de eigenaar beslist hier over bezwaren.',
        ],
      ),
      GuideTopic(
        'Tuchtdossier en stemming',
        steps: [
          'Kies bij een melding of in het ledenmenu op de ledenpagina ‘Tuchtdossier openen’.',
          'Kies de voorgestelde sanctie (waarschuwing, dempen, verwijdering, ban) en de duur, en schrijf de reden.',
          'Vink in noodgevallen ‘Nu dempen (24 uur)’ aan; de persoon is gedempt tot er een besluit is.',
        ],
        notes: [
          'Leden van de tuchtcommissie stemmen binnen 72 uur. In een groep zonder commissie beslist de eigenaar alleen.',
          'De beslissingsdrempel is standaard een gewone meerderheid; de eigenaar kan in de instellingen van het moderatiescherm tweederde of unaniem kiezen.',
          'Wordt de drempel gehaald, dan wordt het dossier meteen goedgekeurd en de sanctie toegepast. Stemt niemand, dan wordt het dossier afgewezen.',
          'Over één persoon kan maar één open dossier tegelijk bestaan. De rangregel geldt.',
        ],
      ),
      GuideTopic(
        'Ban zonder stemming',
        intro: 'De eigenaar en beheerders kunnen iemand bannen zonder op de commissie te wachten.',
        steps: [
          'Kies bij ‘Tuchtdossier openen’ ban als sanctie.',
          'Vink ‘Meteen toepassen, zonder stemming’ aan.',
          'Vul de duur (1–365 dagen of permanent) en de reden in.',
        ],
        notes: [
          'Een beheerder kan geen andere beheerder en niet de eigenaar bannen.',
          'Gaat het om een misdrijf, markeer het dan als ‘illegale activiteit’ en kies de categorie; het account van de persoon wordt geschorst tot het platform het bekijkt.',
          'De persoon kan binnen 7 dagen bezwaar maken.',
        ],
      ),
      GuideTopic(
        'Ingrijpen tijdens een live-uitzending',
        intro: 'Bij bijvoorbeeld intimidatie tijdens een uitzending dempt een host meteen de microfoon van de persoon of verwijdert hem uit de uitzending. Daarna kan zo nodig een tuchtdossier worden geopend.',
      ),
    ],
  ),
  GuideChapter(
    id: 'account',
    title: 'Account, privacy en support',
    summary: 'Juridische documenten, je gegevens, account verwijderen, uitloggen, support.',
    topics: [
      GuideTopic(
        'Hoe worden mijn gegevens beschermd?',
        notes: [
          'Je locatie wordt alleen voor accountbeveiliging gebruikt; hij staat niet op de kaart of je profiel.',
          'Je geboortedatum wordt aan niemand getoond.',
          'Het platformteam kan je privéberichten niet lezen.',
          'De documenten waarmee je akkoord ging, staan in Instellingen → ‘Juridische documenten’.',
        ],
      ),
      GuideTopic(
        'Mijn account verwijderen',
        steps: [
          'Open Instellingen → ‘Account verwijderen’.',
          'Bevestig het verwijderen.',
        ],
        notes: [
          'Je profiel is meteen verborgen voor anderen. Binnen 30 dagen kun je inloggen en ‘verwijderen ongedaan maken’ kiezen.',
          'Na 30 dagen worden je account, berichten, chats en bestanden definitief verwijderd.',
          'Ben je eigenaar van een groep, dan moet je eerst het eigendom overdragen of de groep verwijderen.',
        ],
      ),
      GuideTopic(
        'Uitloggen',
        intro: 'Tik helemaal onderaan in Instellingen op ‘Uitloggen’. De telefoon waarop je uitlogt, krijgt geen meldingen meer.',
      ),
      GuideTopic(
        'Het supportteam schrijven',
        steps: [
          'Open Instellingen → ‘Ondersteuning en feedback’.',
          'Tik op ‘Nieuw bericht’ en kies het type: Probleem (iets werkt niet), Verzoek (een actie voor je account, groep of betaling), Suggestie (nieuwe functie of idee).',
          'Schrijf het onderwerp en de beschrijving; je kunt maximaal 3 afbeeldingen toevoegen.',
        ],
        notes: [
          'Komt er een antwoord, dan staat in de regel in Instellingen ‘nieuw antwoord’. Status van een bericht: Nieuw, In behandeling, Opgelost, Gesloten.',
          'Ben je beheerder van een groep, dan kun je via de groepspagina ook een bericht voor die groep openen.',
        ],
      ),
    ],
  ),
];
