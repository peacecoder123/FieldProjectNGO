import 'package:flutter/material.dart';

import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';

/// Coloured initials avatar.
///
/// Mirrors the React `<Avatar initials={...} size={...} />` component.
/// The background colour is deterministically derived from the initials string
/// so the same user always gets the same colour (matches React behaviour).
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.initials,
    this.size = AvatarSize.medium,
    this.role,
  });

  final String     initials;
  final AvatarSize size;

  /// When provided, uses the role gradient instead of the initials-derived
  /// colour — used for the current-user avatar in the sidebar / header.
  final UserRole? role;

  @override
  Widget build(BuildContext context) {
    final dimension = switch (size) {
      AvatarSize.small  => 28.0,
      AvatarSize.medium => 36.0,
      AvatarSize.large  => 48.0,
      AvatarSize.xlarge => 56.0,
    };

    final fontSize = switch (size) {
      AvatarSize.small  => 11.0,
      AvatarSize.medium => 13.0,
      AvatarSize.large  => 16.0,
      AvatarSize.xlarge => 20.0,
    };

    final decoration = role != null
        ? BoxDecoration(
            gradient: _roleColors(role!),
            borderRadius: BorderRadius.circular(dimension / 2),
          )
        : BoxDecoration(
            color: _colorFromInitials(initials),
            borderRadius: BorderRadius.circular(dimension / 2),
          );

    return Container(
      width: dimension,
      height: dimension,
      decoration: decoration,
      alignment: Alignment.center,
      child: Text(
        initials.length > 2 ? initials.substring(0, 2) : initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Derives a consistent colour from the first character of [initials].
  /// Matches the `colors[initials.charCodeAt(0) % colors.length]` logic
  /// from the React source.
  static Color _colorFromInitials(String initials) {
    const colors = [
      AppColors.blue500,
      AppColors.purple500,
      AppColors.emerald500,
      AppColors.orange500,
      AppColors.rose500,
      AppColors.cyan500,
    ];
    if (initials.isEmpty) return colors[0];
    return colors[initials.codeUnitAt(0) % colors.length];
  }

  static LinearGradient _roleColors(UserRole role) => switch (role) {
    UserRole.superAdmin => AppColors.superAdminGradient,
    UserRole.admin      => AppColors.adminGradient,
    UserRole.member     => AppColors.memberGradient,
    UserRole.volunteer  => AppColors.volunteerGradient,
  };
}

enum AvatarSize { small, medium, large, xlarge }