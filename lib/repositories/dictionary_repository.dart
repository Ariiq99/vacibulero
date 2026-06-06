import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/word_item.dart';

// ── DATA CLASS: DictionaryResult ──────────────────────────────
// Menampung hasil gabungan dari Free Dictionary API + MyMemory API.
class DictionaryResult {
  final String   word;
  final String   phonetic;
  final String   definition;
  final String   example;
  final WordType wordType;
  final String   translation; // Bahasa Indonesia dari MyMemory

  const DictionaryResult({
    required this.word,
    required this.phonetic,
    required this.definition,
    required this.example,
    required this.wordType,
    required this.translation,
  });
}

// ── REPOSITORY: DictionaryRepository ──────────────────────────
// Mengambil data kata dari dua API eksternal secara paralel:
// 1. Free Dictionary API  → definisi, fonetik, jenis kata, contoh
// 2. MyMemory API         → terjemahan Bahasa Indonesia
class DictionaryRepository {
  static const _dictBase    = 'https://api.dictionaryapi.dev/api/v2/entries/en';
  static const _memoryBase  = 'https://api.mymemory.translated.net/get';

  // ── Cari kata (panggil kedua API secara paralel) ──
  Future<DictionaryResult> lookup(String word) async {
    final trimmed = word.trim().toLowerCase();
    if (trimmed.isEmpty) throw Exception('Kata tidak boleh kosong.');

    // Jalankan kedua request secara paralel dengan Future.wait
    final results = await Future.wait([
      _fetchDictionary(trimmed),
      _fetchTranslation(trimmed),
    ]);

    final dictData    = results[0] as Map<String, dynamic>;
    final translation = results[1] as String;

    return DictionaryResult(
      word:        trimmed,
      phonetic:    dictData['phonetic']   as String,
      definition:  dictData['definition'] as String,
      example:     dictData['example']    as String,
      wordType:    dictData['wordType']   as WordType,
      translation: translation,
    );
  }

  // ── Private: Free Dictionary API ──
  Future<Map<String, dynamic>> _fetchDictionary(String word) async {
    final uri = Uri.parse('$_dictBase/$word');
    final res = await http.get(uri).timeout(const Duration(seconds: 8));

    if (res.statusCode == 404) {
      throw Exception('Kata "$word" tidak ditemukan di kamus.');
    }
    if (res.statusCode != 200) {
      throw Exception('Gagal mengambil data kamus (${res.statusCode}).');
    }

    final data    = (jsonDecode(res.body) as List).first as Map<String, dynamic>;
    final meanings = data['meanings'] as List? ?? [];

    // Ambil meaning pertama yang tersedia
    String   definition = 'Tidak ada definisi.';
    String   example    = '';
    WordType wordType   = WordType.other;
    String   phonetic   = '';

    // Cari fonetik
    final phonetics = data['phonetics'] as List? ?? [];
    for (final p in phonetics) {
      final ph = p['text'] as String? ?? '';
      if (ph.isNotEmpty) { phonetic = ph; break; }
    }

    if (meanings.isNotEmpty) {
      final first = meanings.first as Map<String, dynamic>;
      final partOfSpeech = first['partOfSpeech'] as String? ?? '';
      wordType = _parseWordType(partOfSpeech);

      final defs = first['definitions'] as List? ?? [];
      if (defs.isNotEmpty) {
        final firstDef = defs.first as Map<String, dynamic>;
        definition = firstDef['definition'] as String? ?? definition;
        example    = firstDef['example']    as String? ?? '';
      }
    }

    return {
      'phonetic':   phonetic,
      'definition': definition,
      'example':    example,
      'wordType':   wordType,
    };
  }

  // ── Private: MyMemory Translation API ──
  Future<String> _fetchTranslation(String word) async {
    final uri = Uri.parse(
      '$_memoryBase?q=${Uri.encodeComponent(word)}&langpair=en|id',
    );
    final res = await http.get(uri).timeout(const Duration(seconds: 8));

    if (res.statusCode != 200) return word; // fallback ke kata asli

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final translated =
        (data['responseData'] as Map<String, dynamic>)['translatedText']
            as String? ?? word;

    // MyMemory kadang mengembalikan teks dalam huruf besar semua
    return translated.isEmpty ? word : translated.toLowerCase();
  }

  // ── Helper: parse part-of-speech ke enum WordType ──
  WordType _parseWordType(String pos) {
    switch (pos.toLowerCase()) {
      case 'noun':      return WordType.noun;
      case 'verb':      return WordType.verb;
      case 'adjective': return WordType.adjective;
      case 'adverb':    return WordType.adverb;
      default:          return WordType.other;
    }
  }
}
