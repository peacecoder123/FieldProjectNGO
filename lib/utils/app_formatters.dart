import 'package:intl/intl.dart';

/// Formatting helpers used across the UI layer.
abstract final class AppFormatters {
  AppFormatters._();

  // ── Currency ──────────────────────────────────────────────────────────────

  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  /// Formats [amount] as Indian Rupees: ₹1,00,000
  /// Changed to 'num' to handle both int and double
  static String inr(num amount) => _inrFormat.format(amount);

  /// Short form: ₹5L, ₹12k
  static String inrShort(num amount) {
    if (amount >= 100000) {
      final lakhs = amount / 100000;
      // Removes .0 if it's a whole number (e.g., 5.0L -> 5L)
      final label = lakhs == lakhs.toInt() 
          ? lakhs.toInt().toString() 
          : lakhs.toStringAsFixed(1);
      return '₹${label}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(0)}k';
    }
    return inr(amount);
  }

  // ── Dates ─────────────────────────────────────────────────────────────────

  static final DateFormat _dateFormat     = DateFormat('dd MMM yyyy');
  static final DateFormat _isoFormat      = DateFormat('yyyy-MM-dd');
  static final DateFormat _monthYear      = DateFormat('MMMM yyyy');
  static final DateFormat _displayFull    = DateFormat('EEEE, d MMMM yyyy');

  /// '2025-03-15'  →  '15 Mar 2025'
  static String displayDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return _dateFormat.format(dt);
    } catch (_) {
      return isoDate;
    }
  }

  static String toIso(DateTime dt) => _isoFormat.format(dt);
  static String today() => toIso(DateTime.now());
  static String monthYear(DateTime dt) => _monthYear.format(dt);
  static String fullDate(DateTime dt) => _displayFull.format(dt);

  // ── Days remaining ────────────────────────────────────────────────────────

  static int daysUntil(String isoDate) {
    try {
      final target = DateTime.parse(isoDate);
      final now    = DateTime.now();
      // Difference based on midnight to avoid hour/minute discrepancies
      return DateTime(target.year, target.month, target.day).difference(
        DateTime(now.year, now.month, now.day),
      ).inDays;
    } catch (_) {
      return 0;
    }
  }

  // ── Initials ──────────────────────────────────────────────────────────────

  static String initials(String fullName) {
    if (fullName.isEmpty) return '?';
    final parts = fullName.trim().split(' ').where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    
    // Handles cases like "Dr. Anjali Mehta" by skipping prefixes if you want, 
    // but standard initials logic just takes the first two words found.
    return parts
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
  }
}