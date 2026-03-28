import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ngo_volunteer_management/core/constants/app_constants.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'app_avatar.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import '../../shared/providers/app_providers.dart';

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

  @override
  Widget build(BuildContext context) {
    final width    = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.desktopBreakpoint;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: isDesktop ? null : _buildDrawer(),
      body: Row(
        children: [
          if (isDesktop) _Sidebar(
            navItems:  widget.navItems,
            activeTab: widget.activeTab,
            onTabChange: widget.onTabChange,
          ),
          Expanded(
            child: Column(
              children: [
                _TopBar(
                  scaffoldKey:   _scaffoldKey,
                  isDesktop:     isDesktop,
                  activeLabel:   _activeLabel,
                  notifications: widget.notifications,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(
                      isDesktop
                          ? AppConstants.pagePaddingDesktop
                          : AppConstants.pagePadding,
                    ),
                    child: widget.body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() => Drawer(
    backgroundColor: AppColors.slate900,
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
        color: AppColors.slate900,
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors.colors.map((c) => c.withOpacity(0.25)).toList(),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                AppAvatar(
                  initials: user?.displayAvatar ?? '?',
                  size: AvatarSize.small,
                  role: role,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        roleLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        user?.name ?? '',
                        style: const TextStyle(
                          color: AppColors.slate300,
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
          ),
        ),

        // ── Nav items ─────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'NAVIGATION',
              style: const TextStyle(
                color: AppColors.slate500,
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.blue500, AppColors.indigo600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'HopeConnect',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'NGO Management',
                  style: TextStyle(
                    color: AppColors.slate400,
                    fontSize: 10,
                  ),
                ),
              ],
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
                  ? AppColors.blue600
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.blue600.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
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
                          ? Colors.white.withOpacity(0.25)
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
                      color: AppColors.blue400,
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
          const Divider(color: AppColors.slate700, height: 1),
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
              child: Row(
                children: const [
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
  bool _showNotif = false;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user   = ref.watch(currentUserProvider);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : AppColors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.slate700 : AppColors.slate200,
          ),
        ),
      ),
      child: Row(
        children: [
          // Hamburger (mobile only)
          if (!widget.isDesktop) ...[
            IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () =>
                  widget.scaffoldKey.currentState?.openDrawer(),
            ),
            const SizedBox(width: 4),
          ],

          // Page title
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

          // Notification bell
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: isDark ? AppColors.slate300 : AppColors.slate600,
                ),
                onPressed: () =>
                    setState(() => _showNotif = !_showNotif),
              ),
              if (widget.notifications > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
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

          // Theme toggle
          IconButton(
            icon: Icon(
              isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              color: isDark ? AppColors.amber400 : AppColors.slate600,
            ),
            onPressed: () =>
                ref.read(themeModeProvider.notifier).toggle(),
          ),

          // User avatar
          AppAvatar(
            initials: user?.displayAvatar ?? '?',
            size: AvatarSize.small,
            role: user?.role,
          ),
          const SizedBox(width: 4),
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