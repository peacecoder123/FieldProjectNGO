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
    final snapshot = await _db.collection(_collectionPath).get();
    return snapshot.docs.map((doc) => _fromMap(doc.data())).toList();
  }

  @override
  Stream<List<MouRequestEntity>> watchAll() {
    return _db.collection(_collectionPath).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => _fromMap(doc.data())).toList();
    });
  }

  @override
  Future<MouRequestEntity> add(MouRequestEntity request) async {
    await _db
        .collection(_collectionPath)
        .doc(request.id.toString())
        .set(_toMap(request));
    return request;
  }

  @override
  Future<MouRequestEntity> updateStatus(int id, RequestStatus status) async {
    await _db.collection(_collectionPath).doc(id.toString()).update({'status': status.name});
    final doc = await _db.collection(_collectionPath).doc(id.toString()).get();
    return _fromMap(doc.data()!);
  }

  Map<String, dynamic> _toMap(MouRequestEntity r) => {
        'id': r.id,
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
      };

  MouRequestEntity _fromMap(Map<String, dynamic> map) => MouRequestEntity(
        id: map['id'] as int,
        patientName: map['patientName'] as String,
        patientAge: map['patientAge'] as int,
        disease: map['disease'] as String,
        hospital: map['hospital'] as String,
        requestDate: map['requestDate'] as String,
        status: enumValueOr(
          RequestStatus.values,
          map['status'] as String,
          RequestStatus.pending,
        ),
        requesterName: map['requesterName'] as String,
        phone: map['phone'] as String,
        address: map['address'] as String,
        bloodGroup: map['bloodGroup'] as String,
      );

  T enumValueOr<T extends Enum>(List<T> values, String name, T fallback) {
    try {
      return values.firstWhere((e) => e.name == name);
    } catch (_) {
      return fallback;
    }
  }
}
