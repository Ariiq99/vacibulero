import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vacibulero/repositories/auth_repository.dart';
import 'repositories/word_repository.dart';
import 'repositories/dictionary_repository.dart';
import 'repositories/expedition_repository.dart';
import 'repositories/quiz_repository.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/treasury_viewmodel.dart';
import 'viewmodels/add_word_viewmodel.dart';
import 'viewmodels/expedition_viewmodel.dart';
import 'viewmodels/quiz_viewmodel.dart';
import 'router/app_router.dart';
import 'services/app_theme.dart';

// ── SUPABASE CONFIG ────────────────────────────────────────────
// Ganti dengan URL dan Anon Key dari project Supabase kamu
// Dashboard: https://supabase.com/dashboard → Project Settings → API
const _supabaseUrl = 'https://ujoarhbfsgpylkuuhymc.supabase.co';
const _supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVqb2FyaGJmc2dweWxrdXVoeW1jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI4ODYxMzgsImV4cCI6MjA5ODQ2MjEzOH0.k24AQeOmQsv9sUkOoB-sGuXf8juUtd9--dHbr3wWuoo';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Inisialisasi Supabase sebelum runApp ──
  await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);

  runApp(const VacibuleroApp());
}

class VacibuleroApp extends StatelessWidget {
  const VacibuleroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ── Repositories ──
        Provider(create: (_) => AuthRepository(Supabase.instance.client)),
        Provider(create: (_) => WordRepository()),
        Provider(create: (_) => DictionaryRepository()),
        Provider(create: (_) => ExpeditionRepository()),
        Provider(create: (_) => QuizRepository()),

        // ── ViewModels ──
        ChangeNotifierProvider(
          create: (ctx) => AuthViewModel(ctx.read<AuthRepository>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) =>
              TreasuryViewModel(ctx.read<WordRepository>())..loadWords(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => AddWordViewModel(ctx.read<DictionaryRepository>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ExpeditionViewModel(ctx.read<ExpeditionRepository>())
            ..loadThemes(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => QuizViewModel(ctx.read<QuizRepository>()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Vacibulero',
        debugShowCheckedModeBanner: false,
        theme: VaciTheme.light,
        routerConfig: appRouter,
      ),
    );
  }
}
