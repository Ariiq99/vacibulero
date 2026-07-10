import 'package:flutter/material.dart';
import '../../models/quiz_models.dart';

class QuizResultScreen extends StatelessWidget {
  final QuizSession? session;
  const QuizResultScreen({super.key, this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Kuis')),
      body: Center(
        child: session == null
            ? const Text('Tidak ada data sesi')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Skor: ${session!.scorePercent.toStringAsFixed(0)}%',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Benar: ${session!.correctCount} dari ${session!.totalQuestions}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kembali'),
                  ),
                ],
              ),
      ),
    );
  }
}
