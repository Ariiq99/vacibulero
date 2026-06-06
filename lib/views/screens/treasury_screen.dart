import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/treasury_viewmodel.dart';
import '../../models/word_item.dart';
import '../../router/app_router.dart';

// ── VIEW: TreasuryScreen ───────────────────────────────────────
// Menampilkan daftar kata di Word Treasury.
// Menggunakan Consumer<TreasuryViewModel> untuk listen state.
class TreasuryScreen extends StatelessWidget {
  const TreasuryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Treasury 🏴'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      // ── Consumer: rebuild otomatis saat ViewModel berubah ──
      body: Consumer<TreasuryViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              // ── Stats bar ──
              _StatsBar(vm: vm),
              // ── Search bar ──
              _SearchBar(vm: vm),
              // ── Filter chips ──
              _FilterChips(vm: vm),
              // ── List / empty state ──
              Expanded(
                child: vm.isEmpty
                    ? _EmptyState(onAdd: () => context.go(AppRoutes.addWord))
                    : vm.words.isEmpty
                        ? const Center(child: Text('Tidak ada kata yang cocok.'))
                        : _WordList(words: vm.words, vm: vm),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.addWord),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kata'),
      ),
    );
  }
}

// ── Stats Bar ──
class _StatsBar extends StatelessWidget {
  final TreasuryViewModel vm;
  const _StatsBar({required this.vm});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.primaryContainer.withOpacity(0.3),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _StatChip(label: 'Total', value: vm.totalWords.toString(), color: cs.primary),
          const SizedBox(width: 8),
          _StatChip(label: 'Noun',  value: (vm.stats[WordType.noun] ?? 0).toString(),      color: Colors.blue),
          const SizedBox(width: 8),
          _StatChip(label: 'Verb',  value: (vm.stats[WordType.verb] ?? 0).toString(),      color: Colors.green),
          const SizedBox(width: 8),
          _StatChip(label: 'Adj',   value: (vm.stats[WordType.adjective] ?? 0).toString(), color: Colors.orange),
          const SizedBox(width: 8),
          _StatChip(label: 'Adv',   value: (vm.stats[WordType.adverb] ?? 0).toString(),    color: Colors.purple),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        onChanged: vm.search,
        decoration: InputDecoration(
          hintText: 'Cari kata...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: vm.searchQuery.isNotEmpty
              ? IconButton(icon: const Icon(Icons.clear), onPressed: vm.clearFilter)
              : null,
        ),
      ),
    );
  }
}

// ── Filter Chips ──
class _FilterChips extends StatelessWidget {
  final TreasuryViewModel vm;
  const _FilterChips({required this.vm});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _chip(context, null, 'Semua'),
          const SizedBox(width: 8),
          ...WordType.values.map((t) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _chip(context, t, t.name[0].toUpperCase() + t.name.substring(1)),
          )),
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
      padding: const EdgeInsets.all(16),
      itemCount: words.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _WordCard(item: words[i], vm: vm),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(item.word,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                ),
                _TypeBadge(item.wordTypeLabel),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                  onPressed: () => _confirmDelete(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            if (item.phonetic.isNotEmpty)
              Text(item.phonetic, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(item.translation,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500,
                    color: Color(0xFF1A73E8))),
            if (item.example.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('"${item.example}"',
                  style: const TextStyle(fontSize: 12, color: Colors.grey,
                      fontStyle: FontStyle.italic)),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus kata?'),
        content: Text('Hapus "${item.word}" dari Treasury?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () { Navigator.pop(context); vm.deleteWord(item.id); },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String label;
  const _TypeBadge(this.label);
  static const _colors = {
    'Noun': Colors.blue, 'Verb': Colors.green,
    'Adjective': Colors.orange, 'Adverb': Colors.purple,
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[label] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🪙', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 12),
          const Text('Empty Treasure, Lets Dig In!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Tambah kata pertamamu sekarang.',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Kata'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(180, 46)),
          ),
        ],
      ),
    );
  }
}
