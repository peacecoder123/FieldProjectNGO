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

  // ── Number to Words ──────────────────────────────────────────────────────

  /// Converts a number to its Indian currency word representation.
  /// Example: 1250 -> "Rupees One Thousand Two Hundred Fifty only"
  static String numberToWords(num amount) {
    if (amount == 0) return "Zero Rupees only";

    final ones = ["", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", 
                  "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen", "Eighteen", "Nineteen"];
    final tens = ["", "", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy", "Eighty", "Ninety"];

    String convert(int n) {
      if (n < 20) return ones[n];
      if (n < 100) return "${tens[n ~/ 10]}${n % 10 != 0 ? " ${ones[n % 10]}" : ""}";
      if (n < 1000) return "${ones[n ~/ 100]} Hundred${n % 100 != 0 ? " ${convert(n % 100)}" : ""}";
      if (n < 100000) return "${convert(n ~/ 1000)} Thousand${n % 1000 != 0 ? " ${convert(n % 1000)}" : ""}";
      if (n < 10000000) return "${convert(n ~/ 100000)} Lakh${n % 100000 != 0 ? " ${convert(n % 100000)}" : ""}";
      return "${convert(n ~/ 10000000)} Crore${n % 10000000 != 0 ? " ${convert(n % 10000000)}" : ""}";
    }

    final intAmount = amount.floor();
    return "Rupees ${convert(intAmount)} only";
  }
}