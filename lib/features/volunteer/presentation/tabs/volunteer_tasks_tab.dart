import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/core/widgets/app_badge.dart';
import 'package:ngo_volunteer_management/core/widgets/app_card.dart';
import 'package:ngo_volunteer_management/core/widgets/section_header.dart';
import 'package:ngo_volunteer_management/core/widgets/app_modal.dart';
import 'package:ngo_volunteer_management/core/widgets/app_task_image.dart';
import 'package:ngo_volunteer_management/core/widgets/submit_task_form.dart';
import 'package:ngo_volunteer_management/shared/data/entities.dart';
import 'package:ngo_volunteer_management/shared/providers/app_providers.dart';
import 'package:ngo_volunteer_management/shared/providers/feature_providers.dart';

/// VolunteerTasksTab – Volunteer view for managing tasks with filtering.
class VolunteerTasksTab extends ConsumerStatefulWidget {
  const VolunteerTasksTab({super.key});

  @override
  ConsumerState<VolunteerTasksTab> createState() => _VolunteerTasksTabState();
}

class _VolunteerTasksTabState extends ConsumerState<VolunteerTasksTab> {
  TaskStatus? _activeFilter;

  void _showTaskDetails(BuildContext context, TaskEntity task) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.slate900 : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(24),
              child: ListView(
                controller: controller,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.slate700 : AppColors.slate300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.slate100 : AppColors.slate900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      AppBadge.taskStatus(task.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    task.description,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: isDark ? AppColors.slate300 : AppColors.slate600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.event_busy_rounded, size: 18, color: AppColors.slate400),
                      const SizedBox(width: 8),
                      Text(
                        'Deadline: ${task.deadline}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.slate200 : AppColors.slate800,
                        ),
                      ),
                    ],
                  ),

                  if (task.status == TaskStatus.submitted || task.status == TaskStatus.approved) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: task.status == TaskStatus.approved 
                          ? (isDark ? AppColors.emerald500.withValues(alpha: 0.1) : AppColors.emerald50) 
                          : (isDark ? AppColors.blue500.withValues(alpha: 0.1) : AppColors.blue50),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: task.status == TaskStatus.approved 
                            ? (isDark ? AppColors.emerald500.withValues(alpha: 0.2) : AppColors.emerald100) 
                            : (isDark ? AppColors.blue500.withValues(alpha: 0.2) : AppColors.blue100),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                task.status == TaskStatus.approved ? Icons.check_circle_rounded : Icons.info_outline_rounded, 
                                size: 18, 
                                color: task.status == TaskStatus.approved ? AppColors.emerald500 : AppColors.blue500
                              ),
                              const SizedBox(width: 8),
                              Text(
                                task.status == TaskStatus.approved ? 'Task Approved' : 'Under Review',
                                style: TextStyle(
                                  fontSize: 14, 
                                  fontWeight: FontWeight.bold,
                                  color: task.status == TaskStatus.approved ? AppColors.emerald600 : AppColors.blue600
                                ),
                              ),
                            ],
                          ),
                          if (task.uploadedImage != null) ...[
                            const SizedBox(height: 16),
                            const Text(
                              'Submitted Evidence:',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.slate500),
                            ),
                            const SizedBox(height: 8),
                            AppTaskImage(imageUrl: task.uploadedImage, height: 200, width: double.infinity),
                          ],
                          if (task.geotag != null && task.geotag!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded, size: 14, color: AppColors.red500),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    task.geotag!,
                                    style: const TextStyle(
                                      fontSize: 12, 
                                      color: AppColors.slate500, 
                                      fontFamily: 'monospace'
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                  if (task.status == TaskStatus.pending || task.status == TaskStatus.rejected)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _handleSubmit(task);
                        },
                        icon: Icon(
                          task.requiresUpload ? Icons.upload_rounded : Icons.check_circle_rounded,
                          size: 18,
                        ),
                        label: Text(task.requiresUpload ? 'Upload Image & Submit' : 'Mark as Complete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: task.requiresUpload ? AppColors.blue600 : AppColors.emerald600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleSubmit(TaskEntity task) async {
    if (task.requiresUpload) {
      AppModal.show(
        context: context,
        title: 'Submit Task: ${task.title}',
        child: SubmitTaskForm(
          onSubmit: (imageUrl, geotag) async {
            await ref.read(taskProvider.notifier).submit(task.id, imagePath: imageUrl, geotag: geotag);
            if (mounted) Navigator.pop(context);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Task "${task.title}" submitted successfully')),
              );
            }
          },
        ),
      );
    } else {
      await ref.read(taskProvider.notifier).submit(task.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task "${task.title}" marked as complete')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final tasksAsync = ref.watch(taskProvider);

    return tasksAsync.when(
      skipLoadingOnRefresh: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (tasks) {
        final myTasks = tasks
            .where((t) =>
                t.assignedToType == AssigneeType.volunteer &&
                (t.assignedToId == currentUser?.id || 
                 (currentUser?.email != null && t.assignedToEmail == currentUser?.email)))
            .toList();

        final pendingCount = myTasks.where((t) => t.status == TaskStatus.pending).length;
        final submittedCount = myTasks.where((t) => t.status == TaskStatus.submitted).length;

        final filteredTasks = _activeFilter == null
            ? myTasks
            : myTasks.where((t) => t.status == _activeFilter).toList();

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(taskProvider);
            await Future.delayed(const Duration(milliseconds: 800));
          },
          child: ListView(
            shrinkWrap: true, // Fixes unbounded height crash
            physics: const AlwaysScrollableScrollPhysics(), // Smooth scrolling behavior
            padding: const EdgeInsets.all(20),
            children: [
              SectionHeader(
              title: 'My Tasks',
              subtitle: '$pendingCount pending · $submittedCount awaiting review',
            ),
            const SizedBox(height: 16),
            _buildFilterTabs(myTasks),
            const SizedBox(height: 16),
            if (filteredTasks.isEmpty)
              _buildEmptyState()
            else
              ...filteredTasks.map(
                (task) => _TaskCard(
                  task: task,
                  onTap: () => _showTaskDetails(context, task),
                  onSubmit: () => _handleSubmit(task),
                ),
              ),
          ],
        ),
      );
    },
  );
}

  Widget _buildFilterTabs(List<TaskEntity> tasks) {
    final filters = [
      (null, 'All', tasks.length),
      (TaskStatus.pending, 'Pending', tasks.where((t) => t.status == TaskStatus.pending).length),
      (TaskStatus.submitted, 'Submitted', tasks.where((t) => t.status == TaskStatus.submitted).length),
      (TaskStatus.approved, 'Approved', tasks.where((t) => t.status == TaskStatus.approved).length),
      (TaskStatus.rejected, 'Rejected', tasks.where((t) => t.status == TaskStatus.rejected).length),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isActive = _activeFilter == filter.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text('${filter.$2} (${filter.$3})'),
              backgroundColor: isActive ? AppColors.orange500 : null,
              labelStyle: TextStyle(
                color: isActive ? Colors.white : AppColors.slate600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              side: BorderSide(
                color: isActive ? AppColors.orange500 : AppColors.slate200,
              ),
              onPressed: () => setState(() => _activeFilter = filter.$1),
            ),
          );
        }).toList(),
      ), // <-- This was the missing parenthesis
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(Icons.check_circle_rounded, size: 48, color: AppColors.slate300),
            SizedBox(height: 12),
            Text(
              'No tasks in this category',
              style: TextStyle(color: AppColors.slate500),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.onTap,
    required this.onSubmit,
  });

  final TaskEntity task;
  final VoidCallback onTap;
  final VoidCallback onSubmit;

  int _getDaysLeft() {
    try {
      final deadline = DateTime.parse(task.deadline);
      final now = DateTime.now();
      return deadline.difference(now).inDays;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysLeft = _getDaysLeft();
    final isOverdue = daysLeft < 0;
    final isUrgent = daysLeft >= 0 && daysLeft <= 3;

    final statusColor = switch (task.status) {
      TaskStatus.approved     => AppColors.emerald500,
      TaskStatus.submitted    => AppColors.blue500,
      TaskStatus.waitingAdmin => AppColors.brand,
      TaskStatus.rejected     => AppColors.red500,
      TaskStatus.pending      => AppColors.amber500,
    };

    final statusIcon = switch (task.status) {
      TaskStatus.approved     => Icons.check_circle_rounded,
      TaskStatus.submitted    => Icons.check_circle_rounded,
      TaskStatus.waitingAdmin => Icons.admin_panel_settings_rounded,
      TaskStatus.rejected     => Icons.cancel_rounded,
      TaskStatus.pending      => Icons.schedule_rounded,
    };

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(statusIcon, color: statusColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                        AppBadge.taskStatus(task.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.slate500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: isOverdue
                                  ? AppColors.red500
                                  : isUrgent
                                      ? AppColors.amber500
                                      : AppColors.slate400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isOverdue
                                  ? 'Overdue ${daysLeft.abs()}d'
                                  : '$daysLeft days left',
                              style: TextStyle(
                                fontSize: 12,
                                color: isOverdue
                                    ? AppColors.red500
                                    : isUrgent
                                        ? AppColors.amber500
                                        : AppColors.slate500,
                              ),
                            ),
                          ],
                        ),
                        if (task.requiresUpload)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.image_rounded,
                                size: 14,
                                color: AppColors.blue500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                task.uploadedImage != null ? 'Photo submitted' : 'Upload required',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.blue500,
                                ),
                              ),
                            ],
                          ),
                        if (isUrgent && !isOverdue)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.amber50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.warning_rounded, size: 12, color: AppColors.amber600),
                                SizedBox(width: 4),
                                Text(
                                  'Urgent',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.amber600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (task.status == TaskStatus.submitted || task.status == TaskStatus.approved) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: task.status == TaskStatus.approved ? AppColors.emerald50 : AppColors.blue50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: task.status == TaskStatus.approved ? AppColors.emerald100 : AppColors.blue100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    children: [
                      Icon(
                        task.status == TaskStatus.approved ? Icons.check_circle_rounded : Icons.info_outline_rounded, 
                        size: 16, 
                        color: task.status == TaskStatus.approved ? AppColors.emerald600 : AppColors.blue600
                      ),
                      const SizedBox(width: 8),
                      Text(
                        task.status == TaskStatus.approved ? 'Task Approved' : 'Under Review',
                        style: TextStyle(
                          fontSize: 12, 
                          fontWeight: FontWeight.bold,
                          color: task.status == TaskStatus.approved ? AppColors.emerald600 : AppColors.blue600
                        ),
                      ),
                    ],
                  ),
                  if (task.uploadedImage != null) ...[
                    const SizedBox(height: 12),
                    AppTaskImage(imageUrl: task.uploadedImage, height: 120, width: double.infinity),
                  ],
                  if (task.geotag != null && task.geotag!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 12, color: AppColors.red500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '📍 ${task.geotag}',
                            style: const TextStyle(fontSize: 10, color: AppColors.slate500, fontFamily: 'monospace'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (task.status == TaskStatus.pending) ...[
            const Divider(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onSubmit,
                icon: Icon(
                  task.requiresUpload ? Icons.upload_rounded : Icons.check_circle_rounded,
                  size: 18,
                ),
                label: Text(task.requiresUpload ? 'Upload & Submit' : 'Mark Complete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: task.requiresUpload ? AppColors.blue600 : AppColors.emerald600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
          if (task.status == TaskStatus.rejected) ...[
            const Divider(height: 24),
            Row(
              children: [
                const Text(
                  'Task rejected',
                  style: TextStyle(fontSize: 12, color: AppColors.red500),
                ),
                TextButton.icon(
                  onPressed: onSubmit,
                  icon: const Icon(Icons.upload_rounded, size: 14),
                  label: const Text('Re-submit'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}