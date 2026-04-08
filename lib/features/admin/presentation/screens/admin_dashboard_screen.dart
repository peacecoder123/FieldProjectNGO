import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ngo_volunteer_management/core/widgets/app_shell.dart';
import '../../../../shared/providers/feature_providers.dart';
import '../tabs/admin_overview_tab.dart';
import '../tabs/volunteers_tab.dart';
import '../tabs/members_tab.dart';
import '../tabs/donations_tab.dart';
import '../tabs/documentation_tab.dart';
import '../tabs/admin_meetings_tab.dart';
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

  Widget _buildTab() => switch (_activeTab) {
    'overview'        => AdminOverviewTab(isSuperAdmin: widget.isSuperAdmin),
    'volunteers'      => VolunteersTab(isSuperAdmin: widget.isSuperAdmin),
    'members'         => const MembersTab(),
    'donations'       => const DonationsTab(),
    'meetings'        => const AdminMeetingsTab(),
    'documentation'   => const DocumentationTab(),
    'joining-letters' => const JoiningLettersTab(),
    'requests'        => const RequestsTab(),
    _                 => AdminOverviewTab(isSuperAdmin: widget.isSuperAdmin),
  };

  @override
  Widget build(BuildContext context) {
    final joining  = ref.watch(joiningLetterProvider).value ?? [];
    final requests = ref.watch(generalRequestProvider).value ?? [];
    final mou      = ref.watch(mouRequestProvider).value ?? [];
    final docs     = ref.watch(documentRequestProvider).value ?? [];
    
    final joiningPending = joining.where((r) => r.status.name == 'pending').length;
    final requestsPending = requests.where((r) => r.status.name == 'pending').length
                          + mou.where((r) => r.status.name == 'pending').length
                          + docs.where((r) => r.status.name == 'pending').length;
                          
    final int totalNotifications = joiningPending + requestsPending;

    final List<NavItem> navItems = [
      const NavItem(id: 'overview',       label: 'Overview',        icon: Icons.dashboard_rounded),
      const NavItem(id: 'volunteers',     label: 'Volunteers',      icon: Icons.volunteer_activism_rounded),
      const NavItem(id: 'members',        label: 'Members',         icon: Icons.people_rounded),
      const NavItem(id: 'donations',      label: 'Donations',       icon: Icons.currency_rupee_rounded),
      const NavItem(id: 'meetings',       label: 'Meetings',        icon: Icons.groups_rounded),
      const NavItem(id: 'documentation',  label: 'Documentation',   icon: Icons.folder_rounded),
      NavItem(id: 'joining-letters',label: 'Joining Letters', icon: Icons.file_present_rounded, badge: joiningPending > 0 ? joiningPending : null),
      NavItem(id: 'requests',       label: 'Requests',        icon: Icons.inbox_rounded, badge: requestsPending > 0 ? requestsPending : null),
    ];

    return AppShell(
      navItems:      navItems,
      activeTab:     _activeTab,
      onTabChange:   (id) => setState(() => _activeTab = id),
      notifications: totalNotifications,
      body:          _buildTab(),
    );
  }
}