// Stub implementation for non-web platforms.
// The real implementation lives in razorpay_web_logic.dart and is loaded
// only when dart.library.js_interop is available.

import 'package:ngo_volunteer_management/services/payment/razorpay_service.dart';

Future<void> openRazorpayWeb({
  required int amount,
  required String key,
  required String name,
  required String description,
  required String currency,
  required String orderId,
  required String prefillName,
  required String prefillEmail,
  required String prefillPhone,
  required String themeColor,
  required void Function(PaymentOutcome) onResult,
}) async {
  throw UnsupportedError('Razorpay web checkout is not supported on this platform.');
}
