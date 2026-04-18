import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/core/widgets/app_avatar.dart';
import 'package:ngo_volunteer_management/core/widgets/app_badge.dart';
import 'package:ngo_volunteer_management/core/widgets/app_card.dart';
import 'package:ngo_volunteer_management/core/widgets/app_modal.dart';
import 'package:ngo_volunteer_management/core/widgets/section_header.dart';
import 'package:ngo_volunteer_management/shared/data/entities.dart';
import 'package:ngo_volunteer_management/shared/providers/app_providers.dart';
import 'package:ngo_volunteer_management/shared/providers/feature_providers.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';

class MemberVolunteersTab extends ConsumerWidget {
  const MemberVolunteersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final volunteersAsync = ref.watch(volunteerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (currentUser == null) return const Center(child: Text('Please login'));

    return volunteersAsync.when(
      skipLoadingOnRefresh: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (volunteers) {
        final mentoredVolunteers = volunteers
            .where((v) => v.mentorId == currentUser.id)
            .toList();

        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            const _ApprovalQueue(),
            const SizedBox(height: 32),
            SectionHeader(
              title: 'Guided Volunteers',
              subtitle: 'Manage volunteers working under your guidance',
            ),
            const SizedBox(height: 16),
            if (mentoredVolunteers.isEmpty)
              _buildEmptyState(isDark)
            else
              ...mentoredVolunteers.map((v) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _VolunteerCard(
                      volunteer: v,
                      onTap: () => _showVolunteerDetails(context, ref, v),
                    ),
                  )),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(Icons.people_outline_rounded, size: 64, color: isDark ? AppColors.slate700 : AppColors.slate200),
            const SizedBox(height: 16),
            Text(
              'No volunteers assigned to you yet',
              style: TextStyle(
                color: isDark ? AppColors.slate400 : AppColors.slate500,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Admins can assign volunteers to your guidance',
              style: TextStyle(
                color: isDark ? AppColors.slate500 : AppColors.slate400,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVolunteerDetails(BuildContext context, WidgetRef ref, VolunteerEntity v) {
    AppModal.show(
      context: context,
      title: 'Volunteer Details',
      size: ModalSize.large,
      child: _VolunteerDetailsContent(volunteer: v),
    );
  }
}

class _VolunteerCard extends StatelessWidget {
  const _VolunteerCard({required this.volunteer, required this.onTap});
  final VolunteerEntity volunteer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              children: [
                Text(
                  volunteer.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: isDark ? AppColors.white : AppColors.slate900,
                  ),
                ),
                Text(
                  volunteer.email,
                  style: TextStyle(
                    color: isDark ? AppColors.slate400 : AppColors.slate500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                AppBadge.personStatus(volunteer.status),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.slate300),
        ],
      ),
    );
  }
}

class _VolunteerDetailsContent extends ConsumerWidget {
  const _VolunteerDetailsContent({required this.volunteer});
  final VolunteerEntity volunteer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(volunteer.email, style: const TextStyle(color: AppColors.slate500)),
                    const SizedBox(height: 8),
                    if (volunteer.skills.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: volunteer.skills.map((s) => Chip(
                          label: Text(s, style: const TextStyle(fontSize: 10)),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        )).toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Assigned Tasks', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _showAddTaskModal(context, ref),
                icon: const Icon(Icons.add_task_rounded, size: 16),
                label: const Text('Assign Task'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  foregroundColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          tasksAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error loading tasks: $e'),
            data: (tasks) {
              final vTasks = tasks.where((t) => t.assignedToId == volunteer.id && t.assignedToType == AssigneeType.volunteer).toList();
              if (vTasks.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('No tasks assigned yet', style: TextStyle(color: AppColors.slate400))),
                );
              }
              return Column(
                children: vTasks.map((t) => _TaskItem(task: t)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddTaskModal(BuildContext context, WidgetRef ref) {
    AppModal.show(
      context: context,
      title: 'Assign Task to ${volunteer.name}',
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

class _TaskItem extends StatelessWidget {
  const _TaskItem({required this.task});
  final TaskEntity task;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : AppColors.slate50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? AppColors.slate700 : AppColors.slate200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text('Deadline: ${AppFormatters.displayDate(task.deadline)}', style: const TextStyle(fontSize: 11, color: AppColors.slate500)),
              ],
            ),
          ),
          AppBadge.taskStatus(task.status),
        ],
      ),
    );
  }
}

class _AddTaskForm extends StatefulWidget {
  const _AddTaskForm({required this.volunteer, required this.onSubmit});
  final VolunteerEntity volunteer;
  final Function(TaskEntity) onSubmit;

