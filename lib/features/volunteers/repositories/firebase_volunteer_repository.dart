import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/shared/data/entities.dart';
import 'package:ngo_volunteer_management/shared/data/repositories.dart';

class FirebaseVolunteerRepository implements IVolunteerRepository {
  final String _collectionPath = 'volunteers';
  FirebaseFirestore? _firestore;

  FirebaseVolunteerRepository() {
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
  Future<List<VolunteerEntity>> getAll() async {
    final snapshot = await _db.collection(_collectionPath).get();
    return snapshot.docs.map((doc) => _fromMap(doc.data())).toList();
  }

  @override
  Stream<List<VolunteerEntity>> watchAll() {
    return _db.collection(_collectionPath).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => _fromMap(doc.data())).toList();
    });
  }

  @override
  Future<VolunteerEntity?> getById(int id) async {
    final doc = await _db.collection(_collectionPath).doc(id.toString()).get();
    if (!doc.exists) return null;
    return _fromMap(doc.data()!);
  }

  @override
  Stream<VolunteerEntity?> watchById(int id) {
    return _db.collection(_collectionPath).doc(id.toString()).snapshots().map(
      (snap) => snap.exists ? _fromMap(snap.data()!) : null,
    );
  }

  @override
  Future<VolunteerEntity> add(VolunteerEntity volunteer) async {
    await _db
        .collection(_collectionPath)
        .doc(volunteer.id.toString())
        .set(_toMap(volunteer));
    return volunteer;
  }

  @override
  Future<VolunteerEntity> update(VolunteerEntity volunteer) async {
    await _db
        .collection(_collectionPath)
        .doc(volunteer.id.toString())
        .update(_toMap(volunteer));
    return volunteer;
  }

  @override
  Future<void> delete(int id) async {
    await _db.collection(_collectionPath).doc(id.toString()).delete();
  }

  Map<String, dynamic> _toMap(VolunteerEntity v) => {
        'id': v.id,
        'name': v.name,
        'email': v.email,
        'phone': v.phone,
        'address': v.address,
        'joinDate': v.joinDate,
        'status': v.status.name,
        'assignedAdmin': v.assignedAdmin,
        'taskIds': v.taskIds,
        'tenure': v.tenure,
        'skills': v.skills,
        'avatar': v.avatar,
      };

  VolunteerEntity _fromMap(Map<String, dynamic> map) => VolunteerEntity(
        id: map['id'] as int,
        name: map['name'] as String,
        email: map['email'] as String,
        phone: map['phone'] as String,
        address: map['address'] as String,
        joinDate: map['joinDate'] as String,
        status: PersonStatus.fromString(map['status'] as String),
        assignedAdmin: map['assignedAdmin'] as String,
        taskIds: (map['taskIds'] as List<dynamic>).cast<int>(),
        tenure: map['tenure'] as String,
        skills: (map['skills'] as List<dynamic>).cast<String>(),
        avatar: map['avatar'] as String,
      );
}
