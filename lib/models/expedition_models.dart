// ── MODEL: ExpeditionWord ──────────────────────────────────────
// Satu kartu kata dalam Word Expedition (dari JSON lokal).
class ExpeditionWord {
  final String word;
  final String translation;
  final String phonetic;
  final String example;
  final String wordType;

  const ExpeditionWord({
    required this.word,
    required this.translation,
    required this.phonetic,
    required this.example,
    required this.wordType,
  });

  factory ExpeditionWord.fromJson(Map<String, dynamic> json) {
    return ExpeditionWord(
      word:        json['word']        as String,
      translation: json['translation'] as String,
      phonetic:    json['phonetic']    as String? ?? '',
      example:     json['example']     as String? ?? '',
      wordType:    json['wordType']    as String? ?? 'other',
    );
  }
}

// ── MODEL: ExpeditionLevel ─────────────────────────────────────
// Satu level dalam sebuah tema (Level I, II, III).
class ExpeditionLevel {
  final int                  level;   // 1, 2, atau 3
  final List<ExpeditionWord> words;

  const ExpeditionLevel({required this.level, required this.words});

  factory ExpeditionLevel.fromJson(Map<String, dynamic> json) {
    return ExpeditionLevel(
      level: json['level'] as int,
      words: (json['words'] as List)
          .map((w) => ExpeditionWord.fromJson(w as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ── MODEL: ExpeditionTheme ─────────────────────────────────────
// Satu tema di Word Expedition (Animals, Food, Travel, dll.).
class ExpeditionTheme {
  final String                 id;
  final String                 name;
  final String                 emoji;
  final List<ExpeditionLevel>  levels;

  const ExpeditionTheme({
    required this.id,
    required this.name,
    required this.emoji,
    required this.levels,
  });

  factory ExpeditionTheme.fromJson(Map<String, dynamic> json) {
    return ExpeditionTheme(
      id:     json['id']    as String,
      name:   json['name']  as String,
      emoji:  json['emoji'] as String? ?? '📚',
      levels: (json['levels'] as List)
          .map((l) => ExpeditionLevel.fromJson(l as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ── MODEL: ExpeditionProgress ──────────────────────────────────
// Menyimpan progres pengguna pada satu level dari satu tema.
class ExpeditionProgress {
  final String      themeId;
  final int         level;
  final Set<String> completedWords;   // Set kata yang sudah ditandai Hafal
  final bool        isCompleted;
  final DateTime?   completedAt;

  const ExpeditionProgress({
    required this.themeId,
    required this.level,
    required this.completedWords,
    required this.isCompleted,
    this.completedAt,
  });

  // ── Key unik untuk SharedPreferences ──
  String get key => '${themeId}_$level';

  factory ExpeditionProgress.fromJson(Map<String, dynamic> json) {
    return ExpeditionProgress(
      themeId:        json['themeId']  as String,
      level:          json['level']    as int,
      completedWords: Set<String>.from(json['completedWords'] as List),
      isCompleted:    json['isCompleted'] as bool,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'themeId':        themeId,
    'level':          level,
    'completedWords': completedWords.toList(),
    'isCompleted':    isCompleted,
    'completedAt':    completedAt?.toIso8601String(),
  };

  ExpeditionProgress copyWith({
    Set<String>? completedWords,
    bool?        isCompleted,
    DateTime?    completedAt,
  }) {
    return ExpeditionProgress(
      themeId:        themeId,
      level:          level,
      completedWords: completedWords ?? this.completedWords,
      isCompleted:    isCompleted    ?? this.isCompleted,
      completedAt:    completedAt    ?? this.completedAt,
    );
  }
}
