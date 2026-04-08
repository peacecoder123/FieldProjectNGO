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
              backgroundColor: AppColors.blue600,
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
                  child: Text('No meetings scheduled yet.', style: TextStyle(color: isDark ? AppColors.slate400 : AppColors.slate500)),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (upcoming.isNotEmpty) ...[
                  const Text('Upcoming Meetings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  ...upcoming.map((m) => _MeetingCard(meeting: m, isDark: isDark)),
                  const SizedBox(height: 24),
                ],
                if (completed.isNotEmpty) ...[
                  const Text('Completed Meetings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  ...completed.map((m) => _MeetingCard(meeting: m, isDark: isDark)),
                ]
              ],
            );
          },
        ),
      ],
    );
  }

  void _showAddMeetingDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final linkCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    final timeCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Schedule New Meeting'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Meeting Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: linkCtrl,
                decoration: const InputDecoration(labelText: 'Meeting Link (Zoom, Meet, etc.)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dateCtrl,
                decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)', hintText: 'e.g. 2026-05-10'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: timeCtrl,
                decoration: const InputDecoration(labelText: 'Time', hintText: 'e.g. 10:00 AM'),
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
              if (titleCtrl.text.isEmpty || dateCtrl.text.isEmpty) return;
              
              final meeting = MeetingEntity(
                id: 0, 
                title: titleCtrl.text, 
                date: dateCtrl.text, 
                time: timeCtrl.text, 
                attendees: const ['All Members', 'All Volunteers'], 
                status: MeetingStatus.upcoming,
                link: linkCtrl.text,
              );
              
              ref.read(meetingProvider.notifier).add(meeting);
              Navigator.of(ctx).pop();
            },
            child: const Text('Schedule'),
          ),
        ],
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: meeting.status == MeetingStatus.upcoming ? AppColors.blue50 : AppColors.emerald50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    meeting.status.name.toUpperCase(),
                    style: TextStyle(
                      color: meeting.status == MeetingStatus.upcoming ? AppColors.blue600 : AppColors.emerald600,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.slate500),
                const SizedBox(width: 6),
                Text(AppFormatters.displayDate(meeting.date), style: const TextStyle(fontSize: 12, color: AppColors.slate600)),
                const SizedBox(width: 16),
                Icon(Icons.schedule_rounded, size: 14, color: AppColors.slate500),
                const SizedBox(width: 6),
                Text(meeting.time, style: const TextStyle(fontSize: 12, color: AppColors.slate600)),
              ],
            ),
            if (meeting.link != null && meeting.link!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.link_rounded, size: 14, color: AppColors.blue500),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      meeting.link!,
                      style: const TextStyle(fontSize: 12, color: AppColors.blue600, decoration: TextDecoration.underline),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (meeting.summary != null && meeting.summary!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              const Text('Meeting Summary:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              Text(meeting.summary!, style: const TextStyle(fontSize: 13, height: 1.4)),
            ]
          ],
        ),
      ),
    );
  }
}
