enum WordType { noun, verb, adjective, adverb, other }

class WordItem {
  final String id;
  final String word;
  final String translation;
  final WordType wordType;
  final String definitionEN; // definisi bahasa Inggris (asli)
  final String definitionID; // definisi bahasa Indonesia (terjemahan)
  final String example;
  final String exampleID; // contoh kalimat bahasa Indonesia
  final String phonetic;
  final DateTime addedAt;

  const WordItem({
    required this.id,
    required this.word,
    required this.translation,
    required this.wordType,
    required this.definitionEN,
    required this.definitionID,
    required this.example,
    required this.exampleID,
    required this.phonetic,
    required this.addedAt,
  });

  // Getter untuk kemudahan — tampilkan definisi ID jika ada
  String get definition =>
      definitionID.isNotEmpty ? definitionID : definitionEN;

  factory WordItem.fromJson(Map<String, dynamic> json) {
    return WordItem(
      id: json['id'] as String,
      word: json['word'] as String,
      translation: json['translation'] as String,
      wordType: WordType.values.firstWhere(
        (e) => e.name == (json['wordType'] as String),
        orElse: () => WordType.other,
      ),
      definitionEN:
          json['definitionEN'] as String? ??
          json['definition'] as String? ??
          '',
      definitionID: json['definitionID'] as String? ?? '',
      example: json['example'] as String? ?? '',
      exampleID: json['exampleID'] as String? ?? '',
      phonetic: json['phonetic'] as String? ?? '',
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'word': word,
    'translation': translation,
    'wordType': wordType.name,
    'definitionEN': definitionEN,
    'definitionID': definitionID,
    'example': example,
    'exampleID': exampleID,
    'phonetic': phonetic,
    'addedAt': addedAt.toIso8601String(),
  };

  String get wordTypeLabel {
    switch (wordType) {
      case WordType.noun:
        return 'Noun';
      case WordType.verb:
        return 'Verb';
      case WordType.adjective:
        return 'Adjective';
      case WordType.adverb:
        return 'Adverb';
      case WordType.other:
        return 'Other';
    }
  }

  WordItem copyWith({
    String? translation,
    String? definitionEN,
    String? definitionID,
    String? example,
    String? exampleID,
  }) {
    return WordItem(
      id: id,
      word: word,
      translation: translation ?? this.translation,
      wordType: wordType,
      definitionEN: definitionEN ?? this.definitionEN,
      definitionID: definitionID ?? this.definitionID,
      example: example ?? this.example,
      exampleID: exampleID ?? this.exampleID,
      phonetic: phonetic,
      addedAt: addedAt,
    );
  }
}
