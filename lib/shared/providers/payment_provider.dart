import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/payment/razorpay_service.dart';

// ── Payment processing state ─────────────────────────────────────────────────

enum PaymentProcessingState {
  idle,
  processing,
  success,
  failed,
}

class PaymentState {
  const PaymentState({
    this.processingState = PaymentProcessingState.idle,
    this.lastOutcome,
    this.errorMessage,
  });

  final PaymentProcessingState processingState;
  final PaymentOutcome? lastOutcome;
  final String? errorMessage;

  bool get isProcessing => processingState == PaymentProcessingState.processing;
  bool get isSuccess => processingState == PaymentProcessingState.success;
  bool get isFailed => processingState == PaymentProcessingState.failed;

  PaymentState copyWith({
    PaymentProcessingState? processingState,
    PaymentOutcome? lastOutcome,
    String? errorMessage,
  }) =>
      PaymentState(
        processingState: processingState ?? this.processingState,
        lastOutcome: lastOutcome ?? this.lastOutcome,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

// ── Razorpay service provider (singleton for app lifetime) ───────────────────

final razorpayServiceProvider = Provider<RazorpayService>((ref) {
  final service = RazorpayService();
  ref.onDispose(service.dispose);
  return service;
});

// ── Payment state notifier ───────────────────────────────────────────────────

class PaymentNotifier extends StateNotifier<PaymentState> {
  PaymentNotifier(this._service) : super(const PaymentState());

  final RazorpayService _service;

  /// Opens a donation checkout and updates state accordingly.
  Future<PaymentOutcome> processDonation({
    required int amount,
    required String donorName,
    required String email,
    required String phone,
    String purpose = 'General Donation',
  }) async {
    state = state.copyWith(processingState: PaymentProcessingState.processing);

    final outcome = await _service.openDonationCheckout(
      amount: amount,
      donorName: donorName,
      email: email,
      phone: phone,
      purpose: purpose,
    );

    state = state.copyWith(
      processingState: outcome.isSuccess
          ? PaymentProcessingState.success
          : PaymentProcessingState.failed,
      lastOutcome: outcome,
      errorMessage: outcome.errorMessage,
    );

    return outcome;
  }

  /// Opens a membership-fee checkout and updates state accordingly.
  Future<PaymentOutcome> processMembershipPayment({
    required int amount,
    required String memberName,
    required String email,
    required String phone,
    required String membershipType,
  }) async {
    state = state.copyWith(processingState: PaymentProcessingState.processing);

    final outcome = await _service.openMembershipCheckout(
      amount: amount,
      memberName: memberName,
      email: email,
      phone: phone,
      membershipType: membershipType,
    );

    state = state.copyWith(
      processingState: outcome.isSuccess
          ? PaymentProcessingState.success
          : PaymentProcessingState.failed,
      lastOutcome: outcome,
      errorMessage: outcome.errorMessage,
    );

    return outcome;
  }

  /// Resets back to idle (e.g. after showing a success/error dialog).
  void reset() => state = const PaymentState();
}

final paymentStateProvider =
    StateNotifierProvider.autoDispose<PaymentNotifier, PaymentState>(
  (ref) => PaymentNotifier(ref.watch(razorpayServiceProvider)),
);
