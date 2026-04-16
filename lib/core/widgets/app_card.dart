import 'package:flutter/material.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';

/// Bordered card that mirrors the React `<Card className="p-4 ...">` component.
///
/// Automatically adapts background and border to the current theme.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.elevation = 0,
    this.borderRadius = 12,
  });

  final Widget  child;
  final EdgeInsetsGeometry padding;
  final VoidCallback?      onTap;
  final double             elevation;
  final double             borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final card = Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : AppColors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isDark
              ? AppColors.slate700
              : AppColors.slate200,
          width: 0.8,
        ),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: elevation * 6,
                  offset: Offset(0, elevation * 1.5),
                  spreadRadius: -elevation,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                  spreadRadius: -4,
                ),
              ],
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return card;

    return GestureDetector(
      onTap: onTap,
      child: card,
    );
  }
}