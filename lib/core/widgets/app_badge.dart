import 'package:flutter/material.dart';

import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';

/// Pill-shaped status badge.
///
/// Mirrors the React `<Badge status={...} />` component in UIComponents.tsx.
/// Supports every status string used in the original app.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.color,
    this.textColor,
  });

  /// Construct from a [TaskStatus] enum value.
  factory AppBadge.taskStatus(TaskStatus status) => AppBadge(
        label: status.displayName,
        color: _taskStatusBg[status],
        textColor: _taskStatusFg[status],
      );

  /// Construct from a [RequestStatus] enum value.
  factory AppBadge.requestStatus(RequestStatus status) => AppBadge(
        label: status.displayName,
        color: _requestStatusBg[status],
        textColor: _requestStatusFg[status],
      );

  /// Construct from a [PersonStatus] enum value.
  factory AppBadge.personStatus(PersonStatus status) => AppBadge(
        label: status.name,
        color: status == PersonStatus.active
            ? AppColors.emerald100
            : AppColors.slate100,
        textColor: status == PersonStatus.active
            ? AppColors.emerald600
            : AppColors.slate600,
      );

  /// Construct from a [MembershipType] enum value.
  factory AppBadge.membershipType(MembershipType type) => AppBadge(
        label: type.displayLabel,
        color: type == MembershipType.eightyG
            ? AppColors.purple100
            : AppColors.slate100,
        textColor: type == MembershipType.eightyG
            ? AppColors.purple600
            : AppColors.slate600,
      );

  /// Construct from a [MeetingStatus] enum value.
  factory AppBadge.meetingStatus(MeetingStatus status) => AppBadge(
        label: status.name,
        color: status == MeetingStatus.upcoming
            ? AppColors.blue100
            : AppColors.emerald100,
        textColor: status == MeetingStatus.upcoming
            ? AppColors.blue600
            : AppColors.emerald600,
      );

  final String label;
  final Color? color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = (isDark ? _toDark(color) : color) ??
        AppColors.slate100;
    final fg = (isDark ? _toDarkFg(textColor) : textColor) ??
        AppColors.slate600;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  // ── Dark mode colour transforms ───────────────────────────────────────────

  static Color? _toDark(Color? light) {
    if (light == null) return null;
    // Apply a dark-mode overlay: use the same hue but semi-transparent
    return light.withValues(alpha: 0.2);
  }

  static Color? _toDarkFg(Color? light) {
    if (light == null) return null;
    // Lighten the foreground for dark mode
    return Color.lerp(light, AppColors.white, 0.3);
  }

  // ── Colour maps ───────────────────────────────────────────────────────────

  static const _taskStatusBg = {
    TaskStatus.pending   : AppColors.amber100,
    TaskStatus.submitted : AppColors.blue100,
    TaskStatus.approved  : AppColors.emerald100,
    TaskStatus.rejected  : AppColors.red100,
  };

  static const _taskStatusFg = {
    TaskStatus.pending   : AppColors.amber600,
    TaskStatus.submitted : AppColors.blue600,
    TaskStatus.approved  : AppColors.emerald600,
    TaskStatus.rejected  : AppColors.red600,
  };

  static const _requestStatusBg = {
    RequestStatus.pending  : AppColors.amber100,
    RequestStatus.approved : AppColors.emerald100,
    RequestStatus.rejected : AppColors.red100,
  };

  static const _requestStatusFg = {
    RequestStatus.pending  : AppColors.amber600,
    RequestStatus.approved : AppColors.emerald600,
    RequestStatus.rejected : AppColors.red600,
  };
}