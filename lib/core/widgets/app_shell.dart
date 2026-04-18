import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ngo_volunteer_management/core/constants/app_constants.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'app_avatar.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/providers/feature_providers.dart';

/// Navigation item descriptor (mirrors the React `NavItem` interface).
class NavItem {
  const NavItem({
    required this.id,
    required this.label,
    required this.icon,
    this.badge,
  });

  final String   id;
  final String   label;
  final IconData icon;
  final int?     badge;
}

/// The top-level responsive shell:
/// • ≥ 1024 px  →  persistent left sidebar (240 px) + top header
/// • < 1024 px  →  hidden drawer + compact app bar
///
/// Mirrors the React `<Layout>` component from layout/Layout.tsx.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({
    super.key,
    required this.navItems,
    required this.activeTab,
    required this.onTabChange,
    required this.body,
    this.notifications = 0,
  });

  final List<NavItem> navItems;
  final String        activeTab;
  final void Function(String) onTabChange;
  final Widget        body;
  final int           notifications;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    ref.invalidate(volunteerProvider);
    ref.invalidate(memberProvider);
    ref.invalidate(taskProvider);
    ref.invalidate(donationProvider);
    ref.invalidate(joiningLetterProvider);
    ref.invalidate(generalRequestProvider);
    ref.invalidate(mouRequestProvider);
    ref.invalidate(meetingProvider);
    ref.invalidate(documentStorageProvider);
    ref.invalidate(documentRequestProvider);
    ref.invalidate(usersManagementProvider);
    // Short delay so the spinner shows briefly even on fast connections
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Widget build(BuildContext context) {
    final width    = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.desktopBreakpoint;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: false,
      drawer: isDesktop ? null : _buildDrawer(),
      body: Row(
        children: [
          if (isDesktop) _Sidebar(
            navItems:  widget.navItems,
            activeTab: widget.activeTab,
            onTabChange: widget.onTabChange,
          ),
          Expanded(
            child: SafeArea(
              top: !isDesktop,
              child: Column(
                children: [
                  _TopBar(
                    scaffoldKey:   _scaffoldKey,
                    isDesktop:     isDesktop,
                    activeLabel:   _activeLabel,
                    notifications: widget.notifications,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: widget.body,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() => Drawer(
    backgroundColor: AppColors.brand,
    child: _SidebarContent(
      navItems:  widget.navItems,
      activeTab: widget.activeTab,
      onTabChange: (id) {
        widget.onTabChange(id);
        _scaffoldKey.currentState?.closeDrawer();
      },
    ),
  );

  String get _activeLabel =>
      widget.navItems
          .firstWhere(
            (n) => n.id == widget.activeTab,
            orElse: () => widget.navItems.first,
          )
          .label;
}

// ── Desktop sidebar ───────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.navItems,
    required this.activeTab,
    required this.onTabChange,
  });

  final List<NavItem>          navItems;
  final String                 activeTab;
  final void Function(String)  onTabChange;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppConstants.sidebarWidth,
      child: Container(
        color: AppColors.brand,
        child: _SidebarContent(
          navItems: navItems,
          activeTab: activeTab,
          onTabChange: onTabChange,
        ),
      ),
    );
  }
}

// ── Sidebar content (shared by drawer + desktop) ──────────────────────────────

class _SidebarContent extends ConsumerWidget {
  const _SidebarContent({
    required this.navItems,
    required this.activeTab,
    required this.onTabChange,
  });

  final List<NavItem>          navItems;
  final String                 activeTab;
  final void Function(String)  onTabChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final role = user?.role ?? UserRole.volunteer;

    final roleLabel = role.displayName;
    final gradientColors = _gradientForRole(role);

    return Column(
      children: [
        // ── Logo ───────────────────────────────────────────────────────────
        const _SidebarLogo(),

        // ── Role pill ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                AppAvatar(
                  initials: user?.displayAvatar ?? '?',
                  size: AvatarSize.medium,
                  role: role,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        roleLabel.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.name ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Nav items ─────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'NAVIGATION',
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.5),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            itemCount: navItems.length,
            itemBuilder: (context, i) {
              final item     = navItems[i];
              final isActive = item.id == activeTab;
              return _NavTile(
                item:     item,
                isActive: isActive,
                onTap:    () => onTabChange(item.id),
              );
            },
          ),
        ),

        // ── Sign-out ──────────────────────────────────────────────────────
        _SignOutButton(user: user),
      ],
    );
  }

  static LinearGradient _gradientForRole(UserRole role) => switch (role) {
    UserRole.superAdmin => AppColors.superAdminGradient,
    UserRole.admin      => AppColors.adminGradient,
    UserRole.member     => AppColors.memberGradient,
    UserRole.volunteer  => AppColors.volunteerGradient,
  };
}

// ── Logo ──────────────────────────────────────────────────────────────────────

