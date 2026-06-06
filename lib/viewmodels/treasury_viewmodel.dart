import 'package:flutter/foundation.dart';
import '../models/word_item.dart';
import '../repositories/word_repository.dart';

// ── VIEWMODEL: TreasuryViewModel ──────────────────────────────
// Mengelola state dan logika untuk halaman Word Treasury.
// Extends ChangeNotifier → memanggil notifyListeners() setiap
// kali state berubah agar View (Consumer) otomatis rebuild.
class TreasuryViewModel extends ChangeNotifier {
  final WordRepository _repo;

  TreasuryViewModel(this._repo);

  // ── State ──
  List<WordItem>        _words      = [];
  List<WordItem>        _filtered   = [];
  WordType?             _activeFilter;
  String                _searchQuery = '';
  bool                  _isLoading  = false;
  String?               _error;
  Map<WordType, int>    _stats      = {};

  // ── Getters (View membaca state lewat getters) ──
  List<WordItem>     get words        => _filtered;
  List<WordItem>     get allWords     => _words;
  WordType?          get activeFilter => _activeFilter;
  String             get searchQuery  => _searchQuery;
  bool               get isLoading    => _isLoading;
  String?            get error        => _error;
  int                get totalWords   => _words.length;
  Map<WordType, int> get stats        => _stats;

  bool get isEmpty => _words.isEmpty;

  // ── LOAD: muat semua kata saat init ──
  Future<void> loadWords() async {
    _setLoading(true);
    try {
      _words  = await _repo.getAll();
      _stats  = await _repo.getStatsByType();
      _applyFilter();
      _error  = null;
    } catch (e) {
      _error  = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // ── ADD: tambah kata baru ──
  Future<void> addWord(WordItem item) async {
    _setLoading(true);
    try {
      await _repo.add(item);
      _words  = await _repo.getAll();
      _stats  = await _repo.getStatsByType();
      _applyFilter();
      _error  = null;
    } catch (e) {
      _error  = e.toString();
      rethrow; // lempar ke View untuk ditampilkan
    } finally {
      _setLoading(false);
    }
  }

  // ── DELETE: hapus kata ──
  Future<void> deleteWord(String id) async {
    try {
      await _repo.delete(id);
      _words = await _repo.getAll();
      _stats = await _repo.getStatsByType();
      _applyFilter();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  // ── SEARCH: cari kata ──
  void search(String query) {
    _searchQuery  = query;
    _activeFilter = null; // reset filter saat search
    _applyFilter();
  }

  // ── FILTER: filter berdasarkan tipe kata ──
  void filterByType(WordType? type) {
    _activeFilter = type;
    _searchQuery  = '';
    _applyFilter();
  }

  // ── CLEAR FILTER ──
  void clearFilter() {
    _activeFilter = null;
    _searchQuery  = '';
    _applyFilter();
  }

  // ── CHECK: apakah kata sudah ada ──
  Future<bool> wordExists(String word) => _repo.exists(word);

  // ── Private helpers ──
  void _applyFilter() {
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      _filtered = _words.where((w) =>
        w.word.toLowerCase().contains(q) ||
        w.translation.toLowerCase().contains(q),
      ).toList();
    } else if (_activeFilter != null) {
      _filtered = _words.where((w) => w.wordType == _activeFilter).toList();
    } else {
      _filtered = List.from(_words);
    }
    notifyListeners(); // ← memberitahu Consumer untuk rebuild
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
