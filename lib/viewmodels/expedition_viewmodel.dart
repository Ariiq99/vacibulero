import 'package:flutter/foundation.dart';
import '../models/expedition_models.dart';
import '../repositories/expedition_repository.dart';

class ExpeditionViewModel extends ChangeNotifier {
  final ExpeditionRepository _repo;

  ExpeditionViewModel(this._repo) {
    loadContent();
  }

  // ── State ──
  List<ExpeditionTheme> _themes = [];
  Map<String, ExpeditionProgress> _progressMap = {};
  bool _isLoading = false;
  String? _error;

  // State navigasi di dalam sesi belajar
  ExpeditionTheme? _activeTheme;
  String _activeDifficulty = 'Beginner';
  int _activeLevel = 1;
  int _cardIndex = 0;
  bool _isFlipped = false;
  final Set<String> _learnedInSession = {};
  final Set<String> _unknownInSession = {};

  // ── Getters ──
  List<ExpeditionTheme> get themes => _themes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get activeLevel => _activeLevel;
  bool get isFlipped => _isFlipped;
  int get learnedCount => _learnedInSession.length;
  int get unknownCount => _unknownInSession.length;

  // Mengganti tipe data lama ke WordContent sesuai model baru
  WordContent? get currentCard {
    if (_activeTheme == null) return null;
    final words = _currentWords;
    if (_cardIndex >= words.length) return null;
    return words[_cardIndex];
  }

  // Helper dinamis untuk menyaring daftar kata berdasarkan Kategori & Kesulitan aktif
  List<WordContent> get _currentWords {
    if (_activeTheme == null) return [];

    // Cari tingkat kesulitan yang cocok
    final diffData = _activeTheme!.difficulties.firstWhere(
      (d) => d.difficulty.toLowerCase() == _activeDifficulty.toLowerCase(),
      orElse: () =>
          ExpeditionDifficulty(difficulty: _activeDifficulty, levels: []),
    );

    // Cari level yang cocok
    final lvl = diffData.levels.firstWhere(
      (l) => l.level == _activeLevel,
      orElse: () => ExpeditionLevel(level: 1, words: []),
    );

    return lvl.words;
  }

  int get totalCards => _currentWords.length;
  int get currentIndex => _cardIndex;

  // ── Pemuatan Data Utama ──
  Future<void> loadContent() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _themes = await _repo.loadThemes();
      _progressMap = await _repo.getAllProgress();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Logika Status Progress Pengguna ──
  bool isLevelLocked(String themeId, int level) {
    if (level == 1) return false;
    final prevProgress = _progressMap['${themeId}_${level - 1}'];
    return prevProgress == null || !prevProgress.isCompleted;
  }

  bool isLevelCompleted(String themeId, int level) {
    return _progressMap['${themeId}_$level']?.isCompleted ?? false;
  }

  double levelProgress(String themeId, int level, int totalWords) {
    if (totalWords == 0) return 0.0;
    final prog = _progressMap['${themeId}_$level'];
    if (prog == null) return 0.0;
    return prog.completedWords.length / totalWords;
  }

  // ── Logika Manajemen Sesi Belajar (FlipCard) ──
  void startSession(ExpeditionTheme theme, String difficulty, int level) {
    _activeTheme = theme;
    _activeDifficulty = difficulty;
    _activeLevel = level;
    _cardIndex = 0;
    _isFlipped = false;
    _learnedInSession.clear;
    _unknownInSession.clear;
    notifyListeners();
  }

  void flipCard() {
    _isFlipped = !_isFlipped;
    notifyListeners();
  }

  Future<void> markAsLearned() async {
    final current = currentCard;
    if (current == null || _activeTheme == null) return;

    _learnedInSession.add(current.word);
    _unknownInSession.remove(current.word);

    final updatedProgress = await _repo.markWordLearned(
      themeId: _activeTheme!.id,
      level: _activeLevel,
      word: current.word,
      totalWords: totalCards,
    );

    _progressMap[updatedProgress.key] = updatedProgress;
    _nextCard();
  }

  void markAsUnknown() {
    final current = currentCard;
    if (current == null) return;

    _unknownInSession.add(current.word);
    _nextCard();
  }

  void _nextCard() {
    _cardIndex++;
    _isFlipped = false;
    notifyListeners();
  }
}
