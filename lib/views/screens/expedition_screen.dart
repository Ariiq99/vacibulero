import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/expedition_viewmodel.dart';
import '../../models/expedition_models.dart';
import '../../router/app_router.dart';

class ExpeditionScreen extends StatelessWidget {
  const ExpeditionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Tiga tingkatan kesulitan: Beginner, Intermediate, Advanced
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            'Word Expedition 🗺️',
            style: TextStyle(
                color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF1A1A1A)),
            onPressed: () => context.go(AppRoutes.home),
          ),
          bottom: const TabBar(
            labelColor: Color(0xFF2196F3),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF2196F3),
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Beginner 🌱'),
              Tab(text: 'Intermediate 🚀'),
              Tab(text: 'Advanced 🔥'),
            ],
          ),
        ),
        body: Consumer<ExpeditionViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (vm.error != null) {
              return Center(
                  child: Text('Error: ${vm.error}',
                      style: const TextStyle(color: Colors.red)));
            }
            if (vm.themes.isEmpty) {
              return const Center(child: Text('Belum ada konten ekspedisi.'));
            }

            return TabBarView(
              children: [
                _buildDifficultyContent(context, vm, 'Beginner'),
                _buildDifficultyContent(context, vm, 'Intermediate'),
                _buildDifficultyContent(context, vm, 'Advanced'),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDifficultyContent(
      BuildContext context, ExpeditionViewModel vm, String targetDifficulty) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: vm.themes.length,
      itemBuilder: (ctx, i) {
        final theme = vm.themes[i];

        // Cari paket kesulitan yang cocok di dalam tema ini
        final diffData = theme.difficulties.firstWhere(
          (d) => d.difficulty.toLowerCase() == targetDifficulty.toLowerCase(),
          orElse: () =>
              ExpeditionDifficulty(difficulty: targetDifficulty, levels: []),
        );

        if (diffData.levels.isEmpty) {
          return const SizedBox
              .shrink(); // Sembunyikan tema jika kesulitan terkait belum ada datanya
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 20),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey[200]!, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(theme.emoji, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 12),
                    Text(
                      theme.name,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Menggunakan GridView untuk Level Buttons agar simetris & hemat ruang
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: diffData.levels.length,
                  itemBuilder: (context, lvlIdx) {
                    final lvl = diffData.levels[lvlIdx];
                    final locked = vm.isLevelLocked(theme.id, lvl.level);
                    final completed = vm.isLevelCompleted(theme.id, lvl.level);
                    final progress =
                        vm.levelProgress(theme.id, lvl.level, lvl.words.length);

                    return _LevelButton(
                      level: lvl.level,
                      locked: locked,
                      completed: completed,
                      progress: progress,
                      wordCount: lvl.words.length,
                      onTap: locked
                          ? null
                          : () => context.go(
                                AppRoutes.flipCard,
                                extra: {
                                  'theme': theme,
                                  'level': lvl.level,
                                  'words': lvl.words
                                },
                              ),
                    );
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LevelButton extends StatelessWidget {
  final int level;
  final bool locked, completed;
  final double progress;
  final int wordCount;
  final VoidCallback? onTap;

  const _LevelButton({
    required this.level,
    required this.locked,
    required this.completed,
    required this.progress,
    required this.wordCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    IconData icon;

    if (locked) {
      bg = Colors.grey[100]!;
      fg = Colors.grey[400]!;
      icon = Icons.lock_outline_rounded;
    } else if (completed) {
      bg = Colors.green[50]!;
      fg = Colors.green[700]!;
      icon = Icons.check_circle_rounded;
    } else {
      bg = const Color(0xFFE3F2FD);
      fg = const Color(0xFF1E88E5);
      icon = Icons.play_arrow_rounded;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: fg, size: 22),
            const SizedBox(height: 4),
            Text(
              'Lvl $level',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, color: fg),
            ),
            Text(
              '$wordCount Kata',
              style: TextStyle(
                  fontSize: 10,
                  color: fg.withOpacity(0.65),
                  fontWeight: FontWeight.w500),
            ),
            if (!locked && !completed && progress > 0) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 3.5,
                    backgroundColor: Colors.white,
                    color: fg,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
