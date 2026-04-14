import 'package:flutter/material.dart';

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isDark
              ? const Color(0xFF334155) // slate-700
              : const Color(0xFFE2E8F0), // slate-200
        ),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: elevation * 4,
                  offset: Offset(0, elevation),
                ),
              ]
            : null,
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