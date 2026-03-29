import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/core/widgets/app_badge.dart';
import 'package:ngo_volunteer_management/core/widgets/app_card.dart';
import 'package:ngo_volunteer_management/core/widgets/app_modal.dart';
import 'package:ngo_volunteer_management/core/widgets/section_header.dart';
import 'package:ngo_volunteer_management/shared/data/entities.dart';
import 'package:ngo_volunteer_management/shared/providers/app_providers.dart';
import 'package:ngo_volunteer_management/shared/providers/feature_providers.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';

class MemberMeetingsTab extends ConsumerWidget {
  const MemberMeetingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingsAsync = ref.watch(meetingProvider);
    final currentUser = ref.watch(currentUserProvider);

    return meetingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (meetings) {
        return ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            const SectionHeader(
              title: 'Meetings',
              subtitle: 'Scheduled catchups and meeting summaries',
            ),
            const SizedBox(height: 24),
            
            if (meetings.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Text('No meetings scheduled', style: TextStyle(color: AppColors.slate400)),
                )
              )
            else
              ...meetings.map((meeting) {
                final isAttendee = meeting.attendees.contains(currentUser?.name);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MeetingItem(meeting: meeting, isAttendee: isAttendee),
                );
              }),
          ],
        );
      },
    );
  }
}

class _MeetingItem extends ConsumerWidget {
  const _MeetingItem({required this.meeting, required this.isAttendee});
  final MeetingEntity meeting;
  final bool isAttendee;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPast = DateTime.parse(meeting.date).isBefore(DateTime.now());

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(meeting.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              const SizedBox(width: 12),
              if (isAttendee) const AppBadge(label: 'ATTENDING', color: AppColors.emerald500),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded, size: 14, color: AppColors.slate400),
              const SizedBox(width: 4),
              Text(AppFormatters.displayDate(meeting.date), style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
              const SizedBox(width: 12),
              const Icon(Icons.access_time_rounded, size: 14, color: AppColors.slate400),
              const SizedBox(width: 4),
              Text(meeting.time, style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
            ],
          ),
          const SizedBox(height: 16),
          if (meeting.summary != null && meeting.summary!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Summary:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.slate400)),
                  const SizedBox(height: 4),
                  Text(meeting.summary!, style: const TextStyle(fontSize: 13, height: 1.4)),
                ],
              ),
            )
          else if (isAttendee && isPast)
            ElevatedButton.icon(
              onPressed: () => _showAddSummaryModal(context, ref),
              icon: const Icon(Icons.edit_note_rounded, size: 18),
              label: const Text('Add Meeting Summary'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.slate100,
                foregroundColor: AppColors.slate700,
                elevation: 0,
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddSummaryModal(BuildContext context, WidgetRef ref) {
    AppModal.show(
      context: context,
      title: 'Add Meeting Summary',
      child: _AddSummaryForm(
        onSubmit: (summary) {
          ref.read(meetingProvider.notifier).addSummary(meeting.id, summary: summary);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _AddSummaryForm extends StatefulWidget {
  const _AddSummaryForm({required this.onSubmit});
  final Function(String) onSubmit;

  @override
  State<_AddSummaryForm> createState() => _AddSummaryFormState();
}

class _AddSummaryFormState extends State<_AddSummaryForm> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Enter a brief summary of the meeting outcomes...',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => widget.onSubmit(_controller.text),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue600, foregroundColor: Colors.white),
          child: const Text('Save Summary'),
        ),
      ],
    );
  }
}