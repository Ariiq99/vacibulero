import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart'; // <── tambahkan ini
import '../../viewmodels/auth_viewmodel.dart';
import '../../router/app_router.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    if (authVM.status == AuthStatus.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Gunakan context.goNamed (sudah tersedia dari go_router)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authVM.status == AuthStatus.authenticated) {
        context.goNamed(AppRoutes.home);
      } else {
        context.goNamed(AppRoutes.login);
      }
    });

    return const SizedBox.shrink();
  }
}
