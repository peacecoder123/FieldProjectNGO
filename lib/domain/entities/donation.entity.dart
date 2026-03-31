// lib/domain/entities/donation.entity.dart

import 'package:flutter/foundation.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';


@immutable
class DonationEntity {
  final int id;
  final String donorName;
  final int amount;
  final String date;
  final DonationType type;
  final bool receiptGenerated;
  final String purpose;
  final bool is80G;
  final String? receiptNumber;

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
    };
  }

  // Read from Firebase document
  factory DonationEntity.fromMap(Map<String, dynamic> map) {
    return DonationEntity(
      id: map['id']?.toInt() ?? 0,
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
    );
  }

  DonationEntity copyWith({
    int? id,
    String? donorName,
    int? amount,
    String? date,
    DonationType? type,
    bool? receiptGenerated,
    String? purpose,
    bool? is80G,
    String? receiptNumber,
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
    );
  }
}