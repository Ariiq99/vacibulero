class ExpeditionTheme {
  final String id;
  final String name;
  final String emoji;
  final List<ExpeditionDifficulty> difficulties;

  ExpeditionTheme({
    required this.id,
    required this.name,
    required this.emoji,
    required this.difficulties,
  });

  factory ExpeditionTheme.fromJson(Map<String, dynamic> json) {
    return ExpeditionTheme(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      emoji: json['emoji'] ?? '📚',
      difficulties: (json['difficulties'] as List?)
              ?.map((d) => ExpeditionDifficulty.fromJson(d))
              .toList() ??
          [],
    );
  }
}

class ExpeditionDifficulty {
  final String difficulty; // Beginner, Intermediate, Advanced
  final List<ExpeditionLevel> levels;

  ExpeditionDifficulty({required this.difficulty, required this.levels});

  factory ExpeditionDifficulty.fromJson(Map<String, dynamic> json) {
    return ExpeditionDifficulty(
      difficulty: json['difficulty'] ?? 'Beginner',
      levels: (json['levels'] as List?)
              ?.map((l) => ExpeditionLevel.fromJson(l))
              .toList() ??
          [],
    );
  }
}

class ExpeditionLevel {
  final int level;
  final List<WordContent> words;

  ExpeditionLevel({required this.level, required this.words});

  factory ExpeditionLevel.fromJson(Map<String, dynamic> json) {
    return ExpeditionLevel(
      level: json['level'] ?? 1,
      words: (json['words'] as List?)
              ?.map((w) => WordContent.fromJson(w))
              .toList() ??
          [],
    );
  }
}

class WordContent {
  final String word;
  final String meaning;
  final String
      clue; // Poin 2: Digunakan sebagai petunjuk kalimat rumpang saat kuis

  WordContent({required this.word, required this.meaning, required this.clue});

  factory WordContent.fromJson(Map<String, dynamic> json) {
    return WordContent(
      word: json['word'] ?? '',
      meaning: json['meaning'] ?? '',
      clue: json['clue'] ?? 'Fill in the blank space.',
    );
  }
}

class ExpeditionProgress {
  final String themeId;
  final int level;
  final Set<String> completedWords;
  final bool isCompleted;
  final DateTime? completedAt;

  ExpeditionProgress({
    required this.themeId,
    required this.level,
    required this.completedWords,
    required this.isCompleted,
    this.completedAt,
  });

  String get key => '${themeId}_$level';

  factory ExpeditionProgress.fromJson(Map<String, dynamic> json) {
    return ExpeditionProgress(
      themeId: json['themeId'] ?? '',
      level: json['level'] ?? 1,
      completedWords: Set<String>.from(json['completedWords'] ?? []),
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'themeId': themeId,
        'level': level,
        'completedWords': completedWords.toList(),
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
      };
}
