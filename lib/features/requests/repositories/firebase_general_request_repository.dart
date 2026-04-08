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
    return snapshot.docs.map((doc) => _fromMap(doc.data())).toList();
  }

  @override
  Stream<List<GeneralRequestEntity>> watchAll() {
    return _db.collection(_collectionPath).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => _fromMap(doc.data())).toList();
    });
  }

  @override
  Future<GeneralRequestEntity> add(GeneralRequestEntity request) async {
    await _db
        .collection(_collectionPath)
        .doc(request.id.toString())
        .set(_toMap(request));
    return request;
  }

  @override
  Future<GeneralRequestEntity> updateStatus(int id, RequestStatus status) async {
    await _db
        .collection(_collectionPath)
        .doc(id.toString())
        .update({'status': status.name});
    final doc = await _db.collection(_collectionPath).doc(id.toString()).get();
    return _fromMap(doc.data()!);
  }

  Map<String, dynamic> _toMap(GeneralRequestEntity r) => {
        'id': r.id,
        'requestType': r.requestType.name,
        'requesterName': r.requesterName,
        'requesterType': r.requesterType,
        'requestDate': r.requestDate,
        'status': r.status.name,
        'details': r.details,
      };

  GeneralRequestEntity _fromMap(Map<String, dynamic> map) => GeneralRequestEntity(
        id: map['id'] as int,
        requestType: enumValueOr(
          GeneralRequestType.values,
          map['requestType'] as String,
          GeneralRequestType.certificate,
        ),
        requesterName: map['requesterName'] as String,
        requesterType: map['requesterType'] as String,
        requestDate: map['requestDate'] as String,
        status: enumValueOr(
          RequestStatus.values,
          map['status'] as String,
          RequestStatus.pending,
        ),
        details: map['details'] as String,
      );

  T enumValueOr<T extends Enum>(List<T> values, String name, T fallback) {
    try {
      return values.firstWhere((e) => e.name == name);
    } catch (_) {
      return fallback;
    }
  }
}