class _SidebarLogo extends StatelessWidget {
  const _SidebarLogo();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/logo.png',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jayashree Foundation',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'NGO Management',
                    style: const TextStyle(
                      color: AppColors.slate400,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Nav tile ─────────────────────────────────────────────────────────────────

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final NavItem    item;
  final bool       isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: AppConstants.animFast,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                        spreadRadius: -2,
                      )
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 16,
                  color: isActive
                      ? Colors.white
                      : AppColors.slate400,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: isActive ? Colors.white : AppColors.slate300,
                      fontSize: 13,
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
                if (item.badge != null && item.badge! > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white.withValues(alpha: 0.25)
                          : AppColors.red500,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${item.badge}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (isActive)
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sign out button ───────────────────────────────────────────────────────────

class _SignOutButton extends ConsumerWidget {
  const _SignOutButton({required this.user});

  final dynamic user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final u = ref.watch(currentUserProvider);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              AppAvatar(
                initials: u?.displayAvatar ?? '?',
                size: AvatarSize.medium,
                role: u?.role,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      u?.name ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      u?.email ?? '',
                      style: const TextStyle(
                        color: AppColors.slate400,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              ref.read(currentUserProvider.notifier).logout();
              context.go('/');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.transparent,
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.logout_rounded,
                    size: 15,
                    color: AppColors.slate400,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Sign Out',
                    style: TextStyle(
                      color: AppColors.slate400,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top header bar ────────────────────────────────────────────────────────────

class _TopBar extends ConsumerStatefulWidget {
  const _TopBar({
    required this.scaffoldKey,
    required this.isDesktop,
    required this.activeLabel,
    required this.notifications,
  });

  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool   isDesktop;
  final String activeLabel;
  final int    notifications;

  @override
  ConsumerState<_TopBar> createState() => _TopBarState();
}

class _TopBarState extends ConsumerState<_TopBar> {
  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate900 : AppColors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.slate800 : AppColors.slate100,
            width: 1.5,
          ),
        ),
      ),
      child: Row(
        children: [
          if (!widget.isDesktop) ...[
            IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () =>
                  widget.scaffoldKey.currentState?.openDrawer(),
            ),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.activeLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.white : AppColors.slate900,
                  ),
                ),
                if (widget.isDesktop)
                  Text(
                    _dateString(),
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          _buildNotificationButton(isDark),
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? AppColors.amber400 : AppColors.slate600,
            ),
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildNotificationButton(bool isDark) {
    return Container(
      child: SizedBox(
        width: 48,
        height: 48,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: isDark ? AppColors.slate300 : AppColors.slate600,
              ),
              onPressed: () => _showNotificationsDialog(context),
            ),
            if (widget.notifications > 0)
            Align(
              alignment: Alignment.topRight,
              child: Container(
                margin: const EdgeInsets.only(top: 4, right: 4),
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: AppColors.red500,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${widget.notifications}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        final joining  = ref.watch(joiningLetterProvider).value ?? [];
        final requests = ref.watch(generalRequestProvider).value ?? [];
        final mou      = ref.watch(mouRequestProvider).value ?? [];

        final items = <Widget>[];

        for (final r in joining.where((r) => r.status.name == 'pending')) {
          items.add(_buildNotifRow(
            icon: Icons.file_present_rounded,
            iconColor: AppColors.amber500,
            isDark: isDark,
            title: 'Joining Letter Request',
            subtitle: '${r.name} requested on ${r.requestDate.toString().split(' ')[0]}',
          ));
        }
        for (final r in requests.where((r) => r.status.name == 'pending')) {
          items.add(_buildNotifRow(
            icon: Icons.inbox_rounded,
            iconColor: AppColors.blue500,
            isDark: isDark,
            title: 'General Request',
            subtitle: '${r.requesterName}: ${r.requestType.displayLabel}',
          ));
        }
        for (final r in mou.where((r) => r.status.name == 'pending')) {
          items.add(_buildNotifRow(
            icon: Icons.local_hospital_rounded,
            iconColor: AppColors.red500,
            isDark: isDark,
            title: 'MOU Request',
            subtitle: '${r.patientName} at ${r.hospital}',
          ));
        }

        if (items.isEmpty) {
          items.add(
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'No new notifications',
                style: TextStyle(
                  color: isDark ? AppColors.slate500 : AppColors.slate400,
                ),
              ),
            ),
          );
        }

        return AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Notifications',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              TextButton(
                onPressed: () {
                  final approver = ref.read(currentUserProvider)?.name ?? 'Admin';
                  
                  // Clear Joining Letters
                  final joiningNotifier = ref.read(joiningLetterProvider.notifier);
                  final joining = ref.read(joiningLetterProvider).value ?? [];
                  for (final r in joining.where((r) => r.status == RequestStatus.pending)) {
                    joiningNotifier.approve(r.id, generatedBy: approver, tenure: '6 Months');
                  }

                  // Clear General Requests
                  final generalNotifier = ref.read(generalRequestProvider.notifier);
                  final requests = ref.read(generalRequestProvider).value ?? [];
                  for (final r in requests.where((r) => r.status == RequestStatus.pending)) {
                    generalNotifier.approve(r.id, approvedBy: approver);
                  }

                  // Clear MOU Requests
                  final mouNotifier = ref.read(mouRequestProvider.notifier);
                  final mous = ref.read(mouRequestProvider).value ?? [];
                  for (final r in mous.where((r) => r.status == RequestStatus.pending)) {
                    mouNotifier.approve(r.id, approvedBy: approver);
                  }

                  Navigator.of(dialogCtx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ All pending requests have been approved.'), backgroundColor: AppColors.emerald600),
                  );
                },
                child: const Text('Clear all', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(height: 1),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 280),
                  child: SingleChildScrollView(
                    child: Column(children: items),
                  ),
                ),
              ],
            ),
          ),
          actionsPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        );
      },
    );
  }

  Widget _buildNotifRow({
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.white : AppColors.slate900,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.slate400 : AppColors.slate500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _dateString() {
    final now = DateTime.now();
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }
}