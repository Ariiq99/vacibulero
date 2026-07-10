import 'package:flutter/material.dart';
import '../models/quiz_models.dart';
import '../repositories/quiz_repository.dart';

class QuizViewModel extends ChangeNotifier {
  final QuizRepository _repository;
  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  List<QuizAnswer> _answers = [];
  bool _isFinished = false;

  QuizViewModel(this._repository);

  // ── Getters ──
  List<QuizQuestion> get questions => _questions;
  int get currentIndex => _currentIndex;
  QuizQuestion? get currentQuestion =>
      _currentIndex < _questions.length ? _questions[_currentIndex] : null;
  List<QuizAnswer> get answers => _answers;
  bool get isFinished => _isFinished;
  int get totalQuestions => _questions.length;
  int get correctCount => _answers.where((a) => a.isCorrect).length;

  // ── Load soal dari repository (diambil dari Word Treasury) ──
  Future<void> loadQuestions() async {
    _questions = await _repository.generateQuestions(); // <── ini
    _currentIndex = 0;
    _answers = [];
    _isFinished = false;
    notifyListeners();
  }

  // ── Jawab soal ──
  void answerQuestion(String userAnswer) {
    if (currentQuestion == null || _isFinished) return;

    final question = currentQuestion!;
    final isCorrect = userAnswer.trim().toLowerCase() ==
        question.correctAnswer.trim().toLowerCase();

    _answers.add(
      QuizAnswer(
        wordId: question.wordId,
        userAnswer: userAnswer,
        correctAnswer: question.correctAnswer,
        isCorrect: isCorrect,
      ),
    );

    // Pindah ke soal berikutnya atau selesai
    if (_currentIndex + 1 < _questions.length) {
      _currentIndex++;
    } else {
      _isFinished = true;
    }
    notifyListeners();
  }

  // ── Reset kuis ──
  void reset() {
    _currentIndex = 0;
    _answers = [];
    _isFinished = false;
    notifyListeners();
  }
}
