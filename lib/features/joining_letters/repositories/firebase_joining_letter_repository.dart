import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/shared/data/entities.dart';
import 'package:ngo_volunteer_management/shared/data/repositories.dart';

class FirebaseJoiningLetterRepository implements IJoiningLetterRepository {
  final String _collectionPath = 'joining_letter_requests';
  FirebaseFirestore? _firestore;

  FirebaseJoiningLetterRepository() {
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
  Future<List<JoiningLetterRequestEntity>> getAll() async {
    final snapshot = await _db.collection(_collectionPath).get();
    return snapshot.docs.map((doc) => _fromMap(doc.id, doc.data())).toList();
  }

  @override
  Stream<List<JoiningLetterRequestEntity>> watchAll() {
    return _db.collection(_collectionPath).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => _fromMap(doc.id, doc.data())).toList();
    });
  }

  @override
  Future<JoiningLetterRequestEntity> add(JoiningLetterRequestEntity request) async {
    final docRef = await _db.collection(_collectionPath).add(_toMap(request));
    return request.copyWith(id: docRef.id);
  }

  @override
  Future<JoiningLetterRequestEntity> partiallyApprove(String id) async {
    await _db.collection(_collectionPath).doc(id).update({
      'status': RequestStatus.waitingAdmin.name,
    });
    final doc = await _db.collection(_collectionPath).doc(id).get();
    return _fromMap(doc.id, doc.data()!);
  }

  @override
  Future<JoiningLetterRequestEntity> approve(
    String id, {
    required String generatedBy,
    required String tenure,
  }) async {
    await _db.collection(_collectionPath).doc(id).update({
      'status': RequestStatus.approved.name,
      'generatedBy': generatedBy,
      'tenure': tenure,
    });
    final doc = await _db.collection(_collectionPath).doc(id).get();
    return _fromMap(doc.id, doc.data()!);
  }

  @override
  Future<JoiningLetterRequestEntity> reject(String id) async {
    await _db.collection(_collectionPath).doc(id).update({
      'status': RequestStatus.rejected.name,
    });
    final doc = await _db.collection(_collectionPath).doc(id).get();
    return _fromMap(doc.id, doc.data()!);
  }

  Map<String, dynamic> _toMap(JoiningLetterRequestEntity r) => {
        'name': r.name,
        'type': r.type.name,
        'requestDate': r.requestDate,
        'status': r.status.name,
        'tenure': r.tenure,
        'isNewMember': r.isNewMember,
        if (r.generatedBy != null) 'generatedBy': r.generatedBy,
      };

  JoiningLetterRequestEntity _fromMap(String id, Map<String, dynamic> map) => JoiningLetterRequestEntity(
        id: id,
        name: map['name'] as String? ?? 'Unknown',
        type: enumValueOr(
          JoiningLetterType.values,
          map['type'] as String? ?? '',
          JoiningLetterType.volunteer,
        ),
        requestDate: map['requestDate'] as String? ?? '',
        status: enumValueOr(
          RequestStatus.values,
          map['status'] as String? ?? '',
          RequestStatus.pending,
        ),
        tenure: map['tenure'] as String? ?? '',
        isNewMember: map['isNewMember'] as bool? ?? false,
        generatedBy: map['generatedBy'] as String?,
      );

  T enumValueOr<T extends Enum>(List<T> values, String name, T fallback) {
    try {
      return values.firstWhere((e) => e.name == name);
    } catch (_) {
      return fallback;
    }
  }
}
