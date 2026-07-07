import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════
// VACIBULERO DESIGN SYSTEM
// Inspirasi: Duolingo — minimalist, interaktif, dominan biru
// ══════════════════════════════════════════════════════════════

class VaciColors {
  // ── Primary ──
  static const primary = Color(0xFF1A73E8);
  static const primaryDark = Color(0xFF0F4C81);
  static const primaryLight = Color(0xFFE8F0FE);
  static const primaryMid = Color(0xFF4A90E2);

  // ── Accent Gold (reward/achievement) ──
  static const gold = Color(0xFFF6A800);
  static const goldLight = Color(0xFFFFF8E1);
  static const goldDark = Color(0xFFE65100);

  // ── Success / Hafal ──
  static const success = Color(0xFF1D9E75);
  static const successLight = Color(0xFFE8F5E9);

  // ── Error / Belum ──
  static const error = Color(0xFFE53935);
  static const errorLight = Color(0xFFFDECEA);

  // ── Warning ──
  static const warning = Color(0xFFFF8F00);
  static const warningLight = Color(0xFFFFF3E0);

  // ── Neutral ──
  static const dark = Color(0xFF1A1A2E);
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const textHint = Color(0xFFBDBDBD);
  static const surface = Color(0xFFF8F9FA);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE0E0E0);
  static const divider = Color(0xFFF0F0F0);
}

class VaciTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: VaciColors.primary,
        brightness: Brightness.light,
        primary: VaciColors.primary,
        onPrimary: Colors.white,
        primaryContainer: VaciColors.primaryLight,
        secondary: VaciColors.gold,
        surface: VaciColors.surface,
        error: VaciColors.error,
      ),
      scaffoldBackgroundColor: VaciColors.surface,

      // ── AppBar ──
      appBarTheme: const AppBarTheme(
        backgroundColor: VaciColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      // ── Card ──
      cardTheme: CardThemeData(
        elevation: 0,
        color: VaciColors.card,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: VaciColors.border, width: 0.8),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── ElevatedButton ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: VaciColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // ── OutlinedButton ──
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: VaciColors.primary,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: VaciColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // ── TextButton ──
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: VaciColors.primary,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // ── Input ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: VaciColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: VaciColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: VaciColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: VaciColors.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(color: VaciColors.textHint, fontSize: 14),
        prefixIconColor: VaciColors.textSecondary,
      ),

      // ── BottomNavigationBar ──
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: VaciColors.primary,
        unselectedItemColor: VaciColors.textSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),

      // ── Chip ──
      chipTheme: ChipThemeData(
        backgroundColor: VaciColors.primaryLight,
        selectedColor: VaciColors.primary,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),

      // ── SnackBar ──
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      // ── FloatingActionButton ──
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: VaciColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // ── Typography ──
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: VaciColors.dark,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: VaciColors.dark,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: VaciColors.dark,
        ),
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: VaciColors.dark,
        ),
        headlineSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: VaciColors.dark,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: VaciColors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: VaciColors.textPrimary,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: VaciColors.textSecondary,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: VaciColors.textPrimary,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: VaciColors.textSecondary,
        ),
      ),
    );
  }
}

// ── Reusable UI Components ─────────────────────────────────────

// Badge tipe kata (Noun, Verb, dll)
class WordTypeBadge extends StatelessWidget {
  final String label;
  const WordTypeBadge(this.label, {super.key});

  static const _colors = {
    'Noun': [Color(0xFFE3F2FD), Color(0xFF1565C0)],
    'Verb': [Color(0xFFE8F5E9), Color(0xFF2E7D32)],
    'Adjective': [Color(0xFFFFF3E0), Color(0xFFE65100)],
    'Adverb': [Color(0xFFF3E5F5), Color(0xFF6A1B9A)],
    'Other': [Color(0xFFF5F5F5), Color(0xFF424242)],
  };

  @override
  Widget build(BuildContext context) {
    final pair = _colors[label] ?? _colors['Other']!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: pair[0],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: pair[1],
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// Kartu dengan shadow halus ala Duolingo
class VaciCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;

  const VaciCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color ?? VaciColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: VaciColors.border, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

// Primary button dengan gradient
class VaciButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final Color? color;

  const VaciButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? VaciColors.primary,
          disabledBackgroundColor: VaciColors.primary.withOpacity(0.6),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }
}

// Section label
class VaciSectionLabel extends StatelessWidget {
  final String text;
  const VaciSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: VaciColors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
