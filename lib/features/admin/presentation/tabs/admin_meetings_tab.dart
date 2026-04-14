import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/core/widgets/app_card.dart';
import 'package:ngo_volunteer_management/core/widgets/section_header.dart';
import 'package:ngo_volunteer_management/shared/providers/feature_providers.dart';
import 'package:ngo_volunteer_management/shared/data/entities.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';

class AdminMeetingsTab extends ConsumerWidget {
  const AdminMeetingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingsAsync = ref.watch(meetingProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        SectionHeader(
          title: 'Meetings Management',
          subtitle: 'Schedule and manage meetings for members and volunteers',
          actions: ElevatedButton.icon(
            onPressed: () => _showAddMeetingDialog(context, ref),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Schedule Meeting'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brand,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        meetingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (meetings) {
            final upcoming = meetings.where((m) => m.status == MeetingStatus.upcoming).toList();
            final completed = meetings.where((m) => m.status == MeetingStatus.completed).toList();

            if (meetings.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      Icon(Icons.groups_rounded, size: 48, color: isDark ? AppColors.slate600 : AppColors.slate300),
                      const SizedBox(height: 12),
                      Text('No meetings scheduled yet.', style: TextStyle(color: isDark ? AppColors.slate400 : AppColors.slate500)),
                    ],
                  ),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (upcoming.isNotEmpty) ...[
                  Row(
                    children: [
                      Container(width: 4, height: 18, decoration: BoxDecoration(color: AppColors.blue600, borderRadius: BorderRadius.circular(4))),
                      const SizedBox(width: 8),
                      const Text('Upcoming Meetings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...upcoming.map((m) => _MeetingCard(meeting: m, isDark: isDark)),
                  const SizedBox(height: 24),
                ],
                if (completed.isNotEmpty) ...[
                  Row(
                    children: [
                      Container(width: 4, height: 18, decoration: BoxDecoration(color: AppColors.emerald600, borderRadius: BorderRadius.circular(4))),
                      const SizedBox(width: 8),
                      const Text('Completed Meetings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...completed.map((m) => _MeetingCard(meeting: m, isDark: isDark)),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  void _showAddMeetingDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          title: const Text('Schedule New Meeting'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Meeting Title',
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                ),
                const SizedBox(height: 16),

                // Date Picker
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: selectedDate == null
                        ? ''
                        : AppFormatters.displayDate(AppFormatters.toIso(selectedDate!)),
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    hintText: 'Select date',
                    prefixIcon: Icon(Icons.calendar_today_rounded),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setModalState(() => selectedDate = picked);
                  },
                ),
                const SizedBox(height: 16),

                // Time Picker
                InkWell(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: ctx,
                      initialTime: selectedTime ?? TimeOfDay.now(),
                    );
                    if (picked != null) setModalState(() => selectedTime = picked);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Time',
                      prefixIcon: Icon(Icons.schedule_rounded),
                    ),
                    child: Text(
                      selectedTime == null
                          ? 'Tap to select time'
                          : selectedTime!.format(ctx),
                      style: TextStyle(
                        color: selectedTime == null ? Colors.grey : Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty || selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter title and date')),
                  );
                  return;
                }

                final meeting = MeetingEntity(
                  id: '',
                  title: titleCtrl.text.trim(),
                  date: AppFormatters.toIso(selectedDate!),
                  time: selectedTime?.format(ctx) ?? '',
                  attendees: const ['All Members', 'All Volunteers'],
                  status: MeetingStatus.upcoming,
                );

                ref.read(meetingProvider.notifier).add(meeting);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Meeting scheduled successfully'), backgroundColor: AppColors.brand),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.brand, foregroundColor: Colors.white),
              child: const Text('Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeetingCard extends StatelessWidget {
  const _MeetingCard({required this.meeting, required this.isDark});
  
  final MeetingEntity meeting;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isUpcoming = meeting.status == MeetingStatus.upcoming;
    final statusColor = isUpcoming ? AppColors.blue600 : AppColors.emerald600;
    final statusBg = isUpcoming
        ? (isDark ? AppColors.blue600.withValues(alpha: 0.15) : AppColors.blue50)
        : (isDark ? AppColors.emerald600.withValues(alpha: 0.15) : AppColors.emerald50);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    meeting.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? AppColors.white : AppColors.slate900,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    meeting.status.name.toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 14, color: isDark ? AppColors.slate400 : AppColors.slate500),
                const SizedBox(width: 6),
                Text(
                  AppFormatters.displayDate(meeting.date),
                  style: TextStyle(fontSize: 13, color: isDark ? AppColors.slate300 : AppColors.slate600),
                ),
                if (meeting.time.isNotEmpty) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.schedule_rounded, size: 14, color: isDark ? AppColors.slate400 : AppColors.slate500),
                  const SizedBox(width: 6),
                  Text(
                    meeting.time,
                    style: TextStyle(fontSize: 13, color: isDark ? AppColors.slate300 : AppColors.slate600),
                  ),
                ],
              ],
            ),
            if (meeting.attendees.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.people_rounded, size: 14, color: isDark ? AppColors.slate400 : AppColors.slate500),
                  const SizedBox(width: 6),
                  Text(
                    meeting.attendees.join(', '),
                    style: TextStyle(fontSize: 12, color: isDark ? AppColors.slate400 : AppColors.slate500),
                  ),
                ],
              ),
            ],
            if (meeting.summary != null && meeting.summary!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Meeting Summary',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? AppColors.slate200 : AppColors.slate700),
              ),
              const SizedBox(height: 4),
              Text(
                meeting.summary!,
                style: TextStyle(fontSize: 13, height: 1.4, color: isDark ? AppColors.slate300 : AppColors.slate600),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
