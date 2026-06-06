import 'package:flutter/foundation.dart';
import '../models/word_item.dart';
import '../repositories/dictionary_repository.dart';

// ── State saat fetch/save ──
enum AddWordStatus { idle, loading, success, error }

// ── VIEWMODEL: AddWordViewModel ────────────────────────────────
// Mengelola state dan logika untuk halaman Tambah Kata.
// Bertanggung jawab memanggil DictionaryRepository dan
// menyiapkan WordItem untuk disimpan ke TreasuryViewModel.
class AddWordViewModel extends ChangeNotifier {
  final DictionaryRepository _dictRepo;

  AddWordViewModel(this._dictRepo);

  // ── State ──
  AddWordStatus    _status = AddWordStatus.idle;
  DictionaryResult? _result;
  String?          _error;

  // ── Getters ──
  AddWordStatus     get status  => _status;
  DictionaryResult? get result  => _result;
  String?           get error   => _error;
  bool get isLoading => _status == AddWordStatus.loading;
  bool get hasResult => _result != null;

  // ── LOOKUP: cari kata ke Dictionary API + MyMemory ──
  Future<void> lookupWord(String word) async {
    if (word.trim().isEmpty) return;

    _status = AddWordStatus.loading;
    _result = null;
    _error  = null;
    notifyListeners();

    try {
      _result = await _dictRepo.lookup(word.trim());
      _status = AddWordStatus.success;
    } catch (e) {
      _error  = e.toString();
      _status = AddWordStatus.error;
    }
    notifyListeners();
  }

  // ── BUILD: bangun WordItem dari hasil lookup ──
  // Dipanggil View sebelum menyimpan ke TreasuryViewModel
  WordItem buildWordItem() {
    if (_result == null) throw Exception('Tidak ada data kata.');
    return WordItem(
      id:          DateTime.now().millisecondsSinceEpoch.toString(),
      word:        _result!.word,
      translation: _result!.translation,
      wordType:    _result!.wordType,
      definition:  _result!.definition,
      example:     _result!.example,
      phonetic:    _result!.phonetic,
      addedAt:     DateTime.now(),
    );
  }

  // ── RESET: bersihkan state setelah selesai ──
  void reset() {
    _status = AddWordStatus.idle;
    _result = null;
    _error  = null;
    notifyListeners();
  }
}
