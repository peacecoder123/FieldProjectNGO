/// Razorpay configuration constants.
///
/// Replace [testKeyId] with your live key when moving to production.
/// NEVER put [keySecret] in client code — it belongs on the server only.
class RazorpayConfig {
  RazorpayConfig._();

  // ── Test mode key ──────────────────────────────────────────────────────────
  static const String testKeyId = 'rzp_test_SaFPcJFYBcGx5X';

  // ── Live mode key (use after KYC approval) ─────────────────────────────────
  static const String liveKeyId = 'rzp_live_YOUR_KEY_HERE';

  // ── Currently active key ───────────────────────────────────────────────────
  static const bool isTestMode = true;
  static String get keyId => isTestMode ? testKeyId : liveKeyId;

  // ── Checkout UI configuration ──────────────────────────────────────────────
  static const String companyName = 'Jayashree Foundation';
  static const String description = 'Jayashree Foundation NGO';
  static const String currency = 'INR';

  // Theme color for the Razorpay checkout (hex with #)
  static const String themeColor = '#4F46E5'; // Indigo-600

  // ── Prefill defaults ───────────────────────────────────────────────────────
  static const String contactEmail = 'contact@jayashreefoundation.org';
  static const String contactPhone = '+912212345678';

  // ── Membership fee amounts (in ₹) ──────────────────────────────────────────
  static const int membershipFee80G = 5000;
  static const int membershipFeeNon80G = 1000;

  // ── Preset donation amounts ────────────────────────────────────────────────
  static const List<int> presetDonationAmounts = [500, 1000, 2500, 5000, 10000];
  static const int minimumDonationAmount = 1; // Razorpay minimum is ₹1
}
