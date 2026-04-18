import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/core/widgets/app_badge.dart';
import 'package:ngo_volunteer_management/core/widgets/app_task_image.dart';
import 'package:ngo_volunteer_management/shared/data/entities.dart';
import 'package:ngo_volunteer_management/shared/providers/feature_providers.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';

class TaskDetailsModal extends ConsumerWidget {
  const TaskDetailsModal({super.key, required this.task});
  final TaskEntity task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Assigned to: ${task.assignedToName}',
                      style: const TextStyle(fontSize: 13, color: AppColors.slate500),
                    ),
                  ],
                ),
              ),
              AppBadge.taskStatus(task.status),
            ],
          ),
          const SizedBox(height: 20),

          // Timeline Info
          _buildInfoSection(
            icon: Icons.calendar_today_rounded,
            label: 'Timeline',
            content: Row(
              children: [
                _buildTimelineItem('Created', task.createdAt, isDark),
                const SizedBox(width: 24),
                _buildTimelineItem('Deadline', AppFormatters.displayDate(task.deadline), isDark, color: AppColors.orange600),
                if (task.submittedAt != null) ...[
                  const SizedBox(width: 24),
                  _buildTimelineItem('Submitted', task.submittedAt!, isDark, color: AppColors.blue600),
                ],
              ],
            ),
          ),
          const Divider(height: 32),

          // Description
          _buildInfoSection(
            icon: Icons.description_rounded,
            label: 'Description',
            content: Text(
              task.description.isEmpty ? 'No description provided.' : task.description,
              style: TextStyle(height: 1.5, color: isDark ? AppColors.slate300 : AppColors.slate700),
            ),
          ),
          const SizedBox(height: 24),

          // Evidence Section
          if (task.status == TaskStatus.submitted || 
              task.status == TaskStatus.waitingAdmin || 
              task.status == TaskStatus.approved) ...[
            const Text(
              'SUBMISSION EVIDENCE',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, color: AppColors.slate400),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.slate800 : AppColors.slate50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.slate700 : AppColors.slate200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (task.uploadedImage != null) ...[
                    const Text('Captured Photo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    AppTaskImage(imageUrl: task.uploadedImage, height: 250, width: double.infinity),
                    const SizedBox(height: 16),
                  ],
                  if (task.geotag != null && task.geotag!.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 16, color: AppColors.red500),
                        const SizedBox(width: 8),
                        const Text('Submission Location', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.slate900 : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.geotag!,
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: AppColors.slate500),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.map_rounded, size: 18, color: AppColors.brand),
                            onPressed: () {
                              // In a real app, open Google Maps URL
                            },
                            tooltip: 'View on Map',
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (task.uploadedImage == null && (task.geotag == null || task.geotag!.isEmpty))
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No evidence metadata available', style: TextStyle(color: AppColors.slate400, fontSize: 12)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],

          // Admin Actions
          if (task.status == TaskStatus.submitted || task.status == TaskStatus.waitingAdmin)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(taskProvider.notifier).updateStatus(task.id, TaskStatus.approved);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Approve Task'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(taskProvider.notifier).updateStatus(task.id, TaskStatus.rejected);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.red600,
                      side: const BorderSide(color: AppColors.red600),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close Details'),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoSection({required IconData icon, required String label, required Widget content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.brand),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.brand)),
          ],
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildTimelineItem(String label, String value, bool isDark, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.slate400, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color ?? (isDark ? AppColors.slate200 : AppColors.slate800),
          ),
        ),
      ],
    );
  }
}
