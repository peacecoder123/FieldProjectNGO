import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/features/auth/domain/entities/user_entity.dart';
import 'package:ngo_volunteer_management/shared/data/repositories.dart';

/// Real Firebase Auth — integrates Google Sign-In with Firestore whitelisting.
///
/// A user document must exist in `users` with their email mapped to their role
class FirebaseAuthRepository implements IAuthRepository {
  final String _collectionPath = 'users';
  FirebaseFirestore? _firestore;
  late final auth.FirebaseAuth _firebaseAuth;
  late final GoogleSignIn _googleSignIn;

  FirebaseAuthRepository() {
    _firebaseAuth = auth.FirebaseAuth.instance;
    _googleSignIn = GoogleSignIn(
      clientId: '1093449762008-placeholder.apps.googleusercontent.com',
    );
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
    // Keep email/password login as legacy/backup.
    final snapshot = await _db
        .collection(_collectionPath)
        .where('email', isEqualTo: email.toLowerCase().trim())
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    final data = doc.data();
    if (data['password'] != password) return null;

    return _userFromDoc(doc);
  }

  @override
  Future<UserEntity?> loginWithGoogle() async {
    try {
      if (kIsWeb) {
         // Optionally handle web signin specifics if needed
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled sign in

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase Auth
      final auth.UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final auth.User? user = userCredential.user;

      if (user == null || user.email == null) {
        await _googleSignIn.disconnect();
        await _firebaseAuth.signOut();
        throw Exception("Could not retrieve email from Google Sign-In.");
      }

      final email = user.email!.toLowerCase().trim();

      // Check Firestore Whitelist
      final snapshot = await _db
          .collection(_collectionPath)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        // Not whitelisted! Rollback login
        await _googleSignIn.disconnect();
        await _firebaseAuth.signOut();
        throw Exception("Access Denied: Your email ($email) is not whitelisted. Please contact the administrator.");
      }

      final doc = snapshot.docs.first;
      return _userFromDoc(doc);
    } catch (e) {
      debugPrint("Google Sign in error: $e");
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

  @override
  Stream<UserEntity?> watchAuthState() async* {
    // Basic stub. Real apps listen to _firebaseAuth.authStateChanges() and map it
    yield null;
  }

  UserEntity _userFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final rawId = doc.id;
    final userId = int.tryParse(rawId) ?? (data['id'] is int ? data['id'] as int : rawId.hashCode);

    return UserEntity(
      id: userId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: _roleFromString(data['role'] ?? 'admin'),
      avatar: data['avatar'] as String?,
    );
  }

  @override
  Future<void> updateFcmToken(int userId, String? token) async {
    try {
      await _db.collection(_collectionPath).doc(userId.toString()).update({
        'fcmToken': token,
      });
      debugPrint('Sync: FCM token updated for user $userId');
    } catch (e) {
      debugPrint('Sync Error: Failed to update FCM token: $e');
    }
  }

  UserRole _roleFromString(String role) {
    switch (role) {
      case 'superAdmin': return UserRole.superAdmin;
      case 'admin':      return UserRole.admin;
      case 'member':     return UserRole.member;
      case 'volunteer':  return UserRole.volunteer;
      default:           return UserRole.volunteer;
    }
  }
}
