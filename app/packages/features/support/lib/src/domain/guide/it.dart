import '../guide.dart';

// Italian translation of tr.dart; keep chapters, topics, steps and notes in step with it.

const guideIt = <GuideChapter>[
  GuideChapter(
    id: 'start',
    title: 'Primi passi',
    summary: 'Registrazione, accesso, verifica e come muoversi nell’app.',
    topics: [
      GuideTopic(
        'Che cos’è GWAY?',
        intro: 'GWAY è una piattaforma social che riunisce comunità di ogni tipo: escursionismo, corsa, ciclismo, musica, '
            'natura, sport, arte e altro. Entri nei gruppi, partecipi agli eventi, chiacchieri nelle stanze audio dal vivo '
            'e conosci persone nuove.',
        notes: [
          'GWAY è aperto a chi ha almeno 18 anni.',
          'L’app funziona su telefono (Android, iOS) e nel browser; il tuo account è lo stesso ovunque.',
        ],
      ),
      GuideTopic(
        'Creare un account',
        steps: [
          'Nella schermata di accesso tocca «Registrati».',
          'Inserisci email e password. Puoi registrarti anche con Google o Apple.',
          'Se ti sei registrato con l’email, tocca il link di verifica arrivato nella posta in arrivo. Senza email verificata non puoi accedere.',
          'Dopo l’accesso, l’app ti guida nella verifica di sicurezza, nell’accettazione dei documenti legali, nella data di nascita e nella creazione del profilo.',
        ],
        tip: 'Se l’email di verifica non arriva, controlla la cartella spam.',
      ),
      GuideTopic(
        'Ho dimenticato la password',
        steps: [
          'Nella schermata di accesso tocca «Password dimenticata».',
          'Inserisci l’email del tuo account.',
          'Imposta una nuova password con il link nell’email che ricevi.',
        ],
      ),
      GuideTopic(
        'Verifica di sicurezza: posizione, telefono e secondo passaggio',
        intro: 'Per bloccare gli account falsi, l’app può chiederti questi passaggi.',
        steps: [
          'Posizione: l’app chiede il permesso di localizzazione. Senza, l’app non si apre e vedi una schermata che porta alle impostazioni. '
              'La posizione serve solo alla sicurezza dell’account e non viene mostrata a nessuno.',
          'Telefono: inserisci un numero del paese in cui ti trovi e il codice ricevuto via SMS. Si fa una volta; un numero può essere usato su un solo account.',
          'Secondo passaggio: a ogni nuovo accesso arriva un codice SMS al numero registrato. Se hai configurato un’app di autenticazione o l’impronta, usi quella.',
        ],
        tip: 'Dopo la verifica del telefono, accetta il suggerimento «Aggiungi impronta» o «Aggiungi Google Authenticator»: gli accessi successivi saranno più veloci. L’SMS resta come riserva.',
      ),
      GuideTopic(
        'Documenti legali e data di nascita',
        intro: 'Devi accettare le condizioni d’uso, l’informativa privacy, il consenso esplicito e le regole della community.',
        steps: [
          'Apri ogni documento e scorri fino in fondo. Senza leggerlo la casella non si può spuntare.',
          'Tocca «Ho letto e accetto» in fondo al documento.',
          'Inserisci la data di nascita. Non viene mostrata a nessuno e non si può cambiare dopo; se hai sbagliato, scrivi al supporto.',
        ],
        notes: ['Quando esce una nuova versione di un documento, l’app ti chiede di accettarla di nuovo.'],
      ),
      GuideTopic(
        'Creare il profilo',
        steps: [
          'Scegli un nome utente: 3–30 caratteri; sono ammessi lettere minuscole, numeri, trattino basso e punto.',
          'Aggiungi il nome visualizzato e la foto profilo.',
          'Scegli i tuoi interessi (massimo 10). Gruppi e suggerimenti si basano su questi.',
        ],
        notes: ['Puoi cambiare il nome utente una volta ogni 30 giorni.'],
      ),
      GuideTopic(
        'Muoversi nell’app',
        intro: 'La barra in basso ha quattro schede e al centro un pulsante «+».',
        notes: [
          'Oggi: dirette in corso, eventi che iniziano a breve e post di chi segui. In alto a destra ci sono Cerca, Notifiche e Messaggi.',
          'Gruppi: cercare e scoprire gruppi. In alto a destra ci sono Lega dei gruppi e Mappa.',
          'Calendario: gli eventi a cui partecipi e quelli dei tuoi gruppi.',
          'Io: il tuo profilo. In alto a destra ci sono Notifiche, Salvati, Match, Trova compagni di squadra, Riepilogo dell’anno e Impostazioni.',
          'Il pulsante «+»: Stasera, In arrivo, e creare un post, una storia o un gruppo.',
          'Sugli schermi grandi (web, tablet) le stesse sezioni sono nel menu a sinistra, con sotto i gruppi di cui fai parte.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'profile',
    title: 'Profilo e follower',
    summary: 'Modificare il profilo, privacy, seguire, bloccare, badge.',
    topics: [
      GuideTopic(
        'Modificare il mio profilo',
        steps: [
          'Nella scheda Io tocca Impostazioni in alto a destra, poi «Modifica profilo».',
          'Cambia foto profilo, copertina, nome visualizzato, bio e interessi.',
          'Salva.',
        ],
        notes: ['Le immagini possono pesare fino a 5 MB (JPEG, PNG o WebP).'],
      ),
      GuideTopic(
        'Account privato',
        intro: 'Con Impostazioni → «Account privato» attivo, solo i follower che approvi vedono i tuoi post e le tue storie.',
        notes: [
          'Con un account privato, chi vuole seguirti invia una richiesta; la approvi o la rifiuti in cima alla schermata Notifiche. Chi viene rifiutato non riceve avvisi.',
          'Quando rendi di nuovo pubblico l’account, le richieste in attesa vengono approvate automaticamente.',
        ],
      ),
      GuideTopic(
        'Mostrare i miei gruppi nel profilo',
        intro: 'Impostazioni → «Mostra i miei gruppi nel profilo» è disattivato per impostazione predefinita.',
        notes: [
          'Finché è disattivato, solo i membri di un gruppo vedono che ne fai parte. L’amministratore di un altro gruppo non vede in quali gruppi sei.',
          'Se lo attivi, le tue iscrizioni sono visibili a tutti nel profilo.',
          'I gruppi in cui fai parte del team di gestione (proprietario, amministratore, consiglio, moderatore) sono sempre pubblici.',
        ],
      ),
      GuideTopic(
        'Seguire e amici',
        steps: [
          'Tocca «Segui» su un profilo. Se l’account è privato parte una richiesta; inizi a seguire quando viene accettata.',
          'Tocca di nuovo lo stesso pulsante per smettere di seguire o ritirare la richiesta.',
        ],
        notes: [
          'Se vi seguite a vicenda, sul profilo compare «Amico».',
          'Puoi rimuovere qualcuno che ti segue dalla lista dei follower.',
          'Seguire non dà diritto a scrivere; i messaggi diretti sono tra match e compagni di squadra.',
          'Puoi seguire anche i gruppi; i post dei gruppi di cui fai parte arrivano già nel tuo feed.',
        ],
      ),
      GuideTopic(
        'Bloccare qualcuno',
        steps: [
          'Sul profilo della persona apri il menu «Altre opzioni» in alto a destra.',
          'Tocca «Blocca».',
        ],
        notes: [
          'Follow e richieste in entrambe le direzioni vengono eliminati. Non vedrete più i rispettivi profili, post e commenti; non potrete scrivervi né menzionarvi.',
          'La persona bloccata non compare nemmeno nel tuo mazzo di match né nei suggerimenti di compagni.',
          'Le persone bloccate sono in Impostazioni → «Account bloccati», dove puoi sbloccarle. Il follow non torna da solo.',
        ],
      ),
      GuideTopic(
        'Contributi e badge',
        intro: 'I contributi del profilo contano ciò che fai nella vita reale; like, follower e numero di post non contano.',
        notes: [
          'Partecipazione: eventi conclusi a cui hai partecipato senza essere segnato come «non presente».',
          'Organizzazione: eventi che hai creato e a cui hanno partecipato almeno altre 2 persone.',
          'Ricordo: post condivisi collegati a un evento.',
          'Esempi di badge: Primo passo (1 partecipazione), Habitué (10), Compagno di strada (25), Esploratore (3 gruppi diversi), Organizzatore, Custode di ricordi, Recensore, «Appassionato di <categoria>», badge di accoglienza e di stretta di mano, e obiettivi raggiunti.',
          'Non esistono classifiche né liste dei «migliori».',
        ],
      ),
      GuideTopic(
        'Salvati e archivio storie',
        notes: [
          'Per salvare un post tocca l’icona di salvataggio sulla sua scheda. Solo tu vedi ciò che hai salvato: Io → Salvati oppure Impostazioni → Salvati.',
          'Le storie scadute non vengono eliminate: restano in Impostazioni → «Archivio storie».',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'feed',
    title: 'Oggi, post e storie',
    summary: 'Condividere, like, commenti, esplorare e cercare.',
    topics: [
      GuideTopic(
        'La schermata Oggi',
        notes: [
          'In cima «In diretta ora»: le dirette dei tuoi gruppi. Tocca una scheda per entrare.',
          'Poi «Inizia a breve»: gli eventi delle prossime ore; prima quelli dei tuoi gruppi, poi quelli nelle province dei tuoi gruppi.',
          'Sotto c’è il feed: i tuoi post, quelli di chi segui e dei gruppi che segui o di cui fai parte, dal più recente.',
          'Trascina la schermata verso il basso per aggiornare.',
        ],
      ),
      GuideTopic(
        'Condividere un post',
        steps: [
          'Tocca il pulsante «+» in basso, poi «Post».',
          'Scegli fino a 10 foto o video. Un video può durare al massimo 60 secondi e pesare 50 MB.',
          'Per le foto scegli il formato (Originale, 1:1, 4:5, 1,91:1) e regola l’inquadratura.',
          'Scrivi una didascalia. Puoi aggiungere #hashtag e menzionare qualcuno con @nomeutente.',
          'Se vuoi, disattiva i commenti o nascondi il numero di like, poi condividi.',
        ],
        notes: [
          'I dati di posizione delle foto vengono rimossi prima del caricamento.',
          'Puoi modificare il post in seguito; cambiano solo didascalia e opzioni. Se lo elimini, vengono eliminati anche i media.',
          'Per pubblicare in un gruppo, condividi dalla pagina del gruppo. Ogni membro può pubblicare; i membri silenziati no.',
        ],
      ),
      GuideTopic(
        'Like, reazioni e commenti',
        notes: [
          'Puoi mettere like a un post o reagire con 😍 😂 😮 👏 🔥 🙏. Puoi cambiare o togliere la reazione.',
          'Chi può vedere un post può commentarlo, a meno che l’autore non abbia disattivato i commenti.',
          'Puoi rispondere a un commento e mettere like ai commenti. Le risposte hanno un solo livello.',
          'Elimini i tuoi commenti e quelli sui tuoi post. Nei post di gruppo possono eliminare i commenti anche il proprietario e gli amministratori.',
        ],
      ),
      GuideTopic(
        'Condividere una storia',
        steps: [
          'Tocca «+» → «Storia».',
          'Scegli una foto o un video di massimo 60 secondi e condividi.',
        ],
        notes: [
          'Una storia è visibile per 24 ore, poi passa nel tuo archivio.',
          'Solo tu vedi chi ha visto la tua storia.',
          'Aggiungi le storie ai momenti salienti per tenerle nel profilo.',
        ],
      ),
      GuideTopic(
        'Esplorare e cercare',
        steps: [
          'Tocca Cerca in alto a destra nella schermata Oggi.',
          'Cerca persone o #hashtag. Per i gruppi usa la scheda Gruppi.',
        ],
        notes: [
          'Esplora mostra i post con più interazioni delle ultime due settimane, da account pubblici e gruppi che non segui.',
          'Puoi condividere il link di un post; chi lo apre lo vede se ha il permesso.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'groups',
    title: 'Gruppi',
    summary: 'Trovare ed entrare nei gruppi, ruoli e pagina del gruppo.',
    topics: [
      GuideTopic(
        'Trovare un gruppo',
        notes: [
          'Nella scheda Gruppi cerca per nome o scegli una categoria.',
          'Con il pulsante Mappa in alto a destra vedi su una mappa i gruppi e gli eventi vicini.',
          'Con la Lega dei gruppi vedi i gruppi che organizzano gli eventi migliori nella tua categoria e provincia.',
          'Ogni gruppo attivo ha una pagina pubblica; non esistono gruppi segreti.',
        ],
      ),
      GuideTopic(
        'Entrare in un gruppo',
        intro: 'Il tipo di accesso del gruppo è indicato sul pulsante:',
        notes: [
          'Libero: tocca «Unisciti» e diventi subito membro.',
          'Su richiesta: invii una richiesta e un amministratore la approva. Puoi ritirarla.',
          'Su invito: un amministratore ti invita col nome utente; accetti o rifiuti nella schermata Notifiche.',
          'Link di invito: apri il link ricevuto e tocca «Unisciti al gruppo» per diventare membro, qualunque sia il tipo di accesso.',
          'Se il limite di membri del piano del gruppo è raggiunto, non possono entrare nuovi membri.',
        ],
        tip: 'Quando entri nel tuo primo gruppo, ricevi una sola volta una prova di 30 giorni del piano personale «Tutto in uno» (funzioni di match e compagni di squadra).',
      ),
      GuideTopic(
        'Uscire da un gruppo',
        steps: [
          'Tocca il pulsante di iscrizione nella pagina del gruppo.',
          'Scegli «Esci dal gruppo».',
        ],
        notes: [
          'I tuoi ruoli vengono rimossi e la tua partecipazione ai prossimi eventi del gruppo viene annullata.',
          'Il proprietario non può uscire dal gruppo; prima deve trasferire la proprietà.',
        ],
      ),
      GuideTopic(
        'Cosa c’è nella pagina di un gruppo?',
        notes: [
          'Copertina, logo, presentazione, regole, link, provincia e categoria.',
          'Scheda della diretta: dirette in corso e programmate.',
          'Eventi, recensioni «Com’è andata?» e il voto medio del gruppo.',
          'Sondaggi, obiettivi, scheda della lega e post del gruppo.',
          'Membri: il team di gestione è pubblico; l’elenco completo lo vedono solo i membri.',
          'Chat di gruppo: ogni gruppo ha un’unica chat che solo i membri leggono e scrivono.',
        ],
      ),
      GuideTopic(
        'Ruoli nel gruppo',
        intro: 'Un membro può avere più ruoli. Il numero tra parentesi è il grado.',
        notes: [
          'Proprietario (100): tutto, pagamenti e assegnazione dei ruoli.',
          'Amministratore (80): contenuti, eventi, sondaggi, approvare e invitare membri, dirette, ban senza voto, richieste di chiamate vocali.',
          'Consiglio di disciplina (60): vota sulle pratiche disciplinari; esame delle segnalazioni, silenziamento urgente, moderazione delle dirette.',
          'Moderatore (50): esame preliminare delle segnalazioni, silenziamento urgente, moderazione delle dirette.',
          'Membro (10): partecipare, pubblicare, entrare nelle dirette.',
          'Regola del grado: nessuno può sanzionare chi ha grado uguale o superiore. Il proprietario non può essere bannato.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'group-admin',
    title: 'Creare e gestire un gruppo',
    summary: 'Per proprietari e amministratori: gruppo, inviti, ruoli, piani, obiettivi.',
    topics: [
      GuideTopic(
        'Creare un gruppo',
        steps: [
          'Tocca «+» → «Gruppo».',
          'Inserisci il nome (3–60 caratteri) e l’indirizzo del gruppo. L’indirizzo è il link della pagina (/g/indirizzo) e non si può cambiare dopo.',
          'Scegli categoria e provincia. La provincia serve per la mappa e per la Lega dei gruppi.',
          'Scegli il tipo di accesso: libero, su richiesta o su invito.',
          'Aggiungi logo, copertina, presentazione, regole e fino a 5 link.',
        ],
        notes: ['Chi crea il gruppo ne è il proprietario. Il gruppo riceve anche una propria chat.'],
      ),
      GuideTopic(
        'Accettare e invitare membri',
        notes: [
          'In un gruppo su richiesta approvi o rifiuti le richieste in attesa dalla pagina del gruppo (proprietario e amministratori).',
          'Puoi inviare inviti per nome utente. Un gruppo invia al massimo 50 inviti in 24 ore; contano anche quelli ritirati.',
          'Puoi ritirare un invito finché non viene accettato.',
        ],
      ),
      GuideTopic(
        'Link di invito',
        intro: 'Il modo più semplice per portare il tuo gruppo da WhatsApp o Instagram.',
        steps: [
          'Apri la sezione «Link di invito» nella pagina del gruppo.',
          'Scegli la durata (1, 7 o 30 giorni); se vuoi, imposta un limite d’uso (1–1000 persone).',
          'Condividi il link. Chi lo apre, accede e tocca «Unisciti al gruppo» diventa membro.',
        ],
        notes: [
          'Un gruppo può avere al massimo 20 link validi contemporaneamente.',
          'Puoi revocare un link in qualsiasi momento; non si può annullare, ne crei semplicemente uno nuovo.',
          'Su WhatsApp il link condiviso mostra l’anteprima con nome e immagine del gruppo.',
        ],
      ),
      GuideTopic(
        'Assegnare ruoli e trasferire la proprietà',
        notes: [
          'Solo il proprietario assegna e toglie i ruoli: Amministratore, Consiglio di disciplina, Moderatore. I ruoli si danno solo ai membri.',
          'Puoi trasferire la proprietà a un membro attivo. Tu resti membro normale; il nuovo proprietario può darti un ruolo.',
          'Solo il proprietario può eliminare il gruppo. L’eliminazione è definitiva.',
          'Finché sei proprietario di un gruppo non puoi eliminare l’account; prima trasferisci la proprietà o elimina il gruppo.',
        ],
      ),
      GuideTopic(
        'Piani del gruppo',
        intro: 'Il piano stabilisce il numero massimo di membri, di eventi al mese e di minuti di diretta al mese del gruppo.',
        steps: [
          'Apri la scheda «Piano» nella pagina del gruppo per vedere il piano attuale, i limiti e l’utilizzo.',
          'Acquista il piano dal web. L’app mobile mostra solo lo stato del piano.',
        ],
        notes: [
          'Un gruppo senza abbonamento usa i limiti del piano gratuito.',
          'I piani sono prepagati (mensili o annuali); non c’è rinnovo automatico e nessuna carta viene salvata.',
          'Passando a un piano superiore, il tempo rimanente viene trasferito. Se rinnovi lo stesso piano, il tempo si aggiunge alla fine.',
          'I pagamenti dalla Turchia avvengono in TL con PayTR, quelli dall’estero in USD con iyzico.',
          'Se il limite di membri è raggiunto, chi c’è resta, ma non entra nessuno di nuovo.',
          'Prezzi e limiti aggiornati sono nella schermata dei piani. Il piano lo acquista il proprietario.',
        ],
      ),
      GuideTopic(
        'Obiettivi e compiti',
        intro: 'Riunisce il gruppo attorno a uno scopo comune. Proprietario e amministratori creano gli obiettivi; il premio è un badge, niente soldi o punti.',
        notes: [
          'Obiettivo personale: ogni membro ottiene un badge quando raggiunge il proprio numero.',
          'Obiettivo di gruppo: quando il totale del gruppo raggiunge il traguardo, tutti quelli che hanno contribuito ottengono un badge.',
          'Obiettivo a squadre: si formano squadre e conta il totale di ciascuna.',
          'Compito: il membro tocca «Fatto» e aggiunge una breve nota; se un amministratore approva, riceve un badge.',
          'Cosa conta: partecipazione, organizzazione o ricordi. I progressi li calcola il server.',
        ],
      ),
      GuideTopic(
        'Gestire la chat del gruppo',
        notes: [
          'Puoi impostare la chat del gruppo in modo che scrivano solo gli amministratori (come un canale di annunci).',
          'Se un messaggio inappropriato viene segnalato, arriva nella schermata di moderazione del gruppo; chi ha i permessi può rimuoverlo.',
        ],
      ),
      GuideTopic(
        'Rispondere alle richieste di chiamate vocali',
        intro: 'I membri chiedono al gruppo il permesso per le chiamate vocali individuali. Proprietario e amministratori vedono le richieste.',
        steps: [
          'Apri «Richieste di chiamate vocali» nella pagina del gruppo.',
          'Attiva la richiesta oppure rifiutala indicando il motivo.',
          'Puoi disattivare in qualsiasi momento un permesso concesso, indicando il motivo.',
        ],
        notes: ['Se la persona esce dal gruppo, viene rimossa o bannata, il permesso si disattiva automaticamente.'],
      ),
    ],
  ),
  GuideChapter(
    id: 'events',
    title: 'Eventi',
    summary: 'Partecipare, lista d’attesa, accoglienza, stretta di mano, recensioni.',
    topics: [
      GuideTopic(
        'Partecipare a un evento',
        steps: [
          'Apri la pagina dell’evento (dalla pagina del gruppo, da Oggi, dal calendario o dalla mappa).',
          'Leggi data, luogo, informazioni sulla quota, requisiti e attrezzatura necessaria.',
          'Tocca «Partecipa». Se è pieno, il pulsante dice «Entra in lista d’attesa».',
        ],
        notes: [
          'Gli eventi li vedono tutti, ma possono partecipare solo i membri del gruppo.',
          'Se sei in lista d’attesa, arriva il tuo turno quando qualcuno rinuncia e ricevi una notifica.',
          'Negli eventi con approvazione il pulsante dice «Invia richiesta»; partecipi quando l’organizzatore approva.',
          'Per rinunciare tocca «Rinuncia»; il tuo posto va alla prima persona in lista d’attesa.',
          'Le iscrizioni si chiudono quando l’evento inizia.',
        ],
      ),
      GuideTopic(
        'Quota di partecipazione',
        intro: 'La quota è indicata solo a titolo informativo. GWAY non incassa pagamenti; paghi l’organizzatore come indica (per esempio in contanti sul posto).',
      ),
      GuideTopic(
        'Aggiungi al calendario e indicazioni',
        notes: [
          '«Aggiungi al calendario» inserisce l’evento nell’app calendario del telefono.',
          'Se è segnato un punto di ritrovo, «Indicazioni» sotto la piccola mappa apre l’app di mappe del dispositivo.',
        ],
      ),
      GuideTopic(
        'Due eventi alla stessa ora',
        intro: 'Se hai un altro evento all’ora di uno a cui partecipi, l’app ti chiede se vuoi rinunciare all’altro e liberare il posto. La scelta è tua; nulla viene annullato automaticamente.',
      ),
      GuideTopic(
        'La domanda «Vieni?»',
        intro: 'Meno di 24 ore prima dell’inizio ricevi un promemoria e nella pagina dell’evento compare la scheda «Vieni?».',
        notes: [
          '«Sì, vengo»: l’organizzatore vede che ci sarai.',
          '«Non posso»: rinunci; il tuo posto va alla prima persona in lista d’attesa.',
          'Se non rispondi, non vieni tolto dalla lista.',
        ],
      ),
      GuideTopic(
        'Accoglienza: se è la tua prima volta',
        intro: 'Se è la prima volta a un evento di un gruppo, un membro volontario del gruppo può accoglierti.',
        steps: [
          'Iscriviti all’evento.',
          'Nella sezione accoglienza della pagina tocca «Voglio essere accolto»; se vuoi, scrivi come riconoscerti (es. «Ho una giacca rossa»).',
          'Quando qualcuno prende la tua richiesta, ricevi il punto d’incontro (es. «Davanti al bar all’ingresso, 08:45») come notifica.',
          'Dopo l’evento puoi ringraziare chi ti ha accolto.',
        ],
        notes: [
          'Per accogliere qualcuno, iscriviti all’evento; vedi le richieste aperte nella sezione accoglienza. Puoi accogliere fino a 3 persone per evento.',
          'Badge di accoglienza: Apriporta (1), Padrone di casa (5), Cuore della community (20).',
        ],
      ),
      GuideTopic(
        'Luogo a sorpresa',
        intro: 'In alcuni eventi il luogo è una sorpresa. La pagina mostra solo un indizio (es. «A Kadıköy, sul mare») e quando sarà svelato.',
        notes: [
          'All’ora indicata il luogo viene svelato ai partecipanti con una notifica.',
          'Chi è in lista d’attesa o non partecipa non vede il luogo. Se ti iscrivi dopo l’ora prevista, lo vedi subito.',
        ],
      ),
      GuideTopic(
        'Stretta di mano: salva chi hai conosciuto',
        intro: 'Due partecipanti allo stesso evento scansionano a vicenda il QR code per registrare che si sono conosciuti.',
        steps: [
          'La scheda «Stretta di mano» compare nella pagina da 1 ora prima dell’inizio a 6 ore dopo la fine.',
          'Mostra il tuo codice o scansiona quello dell’altra persona con la fotocamera. Senza fotocamera, digita il codice di 6 caratteri.',
        ],
        notes: [
          'Il codice cambia ogni 3 minuti; una sua foto non serve dopo.',
          'Solo tu vedi chi hai conosciuto: Io → Riepilogo dell’anno → Persone conosciute. Il profilo mostra solo il numero.',
          'La stretta di mano non dà diritto a scrivere messaggi.',
        ],
      ),
      GuideTopic(
        'Dopo l’evento',
        notes: [
          'Alla fine ricevi una richiesta di recensione; dai da 1 a 5 stelle. Il voto del gruppo è la media di queste recensioni.',
          'Aggiungi il tuo ricordo condividendo un post collegato all’evento; i ricordi contano per badge e obiettivi.',
          'Se hai partecipato, compare la scheda «C’ero anch’io»; puoi condividerla come immagine in una storia Instagram o su WhatsApp. La scheda non mostra nomi o volti di altri partecipanti.',
          'Gli eventi passati del gruppo sono nella sua pagina.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'event-admin',
    title: 'Organizzare eventi e sondaggi',
    summary: 'Per proprietari e amministratori: creazione, ripetizione, approvazione, annullamento, sondaggi.',
    topics: [
      GuideTopic(
        'Creare un evento',
        steps: [
          'Tocca «Crea evento» nella pagina del gruppo.',
          'Inserisci copertina, titolo, descrizione, inizio e, se vuoi, fine. L’inizio deve essere tra almeno 15 minuti e al massimo 1 anno.',
          'Scrivi il luogo; se vuoi, fissa il punto di ritrovo con un segnaposto sulla mappa o aggiungi un link online.',
          'Aggiungi capienza (vuoto = illimitata), quota, requisiti e lista dell’attrezzatura.',
          'Se serve, attiva «Partecipazione con approvazione» e salva.',
        ],
        notes: [
          'Il modulo mostra quanti eventi ti restano questo mese. Gli eventi annullati contano nel limite mensile del piano.',
          'Il modulo mostra anche quanti eventi hanno quel giorno altri gruppi della stessa categoria nella tua provincia; puoi cambiare data.',
        ],
      ),
      GuideTopic(
        'Evento ricorrente',
        intro: 'Durante la creazione scegli «Ogni settimana» o «Ogni due settimane» in «Ripeti» per avviare una serie (con data di fine facoltativa, al massimo 1 anno).',
        notes: [
          'Una serie tiene sempre aperte le prossime 4 settimane. Ogni data ha i propri partecipanti e la propria lista d’attesa.',
          'Se modifichi l’ultima data, quelle aperte in seguito la seguono.',
          'Con «Interrompi ripetizione» nel menu dell’evento fermi la serie; le date già aperte restano e puoi annullarle una per una.',
          'Se il limite mensile è raggiunto, la data non si apre e ricevi una notifica; si apre quando il limite lo consente.',
        ],
      ),
      GuideTopic(
        'Impostare un luogo a sorpresa',
        steps: [
          'Attiva «Luogo a sorpresa» nel modulo.',
          'Scrivi un indizio nel campo «Luogo»; inserisci a parte il luogo vero e il punto di ritrovo.',
          'Scegli quando svelarlo: 1, 3, 6, 12 o 24 ore prima dell’inizio.',
        ],
        notes: ['Se disattivi la sorpresa, il luogo nascosto viene cancellato e «Luogo» torna a essere il luogo normale.'],
      ),
      GuideTopic(
        'Gestire i partecipanti',
        notes: [
          'Con la partecipazione con approvazione, approvi o rifiuti le richieste in attesa.',
          'Nell’elenco dei partecipanti vedi chi ha confermato «Vieni?».',
          'Dopo l’evento segni gli assenti come «non presente»; non contano come partecipazione.',
          'Modifica: possono cambiare titolo, descrizione, orario, luogo, capienza, quota e copertina. Se cambiano orario o luogo, i partecipanti vengono avvisati. La capienza non può scendere sotto il numero di iscritti.',
          'Annullamento: annulli indicando il motivo; partecipanti e persone in attesa vengono avvisati. Gli eventi passati non si possono modificare.',
        ],
      ),
      GuideTopic(
        'Creare un sondaggio e votare',
        steps: [
          'Tocca «Crea sondaggio» nella pagina del gruppo (proprietario e amministratori).',
          'Scrivi la domanda e da 2 a 10 opzioni.',
          'Se vuoi, consenti scelte multiple, rendi il sondaggio anonimo, imposta una scadenza o collegalo a un evento.',
        ],
        notes: [
          'Solo i membri del gruppo vedono i sondaggi e i risultati.',
          'In un sondaggio anonimo nessuno vede chi ha votato cosa, nemmeno chi l’ha creato.',
          'Quando il sondaggio si chiude non si può più votare e i risultati restano. Chi ha i permessi può chiuderlo prima o eliminarlo.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'calendar',
    title: 'Calendario, Stasera e scoperta',
    summary: 'Calendario, Libero stasera, piccolo tavolo, mappa, lega, riepilogo dell’anno.',
    topics: [
      GuideTopic(
        'Il mio calendario',
        notes: [
          'La scheda Calendario mostra gli eventi a cui partecipi, quelli in attesa di approvazione e quelli in cui sei in lista d’attesa.',
          'Attiva «Eventi dei miei gruppi» per vedere anche tutti gli eventi dei tuoi gruppi.',
          'Passa dalla vista giorno a quella settimana o mese.',
          'Gli eventi che si sovrappongono sono evidenziati.',
          'Puoi aprire anche il calendario di un gruppo dalla sua pagina.',
        ],
      ),
      GuideTopic(
        'Libero stasera',
        steps: [
          'Tocca «+» → «Stasera».',
          'Attiva «Libero stasera»; se vuoi, scrivi una breve nota (es. «caffè, passeggiata breve»).',
        ],
        notes: [
          'Il tuo stato lo vede solo chi condivide con te almeno un gruppo.',
          'Lo stato si disattiva da solo alle 04:00; puoi spegnerlo anche tu quando vuoi.',
        ],
      ),
      GuideTopic(
        'Piccolo tavolo',
        intro: 'Organizza un piccolo incontro con chi è libero stasera.',
        steps: [
          'Nella pagina «Stasera» tocca «Crea un piccolo tavolo».',
          'L’app sceglie e invita 3–5 persone libere stasera con cui condividi dei gruppi.',
          'Con chi accetta chatti nella chat del tavolo.',
        ],
        notes: [
          'Servono almeno 2 persone invitabili; altrimenti la scheda indica quante ne mancano.',
          'Puoi partecipare a un solo tavolo per sera.',
          'Il tavolo chiude alle 12:00 del giorno dopo; la chat resta leggibile ma non si può più scrivere.',
        ],
      ),
      GuideTopic(
        'Scoprire con la mappa',
        steps: [
          'Nella scheda Gruppi tocca Mappa in alto a destra.',
          'Sposta la mappa; filtra per categoria, periodo (oggi, 7 giorni) e distanza dal centro della mappa (5–50 km).',
          'Scegli la vista mappa o elenco.',
        ],
        notes: [
          'La mappa mostra solo eventi futuri e gruppi attivi. La tua posizione non viene usata sulla mappa e non viene mostrata a nessuno.',
          'Se la mappa è temporaneamente disattivata, in alto compare «La mappa non è disponibile al momento.»',
        ],
      ),
      GuideTopic(
        'Lega dei gruppi',
        intro: 'I gruppi della stessa categoria e provincia guadagnano punti ogni mese organizzando buoni eventi.',
        notes: [
          'Punti: ogni partecipante, ogni evento con almeno 3 partecipanti, ogni accoglienza e ogni recensione da 4–5 stelle.',
          'In caso di parità passa avanti il gruppo con meno membri.',
          'Alla chiusura del mese i membri dei primi tre gruppi ricevono una notifica; le posizioni compaiono sulla scheda della lega nella pagina del gruppo.',
        ],
      ),
      GuideTopic(
        'Riepilogo dell’anno e la mia mappa di esplorazione',
        steps: [
          'Tocca Riepilogo dell’anno in alto a destra nella scheda Io.',
          'Scegli «Riepilogo dell’anno», «La mia mappa di esplorazione» o «Persone conosciute».',
        ],
        notes: [
          'Riepilogo dell’anno: numero di eventi, ore totali, gruppi, province e categorie. Puoi condividerlo come scheda per le storie.',
          'La mia mappa di esplorazione: le province dei tuoi eventi si colorano sulla mappa della Turchia («Ho esplorato 7 / 81 province»).',
          'Queste pagine le vedi solo tu; nessun altro, a meno che tu non le condivida.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'live',
    title: 'Audio dal vivo',
    summary: 'Entrare, parlare, reazioni, avviare e condurre una diretta.',
    topics: [
      GuideTopic(
        'Entrare in una diretta',
        steps: [
          'Tocca la scheda «In diretta ora» in Oggi, la scheda della diretta nella pagina del gruppo o la notifica.',
          'Una volta connesso vedi chi è sul palco e chi ascolta.',
        ],
        notes: ['Possono entrare solo i membri del gruppo. Chi viene rimosso da una diretta non può rientrarvi.'],
      ),
      GuideTopic(
        'Usare l’app durante una diretta',
        intro: 'Il tasto indietro o la freccia verso il basso in alto a sinistra non ti fanno uscire dalla diretta; la schermata si riduce e l’audio continua.',
        notes: [
          'In cima a ogni pagina compare la barra «Sei in diretta». Toccala per tornare alla diretta.',
          'Se sei sul palco, puoi anche spegnere e accendere il microfono dalla barra.',
          'Per uscire tocca «Esci» nella schermata della diretta. Se entri in un’altra diretta, esci da quella precedente.',
        ],
      ),
      GuideTopic(
        'Parlare: alzare la mano e palco',
        steps: [
          'Se stai ascoltando, alza la mano con il pulsante ✋.',
          'Quando un host ti porta sul palco compare il pulsante del microfono; toccalo e parla.',
          'Per scendere dal palco da solo tocca «Scendi dal palco».',
        ],
        notes: [
          'Se un host ha disattivato il tuo microfono, non puoi riattivarlo; solo un host può farlo.',
          'Intorno alla foto di chi parla si illumina un bordo.',
        ],
      ),
      GuideTopic(
        'Reazioni e commenti',
        notes: [
          'Con il pulsante reazioni invii ❤️ 👏 😂 🔥 😮 🙌; attraversano lo schermo e non vengono salvate.',
          'Con il pulsante commenti scrivi un commento. I commenti restano nella registrazione della diretta.',
          'Tieni premuto il tuo commento per eliminarlo; quelli degli altri puoi segnalarli.',
        ],
      ),
      GuideTopic(
        'Avviare una diretta',
        intro: 'Proprietario e amministratori del gruppo avviano le dirette.',
        steps: [
          'Tocca «Avvia diretta» nella scheda della diretta nella pagina del gruppo.',
          'Scrivi un titolo. Avvia subito o programmala per dopo.',
        ],
        notes: [
          'Un gruppo può avere contemporaneamente una diretta in corso e fino a cinque programmate.',
          'Una diretta programmata compare come «In arrivo» nella pagina del gruppo; i membri toccano «Ricordamelo». L’host può avviarla al massimo 15 minuti prima dell’orario previsto.',
          'I minuti di diretta dipendono dal piano del gruppo; la schermata di avvio mostra i minuti rimasti. Quando finiscono, la diretta termina da sola.',
          'Se l’host esce e non rientra entro 2 minuti, la diretta termina da sola.',
        ],
      ),
      GuideTopic(
        'Condurre una diretta',
        intro: 'Gli host sono chi ha avviato la diretta e il team di moderazione del gruppo.',
        notes: [
          'Tocca una persona per portarla sul palco, farla scendere o disattivare e riattivare il suo microfono.',
          '«Rimuovi dalla diretta»: la persona non può rientrare in questa diretta.',
          'Le mani alzate compaiono in alto sulla scheda «ha alzato la mano».',
          '«Termina la diretta per tutti» è nel menu in alto a destra.',
          'Sul palco possono stare al massimo 10 persone, host compreso. Anche qui vale la regola del grado.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'messages',
    title: 'Messaggi e chiamate vocali',
    summary: 'Con chi scrivere, chat di gruppo, privacy dei messaggi, chiamate vocali.',
    topics: [
      GuideTopic(
        'Con chi posso scrivere?',
        notes: [
          'I messaggi diretti sono aperti solo con i tuoi match e compagni di squadra. Seguire non dà diritto a scrivere.',
          'Scrivere a un match richiede il piano Chat match, scrivere a un compagno il piano Compagno di squadra. Leggere i messaggi ricevuti è gratis.',
          'Le chat di gruppo sono gratuite; tutti i membri del gruppo possono scrivere.',
          'La schermata Messaggi si apre col pulsante Messaggi in alto a destra in Oggi. Il numero di non letti compare sul pulsante.',
        ],
      ),
      GuideTopic(
        'Scrivere ed eliminare messaggi',
        notes: [
          'Puoi inviare testo (fino a 2.000 caratteri) e una foto.',
          'Durante l’invio compare «Invio…». Se non va a buon fine, il testo torna nel campo con il motivo.',
          'In una chat individuale compare «Visualizzato» quando l’altra persona legge.',
          'Puoi eliminare il tuo messaggio per tutti; al suo posto compare «Questo messaggio è stato eliminato» e il contenuto viene cancellato del tutto.',
        ],
      ),
      GuideTopic(
        'Privacy dei messaggi',
        intro: 'Il team della piattaforma GWAY non può leggere i tuoi messaggi privati, ascoltare le tue chiamate vocali né vedere chi ha chiamato chi.',
        notes: [
          'Puoi segnalare un messaggio. Le segnalazioni dei messaggi diretti vanno al team della piattaforma, quelle della chat di gruppo alla moderazione del gruppo.',
          'Il consiglio di disciplina di un gruppo non può vedere i tuoi messaggi diretti.',
        ],
      ),
      GuideTopic(
        'Ottenere il permesso per le chiamate vocali',
        intro: 'Le chiamate vocali individuali non sono aperte a tutti; il permesso lo concede il proprietario o un amministratore di un gruppo di cui fai parte.',
        steps: [
          'Apri Impostazioni → «Chiamate vocali».',
          'Scegli un gruppo di cui fai parte, scrivi se vuoi una breve nota e invia la richiesta.',
          'Vedi lo stato nella stessa schermata: in revisione, attivo o disattivato (con il motivo). La decisione arriva anche come notifica.',
        ],
        notes: ['Se esci dal gruppo che ha concesso il permesso, il permesso si disattiva.'],
      ),
      GuideTopic(
        'Fare una chiamata vocale',
        steps: [
          'Apri la chat con il tuo match o compagno di squadra.',
          'Tocca il pulsante «Chiamata vocale» in alto a destra.',
        ],
        notes: [
          'Entrambi dovete avere il permesso di chiamata e lo stesso accesso al piano richiesto per la chat. Se non puoi chiamare, il motivo compare al posto del pulsante.',
          'Una chiamata senza risposta entro 30 secondi diventa persa. Una chiamata dura al massimo 60 minuti.',
          'Le chiamate non vengono mai registrate e sono cifrate end-to-end. Se il codice di sicurezza di 12 cifre è uguale sui due schermi, nessuno ascolta.',
          'Si può fare una sola chiamata alla volta; chi è occupato non può essere chiamato.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'matching',
    title: 'Match e compagni di squadra',
    summary: 'Amicizia e incontri, piani personali, trovare compagni di squadra.',
    topics: [
      GuideTopic(
        'Come funziona il match?',
        intro: 'Il match ti aiuta a trovare amici o un partner tra le persone con cui condividi dei gruppi. Usa un profilo match separato; nessuno ti vede lì finché non lo attivi.',
        steps: [
          'Tocca Match in alto a destra nella scheda Io (nel menu a sinistra sugli schermi grandi).',
          'Crea il profilo match: Amicizia, Incontri o entrambi; 2–6 foto, data di nascita, genere, provincia, «su di me».',
          'In Incontri scegli i generi che cerchi e una fascia d’età.',
          'Dai il consenso esplicito.',
        ],
        notes: [
          'Nel tuo mazzo compaiono solo persone che condividono con te almeno un gruppo e hanno attivato la stessa modalità.',
          'In Incontri le preferenze di entrambi devono corrispondere.',
          'Come posizione si usa solo la tua provincia.',
        ],
      ),
      GuideTopic(
        'Scorrere e fare match',
        notes: [
          'Scorri a destra: like. A sinistra: passa. In alto: Super Like. I pulsanti in basso fanno lo stesso.',
          'Tocca i bordi della scheda per cambiare foto; il pulsante «i» apre il profilo completo.',
          'Se vi mettete like a vicenda nella stessa modalità, è match e ricevete una notifica.',
          'I like e i Super Like gratuiti del giorno sono indicati nella schermata match.',
          'Chi hai passato può esserti riproposto dopo 90 giorni.',
        ],
      ),
      GuideTopic(
        'Piani personali',
        intro: 'Ogni funzione è venduta come piano a sé; prendi solo ciò che vuoi.',
        notes: [
          'I miei match: vedere con chi hai fatto match. Senza, sai che c’è un match ma la persona resta nascosta.',
          'Chat match: scrivere ai tuoi match.',
          'Chi ti ha messo like: l’elenco di chi ti ha messo like.',
          'Like illimitati: like illimitati, annulla e filtri.',
          'Super Like e Boost: più Super Like e comparire in cima ai mazzi una volta al giorno.',
          'Compagno di squadra: la sezione compagni e scrivere ai compagni.',
          'Tutto in uno: tutto.',
          'I piani sono prepagati, non si rinnovano da soli e si acquistano dal web. I prezzi sono in Match → Piani.',
        ],
      ),
      GuideTopic(
        'Terminare, mettere in pausa ed eliminare',
        notes: [
          'Se termini un match, la chat si chiude, il follow reciproco viene rimosso e non comparite più nei rispettivi mazzi.',
          'Se avete fatto match in entrambe le modalità, puoi scegliere «Restare solo amici» o «Restare solo negli incontri».',
          'Se metti in pausa il profilo, mazzo e like si fermano; i match esistenti restano.',
          'Puoi eliminare tutti i dati match (profilo, foto, like, match) con un tocco.',
          'Puoi segnalare profili e foto del match.',
        ],
      ),
      GuideTopic(
        'Trovare compagni di squadra',
        intro: 'Trova persone con cui allenarti, fare escursioni o salire sul palco.',
        steps: [
          'In Impostazioni → «Preferenze compagni di squadra» attiva «Cerco una squadra».',
          'Scegli attività, livello, obiettivi, frequenza, orari disponibili e, se vuoi, la provincia.',
          'Nella scheda Io il pulsante «Trova compagni di squadra» mostra i suggerimenti. Ognuno indica il motivo (attività in comune, gruppo in comune, stessa provincia…).',
          'Invia una richiesta (con un messaggio di massimo 200 caratteri). Quando l’altra persona accetta, siete compagni di squadra.',
        ],
        notes: [
          'La provincia serve solo per i suggerimenti e non compare nel profilo.',
          'Puoi inviare al massimo 20 richieste al giorno e una al giorno alla stessa persona.',
          'La sezione compagni richiede il piano Compagno di squadra.',
          'Ciascuno dei due può chiudere il rapporto da compagni quando vuole.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'notifications',
    title: 'Notifiche',
    summary: 'Tipi di notifica, preferenze e notifiche del telefono.',
    topics: [
      GuideTopic(
        'La schermata Notifiche',
        notes: [
          'Si apre con la campanella in alto a destra in Oggi; il numero di non lette compare sul pulsante.',
          'Le notifiche sono raggruppate in Oggi / Questa settimana / Prima; le richieste di follow in attesa sono in cima.',
          'Tocca una notifica per aprire la pagina collegata.',
        ],
      ),
      GuideTopic(
        'Preferenze di notifica',
        steps: ['Apri Impostazioni → «Preferenze di notifica».', 'Disattiva quelle che non vuoi.'],
        notes: [
          'Si possono disattivare: promemoria degli eventi, modifiche e annullamenti, richieste di recensione, avvisi di diretta, messaggi personali, messaggi di gruppo e avvisi di match.',
          'Le notifiche che ti riguardano direttamente, come un’approvazione, il tuo turno in lista d’attesa o una sanzione, non si possono disattivare.',
        ],
      ),
      GuideTopic(
        'Non arrivano le notifiche sul telefono',
        steps: [
          'L’app chiede il permesso alla prima apertura; se non l’hai dato, attivalo in Impostazioni del telefono → App → GWAY → Notifiche.',
          'Su Android controlla che i canali «Messaggi», «Chiamate vocali» e «Notifiche» siano attivi.',
          'Controlla le preferenze di notifica nell’app.',
        ],
        notes: ['Se il telefono è in silenzioso, le notifiche non suonano.'],
      ),
    ],
  ),
  GuideChapter(
    id: 'safety',
    title: 'Sicurezza, segnalazioni e sanzioni',
    summary: 'Segnalare, sanzioni di gruppo, ricorso, verifica in due passaggi.',
    topics: [
      GuideTopic(
        'Segnalare',
        steps: [
          'Apri il menu del post, del commento, dell’evento, del commento in diretta, del messaggio o del profilo.',
          'Tocca «Segnala», scegli un motivo e, se vuoi, scrivi una breve descrizione.',
        ],
        notes: [
          'La persona segnalata non vede né la segnalazione né te. Nemmeno gli amministratori del gruppo vedono chi ha segnalato.',
          'Le segnalazioni legate a un gruppo vanno alla sua moderazione, le altre al team della piattaforma.',
          'Non puoi segnalare te stesso né i tuoi contenuti; lo stesso contenuto lo segnali una volta finché la segnalazione è aperta.',
        ],
      ),
      GuideTopic(
        'Sanzioni di gruppo',
        notes: [
          'Avvertimento: viene registrato e ricevi una notifica.',
          'Silenziamento (1–90 giorni): non puoi pubblicare né commentare nel gruppo né scrivere nella chat; nelle dirette puoi solo ascoltare.',
          'Rimozione: vieni tolto dal gruppo; in seguito puoi rientrare.',
          'Ban (temporaneo o permanente): finché dura non puoi entrare nel gruppo, inviare richieste né ricevere inviti.',
          'Le tue sanzioni sono in Impostazioni → «Le mie sanzioni di gruppo».',
        ],
      ),
      GuideTopic(
        'Fare ricorso contro una sanzione',
        steps: [
          'Apri Impostazioni → «Le mie sanzioni di gruppo».',
          'Tocca «Fai ricorso» accanto alla sanzione e scrivi le tue ragioni (10–1000 caratteri).',
        ],
        notes: [
          'Puoi fare ricorso contro ogni sanzione una volta entro 7 giorni. Contro il silenziamento urgente non si può.',
          'Sul ricorso decide il proprietario del gruppo; se è parte nella pratica, decide il team della piattaforma.',
          'In attesa della decisione la sanzione resta. La decisione ti arriva come notifica.',
        ],
      ),
      GuideTopic(
        'Sospensione e chiusura dell’account',
        notes: [
          'Il team della piattaforma può sospendere o chiudere un account che viola le regole. In tal caso l’app ti mostra il motivo e la data di fine.',
          'Durante la sospensione il profilo è visibile ma i contenuti sono nascosti; un account chiuso definitivamente non compare da nessuna parte.',
          'Se con una decisione di gruppo viene segnata un’attività illegale (come violenza, minacce o frode), l’account viene sospeso fino alla revisione della piattaforma.',
          'Se pensi che ci sia un errore, scrivi al supporto.',
        ],
      ),
      GuideTopic(
        'Verifica in due passaggi',
        steps: [
          'Apri Impostazioni → «Verifica in due passaggi».',
          'Aggiungi un’app di autenticazione (es. Google Authenticator) oppure, sul web, imposta l’accesso con impronta e riconoscimento facciale.',
        ],
        notes: ['Il metodo impostato viene proposto per primo agli accessi successivi; l’SMS resta sempre come riserva.'],
      ),
    ],
  ),
  GuideChapter(
    id: 'moderation',
    title: 'Moderazione del gruppo',
    summary: 'Per i responsabili: esame delle segnalazioni, pratiche disciplinari, voto, ban.',
    topics: [
      GuideTopic(
        'La schermata di moderazione',
        intro: 'La scheda di moderazione nella pagina del gruppo mostra il numero di attività in sospeso. La vedono proprietario, amministratori, membri del consiglio e moderatori.',
        notes: [
          'Segnalazioni: le segnalazioni dello stesso contenuto sono raccolte in una riga. Respingi, Rimuovi contenuto o Apri pratica.',
          'Pratiche: pratiche in votazione, tempo rimasto e numero di voti; vota.',
          'Sanzioni e ricorsi: qui il proprietario decide sui ricorsi.',
        ],
      ),
      GuideTopic(
        'Pratica disciplinare e votazione',
        steps: [
          'Da una segnalazione o dal menu di un membro nella pagina dei membri, scegli «Apri una pratica disciplinare».',
          'Scegli la sanzione proposta (avvertimento, silenziamento, rimozione, ban) e la durata, poi scrivi il motivo.',
          'In caso di urgenza spunta «Silenzia subito (24 ore)»; la persona resta silenziata fino alla decisione.',
        ],
        notes: [
          'I membri del consiglio di disciplina votano entro 72 ore. In un gruppo senza consiglio decide da solo il proprietario.',
          'La soglia di decisione predefinita è la maggioranza semplice; il proprietario può scegliere due terzi o unanimità nelle impostazioni della schermata di moderazione.',
          'Superata la soglia, la pratica è approvata subito e la sanzione applicata. Se nessuno vota, la pratica è respinta.',
          'Su una persona può esserci una sola pratica aperta alla volta. Vale la regola del grado.',
        ],
      ),
      GuideTopic(
        'Ban senza voto',
        intro: 'Proprietario e amministratori possono bannare qualcuno senza aspettare il consiglio.',
        steps: [
          'In «Apri una pratica disciplinare» scegli il ban come sanzione.',
          'Spunta «Applica subito, senza voto».',
          'Inserisci la durata (1–365 giorni o permanente) e il motivo.',
        ],
        notes: [
          'Un amministratore non può bannare un altro amministratore né il proprietario.',
          'Se si tratta di un reato, segnalo come «attività illegale» e scegli la categoria; l’account della persona viene sospeso fino alla revisione della piattaforma.',
          'La persona può fare ricorso entro 7 giorni.',
        ],
      ),
      GuideTopic(
        'Intervento urgente in diretta',
        intro: 'In caso di molestie durante una diretta, un host disattiva subito il microfono della persona o la rimuove dalla diretta. Poi, se serve, si apre una pratica disciplinare.',
      ),
    ],
  ),
  GuideChapter(
    id: 'account',
    title: 'Account, privacy e assistenza',
    summary: 'Documenti legali, i tuoi dati, eliminazione dell’account, uscita, assistenza.',
    topics: [
      GuideTopic(
        'Come sono protetti i miei dati?',
        notes: [
          'La posizione serve solo alla sicurezza dell’account; non compare sulla mappa né nel profilo.',
          'La tua data di nascita non viene mostrata a nessuno.',
          'Il team della piattaforma non può leggere i tuoi messaggi privati.',
          'I documenti che hai accettato sono in Impostazioni → «Documenti legali».',
        ],
      ),
      GuideTopic(
        'Eliminare il mio account',
        steps: [
          'Apri Impostazioni → «Elimina account».',
          'Conferma l’eliminazione.',
        ],
        notes: [
          'Il profilo viene subito nascosto agli altri. Entro 30 giorni puoi accedere e scegliere «annulla eliminazione».',
          'Dopo 30 giorni account, post, messaggi e file vengono eliminati definitivamente.',
          'Se sei proprietario di un gruppo, prima devi trasferire la proprietà o eliminare il gruppo.',
        ],
      ),
      GuideTopic(
        'Uscire',
        intro: 'Tocca «Esci» in fondo alle Impostazioni. Il telefono da cui esci non riceve più notifiche.',
      ),
      GuideTopic(
        'Scrivere al supporto',
        steps: [
          'Apri Impostazioni → «Assistenza e feedback».',
          'Tocca «Nuovo messaggio» e scegli il tipo: Problema (qualcosa non funziona), Richiesta (un intervento su account, gruppo o pagamento), Suggerimento (nuova funzione o idea).',
          'Scrivi oggetto e descrizione; puoi allegare fino a 3 immagini.',
        ],
        notes: [
          'Quando arriva una risposta, la riga nelle Impostazioni indica «nuova risposta». Stati del messaggio: Nuovo, In lavorazione, Risolto, Chiuso.',
          'Se sei amministratore di un gruppo, puoi aprire un messaggio per quel gruppo anche dalla sua pagina.',
        ],
      ),
    ],
  ),
];
