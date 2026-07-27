import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Gridiron Pulse Design System — ESPN-inspired Brutalist Sports Broadcast
///
/// Colors: High-Contrast Red / Black / White
/// Typography: Anton (headlines, uppercase), Archivo Narrow (labels), Inter (body)
/// Shapes: Sharp, 4-8px radius, 2px solid borders
class AppTheme {
  // ── Brand Colors ──
  static const Color primary = Color(0xFF9E0000);
  static const Color primaryContainer = Color(0xFFCC0000);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryFixed = Color(0xFFFFDAD4);
  static const Color primaryFixedDim = Color(0xFFFFB4A8);

  // ── Surface / Background ──
  static const Color surfaceLight = Color(0xFFF9F9F9);
  static const Color surfaceDim = Color(0xFFDADADA);
  static const Color surfaceBright = Color(0xFFF9F9F9);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F3F3);
  static const Color surfaceContainer = Color(0xFFEEEEEE);
  static const Color surfaceContainerHigh = Color(0xFFE8E8E8);
  static const Color surfaceContainerHighest = Color(0xFFE2E2E2);

  // Dark mode surfaces
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);

  // ── On-Surface ──
  static const Color onSurface = Color(0xFF1A1C1C);
  static const Color onSurfaceVariant = Color(0xFF5E3F3A);
  static const Color onSurfaceDark = Color(0xFFF1F1F1);

  // ── Outline / Border ──
  static const Color outline = Color(0xFF926E69);
  static const Color outlineVariant = Color(0xFFE8BDB6);
  static const Color outlineLight = Color(0xFFE0E0E0);

  // ── Secondary / Neutral ──
  static const Color secondary = Color(0xFF5F5E5E);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFE5E2E1);
  static const Color secondaryFixed = Color(0xFFE5E2E1);
  static const Color secondaryFixedDim = Color(0xFFC8C6C5);

  // ── Legacy aliases for backward compatibility ──
  static const Color primaryAccent = primaryContainer;
  static const Color background = darkBackground;
  static const Color surface = darkSurface;
  static const Color textPrimary = onSurfaceDark;
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color divider = Color(0xFF2C2C2C);
  static const Color lightBackground = surfaceLight;
  static const Color lightSurface = surfaceContainerLowest;
  static const Color lightTextPrimary = onSurface;
  static const Color lightTextSecondary = Color(0xFF666666);
  static const Color lightDivider = outlineLight;

  // ── Google Fonts ──
  static TextStyle get display => GoogleFonts.anton(
        fontSize: 64,
        fontWeight: FontWeight.w400,
        height: 1.0,
        letterSpacing: 0.02,
      );

  static TextStyle get headlineLg => GoogleFonts.anton(
        fontSize: 40,
        fontWeight: FontWeight.w400,
        height: 1.1,
        letterSpacing: 0.02,
      );

  static TextStyle get headlineLgMobile => GoogleFonts.anton(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        height: 1.1,
      );

  static TextStyle get headlineMd => GoogleFonts.anton(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        height: 1.2,
      );

  static TextStyle get bodyLg => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 28 / 18,
      );

  static TextStyle get bodyMd => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
      );

  static TextStyle get labelBold => GoogleFonts.archivoNarrow(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 16 / 14,
        letterSpacing: 0.05,
      );

  static TextStyle get labelSm => GoogleFonts.archivoNarrow(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 14 / 12,
      );

  // ── Helpers ──
  static Brightness brightnessFor(bool isDark) =>
      isDark ? Brightness.dark : Brightness.light;

  static Color scaffoldBgFor(bool isDark) =>
      isDark ? darkBackground : surfaceLight;

  static Color cardBgFor(bool isDark) => isDark ? darkSurface : surfaceContainerLowest;

  static Color textPrimaryFor(bool isDark) =>
      isDark ? onSurfaceDark : onSurface;

  static Color textSecondaryFor(bool isDark) =>
      isDark ? textSecondary : lightTextSecondary;

  static Color dividerFor(bool isDark) =>
      isDark ? divider : outlineLight;

  // ── Build Theme ──
  static ThemeData buildTheme({required bool isDark}) {
    final brightness = brightnessFor(isDark);
    final scaffoldBg = scaffoldBgFor(isDark);
    final cardBg = cardBgFor(isDark);
    final txtPrimary = textPrimaryFor(isDark);
    final txtSecondary = textSecondaryFor(isDark);
    final divColor = dividerFor(isDark);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: primaryFixed,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: const Color(0xFF656464),
        tertiary: const Color(0xFF4C4C4C),
        onTertiary: onSecondary,
        error: const Color(0xFFBA1A1A),
        onError: onPrimary,
        surface: cardBg,
        onSurface: txtPrimary,
        outline: outline,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        foregroundColor: txtPrimary,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: headlineMd.copyWith(color: txtPrimary, fontSize: 22),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: divColor, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: divColor,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardBg,
        selectedItemColor: primaryContainer,
        unselectedItemColor: txtSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: labelBold.copyWith(fontSize: 11),
        unselectedLabelStyle: labelSm.copyWith(fontSize: 11),
      ),
      textTheme: TextTheme(
        displayLarge: display,
        headlineLarge: headlineLg,
        headlineMedium: headlineMd,
        bodyLarge: bodyLg,
        bodyMedium: bodyMd,
        labelLarge: labelBold,
        labelSmall: labelSm,
        titleMedium: headlineMd.copyWith(fontSize: 18),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryContainer,
          foregroundColor: onPrimary,
          textStyle: labelBold.copyWith(
            color: onPrimary,
            letterSpacing: 0.05,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: divColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: primaryContainer, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: bodyMd.copyWith(color: txtSecondary),
      ),
    );
  }

  static ThemeData get darkTheme => buildTheme(isDark: true);
  static ThemeData get lightTheme => buildTheme(isDark: false);
}
