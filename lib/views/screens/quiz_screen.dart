import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/quiz_viewmodel.dart';
import '../../viewmodels/treasury_viewmodel.dart';
import '../../router/app_router.dart';

// ── VIEW: QuizScreen ───────────────────────────────────────────
// Halaman Treasure Check! — sesi kuis pilihan ganda.
class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<QuizViewModel, TreasuryViewModel>(
      builder: (context, quizVm, treasuryVm, _) {
        // ── Idle: belum mulai ──
        if (quizVm.status == QuizStatus.idle) {
          return _IdlePage(
            wordCount: treasuryVm.totalWords,
            onStart: () => quizVm.startQuiz(treasuryVm.allWords),
            onBack:  () => context.go(AppRoutes.home),
          );
        }

        // ── Selesai: tampilkan hasil ──
        if (quizVm.isFinished && quizVm.session != null) {
          // Navigasi ke result screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(AppRoutes.quizResult, extra: quizVm.session!);
            quizVm.reset();
          });
          return const SizedBox.shrink();
        }

        // ── In Progress ──
        final q = quizVm.currentQuestion;
        if (q == null) return const SizedBox.shrink();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Treasure Check! ✅'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () { quizVm.reset(); context.go(AppRoutes.home); },
            ),
          ),
          body: Column(
            children: [
              // ── Progress bar ──
              LinearProgressIndicator(
                value: quizVm.progress,
                minHeight: 5,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Soal ${quizVm.currentIdx + 1} dari ${quizVm.totalQ}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    // Arah soal badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        q.direction.name == 'enToId'
                            ? 'EN → ID'
                            : 'ID → EN',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF1A73E8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Question ──
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Pertanyaan
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A73E8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              q.direction.name == 'enToId'
                                  ? 'Apa arti kata ini?'
                                  : 'Apa kata Inggrisnya?',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              q.questionText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Pilihan jawaban
                      ...q.options.map((opt) {
                        final selected = quizVm.selected;
                        Color? bg;
                        Color? fg;
                        IconData? trailIcon;

                        if (selected != null) {
                          if (opt == q.correctAnswer) {
                            bg       = Colors.green.shade50;
                            fg       = Colors.green.shade700;
                            trailIcon = Icons.check_circle;
                          } else if (opt == selected) {
                            bg       = Colors.red.shade50;
                            fg       = Colors.red.shade700;
                            trailIcon = Icons.cancel;
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            child: Material(
                              color: bg ?? const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                onTap: selected == null
                                    ? () => quizVm.selectAnswer(opt)
                                    : null,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: bg != null
                                          ? (fg ?? Colors.grey)
                                          : Colors.grey.shade200,
                                      width: bg != null ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          opt,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: fg ?? Colors.black87,
                                          ),
                                        ),
                                      ),
                                      if (trailIcon != null)
                                        Icon(trailIcon,
                                            color: fg, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // ── Next button (muncul setelah menjawab) ──
              AnimatedOpacity(
                opacity: quizVm.selected != null ? 1 : 0,
                duration: const Duration(milliseconds: 250),
                child: IgnorePointer(
                  ignoring: quizVm.selected == null,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: ElevatedButton(
                      onPressed: quizVm.nextQuestion,
                      child: Text(
                        quizVm.currentIdx < quizVm.totalQ - 1
                            ? 'Soal Berikutnya →'
                            : 'Lihat Hasil',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Idle Page ──
class _IdlePage extends StatelessWidget {
  final int wordCount;
  final VoidCallback onStart, onBack;
  const _IdlePage({
    required this.wordCount,
    required this.onStart,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final canStart = wordCount >= 4;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treasure Check! ✅'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✅', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              const Text(
                'Treasure Check!',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Uji hafalan kata-kata di Treasury kamu',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: canStart
                      ? const Color(0xFFE8F0FE)
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      canStart ? Icons.storage : Icons.warning_amber,
                      color: canStart
                          ? const Color(0xFF1A73E8)
                          : Colors.orange,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        canStart
                            ? '$wordCount kata siap diuji'
                            : 'Minimal 4 kata di Treasury.\n'
                              'Sekarang ada $wordCount kata.',
                        style: TextStyle(
                          color: canStart
                              ? const Color(0xFF1A73E8)
                              : Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: canStart ? onStart : null,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Mulai Kuis',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
