import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ngo_volunteer_management/app/theme/app_colors.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HopeConnect',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Select your role to continue',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.slate300,
                      ),
                ),
                const SizedBox(height: 24),
                ..._roleCards(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _roleCards(BuildContext context) {
    final cards = [
      _RoleCard(
        label: 'Super Admin',
        subtitle: 'Full platform control',
        icon: Icons.admin_panel_settings_rounded,
        gradient: AppColors.superAdminGradient,
        onTap: () => context.go('/login?role=superadmin'),
      ),
      _RoleCard(
        label: 'Admin',
        subtitle: 'Manage volunteers & operations',
        icon: Icons.manage_accounts_rounded,
        gradient: AppColors.adminGradient,
        onTap: () => context.go('/login?role=admin'),
      ),
      _RoleCard(
        label: 'Member',
        subtitle: 'Tasks, meetings & certificates',
        icon: Icons.person_rounded,
        gradient: AppColors.memberGradient,
        onTap: () => context.go('/login?role=member'),
      ),
      _RoleCard(
        label: 'Volunteer',
        subtitle: 'Track your tasks & letters',
        icon: Icons.volunteer_activism_rounded,
        gradient: AppColors.volunteerGradient,
        onTap: () => context.go('/login?role=volunteer'),
      ),
    ];

    return cards
        .map((card) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: card,
            ))
        .toList();
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.slate400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.slate500,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
