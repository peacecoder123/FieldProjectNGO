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
    return snapshot.docs.map((doc) => _fromMap(doc.id, doc.data())).toList();
  }

  @override
  Stream<List<VolunteerEntity>> watchAll() {
    return _db.collection(_collectionPath).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => _fromMap(doc.id, doc.data())).toList();
    });
  }

  @override
  Future<VolunteerEntity?> getById(String id) async {
    final doc = await _db.collection(_collectionPath).doc(id).get();
    if (!doc.exists) return null;
    return _fromMap(doc.id, doc.data()!);
  }

  @override
  Stream<VolunteerEntity?> watchById(String id) {
    return _db.collection(_collectionPath).doc(id).snapshots().map(
      (snap) => snap.exists ? _fromMap(snap.id, snap.data()!) : null,
    );
  }

  @override
  Future<VolunteerEntity> add(VolunteerEntity volunteer) async {
    // Check for duplicate email
    final emailDup = await _db
        .collection(_collectionPath)
        .where('email', isEqualTo: volunteer.email.toLowerCase().trim())
        .get();
    if (emailDup.docs.isNotEmpty) {
      throw Exception('A volunteer with the email ${volunteer.email} already exists.');
    }

    // Check for duplicate phone (if provided)
    if (volunteer.phone.isNotEmpty) {
      final phoneDup = await _db
          .collection(_collectionPath)
          .where('phone', isEqualTo: volunteer.phone.trim())
          .get();
      if (phoneDup.docs.isNotEmpty) {
        throw Exception('A volunteer with the phone number ${volunteer.phone} already exists.');
      }
    }

    final docRef = await _db.collection(_collectionPath).add(_toMap(volunteer));
    return volunteer.copyWith(id: docRef.id);
  }

  @override
  Future<VolunteerEntity> update(VolunteerEntity volunteer) async {
    await _db
        .collection(_collectionPath)
        .doc(volunteer.id)
        .update(_toMap(volunteer));
    return volunteer;
  }

  @override
  Future<void> delete(String id) async {
    await _db.collection(_collectionPath).doc(id).delete();
  }

  Map<String, dynamic> _toMap(VolunteerEntity v) => {
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
        if (v.mentorId != null) 'mentorId': v.mentorId,
        if (v.mentorName != null) 'mentorName': v.mentorName,
      };


  VolunteerEntity _fromMap(String id, Map<String, dynamic> map) => VolunteerEntity(
        id: id,
        name: map['name'] as String? ?? 'Unknown',
        email: map['email'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        address: map['address'] as String? ?? '',
        joinDate: map['joinDate'] as String? ?? '',
        status: PersonStatus.fromString(map['status'] as String? ?? 'pending'),
        assignedAdmin: map['assignedAdmin'] as String? ?? '',
        taskIds: (map['taskIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        tenure: map['tenure'] as String? ?? '',
        skills: (map['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        avatar: map['avatar'] as String? ?? '',
        mentorId: map['mentorId']?.toString(),
        mentorName: map['mentorName'] as String?,
      );

}
