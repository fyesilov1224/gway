import '../guide.dart';

// Spanish translation of tr.dart; keep chapters, topics, steps and notes in step with it.

const guideEs = <GuideChapter>[
  GuideChapter(
    id: 'start',
    title: 'Primeros pasos',
    summary: 'Registro, inicio de sesión, verificación y cómo moverte por la app.',
    topics: [
      GuideTopic(
        '¿Qué es GWAY?',
        intro: 'GWAY es una plataforma social que reúne comunidades de todo tipo: senderismo, running, ciclismo, música, '
            'naturaleza, deporte, arte y más. Te unes a grupos, vas a eventos, charlas en salas de audio en directo '
            'y conoces gente nueva.',
        notes: [
          'GWAY está abierto a mayores de 18 años.',
          'La app funciona en el móvil (Android, iOS) y en el navegador web; tu cuenta es la misma en todas partes.',
        ],
      ),
      GuideTopic(
        'Crear una cuenta',
        steps: [
          'En la pantalla de inicio de sesión, toca «Registrarse».',
          'Escribe tu correo electrónico y una contraseña. También puedes registrarte con Google o Apple.',
          'Si te registraste con correo, toca el enlace de verificación que te llegó. Sin verificar el correo no se puede iniciar sesión.',
          'Tras iniciar sesión, la app te guía por la verificación de seguridad, la aceptación de los documentos legales, tu fecha de nacimiento y la creación del perfil.',
        ],
        tip: 'Si no te llega el correo de verificación, mira en la carpeta de spam.',
      ),
      GuideTopic(
        'Olvidé mi contraseña',
        steps: [
          'En la pantalla de inicio de sesión, toca «He olvidado la contraseña».',
          'Escribe el correo de tu cuenta.',
          'Crea una contraseña nueva con el enlace del correo que recibas.',
        ],
      ),
      GuideTopic(
        'Verificación de seguridad: ubicación, teléfono y segundo paso',
        intro: 'Para evitar cuentas falsas, la app puede pedirte estos pasos.',
        steps: [
          'Ubicación: la app pide permiso de ubicación. Sin él, la app no se abre y verás una pantalla que lleva a los ajustes. '
              'Tu ubicación solo se usa para la seguridad de la cuenta y no se muestra a nadie.',
          'Teléfono: escribes un número del país en el que estás e introduces el código del SMS. Se hace una vez; un número solo puede usarse en una cuenta.',
          'Segundo paso: en cada nuevo inicio de sesión llega un código SMS a tu número. Si configuraste una app de autenticación o la huella, usas eso.',
        ],
        tip: 'Tras verificar el teléfono, acepta la sugerencia «Añadir huella» o «Añadir Google Authenticator» y los siguientes inicios de sesión serán más rápidos. El SMS queda como respaldo.',
      ),
      GuideTopic(
        'Documentos legales y fecha de nacimiento',
        intro: 'Debes aceptar las condiciones de uso, el aviso de privacidad, el consentimiento expreso y las normas de la comunidad.',
        steps: [
          'Abre cada documento y desplázate hasta el final. Sin leerlo no se puede marcar la casilla.',
          'Toca «He leído y acepto» al final del documento.',
          'Introduce tu fecha de nacimiento. No se muestra a nadie y no se puede cambiar después; si te equivocaste, escribe al equipo de soporte.',
        ],
        notes: ['Cuando se publica una nueva versión de un documento, la app te pide que la aceptes de nuevo.'],
      ),
      GuideTopic(
        'Crear tu perfil',
        steps: [
          'Elige un nombre de usuario: 3–30 caracteres; se permiten minúsculas, números, guion bajo y punto.',
          'Añade tu nombre visible y tu foto de perfil.',
          'Elige tus intereses (máximo 10). Los grupos y las sugerencias se basan en ellos.',
        ],
        notes: ['Puedes cambiar tu nombre de usuario una vez cada 30 días.'],
      ),
      GuideTopic(
        'Moverte por la app',
        intro: 'La barra inferior tiene cuatro pestañas y un botón «+» en el centro.',
        notes: [
          'Hoy: directos en curso, eventos que empiezan pronto y publicaciones de quienes sigues. Arriba a la derecha están Buscar, Notificaciones y Mensajes.',
          'Grupos: buscar y descubrir grupos. Arriba a la derecha están Liga de grupos y Mapa.',
          'Calendario: los eventos a los que vas y los de tus grupos.',
          'Yo: tu propio perfil. Arriba a la derecha están Notificaciones, Guardados, Matches, Buscar compañeros de equipo, Resumen del año y Ajustes.',
          'El botón «+»: Esta noche, Próximos y crear una publicación, historia o grupo.',
          'En pantallas grandes (web, tableta) las mismas secciones están en el menú de la izquierda, con los grupos a los que perteneces debajo.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'profile',
    title: 'Perfil y seguidores',
    summary: 'Editar el perfil, privacidad, seguir, bloquear, insignias.',
    topics: [
      GuideTopic(
        'Editar mi perfil',
        steps: [
          'En la pestaña Yo, toca Ajustes arriba a la derecha y luego «Editar perfil».',
          'Cambia tu foto de perfil, portada, nombre visible, biografía e intereses.',
          'Guarda.',
        ],
        notes: ['Las imágenes pueden pesar hasta 5 MB (JPEG, PNG o WebP).'],
      ),
      GuideTopic(
        'Cuenta privada',
        intro: 'Con Ajustes → «Cuenta privada» activado, solo los seguidores que apruebes ven tus publicaciones e historias.',
        notes: [
          'Con una cuenta privada, quien quiere seguirte envía una solicitud; la apruebas o rechazas arriba en la pantalla Notificaciones. A quien rechazas no se le avisa.',
          'Si vuelves a hacer pública tu cuenta, las solicitudes pendientes se aprueban solas.',
        ],
      ),
      GuideTopic(
        'Mostrar mis grupos en mi perfil',
        intro: 'Ajustes → «Mostrar mis grupos en mi perfil» está desactivado por defecto.',
        notes: [
          'Mientras esté desactivado, solo los miembros de un grupo ven que perteneces a él. El administrador de otro grupo no puede ver en qué grupos estás.',
          'Si lo activas, tus membresías serán visibles para todos en tu perfil.',
          'Los grupos en cuyo equipo de gestión estás (propietario, administrador, comité, moderador) siempre son públicos.',
        ],
      ),
      GuideTopic(
        'Seguir y amigos',
        steps: [
          'Toca «Seguir» en un perfil. Si la cuenta es privada, se envía una solicitud y empiezas a seguirla cuando se acepta.',
          'Vuelve a tocar el mismo botón para dejar de seguir o retirar la solicitud.',
        ],
        notes: [
          'Si os seguís mutuamente, el perfil indica «Amigo».',
          'Puedes quitar de tu lista de seguidores a alguien que te sigue.',
          'Seguir no da derecho a escribir; los mensajes directos son entre matches y compañeros de equipo.',
          'También puedes seguir grupos; las publicaciones de los grupos en los que estás ya llegan a tu feed.',
        ],
      ),
      GuideTopic(
        'Bloquear a alguien',
        steps: [
          'En el perfil de la persona, abre el menú «Más opciones» arriba a la derecha.',
          'Toca «Bloquear».',
        ],
        notes: [
          'Se eliminan los seguimientos y solicitudes en ambos sentidos. No veréis vuestros perfiles, publicaciones ni comentarios; no podréis escribiros ni mencionaros.',
          'La persona bloqueada tampoco aparece en tu baraja de matches ni en las sugerencias de compañeros.',
          'Ves a quién has bloqueado en Ajustes → «Cuentas bloqueadas», donde puedes desbloquear. El seguimiento no vuelve solo al desbloquear.',
        ],
      ),
      GuideTopic(
        'Aportaciones e insignias',
        intro: 'Las aportaciones de tu perfil cuentan lo que haces en la vida real; los likes, seguidores y número de publicaciones no cuentan.',
        notes: [
          'Asistencia: eventos terminados a los que fuiste sin que te marcaran «no vino».',
          'Organización: eventos que creaste y a los que asistieron al menos otras 2 personas.',
          'Recuerdo: publicaciones que compartiste vinculadas a un evento.',
          'Ejemplos de insignias: Primer paso (1 asistencia), Habitual (10), Compañero de ruta (25), Explorador (3 grupos distintos), Organizador, Coleccionista de recuerdos, Opinador, «Fan de <categoría>», insignias de bienvenida y de apretón de manos, y metas cumplidas.',
          'No hay clasificaciones ni listas de «los mejores».',
        ],
      ),
      GuideTopic(
        'Guardados y archivo de historias',
        notes: [
          'Para guardar una publicación, toca el icono de guardar de su tarjeta. Solo tú ves lo guardado: Yo → Guardados o Ajustes → Guardados.',
          'Las historias caducadas no se borran; quedan en Ajustes → «Archivo de historias».',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'feed',
    title: 'Hoy, publicaciones e historias',
    summary: 'Compartir, likes, comentarios, explorar y buscar.',
    topics: [
      GuideTopic(
        'La pantalla Hoy',
        notes: [
          'Arriba, «En directo ahora»: los directos de tus grupos. Toca una tarjeta para entrar.',
          'Después, «Empieza pronto»: eventos de las próximas horas; primero los de tus grupos y luego los de las provincias de tus grupos.',
          'Abajo, el feed: tus publicaciones y las de quienes sigues y de los grupos que sigues o a los que perteneces, de la más nueva a la más antigua.',
          'Desliza la pantalla hacia abajo para actualizar.',
        ],
      ),
      GuideTopic(
        'Compartir una publicación',
        steps: [
          'Toca el botón «+» de abajo y luego «Publicación».',
          'Elige hasta 10 fotos o vídeos. Un vídeo puede durar hasta 60 segundos y pesar 50 MB.',
          'Para las fotos, elige la proporción (Original, 1:1, 4:5, 1,91:1) y ajusta el encuadre.',
          'Escribe una descripción. Puedes añadir #hashtags y mencionar a alguien con @usuario.',
          'Si quieres, desactiva los comentarios u oculta el número de likes y comparte.',
        ],
        notes: [
          'Los datos de ubicación de tus fotos se eliminan antes de subirlas.',
          'Puedes editar una publicación después; solo cambian la descripción y las opciones. Si la borras, también se borran sus archivos.',
          'Para publicar en un grupo, comparte desde la página del grupo. Todos los miembros pueden publicar; los silenciados no.',
        ],
      ),
      GuideTopic(
        'Likes, reacciones y comentarios',
        notes: [
          'Puedes dar like a una publicación o reaccionar con 😍 😂 😮 👏 🔥 🙏. Puedes cambiar o quitar tu reacción.',
          'Quien puede ver una publicación puede comentar, salvo que el autor haya desactivado los comentarios.',
          'Puedes responder a un comentario y dar like a comentarios. Las respuestas tienen un solo nivel.',
          'Borras tus propios comentarios y los de tus publicaciones. En publicaciones de grupo, el propietario y los administradores también pueden borrar comentarios.',
        ],
      ),
      GuideTopic(
        'Compartir una historia',
        steps: [
          'Toca «+» → «Historia».',
          'Elige una foto o un vídeo de hasta 60 segundos y compártelo.',
        ],
        notes: [
          'Una historia se ve durante 24 horas y luego pasa a tu archivo.',
          'Solo tú ves quién ha visto tu historia.',
          'Añade historias a destacadas para mantenerlas en tu perfil.',
        ],
      ),
      GuideTopic(
        'Explorar y buscar',
        steps: [
          'Toca Buscar arriba a la derecha de la pantalla Hoy.',
          'Busca personas o #hashtags. Para buscar grupos, usa la pestaña Grupos.',
        ],
        notes: [
          'Explorar muestra las publicaciones con más interacción de las últimas dos semanas, de cuentas públicas y grupos que no sigues.',
          'Puedes compartir el enlace de una publicación; quien lo abre la ve si tiene permiso para verla.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'groups',
    title: 'Grupos',
    summary: 'Encontrar y unirte a grupos, roles y la página del grupo.',
    topics: [
      GuideTopic(
        'Encontrar un grupo',
        notes: [
          'En la pestaña Grupos, busca por nombre o elige una categoría.',
          'Con el botón Mapa de arriba a la derecha ves en un mapa los grupos y eventos cercanos.',
          'Con la Liga de grupos ves los grupos que organizan los mejores eventos en tu categoría y provincia.',
          'Todos los grupos activos tienen página pública; no hay grupos secretos.',
        ],
      ),
      GuideTopic(
        'Unirte a un grupo',
        intro: 'El tipo de acceso del grupo aparece en el botón:',
        notes: [
          'Libre: toca «Unirse» y eres miembro al instante.',
          'Con solicitud: envías una solicitud y un administrador la aprueba. Puedes retirarla.',
          'Por invitación: un administrador te invita por tu nombre de usuario; aceptas o rechazas en la pantalla Notificaciones.',
          'Enlace de invitación: abre el enlace que te enviaron y toca «Unirse al grupo» para ser miembro, sea cual sea el tipo de acceso.',
          'Si se alcanza el límite de miembros del plan del grupo, no puede entrar nadie nuevo.',
        ],
        tip: 'Al unirte a tu primer grupo recibes, una sola vez, una prueba de 30 días del plan personal «Todo en uno» (funciones de matches y compañeros).',
      ),
      GuideTopic(
        'Salir de un grupo',
        steps: [
          'Toca el botón de membresía en la página del grupo.',
          'Elige «Salir del grupo».',
        ],
        notes: [
          'Se eliminan tus roles y tu asistencia a los próximos eventos del grupo.',
          'El propietario no puede salir del grupo; antes debe transferir la propiedad.',
        ],
      ),
      GuideTopic(
        '¿Qué hay en la página de un grupo?',
        notes: [
          'Portada, logo, presentación, normas, enlaces, provincia y categoría.',
          'Tarjeta de directo: directos en curso y programados.',
          'Eventos, valoraciones «¿Qué tal fue?» y la puntuación media del grupo.',
          'Encuestas, metas, la tarjeta de la liga y las publicaciones del grupo.',
          'Miembros: el equipo de gestión es público; la lista completa solo la ven los miembros.',
          'Chat de grupo: cada grupo tiene un único chat que solo leen y escriben sus miembros.',
        ],
      ),
      GuideTopic(
        'Roles en el grupo',
        intro: 'Un miembro puede tener varios roles. El número entre paréntesis es el rango.',
        notes: [
          'Propietario (100): todo, pagos y asignar roles.',
          'Administrador (80): contenido, eventos, encuestas, aprobar e invitar miembros, directos, bloqueos sin votación, solicitudes de llamadas de voz.',
          'Comité disciplinario (60): vota en los casos disciplinarios; revisa denuncias, silencio de urgencia, moderación de directos.',
          'Moderador (50): revisión previa de denuncias, silencio de urgencia, moderación de directos.',
          'Miembro (10): asistir, publicar, entrar en directos.',
          'Regla de rango: nadie puede sancionar a alguien de rango igual o superior. Al propietario no se le puede bloquear.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'group-admin',
    title: 'Crear y gestionar un grupo',
    summary: 'Para propietarios y administradores: grupo, invitaciones, roles, planes, metas.',
    topics: [
      GuideTopic(
        'Crear un grupo',
        steps: [
          'Toca «+» → «Grupo».',
          'Escribe el nombre (3–60 caracteres) y la dirección del grupo. La dirección es el enlace de la página (/g/direccion) y no se puede cambiar después.',
          'Elige la categoría y la provincia. La provincia es necesaria para el mapa y la Liga de grupos.',
          'Elige el tipo de acceso: libre, con solicitud o por invitación.',
          'Añade logo, portada, presentación, normas y hasta 5 enlaces.',
        ],
        notes: ['Quien crea el grupo es su propietario. El grupo también tiene su propio chat.'],
      ),
      GuideTopic(
        'Aceptar e invitar miembros',
        notes: [
          'En un grupo con solicitud, apruebas o rechazas las solicitudes pendientes en la página del grupo (propietario y administradores).',
          'Puedes enviar invitaciones por nombre de usuario. Un grupo puede enviar como máximo 50 invitaciones en 24 horas; las retiradas también cuentan.',
          'Puedes retirar una invitación mientras no se haya aceptado.',
        ],
      ),
      GuideTopic(
        'Enlace de invitación',
        intro: 'La forma más fácil de traer tu grupo desde WhatsApp o Instagram.',
        steps: [
          'Abre la sección «Enlace de invitación» en la página del grupo.',
          'Elige la duración (1, 7 o 30 días); si quieres, pon un límite de usos (1–1000 personas).',
          'Comparte el enlace. Quien lo abra, inicie sesión y toque «Unirse al grupo» será miembro.',
        ],
        notes: [
          'Un grupo puede tener a la vez como máximo 20 enlaces válidos.',
          'Puedes anular un enlace cuando quieras; no se puede deshacer, simplemente creas otro.',
          'En WhatsApp, el enlace compartido se ve con el nombre y la imagen del grupo.',
        ],
      ),
      GuideTopic(
        'Asignar roles y transferir la propiedad',
        notes: [
          'Solo el propietario da y quita roles: Administrador, Comité disciplinario, Moderador. Los roles solo se dan a miembros.',
          'Puedes transferir la propiedad a un miembro activo. Tú sigues como miembro normal; el nuevo propietario puede darte un rol.',
          'Solo el propietario puede eliminar el grupo. La eliminación es permanente.',
          'Mientras seas propietario de un grupo no puedes eliminar tu cuenta; primero transfiere la propiedad o elimina el grupo.',
        ],
      ),
      GuideTopic(
        'Planes de grupo',
        intro: 'El plan fija el número máximo de miembros, los eventos al mes y los minutos de directo al mes del grupo.',
        steps: [
          'Abre la tarjeta «Plan» en la página del grupo para ver el plan actual, sus límites y el uso.',
          'Compra el plan en la web. La app móvil solo muestra el estado del plan.',
        ],
        notes: [
          'Un grupo sin suscripción usa los límites del plan gratuito.',
          'Los planes son de prepago (mensuales o anuales); no hay renovación automática ni se guarda la tarjeta.',
          'Al mejorar el plan, el tiempo restante pasa al nuevo plan. Si renuevas el mismo plan, el tiempo se suma al final.',
          'Los pagos desde Turquía se cobran en TL con PayTR; desde el extranjero, en USD con iyzico.',
          'Si se alcanza el límite de miembros, los actuales se quedan, pero no entra nadie nuevo.',
          'Los precios y límites actuales aparecen en la pantalla de planes. El plan lo compra el propietario.',
        ],
      ),
      GuideTopic(
        'Metas y tareas',
        intro: 'Une al grupo en torno a un objetivo común. El propietario y los administradores crean las metas; el premio es una insignia, sin dinero ni puntos.',
        notes: [
          'Meta personal: cada miembro gana una insignia al llegar a su propio número.',
          'Meta de grupo: cuando el total del grupo llega al objetivo, todos los que aportaron ganan una insignia.',
          'Meta por equipos: se forman equipos y cuenta el total de cada equipo.',
          'Tarea: el miembro toca «Lo hice» y añade una nota breve; si un administrador lo aprueba, recibe una insignia.',
          'Lo que cuenta: asistencia, organización o recuerdos. El servidor calcula el progreso.',
        ],
      ),
      GuideTopic(
        'Gestionar el chat del grupo',
        notes: [
          'Puedes configurar el chat del grupo para que solo escriban los administradores (como un canal de anuncios).',
          'Si se denuncia un mensaje inapropiado, llega a la pantalla de moderación del grupo; una persona autorizada puede retirarlo.',
        ],
      ),
      GuideTopic(
        'Responder solicitudes de llamadas de voz',
        intro: 'Los miembros piden al grupo permiso para llamadas de voz individuales. El propietario y los administradores ven las solicitudes.',
        steps: [
          'Abre «Solicitudes de llamadas de voz» en la página del grupo.',
          'Activa la solicitud o recházala con un motivo.',
          'Puedes desactivar en cualquier momento un permiso concedido, indicando el motivo.',
        ],
        notes: ['Si la persona sale del grupo, la expulsan o la bloquean, el permiso se desactiva solo.'],
      ),
    ],
  ),
  GuideChapter(
    id: 'events',
    title: 'Eventos',
    summary: 'Asistir, lista de espera, bienvenida, apretón de manos, valoración.',
    topics: [
      GuideTopic(
        'Apuntarte a un evento',
        steps: [
          'Abre la página del evento (desde la página del grupo, Hoy, el calendario o el mapa).',
          'Lee la fecha, el lugar, la información del precio, los requisitos y el equipo necesario.',
          'Toca «Asistir». Si no quedan plazas, el botón dice «Apuntarse a la lista de espera».',
        ],
        notes: [
          'Todos ven los eventos, pero solo los miembros del grupo pueden asistir.',
          'Si estás en lista de espera, te toca cuando alguien se borra y recibes una notificación.',
          'En eventos con aprobación, el botón dice «Enviar solicitud»; asistes cuando el organizador la aprueba.',
          'Para borrarte, toca «Cancelar»; tu plaza pasa a la primera persona de la lista de espera.',
          'Las inscripciones se cierran cuando empieza el evento.',
        ],
      ),
      GuideTopic(
        'Precio de asistencia',
        intro: 'El precio solo se muestra como información. GWAY no cobra pagos; pagas al organizador como indique (por ejemplo, en efectivo allí mismo).',
      ),
      GuideTopic(
        'Añadir al calendario y cómo llegar',
        notes: [
          '«Añadir al calendario» guarda el evento en la app de calendario de tu móvil.',
          'Si hay un punto de encuentro marcado, «Cómo llegar», bajo el mapa pequeño, abre la app de mapas de tu dispositivo.',
        ],
      ),
      GuideTopic(
        'Dos eventos a la misma hora',
        intro: 'Si tienes otro evento a la hora de uno al que vas, la app te pregunta si quieres borrarte del otro y liberar tu plaza. Tú decides; nada se cancela automáticamente.',
      ),
      GuideTopic(
        'La pregunta «¿Vienes?»',
        intro: 'Menos de 24 horas antes del inicio recibes un recordatorio y aparece la tarjeta «¿Vienes?» en la página del evento.',
        notes: [
          '«Sí, voy»: el organizador ve que vienes.',
          '«No puedo ir»: te borras; tu plaza pasa a la primera persona de la lista de espera.',
          'Si no respondes, no te quitan de la lista.',
        ],
      ),
      GuideTopic(
        'Bienvenida: si vas por primera vez',
        intro: 'Si es tu primera vez en un evento de un grupo, un miembro voluntario del grupo puede recibirte.',
        steps: [
          'Apúntate al evento.',
          'En la sección de bienvenida de la página, toca «Quiero que me reciban»; si quieres, escribe una nota para reconocerte (p. ej. «Llevo una chaqueta roja»).',
          'Cuando alguien acepta tu solicitud, recibes su punto de encuentro (p. ej. «Delante de la cafetería de la entrada, 08:45») como notificación.',
          'Después del evento puedes dar las gracias a quien te recibió.',
        ],
        notes: [
          'Para recibir a otros, apúntate al evento; verás las solicitudes abiertas en la sección de bienvenida. Puedes recibir hasta a 3 personas por evento.',
          'Insignias de bienvenida: Abrepuertas (1), Anfitrión (5), Corazón de la comunidad (20).',
        ],
      ),
      GuideTopic(
        'Lugar sorpresa',
        intro: 'En algunos eventos el lugar es una sorpresa. La página solo muestra una pista (p. ej. «En Kadıköy, junto al mar») y cuándo se revelará.',
        notes: [
          'A la hora indicada, el lugar se revela a los asistentes con una notificación.',
          'Quien está en lista de espera o no asiste no ve el lugar. Si te apuntas más tarde y ya pasó la hora, lo ves al momento.',
        ],
      ),
      GuideTopic(
        'Apretón de manos: guarda a quien conociste',
        intro: 'Dos asistentes del mismo evento escanean el código QR del otro para guardar que se conocieron.',
        steps: [
          'La tarjeta «Apretón de manos» aparece en la página desde 1 hora antes del inicio hasta 6 horas después del final.',
          'Enseña tu código o escanea el de la otra persona con la cámara. Sin cámara, escribe el código de 6 caracteres.',
        ],
        notes: [
          'El código cambia cada 3 minutos; una foto suya no sirve después.',
          'Solo tú ves a quién conociste: Yo → Resumen del año → Gente que conocí. Tu perfil solo muestra el número.',
          'El apretón de manos no da derecho a escribir mensajes.',
        ],
      ),
      GuideTopic(
        'Después del evento',
        notes: [
          'Al terminar recibes una petición de valoración; da de 1 a 5 estrellas. La puntuación del grupo es la media de estas valoraciones.',
          'Añade tu recuerdo compartiendo una publicación vinculada al evento; los recuerdos cuentan para insignias y metas.',
          'Si asististe, aparece la tarjeta «Yo también estuve»; puedes compartirla como imagen en una historia de Instagram o en WhatsApp. La tarjeta no muestra el nombre ni la cara de otros asistentes.',
          'Los eventos pasados del grupo se ven en su página.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'event-admin',
    title: 'Organizar eventos y encuestas',
    summary: 'Para propietarios y administradores: crear, repetir, aprobar, cancelar, encuestas.',
    topics: [
      GuideTopic(
        'Crear un evento',
        steps: [
          'Toca «Crear evento» en la página del grupo.',
          'Introduce la portada, el título, la descripción, la hora de inicio y, si quieres, la de fin. El inicio debe ser dentro de al menos 15 minutos y como mucho 1 año.',
          'Escribe el lugar; si quieres, marca el punto de encuentro con un pin en el mapa o añade un enlace en línea.',
          'Añade el aforo (vacío = ilimitado), el precio, los requisitos y la lista de equipo.',
          'Si hace falta, activa «Asistencia con aprobación» y guarda.',
        ],
        notes: [
          'El formulario muestra cuántos eventos te quedan este mes. Los eventos cancelados cuentan para el límite mensual de tu plan.',
          'El formulario también muestra cuántos eventos tienen ese día otros grupos de la misma categoría en tu provincia; puedes cambiar la fecha.',
        ],
      ),
      GuideTopic(
        'Evento recurrente',
        intro: 'Al crearlo, elige «Cada semana» o «Cada dos semanas» en «Repetir» para abrir una serie (con fecha de fin opcional, como máximo 1 año).',
        notes: [
          'Una serie siempre mantiene abiertas las próximas 4 semanas. Cada fecha tiene sus propios asistentes y lista de espera.',
          'Si editas la última fecha, las fechas que se abran después seguirán ese modelo.',
          'Con «Dejar de repetir» en el menú del evento detienes la serie; las fechas ya abiertas se quedan y puedes cancelarlas una a una.',
          'Si se alcanza el límite mensual, la fecha no se abre y recibes una notificación; se abre cuando haya hueco.',
        ],
      ),
      GuideTopic(
        'Configurar un lugar sorpresa',
        steps: [
          'Activa «Lugar sorpresa» en el formulario.',
          'Escribe una pista en el campo «Lugar»; introduce aparte el lugar real y el punto de encuentro.',
          'Elige cuándo se revela: 1, 3, 6, 12 o 24 horas antes del inicio.',
        ],
        notes: ['Si desactivas la sorpresa, el lugar oculto se borra y «Lugar» pasa a ser el lugar normal.'],
      ),
      GuideTopic(
        'Gestionar asistentes',
        notes: [
          'Con asistencia con aprobación, apruebas o rechazas las solicitudes pendientes.',
          'En la lista de asistentes ves quién confirmó «¿Vienes?».',
          'Tras el evento, marcas a quienes no fueron como «no vino»; no cuentan como asistencia.',
          'Edición: pueden cambiar el título, la descripción, la hora, el lugar, el aforo, el precio y la portada. Si cambian la hora o el lugar, se avisa a los asistentes. El aforo no puede bajar del número de inscritos.',
          'Cancelación: cancelas indicando el motivo; se avisa a asistentes y personas en espera. Los eventos pasados no se pueden editar.',
        ],
      ),
      GuideTopic(
        'Crear una encuesta y votar',
        steps: [
          'Toca «Crear encuesta» en la página del grupo (propietario y administradores).',
          'Escribe la pregunta y de 2 a 10 opciones.',
          'Si quieres, permite varias respuestas, haz la encuesta anónima, pon una hora de fin o vincúlala a un evento.',
        ],
        notes: [
          'Solo los miembros del grupo ven las encuestas y sus resultados.',
          'En una encuesta anónima nadie puede ver quién votó qué, ni siquiera quien la creó.',
          'Cuando la encuesta se cierra ya no se puede votar y los resultados se quedan. Una persona autorizada puede cerrarla antes o borrarla.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'calendar',
    title: 'Calendario, Esta noche y descubrir',
    summary: 'Calendario, Libre esta noche, mesa pequeña, mapa, liga, resumen del año.',
    topics: [
      GuideTopic(
        'Mi calendario',
        notes: [
          'La pestaña Calendario muestra los eventos a los que vas, los que esperan aprobación y en los que estás en lista de espera.',
          'Activa «Eventos de mis grupos» para ver también todos los eventos de tus grupos.',
          'Cambia entre vista de día, semana y mes.',
          'Los eventos que coinciden en horario aparecen marcados.',
          'También puedes abrir el calendario de un grupo desde su página.',
        ],
      ),
      GuideTopic(
        'Libre esta noche',
        steps: [
          'Toca «+» → «Esta noche».',
          'Activa «Libre esta noche»; si quieres, añade una nota breve (p. ej. «café, paseo corto»).',
        ],
        notes: [
          'Tu estado solo lo ven quienes comparten al menos un grupo contigo.',
          'El estado se desactiva solo a las 04:00; también puedes desactivarlo tú cuando quieras.',
        ],
      ),
      GuideTopic(
        'Mesa pequeña',
        intro: 'Organiza un pequeño encuentro con gente libre esta noche.',
        steps: [
          'En la página «Esta noche», toca «Montar una mesa pequeña».',
          'La app elige e invita a 3–5 personas libres esta noche con las que compartes grupos.',
          'Chateas con quienes aceptan en el chat de la mesa.',
        ],
        notes: [
          'Debe haber al menos 2 personas a las que invitar; si no, la tarjeta indica cuántas faltan.',
          'Solo puedes unirte a una mesa por noche.',
          'La mesa se cierra a las 12:00 del día siguiente; el chat se puede leer, pero ya no escribir.',
        ],
      ),
      GuideTopic(
        'Descubrir con el mapa',
        steps: [
          'En la pestaña Grupos, toca Mapa arriba a la derecha.',
          'Mueve el mapa; filtra por categoría, fecha (hoy, 7 días) y distancia desde el centro del mapa (5–50 km).',
          'Elige la vista de mapa o de lista.',
        ],
        notes: [
          'El mapa solo muestra eventos futuros y grupos activos. Tu ubicación no se usa en el mapa ni se muestra a nadie.',
          'Si el mapa está desactivado temporalmente, arriba pone «El mapa no está disponible ahora.»',
        ],
      ),
      GuideTopic(
        'Liga de grupos',
        intro: 'Los grupos de la misma categoría y provincia suman puntos cada mes organizando buenos eventos.',
        notes: [
          'Puntos: cada asistente, cada evento con al menos 3 asistentes, cada bienvenida y cada valoración de 4–5 estrellas.',
          'En caso de empate, va delante el grupo con menos miembros.',
          'Al cerrar el mes, se avisa a los miembros de los tres primeros grupos; las posiciones aparecen en la tarjeta de la liga de la página del grupo.',
        ],
      ),
      GuideTopic(
        'Resumen del año y mi mapa de exploración',
        steps: [
          'Toca Resumen del año arriba a la derecha de la pestaña Yo.',
          'Elige «Resumen del año», «Mi mapa de exploración» o «Gente que conocí».',
        ],
        notes: [
          'Resumen del año: número de eventos, horas totales, grupos, provincias y categorías. Puedes compartirlo como tarjeta de historia.',
          'Mi mapa de exploración: las provincias de tus eventos se rellenan en el mapa de Turquía («He explorado 7 / 81 provincias»).',
          'Solo tú ves estas páginas; nadie más, salvo que las compartas.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'live',
    title: 'Audio en directo',
    summary: 'Entrar, hablar, reacciones, iniciar y dirigir un directo.',
    topics: [
      GuideTopic(
        'Entrar en un directo',
        steps: [
          'Toca la tarjeta «En directo ahora» de Hoy, la tarjeta de directo de la página del grupo o la notificación.',
          'Al conectarte ves quién está en el escenario y quién escucha.',
        ],
        notes: ['Solo pueden entrar los miembros del grupo. Quien sea expulsado de un directo no puede volver a entrar.'],
      ),
      GuideTopic(
        'Moverte por la app durante un directo',
        intro: 'El botón atrás o la flecha hacia abajo de arriba a la izquierda no te sacan del directo; la pantalla se reduce y el audio sigue.',
        notes: [
          'Arriba de cada página aparece la franja «Estás en directo». Tócala para volver al directo.',
          'Si estás en el escenario, también puedes silenciar y activar tu micro desde la franja.',
          'Para salir, toca «Salir» en la pantalla del directo. Si entras en otro directo, sales del anterior.',
        ],
      ),
      GuideTopic(
        'Hablar: levantar la mano y escenario',
        steps: [
          'Si estás escuchando, levanta la mano con el botón ✋.',
          'Cuando un anfitrión te sube al escenario, aparece tu botón de micro; tócalo y habla.',
          'Para bajar del escenario tú mismo, toca «Bajar del escenario».',
        ],
        notes: [
          'Si un anfitrión silenció tu micro, no puedes activarlo tú; solo un anfitrión puede volver a abrirlo.',
          'El borde de la foto de quien habla se ilumina.',
        ],
      ),
      GuideTopic(
        'Reacciones y comentarios',
        notes: [
          'Con el botón de reacciones envías ❤️ 👏 😂 🔥 😮 🙌; cruzan la pantalla y no se guardan.',
          'Con el botón de comentarios escribes comentarios. Los comentarios se quedan con el registro del directo.',
          'Mantén pulsado tu comentario para borrarlo; puedes denunciar el de otros.',
        ],
      ),
      GuideTopic(
        'Iniciar un directo',
        intro: 'El propietario y los administradores del grupo inician directos.',
        steps: [
          'Toca «Iniciar directo» en la tarjeta de directo de la página del grupo.',
          'Escribe un título. Empieza ya o prográmalo para más tarde.',
        ],
        notes: [
          'Un grupo puede tener a la vez un directo en curso y hasta cinco programados.',
          'Un directo programado aparece como «Próximo» en la página del grupo; los miembros tocan «Recordarme». El anfitrión puede iniciarlo como mucho 15 minutos antes de la hora prevista.',
          'Los minutos de directo dependen del plan del grupo; la pantalla de inicio muestra los minutos restantes. Al agotarse, el directo termina solo.',
          'Si el anfitrión sale y no vuelve en 2 minutos, el directo termina solo.',
        ],
      ),
      GuideTopic(
        'Dirigir un directo',
        intro: 'Los anfitriones son quien inició el directo y el equipo de moderación del grupo.',
        notes: [
          'Toca a una persona para subirla al escenario, bajarla, o silenciar o activar su micro.',
          '«Expulsar del directo»: la persona no puede volver a este directo.',
          'Las manos levantadas aparecen arriba, en la tarjeta «levantó la mano».',
          '«Terminar el directo para todos» está en el menú de arriba a la derecha.',
          'En el escenario caben hasta 10 personas, incluido el anfitrión. Aquí también se aplica la regla de rango.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'messages',
    title: 'Mensajes y llamadas de voz',
    summary: 'Con quién puedes escribir, chat de grupo, privacidad, llamadas de voz.',
    topics: [
      GuideTopic(
        '¿Con quién puedo escribirme?',
        notes: [
          'Los mensajes directos solo están abiertos con tus matches y compañeros de equipo. Seguir no da derecho a escribir.',
          'Escribir a un match requiere el plan Chat de match; escribir a un compañero, el plan Compañero de equipo. Leer los mensajes recibidos es gratis.',
          'Los chats de grupo son gratis; todos los miembros pueden escribir.',
          'La pantalla Mensajes está tras el botón Mensajes, arriba a la derecha de Hoy. El número de no leídos aparece en el botón.',
        ],
      ),
      GuideTopic(
        'Escribir y borrar mensajes',
        notes: [
          'Puedes enviar texto (hasta 2.000 caracteres) y una foto.',
          'Mientras se envía, aparece «Enviando…». Si falla, el texto vuelve al cuadro con el motivo.',
          'En un chat individual aparece «Visto» cuando la otra persona lo lee.',
          'Puedes borrar tu mensaje para todos; en su lugar aparece «Este mensaje se ha eliminado» y su contenido se borra por completo.',
        ],
      ),
      GuideTopic(
        'Privacidad de los mensajes',
        intro: 'El equipo de la plataforma GWAY no puede leer tus mensajes privados, escuchar tus llamadas ni ver quién llamó a quién.',
        notes: [
          'Puedes denunciar un mensaje. Las denuncias de mensajes directos van al equipo de la plataforma; las del chat de grupo, a la moderación del grupo.',
          'El comité disciplinario de un grupo no puede ver tus mensajes directos.',
        ],
      ),
      GuideTopic(
        'Obtener permiso para llamadas de voz',
        intro: 'Las llamadas de voz individuales no están abiertas a todos; el permiso lo da el propietario o un administrador de un grupo al que perteneces.',
        steps: [
          'Abre Ajustes → «Llamadas de voz».',
          'Elige un grupo al que pertenezcas, escribe si quieres una nota breve y envía la solicitud.',
          'Ves tu estado en la misma pantalla: en revisión, activado o desactivado (con el motivo). La decisión también llega como notificación.',
        ],
        notes: ['Si sales del grupo que te dio el permiso, este se desactiva.'],
      ),
      GuideTopic(
        'Hacer una llamada de voz',
        steps: [
          'Abre el chat con tu match o compañero de equipo.',
          'Toca el botón «Llamada de voz» arriba a la derecha.',
        ],
        notes: [
          'Los dos necesitáis permiso de llamada y el mismo acceso de plan que para el chat. Si no puedes llamar, el motivo aparece en lugar del botón.',
          'Una llamada no contestada en 30 segundos queda como perdida. Una llamada dura como máximo 60 minutos.',
          'Las llamadas nunca se graban y están cifradas de extremo a extremo. Si el código de seguridad de 12 dígitos es igual en las dos pantallas, nadie está escuchando.',
          'Solo puedes estar en una llamada a la vez; a quien está ocupado no se le puede llamar.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'matching',
    title: 'Matches y compañeros de equipo',
    summary: 'Amistad y citas, planes personales, buscar compañeros de equipo.',
    topics: [
      GuideTopic(
        '¿Cómo funcionan los matches?',
        intro: 'Los matches te ayudan a encontrar amistad o pareja entre personas con las que compartes grupos. Funcionan con un perfil de match aparte; nadie te ve ahí mientras no lo actives.',
        steps: [
          'Toca Matches arriba a la derecha de la pestaña Yo (en el menú de la izquierda en pantallas grandes).',
          'Crea tu perfil de match: Amistad, Citas o ambos; 2–6 fotos, fecha de nacimiento, género, provincia, «sobre mí».',
          'En Citas, elige los géneros que buscas y un rango de edad.',
          'Da tu consentimiento expreso.',
        ],
        notes: [
          'En tu baraja solo aparecen personas que comparten al menos un grupo contigo y activaron el mismo modo.',
          'En Citas, las preferencias de ambos deben coincidir.',
          'Como ubicación solo se usa tu provincia.',
        ],
      ),
      GuideTopic(
        'Deslizar y hacer match',
        notes: [
          'Desliza a la derecha: like. A la izquierda: pasar. Hacia arriba: superlike. Los botones de abajo hacen lo mismo.',
          'Toca los bordes de la tarjeta para cambiar de foto; el botón «i» abre el perfil completo.',
          'Si os dais like en el mismo modo, hacéis match y recibís una notificación.',
          'Tus likes y superlikes gratis del día aparecen en la pantalla de matches.',
          'A quien pasaste se te puede volver a sugerir tras 90 días.',
        ],
      ),
      GuideTopic(
        'Planes personales',
        intro: 'Cada función se vende como un plan aparte; compras solo lo que quieres.',
        notes: [
          'Mis matches: ver con quién hiciste match. Sin él sabes que hay match, pero la persona queda oculta.',
          'Chat de match: escribir a tus matches.',
          'Quién te dio like: la lista de quienes te dieron like.',
          'Likes ilimitados: likes ilimitados, deshacer y filtros.',
          'Superlike y Boost: más superlikes y aparecer el primero en las barajas una vez al día.',
          'Compañero de equipo: la sección de compañeros y escribirles.',
          'Todo en uno: todo.',
          'Los planes son de prepago, no se renuevan solos y se compran en la web. Los precios aparecen en Matches → Planes.',
        ],
      ),
      GuideTopic(
        'Terminar, pausar y borrar',
        notes: [
          'Si terminas un match, vuestro chat se cierra, se quita el seguimiento mutuo y no apareceréis en la baraja del otro.',
          'Si hicisteis match en los dos modos, puedes elegir «Quedarse solo como amigos» o «Quedarse solo en citas».',
          'Si pausas tu perfil, tu baraja y tus likes se detienen; los matches existentes se quedan.',
          'Puedes borrar todos tus datos de match (perfil, fotos, likes, matches) con un toque.',
          'Puedes denunciar perfiles y fotos de match.',
        ],
      ),
      GuideTopic(
        'Buscar compañeros de equipo',
        intro: 'Encuentra gente con quien entrenar, hacer senderismo o subir al escenario.',
        steps: [
          'En Ajustes → «Preferencias de compañeros de equipo», activa «Busco equipo».',
          'Elige tus actividades, nivel, objetivos, frecuencia, horarios disponibles y, si quieres, tu provincia.',
          'En la pestaña Yo, el botón «Buscar compañeros de equipo» muestra sugerencias. Cada una indica por qué (actividad en común, grupo en común, misma provincia…).',
          'Envía una solicitud (con un mensaje de hasta 200 caracteres). Cuando la otra persona acepta, sois compañeros de equipo.',
        ],
        notes: [
          'Tu provincia solo se usa para las sugerencias y no aparece en tu perfil.',
          'Puedes enviar como máximo 20 solicitudes al día y una al día a la misma persona.',
          'La sección de compañeros requiere el plan Compañero de equipo.',
          'Cualquiera de los dos puede terminar la relación de compañeros cuando quiera.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'notifications',
    title: 'Notificaciones',
    summary: 'Tipos de notificación, preferencias y notificaciones del móvil.',
    topics: [
      GuideTopic(
        'La pantalla Notificaciones',
        notes: [
          'Se abre con la campana de arriba a la derecha de Hoy; el número de no leídas aparece en el botón.',
          'Las notificaciones se agrupan en Hoy / Esta semana / Antes; las solicitudes de seguimiento pendientes están arriba.',
          'Toca una notificación para abrir la página relacionada.',
        ],
      ),
      GuideTopic(
        'Preferencias de notificaciones',
        steps: ['Abre Ajustes → «Preferencias de notificaciones».', 'Desactiva las que no quieras.'],
        notes: [
          'Se pueden desactivar: recordatorios de eventos, cambios y cancelaciones, peticiones de valoración, avisos de directo, mensajes personales, mensajes de grupo y avisos de matches.',
          'Las notificaciones que te afectan directamente, como una aprobación, que te toque en la lista de espera o una sanción, no se pueden desactivar.',
        ],
      ),
      GuideTopic(
        'No me llegan las notificaciones del móvil',
        steps: [
          'La app pide permiso al abrirse por primera vez; si no lo diste, actívalo en Ajustes del móvil → Aplicaciones → GWAY → Notificaciones.',
          'En Android, comprueba que los canales «Mensajes», «Llamadas de voz» y «Notificaciones» están activados.',
          'Revisa las preferencias de notificaciones en la app.',
        ],
        notes: ['Si el móvil está en silencio, las notificaciones no suenan.'],
      ),
    ],
  ),
  GuideChapter(
    id: 'safety',
    title: 'Seguridad, denuncias y sanciones',
    summary: 'Denunciar, sanciones de grupo, apelación, verificación en dos pasos.',
    topics: [
      GuideTopic(
        'Denunciar',
        steps: [
          'Abre el menú de la publicación, comentario, evento, comentario del directo, mensaje o perfil.',
          'Toca «Denunciar», elige un motivo y, si quieres, escribe una breve descripción.',
        ],
        notes: [
          'La persona denunciada no ve la denuncia ni a ti. Los administradores del grupo tampoco ven quién denunció.',
          'Las denuncias de un grupo van a su moderación; las demás, al equipo de la plataforma.',
          'No puedes denunciarte ni denunciar tu propio contenido; el mismo contenido lo denuncias una vez mientras la denuncia esté abierta.',
        ],
      ),
      GuideTopic(
        'Sanciones de grupo',
        notes: [
          'Advertencia: queda registrada y recibes una notificación.',
          'Silencio (1–90 días): no puedes publicar ni comentar en el grupo ni escribir en su chat; en los directos solo puedes escuchar.',
          'Expulsión: te sacan del grupo; después puedes volver a unirte.',
          'Bloqueo (temporal o permanente): mientras dure, no puedes unirte al grupo, enviar solicitudes ni recibir invitaciones.',
          'Tus sanciones aparecen en Ajustes → «Mis sanciones de grupo».',
        ],
      ),
      GuideTopic(
        'Apelar una sanción',
        steps: [
          'Abre Ajustes → «Mis sanciones de grupo».',
          'Toca «Apelar» junto a la sanción y escribe tus motivos (10–1000 caracteres).',
        ],
        notes: [
          'Puedes apelar cada sanción una vez en 7 días. El silencio de urgencia no se puede apelar.',
          'La apelación la resuelve el propietario del grupo; si es parte del caso, decide el equipo de la plataforma.',
          'Mientras se decide, la sanción sigue. La decisión te llega como notificación.',
        ],
      ),
      GuideTopic(
        'Suspensión y bloqueo de la cuenta',
        notes: [
          'El equipo de la plataforma puede suspender o cerrar una cuenta que incumpla las normas. En ese caso, la app te muestra el motivo y la fecha de fin.',
          'Durante la suspensión tu perfil se ve, pero tu contenido se oculta; una cuenta cerrada definitivamente no aparece en ningún sitio.',
          'Si por decisión de grupo se marca actividad ilegal (como violencia, amenazas o fraude), la cuenta se suspende hasta que la plataforma la revise.',
          'Si crees que hay un error, escribe al equipo de soporte.',
        ],
      ),
      GuideTopic(
        'Verificación en dos pasos',
        steps: [
          'Abre Ajustes → «Verificación en dos pasos».',
          'Añade una app de autenticación (p. ej. Google Authenticator) o, en la web, configura el acceso con huella y reconocimiento facial.',
        ],
        notes: ['El método que configures aparece primero en los siguientes accesos; el SMS siempre queda como respaldo.'],
      ),
    ],
  ),
  GuideChapter(
    id: 'moderation',
    title: 'Moderación de grupo',
    summary: 'Para responsables: revisar denuncias, casos disciplinarios, votación, bloqueo.',
    topics: [
      GuideTopic(
        'La pantalla de moderación',
        intro: 'La tarjeta de moderación de la página del grupo muestra el número de tareas pendientes. La ven el propietario, los administradores, los miembros del comité y los moderadores.',
        notes: [
          'Denuncias: las denuncias del mismo contenido se agrupan en una fila. Rechazar, Retirar contenido o Abrir caso.',
          'Casos: casos en votación, tiempo restante y votos; vota.',
          'Sanciones y apelaciones: aquí el propietario resuelve las apelaciones.',
        ],
      ),
      GuideTopic(
        'Caso disciplinario y votación',
        steps: [
          'Desde una denuncia o el menú del miembro en la página de miembros, elige «Abrir un caso disciplinario».',
          'Elige la sanción propuesta (advertencia, silencio, expulsión, bloqueo) y su duración, y escribe el motivo.',
          'En una urgencia, marca «Silenciar ya (24 horas)»; la persona queda silenciada hasta la decisión.',
        ],
        notes: [
          'Los miembros del comité disciplinario votan en 72 horas. En un grupo sin comité, el propietario decide solo.',
          'El umbral de decisión por defecto es la mayoría simple; el propietario puede elegir dos tercios o unanimidad en los ajustes de la pantalla de moderación.',
          'Al superarse el umbral, el caso se aprueba al instante y se aplica la sanción. Si nadie vota, el caso se rechaza.',
          'Solo puede haber un caso abierto a la vez sobre una persona. Se aplica la regla de rango.',
        ],
      ),
      GuideTopic(
        'Bloqueo sin votación',
        intro: 'El propietario y los administradores pueden bloquear a alguien sin esperar al comité.',
        steps: [
          'En «Abrir un caso disciplinario», elige bloqueo como sanción.',
          'Marca «Aplicar ya, sin votación».',
          'Indica la duración (1–365 días o permanente) y el motivo.',
        ],
        notes: [
          'Un administrador no puede bloquear a otro administrador ni al propietario.',
          'Si se trata de un delito, márcalo como «actividad ilegal» y elige la categoría; la cuenta de la persona se suspende hasta que la plataforma la revise.',
          'La persona puede apelar en 7 días.',
        ],
      ),
      GuideTopic(
        'Actuación urgente en un directo',
        intro: 'Ante un caso como el acoso durante un directo, un anfitrión silencia al momento el micro de la persona o la expulsa del directo. Después, si hace falta, se abre un caso disciplinario.',
      ),
    ],
  ),
  GuideChapter(
    id: 'account',
    title: 'Cuenta, privacidad y soporte',
    summary: 'Documentos legales, tus datos, eliminar la cuenta, cerrar sesión, soporte.',
    topics: [
      GuideTopic(
        '¿Cómo se protegen mis datos?',
        notes: [
          'Tu ubicación solo se usa para la seguridad de la cuenta; no aparece en el mapa ni en tu perfil.',
          'Tu fecha de nacimiento no se muestra a nadie.',
          'El equipo de la plataforma no puede leer tus mensajes privados.',
          'Los documentos que aceptaste están en Ajustes → «Documentos legales».',
        ],
      ),
      GuideTopic(
        'Eliminar mi cuenta',
        steps: [
          'Abre Ajustes → «Eliminar cuenta».',
          'Confirma la eliminación.',
        ],
        notes: [
          'Tu perfil se oculta a los demás al instante. Durante 30 días puedes iniciar sesión y elegir «deshacer la eliminación».',
          'Pasados 30 días, tu cuenta, publicaciones, mensajes y archivos se borran para siempre.',
          'Si eres propietario de un grupo, antes debes transferir la propiedad o eliminar el grupo.',
        ],
      ),
      GuideTopic(
        'Cerrar sesión',
        intro: 'Toca «Cerrar sesión» al final de Ajustes. El móvil en el que cierras sesión deja de recibir notificaciones.',
      ),
      GuideTopic(
        'Escribir al equipo de soporte',
        steps: [
          'Abre Ajustes → «Soporte y comentarios».',
          'Toca «Nuevo mensaje» y elige el tipo: Problema (algo no funciona), Solicitud (una gestión para tu cuenta, grupo o pago), Sugerencia (nueva función o idea).',
          'Escribe el asunto y la descripción; puedes añadir hasta 3 imágenes.',
        ],
        notes: [
          'Cuando llega una respuesta, la fila de Ajustes indica «nueva respuesta». Estados del mensaje: Nuevo, En revisión, Resuelto, Cerrado.',
          'Si administras un grupo, también puedes abrir un mensaje para ese grupo desde su página.',
        ],
      ),
    ],
  ),
];
