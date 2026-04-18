import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Builds the Material 3 [ThemeData] for light and dark modes.
///
/// Design decisions:
/// • Uses [ColorScheme.fromSeed] seeded on [AppColors.blue600] so that M3
///   tonal surfaces stay close to the React Tailwind palette.
/// • Typography uses Poppins via Google Fonts for a clean, geometric look.
/// • Every component theme is explicit so behaviour is predictable.
abstract final class AppTheme {
  AppTheme._();

  // ── Public factories ───────────────────────────────────────────────────────

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark()  => _build(Brightness.dark);

  // ── Internal builder ──────────────────────────────────────────────────────

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      brightness: brightness,
      // Override surfaces to match the two-color brand palette
      surface:          AppColors.white,
      onSurface:        AppColors.brand,
      surfaceContainerHighest: AppColors.slate100,
      surfaceContainer: AppColors.slate50,
      primary:          AppColors.brand,
      onPrimary:        AppColors.white,
      secondary:        AppColors.brand,
      onSecondary:      AppColors.white,
      error:            AppColors.red500,
      onError:          AppColors.white,
      outline:          isDark ? AppColors.slate700  : AppColors.slate200,
    );

    final textTheme = GoogleFonts.poppinsTextTheme(_buildTextTheme(isDark));

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      fontFamily: GoogleFonts.poppins().fontFamily,
      textTheme: textTheme,
      scaffoldBackgroundColor: isDark ? AppColors.slate900 : AppColors.white,

      // ── AppBar ─────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.brand,
        foregroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),

      // ── Card ───────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: isDark ? AppColors.slate800 : AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? AppColors.slate700 : AppColors.slate200,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── ElevatedButton ─────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brand,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── OutlinedButton ─────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? AppColors.slate300 : AppColors.slate700,
          side: BorderSide(
            color: isDark ? AppColors.slate600 : AppColors.slate300,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // ── TextButton ─────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brand,
          textStyle: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // ── InputDecoration ────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? AppColors.slate700.withValues(alpha: 0.5)
            : AppColors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.slate300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.slate300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.brand, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.red500),
        ),
        hintStyle: TextStyle(
          color: isDark ? AppColors.slate500 : AppColors.slate400,
          fontSize: 14,
        ),
        labelStyle: TextStyle(
          color: isDark ? AppColors.slate300 : AppColors.slate700,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      // ── Chip ───────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor:
            isDark ? AppColors.slate700 : AppColors.slate100,
        labelStyle: textTheme.labelSmall?.copyWith(
          color: isDark ? AppColors.slate300 : AppColors.slate600,
        ),
        side: BorderSide.none,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),

      // ── Divider ────────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.slate700 : AppColors.slate100,
        thickness: 1,
        space: 1,
      ),

      // ── BottomNavigationBar ────────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor:
            isDark ? AppColors.slate800 : AppColors.white,
        selectedItemColor: AppColors.blue600,
        unselectedItemColor:
            isDark ? AppColors.slate400 : AppColors.slate500,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      // ── NavigationRail ─────────────────────────────────────────────────────
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.brand,
        selectedIconTheme: const IconThemeData(color: AppColors.white),
        unselectedIconTheme:
            IconThemeData(color: AppColors.white.withValues(alpha: 0.6)),
        selectedLabelTextStyle: textTheme.labelSmall?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: textTheme.labelSmall?.copyWith(
          color: AppColors.white.withValues(alpha: 0.6),
        ),
        indicatorColor: AppColors.white.withValues(alpha: 0.2),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // ── TabBar ─────────────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.white,
        unselectedLabelColor: AppColors.white.withValues(alpha: 0.6),
        indicator: BoxDecoration(
          color: AppColors.brand,
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: textTheme.labelMedium,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // ── Snack bar ──────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor:
            isDark ? AppColors.slate700 : AppColors.slate800,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Dialog ─────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor:
            isDark ? AppColors.slate800 : AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: isDark ? AppColors.white : AppColors.slate900,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ── ListTile ───────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }

  // ── Typography ─────────────────────────────────────────────────────────────

  static TextTheme _buildTextTheme(bool isDark) {
    final baseColor =
        isDark ? AppColors.white : AppColors.slate900;
    final mutedColor =
        isDark ? AppColors.slate400 : AppColors.slate500;

    return TextTheme(
      // Display
      displayLarge: TextStyle(
        fontSize: 57, fontWeight: FontWeight.w700, color: baseColor,
        letterSpacing: -0.25,
      ),
      displayMedium: TextStyle(
        fontSize: 45, fontWeight: FontWeight.w700, color: baseColor,
      ),
      displaySmall: TextStyle(
        fontSize: 36, fontWeight: FontWeight.w700, color: baseColor,
      ),

      // Headline
      headlineLarge: TextStyle(
        fontSize: 32, fontWeight: FontWeight.w700, color: baseColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 28, fontWeight: FontWeight.w600, color: baseColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 24, fontWeight: FontWeight.w600, color: baseColor,
      ),

      // Title  (used for card headings, section titles)
      titleLarge: TextStyle(
        fontSize: 22, fontWeight: FontWeight.w600, color: baseColor,
      ),
      titleMedium: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w600, color: baseColor,
        letterSpacing: 0.15,
      ),
      titleSmall: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w500, color: baseColor,
        letterSpacing: 0.1,
      ),

      // Body
      bodyLarge: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w400, color: baseColor,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w400, color: baseColor,
        letterSpacing: 0.25,
      ),
      bodySmall: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w400, color: mutedColor,
        letterSpacing: 0.4,
      ),

      // Label
      labelLarge: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w600, color: baseColor,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w500, color: baseColor,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        fontSize: 11, fontWeight: FontWeight.w500, color: mutedColor,
        letterSpacing: 0.5,
      ),
    );
  }
}