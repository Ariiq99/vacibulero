import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/treasury_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../router/app_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final treasuryVM = context.watch<TreasuryViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.user;
    final wordCount = treasuryVM.words.length;

    // Menentukan skema warna aplikasi bertema edukasi modern
    const primaryBlue = Color(0xFF2196F3);
    const successGreen = Color(0xFF4CAF50);
    const warningOrange = Color(0xFFFF9800);

    // Ambil email user dengan aman
    final userEmail = user?.email;
    final displayName = userEmail != null && userEmail.contains('@')
        ? userEmail.split('@').first
        : 'Pengguna';

    return Scaffold(
      backgroundColor: Colors.grey[50] ?? const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          // Mencegah terjadinya overflow screen pada layar smartphone kecil
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── REGION HEADER: Informasi & Sapaan Profil Pengguna ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, $displayName! 👋',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A1A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Yuk, pertajam kosakata bahasan Inggrismu hari ini!',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    // Tombol Logout Aksi Cepat
                    IconButton(
                      icon: const Icon(Icons.logout_rounded,
                          color: Colors.redAccent),
                      onPressed: () => context.read<AuthViewModel>().signOut(),
                      tooltip: 'Keluar Akun',
                    )
                  ],
                ),
                const SizedBox(height: 28),

                // ── REGION DASHBOARD STATISTIK: Ringkasan Progress Belajar ──
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                          label: 'Kata Hafal',
                          value: '$wordCount',
                          icon: Icons.collections_bookmark_rounded,
                          color: primaryBlue),
                      Container(width: 1, height: 40, color: Colors.grey[200]),
                      _StatItem(
                          label: 'Hari Streak',
                          value: '0',
                          icon: Icons.local_fire_department_rounded,
                          color: warningOrange),
                      Container(width: 1, height: 40, color: Colors.grey[200]),
                      _StatItem(
                          label: 'Level Selesai',
                          value: '3',
                          icon: Icons.stars_rounded,
                          color: successGreen),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Navigasi aktivitas pembelajaran
                const Text(
                  'Aktivitas Pembelajaran',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 16),

                // Integrasi 3 fitur utama
                _FeatureCardRow(
                  icon: Icons.library_books_rounded,
                  title: 'Word Treasury',
                  subtitle:
                      'Simpan, kelompokkan, dan kelola semua kamus kosakata pribadimu secara real-time.',
                  color: primaryBlue,
                  onTap: () => context.pushNamed(AppRoutes.treasury),
                ),
                const SizedBox(height: 16),

                _FeatureCardRow(
                  icon: Icons.explore_rounded,
                  title: 'Word Expedition',
                  subtitle:
                      'Jelajahi petualangan kata baru yang dikelompokkan berdasarkan tema khusus & level akademis.',
                  color: successGreen,
                  onTap: () => context.pushNamed(AppRoutes.expedition),
                ),
                const SizedBox(height: 16),

                _FeatureCardRow(
                  icon: Icons.offline_bolt_rounded,
                  title: 'Treasure Check!',
                  subtitle:
                      'Uji kekuatan ingatan motormu melalui kuis adaptif berbasis performa langsung.',
                  color: warningOrange,
                  onTap: () => context.pushNamed(AppRoutes.quiz),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── SUB-WIDGET COMPONENT: Item Statistik ──
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

// ── SUB-WIDGET COMPONENT: Kartu Navigasi Utama Premium (List Row Style) ──
class _FeatureCardRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCardRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Colors.grey[100] ?? Colors.transparent, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                        fontSize: 11.5, color: Colors.grey[600], height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
