import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/core/widgets/app_avatar.dart';
import 'package:ngo_volunteer_management/core/widgets/app_badge.dart';
import 'package:ngo_volunteer_management/core/widgets/app_card.dart';
import 'package:ngo_volunteer_management/core/widgets/app_modal.dart';
import 'package:ngo_volunteer_management/core/widgets/section_header.dart';
import 'package:ngo_volunteer_management/features/admin/presentation/widgets/task_details_modal.dart';
import 'package:ngo_volunteer_management/shared/data/entities.dart';
import 'package:ngo_volunteer_management/shared/providers/feature_providers.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';

/// VolunteersTab: Admin view for managing volunteers and their tasks.
///
/// Mirrors the React VolunteersTab component with:
/// - Volunteer list with search and status filter
/// - Add Volunteer modal
/// - Volunteer detail sheet with profile + tasks
/// - Approve/reject submitted tasks
/// - View uploaded task images
class VolunteersTab extends ConsumerStatefulWidget {
  const VolunteersTab({super.key, required this.isSuperAdmin});

  final bool isSuperAdmin;

  @override
  ConsumerState<VolunteersTab> createState() => _VolunteersTabState();
}

class _VolunteersTabState extends ConsumerState<VolunteersTab> {
  String _searchQuery = '';
  PersonStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final volunteersAsync = ref.watch(volunteerProvider);

