import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/shared/data/entities.dart';
import 'package:ngo_volunteer_management/shared/data/repositories.dart';

class FirebaseMemberRepository implements IMemberRepository {
  final String _collectionPath = 'members';
  FirebaseFirestore? _firestore;

  FirebaseMemberRepository() {
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
  Future<List<MemberEntity>> getAll() async {
    final snapshot = await _db.collection(_collectionPath).get();
    return snapshot.docs.map((doc) => _fromMap(doc.data())).toList();
  }

  @override
  Stream<List<MemberEntity>> watchAll() {
    return _db.collection(_collectionPath).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => _fromMap(doc.data())).toList();
    });
  }

  @override
  Future<MemberEntity?> getById(int id) async {
    final doc = await _db.collection(_collectionPath).doc(id.toString()).get();
    if (!doc.exists) return null;
    return _fromMap(doc.data()!);
  }

  @override
  Stream<MemberEntity?> watchById(int id) {
    return _db.collection(_collectionPath).doc(id.toString()).snapshots().map(
      (snap) => snap.exists ? _fromMap(snap.data()!) : null,
    );
  }

  @override
  Future<MemberEntity> add(MemberEntity member) async {
    await _db
        .collection(_collectionPath)
        .doc(member.id.toString())
        .set(_toMap(member));
    return member;
  }

  @override
  Future<MemberEntity> update(MemberEntity member) async {
    await _db
        .collection(_collectionPath)
        .doc(member.id.toString())
        .update(_toMap(member));
    return member;
  }

  @override
  Future<void> delete(int id) async {
    await _db.collection(_collectionPath).doc(id.toString()).delete();
  }

  Map<String, dynamic> _toMap(MemberEntity m) => {
        'id': m.id,
        'name': m.name,
        'email': m.email,
        'phone': m.phone,
        'address': m.address,
        'joinDate': m.joinDate,
        'renewalDate': m.renewalDate,
        'status': m.status.name,
        'membershipType': m.membershipType.name,
        'taskIds': m.taskIds,
        'isPaid': m.isPaid,
        'avatar': m.avatar,
      };

  MemberEntity _fromMap(Map<String, dynamic> map) => MemberEntity(
        id: map['id'] as int,
        name: map['name'] as String,
        email: map['email'] as String,
        phone: map['phone'] as String,
        address: map['address'] as String,
        joinDate: map['joinDate'] as String,
        renewalDate: map['renewalDate'] as String,
        status: PersonStatus.fromString(map['status'] as String),
        membershipType: enumValueOr(
          MembershipType.values,
          map['membershipType'] as String,
          MembershipType.nonEightyG,
        ),
        taskIds: (map['taskIds'] as List<dynamic>).cast<int>(),
        isPaid: map['isPaid'] as bool,
        avatar: map['avatar'] as String,
      );

  T enumValueOr<T extends Enum>(List<T> values, String name, T fallback) {
    try {
      return values.firstWhere((e) => e.name == name);
    } catch (_) {
      return fallback;
    }
  }
}
