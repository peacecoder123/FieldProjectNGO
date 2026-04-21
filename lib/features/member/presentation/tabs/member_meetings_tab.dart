import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPast = DateTime.tryParse(meeting.date)?.isBefore(DateTime.now()) ?? false;
    final hasSummary = meeting.summary != null && meeting.summary!.isNotEmpty;

    Future<void> openLink(String url) async {
      final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(meeting.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : AppColors.slate900))),
              const SizedBox(width: 12),
              if (isAttendee) const AppBadge(label: 'ATTENDING', color: AppColors.emerald500),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_month_rounded, size: 14, color: isDark ? AppColors.slate400 : AppColors.slate400),
              const SizedBox(width: 4),
              Text(AppFormatters.displayDate(meeting.date), style: TextStyle(fontSize: 12, color: isDark ? AppColors.slate400 : AppColors.slate500)),
              const SizedBox(width: 12),
              Icon(Icons.access_time_rounded, size: 14, color: isDark ? AppColors.slate400 : AppColors.slate400),
              const SizedBox(width: 4),
              Text(meeting.time, style: TextStyle(fontSize: 12, color: isDark ? AppColors.slate400 : AppColors.slate500)),
            ],
          ),
          if (meeting.link != null && meeting.link!.isNotEmpty) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: () => openLink(meeting.link!),
              child: Row(
                children: [
                  const Icon(Icons.link_rounded, size: 14, color: AppColors.blue500),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      meeting.link!,
                      style: const TextStyle(fontSize: 12, color: AppColors.blue600, decoration: TextDecoration.underline),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.open_in_new_rounded, size: 12, color: AppColors.blue500),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Assignment badge
          if (!hasSummary && isPast && meeting.summaryAssignedTo != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.blue600.withValues(alpha: 0.15) : AppColors.blue50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? AppColors.blue600.withValues(alpha: 0.3) : AppColors.blue100),
              ),
              child: Row(
                children: [
                  const Icon(Icons.assignment_ind_rounded, size: 16, color: AppColors.blue600),
                  const SizedBox(width: 8),
                  Text(
                    'Summary assigned to: ${meeting.summaryAssignedTo}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.blue600),
                  ),
                ],
              ),
            ),
          ],
          // Action buttons
          if (hasSummary)
            ElevatedButton.icon(
              onPressed: () => _showSummaryDialog(context, meeting),
              icon: const Icon(Icons.visibility_rounded, size: 16),
              label: const Text('View Summary'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.emerald600.withValues(alpha: 0.2) : AppColors.emerald50,
                foregroundColor: AppColors.emerald600,
                elevation: 0,
                minimumSize: const Size(double.infinity, 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            )
          else if (isPast && _canAddSummary(ref))
            ElevatedButton.icon(
              onPressed: () => _showAddSummaryModal(context, ref),
              icon: const Icon(Icons.edit_note_rounded, size: 18),
              label: const Text('Add Meeting Summary'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.slate700 : AppColors.slate100,
                foregroundColor: isDark ? AppColors.slate300 : AppColors.slate700,
                elevation: 0,
                minimumSize: const Size(double.infinity, 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
        ],
      ),
    );
  }

  /// Returns true if the current user is allowed to add the MoM summary.
  /// Only the specifically assigned person (by name) or a superAdmin can do it.
  bool _canAddSummary(WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) return false;
    // Super Admin can always add
    if (currentUser.role == UserRole.superAdmin) return true;
    // If no one is assigned yet, no one except superAdmin can add
    if (meeting.summaryAssignedTo == null) return false;
    // Only the assigned person (matched by name) can add
    return currentUser.name == meeting.summaryAssignedTo;
  }

  void _showSummaryDialog(BuildContext context, MeetingEntity meeting) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.slate800 : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.description_rounded, color: AppColors.emerald600, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                meeting.title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.slate900),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 13, color: isDark ? AppColors.slate400 : AppColors.slate500),
                  const SizedBox(width: 6),
                  Text('${AppFormatters.displayDate(meeting.date)} at ${meeting.time}', style: TextStyle(fontSize: 12, color: isDark ? AppColors.slate400 : AppColors.slate500)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.people_rounded, size: 14, color: isDark ? AppColors.slate400 : AppColors.slate500),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Members Attended: ${meeting.attendees.length}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.slate300 : AppColors.slate700),
                        ),
                        const SizedBox(height: 4),
                        ...meeting.attendees.map((attendee) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text('• $attendee', style: TextStyle(fontSize: 12, color: isDark ? AppColors.slate400 : AppColors.slate500)),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
              if (meeting.addedBy != null) ...[
                const SizedBox(height: 8),
                Text('Added by ${meeting.addedBy}', style: TextStyle(fontSize: 12, color: isDark ? AppColors.slate400 : AppColors.slate500)),
              ],
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'Meeting Summary',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? AppColors.slate200 : AppColors.slate800),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.slate900 : AppColors.slate50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.slate700 : AppColors.slate200),
                ),
                child: Text(
                  meeting.summary!,
                  style: TextStyle(fontSize: 14, height: 1.6, color: isDark ? AppColors.slate300 : AppColors.slate700),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
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
        meeting: meeting,
        onSubmit: (summary, attendedList) {
          ref.read(meetingProvider.notifier).addSummary(
            meeting.id, 
            summary: summary,
            attendees: attendedList,
          );
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _AddSummaryForm extends StatefulWidget {
  const _AddSummaryForm({required this.meeting, required this.onSubmit});
  final MeetingEntity meeting;
  final Function(String, List<String>) onSubmit;

  @override
  State<_AddSummaryForm> createState() => _AddSummaryFormState();
}

class _AddSummaryFormState extends State<_AddSummaryForm> {
  final _summaryCtrl = TextEditingController();
  late TextEditingController _namesCtrl;
  late TextEditingController _countCtrl;

  @override
  void initState() {
    super.initState();
    _namesCtrl = TextEditingController(text: widget.meeting.attendees.join(', '));
    _countCtrl = TextEditingController(text: widget.meeting.attendees.length.toString());
  }

  @override
  void dispose() {
    _summaryCtrl.dispose();
    _namesCtrl.dispose();
    _countCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Meeting Details', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppColors.slate300 : AppColors.slate700)),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 13, color: isDark ? AppColors.slate400 : AppColors.slate500),
            const SizedBox(width: 6),
            Text('${AppFormatters.displayDate(widget.meeting.date)} at ${widget.meeting.time}', style: TextStyle(fontSize: 12, color: isDark ? AppColors.slate400 : AppColors.slate500)),
          ],
        ),
        const SizedBox(height: 16),
        
        // Manual Attendees Input
        Text('Who Attended?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? AppColors.slate300 : AppColors.slate700)),
        const SizedBox(height: 8),
        TextField(
          controller: _namesCtrl,
          decoration: InputDecoration(
            hintText: 'Enter names separated by commas...',
            hintStyle: TextStyle(fontSize: 13, color: isDark ? AppColors.slate500 : AppColors.slate400),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          style: TextStyle(fontSize: 13, color: isDark ? Colors.white : AppColors.slate900),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        
        Text('Total Attended Count', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? AppColors.slate300 : AppColors.slate700)),
        const SizedBox(height: 8),
        SizedBox(
          width: 120,
          child: TextField(
            controller: _countCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'e.g. 5',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            style: TextStyle(fontSize: 13, color: isDark ? Colors.white : AppColors.slate900),
          ),
        ),

        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 12),
        Text('Meeting Summary', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppColors.slate300 : AppColors.slate700)),
        const SizedBox(height: 8),
        TextField(
          controller: _summaryCtrl,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Enter a brief summary of the meeting outcomes...',
            border: const OutlineInputBorder(),
            hintStyle: TextStyle(color: isDark ? AppColors.slate500 : AppColors.slate400),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if (_summaryCtrl.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a summary'))
              );
              return;
            }

            final List<String> finalAttendees = _namesCtrl.text
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();

            widget.onSubmit(_summaryCtrl.text.trim(), finalAttendees);
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.brand, foregroundColor: Colors.white),
          child: const Text('Save Summary'),
        ),
      ],
    );
  }
}