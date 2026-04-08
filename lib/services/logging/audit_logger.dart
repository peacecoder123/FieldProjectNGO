import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:ngo_volunteer_management/domain/entities/audit_log.entity.dart';
import 'package:uuid/uuid.dart';

class AuditLogger {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const _collectionPath = 'audit_logs';
  static const _uuid = Uuid();

  /// Logs the generation of any document to Firebase
  static Future<void> logDocumentGeneration({
    required String documentType,
    required String targetId,
    required String generatedBy,
    Map<String, dynamic> additionalMetadata = const {},
  }) async {
    final logId = _uuid.v4();
    
    final log = AuditLogEntity(
      id: logId,
      action: 'DOCUMENT_GENERATED',
      documentType: documentType,
      targetId: targetId,
      generatedBy: generatedBy,
      timestamp: DateTime.now(),
      metadata: additionalMetadata,
    );

    try {
      await _firestore.collection(_collectionPath).doc(logId).set(log.toMap());
      debugPrint('Audit Log Saved: $documentType generated for $targetId');
    } catch (e) {
      debugPrint('Failed to save audit log: $e');
    }
  }
}