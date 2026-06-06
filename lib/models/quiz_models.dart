// ── MODEL: QuizQuestion ────────────────────────────────────────
// Satu soal dalam sesi Treasure Check!

enum QuizDirection { enToId, idToEn }  // arah terjemahan soal
enum QuizType { multipleChoice, matching, typeAnswer }

class QuizQuestion {
  final String        wordId;
  final String        questionText;  // kata atau arti yang ditanyakan
  final String        correctAnswer; // jawaban yang benar
  final List<String>  options;       // untuk tipe multipleChoice
  final QuizDirection direction;
  final QuizType      type;

  const QuizQuestion({
    required this.wordId,
    required this.questionText,
    required this.correctAnswer,
    required this.options,
    required this.direction,
    required this.type,
  });
}

// ── MODEL: QuizAnswer ──────────────────────────────────────────
// Jawaban pengguna untuk satu soal.
class QuizAnswer {
  final String wordId;
  final String userAnswer;
  final String correctAnswer;
  final bool   isCorrect;

  const QuizAnswer({
    required this.wordId,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
  });
}

// ── MODEL: QuizSession ─────────────────────────────────────────
// Ringkasan satu sesi Treasure Check! yang sudah selesai.
class QuizSession {
  final String          id;
  final DateTime        date;
  final List<QuizAnswer> answers;
  final int             totalQuestions;
  final int             correctCount;

  const QuizSession({
    required this.id,
    required this.date,
    required this.answers,
    required this.totalQuestions,
    required this.correctCount,
  });

  // ── Hitung persentase skor ──
  double get scorePercent =>
      totalQuestions == 0 ? 0 : (correctCount / totalQuestions) * 100;

  // ── Daftar wordId yang salah ──
  List<String> get wrongWordIds =>
      answers.where((a) => !a.isCorrect).map((a) => a.wordId).toList();
}
