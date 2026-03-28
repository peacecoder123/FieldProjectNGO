import 'package:flutter/material.dart';

import 'package:ngo_volunteer_management/app/theme/app_colors.dart';

/// Adaptive modal:
/// • On mobile  → bottom sheet (slides up, matches React modal feel).
/// • On desktop → centred dialog (width-constrained).
///
/// Mirrors the React `<Modal title onClose size>` component from UIComponents.tsx.

enum ModalSize { small, medium, large, extraLarge }

class AppModal extends StatelessWidget {
  const AppModal({
    super.key,
    required this.title,
    required this.child,
    this.size = ModalSize.medium,
  });

  final String    title;
  final Widget    child;
  final ModalSize size;

  /// Helper to show this modal from anywhere.
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    ModalSize size = ModalSize.medium,
  }) {
    final isWide =
        MediaQuery.of(context).size.width >= 600;

    if (isWide) {
      return showDialog<T>(
        context: context,
        builder: (_) => AppModal(title: title, child: child, size: size),
      );
    } else {
      return showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _BottomSheetWrapper(
          title: title,
          child: child,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = switch (size) {
      ModalSize.small      => 400.0,
      ModalSize.medium     => 520.0,
      ModalSize.large      => 720.0,
      ModalSize.extraLarge => 960.0,
    };

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.slate800 : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModalHeader(title: title, isDark: isDark),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────

class _ModalHeader extends StatelessWidget {
  const _ModalHeader({required this.title, required this.isDark});
  final String title;
  final bool   isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 8, 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isDark ? AppColors.white : AppColors.slate900,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: isDark ? AppColors.slate400 : AppColors.slate500,
            ),
            onPressed: () => Navigator.of(context).pop(),
            splashRadius: 18,
          ),
        ],
      ),
    );
  }
}

// ── Mobile bottom-sheet wrapper ────────────────────────────────────────────

class _BottomSheetWrapper extends StatelessWidget {
  const _BottomSheetWrapper({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.slate800 : AppColors.white;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, controller) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.slate600 : AppColors.slate200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _ModalHeader(title: title, isDark: isDark),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}