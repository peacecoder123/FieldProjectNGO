import 'package:flutter/material.dart';

import 'app_card.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';

/// Metric tile used on the Admin Overview dashboard.
///
/// Mirrors the React `<StatCard title value subtitle icon color trend />`.
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Icon + trend ─────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: icon,
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: trendUp
                        ? AppColors.emerald100
                        : AppColors.red100,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trendUp
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: 10,
                        color: trendUp
                            ? AppColors.emerald600
                            : AppColors.red600,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        trend!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: trendUp
                              ? AppColors.emerald600
                              : AppColors.red600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Value ────────────────────────────────────────────────────────
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.white : AppColors.slate900,
            ),
          ),

          const SizedBox(height: 2),

          // ── Title ────────────────────────────────────────────────────────
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.slate400 : AppColors.slate500,
            ),
          ),

          // ── Subtitle ─────────────────────────────────────────────────────
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.slate500 : AppColors.slate400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}