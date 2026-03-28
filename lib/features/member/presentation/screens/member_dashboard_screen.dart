import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ngo_volunteer_management/core/widgets/app_shell.dart';
import 'package:ngo_volunteer_management/features/member/presentation/tabs/member_tasks_tab.dart';
import 'package:ngo_volunteer_management/features/member/presentation/tabs/member_meetings_tab.dart';
import 'package:ngo_volunteer_management/features/member/presentation/tabs/hospital_mou_tab.dart';
import 'package:ngo_volunteer_management/features/member/presentation/tabs/member_certificate_tab.dart';
import 'package:ngo_volunteer_management/features/member/presentation/tabs/member_payments_tab.dart';

// ── Member Dashboard ──────────────────────────────────────────────────────────

class MemberDashboardScreen extends ConsumerStatefulWidget {
  const MemberDashboardScreen({super.key});

  @override
  ConsumerState<MemberDashboardScreen> createState() =>
      _MemberDashboardState();
}

class _MemberDashboardState extends ConsumerState<MemberDashboardScreen> {
  String _activeTab = 'tasks';

  static const List<NavItem> _navItems = [
    NavItem(id: 'tasks',       label: 'My Tasks',          icon: Icons.check_box_outlined),
    NavItem(id: 'meetings',    label: 'Minutes of Meeting', icon: Icons.calendar_today_rounded),
    NavItem(id: 'hospital-mou', label: 'Hospital MOU',     icon: Icons.local_hospital_rounded),
    NavItem(id: 'certificate', label: 'Certificate',        icon: Icons.workspace_premium_rounded),
    NavItem(id: 'payments',    label: 'Payments',           icon: Icons.credit_card_rounded),
  ];

  Widget _buildTab() => switch (_activeTab) {
    'tasks'        => const MemberTasksTab(),
    'meetings'     => const MemberMeetingsTab(),
    'hospital-mou' => const HospitalMouTab(),
    'certificate'  => const MemberCertificateTab(),
    'payments'     => const MemberPaymentsTab(),
    _              => const MemberTasksTab(),
  };

  @override
  Widget build(BuildContext context) {
    return AppShell(
      navItems:    _navItems,
      activeTab:   _activeTab,
      onTabChange: (id) => setState(() => _activeTab = id),
      body:        _buildTab(),
    );
  }
}