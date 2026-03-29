import 'package:flutter/material.dart';

/// Central color palette mirroring the Tailwind/shadcn design system.
abstract final class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue50  = Color(0xFFEFF6FF);

  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color violet600 = Color(0xFF7C3AED);
  static const Color purple600 = Color(0xFF9333EA);
  static const Color purple500 = Color(0xFFA855F7);
  static const Color purple400 = Color(0xFFC084FC);
  static const Color purple100 = Color(0xFFF3E8FF);

  static const Color blue700 = Color(0xFF2A52BE); // Dark blue (approx. 20% opacity)
  static const Color emerald700 = Color(0xFF0DB84C); // Dark green
  static const Color orange50 = Color(0xFFF5F7D0); // Light orange
  static const Color orange100 = Color(0xFFFDFABE); // Lighter orange
  static const Color orange600 = Color(0xFFFF9800); // Bright orange
  static const Color orange700 = Color(0xFFFF6600); // Orange-honey color
  static const Color orange800 = Color(0xFFFF4500); // Bright red-orange

  static const Color orange200 = Color(0xFFFFD740); // Added for border references
  static const Color emerald200 = Color(0xFFA7F3D0); // Added for meeting card border
    
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald100 = Color(0xFFD1FAE5);
  static const Color emerald50  = Color(0xFFECFDF5);

  static const Color teal500 = Color(0xFF14B8A6);

  static const Color amber600 = Color(0xFFD97706);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber300 = Color(0xFFFCD34D); // Added for border references
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber50  = Color(0xFFFFFBEB);

  static const Color red600 = Color(0xFFDC2626);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red50  = Color(0xFFFEF2F2);

  static const Color rose600 = Color(0xFFE11D48);
  static const Color rose500 = Color(0xFFF43F5E);
  static const Color rose100 = Color(0xFFFFE4E6);

  static const Color orange500 = Color(0xFFF97316);
  static const Color cyan500 = Color(0xFF06B6D4);

  // ── Slate (neutral) ────────────────────────────────────────────────────────
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

  // ── Semantic aliases ───────────────────────────────────────────────────────
  static const Color primary    = blue600;
  static const Color success    = emerald500;
  static const Color warning    = amber500;
  static const Color error      = red500;

  // ── Role Gradients (Converted to LinearGradient for UI use) ────────────────
  static const LinearGradient superAdminGradient = LinearGradient(
    colors: [violet600, purple600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient adminGradient = LinearGradient(
    colors: [blue600, cyan500],
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

  // ── Chart palette ──────────────────────────────────────────────────────────
  static const Color chartBlue   = Color(0xFF6366F1);
  static const Color chartGreen  = Color(0xFF10B981);
  static const Color chartAmber  = Color(0xFFF59E0B);
  static const Color chartRed    = Color(0xFFEF4444);
  static const Color chartPurple = Color(0xFFA855F7);
}