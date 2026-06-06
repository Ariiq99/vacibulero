import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../router/app_router.dart';

// ── VIEW: HomeScreen ───────────────────────────────────────────
// Halaman utama dengan 3 tab: Treasury, Expedition, Quiz.
// Tidak perlu Consumer karena tidak punya state sendiri.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Vaci',
                style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: 'bulero',
                style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w300,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: const [
          _HomeTab(),
          _PlaceholderTab('Word Expedition', Icons.explore),
          _PlaceholderTab('Treasure Check!', Icons.fact_check),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Expedition',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check),
            label: 'Quiz',
          ),
        ],
      ),
    );
  }
}

// ── Tab beranda ──
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selamat Datang! 👋',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  'Mulai jelajahi kosakata bahasa Inggrismu hari ini.',
                  style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.85), height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text('Fitur Utama', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          // Feature cards
          _FeatureCard(
            emoji: '🏴',
            title: 'Word Treasury',
            subtitle: 'Simpan & kelola kosakata kamu',
            color: const Color(0xFFE8F0FE),
            onTap: () => context.go(AppRoutes.treasury),
          ),
          const SizedBox(height: 10),
          _FeatureCard(
            emoji: '🗺️',
            title: 'Word Expedition',
            subtitle: 'Jelajahi kata per tema & level',
            color: const Color(0xFFE8F5E9),
            onTap: () => context.go(AppRoutes.expedition),
          ),
          const SizedBox(height: 10),
          _FeatureCard(
            emoji: '✅',
            title: 'Treasure Check!',
            subtitle: 'Uji hafalan kosakata kamu',
            color: const Color(0xFFFFF8E1),
            onTap: () => context.go(AppRoutes.quiz),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String emoji, title, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _FeatureCard({
    required this.emoji, required this.title,
    required this.subtitle, required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String label;
  final IconData icon;
  const _PlaceholderTab(this.label, this.icon);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
