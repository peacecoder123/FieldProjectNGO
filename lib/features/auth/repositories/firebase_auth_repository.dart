import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/features/auth/domain/entities/user_entity.dart';
import 'package:ngo_volunteer_management/shared/data/repositories.dart';

/// Real Firebase Auth — validates email/password against the Firestore `users` collection.
///
/// A user document must contain: name, email, password, role
class FirebaseAuthRepository implements IAuthRepository {
  final String _collectionPath = 'users';
  FirebaseFirestore? _firestore;

  FirebaseAuthRepository() {
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
  Future<UserEntity?> login({
    required String email,
    required String password,
  }) async {
    final snapshot = await _db
        .collection(_collectionPath)
        .where('email', isEqualTo: email.toLowerCase().trim())
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    final data = doc.data();
    if (data['password'] != password) return null;

    final rawId = doc.id;
    final userId = int.tryParse(rawId) ?? (data['id'] is int ? data['id'] as int : rawId.hashCode);

    return UserEntity(
      id: userId,
      name: data['name'] ?? '',
      email: data['email'] ?? email,
      role: _roleFromString(data['role'] ?? 'admin'),
      avatar: data['avatar'] as String?,
    );
  }

  @override
  Future<void> logout() async {}

  @override
  Stream<UserEntity?> watchAuthState() async* {
    yield null;
  }

  UserRole _roleFromString(String role) {
    return UserRole.values.firstWhere(
      (r) => r.name == role.toLowerCase(),
      orElse: () => UserRole.admin,
    );
  }
}
