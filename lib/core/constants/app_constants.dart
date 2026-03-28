/// Static constants used throughout the application.
abstract final class AppConstants {
  AppConstants._();

  // ── App identity ──────────────────────────────────────────────────────────
  static const String appName    = 'HopeConnect';
  static const String appTagline = 'NGO Management';
  static const String orgName    = 'HopeConnect NGO';
  static const String orgRegNo   = 'MH-12345/2020';
  static const String orgWhatsApp = '+91-9876543210';

  // ── Shared-prefs keys ─────────────────────────────────────────────────────
  static const String prefThemeMode   = 'app_theme_mode';
  static const String prefCurrentUser = 'current_user_id';

  // ── Layout ────────────────────────────────────────────────────────────────
  /// Screen width above which the desktop sidebar layout is shown.
  static const double desktopBreakpoint = 1024.0;
  /// Screen width above which the tablet two-column grid is shown.
  static const double tabletBreakpoint  = 600.0;

  static const double sidebarWidth     = 240.0;
  static const double cardBorderRadius = 12.0;
  static const double pagePadding      = 20.0;
  static const double pagePaddingDesktop = 24.0;

  // ── Membership fees (₹) ───────────────────────────────────────────────────
  static const int fee80GRenewal    = 5000;
  static const int fee80GNew        = 7500;
  static const int feeNon80GRenewal = 3000;
  static const int feeNon80GNew     = 4500;

  // ── Pagination ────────────────────────────────────────────────────────────
  static const int defaultPageSize = 20;

  // ── Animation durations ───────────────────────────────────────────────────
  static const Duration animFast   = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow   = Duration(milliseconds: 500);
}

/// Route name constants — used with [GoRouter.goNamed].
abstract final class AppRoutes {
  AppRoutes._();

  static const String landing    = 'landing';
  static const String login      = 'login';
  static const String superAdmin = 'superadmin';
  static const String admin      = 'admin';
  static const String member     = 'member';
  static const String volunteer  = 'volunteer';
}