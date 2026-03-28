import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ngo_volunteer_management/core/widgets/app_shell.dart';
import '../../../../shared/providers/feature_providers.dart';
import '../tabs/admin_overview_tab.dart';
import '../tabs/volunteers_tab.dart';
import '../tabs/members_tab.dart';
import '../tabs/donations_tab.dart';
import '../tabs/documentation_tab.dart';
import '../tabs/joining_letters_tab.dart';
import '../tabs/requests_tab.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key, required this.isSuperAdmin});
  final bool isSuperAdmin;

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  String _activeTab = 'overview';

  static final List<NavItem> _navItems = [
    const NavItem(id: 'overview',       label: 'Overview',        icon: Icons.dashboard_rounded),
    const NavItem(id: 'volunteers',     label: 'Volunteers',      icon: Icons.volunteer_activism_rounded),
    const NavItem(id: 'members',        label: 'Members',         icon: Icons.people_rounded),
    const NavItem(id: 'donations',      label: 'Donations',       icon: Icons.currency_rupee_rounded),
    const NavItem(id: 'documentation',  label: 'Documentation',   icon: Icons.folder_rounded),
    const NavItem(id: 'joining-letters',label: 'Joining Letters', icon: Icons.file_present_rounded, badge: 2),
    const NavItem(id: 'requests',       label: 'Requests',        icon: Icons.inbox_rounded, badge: 3),
  ];

  int get _notifications {
    final joining  = ref.watch(joiningLetterProvider).value ?? [];
    final requests = ref.watch(generalRequestProvider).value ?? [];
    final mou      = ref.watch(mouRequestProvider).value ?? [];
    return joining.where((r) => r.status.name == 'pending').length
         + requests.where((r) => r.status.name == 'pending').length
         + mou.where((r) => r.status.name == 'pending').length;
  }

  Widget _buildTab() => switch (_activeTab) {
    'overview'        => AdminOverviewTab(isSuperAdmin: widget.isSuperAdmin),
    'volunteers'      => VolunteersTab(isSuperAdmin: widget.isSuperAdmin),
    'members'         => const MembersTab(),
    'donations'       => const DonationsTab(),
    'documentation'   => const DocumentationTab(),
    'joining-letters' => const JoiningLettersTab(),
    'requests'        => const RequestsTab(),
    _                 => AdminOverviewTab(isSuperAdmin: widget.isSuperAdmin),
  };

  @override
  Widget build(BuildContext context) {
    return AppShell(
      navItems:      _navItems,
      activeTab:     _activeTab,
      onTabChange:   (id) => setState(() => _activeTab = id),
      notifications: _notifications,
      body:          _buildTab(),
    );
  }
}