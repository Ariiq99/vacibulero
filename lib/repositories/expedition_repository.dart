import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expedition_models.dart';

// ── REPOSITORY: ExpeditionRepository ──────────────────────────
// Mengelola konten Word Expedition (dari JSON lokal) dan
// menyimpan/membaca progres pengguna (dari SharedPreferences).
class ExpeditionRepository {
  static const _progressPrefix = 'expedition_progress_';

  // ── READ: muat semua tema dari JSON asset ──
  Future<List<ExpeditionTheme>> loadThemes() async {
    // rootBundle.loadString membaca file dari assets/ folder
    final raw = await rootBundle.loadString(
      'assets/data/expedition_content.json',
    );
    final List data = jsonDecode(raw) as List;
    return data
        .map((t) => ExpeditionTheme.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  // ── READ: baca progres satu level ──
  Future<ExpeditionProgress?> getProgress(String themeId, int level) async {
    final prefs = await SharedPreferences.getInstance();
    final key   = '$_progressPrefix${themeId}_$level';
    final raw   = prefs.getString(key);
    if (raw == null) return null;
    return ExpeditionProgress.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  // ── READ: baca semua progres pengguna ──
  Future<Map<String, ExpeditionProgress>> getAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final result = <String, ExpeditionProgress>{};
    for (final key in prefs.getKeys()) {
      if (key.startsWith(_progressPrefix)) {
        final raw = prefs.getString(key)!;
        final progress = ExpeditionProgress.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
        result[progress.key] = progress;
      }
    }
    return result;
  }

  // ── UPDATE: tandai kata sebagai hafal ──
  Future<ExpeditionProgress> markWordLearned({
    required String themeId,
    required int    level,
    required String word,
    required int    totalWords,
  }) async {
    // Ambil progres yang ada, atau buat baru jika belum ada
    final existing = await getProgress(themeId, level);
    final completed = Set<String>.from(existing?.completedWords ?? {})
      ..add(word);
    final isCompleted = completed.length >= totalWords;

    final updated = ExpeditionProgress(
      themeId:        themeId,
      level:          level,
      completedWords: completed,
      isCompleted:    isCompleted,
      completedAt:    isCompleted ? DateTime.now() : existing?.completedAt,
    );

    await _saveProgress(updated);
    return updated;
  }

  // ── Private: simpan progress ──
  Future<void> _saveProgress(ExpeditionProgress p) async {
    final prefs = await SharedPreferences.getInstance();
    final key   = '$_progressPrefix${p.key}';
    await prefs.setString(key, jsonEncode(p.toJson()));
  }
}
