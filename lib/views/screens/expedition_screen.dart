import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/expedition_viewmodel.dart';
import '../../models/expedition_models.dart';
import '../../router/app_router.dart';

// ── VIEW: ExpeditionScreen ─────────────────────────────────────
// Menampilkan daftar tema Word Expedition beserta level-levelnya.
class ExpeditionScreen extends StatelessWidget {
  const ExpeditionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Expedition 🗺️'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: Consumer<ExpeditionViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.error != null) {
            return Center(child: Text('Error: ${vm.error}'));
          }
          if (vm.themes.isEmpty) {
            return const Center(child: Text('Belum ada konten ekspedisi.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vm.themes.length,
            itemBuilder: (ctx, i) =>
                _ThemeCard(theme: vm.themes[i], vm: vm),
          );
        },
      ),
    );
  }
}

// ── Theme Card ──
class _ThemeCard extends StatelessWidget {
  final ExpeditionTheme theme;
  final ExpeditionViewModel vm;
  const _ThemeCard({required this.theme, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header tema ──
            Row(
              children: [
                Text(theme.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Text(
                  theme.name,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // ── Level buttons ──
            Row(
              children: theme.levels.map((lvl) {
                final locked    = vm.isLevelLocked(theme.id, lvl.level);
                final completed = vm.isLevelCompleted(theme.id, lvl.level);
                final progress  = vm.levelProgress(
                    theme.id, lvl.level, lvl.words.length);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _LevelButton(
                      level:     lvl.level,
                      locked:    locked,
                      completed: completed,
                      progress:  progress,
                      wordCount: lvl.words.length,
                      onTap: locked
                          ? null
                          : () => context.go(
                                AppRoutes.flipCard,
                                extra: {
                                  'theme': theme,
                                  'level': lvl.level,
                                },
                              ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Level Button ──
class _LevelButton extends StatelessWidget {
  final int       level;
  final bool      locked, completed;
  final double    progress;
  final int       wordCount;
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
    Color bg;
    Color fg;
    IconData icon;

    if (locked) {
      bg   = Colors.grey.shade100;
      fg   = Colors.grey.shade400;
      icon = Icons.lock_outline;
    } else if (completed) {
      bg   = Colors.green.shade50;
      fg   = Colors.green.shade700;
      icon = Icons.check_circle_outline;
    } else {
      bg   = const Color(0xFFE8F0FE);
      fg   = const Color(0xFF1A73E8);
      icon = Icons.play_circle_outline;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: fg, size: 22),
            const SizedBox(height: 4),
            Text(
              'Level $level',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, color: fg),
            ),
            Text(
              '$wordCount kata',
              style: TextStyle(fontSize: 10, color: fg.withOpacity(0.7)),
            ),
            if (!locked && !completed && progress > 0) ...[
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: Colors.white,
                  color: fg,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
