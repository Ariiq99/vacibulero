import 'package:flutter/material.dart';
import '../models/word_item.dart';
import '../repositories/word_repository.dart';

class TreasuryViewModel extends ChangeNotifier {
  final WordRepository _repository;
  List<WordItem> _words = [];
  Map<WordType, int> _stats = {};
  bool _isLoading = false;
  String _searchQuery = '';
  WordType? _activeFilter;

  TreasuryViewModel(this._repository);

  // ── Getters ──
  List<WordItem> get words => _words;
  Map<WordType, int> get stats => _stats;
  bool get isLoading => _isLoading;
  bool get isEmpty => _words.isEmpty;
  String get searchQuery => _searchQuery;
  WordType? get activeFilter => _activeFilter;
  int get totalWords => _words.length;

  // ── Load data ──
  Future<void> loadWords() async {
    _isLoading = true;
    notifyListeners();
    _words = await _repository.getAll();
    _stats = await _repository.getStatsByType();
    _applyFilterAndSearch();
    _isLoading = false;
    notifyListeners();
  }

  // ── Search ──
  void search(String query) {
    _searchQuery = query;
    _applyFilterAndSearch();
    notifyListeners();
  }

  // ── Filter by type ──
  void filterByType(WordType? type) {
    _activeFilter = type;
    _applyFilterAndSearch();
    notifyListeners();
  }

  // ── Clear filter (reset ke Semua) ──
  void clearFilter() {
    _searchQuery = '';
    _activeFilter = null;
    _applyFilterAndSearch();
    notifyListeners();
  }

  // ── Tambah kata ──
  Future<void> addWord(WordItem word) async {
    await _repository.add(word);
    await loadWords();
  }

  // ── Hapus kata ──
  Future<void> deleteWord(String id) async {
    await _repository.delete(id);
    await loadWords();
  }

  // ── Cek apakah kata sudah ada ──
  Future<bool> isWordExists(String wordText) async {
    return await _repository.exists(wordText);
  }

  // ── Private: filter + search ──
  void _applyFilterAndSearch() {
    var result = _words;

    // Filter by type
    if (_activeFilter != null) {
      result = result.where((w) => w.wordType == _activeFilter).toList();
    }

    // Search by query
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((w) =>
              w.word.toLowerCase().contains(q) ||
              w.translation.toLowerCase().contains(q))
          .toList();
    }

    // Simpan hasil filter ke _words (tapi hati-hati: _words asli hilang)
    // Karena kita perlu mempertahankan _words asli, kita gunakan list terpisah.
    // Tapi di UI mereka pakai vm.words langsung, jadi kita harus override.
    // Cara aman: simpan _allWords dan _filteredWords.
    // Saya akan ubah pendekatan: simpan _allWords dan _filteredWords.
  }
}
