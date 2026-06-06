import 'package:flutter/foundation.dart';
import '../models/expedition_models.dart';
import '../models/word_item.dart';
import '../repositories/expedition_repository.dart';

// ── VIEWMODEL: ExpeditionViewModel ────────────────────────────
// Mengelola state untuk Word Expedition:
// - Daftar tema yang tersedia
// - Progres pengguna per level
// - State sesi flip card yang sedang berjalan
class ExpeditionViewModel extends ChangeNotifier {
  final ExpeditionRepository _repo;

  ExpeditionViewModel(this._repo);

  // ── State: daftar tema ──
  List<ExpeditionTheme>            _themes   = [];
  Map<String, ExpeditionProgress>  _progress = {};
  bool                             _isLoading = false;
  String?                          _error;

  // ── State: sesi flip card aktif ──
  ExpeditionTheme?   _activeTheme;
  int                _activeLevel = 1;
  int                _cardIndex   = 0;
  bool               _isFlipped   = false;
  List<String>       _learnedInSession = [];
  List<String>       _unknownInSession = [];

  // ── Getters: tema ──
  List<ExpeditionTheme>           get themes    => _themes;
  Map<String, ExpeditionProgress> get progress  => _progress;
  bool                            get isLoading => _isLoading;
  String?                         get error     => _error;

  // ── Getters: sesi flip card ──
  ExpeditionTheme? get activeTheme  => _activeTheme;
  int              get activeLevel  => _activeLevel;
  bool             get isFlipped    => _isFlipped;
  int              get learnedCount => _learnedInSession.length;
  int              get unknownCount => _unknownInSession.length;

  // Kartu yang sedang ditampilkan
  ExpeditionWord? get currentCard {
    if (_activeTheme == null) return null;
    final words = _currentWords;
    if (_cardIndex >= words.length) return null;
    return words[_cardIndex];
  }

  // Semua kata di level aktif
  List<ExpeditionWord> get _currentWords {
    if (_activeTheme == null) return [];
    final lvl = _activeTheme!.levels
        .firstWhere((l) => l.level == _activeLevel,
                    orElse: () => ExpeditionLevel(level: 1, words: []));
    return lvl.words;
  }

  int get totalCards => _currentWords.length;
  int get currentIndex => _cardIndex;

  bool get isSessionDone => _cardIndex >= totalCards;

  // ── Apakah level tertentu sudah selesai ──
  bool isLevelCompleted(String themeId, int level) {
    return _progress['${themeId}_$level']?.isCompleted ?? false;
  }

  // ── Apakah level tertentu terkunci ──
  bool isLevelLocked(String themeId, int level) {
    if (level == 1) return false; // level 1 selalu terbuka
    return !isLevelCompleted(themeId, level - 1);
  }

  // Progres persentase sebuah level
  double levelProgress(String themeId, int level, int totalWords) {
    final prog = _progress['${themeId}_$level'];
    if (prog == null || totalWords == 0) return 0;
    return prog.completedWords.length / totalWords;
  }

  // ── LOAD: muat semua tema dan progres ──
  Future<void> loadThemes() async {
    _isLoading = true;
    notifyListeners();
    try {
      _themes   = await _repo.loadThemes();
      _progress = await _repo.getAllProgress();
      _error    = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  // ── START: mulai sesi flip card ──
  void startSession(ExpeditionTheme theme, int level) {
    _activeTheme        = theme;
    _activeLevel        = level;
    _cardIndex          = 0;
    _isFlipped          = false;
    _learnedInSession   = [];
    _unknownInSession   = [];
    notifyListeners();
  }

  // ── FLIP: balik kartu ──
  void flipCard() {
    _isFlipped = !_isFlipped;
    notifyListeners();
  }

  // ── MARK: tandai kata sebagai Hafal ──
  Future<WordItem?> markAsLearned() async {
    final card = currentCard;
    if (card == null || _activeTheme == null) return null;

    _learnedInSession.add(card.word);

    // Simpan progres ke repository
    await _repo.markWordLearned(
      themeId:    _activeTheme!.id,
      level:      _activeLevel,
      word:       card.word,
      totalWords: totalCards,
    );

    // Refresh progress map
    _progress = await _repo.getAllProgress();

    // Buat WordItem untuk ditambah ke Treasury (dikembalikan ke View)
    final wordItem = WordItem(
      id:          DateTime.now().millisecondsSinceEpoch.toString(),
      word:        card.word,
      translation: card.translation,
      wordType:    _parseWordType(card.wordType),
      definition:  '',
      example:     card.example,
      phonetic:    card.phonetic,
      addedAt:     DateTime.now(),
    );

    _nextCard();
    return wordItem; // View akan menyimpan ini ke TreasuryViewModel
  }

  // ── MARK: tandai sebagai Belum Hafal ──
  void markAsUnknown() {
    final card = currentCard;
    if (card == null) return;
    _unknownInSession.add(card.word);
    _nextCard();
  }

  // ── Private: maju ke kartu berikutnya ──
  void _nextCard() {
    _cardIndex++;
    _isFlipped = false;
    notifyListeners();
  }

  WordType _parseWordType(String type) {
    switch (type.toLowerCase()) {
      case 'noun':      return WordType.noun;
      case 'verb':      return WordType.verb;
      case 'adjective': return WordType.adjective;
      case 'adverb':    return WordType.adverb;
      default:          return WordType.other;
    }
  }
}
