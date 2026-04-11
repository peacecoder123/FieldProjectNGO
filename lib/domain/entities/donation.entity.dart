// lib/domain/entities/donation.entity.dart

import 'package:flutter/foundation.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';

@immutable
class DonationEntity {
  final String id; // Changed to String from main
  final String donorName;
  final int amount;
  final String date;
  final DonationType type;
  final bool receiptGenerated;
  final String purpose;
  final bool is80G;
  final String? receiptNumber;

  // ── Razorpay payment fields ──────────────────────────────────────────────
  final String? razorpayPaymentId;
  final String? razorpayOrderId;
  final PaymentStatus paymentStatus;
  final String? donorEmail;
  final String? donorPhone;

  const DonationEntity({
    required this.id,
    required this.donorName,
    required this.amount,
    required this.date,
    required this.type,
    required this.receiptGenerated,
    required this.purpose,
    required this.is80G,
    this.receiptNumber,
    this.razorpayPaymentId,
    this.razorpayOrderId,
    this.paymentStatus = PaymentStatus.pending,
    this.donorEmail,
    this.donorPhone,
  });

  // Convert to Firebase document
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'donorName': donorName,
      'amount': amount,
      'date': date,
      'type': type.name, // Store enum as String
      'receiptGenerated': receiptGenerated,
      'purpose': purpose,
      'is80G': is80G,
      'receiptNumber': receiptNumber,
      'razorpayPaymentId': razorpayPaymentId,
      'razorpayOrderId': razorpayOrderId,
      'paymentStatus': paymentStatus.name,
      'donorEmail': donorEmail,
      'donorPhone': donorPhone,
    };
  }

  // Read from Firebase document
  factory DonationEntity.fromMap(Map<String, dynamic> map) {
    return DonationEntity(
      id: (map['id'] ?? '').toString(), // Safely handle String ID
      donorName: map['donorName'] ?? '',
      amount: map['amount']?.toInt() ?? 0,
      date: map['date'] ?? '',
      type: DonationType.values.firstWhere(
        (e) => e.name == map['type'], 
        orElse: () => DonationType.online
      ),
      receiptGenerated: map['receiptGenerated'] ?? false,
      purpose: map['purpose'] ?? '',
      is80G: map['is80G'] ?? false,
      receiptNumber: map['receiptNumber'],
      razorpayPaymentId: map['razorpayPaymentId'],
      razorpayOrderId: map['razorpayOrderId'],
      paymentStatus: PaymentStatus.fromString(map['paymentStatus'] ?? 'pending'),
      donorEmail: map['donorEmail'],
      donorPhone: map['donorPhone'],
    );
  }

  DonationEntity copyWith({
    String? id, // Updated to String
    String? donorName,
    int? amount,
    String? date,
    DonationType? type,
    bool? receiptGenerated,
    String? purpose,
    bool? is80G,
    String? receiptNumber,
    String? razorpayPaymentId,
    String? razorpayOrderId,
    PaymentStatus? paymentStatus,
    String? donorEmail,
    String? donorPhone,
  }) {
    return DonationEntity(
      id: id ?? this.id,
      donorName: donorName ?? this.donorName,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      receiptGenerated: receiptGenerated ?? this.receiptGenerated,
      purpose: purpose ?? this.purpose,
      is80G: is80G ?? this.is80G,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      razorpayPaymentId: razorpayPaymentId ?? this.razorpayPaymentId,
      razorpayOrderId: razorpayOrderId ?? this.razorpayOrderId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      donorEmail: donorEmail ?? this.donorEmail,
      donorPhone: donorPhone ?? this.donorPhone,
    );
  }
}