import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/features/auth/domain/entities/user_entity.dart';

class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'users';

  Stream<List<UserEntity>> watchUsers() {
    return _db.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => _fromDoc(doc)).toList();
    });
  }

  Future<void> addUser(UserEntity user) async {
    final existing = await _db
        .collection(_collection)
        .where('email', isEqualTo: user.email.toLowerCase().trim())
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('A user with the email ${user.email} already exists in the system.');
    }

    await _db.collection(_collection).add({
      'email': user.email.toLowerCase().trim(),
      'name': user.name,
      'role': user.role.name,
      'avatar': user.avatar,
      'password': 'password123', // Legacy support
    });
  }

  Future<void> updateUser(UserEntity user) async {
    final snapshot = await _db
        .collection(_collection)
        .where('email', isEqualTo: user.email.toLowerCase())
        .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'name': user.name,
        'role': user.role.name,
      });
    }
  }

  Future<void> removeUser(String email) async {
    final snapshot = await _db
        .collection(_collection)
        .where('email', isEqualTo: email.toLowerCase())
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  UserEntity _fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final roleStr = data['role'] as String? ?? 'volunteer';
    
    final role = UserRole.values.firstWhere(
      (r) => r.name == roleStr,
      orElse: () => UserRole.volunteer,
    );

    return UserEntity(
      id:     doc.id,
      email:  data['email'] ?? '',
      name:   data['name'] ?? '',
      role:   role,
      avatar: data['avatar'] ?? '',
    );
  }
}
