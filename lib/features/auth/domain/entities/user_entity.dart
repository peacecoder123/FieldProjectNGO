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
    this.fcmToken,
    this.inviteEmailSentAt,
  });

  final String    id; // Changed to String
  final String    name;
  final String    email;
  final UserRole  role;
  final String?   avatar;
  final String?   fcmToken; // From merged3
  final DateTime? inviteEmailSentAt; // From main

  /// One or two-character initials used for the avatar widget.
  /// Falls back to derived initials if not supplied.
  String get displayAvatar {
    if (avatar != null && avatar!.isNotEmpty) return avatar!;
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  UserEntity copyWith({
    String?    id,
    String?    name,
    String?    email,
    UserRole?  role,
    String?    avatar,
    String?    fcmToken,
    DateTime?  inviteEmailSentAt,
  }) {
    return UserEntity(
      id:                id                ?? this.id,
      name:              name              ?? this.name,
      email:             email             ?? this.email,
      role:              role              ?? this.role,
      avatar:            avatar            ?? this.avatar,
      fcmToken:          fcmToken          ?? this.fcmToken,
      inviteEmailSentAt: inviteEmailSentAt ?? this.inviteEmailSentAt,
    );
  }

  // ── Equatable ──────────────────────────────────────────────────────────────
  @override
  List<Object?> get props => [id, name, email, role, avatar, fcmToken, inviteEmailSentAt];

  // ── Serialisation ───────────────────────────────────────────────────────
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id:       (json['id'] ?? '').toString(),
      name:     json['name']   as String,
      email:    json['email']  as String,
      role:     UserRole.values.firstWhere(
        (r) => r.name.toLowerCase() == (json['role'] as String? ?? '').toLowerCase().trim(),
        orElse: () => UserRole.volunteer,
      ),
      avatar:   json['avatar'] as String?,
      fcmToken: json['fcmToken'] as String?,
      inviteEmailSentAt: json['inviteEmailSentAt'] != null
          ? (json['inviteEmailSentAt'] is String
              ? DateTime.tryParse(json['inviteEmailSentAt'])
              : (json['inviteEmailSentAt'] as dynamic).toDate())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':                id,
    'name':              name,
    'email':             email,
    'role':              role.name,
    'avatar':            avatar,
    'fcmToken':          fcmToken,
    'inviteEmailSentAt': inviteEmailSentAt?.toIso8601String(),
  };
}