  @override
  State<_AddTaskForm> createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<_AddTaskForm> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  DateTime _deadline = DateTime.now().add(const Duration(days: 7));
  bool _requiresUpload = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Task Title'),
            onSaved: (val) => _title = val ?? '',
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Deadline'),
            subtitle: Text(AppFormatters.displayDate(AppFormatters.toIso(_deadline))),
            trailing: const Icon(Icons.calendar_month_rounded),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _deadline,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) setState(() => _deadline = picked);
            },
          ),
          SwitchListTile.adaptive(
            secondary: const Icon(Icons.camera_alt_rounded),
            title: const Text('Requires Image Upload'),
            subtitle: const Text('Volunteer must capture camera proof with geotag'),
            value: _requiresUpload,
            onChanged: (val) => setState(() => _requiresUpload = val),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                _formKey.currentState?.save();
                widget.onSubmit(TaskEntity(
                  id: '',
                  title: _title,
                  description: '',
                  deadline: AppFormatters.toIso(_deadline),
                  assignedToId: widget.volunteer.id,
                  assignedToName: widget.volunteer.name,
                  assignedToEmail: widget.volunteer.email,
                  assignedToType: AssigneeType.volunteer,
                  status: TaskStatus.pending,
                  requiresUpload: _requiresUpload,
                  createdAt: AppFormatters.today(),
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brand,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Assign Task'),
          ),
        ],
      ),
    );
  }
}

class _ApprovalQueue extends ConsumerWidget {
  const _ApprovalQueue();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final tasksAsync = ref.watch(taskProvider);
    final volunteersAsync = ref.watch(volunteerProvider);
    
    if (currentUser == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Pending Approvals',
          subtitle: 'Review task submissions from your guided volunteers',
        ),
        const SizedBox(height: 16),
        tasksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
          data: (tasks) {
            return volunteersAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => const SizedBox.shrink(),
              data: (volunteers) {
                // Get IDs of volunteers mentored by this member
                final mentoredIds = volunteers
                    .where((v) => v.mentorId == currentUser.id)
                    .map((v) => v.id)
                    .toSet();

                // Filter for submitted tasks from mentored volunteers
                final pendingTasks = tasks.where((t) => 
                  mentoredIds.contains(t.assignedToId) && 
                  t.status == TaskStatus.submitted
                ).toList();

                if (pendingTasks.isEmpty) {
                  return AppCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline_rounded, size: 20, color: AppColors.emerald500),
                        const SizedBox(width: 12),
                        const Text('All caught up! No pending approvals.',
                          style: TextStyle(color: AppColors.slate500, fontSize: 13)),
                      ],
                    ),
                  );
                }

                return Column(
                  children: pendingTasks.map((t) => _ApprovalItem(task: t)).toList(),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _ApprovalItem extends ConsumerWidget {
  const _ApprovalItem({required this.task});
  final TaskEntity task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppAvatar(
                  initials: AppFormatters.initials(task.assignedToName),
                  size: AvatarSize.small,
                  role: UserRole.volunteer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      Text('Submitted by ${task.assignedToName}', style: const TextStyle(color: AppColors.slate500, fontSize: 11)),
                    ],
                  ),
                ),
                AppBadge.taskStatus(task.status),
              ],
            ),
            const SizedBox(height: 12),
            if (task.uploadedImage != null)
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(task.uploadedImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleAction(ref, context, isApprove: false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.red500,
                      side: const BorderSide(color: AppColors.red100),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleAction(ref, context, isApprove: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald500,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Partial Approve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAction(WidgetRef ref, BuildContext context, {required bool isApprove}) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    try {
      if (isApprove) {
        await ref.read(taskProvider.notifier).updateStatus(
          task.id, 
          TaskStatus.waitingAdmin,
          approvedBy: currentUser.name,
        );
      } else {
        await ref.read(taskProvider.notifier).updateStatus(
          task.id, 
          TaskStatus.rejected,
        );
      }
      
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isApprove ? 'Task partially approved and escalated to Admin.' : 'Task rejected.'),
          backgroundColor: isApprove ? AppColors.emerald500 : AppColors.red500,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.red500),
      );
    }
  }
}
