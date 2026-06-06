// ── MODEL: WordItem ────────────────────────────────────────────
// Merepresentasikan satu kata kosakata di Word Treasury.
// Model hanya berisi data dan logika konversi (fromJson/toJson).
// Tidak boleh ada UI atau state management di sini.

enum WordType { noun, verb, adjective, adverb, other }

class WordItem {
  final String   id;
  final String   word;
  final String   translation;   // Bahasa Indonesia
  final WordType wordType;
  final String   definition;    // Definisi bahasa Inggris
  final String   example;       // Contoh kalimat
  final String   phonetic;      // Fonetik, misal: /ˈɛl.ə.kwənt/
  final DateTime addedAt;

  const WordItem({
    required this.id,
    required this.word,
    required this.translation,
    required this.wordType,
    required this.definition,
    required this.example,
    required this.phonetic,
    required this.addedAt,
  });

  // ── Factory: dari JSON (untuk load dari SharedPreferences) ──
  factory WordItem.fromJson(Map<String, dynamic> json) {
    return WordItem(
      id:          json['id']          as String,
      word:        json['word']         as String,
      translation: json['translation']  as String,
      wordType:    WordType.values.firstWhere(
        (e) => e.name == (json['wordType'] as String),
        orElse: () => WordType.other,
      ),
      definition:  json['definition']   as String,
      example:     json['example']      as String,
      phonetic:    json['phonetic']     as String? ?? '',
      addedAt:     DateTime.parse(json['addedAt'] as String),
    );
  }

  // ── toJson: untuk simpan ke SharedPreferences ──
  Map<String, dynamic> toJson() => {
    'id':          id,
    'word':        word,
    'translation': translation,
    'wordType':    wordType.name,
    'definition':  definition,
    'example':     example,
    'phonetic':    phonetic,
    'addedAt':     addedAt.toIso8601String(),
  };

  // ── Helper: label tampilan dari enum ──
  String get wordTypeLabel {
    switch (wordType) {
      case WordType.noun:      return 'Noun';
      case WordType.verb:      return 'Verb';
      case WordType.adjective: return 'Adjective';
      case WordType.adverb:    return 'Adverb';
      case WordType.other:     return 'Other';
    }
  }

  // ── copyWith: membuat salinan dengan field tertentu diubah ──
  WordItem copyWith({
    String?   translation,
    String?   definition,
    String?   example,
  }) {
    return WordItem(
      id:          id,
      word:        word,
      translation: translation ?? this.translation,
      wordType:    wordType,
      definition:  definition ?? this.definition,
      example:     example    ?? this.example,
      phonetic:    phonetic,
      addedAt:     addedAt,
    );
  }
}
