// ============================================================
// FILE: test/word_item_test.dart
//
// Unit Test untuk WordItem Model — AFL 3 MAD (v2)
// Menguji logika pada kelas WordItem:
//   1. wordTypeLabel getter   — konversi enum ke label string
//   2. definition getter      — fallback dari ID ke EN
//   3. fromJson()              — deserialisasi dari Map
//   4. toJson()                — serialisasi ke Map
//   5. copyWith()              — membuat salinan dengan field diubah
//
// Pola: Arrange → Act → Assert (AAA)
// ============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:vacibulero/models/word_item.dart';

void main() {
  // ── Helper: membuat WordItem standar untuk keperluan test ──
  WordItem makeTestWord({
    String id = 'test-001',
    String word = 'eloquent',
    String translation = 'fasih',
    WordType wordType = WordType.adjective,
    String definitionEN = 'Fluent or persuasive in speaking or writing.',
    String definitionID = 'Fasih atau persuasif dalam berbicara atau menulis.',
    String example = 'She gave an eloquent speech.',
    String exampleID = 'Dia memberikan pidato yang fasih.',
    String phonetic = '/ˈɛl.ə.kwənt/',
    DateTime? addedAt,
  }) {
    return WordItem(
      id: id,
      word: word,
      translation: translation,
      wordType: wordType,
      definitionEN: definitionEN,
      definitionID: definitionID,
      example: example,
      exampleID: exampleID,
      phonetic: phonetic,
      addedAt: addedAt ?? DateTime(2025, 6, 1, 10, 0),
    );
  }

  // ════════════════════════════════════════════════════════════
  // GROUP 1: wordTypeLabel getter
  // ════════════════════════════════════════════════════════════
  group('wordTypeLabel getter', () {
    test('mengembalikan "Noun" untuk WordType.noun', () {
      // ── Arrange ──
      final word = makeTestWord(wordType: WordType.noun);
      // ── Act ──
      final label = word.wordTypeLabel;
      // ── Assert ──
      expect(label, equals('Noun'));
    });

    test('mengembalikan "Verb" untuk WordType.verb', () {
      final word = makeTestWord(wordType: WordType.verb);
      final label = word.wordTypeLabel;
      expect(label, equals('Verb'));
    });

    test('mengembalikan "Adjective" untuk WordType.adjective', () {
      final word = makeTestWord(wordType: WordType.adjective);
      final label = word.wordTypeLabel;
      expect(label, equals('Adjective'));
    });

    test('mengembalikan "Adverb" untuk WordType.adverb', () {
      final word = makeTestWord(wordType: WordType.adverb);
      final label = word.wordTypeLabel;
      expect(label, equals('Adverb'));
    });

    test('mengembalikan "Other" untuk WordType.other', () {
      final word = makeTestWord(wordType: WordType.other);
      final label = word.wordTypeLabel;
      expect(label, equals('Other'));
    });

    test('label tidak pernah kosong untuk semua tipe WordType', () {
      for (final type in WordType.values) {
        final word = makeTestWord(wordType: type);
        final label = word.wordTypeLabel;
        expect(
          label.isNotEmpty,
          isTrue,
          reason: 'Label untuk $type tidak boleh kosong',
        );
      }
    });
  });

  // ════════════════════════════════════════════════════════════
  // GROUP 2: definition getter (fallback logic)
  // ════════════════════════════════════════════════════════════
  group('definition getter (fallback ID -> EN)', () {
    test('mengembalikan definitionID jika tersedia', () {
      // ── Arrange ──
      final word = makeTestWord(
        definitionEN: 'English definition',
        definitionID: 'Definisi Indonesia',
      );

      // ── Act ──
      final result = word.definition;

      // ── Assert ──
      expect(result, equals('Definisi Indonesia'));
    });

    test('fallback ke definitionEN jika definitionID kosong', () {
      // ── Arrange ──
      final word = makeTestWord(
        definitionEN: 'English definition only',
        definitionID: '',
      );

      // ── Act ──
      final result = word.definition;

      // ── Assert ──
      expect(result, equals('English definition only'));
    });

    test('mengembalikan string kosong jika keduanya kosong', () {
      // ── Arrange ──
      final word = makeTestWord(definitionEN: '', definitionID: '');

      // ── Act ──
      final result = word.definition;

      // ── Assert ──
      expect(result, equals(''));
    });
  });

  // ════════════════════════════════════════════════════════════
  // GROUP 3: toJson() — serialisasi ke Map
  // ════════════════════════════════════════════════════════════
  group('toJson()', () {
    test('menghasilkan Map dengan semua key yang diperlukan', () {
      // ── Arrange ──
      final word = makeTestWord();

      // ── Act ──
      final json = word.toJson();

      // ── Assert ──
      expect(json.containsKey('id'), isTrue);
      expect(json.containsKey('word'), isTrue);
      expect(json.containsKey('translation'), isTrue);
      expect(json.containsKey('wordType'), isTrue);
      expect(json.containsKey('definitionEN'), isTrue);
      expect(json.containsKey('definitionID'), isTrue);
      expect(json.containsKey('example'), isTrue);
      expect(json.containsKey('exampleID'), isTrue);
      expect(json.containsKey('phonetic'), isTrue);
      expect(json.containsKey('addedAt'), isTrue);
    });

    test('nilai field sesuai dengan data asli WordItem', () {
      // ── Arrange ──
      final word = makeTestWord(
        id: 'id-999',
        word: 'persevere',
        translation: 'bertahan',
        wordType: WordType.verb,
      );

      // ── Act ──
      final json = word.toJson();

      // ── Assert ──
      expect(json['id'], equals('id-999'));
      expect(json['word'], equals('persevere'));
      expect(json['translation'], equals('bertahan'));
      expect(json['wordType'], equals('verb'));
    });

    test('wordType diserialisasi sebagai String nama enum (bukan index)', () {
      // ── Arrange ──
      final word = makeTestWord(wordType: WordType.adjective);

      // ── Act ──
      final json = word.toJson();

      // ── Assert ──
      expect(json['wordType'], equals('adjective'));
      expect(json['wordType'], isA<String>());
    });

    test('definitionID dan definitionEN tersimpan terpisah', () {
      // ── Arrange ──
      final word = makeTestWord(
        definitionEN: 'Hibernate means to sleep through winter.',
        definitionID: 'Hibernasi berarti tidur sepanjang musim dingin.',
      );

      // ── Act ──
      final json = word.toJson();

      // ── Assert ──
      expect(
        json['definitionEN'],
        equals('Hibernate means to sleep through winter.'),
      );
      expect(
        json['definitionID'],
        equals('Hibernasi berarti tidur sepanjang musim dingin.'),
      );
    });

    test('addedAt diserialisasi sebagai String ISO 8601', () {
      // ── Arrange ──
      final date = DateTime(2025, 6, 15, 9, 30);
      final word = makeTestWord(addedAt: date);

      // ── Act ──
      final json = word.toJson();

      // ── Assert ──
      expect(json['addedAt'], equals(date.toIso8601String()));
      expect(json['addedAt'], isA<String>());
    });
  });

  // ════════════════════════════════════════════════════════════
  // GROUP 4: fromJson() — deserialisasi dari Map
  // ════════════════════════════════════════════════════════════
  group('fromJson()', () {
    final sampleJson = {
      'id': 'json-001',
      'word': 'hibernate',
      'translation': 'tidur panjang',
      'wordType': 'verb',
      'definitionEN': 'Spend the winter in a dormant state.',
      'definitionID': 'Menghabiskan musim dingin dalam keadaan tidak aktif.',
      'example': 'Bears hibernate during winter.',
      'exampleID': 'Beruang berhibernasi selama musim dingin.',
      'phonetic': '/ˈhaɪ.bər.neɪt/',
      'addedAt': '2025-03-10T08:00:00.000',
    };

    test('membuat WordItem dari JSON dengan nilai yang benar', () {
      // ── Arrange ──
      // JSON sudah disiapkan di atas

      // ── Act ──
      final word = WordItem.fromJson(sampleJson);

      // ── Assert ──
      expect(word.id, equals('json-001'));
      expect(word.word, equals('hibernate'));
      expect(word.translation, equals('tidur panjang'));
      expect(word.wordType, equals(WordType.verb));
      expect(word.definitionEN, equals('Spend the winter in a dormant state.'));
      expect(
        word.definitionID,
        equals('Menghabiskan musim dingin dalam keadaan tidak aktif.'),
      );
      expect(word.phonetic, equals('/ˈhaɪ.bər.neɪt/'));
    });

    test('wordType di-parse dengan benar dari String ke enum', () {
      // ── Arrange ──
      final jsonData = {...sampleJson, 'wordType': 'adjective'};

      // ── Act ──
      final word = WordItem.fromJson(jsonData);

      // ── Assert ──
      expect(word.wordType, equals(WordType.adjective));
    });

    test('addedAt di-parse dengan benar dari String ISO 8601 ke DateTime', () {
      // ── Arrange ──
      final jsonData = {...sampleJson, 'addedAt': '2025-06-15T09:30:00.000'};

      // ── Act ──
      final word = WordItem.fromJson(jsonData);

      // ── Assert ──
      expect(word.addedAt.year, equals(2025));
      expect(word.addedAt.month, equals(6));
      expect(word.addedAt.day, equals(15));
      expect(word.addedAt.hour, equals(9));
      expect(word.addedAt.minute, equals(30));
    });

    test('wordType fallback ke "other" jika nilai tidak dikenal', () {
      // ── Arrange ──
      final jsonData = {...sampleJson, 'wordType': 'preposition'};

      // ── Act ──
      final word = WordItem.fromJson(jsonData);

      // ── Assert ──
      expect(word.wordType, equals(WordType.other));
    });

    test('phonetic boleh kosong tanpa menyebabkan error', () {
      // ── Arrange ──
      final jsonData = Map<String, dynamic>.from(sampleJson)
        ..remove('phonetic');

      // ── Act ──
      final word = WordItem.fromJson(jsonData);

      // ── Assert ──
      expect(word.phonetic, equals(''));
    });

    test(
      'definitionID boleh kosong (backward compatible dengan data lama)',
      () {
        // ── Arrange ──
        final jsonData = Map<String, dynamic>.from(sampleJson)
          ..remove('definitionID');

        // ── Act ──
        final word = WordItem.fromJson(jsonData);

        // ── Assert ──
        expect(word.definitionID, equals(''));
        expect(word.definition, equals(word.definitionEN));
      },
    );

    test(
      'fromJson mendukung field "definition" lama untuk backward compatibility',
      () {
        // ── Arrange ──
        // Simulasi data dari versi 1 aplikasi (sebelum field di-split EN/ID)
        final legacyJson = {
          'id': 'legacy-001',
          'word': 'old',
          'translation': 'lama',
          'wordType': 'adjective',
          'definition': 'Legacy definition field',
          'example': 'An old example.',
          'phonetic': '/oʊld/',
          'addedAt': '2024-01-01T00:00:00.000',
        };

        // ── Act ──
        final word = WordItem.fromJson(legacyJson);

        // ── Assert ──
        expect(word.definitionEN, equals('Legacy definition field'));
      },
    );
  });

  // ════════════════════════════════════════════════════════════
  // GROUP 5: toJson() -> fromJson() round-trip
  // ════════════════════════════════════════════════════════════
  group('toJson() -> fromJson() round-trip', () {
    test('data tetap sama setelah konversi toJson lalu fromJson', () {
      // ── Arrange ──
      final original = makeTestWord(
        id: 'rt-001',
        word: 'wanderlust',
        translation: 'hasrat berpetualang',
        wordType: WordType.noun,
        phonetic: '/ˈwɒn.də.lʌst/',
        addedAt: DateTime(2025, 5, 20, 14, 0),
      );

      // ── Act ──
      final json = original.toJson();
      final restored = WordItem.fromJson(json);

      // ── Assert ──
      expect(restored.id, equals(original.id));
      expect(restored.word, equals(original.word));
      expect(restored.translation, equals(original.translation));
      expect(restored.wordType, equals(original.wordType));
      expect(restored.definitionEN, equals(original.definitionEN));
      expect(restored.definitionID, equals(original.definitionID));
      expect(restored.phonetic, equals(original.phonetic));
      expect(restored.addedAt, equals(original.addedAt));
    });

    test('round-trip untuk semua WordType menghasilkan tipe yang sama', () {
      // ── Arrange & Act & Assert ──
      for (final type in WordType.values) {
        final original = makeTestWord(wordType: type);
        final json = original.toJson();
        final restored = WordItem.fromJson(json);

        expect(
          restored.wordType,
          equals(original.wordType),
          reason: 'Round-trip gagal untuk WordType.$type',
        );
      }
    });
  });

  // ════════════════════════════════════════════════════════════
  // GROUP 6: copyWith()
  // ════════════════════════════════════════════════════════════
  group('copyWith()', () {
    test('mengubah translation tanpa mengubah field lain', () {
      // ── Arrange ──
      final original = makeTestWord(word: 'cat', translation: 'kucing');

      // ── Act ──
      final updated = original.copyWith(translation: 'seekor kucing');

      // ── Assert ──
      expect(updated.translation, equals('seekor kucing'));
      expect(updated.id, equals(original.id));
      expect(updated.word, equals(original.word));
      expect(updated.wordType, equals(original.wordType));
    });

    test('mengubah definitionID tanpa mengubah field lain', () {
      // ── Arrange ──
      final original = makeTestWord(definitionID: 'Definisi lama.');

      // ── Act ──
      final updated = original.copyWith(
        definitionID: 'Definisi baru yang diperbarui.',
      );

      // ── Assert ──
      expect(updated.definitionID, equals('Definisi baru yang diperbarui.'));
      expect(updated.word, equals(original.word));
      expect(updated.definitionEN, equals(original.definitionEN));
    });

    test('copyWith tanpa argumen menghasilkan object dengan nilai sama', () {
      // ── Arrange ──
      final original = makeTestWord();

      // ── Act ──
      final copy = original.copyWith();

      // ── Assert ──
      expect(copy.id, equals(original.id));
      expect(copy.word, equals(original.word));
      expect(copy.translation, equals(original.translation));
      expect(copy.wordType, equals(original.wordType));
      expect(copy.definitionEN, equals(original.definitionEN));
      expect(copy.definitionID, equals(original.definitionID));
      expect(copy.example, equals(original.example));
    });

    test('object asli tidak berubah setelah copyWith (immutability)', () {
      // ── Arrange ──
      final original = makeTestWord(translation: 'fasih');

      // ── Act ──
      original.copyWith(translation: 'pandai bicara');

      // ── Assert ──
      expect(original.translation, equals('fasih'));
    });
  });
}
