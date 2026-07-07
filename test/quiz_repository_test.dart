// ============================================================
// FILE: test/quiz_repository_test.dart
//
// Unit Test untuk QuizRepository — AFL 3 MAD
// Menguji dua fungsi utama:
//   1. generateQuestions() — membuat soal kuis dari daftar kata
//   2. evaluateSession()   — mengevaluasi jawaban dan menghitung skor
//
// Pola: Arrange → Act → Assert (AAA)
// ============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:vacibulero/models/word_item.dart';
import 'package:vacibulero/models/quiz_models.dart';
import 'package:vacibulero/repositories/quiz_repository.dart';

void main() {
  // ── Inisialisasi repository yang akan diuji ──
  // Repository ini tidak memiliki dependency eksternal (no API, no DB)
  // sehingga bisa langsung diinstansiasi tanpa mock apapun.
  late QuizRepository repo;

  // setUp() dipanggil SEBELUM setiap test — memastikan setiap test
  // dimulai dengan instance yang bersih (clean state).
  setUp(() {
    repo = QuizRepository();
  });

  // ── Helper: membuat WordItem dummy untuk keperluan test ──
  // Fungsi ini menghindari pengulangan kode di setiap test case.
  WordItem makeWord({
    required String id,
    required String word,
    required String translation,
    WordType type = WordType.noun,
  }) {
    return WordItem(
      id: id,
      word: word,
      translation: translation,
      wordType: type,
      definitionEN: 'Test definition for $word',
      definitionID: 'Definisi tes untuk $word',
      example: 'Example sentence using $word.',
      exampleID: 'Contoh kalimat menggunakan $word.',
      phonetic: '/test/',
      addedAt: DateTime(2025, 1, 1),
    );
  }

  // ── Data dummy yang dipakai di banyak test ──
  // Minimal 4 kata diperlukan untuk membuat soal dengan 4 opsi pilihan.
  final sampleWords = [
    makeWord(id: '1', word: 'cat', translation: 'kucing', type: WordType.noun),
    makeWord(id: '2', word: 'dog', translation: 'anjing', type: WordType.noun),
    makeWord(id: '3', word: 'run', translation: 'berlari', type: WordType.verb),
    makeWord(
      id: '4',
      word: 'happy',
      translation: 'bahagia',
      type: WordType.adjective,
    ),
    makeWord(
      id: '5',
      word: 'quickly',
      translation: 'dengan cepat',
      type: WordType.adverb,
    ),
    makeWord(
      id: '6',
      word: 'elephant',
      translation: 'gajah',
      type: WordType.noun,
    ),
    makeWord(
      id: '7',
      word: 'swim',
      translation: 'berenang',
      type: WordType.verb,
    ),
    makeWord(
      id: '8',
      word: 'beautiful',
      translation: 'cantik',
      type: WordType.adjective,
    ),
  ];

  // ════════════════════════════════════════════════════════════
  // GROUP 1: generateQuestions()
  // Menguji fungsi pembuat soal kuis
  // ════════════════════════════════════════════════════════════
  group('generateQuestions()', () {
    test('menghasilkan jumlah soal sesuai parameter count', () {
      // ── Arrange ──
      // Siapkan 8 kata dan minta 5 soal
      const requestedCount = 5;

      // ── Act ──
      // Panggil fungsi yang diuji
      final questions = repo.generateQuestions(
        sampleWords,
        count: requestedCount,
      );

      // ── Assert ──
      // Verifikasi jumlah soal sesuai yang diminta
      expect(questions.length, equals(requestedCount));
    });

    test('menghasilkan semua kata jika count melebihi jumlah kata', () {
      // ── Arrange ──
      // Minta 20 soal tapi hanya ada 8 kata
      const requestedCount = 20;

      // ── Act ──
      final questions = repo.generateQuestions(
        sampleWords,
        count: requestedCount,
      );

      // ── Assert ──
      // Tidak bisa melebihi jumlah kata yang tersedia
      expect(questions.length, equals(sampleWords.length));
    });

    test('setiap soal memiliki tepat 4 pilihan jawaban', () {
      // ── Arrange ──
      // Gunakan semua 8 kata sampel

      // ── Act ──
      final questions = repo.generateQuestions(sampleWords);

      // ── Assert ──
      // Iterasi setiap soal dan periksa jumlah opsinya
      for (final q in questions) {
        expect(
          q.options.length,
          equals(4),
          reason: 'Soal untuk kata "${q.questionText}" harus punya 4 opsi',
        );
      }
    });

    test('jawaban benar selalu ada di dalam daftar pilihan', () {
      // ── Arrange ──
      // Ini adalah invariant paling penting: correctAnswer HARUS ada di options

      // ── Act ──
      final questions = repo.generateQuestions(sampleWords);

      // ── Assert ──
      for (final q in questions) {
        expect(
          q.options.contains(q.correctAnswer),
          isTrue,
          reason:
              '"${q.correctAnswer}" harus ada di options soal "${q.questionText}"',
        );
      }
    });

    test('tidak ada duplikat pilihan jawaban dalam satu soal', () {
      // ── Arrange ──
      // Setiap opsi harus unik — tidak boleh ada jawaban yang sama dua kali

      // ── Act ──
      final questions = repo.generateQuestions(sampleWords);

      // ── Assert ──
      for (final q in questions) {
        final uniqueOptions = q.options.toSet();
        expect(
          uniqueOptions.length,
          equals(q.options.length),
          reason: 'Tidak boleh ada opsi duplikat di soal "${q.questionText}"',
        );
      }
    });

    test(
      'direction soal hanya berisi nilai yang valid (enToId atau idToEn)',
      () {
        // ── Arrange ──
        final validDirections = QuizDirection.values;

        // ── Act ──
        final questions = repo.generateQuestions(sampleWords);

        // ── Assert ──
        for (final q in questions) {
          expect(
            validDirections.contains(q.direction),
            isTrue,
            reason: 'Direction harus berupa enToId atau idToEn',
          );
        }
      },
    );

    test('melempar Exception saat kata kurang dari 2', () {
      // ── Arrange ──
      // Hanya 1 kata — tidak cukup untuk membuat soal dengan pengecoh
      final tooFewWords = [
        makeWord(id: '1', word: 'cat', translation: 'kucing'),
      ];

      // ── Act & Assert ──
      // Verifikasi bahwa fungsi melempar exception dengan pesan yang sesuai
      expect(
        () => repo.generateQuestions(tooFewWords),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Minimal 2 kata'),
          ),
        ),
      );
    });

    test('melempar Exception saat list kata kosong', () {
      // ── Arrange ──
      final emptyList = <WordItem>[];

      // ── Act & Assert ──
      expect(() => repo.generateQuestions(emptyList), throwsException);
    });

    test('tipe soal adalah multipleChoice', () {
      // ── Arrange & Act ──
      final questions = repo.generateQuestions(sampleWords);

      // ── Assert ──
      for (final q in questions) {
        expect(q.type, equals(QuizType.multipleChoice));
      }
    });

    test('setiap soal memiliki wordId yang tidak kosong', () {
      // ── Arrange & Act ──
      final questions = repo.generateQuestions(sampleWords);

      // ── Assert ──
      for (final q in questions) {
        expect(q.wordId.isNotEmpty, isTrue);
      }
    });

    test(
      'soal EN→ID: questionText adalah kata Inggris, correctAnswer adalah terjemahan',
      () {
        // ── Arrange ──
        // Gunakan kata tunggal yang diketahui dan filter soal EN→ID
        final questions = repo.generateQuestions(sampleWords, count: 30);
        final enToIdQuestions = questions
            .where((q) => q.direction == QuizDirection.enToId)
            .toList();

        // ── Act & Assert ──
        // Verifikasi bahwa EN→ID: pertanyaan = kata EN, jawaban = terjemahan ID
        for (final q in enToIdQuestions) {
          final source = sampleWords.firstWhere((w) => w.id == q.wordId);
          expect(q.questionText, equals(source.word));
          expect(q.correctAnswer, equals(source.translation));
        }
      },
    );

    test(
      'soal ID→EN: questionText adalah terjemahan, correctAnswer adalah kata Inggris',
      () {
        // ── Arrange ──
        final questions = repo.generateQuestions(sampleWords, count: 30);
        final idToEnQuestions = questions
            .where((q) => q.direction == QuizDirection.idToEn)
            .toList();

        // ── Act & Assert ──
        for (final q in idToEnQuestions) {
          final source = sampleWords.firstWhere((w) => w.id == q.wordId);
          expect(q.questionText, equals(source.translation));
          expect(q.correctAnswer, equals(source.word));
        }
      },
    );
  });

  // ════════════════════════════════════════════════════════════
  // GROUP 2: evaluateSession()
  // Menguji fungsi evaluasi jawaban dan perhitungan skor
  // ════════════════════════════════════════════════════════════
  group('evaluateSession()', () {
    // ── Helper: buat soal dummy untuk evaluasi ──
    List<QuizQuestion> makeMockQuestions() {
      return [
        QuizQuestion(
          wordId: '1',
          questionText: 'cat',
          correctAnswer: 'kucing',
          options: ['kucing', 'anjing', 'berlari', 'bahagia'],
          direction: QuizDirection.enToId,
          type: QuizType.multipleChoice,
        ),
        QuizQuestion(
          wordId: '2',
          questionText: 'anjing',
          correctAnswer: 'dog',
          options: ['cat', 'dog', 'run', 'happy'],
          direction: QuizDirection.idToEn,
          type: QuizType.multipleChoice,
        ),
        QuizQuestion(
          wordId: '3',
          questionText: 'run',
          correctAnswer: 'berlari',
          options: ['berlari', 'kucing', 'gajah', 'cantik'],
          direction: QuizDirection.enToId,
          type: QuizType.multipleChoice,
        ),
        QuizQuestion(
          wordId: '4',
          questionText: 'happy',
          correctAnswer: 'bahagia',
          options: ['anjing', 'bahagia', 'berenang', 'dengan cepat'],
          direction: QuizDirection.enToId,
          type: QuizType.multipleChoice,
        ),
      ];
    }

    test('skor 100% ketika semua jawaban benar', () {
      // ── Arrange ──
      final questions = makeMockQuestions();
      // Semua jawaban benar
      final answers = {
        '1': 'kucing',
        '2': 'dog',
        '3': 'berlari',
        '4': 'bahagia',
      };

      // ── Act ──
      final session = repo.evaluateSession(questions, answers);

      // ── Assert ──
      expect(session.correctCount, equals(4));
      expect(session.totalQuestions, equals(4));
      expect(session.scorePercent, equals(100.0));
    });

    test('skor 0% ketika semua jawaban salah', () {
      // ── Arrange ──
      final questions = makeMockQuestions();
      // Semua jawaban salah
      final answers = {
        '1': 'anjing', // salah, seharusnya 'kucing'
        '2': 'cat', // salah, seharusnya 'dog'
        '3': 'gajah', // salah, seharusnya 'berlari'
        '4': 'berenang', // salah, seharusnya 'bahagia'
      };

      // ── Act ──
      final session = repo.evaluateSession(questions, answers);

      // ── Assert ──
      expect(session.correctCount, equals(0));
      expect(session.scorePercent, equals(0.0));
    });

    test('skor 50% ketika setengah jawaban benar', () {
      // ── Arrange ──
      final questions = makeMockQuestions();
      final answers = {
        '1': 'kucing', // ✓ benar
        '2': 'dog', // ✓ benar
        '3': 'gajah', // ✗ salah
        '4': 'berenang', // ✗ salah
      };

      // ── Act ──
      final session = repo.evaluateSession(questions, answers);

      // ── Assert ──
      expect(session.correctCount, equals(2));
      expect(session.scorePercent, equals(50.0));
    });

    test('totalQuestions sesuai jumlah soal yang dievaluasi', () {
      // ── Arrange ──
      final questions = makeMockQuestions();
      final answers = {
        '1': 'kucing',
        '2': 'dog',
        '3': 'berlari',
        '4': 'bahagia',
      };

      // ── Act ──
      final session = repo.evaluateSession(questions, answers);

      // ── Assert ──
      expect(session.totalQuestions, equals(questions.length));
    });

    test('wrongWordIds berisi id kata yang dijawab salah', () {
      // ── Arrange ──
      final questions = makeMockQuestions();
      final answers = {
        '1': 'kucing', // ✓ benar
        '2': 'cat', // ✗ salah — wordId '2'
        '3': 'berlari', // ✓ benar
        '4': 'berenang', // ✗ salah — wordId '4'
      };

      // ── Act ──
      final session = repo.evaluateSession(questions, answers);

      // ── Assert ──
      expect(session.wrongWordIds, containsAll(['2', '4']));
      expect(session.wrongWordIds.length, equals(2));
    });

    test('wrongWordIds kosong jika semua jawaban benar', () {
      // ── Arrange ──
      final questions = makeMockQuestions();
      final answers = {
        '1': 'kucing',
        '2': 'dog',
        '3': 'berlari',
        '4': 'bahagia',
      };

      // ── Act ──
      final session = repo.evaluateSession(questions, answers);

      // ── Assert ──
      expect(session.wrongWordIds, isEmpty);
    });

    test('jawaban kosong (tidak menjawab) dihitung sebagai salah', () {
      // ── Arrange ──
      final questions = makeMockQuestions();
      // wordId '1' tidak dijawab (tidak ada di map)
      final answers = {'2': 'dog', '3': 'berlari', '4': 'bahagia'};

      // ── Act ──
      final session = repo.evaluateSession(questions, answers);

      // ── Assert ──
      // 3 benar dari 4 soal
      expect(session.correctCount, equals(3));
      expect(session.wrongWordIds, contains('1'));
    });

    test('perbandingan jawaban tidak case-sensitive', () {
      // ── Arrange ──
      final questions = makeMockQuestions();
      // Jawaban dengan huruf kapital berbeda
      final answers = {
        '1': 'KUCING', // huruf besar semua
        '2': 'Dog', // huruf besar di awal
        '3': 'berlari', // normal
        '4': 'BAHAGIA', // huruf besar semua
      };

      // ── Act ──
      final session = repo.evaluateSession(questions, answers);

      // ── Assert ──
      // Semua harus dihitung benar meski case berbeda
      expect(session.correctCount, equals(4));
    });

    test('session memiliki id yang tidak kosong', () {
      // ── Arrange ──
      final questions = makeMockQuestions();
      final answers = {
        '1': 'kucing',
        '2': 'dog',
        '3': 'berlari',
        '4': 'bahagia',
      };

      // ── Act ──
      final session = repo.evaluateSession(questions, answers);

      // ── Assert ──
      expect(session.id.isNotEmpty, isTrue);
    });

    test('session.answers berisi semua hasil per soal', () {
      // ── Arrange ──
      final questions = makeMockQuestions();
      final answers = {
        '1': 'kucing',
        '2': 'cat',
        '3': 'berlari',
        '4': 'berenang',
      };

      // ── Act ──
      final session = repo.evaluateSession(questions, answers);

      // ── Assert ──
      // Jumlah QuizAnswer harus sama dengan jumlah soal
      expect(session.answers.length, equals(questions.length));
    });

    test('QuizAnswer menyimpan jawaban pengguna dengan benar', () {
      // ── Arrange ──
      final questions = makeMockQuestions();
      final answers = {
        '1': 'anjing',
        '2': 'dog',
        '3': 'berlari',
        '4': 'bahagia',
      };

      // ── Act ──
      final session = repo.evaluateSession(questions, answers);

      // ── Assert ──
      // Cek jawaban untuk soal pertama (wordId '1')
      final firstAnswer = session.answers.firstWhere((a) => a.wordId == '1');
      expect(firstAnswer.userAnswer, equals('anjing')); // yang diketik user
      expect(firstAnswer.correctAnswer, equals('kucing')); // jawaban benar
      expect(firstAnswer.isCorrect, isFalse); // salah
    });
  });
}
