import '../guide.dart';

// French translation of tr.dart; keep chapters, topics, steps and notes in step with it.

const guideFr = <GuideChapter>[
  GuideChapter(
    id: 'start',
    title: 'Premiers pas',
    summary: 'Inscription, connexion, vérification et prise en main de l’application.',
    topics: [
      GuideTopic(
        'Qu’est-ce que GWAY ?',
        intro: 'GWAY est une plateforme sociale qui réunit toutes sortes de communautés : randonnée, course, vélo, musique, '
            'nature, sport, art… Tu rejoins des groupes, participes à des événements, discutes dans des salons audio en direct '
            'et rencontres de nouvelles personnes.',
        notes: [
          'GWAY est ouvert aux personnes de 18 ans et plus.',
          'L’application fonctionne sur téléphone (Android, iOS) et dans un navigateur web ; ton compte est le même partout.',
        ],
      ),
      GuideTopic(
        'Créer un compte',
        steps: [
          'Sur l’écran de connexion, touche « S’inscrire ».',
          'Saisis ton adresse e-mail et un mot de passe. Tu peux aussi t’inscrire avec Google ou Apple.',
          'Si tu t’es inscrit par e-mail, touche le lien de vérification envoyé dans ta boîte de réception. Sans e-mail vérifié, la connexion est impossible.',
          'Une fois connecté, l’application te guide dans la vérification de sécurité, l’acceptation des documents juridiques, ta date de naissance et la création de ton profil.',
        ],
        tip: 'Si l’e-mail de vérification n’arrive pas, regarde dans tes spams.',
      ),
      GuideTopic(
        'J’ai oublié mon mot de passe',
        steps: [
          'Sur l’écran de connexion, touche « Mot de passe oublié ».',
          'Saisis l’adresse e-mail de ton compte.',
          'Définis un nouveau mot de passe avec le lien reçu par e-mail.',
        ],
      ),
      GuideTopic(
        'Vérification de sécurité : position, téléphone et deuxième étape',
        intro: 'Pour empêcher les faux comptes, l’application peut te demander ces étapes.',
        steps: [
          'Position : l’application demande l’autorisation de localisation. Sans elle, l’application ne s’ouvre pas et un écran te mène aux réglages. '
              'Ta position sert uniquement à la sécurité du compte et n’est montrée à personne.',
          'Téléphone : tu saisis un numéro du pays où tu te trouves, puis le code reçu par SMS. Cela se fait une fois ; un numéro ne peut servir qu’à un seul compte.',
          'Deuxième étape : à chaque nouvelle connexion, un code SMS est envoyé à ton numéro enregistré. Si tu as configuré une application d’authentification ou l’empreinte digitale, tu l’utilises à la place.',
        ],
        tip: 'Après la vérification du téléphone, accepte la proposition « Ajouter l’empreinte » ou « Ajouter Google Authenticator » pour te connecter plus vite ensuite. Le SMS reste en secours.',
      ),
      GuideTopic(
        'Documents juridiques et date de naissance',
        intro: 'Tu dois accepter les conditions d’utilisation, la notice d’information, le consentement explicite et les règles de la communauté.',
        steps: [
          'Ouvre chaque document et fais défiler jusqu’à la fin. La case ne peut être cochée qu’après lecture.',
          'Touche « J’ai lu et j’accepte » à la fin du document.',
          'Saisis ta date de naissance. Elle n’est montrée à personne et ne peut pas être modifiée ensuite ; en cas d’erreur, écris à l’équipe d’assistance.',
        ],
        notes: ['Quand une nouvelle version d’un document est publiée, l’application te demande de l’accepter à nouveau.'],
      ),
      GuideTopic(
        'Créer ton profil',
        steps: [
          'Choisis un nom d’utilisateur : 3 à 30 caractères ; minuscules, chiffres, tiret bas et point autorisés.',
          'Ajoute ton nom affiché et ta photo de profil.',
          'Choisis tes centres d’intérêt (10 au maximum). Les groupes et suggestions en dépendent.',
        ],
        notes: ['Tu peux changer ton nom d’utilisateur une fois tous les 30 jours.'],
      ),
      GuideTopic(
        'Se repérer dans l’application',
        intro: 'La barre du bas compte quatre onglets et un bouton « + » au centre.',
        notes: [
          'Aujourd’hui : les directs en cours, les événements qui commencent bientôt et les publications des personnes que tu suis. En haut à droite : Rechercher, Notifications et Messages.',
          'Groupes : rechercher et découvrir des groupes. En haut à droite : Ligue des groupes et Carte.',
          'Agenda : les événements auxquels tu participes et ceux de tes groupes.',
          'Moi : ton profil. En haut à droite : Notifications, Enregistrés, Rencontres, Trouver des coéquipiers, Bilan de l’année et Paramètres.',
          'Le bouton « + » : Ce soir, À venir, et créer une publication, une story ou un groupe.',
          'Sur grand écran (web, tablette), les mêmes sections sont dans le menu de gauche, avec en dessous les groupes dont tu es membre.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'profile',
    title: 'Profil et abonnements',
    summary: 'Modifier son profil, confidentialité, suivre, bloquer, badges.',
    topics: [
      GuideTopic(
        'Modifier mon profil',
        steps: [
          'Dans l’onglet Moi, touche Paramètres en haut à droite, puis « Modifier le profil ».',
          'Change ta photo de profil, ta couverture, ton nom affiché, ta bio et tes centres d’intérêt.',
          'Enregistre.',
        ],
        notes: ['Les images peuvent faire jusqu’à 5 Mo (JPEG, PNG ou WebP).'],
      ),
      GuideTopic(
        'Compte privé',
        intro: 'Quand Paramètres → « Compte privé » est activé, seuls les abonnés que tu as acceptés voient tes publications et tes stories.',
        notes: [
          'Avec un compte privé, les personnes qui veulent te suivre envoient une demande ; tu l’acceptes ou la refuses en haut de l’écran Notifications. La personne refusée n’est pas prévenue.',
          'Quand tu repasses ton compte en public, les demandes en attente sont acceptées automatiquement.',
        ],
      ),
      GuideTopic(
        'Afficher mes groupes sur mon profil',
        intro: 'Paramètres → « Afficher mes groupes sur mon profil » est désactivé par défaut.',
        notes: [
          'Tant que c’est désactivé, seuls les membres d’un groupe voient que tu en fais partie. L’admin d’un autre groupe ne voit pas dans quels groupes tu es.',
          'Si tu l’actives, tes adhésions sont visibles par tous sur ton profil.',
          'Les groupes où tu fais partie de l’équipe de gestion (propriétaire, admin, conseil, modérateur) sont toujours publics.',
        ],
      ),
      GuideTopic(
        'Suivre et amis',
        steps: [
          'Touche « Suivre » sur un profil. Si le compte est privé, une demande part ; tu suis la personne une fois la demande acceptée.',
          'Touche à nouveau le même bouton pour ne plus suivre ou annuler la demande.',
        ],
        notes: [
          'Si vous vous suivez mutuellement, le profil affiche « Ami ».',
          'Tu peux retirer quelqu’un de ta liste d’abonnés.',
          'Suivre quelqu’un ne permet pas de lui écrire ; les messages privés sont réservés aux matchs et aux coéquipiers.',
          'Tu peux aussi suivre des groupes ; les publications des groupes dont tu es membre arrivent déjà dans ton fil.',
        ],
      ),
      GuideTopic(
        'Bloquer quelqu’un',
        steps: [
          'Sur le profil de la personne, ouvre le menu « Plus d’options » en haut à droite.',
          'Touche « Bloquer ».',
        ],
        notes: [
          'Les abonnements et demandes dans les deux sens sont supprimés. Vous ne voyez plus vos profils, publications et commentaires ; vous ne pouvez ni vous écrire ni vous mentionner.',
          'La personne bloquée n’apparaît plus non plus dans ta pile de rencontres ni dans les suggestions de coéquipiers.',
          'Tu retrouves les personnes bloquées dans Paramètres → « Comptes bloqués », où tu peux les débloquer. L’abonnement ne revient pas automatiquement.',
        ],
      ),
      GuideTopic(
        'Contributions et badges',
        intro: 'Les contributions de ton profil comptent ce que tu fais dans la vraie vie ; les likes, abonnés et nombres de publications ne comptent pas.',
        notes: [
          'Participation : événements terminés auxquels tu as participé sans être marqué « absent ».',
          'Organisation : événements que tu as créés et auxquels au moins 2 autres personnes ont participé.',
          'Souvenir : publications partagées liées à un événement.',
          'Exemples de badges : Premier pas (1 participation), Habitué (10), Compagnon de route (25), Explorateur (3 groupes différents), Organisateur, Gardien de souvenirs, Donneur d’avis, « Fan de <catégorie> », badges d’accueil et de poignée de main, et objectifs atteints.',
          'Il n’y a ni classement ni liste des « meilleurs ».',
        ],
      ),
      GuideTopic(
        'Enregistrés et archives des stories',
        notes: [
          'Pour enregistrer une publication, touche l’icône d’enregistrement sur sa carte. Toi seul vois ce que tu as enregistré : Moi → Enregistrés ou Paramètres → Enregistrés.',
          'Les stories expirées ne sont pas supprimées, elles restent dans Paramètres → « Archives des stories ».',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'feed',
    title: 'Aujourd’hui, publications et stories',
    summary: 'Partager, likes, commentaires, explorer et rechercher.',
    topics: [
      GuideTopic(
        'L’écran Aujourd’hui',
        notes: [
          'Tout en haut, « En direct » : les directs de tes groupes. Touche une carte pour rejoindre.',
          'Ensuite, « Bientôt » : les événements des prochaines heures ; d’abord ceux de tes groupes, puis ceux des provinces de tes groupes.',
          'En dessous, le fil : tes publications, celles des personnes que tu suis et des groupes que tu suis ou dont tu es membre, des plus récentes aux plus anciennes.',
          'Tire l’écran vers le bas pour actualiser.',
        ],
      ),
      GuideTopic(
        'Partager une publication',
        steps: [
          'Touche le bouton « + » en bas, puis « Publication ».',
          'Choisis jusqu’à 10 photos ou vidéos. Une vidéo peut durer 60 secondes et peser 50 Mo au maximum.',
          'Pour les photos, choisis le format (Original, 1:1, 4:5, 1,91:1) et ajuste le cadrage.',
          'Écris une légende. Tu peux ajouter des #hashtags et mentionner quelqu’un avec @nomdutilisateur.',
          'Si tu veux, désactive les commentaires ou masque le nombre de likes, puis partage.',
        ],
        notes: [
          'Les données de localisation de tes photos sont supprimées avant l’envoi.',
          'Tu peux modifier une publication ensuite ; seuls la légende et les options changent. Si tu la supprimes, ses médias sont supprimés aussi.',
          'Pour publier dans un groupe, partage depuis la page du groupe. Chaque membre peut publier, sauf les membres en sourdine.',
        ],
      ),
      GuideTopic(
        'Likes, réactions et commentaires',
        notes: [
          'Tu peux liker une publication ou réagir avec 😍 😂 😮 👏 🔥 🙏. Tu peux changer ou retirer ta réaction.',
          'Toute personne qui voit une publication peut commenter, sauf si l’auteur a désactivé les commentaires.',
          'Tu peux répondre à un commentaire et liker des commentaires. Les réponses n’ont qu’un niveau.',
          'Tu supprimes tes propres commentaires et ceux de tes publications. Sur les publications de groupe, le propriétaire et les admins peuvent aussi supprimer les commentaires.',
        ],
      ),
      GuideTopic(
        'Partager une story',
        steps: [
          'Touche « + » → « Story ».',
          'Choisis une photo ou une vidéo de 60 secondes maximum et partage.',
        ],
        notes: [
          'Une story est visible 24 heures, puis passe dans tes archives.',
          'Toi seul vois qui a regardé ta story.',
          'Ajoute des stories à tes moments forts pour les garder sur ton profil.',
        ],
      ),
      GuideTopic(
        'Explorer et rechercher',
        steps: [
          'Touche Rechercher en haut à droite de l’écran Aujourd’hui.',
          'Recherche des personnes ou des #hashtags. Pour les groupes, utilise l’onglet Groupes.',
        ],
        notes: [
          'Explorer montre les publications des deux dernières semaines qui suscitent le plus d’interactions, issues de comptes publics et de groupes que tu ne suis pas.',
          'Tu peux partager le lien d’une publication ; la personne qui l’ouvre la voit si elle y a accès.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'groups',
    title: 'Groupes',
    summary: 'Trouver et rejoindre un groupe, rôles et page de groupe.',
    topics: [
      GuideTopic(
        'Trouver un groupe',
        notes: [
          'Dans l’onglet Groupes, cherche par nom ou choisis une catégorie.',
          'Avec le bouton Carte en haut à droite, vois les groupes et événements autour de toi sur une carte.',
          'Avec la Ligue des groupes, vois les groupes qui organisent les meilleurs événements dans ta catégorie et ta province.',
          'Chaque groupe actif a une page publique ; il n’existe pas de groupe secret.',
        ],
      ),
      GuideTopic(
        'Rejoindre un groupe',
        intro: 'Le mode d’adhésion du groupe est indiqué sur le bouton :',
        notes: [
          'Libre : touche « Rejoindre » et tu deviens membre tout de suite.',
          'Sur demande : tu envoies une demande ; un admin du groupe l’accepte. Tu peux annuler ta demande.',
          'Sur invitation : un admin t’invite avec ton nom d’utilisateur ; tu acceptes ou refuses sur l’écran Notifications.',
          'Lien d’invitation : ouvre le lien reçu et touche « Rejoindre le groupe » pour devenir membre, quel que soit le mode d’adhésion.',
          'Si la limite de membres de la formule du groupe est atteinte, aucun nouveau membre ne peut entrer.',
        ],
        tip: 'Quand tu rejoins ton premier groupe, tu bénéficies une seule fois d’un essai de 30 jours de la formule personnelle « Tout-en-un » (rencontres et coéquipiers).',
      ),
      GuideTopic(
        'Quitter un groupe',
        steps: [
          'Touche le bouton d’adhésion sur la page du groupe.',
          'Choisis « Quitter le groupe ».',
        ],
        notes: [
          'Tes rôles sont supprimés et tu es retiré des prochains événements du groupe.',
          'Le propriétaire ne peut pas quitter le groupe ; il doit d’abord transférer la propriété.',
        ],
      ),
      GuideTopic(
        'Que trouve-t-on sur une page de groupe ?',
        notes: [
          'Couverture, logo, présentation, règles, liens, province et catégorie.',
          'Carte du direct : directs en cours et programmés.',
          'Événements, avis « C’était comment ? » et note moyenne du groupe.',
          'Sondages, objectifs, carte de ligue et publications du groupe.',
          'Membres : l’équipe de gestion est publique ; seuls les membres voient la liste complète.',
          'Discussion de groupe : chaque groupe a une seule discussion, lue et écrite uniquement par ses membres.',
        ],
      ),
      GuideTopic(
        'Les rôles dans un groupe',
        intro: 'Un membre peut avoir plusieurs rôles. Le nombre entre parenthèses est le rang.',
        notes: [
          'Propriétaire (100) : tout, paiement et attribution des rôles.',
          'Admin (80) : contenus, événements, sondages, acceptation et invitation des membres, directs, bannissement sans vote, demandes d’appels vocaux.',
          'Conseil de discipline (60) : vote sur les dossiers disciplinaires ; examen des signalements, sourdine d’urgence, modération des directs.',
          'Modérateur (50) : premier examen des signalements, sourdine d’urgence, modération des directs.',
          'Membre (10) : participer, publier, rejoindre les directs.',
          'Règle de rang : personne ne peut sanctionner quelqu’un de rang égal ou supérieur. Le propriétaire ne peut pas être banni.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'group-admin',
    title: 'Créer et gérer un groupe',
    summary: 'Pour propriétaires et admins : groupe, invitations, rôles, formules, objectifs.',
    topics: [
      GuideTopic(
        'Créer un groupe',
        steps: [
          'Touche « + » → « Groupe ».',
          'Saisis le nom (3 à 60 caractères) et l’adresse du groupe. L’adresse est le lien de la page (/g/adresse) et ne peut plus être modifiée.',
          'Choisis la catégorie et la province. La province sert à la carte et à la Ligue des groupes.',
          'Choisis le mode d’adhésion : libre, sur demande ou sur invitation.',
          'Ajoute le logo, la couverture, la présentation, les règles et jusqu’à 5 liens.',
        ],
        notes: ['La personne qui crée le groupe en est propriétaire. Le groupe reçoit aussi sa propre discussion.'],
      ),
      GuideTopic(
        'Accepter et inviter des membres',
        notes: [
          'Dans un groupe sur demande, tu acceptes ou refuses les demandes en attente sur la page du groupe (propriétaire et admins).',
          'Tu peux envoyer des invitations par nom d’utilisateur. Un groupe peut envoyer 50 invitations au maximum en 24 heures ; les invitations annulées comptent aussi.',
          'Tu peux annuler une invitation tant qu’elle n’est pas acceptée.',
        ],
      ),
      GuideTopic(
        'Lien d’invitation',
        intro: 'Le moyen le plus simple de faire venir ton groupe depuis WhatsApp ou Instagram.',
        steps: [
          'Ouvre la section « Lien d’invitation » sur la page du groupe.',
          'Choisis la durée (1, 7 ou 30 jours) ; tu peux fixer une limite d’utilisation (1 à 1000 personnes).',
          'Partage le lien. La personne qui l’ouvre, se connecte et touche « Rejoindre le groupe » devient membre.',
        ],
        notes: [
          'Un groupe peut avoir 20 liens valides au maximum en même temps.',
          'Tu peux révoquer un lien à tout moment ; c’est irréversible, il suffit d’en créer un nouveau.',
          'Sur WhatsApp, le lien partagé s’affiche avec le nom et l’image du groupe.',
        ],
      ),
      GuideTopic(
        'Attribuer des rôles et transférer la propriété',
        notes: [
          'Seul le propriétaire donne et retire les rôles : Admin, Conseil de discipline, Modérateur. Un rôle ne peut être donné qu’à un membre.',
          'Tu peux transférer la propriété à un membre actif. Tu restes simple membre ; le nouveau propriétaire peut te donner un rôle.',
          'Seul le propriétaire peut supprimer le groupe. La suppression est définitive.',
          'Tant que tu es propriétaire d’un groupe, tu ne peux pas supprimer ton compte ; transfère d’abord la propriété ou supprime le groupe.',
        ],
      ),
      GuideTopic(
        'Formules de groupe',
        intro: 'La formule fixe le nombre maximal de membres, d’événements par mois et de minutes de direct par mois.',
        steps: [
          'Ouvre la carte « Formule » sur la page du groupe pour voir la formule actuelle, ses limites et l’utilisation.',
          'Achète la formule sur le web. L’application mobile affiche seulement l’état de la formule.',
        ],
        notes: [
          'Un groupe sans abonnement utilise les limites de la formule gratuite.',
          'Les formules sont prépayées (mensuelles ou annuelles) ; pas de renouvellement automatique, aucune carte n’est enregistrée.',
          'En passant à une formule supérieure, le temps restant est reporté. Si tu renouvelles la même formule, la durée s’ajoute à la fin.',
          'Les paiements depuis la Turquie passent par PayTR en TL, ceux de l’étranger par iyzico en USD.',
          'Si la limite de membres est atteinte, les membres restent mais aucun nouveau ne peut entrer.',
          'Les prix et limites actuels figurent sur l’écran des formules. C’est le propriétaire qui achète la formule.',
        ],
      ),
      GuideTopic(
        'Objectifs et missions',
        intro: 'Rassemble le groupe autour d’un but commun. Le propriétaire et les admins créent les objectifs ; la récompense est un badge, sans argent ni points.',
        notes: [
          'Objectif personnel : chaque membre reçoit un badge en atteignant son propre chiffre.',
          'Objectif de groupe : quand le total du groupe atteint la cible, tous ceux qui ont contribué reçoivent un badge.',
          'Objectif d’équipe : des équipes sont formées et le total de chaque équipe est compté.',
          'Mission : le membre touche « C’est fait » et ajoute une courte note ; si un admin valide, un badge est attribué.',
          'Ce qui compte : participation, organisation ou souvenirs. Le serveur calcule la progression.',
        ],
      ),
      GuideTopic(
        'Gérer la discussion du groupe',
        notes: [
          'Tu peux régler la discussion de groupe pour que seuls les admins écrivent (comme un canal d’annonces).',
          'Si un message inapproprié est signalé, il arrive dans l’écran de modération du groupe ; une personne habilitée peut le retirer.',
        ],
      ),
      GuideTopic(
        'Répondre aux demandes d’appels vocaux',
        intro: 'Les membres demandent au groupe l’autorisation de passer des appels vocaux privés. Le propriétaire et les admins voient les demandes.',
        steps: [
          'Ouvre « Demandes d’appels vocaux » sur la page du groupe.',
          'Active la demande, ou refuse-la avec un motif.',
          'Tu peux retirer à tout moment une autorisation accordée, avec un motif.',
        ],
        notes: ['Si la personne quitte le groupe, en est exclue ou bannie, l’autorisation prend fin automatiquement.'],
      ),
    ],
  ),
  GuideChapter(
    id: 'events',
    title: 'Événements',
    summary: 'Participer, liste d’attente, accueil, poignée de main, avis.',
    topics: [
      GuideTopic(
        'Participer à un événement',
        steps: [
          'Ouvre la page de l’événement (depuis la page du groupe, Aujourd’hui, l’agenda ou la carte).',
          'Lis la date, le lieu, le tarif, les conditions de participation et l’équipement nécessaire.',
          'Touche « Participer ». S’il n’y a plus de place, le bouton indique « Rejoindre la liste d’attente ».',
        ],
        notes: [
          'Tout le monde voit les événements, mais seuls les membres du groupe peuvent participer.',
          'Si tu es sur liste d’attente, ton tour vient quand quelqu’un se désiste et tu reçois une notification.',
          'Pour un événement avec validation, le bouton indique « Envoyer une demande » ; tu participes quand l’organisateur accepte.',
          'Pour te désister, touche « Annuler » ; ta place passe à la première personne de la liste d’attente.',
          'Les inscriptions ferment au début de l’événement.',
        ],
      ),
      GuideTopic(
        'Tarif de participation',
        intro: 'Le tarif est indiqué à titre d’information. GWAY n’encaisse aucun paiement ; tu paies l’organisateur comme il l’indique (par exemple en espèces sur place).',
      ),
      GuideTopic(
        'Ajouter à l’agenda et itinéraire',
        notes: [
          '« Ajouter à l’agenda » ajoute l’événement à l’application agenda de ton téléphone.',
          'Si un point de rendez-vous est indiqué, « Itinéraire » sous la petite carte ouvre l’application de cartes de ton appareil.',
        ],
      ),
      GuideTopic(
        'Deux événements à la même heure',
        intro: 'Si tu as un autre événement à l’heure d’un événement auquel tu participes, l’application te demande si tu veux te désister de l’autre pour libérer ta place. C’est ton choix ; rien n’est annulé automatiquement.',
      ),
      GuideTopic(
        'La question « Tu viens ? »',
        intro: 'Moins de 24 heures avant le début, tu reçois un rappel et la carte « Tu viens ? » apparaît sur la page de l’événement.',
        notes: [
          '« Oui, je viens » : l’organisateur voit que tu viens.',
          '« Je ne peux pas » : tu te désistes ; ta place passe à la première personne de la liste d’attente.',
          'Sans réponse, tu n’es pas retiré de la liste.',
        ],
      ),
      GuideTopic(
        'Accueil : si c’est ta première fois',
        intro: 'Si c’est ta première fois à un événement d’un groupe, un membre bénévole du groupe peut t’accueillir.',
        steps: [
          'Inscris-toi à l’événement.',
          'Dans la section accueil de la page, touche « Je veux être accueilli » ; tu peux ajouter une note pour te reconnaître (ex. « Je porte une veste rouge »).',
          'Quand un accueillant prend ta demande, tu reçois son point de rendez-vous (ex. « Devant le café de l’entrée, 08:45 ») en notification.',
          'Après l’événement, tu peux remercier ton accueillant.',
        ],
        notes: [
          'Pour accueillir, inscris-toi à l’événement ; tu vois les demandes ouvertes dans la section accueil. Tu peux accueillir jusqu’à 3 personnes par événement.',
          'Badges d’accueil : Porte ouverte (1), Hôte (5), Cœur de la communauté (20).',
        ],
      ),
      GuideTopic(
        'Lieu surprise',
        intro: 'Pour certains événements, le lieu est une surprise. La page affiche seulement un indice (ex. « À Kadıköy, au bord de la mer ») et l’heure de la révélation.',
        notes: [
          'À l’heure prévue, le lieu est révélé aux participants par notification.',
          'Les personnes en liste d’attente et les non-inscrits ne voient pas le lieu. Si tu t’inscris après l’heure de révélation, tu le vois tout de suite.',
        ],
      ),
      GuideTopic(
        'Poignée de main : garder une trace des rencontres',
        intro: 'Deux participants d’un même événement scannent leur QR code mutuel pour enregistrer qu’ils se sont rencontrés.',
        steps: [
          'La carte « Poignée de main » apparaît sur la page de 1 heure avant le début jusqu’à 6 heures après la fin.',
          'Montre ton code ou scanne celui de l’autre avec l’appareil photo. Sans caméra, saisis le code de 6 caractères.',
        ],
        notes: [
          'Le code change toutes les 3 minutes ; une photo ne sert à rien plus tard.',
          'Toi seul vois tes rencontres : Moi → Bilan de l’année → Mes rencontres. Ton profil n’affiche que le nombre.',
          'Une poignée de main ne permet pas d’envoyer des messages.',
        ],
      ),
      GuideTopic(
        'Après l’événement',
        notes: [
          'Une fois terminé, tu reçois une demande d’avis ; donne de 1 à 5 étoiles. La note du groupe est la moyenne de ces avis.',
          'Ajoute ton souvenir en partageant une publication liée à l’événement ; les souvenirs comptent pour les badges et objectifs.',
          'Si tu y étais, la carte « J’y étais aussi » apparaît ; tu peux la partager en image dans une story Instagram ou sur WhatsApp. Elle ne montre ni le nom ni le visage d’autres participants.',
          'Les événements passés du groupe sont visibles sur sa page.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'event-admin',
    title: 'Organiser des événements et des sondages',
    summary: 'Pour propriétaires et admins : création, répétition, validation, annulation, sondage.',
    topics: [
      GuideTopic(
        'Créer un événement',
        steps: [
          'Touche « Créer un événement » sur la page du groupe.',
          'Saisis la couverture, le titre, la description, l’heure de début et, si tu veux, de fin. Le début doit être dans au moins 15 minutes et au plus 1 an.',
          'Indique le lieu ; tu peux épingler le point de rendez-vous sur la carte ou ajouter un lien en ligne.',
          'Ajoute la capacité (vide = illimitée), le tarif, les conditions de participation et la liste d’équipement.',
          'Si besoin, active « Participation sur validation » et enregistre.',
        ],
        notes: [
          'Le formulaire indique combien d’événements il te reste ce mois-ci. Les événements annulés comptent dans la limite mensuelle de ta formule.',
          'Le formulaire montre aussi combien d’événements d’autres groupes de la même catégorie ont lieu ce jour-là dans ta province ; tu peux changer la date.',
        ],
      ),
      GuideTopic(
        'Événement récurrent',
        intro: 'À la création, choisis « Chaque semaine » ou « Toutes les deux semaines » dans « Répéter » pour lancer une série (avec date de fin facultative, 1 an maximum).',
        notes: [
          'Une série garde toujours les 4 prochaines semaines ouvertes. Chaque date a ses propres participants et sa liste d’attente.',
          'Si tu modifies la dernière date, les dates ouvertes ensuite suivent ce modèle.',
          '« Arrêter la répétition » dans le menu de l’événement stoppe la série ; les dates déjà ouvertes restent, tu peux les annuler une par une.',
          'Si la limite mensuelle est atteinte, la date ne s’ouvre pas et tu es prévenu ; elle s’ouvre dès que la limite le permet.',
        ],
      ),
      GuideTopic(
        'Configurer un lieu surprise',
        steps: [
          'Active « Lieu surprise » dans le formulaire.',
          'Écris un indice dans le champ « Lieu » ; saisis le vrai lieu et le point de rendez-vous à part.',
          'Choisis le moment de la révélation : 1, 3, 6, 12 ou 24 heures avant le début.',
        ],
        notes: ['Si tu désactives la surprise, le lieu caché est supprimé et « Lieu » redevient le lieu normal.'],
      ),
      GuideTopic(
        'Gérer les participants',
        notes: [
          'Avec la validation, tu acceptes ou refuses les demandes en attente.',
          'La liste des participants montre qui a confirmé « Tu viens ? ».',
          'Après l’événement, tu marques les absents comme « absent » ; ils ne comptent pas comme participants.',
          'Modification : titre, description, horaire, lieu, capacité, tarif et couverture peuvent changer. Si l’horaire ou le lieu change, les participants sont prévenus. La capacité ne peut pas descendre sous le nombre d’inscrits.',
          'Annulation : tu annules avec un motif ; participants et personnes en attente sont prévenus. Un événement passé ne peut plus être modifié.',
        ],
      ),
      GuideTopic(
        'Créer un sondage et voter',
        steps: [
          'Touche « Créer un sondage » sur la page du groupe (propriétaire et admins).',
          'Écris la question et 2 à 10 options.',
          'Tu peux autoriser plusieurs choix, rendre le sondage anonyme, fixer une fin ou le lier à un événement.',
        ],
        notes: [
          'Seuls les membres du groupe voient les sondages et leurs résultats.',
          'Dans un sondage anonyme, personne ne voit qui a voté quoi, pas même son créateur.',
          'Une fois le sondage clos, on ne peut plus voter et les résultats restent. Une personne habilitée peut le clore plus tôt ou le supprimer.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'calendar',
    title: 'Agenda, Ce soir et découverte',
    summary: 'Agenda, Libre ce soir, petite table, carte, ligue, bilan de l’année.',
    topics: [
      GuideTopic(
        'Mon agenda',
        notes: [
          'L’onglet Agenda montre les événements auxquels tu participes, ceux en attente de validation et ceux où tu es en liste d’attente.',
          'Active « Événements de mes groupes » pour voir aussi tous les événements de tes groupes.',
          'Passe de la vue jour à la vue semaine ou mois.',
          'Les événements qui se chevauchent sont signalés.',
          'Tu peux aussi ouvrir l’agenda d’un groupe depuis sa page.',
        ],
      ),
      GuideTopic(
        'Libre ce soir',
        steps: [
          'Touche « + » → « Ce soir ».',
          'Active « Libre ce soir » ; tu peux ajouter une courte note (ex. « café, petite balade »).',
        ],
        notes: [
          'Seules les personnes qui partagent au moins un groupe avec toi voient ton statut.',
          'Le statut se désactive automatiquement à 04:00 ; tu peux aussi le couper toi-même à tout moment.',
        ],
      ),
      GuideTopic(
        'Petite table',
        intro: 'Organise une petite rencontre avec des personnes libres ce soir.',
        steps: [
          'Sur la page « Ce soir », touche « Créer une petite table ».',
          'L’application choisit et invite 3 à 5 personnes libres ce soir avec qui tu partages des groupes.',
          'Tu discutes avec celles qui acceptent dans la discussion de la table.',
        ],
        notes: [
          'Il faut au moins 2 personnes invitables ; sinon la carte indique combien il en manque.',
          'Tu ne peux rejoindre qu’une table par soirée.',
          'La table ferme le lendemain à 12:00 ; la discussion reste lisible mais on ne peut plus écrire.',
        ],
      ),
      GuideTopic(
        'Découvrir avec la carte',
        steps: [
          'Dans l’onglet Groupes, touche Carte en haut à droite.',
          'Déplace la carte ; filtre par catégorie, période (aujourd’hui, 7 jours) et distance depuis le centre de la carte (5 à 50 km).',
          'Choisis la vue carte ou liste.',
        ],
        notes: [
          'La carte n’affiche que les événements à venir et les groupes actifs. Ta position n’est pas utilisée sur la carte et n’est montrée à personne.',
          'Si la carte est temporairement indisponible, il est écrit « La carte n’est pas disponible pour le moment. » en haut.',
        ],
      ),
      GuideTopic(
        'Ligue des groupes',
        intro: 'Les groupes d’une même catégorie et province gagnent des points chaque mois en organisant de bons événements.',
        notes: [
          'Points : chaque participant, chaque événement d’au moins 3 participants, chaque accueil et chaque avis à 4–5 étoiles.',
          'En cas d’égalité, le groupe qui a le moins de membres passe devant.',
          'À la fin du mois, les membres des trois premiers groupes sont prévenus ; le classement figure sur la carte de ligue de la page du groupe.',
        ],
      ),
      GuideTopic(
        'Bilan de l’année et ma carte d’exploration',
        steps: [
          'Dans l’onglet Moi, touche Bilan de l’année en haut à droite.',
          'Choisis « Bilan de l’année », « Ma carte d’exploration » ou « Mes rencontres ».',
        ],
        notes: [
          'Bilan de l’année : nombre d’événements, total d’heures, groupes, provinces et catégories. Tu peux le partager en carte de story.',
          'Ma carte d’exploration : les provinces de tes événements se remplissent sur la carte de la Turquie (« 7 / 81 provinces explorées »).',
          'Ces pages ne sont visibles que par toi ; personne d’autre ne les voit si tu ne les partages pas.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'live',
    title: 'Audio en direct',
    summary: 'Rejoindre, prendre la parole, réactions, lancer et animer un direct.',
    topics: [
      GuideTopic(
        'Rejoindre un direct',
        steps: [
          'Touche la carte « En direct » sur Aujourd’hui, la carte du direct sur la page du groupe ou la notification.',
          'Une fois connecté, tu vois qui est sur scène et qui écoute.',
        ],
        notes: ['Seuls les membres du groupe peuvent rejoindre. Une personne retirée d’un direct ne peut plus y revenir.'],
      ),
      GuideTopic(
        'Naviguer pendant un direct',
        intro: 'Le bouton retour ou la flèche vers le bas en haut à gauche ne te fait pas quitter le direct ; l’écran se réduit et le son continue.',
        notes: [
          'Un bandeau « Tu es en direct » apparaît en haut de chaque page. Touche-le pour revenir au direct.',
          'Si tu es sur scène, tu peux aussi couper et réactiver ton micro depuis le bandeau.',
          'Pour partir, touche « Quitter » sur l’écran du direct. Si tu rejoins un autre direct, tu quittes le précédent.',
        ],
      ),
      GuideTopic(
        'Prendre la parole : lever la main et scène',
        steps: [
          'Si tu écoutes, lève la main avec le bouton ✋.',
          'Quand un animateur te fait monter sur scène, ton bouton micro apparaît ; touche-le pour parler.',
          'Pour quitter la scène toi-même, touche « Quitter la scène ».',
        ],
        notes: [
          'Si un animateur a coupé ton micro, tu ne peux pas le réactiver ; seul un animateur peut le rouvrir.',
          'Le contour de la photo de la personne qui parle s’illumine.',
        ],
      ),
      GuideTopic(
        'Réactions et commentaires',
        notes: [
          'Avec le bouton réactions, envoie ❤️ 👏 😂 🔥 😮 🙌 ; elles traversent l’écran et ne sont pas conservées.',
          'Avec le bouton commentaires, écris un commentaire. Les commentaires restent avec l’historique du direct.',
          'Appuie longuement sur ton commentaire pour le supprimer ; tu peux signaler celui des autres.',
        ],
      ),
      GuideTopic(
        'Lancer un direct',
        intro: 'Le propriétaire et les admins du groupe lancent les directs.',
        steps: [
          'Touche « Lancer un direct » sur la carte du direct de la page du groupe.',
          'Écris un titre. Lance tout de suite ou programme pour plus tard.',
        ],
        notes: [
          'Un groupe peut avoir un direct en cours et jusqu’à cinq directs programmés à la fois.',
          'Un direct programmé apparaît comme « À venir » sur la page du groupe ; les membres touchent « Me rappeler ». L’animateur peut le lancer au plus 15 minutes avant l’heure prévue.',
          'Les minutes de direct dépendent de la formule du groupe ; l’écran de lancement indique les minutes restantes. Une fois épuisées, le direct se termine automatiquement.',
          'Si l’animateur part et ne revient pas dans les 2 minutes, le direct se termine automatiquement.',
        ],
      ),
      GuideTopic(
        'Animer un direct',
        intro: 'Les animateurs sont la personne qui a lancé le direct et l’équipe de modération du groupe.',
        notes: [
          'Touche une personne pour la faire monter sur scène, la faire descendre, couper ou réactiver son micro.',
          '« Retirer du direct » : la personne ne peut plus revenir dans ce direct.',
          'Les mains levées apparaissent sur la carte « a levé la main » tout en haut.',
          '« Terminer le direct pour tous » se trouve dans le menu en haut à droite.',
          'La scène compte au plus 10 personnes, animateur compris. La règle de rang s’applique aussi.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'messages',
    title: 'Messages et appels vocaux',
    summary: 'Avec qui écrire, discussion de groupe, confidentialité, appels vocaux.',
    topics: [
      GuideTopic(
        'À qui puis-je écrire ?',
        notes: [
          'Les messages privés ne sont ouverts qu’avec tes matchs et tes coéquipiers. Suivre quelqu’un ne permet pas de lui écrire.',
          'Écrire à un match demande la formule Discussion de match, écrire à un coéquipier la formule Coéquipier. Lire les messages reçus est gratuit.',
          'Les discussions de groupe sont gratuites ; tous les membres peuvent y écrire.',
          'L’écran Messages se trouve derrière le bouton Messages en haut à droite d’Aujourd’hui. Le nombre de non-lus s’affiche sur le bouton.',
        ],
      ),
      GuideTopic(
        'Écrire et supprimer des messages',
        notes: [
          'Tu peux envoyer du texte (2 000 caractères maximum) et une photo.',
          'Pendant l’envoi, il est écrit « Envoi… ». En cas d’échec, le texte revient dans le champ avec la raison.',
          'Dans une discussion privée, « Vu » s’affiche quand l’autre personne a lu.',
          'Tu peux supprimer ton message pour tous ; à sa place apparaît « Ce message a été supprimé » et son contenu est effacé entièrement.',
        ],
      ),
      GuideTopic(
        'Confidentialité des messages',
        intro: 'L’équipe de la plateforme GWAY ne peut pas lire tes messages privés, écouter tes appels vocaux ni voir qui a appelé qui.',
        notes: [
          'Tu peux signaler un message. Les signalements de messages privés vont à l’équipe de la plateforme, ceux de la discussion de groupe à la modération du groupe.',
          'Le conseil de discipline d’un groupe ne peut pas voir tes messages privés.',
        ],
      ),
      GuideTopic(
        'Obtenir l’autorisation d’appels vocaux',
        intro: 'Les appels vocaux privés ne sont pas ouverts à tous ; l’autorisation est donnée par le propriétaire ou un admin d’un groupe dont tu es membre.',
        steps: [
          'Ouvre Paramètres → « Appels vocaux ».',
          'Choisis un de tes groupes, ajoute si tu veux une courte note et envoie la demande.',
          'Ton statut s’affiche sur le même écran : en cours, activé ou désactivé (avec le motif). La décision arrive aussi en notification.',
        ],
        notes: ['Si tu quittes le groupe qui a donné l’autorisation, elle prend fin.'],
      ),
      GuideTopic(
        'Passer un appel vocal',
        steps: [
          'Ouvre la discussion avec ton match ou ton coéquipier.',
          'Touche le bouton « Appel vocal » en haut à droite.',
        ],
        notes: [
          'Vous devez tous les deux avoir l’autorisation d’appel et le même accès de formule que pour la discussion. Si tu ne peux pas appeler, la raison s’affiche à la place du bouton.',
          'Un appel sans réponse en 30 secondes devient un appel manqué. Un appel dure au plus 60 minutes.',
          'Les appels ne sont jamais enregistrés et sont chiffrés de bout en bout. Si le code de sécurité à 12 chiffres est identique chez vous deux, personne n’écoute.',
          'On ne peut passer qu’un appel à la fois ; une personne occupée ne peut pas être appelée.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'matching',
    title: 'Rencontres et coéquipiers',
    summary: 'Amitié et rencontres amoureuses, formules personnelles, trouver des coéquipiers.',
    topics: [
      GuideTopic(
        'Comment fonctionnent les rencontres ?',
        intro: 'Les rencontres t’aident à trouver des amis ou l’amour parmi les personnes avec qui tu partages des groupes. Elles utilisent un profil de rencontre à part ; personne ne t’y voit tant que tu ne l’as pas activé.',
        steps: [
          'Dans l’onglet Moi, touche Rencontres en haut à droite (dans le menu de gauche sur grand écran).',
          'Crée ton profil de rencontre : Amitié, Rencontres ou les deux ; 2 à 6 photos, date de naissance, genre, province, « à propos ».',
          'En mode Rencontres, choisis les genres recherchés et une tranche d’âge.',
          'Donne ton consentement explicite.',
        ],
        notes: [
          'Ta pile montre seulement des personnes qui partagent au moins un groupe avec toi et ont activé le même mode.',
          'En mode Rencontres, vos préférences doivent correspondre mutuellement.',
          'Seule ta province sert de localisation.',
        ],
      ),
      GuideTopic(
        'Swiper et matcher',
        notes: [
          'Swipe à droite : liker. À gauche : passer. Vers le haut : Super Like. Les boutons du bas font la même chose.',
          'Touche les bords de la carte pour changer de photo ; le bouton « i » ouvre le profil complet.',
          'Si vous vous likez dans le même mode, c’est un match et vous êtes prévenus.',
          'Tes likes et Super Likes gratuits du jour sont indiqués sur l’écran des rencontres.',
          'Une personne passée peut être reproposée après 90 jours.',
        ],
      ),
      GuideTopic(
        'Formules personnelles',
        intro: 'Chaque fonction est vendue comme une formule à part ; tu prends seulement ce que tu veux.',
        notes: [
          'Mes matchs : voir avec qui tu as matché. Sans elle, tu sais qu’il y a un match mais la personne reste cachée.',
          'Discussion de match : écrire à tes matchs.',
          'Qui te like : la liste des personnes qui t’ont liké.',
          'Likes illimités : likes illimités, annulation et filtres.',
          'Super Like et Boost : plus de Super Likes, et apparaître en tête des piles une fois par jour.',
          'Coéquipier : la section coéquipiers et écrire aux coéquipiers.',
          'Tout-en-un : tout.',
          'Les formules sont prépayées, ne se renouvellent pas automatiquement et s’achètent sur le web. Les prix figurent dans Rencontres → Formules.',
        ],
      ),
      GuideTopic(
        'Terminer, mettre en pause, supprimer',
        notes: [
          'Si tu mets fin à un match, votre discussion se ferme, l’abonnement mutuel est retiré et vous n’apparaissez plus dans vos piles.',
          'Si vous avez matché dans les deux modes, tu peux choisir « Rester amis seulement » ou « Garder seulement les rencontres ».',
          'Si tu mets ton profil en pause, ta pile et tes likes s’arrêtent ; les matchs existants restent.',
          'Tu peux supprimer toutes tes données de rencontre (profil, photos, likes, matchs) en une seule touche.',
          'Tu peux signaler les profils et photos de rencontre.',
        ],
      ),
      GuideTopic(
        'Trouver des coéquipiers',
        intro: 'Trouve des personnes avec qui t’entraîner, randonner ou monter sur scène.',
        steps: [
          'Dans Paramètres → « Préférences de coéquipiers », active « Je cherche une équipe ».',
          'Choisis tes activités, ton niveau, tes objectifs, ta fréquence, tes disponibilités et, si tu veux, ta province.',
          'Dans l’onglet Moi, le bouton « Trouver des coéquipiers » montre les suggestions. Chacune indique pourquoi (activité commune, groupe commun, même province…).',
          'Envoie une demande (avec un message de 200 caractères maximum). Quand l’autre accepte, vous êtes coéquipiers.',
        ],
        notes: [
          'Ta province sert seulement aux suggestions et n’apparaît pas sur ton profil.',
          'Tu peux envoyer 20 demandes par jour au maximum, et une seule par jour à la même personne.',
          'La section coéquipiers demande la formule Coéquipier.',
          'Chacun peut mettre fin à la relation de coéquipiers à tout moment.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'notifications',
    title: 'Notifications',
    summary: 'Types de notifications, préférences et notifications du téléphone.',
    topics: [
      GuideTopic(
        'L’écran Notifications',
        notes: [
          'Il s’ouvre avec la cloche en haut à droite d’Aujourd’hui ; le nombre de non-lues s’affiche sur le bouton.',
          'Les notifications sont regroupées en Aujourd’hui / Cette semaine / Plus tôt ; les demandes d’abonnement en attente sont en haut.',
          'Touche une notification pour ouvrir la page concernée.',
        ],
      ),
      GuideTopic(
        'Préférences de notification',
        steps: ['Ouvre Paramètres → « Préférences de notification ».', 'Désactive celles que tu ne veux pas.'],
        notes: [
          'Tu peux désactiver : rappels d’événements, modifications et annulations, demandes d’avis, notifications de direct, messages privés, messages de groupe et notifications de rencontres.',
          'Les notifications qui te concernent directement, comme une validation, ton tour sur la liste d’attente ou une sanction, ne peuvent pas être désactivées.',
        ],
      ),
      GuideTopic(
        'Je ne reçois pas les notifications du téléphone',
        steps: [
          'L’application demande l’autorisation à la première ouverture ; si tu as refusé, active-la dans Réglages du téléphone → Applications → GWAY → Notifications.',
          'Sur Android, vérifie que les canaux « Messages », « Appels vocaux » et « Notifications » sont activés.',
          'Vérifie les préférences de notification dans l’application.',
        ],
        notes: ['Si ton téléphone est en mode silencieux, les notifications ne sonnent pas.'],
      ),
    ],
  ),
  GuideChapter(
    id: 'safety',
    title: 'Sécurité, signalements et sanctions',
    summary: 'Signaler, sanctions de groupe, appel, validation en deux étapes.',
    topics: [
      GuideTopic(
        'Signaler',
        steps: [
          'Ouvre le menu de la publication, du commentaire, de l’événement, du commentaire en direct, du message ou du profil.',
          'Touche « Signaler », choisis un motif et ajoute si tu veux une courte description.',
        ],
        notes: [
          'La personne signalée ne voit ni le signalement ni toi. Les admins du groupe ne voient pas non plus qui a signalé.',
          'Les signalements liés à un groupe vont à sa modération, les autres à l’équipe de la plateforme.',
          'Tu ne peux pas te signaler ni signaler ton propre contenu ; tu signales un même contenu une seule fois tant que le signalement est ouvert.',
        ],
      ),
      GuideTopic(
        'Sanctions de groupe',
        notes: [
          'Avertissement : il est enregistré et tu reçois une notification.',
          'Sourdine (1 à 90 jours) : tu ne peux ni publier ni commenter dans le groupe, ni écrire dans sa discussion ; en direct, tu peux seulement écouter.',
          'Exclusion : tu es retiré du groupe ; tu peux le rejoindre plus tard.',
          'Bannissement (temporaire ou définitif) : pendant sa durée, tu ne peux pas rejoindre le groupe, envoyer de demande ni recevoir d’invitation.',
          'Tes sanctions figurent dans Paramètres → « Mes sanctions de groupe ».',
        ],
      ),
      GuideTopic(
        'Faire appel d’une sanction',
        steps: [
          'Ouvre Paramètres → « Mes sanctions de groupe ».',
          'Touche « Faire appel » à côté de la sanction et écris tes raisons (10 à 1000 caractères).',
        ],
        notes: [
          'Tu peux faire appel de chaque sanction une fois sous 7 jours. La sourdine d’urgence ne peut pas faire l’objet d’un appel.',
          'Le propriétaire du groupe statue sur l’appel ; s’il est partie au dossier, c’est l’équipe de la plateforme qui décide.',
          'La sanction continue en attendant la décision. Tu la reçois en notification.',
        ],
      ),
      GuideTopic(
        'Suspension et bannissement du compte',
        notes: [
          'L’équipe de la plateforme peut suspendre ou fermer un compte qui enfreint les règles. L’application t’indique alors le motif et la date de fin.',
          'Pendant la suspension, ton profil est visible mais ton contenu masqué ; un compte fermé définitivement n’apparaît nulle part.',
          'Si une activité illégale (violence, menace, escroquerie…) est signalée par décision de groupe, le compte est suspendu jusqu’à l’examen de la plateforme.',
          'Si tu penses qu’il y a une erreur, écris à l’équipe d’assistance.',
        ],
      ),
      GuideTopic(
        'Validation en deux étapes',
        steps: [
          'Ouvre Paramètres → « Validation en deux étapes ».',
          'Ajoute une application d’authentification (ex. Google Authenticator) ou, sur le web, configure la connexion par empreinte et reconnaissance faciale.',
        ],
        notes: ['La méthode configurée passe en premier lors des connexions suivantes ; le SMS reste toujours en secours.'],
      ),
    ],
  ),
  GuideChapter(
    id: 'moderation',
    title: 'Modération de groupe',
    summary: 'Pour les responsables : examen des signalements, dossiers, vote, bannissement.',
    topics: [
      GuideTopic(
        'L’écran de modération',
        intro: 'La carte de modération sur la page du groupe indique le nombre de tâches en attente. Le propriétaire, les admins, les membres du conseil et les modérateurs la voient.',
        notes: [
          'Signalements : les signalements d’un même contenu sont regroupés sur une ligne. Rejeter, Retirer le contenu ou Ouvrir un dossier.',
          'Dossiers : dossiers en cours de vote, temps restant et nombre de votes ; vote.',
          'Sanctions et appels : le propriétaire statue ici sur les appels.',
        ],
      ),
      GuideTopic(
        'Dossier disciplinaire et vote',
        steps: [
          'Depuis un signalement ou le menu d’un membre sur la page des membres, choisis « Ouvrir un dossier disciplinaire ».',
          'Choisis la sanction proposée (avertissement, sourdine, exclusion, bannissement) et sa durée, puis écris le motif.',
          'En urgence, coche « Mettre en sourdine maintenant (24 heures) » ; la personne est en sourdine jusqu’à la décision.',
        ],
        notes: [
          'Les membres du conseil de discipline votent sous 72 heures. Dans un groupe sans conseil, le propriétaire décide seul.',
          'Le seuil de décision est par défaut la majorité simple ; le propriétaire peut choisir deux tiers ou unanimité dans les réglages de l’écran de modération.',
          'Dès que le seuil est atteint, le dossier est approuvé et la sanction appliquée. Sans vote, le dossier est rejeté.',
          'Une personne ne peut faire l’objet que d’un seul dossier ouvert à la fois. La règle de rang s’applique.',
        ],
      ),
      GuideTopic(
        'Bannissement sans vote',
        intro: 'Le propriétaire et les admins peuvent bannir quelqu’un sans attendre le conseil.',
        steps: [
          'Dans « Ouvrir un dossier disciplinaire », choisis le bannissement comme sanction.',
          'Coche « Appliquer tout de suite, sans vote ».',
          'Indique la durée (1 à 365 jours ou définitif) et le motif.',
        ],
        notes: [
          'Un admin ne peut bannir ni un autre admin ni le propriétaire.',
          'S’il s’agit d’une infraction, marque-la comme « activité illégale » et choisis sa catégorie ; le compte de la personne est suspendu jusqu’à l’examen de la plateforme.',
          'La personne peut faire appel sous 7 jours.',
        ],
      ),
      GuideTopic(
        'Intervention d’urgence pendant un direct',
        intro: 'En cas de harcèlement pendant un direct, un animateur coupe immédiatement le micro de la personne ou la retire du direct. Un dossier disciplinaire peut ensuite être ouvert si nécessaire.',
      ),
    ],
  ),
  GuideChapter(
    id: 'account',
    title: 'Compte, confidentialité et assistance',
    summary: 'Documents juridiques, tes données, suppression du compte, déconnexion, assistance.',
    topics: [
      GuideTopic(
        'Comment mes données sont-elles protégées ?',
        notes: [
          'Ta position sert uniquement à la sécurité du compte ; elle n’apparaît ni sur la carte ni sur ton profil.',
          'Ta date de naissance n’est montrée à personne.',
          'L’équipe de la plateforme ne peut pas lire tes messages privés.',
          'Les documents que tu as acceptés se trouvent dans Paramètres → « Documents juridiques ».',
        ],
      ),
      GuideTopic(
        'Supprimer mon compte',
        steps: [
          'Ouvre Paramètres → « Supprimer le compte ».',
          'Confirme la suppression.',
        ],
        notes: [
          'Ton profil est aussitôt masqué aux autres. Pendant 30 jours, tu peux te connecter et choisir « annuler la suppression ».',
          'Après 30 jours, ton compte, tes publications, tes messages et tes fichiers sont définitivement supprimés.',
          'Si tu es propriétaire d’un groupe, tu dois d’abord transférer la propriété ou supprimer le groupe.',
        ],
      ),
      GuideTopic(
        'Se déconnecter',
        intro: 'Touche « Se déconnecter » tout en bas des Paramètres. Le téléphone sur lequel tu te déconnectes ne reçoit plus de notifications.',
      ),
      GuideTopic(
        'Écrire à l’équipe d’assistance',
        steps: [
          'Ouvre Paramètres → « Assistance et commentaires ».',
          'Touche « Nouveau message » et choisis le type : Problème (quelque chose ne marche pas), Demande (une action pour ton compte, ton groupe ou ton paiement), Suggestion (nouvelle fonction ou idée).',
          'Écris l’objet et la description ; tu peux ajouter jusqu’à 3 images.',
        ],
        notes: [
          'Quand une réponse arrive, la ligne dans les Paramètres indique « nouvelle réponse ». États d’un message : Nouveau, En cours, Résolu, Fermé.',
          'Si tu es admin d’un groupe, tu peux aussi ouvrir un message pour ce groupe depuis sa page.',
        ],
      ),
    ],
  ),
];
