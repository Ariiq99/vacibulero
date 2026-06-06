import 'package:go_router/go_router.dart';
import '../views/screens/home_screen.dart';
import '../views/screens/treasury_screen.dart';
import '../views/screens/add_word_screen.dart';
import '../views/screens/expedition_screen.dart';
import '../views/screens/flip_card_screen.dart';
import '../views/screens/quiz_screen.dart';
import '../views/screens/quiz_result_screen.dart';
import '../models/expedition_models.dart';
import '../models/quiz_models.dart';

class AppRoutes {
  static const home         = '/';
  static const treasury     = '/treasury';
  static const addWord      = '/add-word';
  static const expedition   = '/expedition';
  static const flipCard     = '/flip-card';
  static const quiz         = '/quiz';
  static const quizResult   = '/quiz-result';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (_, __) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.treasury,
      builder: (_, __) => const TreasuryScreen(),
    ),
    GoRoute(
      path: AppRoutes.addWord,
      builder: (_, __) => const AddWordScreen(),
    ),
    GoRoute(
      path: AppRoutes.expedition,
      builder: (_, __) => const ExpeditionScreen(),
    ),
    GoRoute(
      path: AppRoutes.flipCard,
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>;
        return FlipCardScreen(
          theme: extra['theme'] as ExpeditionTheme,
          level: extra['level'] as int,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.quiz,
      builder: (_, __) => const QuizScreen(),
    ),
    GoRoute(
      path: AppRoutes.quizResult,
      builder: (_, state) {
        final session = state.extra as QuizSession;
        return QuizResultScreen(session: session);
      },
    ),
  ],
);
