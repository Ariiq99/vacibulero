import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/word_item.dart';

// ── DATA CLASS: DictionaryResult ──────────────────────────────
class DictionaryResult {
  final String word;
  final String phonetic;
  final String definitionEN; // definisi asli bahasa Inggris
  final String definitionID; // definisi yang sudah diterjemahkan ke ID
  final String example;
  final String exampleID; // contoh kalimat dalam bahasa Indonesia
  final WordType wordType;
  final String translation; // terjemahan kata ke Bahasa Indonesia

  const DictionaryResult({
    required this.word,
    required this.phonetic,
    required this.definitionEN,
    required this.definitionID,
    required this.example,
    required this.exampleID,
    required this.wordType,
    required this.translation,
  });
}

// ── REPOSITORY: DictionaryRepository ──────────────────────────
// Mengambil data dari dua API secara paralel:
// 1. Free Dictionary API  → definisi EN, fonetik, jenis kata, contoh
// 2. MyMemory API         → terjemahan kata, definisi, dan contoh ke ID
class DictionaryRepository {
  static const _dictBase = 'https://api.dictionaryapi.dev/api/v2/entries/en';
  static const _memoryBase = 'https://api.mymemory.translated.net/get';

  Future<DictionaryResult> lookup(String word) async {
    final trimmed = word.trim().toLowerCase();
    if (trimmed.isEmpty) throw Exception('Kata tidak boleh kosong.');

    // ── Step 1: Ambil data dari Free Dictionary API dulu ──
    final dictData = await _fetchDictionary(trimmed);

    final definitionEN = dictData['definition'] as String;
    final example = dictData['example'] as String;

    // ── Step 2: Terjemahkan kata, definisi, dan contoh secara paralel ──
    final translations = await Future.wait([
      _fetchTranslation(trimmed), // terjemahan kata
      _fetchTranslation(definitionEN), // terjemahan definisi
      if (example.isNotEmpty)
        _fetchTranslation(example) // terjemahan contoh kalimat
      else
        Future.value(''),
    ]);

    return DictionaryResult(
      word: trimmed,
      phonetic: dictData['phonetic'] as String,
      definitionEN: definitionEN,
      definitionID: translations[1], // definisi sudah dalam ID
      example: example,
      exampleID: translations.length > 2 ? translations[2] : '',
      wordType: dictData['wordType'] as WordType,
      translation: translations[0], // terjemahan kata
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

    final data = (jsonDecode(res.body) as List).first as Map<String, dynamic>;
    final meanings = data['meanings'] as List? ?? [];

    String definition = 'Tidak ada definisi.';
    String example = '';
    WordType wordType = WordType.other;
    String phonetic = '';

    // Ambil fonetik
    final phonetics = data['phonetics'] as List? ?? [];
    for (final p in phonetics) {
      final ph = p['text'] as String? ?? '';
      if (ph.isNotEmpty) {
        phonetic = ph;
        break;
      }
    }

    if (meanings.isNotEmpty) {
      final first = meanings.first as Map<String, dynamic>;
      final partOfSpeech = first['partOfSpeech'] as String? ?? '';
      wordType = _parseWordType(partOfSpeech);

      final defs = first['definitions'] as List? ?? [];
      if (defs.isNotEmpty) {
        final firstDef = defs.first as Map<String, dynamic>;
        definition = firstDef['definition'] as String? ?? definition;
        example = firstDef['example'] as String? ?? '';
      }
    }

    return {
      'phonetic': phonetic,
      'definition': definition,
      'example': example,
      'wordType': wordType,
    };
  }

  // ── Private: MyMemory Translation API ──
  // Digunakan untuk menerjemahkan kata, definisi, maupun contoh kalimat
  Future<String> _fetchTranslation(String text) async {
    if (text.isEmpty) return '';

    // MyMemory punya batas 500 karakter per request
    final clipped = text.length > 490 ? '${text.substring(0, 490)}...' : text;

    final uri = Uri.parse(
      '$_memoryBase?q=${Uri.encodeComponent(clipped)}&langpair=en|id',
    );

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return text;

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final translated =
          (data['responseData'] as Map<String, dynamic>)['translatedText']
              as String? ??
          text;

      // MyMemory kadang mengembalikan ALL CAPS jika tidak yakin
      // Konversi ke sentence case agar lebih terbaca
      if (translated.isEmpty) return text;
      return _toSentenceCase(translated);
    } catch (_) {
      return text; // fallback ke teks asli jika error
    }
  }

  // ── Helper: sentence case ──
  String _toSentenceCase(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // ── Helper: parse part-of-speech ke enum ──
  WordType _parseWordType(String pos) {
    switch (pos.toLowerCase()) {
      case 'noun':
        return WordType.noun;
      case 'verb':
        return WordType.verb;
      case 'adjective':
        return WordType.adjective;
      case 'adverb':
        return WordType.adverb;
      default:
        return WordType.other;
    }
  }
}
