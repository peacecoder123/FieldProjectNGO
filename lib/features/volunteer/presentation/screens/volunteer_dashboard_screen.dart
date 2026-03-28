import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngo_volunteer_management/core/widgets/app_shell.dart';
import 'package:ngo_volunteer_management/shared/providers/feature_providers.dart';
import '../tabs/volunteer_tasks_tab.dart';
import '../tabs/volunteer_meetings_tab.dart';
import '../tabs/volunteer_certificate_tab.dart';
import '../tabs/volunteer_joining_letter_tab.dart';

class VolunteerDashboardScreen extends ConsumerStatefulWidget {
  const VolunteerDashboardScreen({super.key});

  @override
  ConsumerState<VolunteerDashboardScreen> createState() => _VolunteerDashboardScreenState();
}

class _VolunteerDashboardScreenState extends ConsumerState<VolunteerDashboardScreen> {
  String _activeTab = 'tasks';

  static final List<NavItem> _navItems = [
    const NavItem(id: 'tasks',       label: 'My Tasks',    icon: Icons.task_alt_rounded),
    const NavItem(id: 'meetings',    label: 'Meetings',    icon: Icons.video_camera_front_rounded),
    const NavItem(id: 'joining',     label: 'Request',     icon: Icons.description_rounded),
    const NavItem(id: 'certificate', label: 'Certificate', icon: Icons.badge_rounded),
  ];

  Widget _buildTab() => switch (_activeTab) {
    'tasks'       => const VolunteerTasksTab(),
    'meetings'    => const VolunteerMeetingsTab(),
    'joining'     => const VolunteerJoiningLetterTab(),
    'certificate' => const VolunteerCertificateTab(),
    _             => const VolunteerTasksTab(),
  };

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskProvider).value ?? [];
    final pendingTasks = tasks.where((t) => t.status.name == 'pending').length;

    return AppShell(
      navItems:      _navItems,
      activeTab:     _activeTab,
      onTabChange:   (id) => setState(() => _activeTab = id),
      notifications: pendingTasks,
      body:          _buildTab(),
    );
  }
}