import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/treasury_viewmodel.dart';
import '../../models/word_item.dart';
import '../../services/app_theme.dart';
import '../../router/app_router.dart';

class TreasuryScreen extends StatelessWidget {
  const TreasuryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaciColors.surface,
      appBar: AppBar(
        title: const Text('Word Treasury 🏴'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: Consumer<TreasuryViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              // ── Stats header ──
              _TreasuryHeader(vm: vm),
              // ── Search ──
              _SearchBar(vm: vm),
              // ── Filter chips ──
              _FilterRow(vm: vm),
              // ── List ──
              Expanded(
                child: vm.isEmpty
                    ? _EmptyState(onAdd: () => context.go(AppRoutes.addWord))
                    : vm.words.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak ada kata yang cocok.',
                          style: TextStyle(color: VaciColors.textSecondary),
                        ),
                      )
                    : _WordList(words: vm.words, vm: vm),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.addWord),
        icon: const Icon(Icons.add),
        label: const Text(
          'Tambah Kata',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: VaciColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

// ── Treasury Header dengan stats ──
class _TreasuryHeader extends StatelessWidget {
  final TreasuryViewModel vm;
  const _TreasuryHeader({required this.vm});

  @override
  Widget build(BuildContext context) {
    final stats = vm.stats;
    return Container(
      color: VaciColors.primary,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          // Total kata
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('📚', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${vm.totalWords} Kata',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'di Word Treasury kamu',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Stats per kategori
          Row(
            children: WordType.values
                .where((t) => t != WordType.other)
                .map(
                  (t) => Expanded(
                    child: _StatChip(
                      label: _short(t),
                      value: stats[t] ?? 0,
                      color: _color(t),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  String _short(WordType t) {
    switch (t) {
      case WordType.noun:
        return 'Noun';
      case WordType.verb:
        return 'Verb';
      case WordType.adjective:
        return 'Adj';
      case WordType.adverb:
        return 'Adv';
      default:
        return '';
    }
  }

  Color _color(WordType t) {
    switch (t) {
      case WordType.noun:
        return const Color(0xFF64B5F6);
      case WordType.verb:
        return const Color(0xFF81C784);
      case WordType.adjective:
        return const Color(0xFFFFB74D);
      case WordType.adverb:
        return const Color(0xFFCE93D8);
      default:
        return Colors.white;
    }
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

// ── Search Bar ──
class _SearchBar extends StatelessWidget {
  final TreasuryViewModel vm;
  const _SearchBar({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: TextField(
        onChanged: vm.search,
        decoration: InputDecoration(
          hintText: 'Cari kata...',
          prefixIcon: const Icon(Icons.search, color: VaciColors.textSecondary),
          suffixIcon: vm.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: vm.clearFilter,
                )
              : null,
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}

// ── Filter Chips ──
class _FilterRow extends StatelessWidget {
  final TreasuryViewModel vm;
  const _FilterRow({required this.vm});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _chip(context, null, 'Semua'),
          const SizedBox(width: 6),
          ...WordType.values
              .where((t) => t != WordType.other)
              .map(
                (t) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _chip(
                    context,
                    t,
                    t.name[0].toUpperCase() + t.name.substring(1),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, WordType? type, String label) {
    final active = vm.activeFilter == type && vm.searchQuery.isEmpty;
    return FilterChip(
      label: Text(label),
      selected: active,
      onSelected: (_) => vm.filterByType(type),
      selectedColor: VaciColors.primary,
      labelStyle: TextStyle(
        color: active ? Colors.white : VaciColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      backgroundColor: Colors.white,
      side: BorderSide(color: active ? VaciColors.primary : VaciColors.border),
    );
  }
}

// ── Word List ──
class _WordList extends StatelessWidget {
  final List<WordItem> words;
  final TreasuryViewModel vm;
  const _WordList({required this.words, required this.vm});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: words.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) => _WordCard(item: words[i], vm: vm),
    );
  }
}

// ── Word Card ──
class _WordCard extends StatelessWidget {
  final WordItem item;
  final TreasuryViewModel vm;
  const _WordCard({required this.item, required this.vm});

  @override
  Widget build(BuildContext context) {
    return VaciCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.word,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: VaciColors.dark,
                  ),
                ),
              ),
              WordTypeBadge(item.wordTypeLabel),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _confirmDelete(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: VaciColors.errorLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: VaciColors.error,
                  ),
                ),
              ),
            ],
          ),
          if (item.phonetic.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              item.phonetic,
              style: const TextStyle(
                fontSize: 12,
                color: VaciColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 8),
          // Terjemahan
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: VaciColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.translation,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: VaciColors.primary,
              ),
            ),
          ),
          // Definisi (Bahasa Indonesia)
          if (item.definition.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.definition,
              style: const TextStyle(
                fontSize: 13,
                color: VaciColors.textPrimary,
                height: 1.5,
              ),
            ),
          ],
          // Contoh kalimat
          if (item.example.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '"${item.example}"',
              style: const TextStyle(
                fontSize: 12,
                color: VaciColors.textSecondary,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus kata?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text('Hapus "${item.word}" dari Treasury?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              vm.deleteWord(item.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: VaciColors.error,
              minimumSize: const Size(80, 40),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ──
class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: VaciColors.goldLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Text('🪙', style: TextStyle(fontSize: 48)),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Empty Treasure,\nLets Dig In!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: VaciColors.dark,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tambah kata pertamamu dan mulai\nbangun koleksi kosakata kamu!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: VaciColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            VaciButton(
              label: 'Tambah Kata Pertama',
              icon: Icons.add,
              onPressed: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}
