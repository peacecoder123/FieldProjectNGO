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
      clientId: kIsWeb ? '1093449762008-vau99kj7q90uou7aau2esvidn9unl2ak.apps.googleusercontent.com' : null,
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
        await _googleSignIn.signOut(); // Use signOut instead of disconnect to allow retry
        await _firebaseAuth.signOut();
        throw Exception("Whitelisting Required: The email '$email' is not in the Jayashree Foundation database. Please add it to the 'users' collection in Firestore first.");
      }

      final doc = snapshot.docs.first;
      return _userFromDoc(doc);
    } on auth.FirebaseAuthException catch (e) {
      debugPrint("Firebase Auth Error: ${e.code} - ${e.message}");
      throw Exception("Authentication Service Error: ${e.message}");
    } catch (e) {
      debugPrint("Google Sign in error: $e");
      if (e.toString().contains('Exception:')) rethrow;
      throw Exception("Google Sign-In was interrupted or failed. Please check your internet and try again.");
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
    final userId = doc.id;

    return UserEntity(
      id: userId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: _roleFromString(data['role'] ?? 'admin'),
      avatar: data['avatar'] as String?,
    );
  }

  @override
  Future<void> updateFcmToken(String userId, String? token) async {
    try {
      await _db.collection(_collectionPath).doc(userId).update({
        'fcmToken': token,
      });
      debugPrint('Sync: FCM token updated for user $userId');
    } catch (e) {
      debugPrint('Sync Error: Failed to update FCM token: $e');
    }
  }

  UserRole _roleFromString(String role) {
    return UserRole.values.firstWhere(
      (r) => r.name.toLowerCase() == role.toLowerCase().trim(),
      orElse: () => UserRole.volunteer,
    );
  }
}
