import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/shared/data/entities.dart';
import 'package:ngo_volunteer_management/shared/data/repositories.dart';

class FirebaseGeneralRequestRepository implements IGeneralRequestRepository {
  final String _collectionPath = 'general_requests';
  FirebaseFirestore? _firestore;

  FirebaseGeneralRequestRepository() {
    if (Firebase.apps.isNotEmpty) {
      _firestore = FirebaseFirestore.instance;
    }
  }

  FirebaseFirestore get _db {
    if (_firestore == null) {
      try {
        _firestore = FirebaseFirestore.instance;
      } catch (e) {
        debugPrint('Firebase not initialized: $e');
        rethrow;
      }
    }
    return _firestore!;
  }

  @override
  Future<List<GeneralRequestEntity>> getAll() async {
    final snapshot = await _db.collection(_collectionPath).get();
    return snapshot.docs.map((doc) => _fromMap(doc.id, doc.data())).toList();
  }

  @override
  Stream<List<GeneralRequestEntity>> watchAll() {
    return _db.collection(_collectionPath).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => _fromMap(doc.id, doc.data())).toList();
    });
  }

  @override
  Future<GeneralRequestEntity> add(GeneralRequestEntity request) async {
    final docRef = await _db.collection(_collectionPath).add(_toMap(request));
    return request.copyWith(id: docRef.id);
  }

  @override
  Future<GeneralRequestEntity> updateStatus(String id, RequestStatus status, {String? approvedBy}) async {
    final Map<String, dynamic> updates = {'status': status.name};
    if (status == RequestStatus.approved && approvedBy != null) {
      updates['approvedBy'] = approvedBy;
      updates['approvedAt'] = DateTime.now().toIso8601String();
    }
    
    await _db
        .collection(_collectionPath)
        .doc(id)
        .update(updates);
    final doc = await _db.collection(_collectionPath).doc(id).get();
    return _fromMap(doc.id, doc.data()!);
  }
  Map<String, dynamic> _toMap(GeneralRequestEntity r) => {
        'requestType': r.requestType.name,
        'requesterName': r.requesterName,
        'requesterType': r.requesterType,
        'requestDate': r.requestDate,
        'status': r.status.name,
        'details': r.details,
        if (r.approvedBy != null) 'approvedBy': r.approvedBy,
        if (r.approvedAt != null) 'approvedAt': r.approvedAt,
        if (r.requesterId != null) 'requesterId': r.requesterId,
      };

  GeneralRequestEntity _fromMap(String id, Map<String, dynamic> map) => GeneralRequestEntity(
        id: id,
        requestType: enumValueOr(
          GeneralRequestType.values,
          map['requestType'] as String? ?? '',
          GeneralRequestType.certificate,
        ),
        requesterName: map['requesterName'] as String? ?? 'Unknown',
        requesterType: map['requesterType'] as String? ?? 'volunteer',
        requestDate: map['requestDate'] as String? ?? '',
        status: enumValueOr(
          RequestStatus.values,
          map['status'] as String? ?? '',
          RequestStatus.pending,
        ),
        details: map['details'] as String? ?? '',
        approvedBy: map['approvedBy'] as String?,
        approvedAt: map['approvedAt'] as String?,
        requesterId: map['requesterId'] as String?,
      );

  T enumValueOr<T extends Enum>(List<T> values, String name, T fallback) {
    try {
      return values.firstWhere((e) => e.name == name);
    } catch (_) {
      return fallback;
    }
  }
}
