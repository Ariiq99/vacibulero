import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word_item.dart';

class WordRepository {
  static const _key = 'word_treasury';

  // ── READ: ambil semua kata ──
  Future<List<WordItem>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    final List<dynamic> decoded = json.decode(raw);
    return decoded
        .map((e) => WordItem.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
  }

  // ── CREATE: tambah kata baru ──
  Future<void> add(WordItem item) async {
    final all = await getAll();
    final exists = all.any(
      (w) => w.word.toLowerCase() == item.word.toLowerCase(),
    );
    if (exists) throw Exception('Kata "${item.word}" sudah ada di Treasury.');
    all.insert(0, item);
    await _save(all);
  }

  // ── DELETE: hapus kata ──
  Future<void> delete(String id) async {
    final all = await getAll();
    all.removeWhere((w) => w.id == id);
    await _save(all);
  }

  // ── UPDATE: perbarui kata ──
  Future<void> update(WordItem updated) async {
    final all = await getAll();
    final idx = all.indexWhere((w) => w.id == updated.id);
    if (idx == -1) throw Exception('Kata tidak ditemukan.');
    all[idx] = updated;
    await _save(all);
  }

  // ── SEARCH: cari kata ──
  Future<List<WordItem>> search(String query) async {
    if (query.trim().isEmpty) return getAll();
    final all = await getAll();
    final q = query.toLowerCase();
    return all
        .where(
          (w) =>
              w.word.toLowerCase().contains(q) ||
              w.translation.toLowerCase().contains(q),
        )
        .toList();
  }

  // ── FILTER: filter by type ──
  Future<List<WordItem>> filterByType(WordType type) async {
    final all = await getAll();
    return all.where((w) => w.wordType == type).toList();
  }

  // ── CHECK: apakah kata sudah ada ──
  Future<bool> exists(String word) async {
    final all = await getAll();
    return all.any((w) => w.word.toLowerCase() == word.toLowerCase());
  }

  // ── STATS: jumlah kata per tipe ──
  Future<Map<WordType, int>> getStatsByType() async {
    final all = await getAll();
    final stats = <WordType, int>{};
    for (final type in WordType.values) {
      stats[type] = all.where((w) => w.wordType == type).length;
    }
    return stats;
  }

  // ── Private: simpan ke SharedPreferences ──
  Future<void> _save(List<WordItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList =
        items.map((w) => w.toJson()).toList();
    final String encoded = json.encode(jsonList); // <── eksplisit
    await prefs.setString(_key, encoded);
  }
}
