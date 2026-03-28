import 'package:equatable/equatable.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';

/// Immutable user entity used across all features.
///
/// Mirrors the `currentUser` shape in the React `AppContext`:
/// ```ts
/// { id, name, email, avatar, role }
/// ```
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
  });

  final int      id;
  final String   name;
  final String   email;
  final UserRole role;

  /// One or two-character initials used for the avatar widget.
  /// Falls back to derived initials if not supplied.
  final String? avatar;

  String get displayAvatar {
    if (avatar != null && avatar!.isNotEmpty) return avatar!;
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  UserEntity copyWith({
    int?      id,
    String?   name,
    String?   email,
    UserRole? role,
    String?   avatar,
  }) {
    return UserEntity(
      id:     id     ?? this.id,
      name:   name   ?? this.name,
      email:  email  ?? this.email,
      role:   role   ?? this.role,
      avatar: avatar ?? this.avatar,
    );
  }

  // ── Equatable ──────────────────────────────────────────────────────────────
  @override
  List<Object?> get props => [id, name, email, role, avatar];

  // ── Serialisation (kept minimal — mock data only for now) ─────────────────
  factory UserEntity.fromJson(Map<String, dynamic> json) => UserEntity(
    id:     json['id']     as int,
    name:   json['name']   as String,
    email:  json['email']  as String,
    role:   UserRole.values.firstWhere(
      (r) => r.name == json['role'],
      orElse: () => UserRole.volunteer,
    ),
    avatar: json['avatar'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id':     id,
    'name':   name,
    'email':  email,
    'role':   role.name,
    'avatar': avatar,
  };
}