import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/add_word_viewmodel.dart';
import '../../viewmodels/treasury_viewmodel.dart';
import '../../router/app_router.dart';

// ── VIEW: AddWordScreen ────────────────────────────────────────
// Halaman pencarian dan penyimpanan kata baru ke Word Treasury.
// Menggunakan Consumer<AddWordViewModel> untuk state lookup,
// dan context.read<TreasuryViewModel>() untuk menyimpan kata.
class AddWordScreen extends StatefulWidget {
  const AddWordScreen({super.key});
  @override
  State<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    // Reset ViewModel saat keluar halaman
    context.read<AddWordViewModel>().reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Kata'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.treasury),
        ),
      ),
      body: Column(
        children: [
          // ── Search area ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      hintText: 'Ketik kata Inggris...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _lookup(),
                  ),
                ),
                const SizedBox(width: 10),
                Consumer<AddWordViewModel>(
                  builder: (_, vm, __) => ElevatedButton(
                    onPressed: vm.isLoading ? null : _lookup,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(70, 50)),
                    child: vm.isLoading
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Cari'),
                  ),
                ),
              ],
            ),
          ),

          // ── Result area ──
          // Consumer listen ke AddWordViewModel
          Expanded(
            child: Consumer<AddWordViewModel>(
              builder: (context, vm, _) {
                if (vm.status == AddWordStatus.error) {
                  return _ErrorState(message: vm.error ?? 'Terjadi kesalahan.');
                }
                if (!vm.hasResult) {
                  return const _IdleState();
                }
                final r = vm.result!;
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // ── Result card ──
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(r.word,
                                      style: const TextStyle(
                                          fontSize: 24, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 10),
                                  _TypeBadge(r.wordType.name),
                                ],
                              ),
                              if (r.phonetic.isNotEmpty)
                                Text(r.phonetic,
                                    style: const TextStyle(fontSize: 13, color: Colors.grey)),
                              const Divider(height: 20),
                              _InfoRow('Terjemahan (ID)', r.translation),
                              const SizedBox(height: 8),
                              _InfoRow('Definisi (EN)', r.definition),
                              if (r.example.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                _InfoRow('Contoh kalimat', '"${r.example}"'),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Save button ──
                      ElevatedButton.icon(
                        onPressed: () => _saveWord(context, vm),
                        icon: const Icon(Icons.save),
                        label: const Text('Simpan ke Treasury'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () { _controller.clear(); vm.reset(); },
                        child: const Text('Cari kata lain'),
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
    final word = _controller.text.trim();
    if (word.isEmpty) return;
    // context.read → panggil action tanpa trigger rebuild
    context.read<AddWordViewModel>().lookupWord(word);
  }

  Future<void> _saveWord(BuildContext ctx, AddWordViewModel vm) async {
    try {
      final item = vm.buildWordItem();
      // Simpan ke TreasuryViewModel
      await ctx.read<TreasuryViewModel>().addWord(item);
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text('"${item.word}" berhasil ditambahkan ke Treasury! ✅'),
            backgroundColor: Colors.green,
          ),
        );
        ctx.go(AppRoutes.treasury);
      }
    } catch (e) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, height: 1.5)),
      ],
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge(this.type);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(type, style: const TextStyle(fontSize: 12, color: Color(0xFF1A73E8), fontWeight: FontWeight.bold)),
    );
  }
}

class _IdleState extends StatelessWidget {
  const _IdleState();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🔍', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text('Ketik kata dan tekan Cari', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
