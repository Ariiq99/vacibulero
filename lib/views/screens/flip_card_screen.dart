import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/expedition_viewmodel.dart';
import '../../viewmodels/treasury_viewmodel.dart';
import '../../models/expedition_models.dart';
import '../../router/app_router.dart';

// ── VIEW: FlipCardScreen ───────────────────────────────────────
// Sesi belajar dengan flip card untuk satu level Word Expedition.
class FlipCardScreen extends StatefulWidget {
  final ExpeditionTheme theme;
  final int             level;
  const FlipCardScreen({super.key, required this.theme, required this.level});

  @override
  State<FlipCardScreen> createState() => _FlipCardScreenState();
}

class _FlipCardScreenState extends State<FlipCardScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _animCtrl;
  late Animation<double>    _anim;

  @override
  void initState() {
    super.initState();
    // Mulai sesi di ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpeditionViewModel>()
          .startSession(widget.theme, widget.level);
    });

    // Setup animasi flip
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _anim = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _handleFlip(ExpeditionViewModel vm) {
    vm.flipCard();
    if (vm.isFlipped) {
      _animCtrl.forward();
    } else {
      _animCtrl.reverse();
    }
  }

  void _handleFlipReset() {
    _animCtrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.theme.emoji} ${widget.theme.name} — Level ${widget.level}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go(AppRoutes.expedition),
        ),
      ),
      body: Consumer<ExpeditionViewModel>(
        builder: (context, vm, _) {
          // ── Sesi selesai ──
          if (vm.isSessionDone) {
            return _SessionSummary(
              learned: vm.learnedCount,
              unknown: vm.unknownCount,
              total:   vm.totalCards,
              onFinish: () => context.go(AppRoutes.expedition),
            );
          }

          final card = vm.currentCard;
          if (card == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // ── Progress bar ──
              LinearProgressIndicator(
                value: vm.totalCards > 0
                    ? vm.currentIndex / vm.totalCards
                    : 0,
                minHeight: 4,
              ),

              // ── Counter ──
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${vm.currentIndex + 1} / ${vm.totalCards}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 16, color: Colors.green),
                        Text(' ${vm.learnedCount}',
                            style: const TextStyle(color: Colors.green)),
                        const SizedBox(width: 12),
                        const Icon(Icons.cancel_outlined,
                            size: 16, color: Colors.red),
                        Text(' ${vm.unknownCount}',
                            style: const TextStyle(color: Colors.red)),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Flip Card ──
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 8),
                  child: GestureDetector(
                    onTap: () => _handleFlip(vm),
                    child: AnimatedBuilder(
                      animation: _anim,
                      builder: (context, _) {
                        final angle = _anim.value;
                        final showBack = angle > pi / 2;

                        return Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(angle),
                          alignment: Alignment.center,
                          child: showBack
                              ? Transform(
                                  transform: Matrix4.identity()
                                    ..rotateY(pi),
                                  alignment: Alignment.center,
                                  child: _CardBack(card: card),
                                )
                              : _CardFront(card: card),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // ── Action buttons (muncul saat kartu dibalik) ──
              AnimatedOpacity(
                opacity: vm.isFlipped ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !vm.isFlipped,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: Row(
                      children: [
                        // Tombol Belum Hafal
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              vm.markAsUnknown();
                              _handleFlipReset();
                            },
                            icon: const Icon(Icons.close,
                                color: Colors.red),
                            label: const Text('Belum',
                                style: TextStyle(color: Colors.red)),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 52),
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Tombol Hafal
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final wordItem =
                                  await vm.markAsLearned();
                              _handleFlipReset();
                              // Auto-save ke Treasury jika belum ada
                              if (wordItem != null && context.mounted) {
                                final treasury =
                                    context.read<TreasuryViewModel>();
                                final exists = await treasury
                                    .wordExists(wordItem.word);
                                if (!exists) {
                                  try {
                                    await treasury.addWord(wordItem);
                                  } catch (_) {
                                    // abaikan jika sudah ada
                                  }
                                }
                              }
                            },
                            icon: const Icon(Icons.check),
                            label: const Text('Hafal ✓'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 52),
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Hint saat belum dibalik
              if (!vm.isFlipped)
                const Padding(
                  padding: EdgeInsets.only(bottom: 28),
                  child: Text(
                    'Ketuk kartu untuk melihat artinya',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── Card Front (kata EN) ──
class _CardFront extends StatelessWidget {
  final ExpeditionWord card;
  const _CardFront({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A73E8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A73E8).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card.word,
            style: const TextStyle(
              fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white,
            ),
          ),
          if (card.phonetic.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              card.phonetic,
              style: TextStyle(
                fontSize: 16, color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Ketuk untuk lihat arti',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card Back (arti + contoh) ──
class _CardBack extends StatelessWidget {
  final ExpeditionWord card;
  const _CardBack({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1A73E8), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              card.word,
              style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold,
                color: Color(0xFF1A73E8),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              card.translation,
              style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                card.wordType,
                style: const TextStyle(
                  fontSize: 12, color: Color(0xFF1A73E8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (card.example.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '"${card.example}"',
                style: const TextStyle(
                  fontSize: 13, color: Colors.grey,
                  fontStyle: FontStyle.italic, height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Session Summary ──
class _SessionSummary extends StatelessWidget {
  final int learned, unknown, total;
  final VoidCallback onFinish;
  const _SessionSummary({
    required this.learned,
    required this.unknown,
    required this.total,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (learned / total * 100).round() : 0;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              learned == total ? '🎉' : '📚',
              style: const TextStyle(fontSize: 56),
            ),
            const SizedBox(height: 12),
            Text(
              learned == total ? 'Level Selesai!' : 'Sesi Selesai!',
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SummaryBadge(
                    icon: Icons.check_circle_outline,
                    label: 'Hafal',
                    value: learned,
                    color: Colors.green),
                const SizedBox(width: 16),
                _SummaryBadge(
                    icon: Icons.cancel_outlined,
                    label: 'Belum',
                    value: unknown,
                    color: Colors.red),
                const SizedBox(width: 16),
                _SummaryBadge(
                    icon: Icons.percent,
                    label: 'Skor',
                    value: pct,
                    color: const Color(0xFF1A73E8),
                    suffix: '%'),
              ],
            ),
            const SizedBox(height: 8),
            if (learned > 0)
              Text(
                '$learned kata otomatis tersimpan ke Word Treasury ✅',
                style: const TextStyle(color: Colors.green, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: onFinish,
              child: const Text('Kembali ke Ekspedisi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryBadge extends StatelessWidget {
  final IconData icon;
  final String   label;
  final int      value;
  final Color    color;
  final String   suffix;
  const _SummaryBadge({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text('$value$suffix',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
