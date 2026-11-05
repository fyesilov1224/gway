"""Server sentences: Zihin Düellosu (docs/ARCHITECTURE.md §3j, §11 Sunucu). Admin-only sentences stay Turkish."""


def r(tr, en, de, fr, nl, es, pt, it, ru, ar, az, uk):
    return (tr, en, de, fr, nl, es, pt, it, ru, ar, az, uk)


ROWS = [
    r('Soru sayısı 5, 10, 20 ya da 50 olmalı.', 'The number of questions must be 5, 10, 20 or 50.', 'Die Fragenzahl muss 5, 10, 20 oder 50 sein.',
      'Le nombre de questions doit être 5, 10, 20 ou 50.', 'Het aantal vragen moet 5, 10, 20 of 50 zijn.', 'El número de preguntas debe ser 5, 10, 20 o 50.',
      'O número de perguntas deve ser 5, 10, 20 ou 50.', 'Il numero di domande deve essere 5, 10, 20 o 50.', 'Число вопросов: 5, 10, 20 или 50.',
      'يجب أن يكون عدد الأسئلة 5 أو 10 أو 20 أو 50.', 'Sual sayı 5, 10, 20 və ya 50 olmalıdır.', 'Кількість запитань: 5, 10, 20 або 50.'),
    r('Oyun oynaman şu anda kapalı.', "You can't play games right now.", 'Du kannst gerade keine Spiele spielen.', 'Tu ne peux pas jouer pour le moment.',
      'Je kunt nu geen spellen spelen.', 'Ahora no puedes jugar.', 'Você não pode jogar agora.', 'Al momento non puoi giocare.',
      'Сейчас вы не можете играть.', 'لا يمكنك اللعب الآن.', 'Hazırda oyun oynaya bilməzsən.', 'Зараз ви не можете грати.'),
    r('Önce süren düellonu bitir.', 'Finish your current duel first.', 'Beende zuerst dein laufendes Duell.', "Termine d'abord ton duel en cours.",
      'Maak eerst je lopende duel af.', 'Termina primero tu duelo en curso.', 'Termine primeiro seu duelo em andamento.', 'Prima finisci il duello in corso.',
      'Сначала завершите текущую дуэль.', 'أنهِ مبارزتك الحالية أولًا.', 'Əvvəlcə davam edən duelini bitir.', 'Спершу завершіть поточну дуель.'),
    r('Düello bulunamadı.', 'Duel not found.', 'Duell nicht gefunden.', 'Duel introuvable.', 'Duel niet gevonden.', 'Duelo no encontrado.',
      'Duelo não encontrado.', 'Duello non trovato.', 'Дуэль не найдена.', 'لم يتم العثور على المبارزة.', 'Duel tapılmadı.', 'Дуель не знайдено.'),
    r('Bu düelloda oyuncu değilsin.', "You're not a player in this duel.", 'Du spielst in diesem Duell nicht mit.', "Tu n'es pas joueur dans ce duel.",
      'Je speelt niet mee in dit duel.', 'No juegas en este duelo.', 'Você não joga neste duelo.', 'Non sei un giocatore di questo duello.',
      'Вы не участвуете в этой дуэли.', 'لست لاعبًا في هذه المبارزة.', 'Bu dueldə oyunçu deyilsən.', 'Ви не берете участі в цій дуелі.'),
    r('Düello bitti.', 'The duel is over.', 'Das Duell ist vorbei.', 'Le duel est terminé.', 'Het duel is afgelopen.', 'El duelo ha terminado.',
      'O duelo terminou.', 'Il duello è finito.', 'Дуэль окончена.', 'انتهت المبارزة.', 'Duel bitdi.', 'Дуель завершено.'),
    r('Düello güncellendi, soru yenileniyor.', 'The duel was updated; refreshing the question.', 'Das Duell wurde aktualisiert, die Frage wird neu geladen.',
      'Le duel a été mis à jour, actualisation de la question.', 'Het duel is bijgewerkt, de vraag wordt vernieuwd.',
      'El duelo se actualizó; actualizando la pregunta.', 'O duelo foi atualizado; atualizando a pergunta.',
      'Il duello è stato aggiornato, aggiorno la domanda.', 'Дуэль обновилась, вопрос обновляется.', 'تم تحديث المبارزة، يجري تحديث السؤال.',
      'Duel yeniləndi, sual yenilənir.', 'Дуель оновлено, запитання оновлюється.'),
    r("seni Zihin Düellosu'na davet etti.", 'invited you to a Mind Duel.', 'hat dich zu einem Gedankenduell eingeladen.', "t'a défié en Duel mental.",
      'heeft je uitgedaagd voor een Breinduel.', 'te retó a un Duelo mental.', 'desafiou você para um Duelo mental.', 'ti ha sfidato a un Duello mentale.',
      'вызывает вас на «Дуэль разума».', 'تحدّاك في مبارزة العقول.', 'səni Zehin Duelinə dəvət etdi.', 'викликає вас на «Дуель розуму».'),
]
