import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/shared/data/entities.dart';
import 'package:ngo_volunteer_management/shared/data/repositories.dart';

class FirebaseMouRequestRepository implements IMouRequestRepository {
  final String _collectionPath = 'mou_requests';
  FirebaseFirestore? _firestore;

  FirebaseMouRequestRepository() {
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
  Future<List<MouRequestEntity>> getAll() async {
    final snapshot = await _db.collection(_collectionPath).orderBy('requestDate', descending: true).get();
    return snapshot.docs.map((doc) => _fromMap(doc.id, doc.data())).toList();
  }

  @override
  Stream<List<MouRequestEntity>> watchAll() {
    return _db.collection(_collectionPath).orderBy('requestDate', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => _fromMap(doc.id, doc.data())).toList();
    });
  }

  @override
  Future<MouRequestEntity> add(MouRequestEntity request) async {
    final docRef = await _db.collection(_collectionPath).add(_toMap(request));
    return request.copyWith(id: docRef.id);
  }

  @override
  Future<MouRequestEntity> updateStatus(
    String id,
    RequestStatus status, {
    String? approvedBy,
    String? certificateUrl,
  }) async {
    final Map<String, dynamic> updates = {'status': status.name};
    if (status == RequestStatus.approved) {
      if (approvedBy != null) updates['approvedBy'] = approvedBy;
      if (certificateUrl != null) updates['certificateUrl'] = certificateUrl;
      updates['approvedAt'] = DateTime.now().toIso8601String();
    }

    await _db.collection(_collectionPath).doc(id).update(updates);
    final doc = await _db.collection(_collectionPath).doc(id).get();
    return _fromMap(doc.id, doc.data()!);
  }
  Map<String, dynamic> _toMap(MouRequestEntity r) => {
        'patientName': r.patientName,
        'patientAge': r.patientAge,
        'disease': r.disease,
        'hospital': r.hospital,
        'requestDate': r.requestDate,
        'status': r.status.name,
        'requesterName': r.requesterName,
        'phone': r.phone,
        'address': r.address,
        'bloodGroup': r.bloodGroup,
        if (r.approvedBy != null) 'approvedBy': r.approvedBy,
        if (r.approvedAt != null) 'approvedAt': r.approvedAt,
        if (r.requesterId != null) 'requesterId': r.requesterId,
        if (r.certificateUrl != null) 'certificateUrl': r.certificateUrl,
      };

  MouRequestEntity _fromMap(String id, Map<String, dynamic> map) => MouRequestEntity(
        id: id,
        patientName: map['patientName'] as String? ?? 'Unknown',
        patientAge: map['patientAge'] as int? ?? 0,
        disease: map['disease'] as String? ?? '',
        hospital: map['hospital'] as String? ?? '',
        requestDate: map['requestDate'] as String? ?? '',
        status: enumValueOr(
          RequestStatus.values,
          map['status'] as String? ?? '',
          RequestStatus.pending,
        ),
        requesterName: map['requesterName'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        address: map['address'] as String? ?? '',
        bloodGroup: map['bloodGroup'] as String? ?? '',
        approvedBy: map['approvedBy'] as String?,
        approvedAt: map['approvedAt'] as String?,
        requesterId: map['requesterId'] as String?,
        certificateUrl: map['certificateUrl'] as String?,
      );

  T enumValueOr<T extends Enum>(List<T> values, String name, T fallback) {
    try {
      return values.firstWhere((e) => e.name == name);
    } catch (_) {
      return fallback;
    }
  }
}
