import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../services/app_theme.dart';
import 'login_screen.dart';
import 'home_screen.dart';

// ── VIEW: AuthGate ─────────────────────────────────────────────
// Widget penjaga yang menentukan halaman mana yang ditampilkan
// berdasarkan status autentikasi pengguna.
// Dipasang sebagai halaman awal di GoRouter.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, auth, _) {
        // ── Loading saat cek status awal ──
        if (auth.status == AuthStatus.initial) {
          return const Scaffold(
            backgroundColor: VaciColors.primary,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Vacibulero',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 24),
                  CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                ],
              ),
            ),
          );
        }

        // ── Sudah login → tampilkan Home ──
        if (auth.isAuthenticated) return const HomeScreen();

        // ── Belum login → tampilkan Login ──
        return const LoginScreen();
      },
    );
  }
}
