import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/core/widgets/app_badge.dart';
import 'package:ngo_volunteer_management/core/widgets/app_card.dart';
import 'package:ngo_volunteer_management/core/widgets/app_modal.dart';
import 'package:ngo_volunteer_management/core/widgets/section_header.dart';
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

    return Column(
      children: [
        const SectionHeader(
          title: 'My Tasks',
          subtitle: 'Active assignments and submission portal',
        ),
        const SizedBox(height: 16),
        Expanded(
          child: tasksAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (tasks) {
              final myTasks = tasks.where((t) => t.assignedToId == currentUser.id).toList();

              if (myTasks.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_turned_in_rounded, size: 64, color: AppColors.slate200),
                      SizedBox(height: 16),
                      Text('No tasks assigned to you yet', style: TextStyle(color: AppColors.slate500)),
                    ],
                  ),
                );
              }

              return ListView.separated(
                itemCount: myTasks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final task = myTasks[index];
                  return _MemberTaskItem(task: task);
                },
              );
            },
          ),
        ),
      ],
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
            children: [
              Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                backgroundColor: AppColors.blue600,
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
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.blue600),
                  const SizedBox(width: 8),
                  const Expanded(
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
      child: _SubmitTaskForm(
        onSubmit: (imageUrl) {
          ref.read(taskProvider.notifier).submit(task.id, imagePath: imageUrl);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _SubmitTaskForm extends StatefulWidget {
  const _SubmitTaskForm({required this.onSubmit});
  final Function(String) onSubmit;

  @override
  State<_SubmitTaskForm> createState() => _SubmitTaskFormState();
}

class _SubmitTaskFormState extends State<_SubmitTaskForm> {
  String _imageUrl = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Please provide proof of completion (Image URL or photo)',
          style: TextStyle(fontSize: 14, color: AppColors.slate600),
        ),
        const SizedBox(height: 16),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.slate50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.slate200, style: BorderStyle.solid),
          ),
          child: _imageUrl.isEmpty
              ? InkWell(
                  onTap: () => setState(() => _imageUrl = 'https://picsum.photos/seed/${DateTime.now().millisecond}/400/300'),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_rounded, size: 48, color: AppColors.slate400),
                      SizedBox(height: 8),
                      Text('Tap to upload photo', style: TextStyle(color: AppColors.slate400, fontWeight: FontWeight.w500)),
                    ],
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(_imageUrl, fit: BoxFit.cover),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          onPressed: () => setState(() => _imageUrl = ''),
                          icon: const Icon(Icons.cancel_rounded, color: Colors.white),
                          style: IconButton.styleFrom(backgroundColor: Colors.black45),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _imageUrl.isEmpty ? null : () => widget.onSubmit(_imageUrl),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.emerald600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Confirm Submission'),
        ),
      ],
    );
  }
}