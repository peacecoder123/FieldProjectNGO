import 'package:flutter/material.dart';

import 'package:ngo_volunteer_management/app/theme/app_colors.dart';

/// Section title + optional subtitle + optional action button row.
///
/// Mirrors the React `<SectionHeader title subtitle actions />`.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    this.title,
    this.subtitle,
    this.actions,
  });

  final String? title;
  final String? subtitle;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          final headerContent = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null)
                Text(
                  title!,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: isDark ? AppColors.white : AppColors.brand,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.slate400 : AppColors.slate500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          );

          if (!isWide && actions != null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                headerContent,
                const SizedBox(height: 16),
                actions!,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: headerContent),
              if (actions != null) ...[
                const SizedBox(width: 16),
                actions!,
              ],
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Centred empty-state illustration with icon, title, and optional subtitle.
///
/// Mirrors the React `<EmptyState icon title subtitle />`.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  final IconData icon;
  final String   title;
  final String?  subtitle;
  final Widget?  action;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDark ? AppColors.slate700 : AppColors.slate100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 28,
                color: isDark ? AppColors.slate500 : AppColors.slate400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: isDark ? AppColors.slate300 : AppColors.slate600,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.slate500 : AppColors.slate400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}