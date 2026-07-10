import '../models/quiz_models.dart';
import '../models/word_item.dart';
import 'word_repository.dart';

class QuizRepository {
  final WordRepository _wordRepo = WordRepository();

  // ── Generate soal dari Treasury ──
  Future<List<QuizQuestion>> generateQuestions() async {
    final words = await _wordRepo.getAll();
    if (words.length < 4) return [];

    // Buat soal multiple choice: terjemahan Inggris -> Indonesia
    return words.map((word) {
      return QuizQuestion(
        wordId: word.id,
        questionText: 'Apa arti dari "${word.word}"?',
        correctAnswer: word.translation,
        options: _generateOptions(words, word.translation),
        direction: QuizDirection.enToId,
        type: QuizType.multipleChoice,
        exampleSentence: word.exampleID, // clue contoh kalimat
      );
    }).toList()
      ..shuffle();
  }

  // ── Evaluasi sesi kuis ──
  QuizSession evaluateSession(List<QuizAnswer> answers) {
    final total = answers.length;
    final correct = answers.where((a) => a.isCorrect).length;
    return QuizSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      answers: answers,
      totalQuestions: total,
      correctCount: correct,
    );
  }

  // ── Helper: opsi acak ──
  List<String> _generateOptions(List<WordItem> allWords, String correct) {
    final others = allWords
        .map((w) => w.translation)
        .where((t) => t != correct)
        .toList()
      ..shuffle();
    final options = [correct];
    for (var i = 0; i < 3 && i < others.length; i++) {
      options.add(others[i]);
    }
    return options..shuffle();
  }
}
