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

class VolunteerTasksTab extends ConsumerWidget {
  const VolunteerTasksTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final tasksAsync = ref.watch(taskProvider);

    return Column(
      children: [
        const SectionHeader(
          title: 'Tasks',
          subtitle: 'Assignments and completion proofs',
        ),
        const SizedBox(height: 16),
        Expanded(
          child: tasksAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (tasks) {
              final myTasks = tasks.where((t) => t.assignedToId == currentUser?.id).toList();

              if (myTasks.isEmpty) {
                return const Center(child: Text('No tasks assigned', style: TextStyle(color: AppColors.slate500)));
              }

              return ListView.separated(
                itemCount: myTasks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final task = myTasks[index];
                  return _VolunteerTaskItem(task: task);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _VolunteerTaskItem extends ConsumerWidget {
  const _VolunteerTaskItem({required this.task});
  final TaskEntity task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              _StatusBadge(status: task.status),
            ],
          ),
          const SizedBox(height: 4),
          Text('Deadline: ${AppFormatters.displayDate(task.deadline)}', style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
          if (task.status == TaskStatus.pending) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showSubmitModal(context, ref),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue600, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 40)),
              child: const Text('Submit Completion Proof'),
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
        onSubmit: (url) {
          ref.read(taskProvider.notifier).submit(task.id, imagePath: url);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final TaskStatus status;
  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      TaskStatus.pending => AppColors.amber500,
      TaskStatus.submitted => AppColors.blue500,
      TaskStatus.approved => AppColors.emerald500,
      TaskStatus.rejected => AppColors.red500,
    };
    return AppBadge(label: status.displayName.toUpperCase(), color: color);
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
      children: [
        const Text('Upload photo proof of task completion.'),
        const SizedBox(height: 16),
        InkWell(
          onTap: () => setState(() => _imageUrl = 'https://picsum.photos/400/300'),
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.slate200)),
            child: _imageUrl.isEmpty ? const Icon(Icons.add_a_photo_rounded, size: 40, color: AppColors.slate300) : Image.network(_imageUrl, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _imageUrl.isEmpty ? null : () => widget.onSubmit(_imageUrl),
          child: const Text('Confirm Submission'),
        ),
      ],
    );
  }
}