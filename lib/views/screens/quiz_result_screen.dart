import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/quiz_models.dart';
import '../../router/app_router.dart';

// ── VIEW: QuizResultScreen ─────────────────────────────────────
// Menampilkan ringkasan hasil sesi Treasure Check!
class QuizResultScreen extends StatelessWidget {
  final QuizSession session;
  const QuizResultScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final score = session.scorePercent;
    final emoji = score >= 80 ? '🏆' : score >= 60 ? '👍' : '💪';
    final msg   = score >= 80
        ? 'Luar biasa!'
        : score >= 60
            ? 'Bagus! Terus semangat!'
            : 'Terus berlatih!';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Kuis'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            // ── Score card ──
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 56)),
                    const SizedBox(height: 8),
                    Text(
                      msg,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    // Score ring
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 110, height: 110,
                          child: CircularProgressIndicator(
                            value: score / 100,
                            strokeWidth: 10,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              score >= 80
                                  ? Colors.green
                                  : score >= 60
                                      ? Colors.orange
                                      : Colors.red,
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              '${score.round()}%',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text('Skor',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ScoreStat(
                          label: 'Benar',
                          value: session.correctCount,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 24),
                        _ScoreStat(
                          label: 'Salah',
                          value: session.totalQuestions -
                              session.correctCount,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 24),
                        _ScoreStat(
                          label: 'Total',
                          value: session.totalQuestions,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Kata yang salah ──
            if (session.wrongWordIds.isNotEmpty) ...[
              const Text(
                'Perlu dipelajari lagi:',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...session.answers
                  .where((a) => !a.isCorrect)
                  .map((a) => _WrongAnswerCard(answer: a)),
              const SizedBox(height: 12),
            ],

            // ── Buttons ──
            ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.quiz),
              icon: const Icon(Icons.refresh),
              label: const Text('Kuis Lagi'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.home),
              icon: const Icon(Icons.home_outlined),
              label: const Text('Kembali ke Beranda'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreStat extends StatelessWidget {
  final String label;
  final int    value;
  final Color  color;
  const _ScoreStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _WrongAnswerCard extends StatelessWidget {
  final QuizAnswer answer;
  const _WrongAnswerCard({required this.answer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.cancel_outlined,
                color: Colors.red, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jawabanmu: ${answer.userAnswer}',
                    style: const TextStyle(
                        fontSize: 13, color: Colors.red),
                  ),
                  Text(
                    'Jawaban benar: ${answer.correctAnswer}',
                    style: const TextStyle(
                        fontSize: 13,
                        color: Colors.green,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
