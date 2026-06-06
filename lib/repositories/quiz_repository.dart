import 'dart:math';
import '../models/word_item.dart';
import '../models/quiz_models.dart';

// ── REPOSITORY: QuizRepository ─────────────────────────────────
// Menghasilkan soal kuis dari Word Treasury dan menyimpan hasil.
class QuizRepository {
  final _random = Random();

  // ── Generate satu sesi soal dari list kata ──
  // Menghasilkan campuran soal pilihan ganda (EN→ID dan ID→EN)
  List<QuizQuestion> generateQuestions(
    List<WordItem> words, {
    int count = 10,
  }) {
    if (words.length < 2) {
      throw Exception(
        'Minimal 2 kata di Treasury untuk memulai Treasure Check!',
      );
    }

    // Acak kata dan ambil sejumlah 'count' (atau semua jika kurang)
    final pool = List<WordItem>.from(words)..shuffle(_random);
    final selected = pool.take(min(count, pool.length)).toList();

    return selected.map((word) {
      // Tentukan arah secara acak
      final isEnToId = _random.nextBool();
      return _buildMultipleChoice(word, words, isEnToId);
    }).toList();
  }

  // ── Buat soal pilihan ganda ──
  QuizQuestion _buildMultipleChoice(
    WordItem   target,
    List<WordItem> allWords,
    bool       isEnToId,
  ) {
    final questionText  = isEnToId ? target.word        : target.translation;
    final correctAnswer = isEnToId ? target.translation : target.word;

    // Ambil 3 pengecoh dari kata-kata lain
    final distractors = allWords
        .where((w) => w.id != target.id)
        .toList()
      ..shuffle(_random);

    final wrongOptions = distractors
        .take(3)
        .map((w) => isEnToId ? w.translation : w.word)
        .toList();

    // Gabungkan dan acak semua opsi
    final options = [correctAnswer, ...wrongOptions]..shuffle(_random);

    return QuizQuestion(
      wordId:        target.id,
      questionText:  questionText,
      correctAnswer: correctAnswer,
      options:       options,
      direction:     isEnToId ? QuizDirection.enToId : QuizDirection.idToEn,
      type:          QuizType.multipleChoice,
    );
  }

  // ── Evaluasi jawaban dan buat QuizSession ──
  QuizSession evaluateSession(
    List<QuizQuestion> questions,
    Map<String, String> userAnswers, // {wordId: jawaban}
  ) {
    final answers = questions.map((q) {
      final userAns     = userAnswers[q.wordId] ?? '';
      final isCorrect   = userAns.toLowerCase().trim() ==
                          q.correctAnswer.toLowerCase().trim();
      return QuizAnswer(
        wordId:        q.wordId,
        userAnswer:    userAns,
        correctAnswer: q.correctAnswer,
        isCorrect:     isCorrect,
      );
    }).toList();

    return QuizSession(
      id:             DateTime.now().millisecondsSinceEpoch.toString(),
      date:           DateTime.now(),
      answers:        answers,
      totalQuestions: questions.length,
      correctCount:   answers.where((a) => a.isCorrect).length,
    );
  }
}
