import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/core/widgets/app_avatar.dart';
import 'package:ngo_volunteer_management/core/widgets/app_card.dart';
import 'package:ngo_volunteer_management/shared/providers/app_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final roleColor = switch (user.role) {
      UserRole.superAdmin => AppColors.purple500,
      UserRole.admin      => AppColors.blue500,
      UserRole.member     => AppColors.emerald500,
      UserRole.volunteer  => AppColors.orange500,
    };

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'My Profile',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.white : AppColors.slate900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your personal information and account settings',
            style: TextStyle(fontSize: 14, color: isDark ? AppColors.slate400 : AppColors.slate500),
          ),
          const SizedBox(height: 28),

          // Avatar & Name Card
          AppCard(
            child: Row(
              children: [
                AppAvatar(
                  initials: user.displayAvatar,
                  role: user.role,
                  size: AvatarSize.xlarge,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.white : AppColors.slate900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(fontSize: 14, color: isDark ? AppColors.slate400 : AppColors.slate500),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: roleColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: roleColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_rounded, size: 14, color: roleColor),
                            const SizedBox(width: 6),
                            Text(
                              user.role.displayName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: roleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Account Details
          Text(
            'Account Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.white : AppColors.slate800,
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.person_rounded,
                  label: 'Full Name',
                  value: user.name,
                  isDark: isDark,
                ),
                _Divider(),
                _InfoRow(
                  icon: Icons.email_rounded,
                  label: 'Email Address',
                  value: user.email,
                  isDark: isDark,
                ),
                _Divider(),
                _InfoRow(
                  icon: Icons.shield_rounded,
                  label: 'Role',
                  value: user.role.displayName,
                  isDark: isDark,
                  valueColor: roleColor,
                ),
                _Divider(),
                _InfoRow(
                  icon: Icons.login_rounded,
                  label: 'Authentication',
                  value: 'Google Sign-In',
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Security / Settings
          Text(
            'Security',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.white : AppColors.slate800,
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.blue100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.key_rounded, size: 18, color: AppColors.blue600),
                  ),
                  title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: const Text('A password reset link will be sent to your email', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.slate400),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Password reset link sent to ${user.email}'),
                        backgroundColor: AppColors.blue600,
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.red50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.logout_rounded, size: 18, color: AppColors.red600),
                  ),
                  title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.red600)),
                  subtitle: const Text('Sign out from this device', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.slate400),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Sign Out?'),
                        content: const Text('Are you sure you want to sign out?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              ref.read(currentUserProvider.notifier).logout();
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red600, foregroundColor: Colors.white),
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Divider(height: 24, indent: 0, endIndent: 0);
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.slate700 : AppColors.slate100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: isDark ? AppColors.slate300 : AppColors.slate600),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppColors.slate500 : AppColors.slate400)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? (isDark ? AppColors.white : AppColors.slate900),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
