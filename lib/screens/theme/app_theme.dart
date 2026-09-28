import 'package:flutter/material.dart';

/// Single source of truth for colors, gradients and reusable styles.
/// Every screen should use these instead of hard-coded Color(0x...) values.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0B0D14);
  static const Color surface = Color(0xFF161A24);
  static const Color surfaceHigh = Color(0xFF1E2230);

  static const Color primary = Color(0xFF7C5CFC);
  static const Color primaryLight = Color(0xFF9D87FF);
  static const Color primaryDeep = Color(0xFF6748E8);
  static const Color accent = Color(0xFF4F7CFF);
  static const Color gold = Color(0xFFE0B45A);
  static const Color success = Color(0xFF63D5A5);
  static const Color danger = Color(0xFFFF6B6B);

  static const Color textPrimary = Color(0xFFF7F7FA);
  static const Color textMuted = Color(0xFF969AAA);

  static Color get border => Colors.white.withValues(alpha: 0.06);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryDeep, Color(0xFF9B5CFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.primary,
      secondary: AppColors.gold,
      surface: AppColors.surface,
      error: AppColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(color: AppColors.border, space: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceHigh,
        contentTextStyle: const TextStyle(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primaryLight),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceHigh,
        side: BorderSide.none,
        labelStyle: const TextStyle(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryLight,
      ),
    );
  }

  /// Shared look for text fields, so every form matches.
  /// Usage: decoration: AppTheme.inputDecoration('Email', Icons.email_outlined)
  static InputDecoration inputDecoration(String label, [IconData? icon]) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textMuted),
      prefixIcon: icon == null ? null : Icon(icon, color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.surface,
      enabledBorder: border(Colors.white.withValues(alpha: 0.08)),
      focusedBorder: border(AppColors.primary, 1.5),
      errorBorder: border(AppColors.danger),
      focusedErrorBorder: border(AppColors.danger, 1.5),
      disabledBorder: border(Colors.white.withValues(alpha: 0.04)),
    );
  }

  /// Standard card decoration used across the app.
  static BoxDecoration card({Color? color, double radius = 18}) {
    return BoxDecoration(
      color: color ?? AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.border),
    );
  }
}