    return Column(
      children: [
        SectionHeader(
          subtitle: 'Manage NGO volunteers and their tasks',
          actions: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showDeleteVolunteerGlobalModal(context),
                icon: const Icon(Icons.person_remove_rounded, size: 18),
                label: const Text('Delete Volunteer'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.red500,
                  side: const BorderSide(color: AppColors.red500),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showAddVolunteerModal(context),
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('Add Volunteer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildFilters(),
        const SizedBox(height: 16),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(volunteerProvider);
              await Future.delayed(const Duration(milliseconds: 800));
            },
            child: volunteersAsync.when(
              skipLoadingOnRefresh: true,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (volunteers) {
                final filtered = _filterVolunteers(volunteers);
  
                if (filtered.isEmpty) {
                  return _buildEmptyState();
                }
  
                return _buildVolunteerList(filtered);
              },
            ),
          ),
        ),
      ],
    );
  }

  List<VolunteerEntity> _filterVolunteers(List<VolunteerEntity> volunteers) {
    return volunteers.where((v) {
      final matchesSearch = v.name.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          v.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _statusFilter == null || v.status == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.person_search_rounded,
              size: 28,
              color: AppColors.slate400,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No volunteers found',
            style: TextStyle(
              color: AppColors.slate500,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Try adjusting your search or filter',
            style: TextStyle(color: AppColors.slate400, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildVolunteerList(List<VolunteerEntity> volunteers) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;

        if (isWide) {
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: volunteers.length,
            itemBuilder: (context, index) {
              final v = volunteers[index];
              return _VolunteerCard(
                volunteer: v,
                onTap: () => _showVolunteerDetails(context, v),
              );
            },
          );
        }

        return ListView.separated(
          itemCount: volunteers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final v = volunteers[index];
            return _VolunteerCard(
              volunteer: v,
              onTap: () => _showVolunteerDetails(context, v),
            );
          },
        );
      },
    );
  }

  Widget _buildFilters() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search by name or email...',
              prefixIcon:
                  const Icon(Icons.search_rounded, size: 20),
              filled: true,
              fillColor: isDark ? AppColors.slate800 : AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark ? AppColors.slate700 : AppColors.slate200,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark ? AppColors.slate700 : AppColors.slate200,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.slate800 : AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AppColors.slate700 : AppColors.slate200,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<PersonStatus?>(
              value: _statusFilter,
              hint: const Text('Status'),
              icon: const Icon(Icons.filter_list_rounded, size: 18),
              onChanged: (val) => setState(() => _statusFilter = val),
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
                ...PersonStatus.values.map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(s.name[0].toUpperCase() + s.name.substring(1)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddVolunteerModal(BuildContext context) {
    AppModal.show(
      context: context,
      title: 'Add New Volunteer',
      size: ModalSize.medium,
      child: _AddVolunteerForm(
        onSubmit: (v) async {
          try {
            await ref.read(volunteerProvider.notifier).add(v);
            ref.invalidate(volunteerProvider);
            if (!context.mounted) return;
            
            Navigator.pop(context);
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text('${v.name} has been added as a volunteer.')),
                  ],
                ),
                backgroundColor: AppColors.emerald500,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          } catch (e) {
            if (!context.mounted) return;
            
            String errorMsg = e.toString();
            if (errorMsg.contains('Exception:')) {
              errorMsg = errorMsg.split('Exception:').last.trim();
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(errorMsg)),
                  ],
                ),
                backgroundColor: AppColors.red500,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
      ),
    );
  }

  void _showDeleteVolunteerGlobalModal(BuildContext context) {
    AppModal.show(
      context: context,
      title: 'Delete Volunteer',
      size: ModalSize.medium,
      child: const _DeleteVolunteerGlobalForm(),
    );
  }

  void _showVolunteerDetails(BuildContext context, VolunteerEntity v) {
    AppModal.show(
      context: context,
      title: 'Volunteer Profile',
      size: ModalSize.large,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_note_rounded, color: AppColors.brand),
          onPressed: () {
            // Close details and show edit
            Navigator.pop(context);
            _showEditVolunteerModal(context, v);
          },
          tooltip: 'Edit Profile',
        ),
      ],
      child: _VolunteerDetailsContent(
        volunteer: v,
        isSuperAdmin: widget.isSuperAdmin,
      ),
    );
  }

  void _showEditVolunteerModal(BuildContext context, VolunteerEntity v) {
    AppModal.show(
      context: context,
      title: 'Edit Volunteer Details',
      size: ModalSize.medium,
      child: _EditVolunteerForm(
        volunteer: v,
        onSubmit: (updated) async {
          try {
            await ref.read(volunteerProvider.notifier).update(updated);
            if (!context.mounted) return;
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Update failed: $e')),
            );
          }
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VOLUNTEER CARD
// ─────────────────────────────────────────────────────────────────────────────

class _VolunteerCard extends ConsumerWidget {
  const _VolunteerCard({required this.volunteer, required this.onTap});

  final VolunteerEntity volunteer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final taskCount = tasksAsync.when(
      data: (tasks) => tasks
          .where((t) =>
              t.assignedToId == volunteer.id &&
              t.assignedToType == AssigneeType.volunteer)
          .length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          AppAvatar(
            initials: AppFormatters.initials(volunteer.name),
            size: AvatarSize.large,
            role: UserRole.volunteer,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  volunteer.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Text(
                  volunteer.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.slate500,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.assignment_rounded,
                        size: 12, color: isDark ? AppColors.slate400 : AppColors.slate500),
                    const SizedBox(width: 4),
                    Text(
                      '$taskCount tasks',
                      style: TextStyle(
                        color: isDark ? AppColors.slate400 : AppColors.slate500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBadge.personStatus(volunteer.status),
              const SizedBox(height: 4),
              Text(
                volunteer.assignedAdmin.isNotEmpty
                    ? volunteer.assignedAdmin
                    : 'No admin',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.slate400,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: AppColors.slate300),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ADD VOLUNTEER FORM
// ─────────────────────────────────────────────────────────────────────────────

class _AddVolunteerForm extends StatefulWidget {
  const _AddVolunteerForm({required this.onSubmit});

  final Future<void> Function(VolunteerEntity) onSubmit;

  @override
  State<_AddVolunteerForm> createState() => _AddVolunteerFormState();
}

class _AddVolunteerFormState extends State<_AddVolunteerForm> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String _name = '';
  String _email = '';
  String _phone = '';
  String _address = '';
  String _skills = '';
  String _assignedAdmin = '';
  String _tenure = 'monthly';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_rounded),
              ),
              onSaved: (val) => _name = val ?? '',
              validator: (v) =>
                  (v?.trim().isEmpty ?? true) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email_rounded),
              ),
              keyboardType: TextInputType.emailAddress,
              onSaved: (val) => _email = val ?? '',
              validator: (v) {
                if (v?.trim().isEmpty ?? true) return 'Required';
                if (!v!.contains('@')) return 'Invalid email';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_rounded),
              ),
              keyboardType: TextInputType.phone,
              onSaved: (val) => _phone = val ?? '',
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Address',
                prefixIcon: Icon(Icons.location_on_rounded),
              ),
              maxLines: 2,
              onSaved: (val) => _address = val ?? '',
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Skills (comma separated)',
                prefixIcon: Icon(Icons.psychology_rounded),
                hintText: 'e.g. Teaching, Design, Event Management',
              ),
              onSaved: (val) => _skills = val ?? '',
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Assigned Admin',
                prefixIcon: Icon(Icons.shield_rounded),
              ),
              onSaved: (val) => _assignedAdmin = val ?? '',
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Tenure',
                prefixIcon: Icon(Icons.calendar_month_rounded),
              ),
              value: _tenure,
              items: const [
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                DropdownMenuItem(value: 'annual', child: Text('Annual')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _tenure = val);
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Add Volunteer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      setState(() => _isLoading = true);
      try {
        await widget.onSubmit(
          VolunteerEntity(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: _name.trim(),
            email: _email.trim(),
            phone: _phone.trim(),
            address: _address.trim(),
            joinDate: AppFormatters.today(),
            status: PersonStatus.active,
            assignedAdmin: _assignedAdmin.trim(),
            taskIds: const [],
            tenure: _tenure,
            skills: _skills
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList(),
            avatar: '',
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VOLUNTEER DETAILS CONTENT
// ─────────────────────────────────────────────────────────────────────────────

class _VolunteerDetailsContent extends ConsumerWidget {
  const _VolunteerDetailsContent({
    required this.volunteer,
    required this.isSuperAdmin,
  });

  final VolunteerEntity volunteer;
  final bool isSuperAdmin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          _buildProfileHeader(isDark),
          const SizedBox(height: 24),

          // Profile Information
          const Text(
            'Profile Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _buildProfileCard(isDark),
          const SizedBox(height: 24),

          // Tasks Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Assigned Tasks',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              TextButton.icon(
                onPressed: () => _showAddTaskModal(context, ref),
                icon: const Icon(Icons.add_task_rounded, size: 18),
                label: const Text('Add Task'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Tasks List
          tasksAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error loading tasks: $e'),
            data: (tasks) => _buildTasksList(context, ref, tasks),
          ),

          const SizedBox(height: 32),
          const Divider(height: 1),
          const SizedBox(height: 24),
          const Text('Danger Zone', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.red500)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.red500.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.red500.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Delete Volunteer', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.red600)),
                      const SizedBox(height: 4),
                      Text('Permanently remove this volunteer from the platform. This action cannot be undone.', 
                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.red100 : AppColors.red500)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _confirmDelete(context, ref),
                  icon: const Icon(Icons.delete_outline_rounded, size: 16),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red500,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    bool isDeleting = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          title: const Text('Delete Volunteer Profile?'),
          content: Text('Are you sure you want to permanently delete ${volunteer.name}?'),
          actions: [
            TextButton(
              onPressed: isDeleting ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: isDeleting ? null : () async {
                setModalState(() => isDeleting = true);
                try {
                  await ref.read(volunteerProvider.notifier).delete(volunteer.id);
                  ref.invalidate(volunteerProvider);
                  if (context.mounted) {
                    Navigator.pop(ctx); // pop dialog
                    Navigator.pop(context); // pop modal sheet
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${volunteer.name} has been deleted'), backgroundColor: AppColors.red600),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    setModalState(() => isDeleting = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.red600),
                    );
                  }
                }
              },
              child: isDeleting
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Delete', style: TextStyle(color: AppColors.red500)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppAvatar(
          initials: AppFormatters.initials(volunteer.name),
          size: AvatarSize.xlarge,
          role: UserRole.volunteer,
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                volunteer.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                volunteer.email,
                style: const TextStyle(color: AppColors.slate500),
              ),
              const SizedBox(height: 8),
              if (volunteer.skills.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: volunteer.skills.map((s) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.blue600.withValues(alpha: 0.2)
                            : AppColors.blue50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDark
                              ? AppColors.blue400.withValues(alpha: 0.3)
                              : AppColors.blue100,
                        ),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.blue400 : AppColors.blue600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(bool isDark) {
    return AppCard(
      child: Column(
        children: [
          _InfoRow(
            label: 'Phone',
            value: volunteer.phone.isNotEmpty ? volunteer.phone : 'N/A',
            icon: Icons.phone_rounded,
          ),
          const Divider(height: 24),
          _InfoRow(
            label: 'Address',
            value: volunteer.address.isNotEmpty ? volunteer.address : 'N/A',
            icon: Icons.location_on_rounded,
          ),
          const Divider(height: 24),
          _InfoRow(
            label: 'Join Date',
            value: AppFormatters.displayDate(volunteer.joinDate),
            icon: Icons.calendar_today_rounded,
          ),
          const Divider(height: 24),
          _InfoRow(
            label: 'Tenure',
            value: volunteer.tenure == 'monthly' ? 'Monthly' : 'Annual',
            icon: Icons.schedule_rounded,
          ),
          const Divider(height: 24),
          _InfoRow(
            label: 'Assigned Admin',
            value: volunteer.assignedAdmin.isNotEmpty
                ? volunteer.assignedAdmin
                : 'Not assigned',
            icon: Icons.shield_rounded,
          ),
          const Divider(height: 24),
          _InfoRow(
            label: 'Status',
            value: volunteer.status.displayName,
            icon: Icons.badge_rounded,
            trailing: AppBadge.personStatus(volunteer.status),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(
    BuildContext context,
    WidgetRef ref,
    List<TaskEntity> tasks,
  ) {
    final volunteerTasks = tasks
        .where((t) =>
            t.assignedToId == volunteer.id &&
            t.assignedToType == AssigneeType.volunteer)
        .toList();

    if (volunteerTasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.slate800
              : AppColors.slate50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No tasks assigned yet',
            style: TextStyle(color: AppColors.slate400),
          ),
        ),
      );
    }

    return Column(
      children: volunteerTasks
          .map((t) => _TaskItem(
                task: t,
                volunteer: volunteer,
              ))
          .toList(),
    );
  }

  void _showAddTaskModal(BuildContext context, WidgetRef ref) {
    AppModal.show(
      context: context,
      title: 'Assign New Task',
      size: ModalSize.medium,
      child: _AddTaskForm(
        volunteer: volunteer,
        onSubmit: (task) {
          ref.read(taskProvider.notifier).add(task);
          Navigator.pop(context);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INFO ROW
// ─────────────────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.trailing,
  });

  final String label;
  final String value;
  final IconData icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.slate400),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.slate400,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TASK ITEM
// ─────────────────────────────────────────────────────────────────────────────

class _TaskItem extends ConsumerWidget {
  const _TaskItem({required this.task, required this.volunteer});

  final TaskEntity task;
  final VolunteerEntity volunteer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => _showDetails(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.slate800 : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.slate700 : AppColors.slate200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                _TaskStatusBadge(status: task.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              task.description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.slate500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.event_rounded,
                            size: 14,
                            color: AppColors.slate400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Due: ${AppFormatters.displayDate(task.deadline)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.slate500,
                            ),
                          ),
                        ],
                      ),
                      if (task.requiresUpload)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.amber100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Requires Upload',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.amber600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (task.geotag != null && task.geotag!.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on_rounded, size: 14, color: AppColors.red500),
                            const SizedBox(width: 4),
                            const Text(
                              'Geotagged',
                              style: TextStyle(fontSize: 12, color: AppColors.slate500),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                if (task.status == TaskStatus.submitted || task.status == TaskStatus.waitingAdmin)
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => _showDetails(context),
                        icon: const Icon(Icons.visibility_rounded, size: 16),
                        label: const Text('View'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.blue600,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.emerald500,
                          size: 24,
                        ),
                        onPressed: () => ref
                            .read(taskProvider.notifier)
                            .updateStatus(task.id, TaskStatus.approved),
                        tooltip: 'Approve',
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.cancel_rounded,
                          color: AppColors.red500,
                          size: 24,
                        ),
                        onPressed: () => ref
                            .read(taskProvider.notifier)
                            .updateStatus(task.id, TaskStatus.rejected),
                        tooltip: 'Reject',
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    AppModal.show(
      context: context,
      title: 'Task Submission Detail',
      child: TaskDetailsModal(task: task),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TASK STATUS BADGE
// ─────────────────────────────────────────────────────────────────────────────

class _TaskStatusBadge extends StatelessWidget {
  const _TaskStatusBadge({required this.status});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      TaskStatus.pending      => AppColors.amber500,
      TaskStatus.submitted    => AppColors.blue500,
      TaskStatus.waitingAdmin => AppColors.brand,
      TaskStatus.approved     => AppColors.emerald500,
      TaskStatus.rejected      => AppColors.red500,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.displayName.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ADD TASK FORM
// ─────────────────────────────────────────────────────────────────────────────

class _AddTaskForm extends StatefulWidget {
  const _AddTaskForm({required this.volunteer, required this.onSubmit});

  final VolunteerEntity volunteer;
  final void Function(TaskEntity) onSubmit;

  @override
  State<_AddTaskForm> createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<_AddTaskForm> {
  final _formKey = GlobalKey<FormState>();

  String _title = '';
  String _description = '';
  DateTime _deadline = DateTime.now().add(const Duration(days: 7));
  bool _requiresUpload = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Task Title',
                prefixIcon: Icon(Icons.task_alt_rounded),
              ),
              onSaved: (val) => _title = val ?? '',
              validator: (v) =>
                  (v?.trim().isEmpty ?? true) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description_rounded),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              onSaved: (val) => _description = val ?? '',
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.event_rounded),
              title: const Text('Deadline'),
              subtitle: Text(AppFormatters.displayDate(
                AppFormatters.toIso(_deadline),
              )),
              trailing: TextButton(
                onPressed: _selectDate,
                child: const Text('Change'),
              ),
            ),
            SwitchListTile.adaptive(
              secondary: const Icon(Icons.image_rounded),
              title: const Text('Requires Image Upload'),
              subtitle: const Text('Volunteer must upload proof'),
              value: _requiresUpload,
              onChanged: (val) => setState(() => _requiresUpload = val),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Assign Task'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      widget.onSubmit(
        TaskEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _title.trim(),
          description: _description.trim(),
          deadline: AppFormatters.toIso(_deadline),
          assignedToId: widget.volunteer.id,
          assignedToName: widget.volunteer.name,
          assignedToEmail: widget.volunteer.email,
          assignedToType: AssigneeType.volunteer,
          status: TaskStatus.pending,
          requiresUpload: _requiresUpload,
          createdAt: AppFormatters.today(),
        ),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EDIT VOLUNTEER FORM
// ─────────────────────────────────────────────────────────────────────────────

class _EditVolunteerForm extends StatefulWidget {
  const _EditVolunteerForm({required this.volunteer, required this.onSubmit});

  final VolunteerEntity volunteer;
  final void Function(VolunteerEntity) onSubmit;

  @override
  State<_EditVolunteerForm> createState() => _EditVolunteerFormState();
}

class _EditVolunteerFormState extends State<_EditVolunteerForm> {
  final _formKey = GlobalKey<FormState>();

  late String _name;
  late String _phone;
  late String _address;
  late DateTime _joinDate;
  late String _tenure;
  late PersonStatus _status;
  late TextEditingController _skillsController;

  @override
  void initState() {
    super.initState();
    _name = widget.volunteer.name;
    _phone = widget.volunteer.phone;
    _address = widget.volunteer.address;
    _joinDate = DateTime.tryParse(widget.volunteer.joinDate) ?? DateTime.now();
    _tenure = widget.volunteer.tenure;
    _status = widget.volunteer.status;
    _skillsController =
        TextEditingController(text: widget.volunteer.skills.join(', '));
  }

  @override
  void dispose() {
    _skillsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              initialValue: _name,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_rounded, size: 20),
              ),
              onSaved: (val) => _name = val ?? '',
              validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _phone,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_rounded, size: 20),
                hintText: 'Enter phone number',
              ),
              keyboardType: TextInputType.phone,
              onSaved: (val) => _phone = val ?? '',
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _address,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                labelText: 'Address',
                prefixIcon: Icon(Icons.location_on_rounded, size: 20),
                hintText: 'Enter full address',
                alignLabelWithHint: true,
              ),
              maxLines: 2,
              onSaved: (val) => _address = val ?? '',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _skillsController,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                labelText: 'Skills (comma separated)',
                prefixIcon: Icon(Icons.psychology_rounded, size: 20),
                hintText: 'e.g. Teaching, Design, Coordination',
              ),
            ),
            const SizedBox(height: 16),
            _buildDropdown<String>(
              label: 'Tenure',
              icon: Icons.schedule_rounded,
              value: _tenure,
              items: ['monthly', 'annual'],
              onChanged: (val) => setState(() => _tenure = val!),
              display: (v) => v[0].toUpperCase() + v.substring(1),
            ),
            const SizedBox(height: 16),
            _buildDropdown<PersonStatus>(
              label: 'Status',
              icon: Icons.badge_rounded,
              value: _status,
              items: PersonStatus.values,
              onChanged: (val) => setState(() => _status = val!),
              display: (v) => v.displayName,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required IconData icon,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) display,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items
          .map((i) => DropdownMenuItem(value: i, child: Text(display(i))))
          .toList(),
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, color: AppColors.slate900),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final skills = _skillsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      widget.onSubmit(
        widget.volunteer.copyWith(
          name: _name,
          phone: _phone,
          address: _address,
          tenure: _tenure,
          status: _status,
          skills: skills,
        ),
      );
    }
  }
// GLOBAL DELETE VOLUNTEER LIST MODAL
// ─────────────────────────────────────────────────────────────────────────────

class _DeleteVolunteerGlobalForm extends ConsumerStatefulWidget {
  const _DeleteVolunteerGlobalForm();
  @override
  ConsumerState<_DeleteVolunteerGlobalForm> createState() => _DeleteVolunteerGlobalFormState();
}

class _DeleteVolunteerGlobalFormState extends ConsumerState<_DeleteVolunteerGlobalForm> {
  String _search = '';
  String? _deletingId;

  @override
  Widget build(BuildContext context) {
    final volunteersAsync = ref.watch(volunteerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          decoration: const InputDecoration(
            hintText: 'Search volunteer by name or email...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (val) => setState(() => _search = val),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 350,
          child: volunteersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error loading volunteers: $e')),
            data: (volunteers) {
              final filtered = volunteers.where((v) {
                return v.name.toLowerCase().contains(_search.toLowerCase()) ||
                       v.email.toLowerCase().contains(_search.toLowerCase());
              }).toList();

              if (filtered.isEmpty) {
                return const Center(child: Text('No matching volunteers found'));
              }

              return ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final v = filtered[index];
                  final isDeleting = _deletingId == v.id;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    leading: AppAvatar(initials: AppFormatters.initials(v.name), size: AvatarSize.medium, role: UserRole.volunteer),
                    title: Text(v.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppColors.white : AppColors.slate900)),
                    subtitle: Text(v.email, style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
                    trailing: isDeleting
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.red500))
                        : IconButton(
                            icon: const Icon(Icons.person_remove_rounded, color: AppColors.red500),
                            onPressed: () => _confirmDelete(v),
                            tooltip: 'Delete ${v.name}',
                          ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _confirmDelete(VolunteerEntity v) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to permanently delete ${v.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _deletingId = v.id);
              try {
                await ref.read(volunteerProvider.notifier).delete(v.id);
                ref.invalidate(volunteerProvider);
                if (mounted) {
                  Navigator.pop(context); // Close the search modal
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${v.name} has been deleted'), backgroundColor: AppColors.red600),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.red600),
                  );
                }
              } finally {
                if (mounted) setState(() => _deletingId = null);
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.red500)),
          ),
        ],
      ),
    );
  }
}
