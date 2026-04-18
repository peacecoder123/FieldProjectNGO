import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ngo_volunteer_management/core/widgets/app_shell.dart';
import 'package:ngo_volunteer_management/features/member/presentation/tabs/member_tasks_tab.dart';
import 'package:ngo_volunteer_management/features/member/presentation/tabs/member_meetings_tab.dart';
import 'package:ngo_volunteer_management/features/member/presentation/tabs/hospital_mou_tab.dart';
import 'package:ngo_volunteer_management/features/member/presentation/tabs/member_certificate_tab.dart';
import 'package:ngo_volunteer_management/features/member/presentation/tabs/member_payments_tab.dart';
import 'package:ngo_volunteer_management/features/member/presentation/tabs/member_volunteers_tab.dart';
import 'package:ngo_volunteer_management/features/admin/presentation/screens/profile_screen.dart';
import 'package:ngo_volunteer_management/shared/providers/app_providers.dart';
import 'package:ngo_volunteer_management/shared/providers/feature_providers.dart';
import 'package:ngo_volunteer_management/shared/providers/dismissed_notifs_provider.dart';

// ── Member Dashboard ──────────────────────────────────────────────────────────

class MemberDashboardScreen extends ConsumerStatefulWidget {
  const MemberDashboardScreen({super.key});

  @override
  ConsumerState<MemberDashboardScreen> createState() => _MemberDashboardState();
}

class _MemberDashboardState extends ConsumerState<MemberDashboardScreen> {
  String _activeTab = 'tasks';

  static const List<NavItem> _navItems = [
    NavItem(id: 'tasks',        label: 'My Tasks',           icon: Icons.check_box_outlined),
    NavItem(id: 'meetings',     label: 'Minutes of Meeting',  icon: Icons.calendar_today_rounded),
    NavItem(id: 'hospital-mou', label: 'Hospital MOU',       icon: Icons.local_hospital_rounded),
    NavItem(id: 'certificate',  label: 'Certificate',         icon: Icons.workspace_premium_rounded),
    NavItem(id: 'volunteers',   label: 'My Volunteers',      icon: Icons.people_outline_rounded),
    NavItem(id: 'payments',     label: 'Payments',            icon: Icons.credit_card_rounded),
    NavItem(id: 'profile',      label: 'Profile',             icon: Icons.account_circle_rounded),
  ];

  Widget _buildTab() => switch (_activeTab) {
    'tasks'        => const MemberTasksTab(),
    'meetings'     => const MemberMeetingsTab(),
    'hospital-mou' => const HospitalMouTab(),
    'certificate'  => const MemberCertificateTab(),
    'volunteers'   => const MemberVolunteersTab(),
    'payments'     => const MemberPaymentsTab(),
    'profile'      => const ProfileScreen(),
    _              => const MemberTasksTab(),
  };

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final tasksAsync = ref.watch(taskProvider);
    final dismissed = ref.watch(dismissedNotifsProvider);
    
    final pendingTasks = tasksAsync.value?.where((t) => 
      t.assignedToId == currentUser?.id && 
      t.status.name == 'pending' &&
      !dismissed.contains(t.id)
    ).length ?? 0;

    return AppShell(
      navItems:    _navItems,
      activeTab:   _activeTab,
      onTabChange: (id) => setState(() => _activeTab = id),
      notifications: pendingTasks,
      body:        _buildTab(),
    );
  }
}