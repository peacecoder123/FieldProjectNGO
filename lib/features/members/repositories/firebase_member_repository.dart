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
    return snapshot.docs.map((doc) => _fromMap(doc.id, doc.data())).toList();
  }

  @override
  Stream<List<MemberEntity>> watchAll() {
    return _db.collection(_collectionPath).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => _fromMap(doc.id, doc.data())).toList();
    });
  }

  @override
  Future<MemberEntity?> getById(String id) async {
    final doc = await _db.collection(_collectionPath).doc(id).get();
    if (!doc.exists) return null;
    return _fromMap(doc.id, doc.data()!);
  }

  @override
  Stream<MemberEntity?> watchById(String id) {
    return _db.collection(_collectionPath).doc(id).snapshots().map(
      (snap) => snap.exists ? _fromMap(snap.id, snap.data()!) : null,
    );
  }

  @override
  Future<MemberEntity> add(MemberEntity member) async {
    final docRef = await _db.collection(_collectionPath).add(_toMap(member));
    return member.copyWith(id: docRef.id);
  }

  @override
  Future<MemberEntity> update(MemberEntity member) async {
    await _db
        .collection(_collectionPath)
        .doc(member.id)
        .update(_toMap(member));
    return member;
  }

  @override
  Future<void> delete(String id) async {
    await _db.collection(_collectionPath).doc(id).delete();
  }

  Map<String, dynamic> _toMap(MemberEntity m) => {
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

  MemberEntity _fromMap(String id, Map<String, dynamic> map) => MemberEntity(
        id: id,
        name: map['name'] as String? ?? 'Unknown',
        email: map['email'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        address: map['address'] as String? ?? '',
        joinDate: map['joinDate'] as String? ?? '',
        renewalDate: map['renewalDate'] as String? ?? '',
        status: PersonStatus.fromString(map['status'] as String? ?? 'pending'),
        membershipType: enumValueOr(
          MembershipType.values,
          map['membershipType'] as String? ?? '',
          MembershipType.nonEightyG,
        ),
        taskIds: (map['taskIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        isPaid: map['isPaid'] as bool? ?? false,
        avatar: map['avatar'] as String? ?? '',
      );

  T enumValueOr<T extends Enum>(List<T> values, String name, T fallback) {
    try {
      return values.firstWhere((e) => e.name == name);
    } catch (_) {
      return fallback;
    }
  }
}
