import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/expedition_models.dart';
import '../../viewmodels/expedition_viewmodel.dart';
import '../../router/app_router.dart';

class FlipCardScreen extends StatefulWidget {
  final ExpeditionTheme theme;
  const FlipCardScreen({super.key, required this.theme});

  @override
  State<FlipCardScreen> createState() => _FlipCardScreenState();
}

class _FlipCardScreenState extends State<FlipCardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpeditionViewModel>().startSession(
            widget.theme,
            'Beginner',
            1,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ExpeditionViewModel>();
    final currentWord = vm.currentCard;
    final total = vm.totalCards;
    final index = vm.currentIndex;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          '${widget.theme.emoji} ${widget.theme.name}',
          style: const TextStyle(
              color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1A1A1A)),
          onPressed: () => context.go(AppRoutes.expedition),
        ),
      ),
      body: currentWord == null
          ? _buildCompletionScreen(context, vm)
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kata ${index + 1} dari $total',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, color: Colors.grey),
                      ),
                      Text(
                        'Hafal: ${vm.learnedCount}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: total > 0 ? (index / total) : 0,
                    backgroundColor: Colors.grey[200],
                    color: Colors.blue,
                    minHeight: 6,
                  ),
                  const SizedBox(height: 40),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => vm.flipCard(),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: vm.isFlipped ? Colors.blue[50] : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: vm.isFlipped
                                ? Colors.blue[200]!
                                : Colors.grey[200]!,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              vm.isFlipped ? 'ARTI KATA' : 'KOSAKATA',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: vm.isFlipped
                                    ? Colors.blue[700]
                                    : Colors.grey,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              vm.isFlipped
                                  ? currentWord.meaning
                                  : currentWord.word,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: vm.isFlipped
                                    ? Colors.blue[900]
                                    : const Color(0xFF1A1A1A),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            if (!vm.isFlipped)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  currentWord.clue,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF4A4A4A),
                                      fontStyle: FontStyle.italic),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            const SizedBox(height: 32),
                            Icon(Icons.touch_app_rounded,
                                color: Colors.grey[400], size: 20),
                            const SizedBox(height: 4),
                            Text(
                              'Ketuk kartu untuk membalik',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[400]),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => vm.markAsUnknown(),
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.red),
                          label: const Text('Belum Tahu',
                              style: TextStyle(color: Colors.red)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => vm.markAsLearned(),
                          icon: const Icon(Icons.check_rounded,
                              color: Colors.white),
                          label: const Text('Sudah Hafal',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCompletionScreen(BuildContext context, ExpeditionViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 24),
            const Text(
              'Ekspedisi Selesai!',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 8),
            Text(
              'Kamu telah meninjau seluruh kosakata pada paket level ini.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.expedition),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Kembali ke Peta Ekspedisi',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}
