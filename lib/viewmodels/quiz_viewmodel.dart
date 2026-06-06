import 'package:flutter/foundation.dart';
import '../models/quiz_models.dart';
import '../models/word_item.dart';
import '../repositories/quiz_repository.dart';

enum QuizStatus { idle, inProgress, finished }

// ── VIEWMODEL: QuizViewModel ───────────────────────────────────
// Mengelola state dan logika untuk halaman Treasure Check!
class QuizViewModel extends ChangeNotifier {
  final QuizRepository _repo;

  QuizViewModel(this._repo);

  // ── State ──
  QuizStatus          _status    = QuizStatus.idle;
  List<QuizQuestion>  _questions = [];
  int                 _current   = 0;
  Map<String, String> _answers   = {}; // {wordId: jawaban}
  String?             _selected;       // opsi yang dipilih saat ini
  QuizSession?        _session;
  String?             _error;

  // ── Getters ──
  QuizStatus      get status      => _status;
  int             get currentIdx  => _current;
  int             get totalQ      => _questions.length;
  String?         get selected    => _selected;
  QuizSession?    get session     => _session;
  String?         get error       => _error;
  bool            get isFinished  => _status == QuizStatus.finished;

  QuizQuestion? get currentQuestion =>
      _current < _questions.length ? _questions[_current] : null;

  double get progress =>
      _questions.isEmpty ? 0 : (_current / _questions.length);

  // ── START: mulai sesi kuis dari daftar kata ──
  void startQuiz(List<WordItem> words) {
    try {
      _questions = _repo.generateQuestions(words, count: 10);
      _current   = 0;
      _answers   = {};
      _selected  = null;
      _session   = null;
      _error     = null;
      _status    = QuizStatus.inProgress;
    } catch (e) {
      _error  = e.toString();
      _status = QuizStatus.idle;
    }
    notifyListeners();
  }

  // ── SELECT: pilih jawaban ──
  void selectAnswer(String answer) {
    if (_selected != null) return; // sudah dijawab, tidak bisa ganti
    _selected = answer;
    final q = currentQuestion;
    if (q != null) _answers[q.wordId] = answer;
    notifyListeners();
  }

  // ── NEXT: ke soal berikutnya ──
  void nextQuestion() {
    if (_current < _questions.length - 1) {
      _current++;
      _selected = null;
      notifyListeners();
    } else {
      _finishQuiz();
    }
  }

  // ── Apakah jawaban yang dipilih benar ──
  bool? get isCurrentAnswerCorrect {
    if (_selected == null || currentQuestion == null) return null;
    return _selected == currentQuestion!.correctAnswer;
  }

  // ── Private: selesaikan sesi ──
  void _finishQuiz() {
    _session = _repo.evaluateSession(_questions, _answers);
    _status  = QuizStatus.finished;
    notifyListeners();
  }

  // ── RESET: kembali ke idle ──
  void reset() {
    _status    = QuizStatus.idle;
    _questions = [];
    _current   = 0;
    _answers   = {};
    _selected  = null;
    _session   = null;
    _error     = null;
    notifyListeners();
  }
}
