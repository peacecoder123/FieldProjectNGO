import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'razorpay_config.dart';
import 'razorpay_web_stub.dart';

/// Describes the result of a payment attempt.
enum PaymentResult { success, failure, externalWallet }

/// Data returned after a payment is completed (or fails).
class PaymentOutcome {
  const PaymentOutcome({
    required this.result,
    this.paymentId,
    this.orderId,
    this.signature,
    this.errorCode,
    this.errorMessage,
    this.walletName,
  });

  final PaymentResult result;
  final String? paymentId;
  final String? orderId;
  final String? signature;
  final int? errorCode;
  final String? errorMessage;
  final String? walletName;

  bool get isSuccess => result == PaymentResult.success;
}

/// Thin wrapper around the Razorpay Flutter SDK with Web Support.
class RazorpayService {
  RazorpayService() {
    if (!kIsWeb) {
      _razorpay = Razorpay();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    }
  }

  late final Razorpay _razorpay;
  Completer<PaymentOutcome>? _completer;

  // ── Public API ──────────────────────────────────────────────────────────────

  Future<PaymentOutcome> openDonationCheckout({
    required int amount,
    required String donorName,
    required String email,
    required String phone,
    String purpose = 'General Donation',
  }) {
    return _open(
      amount: amount,
      description: 'Donation – $purpose',
      prefillName: donorName,
      prefillEmail: email,
      prefillPhone: phone,
      notes: {
        'type': 'donation',
        'purpose': purpose,
      },
    );
  }

  Future<PaymentOutcome> openMembershipCheckout({
    required int amount,
    required String memberName,
    required String email,
    required String phone,
    required String membershipType,
  }) {
    return _open(
      amount: amount,
      description: 'Membership Fee – $membershipType',
      prefillName: memberName,
      prefillEmail: email,
      prefillPhone: phone,
      notes: {
        'type': 'membership',
        'membership_type': membershipType,
      },
    );
  }

  void dispose() {
    if (!kIsWeb) {
      _razorpay.clear();
    }
  }

  // ── Internals ───────────────────────────────────────────────────────────────

  Future<PaymentOutcome> _open({
    required int amount,
    required String description,
    required String prefillName,
    required String prefillEmail,
    required String prefillPhone,
    Map<String, String>? notes,
  }) async {
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(const PaymentOutcome(
        result: PaymentResult.failure,
        errorMessage: 'Cancelled by new checkout',
      ));
    }

    _completer = Completer<PaymentOutcome>();

    try {
      debugPrint('📡 Calling createRazorpayOrder Cloud Function...');
      final callable = FirebaseFunctions.instance.httpsCallable('createRazorpayOrder');
      final result = await callable.call<Map<String, dynamic>>({
        'amount': amount,
        'currency': RazorpayConfig.currency,
      });

      final orderId = result.data['orderId'] as String;
      debugPrint('✅ Got order_id: $orderId');

      if (kIsWeb) {
        debugPrint('🌐 Opening Razorpay Web Checkout...');
        await openRazorpayWeb(
          amount: amount,
          key: RazorpayConfig.keyId,
          name: RazorpayConfig.companyName,
          description: description,
          currency: RazorpayConfig.currency,
          orderId: orderId,
          prefillName: prefillName,
          prefillEmail: prefillEmail,
          prefillPhone: prefillPhone,
          themeColor: RazorpayConfig.themeColor,
          onResult: (outcome) {
            if (_completer != null && !_completer!.isCompleted) {
              _completer!.complete(outcome);
            }
          },
        );
      } else {
        final options = <String, dynamic>{
          'key': RazorpayConfig.keyId,
          'amount': amount * 100,
          'name': RazorpayConfig.companyName,
          'description': description,
          'currency': RazorpayConfig.currency,
          'order_id': orderId,
          'prefill': {
            'name': prefillName,
            'email': prefillEmail,
            'contact': prefillPhone,
          },
          'theme': {
            'color': RazorpayConfig.themeColor,
          },
          if (notes != null) 'notes': notes,
        };
        _razorpay.open(options);
      }
    } catch (e) {
      debugPrint('Razorpay open error: $e');
      if (!_completer!.isCompleted) {
        _completer!.complete(PaymentOutcome(
          result: PaymentResult.failure,
          errorMessage: e.toString(),
        ));
      }
    }

    return _completer!.future;
  }

  void _handleSuccess(PaymentSuccessResponse response) {
    debugPrint('✅ Payment Success: ${response.paymentId}');
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(PaymentOutcome(
        result: PaymentResult.success,
        paymentId: response.paymentId,
        orderId: response.orderId,
        signature: response.signature,
      ));
    }
  }

  void _handleError(PaymentFailureResponse response) {
    debugPrint('❌ Payment Failed: ${response.code} – ${response.message}');
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(PaymentOutcome(
        result: PaymentResult.failure,
        errorCode: response.code,
        errorMessage: response.message,
      ));
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('💳 External Wallet: ${response.walletName}');
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(PaymentOutcome(
        result: PaymentResult.externalWallet,
        walletName: response.walletName,
      ));
    }
  }
}
