import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/core/widgets/app_badge.dart';
import 'package:ngo_volunteer_management/core/widgets/app_card.dart';
import 'package:ngo_volunteer_management/core/widgets/app_modal.dart';
import 'package:ngo_volunteer_management/core/widgets/section_header.dart';
import 'package:ngo_volunteer_management/core/widgets/submit_task_form.dart';
import 'package:ngo_volunteer_management/shared/data/entities.dart';
import 'package:ngo_volunteer_management/shared/providers/app_providers.dart';
import 'package:ngo_volunteer_management/shared/providers/feature_providers.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';

class MemberTasksTab extends ConsumerWidget {
  const MemberTasksTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final tasksAsync = ref.watch(taskProvider);

    if (currentUser == null) return const Center(child: Text('Please login'));

    return tasksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (tasks) {
        final myTasks = tasks
            .where((t) =>
                t.assignedToType == AssigneeType.member &&
                t.assignedToId == currentUser.id)
            .toList();

        return ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            const SectionHeader(
              title: 'My Tasks',
              subtitle: 'Active assignments and submission portal',
            ),
            const SizedBox(height: 24),
            
            if (myTasks.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      Icon(Icons.assignment_turned_in_rounded, size: 64, color: AppColors.slate200),
                      SizedBox(height: 16),
                      Text('No tasks assigned to you yet', style: TextStyle(color: AppColors.slate500)),
                    ],
                  ),
                ),
              )
            else
              ...myTasks.map((task) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MemberTaskItem(task: task),
              )),
          ],
        );
      },
    );
  }
}

class _MemberTaskItem extends ConsumerWidget {
  const _MemberTaskItem({required this.task});
  final TaskEntity task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = switch (task.status) {
      TaskStatus.pending => AppColors.amber500,
      TaskStatus.submitted => AppColors.blue500,
      TaskStatus.approved => AppColors.emerald500,
      TaskStatus.rejected => AppColors.red500,
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              const SizedBox(width: 12),
              AppBadge(label: task.status.displayName.toUpperCase(), color: statusColor),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.slate400),
              const SizedBox(width: 4),
              Text(
                'Deadline: ${AppFormatters.displayDate(task.deadline)}',
                style: const TextStyle(fontSize: 12, color: AppColors.slate500),
              ),
            ],
          ),
          if (task.status == TaskStatus.pending) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showSubmitModal(context, ref),
              icon: const Icon(Icons.cloud_upload_rounded, size: 18),
              label: const Text('Submit Completion'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ] else if (task.status == TaskStatus.submitted) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.blue50, borderRadius: BorderRadius.circular(8)),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: AppColors.blue600),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your submission is under review by the admin.',
                      style: TextStyle(fontSize: 12, color: AppColors.blue600, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showSubmitModal(BuildContext context, WidgetRef ref) {
    AppModal.show(
      context: context,
      title: 'Submit Task: ${task.title}',
      child: SubmitTaskForm(
        onSubmit: (imageUrl, geotag) {
          ref.read(taskProvider.notifier).submit(task.id, imagePath: imageUrl, geotag: geotag);
          Navigator.pop(context);
        },
      ),
    );
  }
}