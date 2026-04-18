import 'package:flutter/material.dart';

import 'app_card.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';

/// Compact metric tile for the Admin/Admin dashboard.
/// Icon (top-left) → value → title, no wasted vertical space.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconBackground,
    this.subtitle,
    this.trend,
    this.trendUp = true,
  });

  final String  title;
  final String  value;
  final Widget  icon;
  final Color   iconBackground;
  final String? subtitle;
  final String? trend;
  final bool    trendUp;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Icon + trend ─────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: SizedBox(width: 16, height: 16, child: icon),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: trendUp
                        ? (isDark
                            ? AppColors.emerald700.withValues(alpha: 0.3)
                            : AppColors.emerald100)
                        : (isDark
                            ? AppColors.red600.withValues(alpha: 0.3)
                            : AppColors.red100),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trendUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                        size: 7,
                        color: trendUp
                            ? (isDark ? AppColors.emerald400 : AppColors.emerald600)
                            : (isDark ? AppColors.red500 : AppColors.red600),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        trend!,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: trendUp
                              ? (isDark ? AppColors.emerald400 : AppColors.emerald600)
                              : (isDark ? AppColors.red500 : AppColors.red600),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // ── Value + title ────────────────────────────────
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.white : AppColors.slate900,
              fontSize: 18,
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          // Title
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.slate400 : AppColors.slate500,
              height: 1.2,
            ),
          ),
          // Subtitle
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? AppColors.slate500 : AppColors.slate400,
                height: 1.2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
