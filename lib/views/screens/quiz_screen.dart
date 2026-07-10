import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/quiz_models.dart';
import '../../viewmodels/quiz_viewmodel.dart';
import '../../router/app_router.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final TextEditingController _answerController = TextEditingController();
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizViewModel>().loadQuestions();
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _submitAnswer(QuizViewModel vm, String answer) {
    if (answer.trim().isEmpty) return;
    vm.answerQuestion(answer);
    _answerController.clear();
    _selectedOption = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<QuizViewModel>();
    final question = vm.currentQuestion;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Treasure Check!'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed(AppRoutes.home),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Progress ──
            if (vm.totalQuestions > 0) ...[
              Text(
                'Soal ${vm.currentIndex + 1} dari ${vm.totalQuestions}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (vm.currentIndex + 1) / vm.totalQuestions,
                backgroundColor: Colors.grey[200],
                color: Colors.orange,
                minHeight: 8,
              ),
              const SizedBox(height: 24),
            ],

            // ── Isi Konten ──
            if (vm.isFinished) ...[
              _buildResult(vm),
            ] else if (question != null) ...[
              _buildQuestion(context, vm, question),
            ] else if (vm.totalQuestions == 0) ...[
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 60, color: Colors.orange),
                    SizedBox(height: 16),
                    Text(
                      'Minimal 4 kata di Treasury!',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Tambahkan kata dulu di Word Treasury'),
                  ],
                ),
              ),
            ] else ...[
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }

  // ── Widget Soal ──
  Widget _buildQuestion(
    BuildContext context,
    QuizViewModel vm,
    QuizQuestion question,
  ) {
    final isMultipleChoice = question.type == QuizType.multipleChoice;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pertanyaan
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Text(
              question.questionText,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),

          // ── CLUE: Contoh Kalimat ──
          if (question.exampleSentence != null &&
              question.exampleSentence!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.amber.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '💡 Contoh: "${question.exampleSentence}"',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),

          // Input Jawaban (Multiple Choice atau Text)
          if (isMultipleChoice) ...[
            ...question.options.map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: _selectedOption,
                onChanged: (value) {
                  setState(() => _selectedOption = value);
                },
              );
            }).toList(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedOption != null
                    ? () => _submitAnswer(vm, _selectedOption!)
                    : null,
                child: const Text('Jawab'),
              ),
            ),
          ] else ...[
            TextField(
              controller: _answerController,
              decoration: InputDecoration(
                hintText: 'Ketik jawaban...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _submitAnswer(vm, _answerController.text),
                ),
              ),
              onSubmitted: (value) => _submitAnswer(vm, value),
            ),
          ],
        ],
      ),
    );
  }

  // ── Widget Hasil ──
  Widget _buildResult(QuizViewModel vm) {
    final score = vm.correctCount / vm.totalQuestions * 100;

    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              score >= 80 ? Icons.celebration : Icons.school,
              size: 80,
              color: score >= 80 ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              'Selesai! 🎉',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Benar: ${vm.correctCount} dari ${vm.totalQuestions}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              'Akurasi: ${score.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: score >= 80 ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  vm.reset();
                  vm.loadQuestions();
                },
                child: const Text('Ulangi Kuis'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.goNamed(AppRoutes.home),
              child: const Text('Kembali ke Beranda'),
            ),
          ],
        ),
      ),
    );
  }
}
