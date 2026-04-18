import 'package:flutter/material.dart';

/// Central color palette — matched to the Jayashree Foundation logo.
/// Logo is deep navy (#0C1A3A) with white accents.
abstract final class AppColors {
  AppColors._();

  // ── Brand (derived from logo navy) ──────────────────────────────────
  static const Color brand     = Color(0xFF001B3A); // User primary color
  static const Color navy900 = Color(0xFF0C1A3A); // Logo primary navy
  static const Color navy800 = Color(0xFF14254D);
  static const Color navy700 = Color(0xFF1A3166);
  static const Color navy600 = Color(0xFF1F3D7A);
  static const Color navy500 = Color(0xFF254794);
  static const Color navy400 = Color(0xFF4968AD);
  static const Color navy100 = Color(0xFFE4E9F5);
  static const Color navy50  = Color(0xFFF2F4FA);

  // Kept for backward compat / charts
  static const Color blue700 = navy600;
  static const Color blue600 = navy500;
  static const Color blue500 = navy400;
  static const Color blue400 = navy400;
  static const Color blue200 = Color(0xFFBFDBFE);
  static const Color blue100 = navy100;
  static const Color blue50  = navy50;

  static const Color indigo600 = navy700;

  static const Color violet600 = Color(0xFF7C3AED);
  static const Color purple600 = Color(0xFF9333EA);
  static const Color purple500 = Color(0xFFA855F7);
  static const Color purple400 = Color(0xFFC084FC);
  static const Color purple100 = Color(0xFFF3E8FF);

  static const Color emerald700 = Color(0xFF0DB84C);
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald200 = Color(0xFFA7F3D0);
  static const Color emerald100 = Color(0xFFD1FAE5);
  static const Color emerald50  = Color(0xFFECFDF5);

  static const Color teal500 = Color(0xFF14B8A6);

  static const Color orange500 = Color(0xFFF97316);
  static const Color orange600 = Color(0xFFFF9800);
  static const Color orange700 = Color(0xFFFF6600);
  static const Color orange800 = Color(0xFFFF4500);
  static const Color orange50  = Color(0xFFF5F7D0);
  static const Color orange100 = Color(0xFFFDFABE);
  static const Color orange200 = Color(0xFFFFD740);

  static const Color amber600 = Color(0xFFD97706);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber300 = Color(0xFFFCD34D);
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber50  = Color(0xFFFFFBEB);

  static const Color rose600 = Color(0xFFE11D48);
  static const Color rose500 = Color(0xFFF43F5E);
  static const Color rose100 = Color(0xFFFFE4E6);

  static const Color cyan500 = Color(0xFF06B6D4);

  static const Color red600 = Color(0xFFDC2626);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red50  = Color(0xFFFEF2F2);

  // ── Slate (neutral) ────────────────────────────────────────────────
  static const Color slate950 = Color(0xFF020617);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate50  = Color(0xFFF8FAFC);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // ── Semantic aliases ───────────────────────────────────────────────
  static const Color primary    = brand;
  static const Color success    = emerald500;
  static const Color warning    = amber500;
  static const Color error      = red500;

  // ── Role Gradients ─────────────────────────────────────────────────
  static const LinearGradient superAdminGradient = LinearGradient(
    colors: [violet600, purple600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient adminGradient = LinearGradient(
    colors: [navy500, cyan500],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient memberGradient = LinearGradient(
    colors: [emerald500, teal500],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient volunteerGradient = LinearGradient(
    colors: [orange500, rose500],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Chart palette ──────────────────────────────────────────────────
  static const Color chartBlue   = navy500;
  static const Color chartGreen  = emerald500;
  static const Color chartAmber  = amber500;
  static const Color chartRed    = red500;
  static const Color chartPurple = purple500;
}
