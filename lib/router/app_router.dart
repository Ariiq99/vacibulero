import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../views/screens/home_screen.dart';
import '../views/screens/treasury_screen.dart';
import '../views/screens/expedition_screen.dart';
import '../views/screens/quiz_screen.dart';
import '../views/screens/login_screen.dart';
import '../views/screens/register_screen.dart';
import '../views/screens/add_word_screen.dart';
import '../views/screens/flip_card_screen.dart';
import '../views/screens/quiz_result_screen.dart';
import '../models/expedition_models.dart';
import '../models/quiz_models.dart';

class AppRoutes {
  static const home = 'home';
  static const treasury = 'treasury';
  static const expedition = 'expedition';
  static const quiz = 'quiz';
  static const login = 'login';
  static const register = 'register';
  static const addWord = 'addWord';
  static const flipCard = 'flipCard';
  static const quizResult = 'quizResult';
}

Page<dynamic> _buildFadeTransitionPage(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final isAuthenticated = Supabase.instance.client.auth.currentUser != null;
    final isGoingToAuth = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';

    if (!isAuthenticated && !isGoingToAuth) {
      return '/login';
    }
    if (isAuthenticated && isGoingToAuth) {
      return '/';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      name: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/treasury',
      name: AppRoutes.treasury,
      pageBuilder: (context, state) =>
          _buildFadeTransitionPage(const TreasuryScreen()),
    ),
    GoRoute(
      path: '/expedition',
      name: AppRoutes.expedition,
      pageBuilder: (context, state) =>
          _buildFadeTransitionPage(const ExpeditionScreen()),
    ),
    GoRoute(
      path: '/quiz',
      name: AppRoutes.quiz,
      pageBuilder: (context, state) =>
          _buildFadeTransitionPage(const QuizScreen()),
    ),
    GoRoute(
      path: '/login',
      name: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/add-word',
      name: AppRoutes.addWord,
      builder: (context, state) => const AddWordScreen(),
    ),
    // ── FlipCard (hanya theme) ──
    GoRoute(
      path: '/flip-card',
      name: AppRoutes.flipCard,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final theme = extra?['theme'] as ExpeditionTheme? ??
            ExpeditionTheme(
              id: 'general',
              name: 'General',
              emoji: '📚',
              difficulties: [], // Menyesuaikan dengan parameter model baru
            );
        return _buildFadeTransitionPage(FlipCardScreen(theme: theme));
      },
    ),
    // ── QuizResult ──
    GoRoute(
      path: '/quiz-result',
      name: AppRoutes.quizResult,
      pageBuilder: (context, state) {
        final session = state.extra as QuizSession?;
        return _buildFadeTransitionPage(QuizResultScreen(session: session));
      },
    ),
  ],
);
