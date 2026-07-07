import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/add_word_viewmodel.dart';
import '../../viewmodels/treasury_viewmodel.dart';
import '../../models/word_item.dart';
import '../../repositories/dictionary_repository.dart';
import '../../services/app_theme.dart';
import '../../router/app_router.dart';

class AddWordScreen extends StatefulWidget {
  const AddWordScreen({super.key});
  @override
  State<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    context.read<AddWordViewModel>().reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaciColors.surface,
      appBar: AppBar(
        title: const Text('Tambah Kata'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.treasury),
        ),
      ),
      body: Column(
        children: [
          // ── Search bar ──
          Container(
            color: VaciColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ketik kata Inggris...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white70,
                      ),
                    ),
                    onSubmitted: (_) => _lookup(),
                  ),
                ),
                const SizedBox(width: 10),
                Consumer<AddWordViewModel>(
                  builder: (_, vm, __) => ElevatedButton(
                    onPressed: vm.isLoading ? null : _lookup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: VaciColors.primary,
                      minimumSize: const Size(70, 52),
                      disabledBackgroundColor: Colors.white54,
                    ),
                    child: vm.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: VaciColors.primary,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Cari',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
            ),
          ),

          // ── Result area ──
          Expanded(
            child: Consumer<AddWordViewModel>(
              builder: (context, vm, _) {
                if (vm.status == AddWordStatus.error) {
                  return _ErrorView(message: vm.error ?? 'Terjadi kesalahan.');
                }
                if (!vm.hasResult) return const _IdleView();

                final r = vm.result!;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ── Result card ──
                      VaciCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Word + type
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r.word,
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w800,
                                          color: VaciColors.dark,
                                        ),
                                      ),
                                      if (r.phonetic.isNotEmpty)
                                        Text(
                                          r.phonetic,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: VaciColors.textSecondary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                WordTypeBadge(
                                  r.wordType.name[0].toUpperCase() +
                                      r.wordType.name.substring(1),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            const Divider(color: VaciColors.divider),
                            const SizedBox(height: 14),

                            // Terjemahan
                            _InfoSection(
                              icon: Icons.translate,
                              color: VaciColors.primary,
                              label: 'Terjemahan (Bahasa Indonesia)',
                              value: r.translation,
                              bold: true,
                            ),
                            const SizedBox(height: 14),

                            // Definisi ID
                            _InfoSection(
                              icon: Icons.menu_book_outlined,
                              color: VaciColors.success,
                              label: 'Definisi (Bahasa Indonesia)',
                              value: r.definitionID.isNotEmpty
                                  ? r.definitionID
                                  : r.definitionEN,
                            ),
                            const SizedBox(height: 14),

                            // Definisi EN (toggle)
                            if (r.definitionEN.isNotEmpty &&
                                r.definitionID.isNotEmpty)
                              _InfoSection(
                                icon: Icons.language,
                                color: VaciColors.textSecondary,
                                label: 'Definisi (English)',
                                value: r.definitionEN,
                                muted: true,
                              ),

                            // Contoh kalimat
                            if (r.example.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              _InfoSection(
                                icon: Icons.format_quote,
                                color: VaciColors.gold,
                                label: 'Contoh Kalimat',
                                value: '"${r.example}"',
                                italic: true,
                              ),
                            ],

                            // Contoh kalimat terjemahan
                            if (r.exampleID.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              _InfoSection(
                                icon: Icons.format_quote_outlined,
                                color: VaciColors.goldDark,
                                label: 'Terjemahan Contoh',
                                value: '"${r.exampleID}"',
                                italic: true,
                                muted: true,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Save button ──
                      VaciButton(
                        label: 'Simpan ke Treasury 🏴',
                        icon: Icons.save_outlined,
                        onPressed: () => _saveWord(context, vm),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          _ctrl.clear();
                          vm.reset();
                        },
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Cari kata lain'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _lookup() {
    final word = _ctrl.text.trim();
    if (word.isEmpty) return;
    context.read<AddWordViewModel>().lookupWord(word);
  }

  Future<void> _saveWord(BuildContext ctx, AddWordViewModel vm) async {
    try {
      final r = vm.result!;
      final item = WordItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        word: r.word,
        translation: r.translation,
        wordType: r.wordType,
        definitionEN: r.definitionEN,
        definitionID: r.definitionID,
        example: r.example,
        exampleID: r.exampleID,
        phonetic: r.phonetic,
        addedAt: DateTime.now(),
      );
      await ctx.read<TreasuryViewModel>().addWord(item);
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text('"${item.word}" berhasil disimpan ke Treasury! ✅'),
            backgroundColor: VaciColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        ctx.go(AppRoutes.treasury);
      }
    } catch (e) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: VaciColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// ── Info Section ──
class _InfoSection extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label, value;
  final bool bold, italic, muted;

  const _InfoSection({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.bold = false,
    this.italic = false,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: muted ? VaciColors.textSecondary : color,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                  fontStyle: italic ? FontStyle.italic : FontStyle.normal,
                  color: muted
                      ? VaciColors.textSecondary
                      : VaciColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IdleView extends StatelessWidget {
  const _IdleView();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: VaciColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text('🔍', style: TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ketik kata dan tekan Cari',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: VaciColors.dark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Definisi akan muncul dalam Bahasa Indonesia',
            style: TextStyle(fontSize: 12, color: VaciColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: VaciColors.errorLight,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(
                child: Text('😕', style: TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Kata tidak ditemukan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: VaciColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
