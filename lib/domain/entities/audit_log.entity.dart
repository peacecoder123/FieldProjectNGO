import 'package:flutter/foundation.dart';

@immutable
class AuditLogEntity {
  final String id;
  final String action; // e.g., 'DOCUMENT_GENERATED', 'PAYMENT_RECEIVED'
  final String documentType; // e.g., '80G Certificate'
  final String targetId; // The ID of the donation or member this belongs to
  final String generatedBy; // The Admin/System who generated it
  final DateTime timestamp;
  final Map<String, dynamic> metadata; // Extra info like receipt numbers

  const AuditLogEntity({
    required this.id,
    required this.action,
    required this.documentType,
    required this.targetId,
    required this.generatedBy,
    required this.timestamp,
    this.metadata = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'action': action,
      'documentType': documentType,
      'targetId': targetId,
      'generatedBy': generatedBy,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}