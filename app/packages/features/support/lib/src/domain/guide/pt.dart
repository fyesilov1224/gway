import '../guide.dart';

// Portuguese (Brazil) translation of tr.dart; keep chapters, topics, steps and notes in step with it.

const guidePt = <GuideChapter>[
  GuideChapter(
    id: 'start',
    title: 'Primeiros passos',
    summary: 'Cadastro, login, verificação e como navegar pelo app.',
    topics: [
      GuideTopic(
        'O que é o GWAY?',
        intro: 'O GWAY é uma plataforma social que reúne todo tipo de comunidade: trilha, corrida, ciclismo, música, '
            'natureza, esporte, arte e muito mais. Você entra em grupos, vai a eventos, conversa em salas de áudio ao vivo '
            'e conhece gente nova.',
        notes: [
          'O GWAY é aberto a maiores de 18 anos.',
          'O app funciona no celular (Android, iOS) e no navegador; sua conta é a mesma em todo lugar.',
        ],
      ),
      GuideTopic(
        'Criar uma conta',
        steps: [
          'Na tela de login, toque em "Cadastrar".',
          'Digite seu e-mail e uma senha. Você também pode se cadastrar com Google ou Apple.',
          'Se você se cadastrou por e-mail, toque no link de verificação que chegou na sua caixa de entrada. Sem verificar o e-mail não é possível entrar.',
          'Depois do login, o app leva você pela verificação de segurança, pela aceitação dos documentos legais, pela data de nascimento e pela criação do perfil.',
        ],
        tip: 'Se o e-mail de verificação não chegou, confira a pasta de spam.',
      ),
      GuideTopic(
        'Esqueci minha senha',
        steps: [
          'Na tela de login, toque em "Esqueci a senha".',
          'Digite o e-mail da sua conta.',
          'Crie uma senha nova pelo link do e-mail que você receber.',
        ],
      ),
      GuideTopic(
        'Verificação de segurança: localização, telefone e segunda etapa',
        intro: 'Para evitar contas falsas, o app pode pedir estas etapas.',
        steps: [
          'Localização: o app pede permissão de localização. Sem ela, o app não abre e você vê uma tela que leva às configurações. '
              'Sua localização é usada só para a segurança da conta e não é mostrada a ninguém.',
          'Telefone: você digita um número do país em que está e informa o código do SMS. Isso é feito uma vez; um número só pode ser usado em uma conta.',
          'Segunda etapa: a cada novo login chega um código por SMS no seu número cadastrado. Se você configurou um app autenticador ou a digital, usa isso.',
        ],
        tip: 'Depois de verificar o telefone, aceite a sugestão "Adicionar digital" ou "Adicionar Google Authenticator" para entrar mais rápido nas próximas vezes. O SMS fica como reserva.',
      ),
      GuideTopic(
        'Documentos legais e data de nascimento',
        intro: 'Você precisa aceitar os termos de uso, o aviso de privacidade, o consentimento explícito e as regras da comunidade.',
        steps: [
          'Abra cada documento e role até o fim. Sem ler, a caixa não pode ser marcada.',
          'Toque em "Li e aceito" no fim do documento.',
          'Informe sua data de nascimento. Ela não é mostrada a ninguém e não pode ser alterada depois; se errou, escreva para a equipe de suporte.',
        ],
        notes: ['Quando uma nova versão de um documento é publicada, o app pede que você a aceite de novo.'],
      ),
      GuideTopic(
        'Criar seu perfil',
        steps: [
          'Escolha um nome de usuário: 3–30 caracteres; letras minúsculas, números, sublinhado e ponto são permitidos.',
          'Adicione seu nome de exibição e foto de perfil.',
          'Escolha seus interesses (até 10). Grupos e sugestões se baseiam neles.',
        ],
        notes: ['Você pode mudar seu nome de usuário uma vez a cada 30 dias.'],
      ),
      GuideTopic(
        'Navegar pelo app',
        intro: 'A barra inferior tem quatro abas e um botão "+" no meio.',
        notes: [
          'Hoje: transmissões ao vivo agora, eventos que começam logo e publicações de quem você segue. No canto superior direito ficam Pesquisar, Notificações e Mensagens.',
          'Grupos: buscar e descobrir grupos. No canto superior direito ficam Liga dos grupos e Mapa.',
          'Agenda: os eventos a que você vai e os dos seus grupos.',
          'Eu: seu próprio perfil. No canto superior direito ficam Notificações, Salvos, Matches, Encontrar parceiros de equipe, Retrospectiva do ano e Configurações.',
          'O botão "+": Hoje à noite, Próximos e criar publicação, story ou grupo.',
          'Em telas grandes (web, tablet), as mesmas seções ficam no menu à esquerda, com os grupos de que você participa logo abaixo.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'profile',
    title: 'Perfil e seguidores',
    summary: 'Editar o perfil, privacidade, seguir, bloquear, selos.',
    topics: [
      GuideTopic(
        'Editar meu perfil',
        steps: [
          'Na aba Eu, toque em Configurações no canto superior direito e depois em "Editar perfil".',
          'Mude a foto de perfil, a capa, o nome de exibição, a bio e os interesses.',
          'Salve.',
        ],
        notes: ['As imagens podem ter até 5 MB (JPEG, PNG ou WebP).'],
      ),
      GuideTopic(
        'Conta privada',
        intro: 'Com Configurações → "Conta privada" ativada, só os seguidores que você aprovar veem suas publicações e stories.',
        notes: [
          'Com conta privada, quem quer seguir você envia um pedido; você aprova ou recusa no topo da tela Notificações. Quem é recusado não é avisado.',
          'Quando você volta a deixar a conta pública, os pedidos pendentes são aprovados automaticamente.',
        ],
      ),
      GuideTopic(
        'Mostrar meus grupos no perfil',
        intro: 'Configurações → "Mostrar meus grupos no perfil" vem desativado.',
        notes: [
          'Enquanto estiver desativado, só os membros de um grupo veem que você participa dele. O administrador de outro grupo não vê em quais grupos você está.',
          'Se ativar, suas participações ficam visíveis para todos no seu perfil.',
          'Os grupos em que você faz parte da equipe de gestão (dono, administrador, conselho, moderador) são sempre públicos.',
        ],
      ),
      GuideTopic(
        'Seguir e amigos',
        steps: [
          'Toque em "Seguir" num perfil. Se a conta for privada, vai um pedido; você passa a seguir quando ele é aceito.',
          'Toque de novo no mesmo botão para deixar de seguir ou retirar o pedido.',
        ],
        notes: [
          'Se vocês se seguem, o perfil mostra "Amigo".',
          'Você pode remover alguém que segue você da sua lista de seguidores.',
          'Seguir não dá direito a mandar mensagem; mensagens diretas são entre matches e parceiros de equipe.',
          'Você também pode seguir grupos; as publicações dos grupos de que você participa já aparecem no seu feed.',
        ],
      ),
      GuideTopic(
        'Bloquear alguém',
        steps: [
          'No perfil da pessoa, abra o menu "Mais opções" no canto superior direito.',
          'Toque em "Bloquear".',
        ],
        notes: [
          'Os follows e pedidos nos dois sentidos são apagados. Vocês não veem o perfil, as publicações e os comentários um do outro; não podem trocar mensagens nem se mencionar.',
          'A pessoa bloqueada também não aparece no seu baralho de matches nem nas sugestões de parceiros.',
          'Quem você bloqueou fica em Configurações → "Contas bloqueadas", onde dá para desbloquear. O follow não volta sozinho depois.',
        ],
      ),
      GuideTopic(
        'Contribuições e selos',
        intro: 'As contribuições do seu perfil contam o que você faz na vida real; curtidas, seguidores e número de publicações não contam.',
        notes: [
          'Presença: eventos encerrados de que você participou sem ser marcado como "não compareceu".',
          'Organização: eventos que você criou e dos quais pelo menos outras 2 pessoas participaram.',
          'Lembrança: publicações que você compartilhou vinculadas a um evento.',
          'Exemplos de selos: Primeiro passo (1 presença), Frequentador (10), Companheiro de estrada (25), Explorador (3 grupos diferentes), Organizador, Guardião de lembranças, Avaliador, "Fã de <categoria>", selos de boas-vindas e de aperto de mão, e metas concluídas.',
          'Não existem rankings nem listas de "melhores".',
        ],
      ),
      GuideTopic(
        'Salvos e arquivo de stories',
        notes: [
          'Para salvar uma publicação, toque no ícone de salvar do card. Só você vê o que salvou: Eu → Salvos ou Configurações → Salvos.',
          'Stories expirados não são apagados; ficam em Configurações → "Arquivo de stories".',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'feed',
    title: 'Hoje, publicações e stories',
    summary: 'Compartilhar, curtidas, comentários, explorar e pesquisar.',
    topics: [
      GuideTopic(
        'A tela Hoje',
        notes: [
          'No topo, "Ao vivo agora": as transmissões dos seus grupos. Toque num card para entrar.',
          'Depois, "Começa em breve": eventos das próximas horas; primeiro os dos seus grupos, depois os das províncias dos seus grupos.',
          'Embaixo, o feed: suas publicações, as de quem você segue e as dos grupos que você segue ou de que participa, das mais novas para as mais antigas.',
          'Puxe a tela para baixo para atualizar.',
        ],
      ),
      GuideTopic(
        'Compartilhar uma publicação',
        steps: [
          'Toque no botão "+" embaixo e depois em "Publicação".',
          'Escolha até 10 fotos ou vídeos. Um vídeo pode ter até 60 segundos e 50 MB.',
          'Para fotos, escolha a proporção (Original, 1:1, 4:5, 1,91:1) e ajuste o enquadramento.',
          'Escreva uma legenda. Você pode adicionar #hashtags e mencionar alguém com @usuario.',
          'Se quiser, desative os comentários ou oculte o número de curtidas e compartilhe.',
        ],
        notes: [
          'Os dados de localização das suas fotos são removidos antes do envio.',
          'Você pode editar a publicação depois; só a legenda e as opções mudam. Se apagar, as mídias também são apagadas.',
          'Para publicar num grupo, compartilhe pela página do grupo. Todo membro pode publicar; membros silenciados não.',
        ],
      ),
      GuideTopic(
        'Curtidas, reações e comentários',
        notes: [
          'Você pode curtir uma publicação ou reagir com 😍 😂 😮 👏 🔥 🙏. Dá para mudar ou retirar a reação.',
          'Quem pode ver a publicação pode comentar, a não ser que o autor tenha desativado os comentários.',
          'Você pode responder a um comentário e curtir comentários. As respostas têm um só nível.',
          'Você apaga seus próprios comentários e os das suas publicações. Em publicações de grupo, o dono e os administradores também podem apagar comentários.',
        ],
      ),
      GuideTopic(
        'Compartilhar um story',
        steps: [
          'Toque em "+" → "Story".',
          'Escolha uma foto ou um vídeo de até 60 segundos e compartilhe.',
        ],
        notes: [
          'O story fica visível por 24 horas e depois vai para o seu arquivo.',
          'Só você vê quem viu seu story.',
          'Adicione stories aos destaques para mantê-los no seu perfil.',
        ],
      ),
      GuideTopic(
        'Explorar e pesquisar',
        steps: [
          'Toque em Pesquisar no canto superior direito da tela Hoje.',
          'Pesquise pessoas ou #hashtags. Para buscar grupos, use a aba Grupos.',
        ],
        notes: [
          'Explorar mostra as publicações com mais interação das últimas duas semanas, de contas públicas e grupos que você não segue.',
          'Você pode compartilhar o link de uma publicação; quem abrir verá se tiver permissão.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'groups',
    title: 'Grupos',
    summary: 'Encontrar e entrar em grupos, papéis e a página do grupo.',
    topics: [
      GuideTopic(
        'Encontrar um grupo',
        notes: [
          'Na aba Grupos, pesquise pelo nome ou escolha uma categoria.',
          'Com o botão Mapa no canto superior direito, veja grupos e eventos perto de você.',
          'Com a Liga dos grupos, veja os grupos que fazem os melhores eventos na sua categoria e província.',
          'Todo grupo ativo tem página pública; não existe grupo secreto.',
        ],
      ),
      GuideTopic(
        'Entrar num grupo',
        intro: 'O tipo de entrada do grupo aparece no botão:',
        notes: [
          'Livre: toque em "Entrar" e você vira membro na hora.',
          'Com pedido: você envia um pedido e um administrador aprova. Você pode retirar o pedido.',
          'Por convite: um administrador convida você pelo nome de usuário; você aceita ou recusa na tela Notificações.',
          'Link de convite: abra o link que recebeu e toque em "Entrar no grupo" para virar membro, seja qual for o tipo de entrada.',
          'Se o limite de membros do plano do grupo for atingido, ninguém novo pode entrar.',
        ],
        tip: 'Ao entrar no seu primeiro grupo, você ganha uma única vez 30 dias de teste do plano pessoal "Tudo em um" (recursos de match e parceiros).',
      ),
      GuideTopic(
        'Sair de um grupo',
        steps: [
          'Toque no botão de participação na página do grupo.',
          'Escolha "Sair do grupo".',
        ],
        notes: [
          'Seus papéis são removidos e sua presença nos próximos eventos do grupo é cancelada.',
          'O dono não pode sair do grupo; antes precisa transferir a propriedade.',
        ],
      ),
      GuideTopic(
        'O que tem na página do grupo?',
        notes: [
          'Capa, logo, apresentação, regras, links, província e categoria.',
          'Card ao vivo: transmissões em andamento e agendadas.',
          'Eventos, avaliações "Como foi?" e a nota média do grupo.',
          'Enquetes, metas, o card da liga e as publicações do grupo.',
          'Membros: a equipe de gestão é pública; a lista completa só os membros veem.',
          'Chat do grupo: cada grupo tem um único chat que só os membros leem e escrevem.',
        ],
      ),
      GuideTopic(
        'Papéis no grupo',
        intro: 'Um membro pode ter mais de um papel. O número entre parênteses é a posição.',
        notes: [
          'Dono do grupo (100): tudo, pagamento e atribuição de papéis.',
          'Administrador (80): conteúdo, eventos, enquetes, aprovar e convidar membros, transmissões, banimento sem votação, pedidos de chamada de voz.',
          'Conselho disciplinar (60): vota nos casos disciplinares; analisa denúncias, silenciamento de emergência, moderação ao vivo.',
          'Moderador (50): análise prévia de denúncias, silenciamento de emergência, moderação ao vivo.',
          'Membro (10): participar, publicar, entrar em transmissões.',
          'Regra de posição: ninguém pode punir alguém de posição igual ou superior. O dono não pode ser banido.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'group-admin',
    title: 'Criar e gerenciar um grupo',
    summary: 'Para donos e administradores: grupo, convites, papéis, planos, metas.',
    topics: [
      GuideTopic(
        'Criar um grupo',
        steps: [
          'Toque em "+" → "Grupo".',
          'Digite o nome (3–60 caracteres) e o endereço do grupo. O endereço é o link da página (/g/endereco) e não pode ser mudado depois.',
          'Escolha a categoria e a província. A província é necessária para o mapa e a Liga dos grupos.',
          'Escolha o tipo de entrada: livre, com pedido ou por convite.',
          'Adicione logo, capa, apresentação, regras e até 5 links.',
        ],
        notes: ['Quem cria o grupo é o dono. O grupo também ganha um chat próprio.'],
      ),
      GuideTopic(
        'Aceitar e convidar membros',
        notes: [
          'Num grupo com pedido, você aprova ou recusa os pedidos pendentes na página do grupo (dono e administradores).',
          'Você pode enviar convites pelo nome de usuário. Um grupo envia no máximo 50 convites em 24 horas; convites retirados também contam.',
          'Você pode retirar um convite enquanto ele não for aceito.',
        ],
      ),
      GuideTopic(
        'Link de convite',
        intro: 'O jeito mais fácil de trazer seu grupo do WhatsApp ou do Instagram.',
        steps: [
          'Abra a seção "Link de convite" na página do grupo.',
          'Escolha a validade (1, 7 ou 30 dias); se quiser, defina um limite de uso (1–1000 pessoas).',
          'Compartilhe o link. Quem abrir, entrar na conta e tocar em "Entrar no grupo" vira membro.',
        ],
        notes: [
          'Um grupo pode ter no máximo 20 links válidos ao mesmo tempo.',
          'Você pode revogar um link a qualquer momento; não dá para desfazer, basta criar outro.',
          'No WhatsApp, o link compartilhado aparece com o nome e a imagem do grupo.',
        ],
      ),
      GuideTopic(
        'Atribuir papéis e transferir a propriedade',
        notes: [
          'Só o dono dá e tira papéis: Administrador, Conselho disciplinar, Moderador. Papéis só vão para membros.',
          'Você pode transferir a propriedade para um membro ativo. Você continua como membro comum; o novo dono pode lhe dar um papel.',
          'Só o dono pode excluir o grupo. A exclusão é definitiva.',
          'Enquanto for dono de um grupo, você não pode excluir sua conta; antes transfira a propriedade ou exclua o grupo.',
        ],
      ),
      GuideTopic(
        'Planos do grupo',
        intro: 'O plano define o número máximo de membros, de eventos por mês e de minutos ao vivo por mês do grupo.',
        steps: [
          'Abra o card "Plano" na página do grupo para ver o plano atual, os limites e o uso.',
          'Compre o plano pela web. O app no celular só mostra o status do plano.',
        ],
        notes: [
          'Um grupo sem assinatura usa os limites do plano gratuito.',
          'Os planos são pré-pagos (mensais ou anuais); não há renovação automática e nenhum cartão é guardado.',
          'Ao fazer upgrade, o tempo restante passa para o novo plano. Se renovar o mesmo plano, o tempo é somado no fim.',
          'Pagamentos da Turquia são cobrados em TL pela PayTR; do exterior, em USD pela iyzico.',
          'Se o limite de membros for atingido, os atuais continuam, mas ninguém novo entra.',
          'Preços e limites atuais aparecem na tela de planos. Quem compra o plano é o dono.',
        ],
      ),
      GuideTopic(
        'Metas e tarefas',
        intro: 'Reúne o grupo em torno de um objetivo comum. O dono e os administradores criam as metas; o prêmio é um selo, sem dinheiro nem pontos.',
        notes: [
          'Meta pessoal: cada membro ganha um selo ao atingir o próprio número.',
          'Meta do grupo: quando o total do grupo chega ao alvo, todos que contribuíram ganham um selo.',
          'Meta por equipes: formam-se equipes e conta o total de cada uma.',
          'Tarefa: o membro toca em "Fiz" e adiciona uma nota curta; se um administrador aprovar, ganha um selo.',
          'O que conta: presença, organização ou lembranças. O servidor calcula o progresso.',
        ],
      ),
      GuideTopic(
        'Gerenciar o chat do grupo',
        notes: [
          'Você pode deixar o chat do grupo só para administradores escreverem (como um canal de avisos).',
          'Se uma mensagem inadequada for denunciada, ela vai para a tela de moderação do grupo; quem tem permissão pode removê-la.',
        ],
      ),
      GuideTopic(
        'Responder pedidos de chamada de voz',
        intro: 'Os membros pedem ao grupo permissão para chamadas de voz individuais. O dono e os administradores veem os pedidos.',
        steps: [
          'Abra "Pedidos de chamadas de voz" na página do grupo.',
          'Ative o pedido ou recuse-o com um motivo.',
          'Você pode desativar a qualquer momento uma permissão concedida, informando o motivo.',
        ],
        notes: ['Se a pessoa sair do grupo, for removida ou banida, a permissão é desativada automaticamente.'],
      ),
    ],
  ),
  GuideChapter(
    id: 'events',
    title: 'Eventos',
    summary: 'Participar, lista de espera, boas-vindas, aperto de mão, avaliação.',
    topics: [
      GuideTopic(
        'Participar de um evento',
        steps: [
          'Abra a página do evento (pela página do grupo, por Hoje, pela agenda ou pelo mapa).',
          'Leia a data, o local, as informações de valor, os requisitos e o equipamento necessário.',
          'Toque em "Participar". Se estiver lotado, o botão diz "Entrar na lista de espera".',
        ],
        notes: [
          'Todos veem os eventos, mas só membros do grupo podem participar.',
          'Se você está na lista de espera, sua vez chega quando alguém desiste e você recebe uma notificação.',
          'Em eventos com aprovação, o botão diz "Enviar pedido"; você participa quando o organizador aprova.',
          'Para desistir, toque em "Desistir"; sua vaga vai para a primeira pessoa da lista de espera.',
          'As inscrições fecham quando o evento começa.',
        ],
      ),
      GuideTopic(
        'Valor de participação',
        intro: 'O valor aparece só como informação. O GWAY não recebe pagamentos; você paga ao organizador do jeito que ele indicar (por exemplo, em dinheiro no local).',
      ),
      GuideTopic(
        'Adicionar à agenda e rotas',
        notes: [
          '"Adicionar à agenda" coloca o evento no app de agenda do seu celular.',
          'Se houver um ponto de encontro marcado, "Rotas", embaixo do mapinha, abre o app de mapas do seu aparelho.',
        ],
      ),
      GuideTopic(
        'Dois eventos no mesmo horário',
        intro: 'Se você tem outro evento no horário de um de que vai participar, o app pergunta se quer desistir do outro e liberar sua vaga. A escolha é sua; nada é cancelado automaticamente.',
      ),
      GuideTopic(
        'A pergunta "Você vem?"',
        intro: 'Menos de 24 horas antes do início, você recebe um lembrete e o card "Você vem?" aparece na página do evento.',
        notes: [
          '"Sim, eu vou": o organizador vê que você vai.',
          '"Não posso ir": você desiste; sua vaga vai para a primeira pessoa da lista de espera.',
          'Se não responder, você não é tirado da lista.',
        ],
      ),
      GuideTopic(
        'Boas-vindas: se é sua primeira vez',
        intro: 'Se é sua primeira vez num evento de um grupo, um membro voluntário do grupo pode receber você.',
        steps: [
          'Inscreva-se no evento.',
          'Na seção de boas-vindas da página, toque em "Quero ser recebido"; se quiser, escreva uma nota para ser reconhecido (ex.: "Estou de jaqueta vermelha").',
          'Quando alguém aceitar seu pedido, você recebe o ponto de encontro (ex.: "Em frente ao café da entrada, 08:45") como notificação.',
          'Depois do evento, você pode agradecer a quem recebeu você.',
        ],
        notes: [
          'Para receber outras pessoas, inscreva-se no evento; os pedidos abertos aparecem na seção de boas-vindas. Você pode receber até 3 pessoas por evento.',
          'Selos de boas-vindas: Porta aberta (1), Anfitrião (5), Coração da comunidade (20).',
        ],
      ),
      GuideTopic(
        'Local surpresa',
        intro: 'Em alguns eventos o local é surpresa. A página mostra só uma pista (ex.: "Em Kadıköy, à beira-mar") e quando o local será revelado.',
        notes: [
          'No horário marcado, o local é revelado aos participantes por notificação.',
          'Quem está na lista de espera ou não vai não vê o local. Se você se inscrever depois e o horário já tiver passado, vê na hora.',
        ],
      ),
      GuideTopic(
        'Aperto de mão: guarde quem você conheceu',
        intro: 'Dois participantes do mesmo evento escaneiam o QR code um do outro para registrar que se conheceram.',
        steps: [
          'O card "Aperto de mão" aparece na página de 1 hora antes do início até 6 horas depois do fim.',
          'Mostre seu código ou escaneie o da outra pessoa com a câmera. Sem câmera, digite o código de 6 caracteres.',
        ],
        notes: [
          'O código muda a cada 3 minutos; uma foto dele não serve depois.',
          'Só você vê quem conheceu: Eu → Retrospectiva do ano → Pessoas que conheci. Seu perfil mostra só o número.',
          'O aperto de mão não dá direito a mandar mensagem.',
        ],
      ),
      GuideTopic(
        'Depois do evento',
        notes: [
          'Quando acabar, chega um pedido de avaliação; dê de 1 a 5 estrelas. A nota do grupo é a média dessas avaliações.',
          'Adicione sua lembrança compartilhando uma publicação vinculada ao evento; lembranças contam para selos e metas.',
          'Se você foi, aparece o card "Eu também estive lá"; dá para compartilhar como imagem num story do Instagram ou no WhatsApp. O card não mostra nome nem rosto de outros participantes.',
          'Os eventos passados do grupo aparecem na página dele.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'event-admin',
    title: 'Organizar eventos e enquetes',
    summary: 'Para donos e administradores: criar, repetir, aprovar, cancelar, enquetes.',
    topics: [
      GuideTopic(
        'Criar um evento',
        steps: [
          'Toque em "Criar evento" na página do grupo.',
          'Informe capa, título, descrição, horário de início e, se quiser, de término. O início deve ser em pelo menos 15 minutos e no máximo 1 ano.',
          'Escreva o local; se quiser, marque o ponto de encontro com um alfinete no mapa ou adicione um link on-line.',
          'Adicione a capacidade (em branco = ilimitada), o valor, os requisitos e a lista de equipamentos.',
          'Se precisar, ative "Participação com aprovação" e salve.',
        ],
        notes: [
          'O formulário mostra quantos eventos ainda restam neste mês. Eventos cancelados contam para o limite mensal do seu plano.',
          'O formulário também mostra quantos eventos outros grupos da mesma categoria têm naquele dia na sua província; você pode mudar a data.',
        ],
      ),
      GuideTopic(
        'Evento recorrente',
        intro: 'Ao criar, escolha "Toda semana" ou "A cada duas semanas" em "Repetir" para abrir uma série (com data final opcional, no máximo 1 ano).',
        notes: [
          'Uma série sempre mantém abertas as próximas 4 semanas. Cada data tem seus próprios participantes e lista de espera.',
          'Se você editar a última data, as próximas que abrirem seguem esse modelo.',
          'Com "Parar repetição" no menu do evento, você encerra a série; as datas já abertas ficam, e você pode cancelá-las uma a uma.',
          'Se o limite mensal for atingido, a data não abre e você recebe uma notificação; ela abre quando houver espaço.',
        ],
      ),
      GuideTopic(
        'Configurar um local surpresa',
        steps: [
          'Ative "Local surpresa" no formulário.',
          'Escreva uma pista no campo "Local"; informe à parte o local real e o ponto de encontro.',
          'Escolha quando revelar: 1, 3, 6, 12 ou 24 horas antes do início.',
        ],
        notes: ['Se você desativar a surpresa, o local oculto é apagado e "Local" vira o local normal.'],
      ),
      GuideTopic(
        'Gerenciar participantes',
        notes: [
          'Com participação com aprovação, você aprova ou recusa os pedidos pendentes.',
          'Na lista de participantes você vê quem confirmou "Você vem?".',
          'Depois do evento, você marca quem faltou como "não compareceu"; essas pessoas não contam como presença.',
          'Edição: título, descrição, horário, local, capacidade, valor e capa podem mudar. Se o horário ou o local mudar, os participantes são avisados. A capacidade não pode ficar abaixo do número de inscritos.',
          'Cancelamento: você cancela informando o motivo; participantes e quem está na espera são avisados. Eventos passados não podem ser editados.',
        ],
      ),
      GuideTopic(
        'Criar enquete e votar',
        steps: [
          'Toque em "Criar enquete" na página do grupo (dono e administradores).',
          'Escreva a pergunta e de 2 a 10 opções.',
          'Se quiser, permita várias escolhas, deixe a enquete anônima, defina um término ou vincule-a a um evento.',
        ],
        notes: [
          'Só os membros do grupo veem as enquetes e os resultados.',
          'Numa enquete anônima ninguém vê quem votou em quê, nem quem a criou.',
          'Quando a enquete fecha, não dá mais para votar e os resultados ficam. Quem tem permissão pode fechá-la antes ou excluí-la.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'calendar',
    title: 'Agenda, Hoje à noite e descobertas',
    summary: 'Agenda, Livre hoje à noite, mesinha, mapa, liga, retrospectiva do ano.',
    topics: [
      GuideTopic(
        'Minha agenda',
        notes: [
          'A aba Agenda mostra os eventos de que você participa, os que aguardam aprovação e aqueles em que você está na lista de espera.',
          'Ative "Eventos dos meus grupos" para ver também todos os eventos dos seus grupos.',
          'Alterne entre as visualizações de dia, semana e mês.',
          'Eventos com horários sobrepostos aparecem marcados.',
          'Você também pode abrir a agenda de um grupo pela página dele.',
        ],
      ),
      GuideTopic(
        'Livre hoje à noite',
        steps: [
          'Toque em "+" → "Hoje à noite".',
          'Ative "Livre hoje à noite"; se quiser, escreva uma nota curta (ex.: "café, caminhada rápida").',
        ],
        notes: [
          'Seu status só aparece para quem tem pelo menos um grupo em comum com você.',
          'O status se desativa sozinho às 04:00; você também pode desativá-lo quando quiser.',
        ],
      ),
      GuideTopic(
        'Mesinha',
        intro: 'Monta um pequeno encontro com quem está livre hoje à noite.',
        steps: [
          'Na página "Hoje à noite", toque em "Montar uma mesinha".',
          'O app escolhe e convida 3–5 pessoas livres hoje à noite que têm grupos em comum com você.',
          'Você conversa com quem aceitar no chat da mesa.',
        ],
        notes: [
          'É preciso haver pelo menos 2 pessoas para convidar; senão, o card mostra quantas faltam.',
          'Você só pode entrar em uma mesa por noite.',
          'A mesa fecha às 12:00 do dia seguinte; o chat continua legível, mas não dá mais para escrever.',
        ],
      ),
      GuideTopic(
        'Descobrir com o mapa',
        steps: [
          'Na aba Grupos, toque em Mapa no canto superior direito.',
          'Mova o mapa; filtre por categoria, período (hoje, 7 dias) e distância do centro do mapa (5–50 km).',
          'Escolha a visualização de mapa ou de lista.',
        ],
        notes: [
          'O mapa mostra só eventos futuros e grupos ativos. Sua localização não é usada no mapa nem mostrada a ninguém.',
          'Se o mapa estiver temporariamente desligado, aparece em cima "O mapa não está disponível agora."',
        ],
      ),
      GuideTopic(
        'Liga dos grupos',
        intro: 'Grupos da mesma categoria e província ganham pontos todo mês fazendo bons eventos.',
        notes: [
          'Pontos: cada participante, cada evento com pelo menos 3 participantes, cada boas-vindas e cada avaliação de 4–5 estrelas.',
          'Em caso de empate, fica à frente o grupo com menos membros.',
          'Ao fechar o mês, os membros dos três primeiros grupos são avisados; as posições aparecem no card da liga na página do grupo.',
        ],
      ),
      GuideTopic(
        'Retrospectiva do ano e meu mapa de exploração',
        steps: [
          'Toque em Retrospectiva do ano no canto superior direito da aba Eu.',
          'Escolha "Retrospectiva do ano", "Meu mapa de exploração" ou "Pessoas que conheci".',
        ],
        notes: [
          'Retrospectiva do ano: número de eventos, total de horas, grupos, províncias e categorias. Dá para compartilhar como card de story.',
          'Meu mapa de exploração: as províncias dos seus eventos se preenchem no mapa da Turquia ("Explorei 7 / 81 províncias").',
          'Só você vê essas páginas; ninguém mais, a menos que você compartilhe.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'live',
    title: 'Áudio ao vivo',
    summary: 'Entrar, falar, reações, iniciar e conduzir uma transmissão.',
    topics: [
      GuideTopic(
        'Entrar numa transmissão',
        steps: [
          'Toque no card "Ao vivo agora" em Hoje, no card ao vivo da página do grupo ou na notificação.',
          'Ao conectar, você vê quem está no palco e quem está ouvindo.',
        ],
        notes: ['Só membros do grupo podem entrar. Quem for removido de uma transmissão não pode voltar a ela.'],
      ),
      GuideTopic(
        'Usar o app durante a transmissão',
        intro: 'O botão voltar ou a seta para baixo no canto superior esquerdo não tiram você da transmissão; a tela diminui e o áudio continua.',
        notes: [
          'No topo de cada página aparece a faixa "Você está ao vivo". Toque nela para voltar à transmissão.',
          'Se você estiver no palco, também pode silenciar e ativar o microfone pela faixa.',
          'Para sair, toque em "Sair" na tela da transmissão. Se entrar em outra transmissão, você sai da anterior.',
        ],
      ),
      GuideTopic(
        'Falar: levantar a mão e palco',
        steps: [
          'Se você está ouvindo, levante a mão com o botão ✋.',
          'Quando um anfitrião levar você ao palco, aparece seu botão de microfone; toque e fale.',
          'Para sair do palco por conta própria, toque em "Sair do palco".',
        ],
        notes: [
          'Se um anfitrião silenciou seu microfone, você não consegue ativá-lo; só um anfitrião pode liberar de novo.',
          'A borda da foto de quem está falando acende.',
        ],
      ),
      GuideTopic(
        'Reações e comentários',
        notes: [
          'Com o botão de reações você envia ❤️ 👏 😂 🔥 😮 🙌; elas cruzam a tela e não são guardadas.',
          'Com o botão de comentários você escreve. Os comentários ficam no registro da transmissão.',
          'Mantenha pressionado o seu comentário para apagá-lo; o de outras pessoas você pode denunciar.',
        ],
      ),
      GuideTopic(
        'Iniciar uma transmissão',
        intro: 'O dono e os administradores do grupo iniciam transmissões.',
        steps: [
          'Toque em "Iniciar transmissão" no card ao vivo da página do grupo.',
          'Escreva um título. Comece agora ou agende para depois.',
        ],
        notes: [
          'Um grupo pode ter ao mesmo tempo uma transmissão ao vivo e até cinco agendadas.',
          'A transmissão agendada aparece como "Próximos" na página do grupo; os membros tocam em "Lembrar". O anfitrião pode iniciá-la no máximo 15 minutos antes do horário marcado.',
          'Os minutos ao vivo dependem do plano do grupo; a tela de início mostra os minutos restantes. Quando acabam, a transmissão termina sozinha.',
          'Se o anfitrião sair e não voltar em 2 minutos, a transmissão termina sozinha.',
        ],
      ),
      GuideTopic(
        'Conduzir uma transmissão',
        intro: 'Os anfitriões são quem iniciou a transmissão e a equipe de moderação do grupo.',
        notes: [
          'Toque numa pessoa para levá-la ao palco, tirá-la do palco ou silenciar e ativar o microfone dela.',
          '"Remover da transmissão": a pessoa não pode voltar a esta transmissão.',
          'As mãos levantadas aparecem no topo, no card "levantou a mão".',
          '"Encerrar a transmissão para todos" fica no menu do canto superior direito.',
          'No palco cabem até 10 pessoas, contando o anfitrião. A regra de posição também vale aqui.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'messages',
    title: 'Mensagens e chamadas de voz',
    summary: 'Com quem conversar, chat do grupo, privacidade, chamadas de voz.',
    topics: [
      GuideTopic(
        'Com quem posso trocar mensagens?',
        notes: [
          'Mensagens diretas só ficam abertas com seus matches e parceiros de equipe. Seguir não dá direito a mandar mensagem.',
          'Para escrever a um match você precisa do plano Chat de Match; a um parceiro, do plano Parceiro de Equipe. Ler as mensagens recebidas é grátis.',
          'Os chats de grupo são grátis; todos os membros do grupo podem escrever.',
          'A tela Mensagens fica no botão Mensagens, no canto superior direito de Hoje. O número de não lidas aparece no botão.',
        ],
      ),
      GuideTopic(
        'Escrever e apagar mensagens',
        notes: [
          'Você pode enviar texto (até 2.000 caracteres) e uma foto.',
          'Enquanto envia, aparece "Enviando…". Se falhar, o texto volta para a caixa com o motivo.',
          'Num chat individual aparece "Visto" quando a outra pessoa lê.',
          'Você pode apagar sua mensagem para todos; no lugar dela aparece "Esta mensagem foi apagada" e o conteúdo é removido por completo.',
        ],
      ),
      GuideTopic(
        'Privacidade das mensagens',
        intro: 'A equipe da plataforma GWAY não pode ler suas mensagens privadas, ouvir suas chamadas de voz nem ver quem ligou para quem.',
        notes: [
          'Você pode denunciar uma mensagem. Denúncias de mensagens diretas vão para a equipe da plataforma; as do chat do grupo, para a moderação do grupo.',
          'O conselho disciplinar de um grupo não vê suas mensagens diretas.',
        ],
      ),
      GuideTopic(
        'Obter permissão para chamadas de voz',
        intro: 'Chamadas de voz individuais não são abertas a todos; a permissão é dada pelo dono ou por um administrador de um grupo de que você participa.',
        steps: [
          'Abra Configurações → "Chamadas de voz".',
          'Escolha um grupo de que participa, escreva se quiser uma nota curta e envie o pedido.',
          'Você vê seu status na mesma tela: em análise, ativado ou desativado (com o motivo). A decisão também chega por notificação.',
        ],
        notes: ['Se você sair do grupo que concedeu a permissão, ela é desativada.'],
      ),
      GuideTopic(
        'Fazer uma chamada de voz',
        steps: [
          'Abra o chat com seu match ou parceiro de equipe.',
          'Toque no botão "Chamada de voz" no canto superior direito.',
        ],
        notes: [
          'Os dois precisam ter permissão de chamada e o mesmo acesso de plano do chat. Se você não puder ligar, o motivo aparece no lugar do botão.',
          'Uma chamada não atendida em 30 segundos vira chamada perdida. Uma chamada dura no máximo 60 minutos.',
          'As chamadas nunca são gravadas e têm criptografia de ponta a ponta. Se o código de segurança de 12 dígitos for igual nas duas telas, ninguém está ouvindo.',
          'Só dá para estar em uma chamada por vez; quem está ocupado não pode ser chamado.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'matching',
    title: 'Matches e parceiros de equipe',
    summary: 'Amizade e namoro, planos pessoais, encontrar parceiros de equipe.',
    topics: [
      GuideTopic(
        'Como funciona o match?',
        intro: 'O match ajuda você a encontrar amizade ou namoro entre pessoas com quem tem grupos em comum. Ele usa um perfil de match separado; ninguém vê você ali até você ativá-lo.',
        steps: [
          'Toque em Matches no canto superior direito da aba Eu (no menu à esquerda em telas grandes).',
          'Crie seu perfil de match: Amizade, Namoro ou os dois; 2–6 fotos, data de nascimento, gênero, província, "sobre mim".',
          'No Namoro, escolha os gêneros que procura e uma faixa etária.',
          'Dê seu consentimento explícito.',
        ],
        notes: [
          'No seu baralho só aparecem pessoas que têm pelo menos um grupo em comum com você e ativaram o mesmo modo.',
          'No Namoro, as preferências dos dois precisam combinar.',
          'Como localização, só a sua província é usada.',
        ],
      ),
      GuideTopic(
        'Deslizar e dar match',
        notes: [
          'Deslize para a direita: curtir. Para a esquerda: passar. Para cima: Super Curtida. Os botões embaixo fazem o mesmo.',
          'Toque nas bordas do card para trocar de foto; o botão "i" abre o perfil completo.',
          'Se vocês se curtirem no mesmo modo, dá match e os dois são avisados.',
          'Suas curtidas e Super Curtidas grátis do dia aparecem na tela de matches.',
          'Quem você passou pode ser sugerido de novo depois de 90 dias.',
        ],
      ),
      GuideTopic(
        'Planos pessoais',
        intro: 'Cada recurso é vendido como um plano separado; você pega só o que quiser.',
        notes: [
          'Meus matches: ver com quem deu match. Sem ele, você sabe que houve match, mas a pessoa fica oculta.',
          'Chat de Match: escrever aos seus matches.',
          'Quem curtiu você: a lista de quem curtiu você.',
          'Curtidas ilimitadas: curtidas ilimitadas, desfazer e filtros.',
          'Super Curtida e Destaque: mais Super Curtidas e aparecer no topo dos baralhos uma vez por dia.',
          'Parceiro de Equipe: a seção de parceiros e escrever a eles.',
          'Tudo em um: tudo.',
          'Os planos são pré-pagos, não renovam sozinhos e são comprados pela web. Os preços aparecem em Matches → Planos.',
        ],
      ),
      GuideTopic(
        'Encerrar, pausar e apagar',
        notes: [
          'Se você encerrar um match, o chat fecha, o follow mútuo é removido e vocês não aparecem mais no baralho um do outro.',
          'Se vocês deram match nos dois modos, você pode escolher "Ficar só na amizade" ou "Ficar só no namoro".',
          'Se pausar seu perfil, o baralho e as curtidas param; os matches existentes ficam.',
          'Você pode apagar todos os seus dados de match (perfil, fotos, curtidas, matches) com um toque.',
          'Você pode denunciar perfis e fotos de match.',
        ],
      ),
      GuideTopic(
        'Encontrar parceiros de equipe',
        intro: 'Encontre gente para treinar, fazer trilha ou subir ao palco com você.',
        steps: [
          'Em Configurações → "Preferências de parceiros de equipe", ative "Procuro uma equipe".',
          'Escolha atividades, nível, objetivos, frequência, horários disponíveis e, se quiser, sua província.',
          'Na aba Eu, o botão "Encontrar parceiros de equipe" mostra sugestões. Cada uma diz o porquê (atividade em comum, grupo em comum, mesma província…).',
          'Envie um pedido (com uma mensagem de até 200 caracteres). Quando a outra pessoa aceitar, vocês viram parceiros de equipe.',
        ],
        notes: [
          'Sua província é usada só nas sugestões e não aparece no seu perfil.',
          'Você pode enviar no máximo 20 pedidos por dia e um por dia para a mesma pessoa.',
          'A seção de parceiros exige o plano Parceiro de Equipe.',
          'Qualquer um dos dois pode encerrar a parceria quando quiser.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'notifications',
    title: 'Notificações',
    summary: 'Tipos de notificação, preferências e notificações do celular.',
    topics: [
      GuideTopic(
        'A tela Notificações',
        notes: [
          'Abre pelo sino no canto superior direito de Hoje; o número de não lidas aparece no botão.',
          'As notificações são agrupadas em Hoje / Esta semana / Antes; pedidos para seguir pendentes ficam no topo.',
          'Toque numa notificação para abrir a página relacionada.',
        ],
      ),
      GuideTopic(
        'Preferências de notificação',
        steps: ['Abra Configurações → "Preferências de notificação".', 'Desative as que você não quiser.'],
        notes: [
          'Dá para desativar: lembretes de eventos, mudanças e cancelamentos, pedidos de avaliação, avisos ao vivo, mensagens pessoais, mensagens de grupo e avisos de match.',
          'Notificações que afetam você diretamente, como aprovação, sua vez na lista de espera ou sanções, não podem ser desativadas.',
        ],
      ),
      GuideTopic(
        'As notificações do celular não chegam',
        steps: [
          'O app pede permissão na primeira vez que abre; se você não deu, ative em Configurações do celular → Apps → GWAY → Notificações.',
          'No Android, confira se os canais "Mensagens", "Chamadas de voz" e "Notificações" estão ativados.',
          'Confira as preferências de notificação no app.',
        ],
        notes: ['Se o celular estiver no silencioso, as notificações não tocam.'],
      ),
    ],
  ),
  GuideChapter(
    id: 'safety',
    title: 'Segurança, denúncias e sanções',
    summary: 'Denunciar, sanções do grupo, recurso, verificação em duas etapas.',
    topics: [
      GuideTopic(
        'Denunciar',
        steps: [
          'Abra o menu da publicação, do comentário, do evento, do comentário ao vivo, da mensagem ou do perfil.',
          'Toque em "Denunciar", escolha um motivo e, se quiser, escreva uma breve descrição.',
        ],
        notes: [
          'A pessoa denunciada não vê a denúncia nem você. Os administradores do grupo também não veem quem denunciou.',
          'Denúncias ligadas a um grupo vão para a moderação dele; as demais, para a equipe da plataforma.',
          'Você não pode denunciar a si mesmo nem o próprio conteúdo; o mesmo conteúdo você denuncia uma vez enquanto a denúncia estiver aberta.',
        ],
      ),
      GuideTopic(
        'Sanções do grupo',
        notes: [
          'Advertência: fica registrada e você recebe uma notificação.',
          'Silenciamento (1–90 dias): você não pode publicar nem comentar no grupo nem escrever no chat; nas transmissões só pode ouvir.',
          'Remoção: você é removido do grupo; depois pode entrar de novo.',
          'Banimento (temporário ou permanente): enquanto durar, você não pode entrar no grupo, enviar pedido nem receber convite.',
          'Suas sanções aparecem em Configurações → "Minhas sanções de grupo".',
        ],
      ),
      GuideTopic(
        'Recorrer de uma sanção',
        steps: [
          'Abra Configurações → "Minhas sanções de grupo".',
          'Toque em "Recorrer" ao lado da sanção e escreva seus motivos (10–1000 caracteres).',
        ],
        notes: [
          'Você pode recorrer de cada sanção uma vez em até 7 dias. Silenciamento de emergência não admite recurso.',
          'Quem decide o recurso é o dono do grupo; se ele for parte do caso, a equipe da plataforma decide.',
          'Enquanto a decisão não sai, a sanção continua. A decisão chega por notificação.',
        ],
      ),
      GuideTopic(
        'Suspensão e banimento da conta',
        notes: [
          'A equipe da plataforma pode suspender ou encerrar uma conta que viole as regras. Nesse caso, o app mostra o motivo e a data de término.',
          'Durante a suspensão, seu perfil aparece, mas seu conteúdo fica oculto; uma conta encerrada definitivamente não aparece em lugar nenhum.',
          'Se uma decisão do grupo marcar atividade ilegal (como violência, ameaça ou fraude), a conta fica suspensa até a análise da plataforma.',
          'Se achar que houve um engano, escreva para a equipe de suporte.',
        ],
      ),
      GuideTopic(
        'Verificação em duas etapas',
        steps: [
          'Abra Configurações → "Verificação em duas etapas".',
          'Adicione um app autenticador (ex.: Google Authenticator) ou, na web, configure o login com digital e reconhecimento facial.',
        ],
        notes: ['O método configurado vem primeiro nos próximos logins; o SMS sempre fica como reserva.'],
      ),
    ],
  ),
  GuideChapter(
    id: 'moderation',
    title: 'Moderação do grupo',
    summary: 'Para responsáveis: analisar denúncias, casos disciplinares, votação, banimento.',
    topics: [
      GuideTopic(
        'A tela de moderação',
        intro: 'O card de moderação na página do grupo mostra o número de tarefas pendentes. O dono, os administradores, os membros do conselho e os moderadores o veem.',
        notes: [
          'Denúncias: as denúncias do mesmo conteúdo ficam juntas numa linha. Rejeitar, Remover conteúdo ou Abrir caso.',
          'Casos: casos em votação, tempo restante e número de votos; vote.',
          'Sanções e recursos: aqui o dono decide os recursos.',
        ],
      ),
      GuideTopic(
        'Caso disciplinar e votação',
        steps: [
          'Numa denúncia ou no menu do membro na página de membros, escolha "Abrir caso disciplinar".',
          'Escolha a sanção proposta (advertência, silenciamento, remoção, banimento) e a duração, e escreva o motivo.',
          'Em emergência, marque "Silenciar agora (24 horas)"; a pessoa fica silenciada até a decisão.',
        ],
        notes: [
          'Os membros do conselho disciplinar votam em até 72 horas. Num grupo sem conselho, o dono decide sozinho.',
          'O limite de decisão padrão é a maioria simples; o dono pode escolher dois terços ou unanimidade nas configurações da tela de moderação.',
          'Ao atingir o limite, o caso é aprovado na hora e a sanção é aplicada. Se ninguém votar, o caso é rejeitado.',
          'Só pode haver um caso aberto por vez sobre a mesma pessoa. A regra de posição vale.',
        ],
      ),
      GuideTopic(
        'Banimento sem votação',
        intro: 'O dono e os administradores podem banir alguém sem esperar o conselho.',
        steps: [
          'Em "Abrir caso disciplinar", escolha banimento como sanção.',
          'Marque "Aplicar já, sem votação".',
          'Informe a duração (1–365 dias ou permanente) e o motivo.',
        ],
        notes: [
          'Um administrador não pode banir outro administrador nem o dono.',
          'Se for crime, marque como "atividade ilegal" e escolha a categoria; a conta da pessoa fica suspensa até a análise da plataforma.',
          'A pessoa pode recorrer em até 7 dias.',
        ],
      ),
      GuideTopic(
        'Ação de emergência na transmissão',
        intro: 'Num caso como assédio durante uma transmissão, um anfitrião silencia na hora o microfone da pessoa ou a remove da transmissão. Depois, se preciso, abre-se um caso disciplinar.',
      ),
    ],
  ),
  GuideChapter(
    id: 'account',
    title: 'Conta, privacidade e suporte',
    summary: 'Documentos legais, seus dados, excluir a conta, sair, suporte.',
    topics: [
      GuideTopic(
        'Como meus dados são protegidos?',
        notes: [
          'Sua localização é usada só para a segurança da conta; não aparece no mapa nem no perfil.',
          'Sua data de nascimento não é mostrada a ninguém.',
          'A equipe da plataforma não pode ler suas mensagens privadas.',
          'Os documentos que você aceitou ficam em Configurações → "Documentos legais".',
        ],
      ),
      GuideTopic(
        'Excluir minha conta',
        steps: [
          'Abra Configurações → "Excluir conta".',
          'Confirme a exclusão.',
        ],
        notes: [
          'Seu perfil fica oculto para os outros na hora. Em até 30 dias você pode entrar e escolher "desfazer exclusão".',
          'Depois de 30 dias, sua conta, publicações, mensagens e arquivos são apagados para sempre.',
          'Se você é dono de um grupo, antes precisa transferir a propriedade ou excluir o grupo.',
        ],
      ),
      GuideTopic(
        'Sair da conta',
        intro: 'Toque em "Sair" no fim das Configurações. O celular em que você sair deixa de receber notificações.',
      ),
      GuideTopic(
        'Escrever para a equipe de suporte',
        steps: [
          'Abra Configurações → "Suporte e feedback".',
          'Toque em "Nova mensagem" e escolha o tipo: Problema (algo não funciona), Solicitação (uma ação para sua conta, grupo ou pagamento), Sugestão (novo recurso ou ideia).',
          'Escreva o assunto e a descrição; você pode anexar até 3 imagens.',
        ],
        notes: [
          'Quando chega uma resposta, a linha nas Configurações mostra "nova resposta". Status da mensagem: Novo, Em análise, Resolvido, Fechado.',
          'Se você administra um grupo, também pode abrir uma mensagem para ele pela página do grupo.',
        ],
      ),
    ],
  ),
];
