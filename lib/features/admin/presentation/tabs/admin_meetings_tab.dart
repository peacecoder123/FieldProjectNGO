import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
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
    final linkCtrl = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    // Fetch real member and volunteer names
    final memberNames = ref.read(memberProvider).value?.map((m) => m.name).toList() ?? [];
    final volunteerNames = ref.read(volunteerProvider).value?.map((v) => v.name).toList() ?? [];
    final allPeople = [...memberNames, ...volunteerNames];
    final selectedAttendees = Set<String>.from(allPeople); // all checked by default

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return AlertDialog(
            title: const Text('Schedule New Meeting'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Meeting Title',
                        prefixIcon: Icon(Icons.title_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: linkCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Meeting Link (Zoom, Meet, etc.)',
                        prefixIcon: Icon(Icons.link_rounded),
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
                            color: selectedTime == null ? Colors.grey : (isDark ? Colors.white : Colors.black87),
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Attendees section
                    Text('Attendees (${selectedAttendees.length}/${allPeople.length})',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? AppColors.slate200 : AppColors.slate800),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () => setModalState(() => selectedAttendees.addAll(allPeople)),
                          icon: const Icon(Icons.select_all_rounded, size: 16),
                          label: const Text('All', style: TextStyle(fontSize: 12)),
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () => setModalState(() => selectedAttendees.clear()),
                          icon: const Icon(Icons.deselect_rounded, size: 16),
                          label: const Text('None', style: TextStyle(fontSize: 12)),
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        ),
                      ],
                    ),
                    if (memberNames.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('Members', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.blue600)),
                      ...memberNames.map((name) => CheckboxListTile(
                        title: Text(name, style: const TextStyle(fontSize: 13)),
                        value: selectedAttendees.contains(name),
                        onChanged: (val) => setModalState(() {
                          if (val == true) selectedAttendees.add(name); else selectedAttendees.remove(name);
                        }),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        visualDensity: VisualDensity.compact,
                      )),
                    ],
                    if (volunteerNames.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('Volunteers', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.emerald600)),
                      ...volunteerNames.map((name) => CheckboxListTile(
                        title: Text(name, style: const TextStyle(fontSize: 13)),
                        value: selectedAttendees.contains(name),
                        onChanged: (val) => setModalState(() {
                          if (val == true) selectedAttendees.add(name); else selectedAttendees.remove(name);
                        }),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        visualDensity: VisualDensity.compact,
                      )),
                    ],
                  ],
                ),
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
                  if (selectedAttendees.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select at least one attendee')),
                    );
                    return;
                  }

                  final meeting = MeetingEntity(
                    id: '',
                    title: titleCtrl.text.trim(),
                    date: AppFormatters.toIso(selectedDate!),
                    time: selectedTime?.format(ctx) ?? '10:00 AM',
                    attendees: selectedAttendees.toList(),
                    status: MeetingStatus.upcoming,
                    link: linkCtrl.text.trim(),
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
          );
        },
      ),
    );
  }
}

class _MeetingCard extends ConsumerWidget {
  const _MeetingCard({required this.meeting, required this.isDark});
  final MeetingEntity meeting;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSummary = meeting.summary != null && meeting.summary!.isNotEmpty;
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
            // Title + badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    meeting.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? AppColors.white : AppColors.slate900),
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
            // Date + time
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
            // Clickable meeting link
            if (meeting.link != null && meeting.link!.isNotEmpty) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _openLink(meeting.link!),
                child: Row(
                  children: [
                    const Icon(Icons.link_rounded, size: 14, color: AppColors.blue500),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        meeting.link!,
                        style: const TextStyle(fontSize: 12, color: AppColors.blue600, decoration: TextDecoration.underline),
                        overflow: TextOverflow.ellipsis,
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
            if (!hasSummary && !isUpcoming && meeting.summaryAssignedTo != null) ...[
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
                onPressed: () => _showSummaryDialog(context),
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
            else if (isUpcoming)
              ElevatedButton.icon(
                onPressed: () => _showMarkCompletedDialog(context, ref),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                label: const Text('Mark as Completed'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.orange500.withValues(alpha: 0.15) : AppColors.orange50,
                  foregroundColor: AppColors.orange600,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              )
            else if (meeting.summaryAssignedTo == null || meeting.summaryAssignedTo == 'Admin')
              ElevatedButton.icon(
                onPressed: () => _showAddSummaryModal(context, ref, meeting),
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
      ),
    );
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showMarkCompletedDialog(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String assignTo = 'Admin';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: isDark ? AppColors.slate800 : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Mark Meeting as Completed', style: TextStyle(color: isDark ? Colors.white : AppColors.slate900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The meeting "${meeting.title}" will be marked as completed.',
                style: TextStyle(fontSize: 14, color: isDark ? AppColors.slate300 : AppColors.slate600),
              ),
              const SizedBox(height: 20),
              Text('Assign summary writing to:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? AppColors.slate200 : AppColors.slate800)),
              const SizedBox(height: 12),
              ...['Admin', 'Member'].map((role) => RadioListTile<String>(
                title: Text(role, style: TextStyle(color: isDark ? AppColors.slate200 : AppColors.slate800)),
                value: role,
                groupValue: assignTo,
                activeColor: AppColors.blue600,
                onChanged: (val) => setDialogState(() => assignTo = val!),
                contentPadding: EdgeInsets.zero,
                dense: true,
              )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(meetingProvider.notifier).markCompleted(meeting.id, summaryAssignedTo: assignTo);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Meeting marked as completed. Summary assigned to $assignTo.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue600, foregroundColor: Colors.white),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSummaryDialog(BuildContext context) {
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
            Expanded(child: Text(meeting.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.slate900))),
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
              const SizedBox(height: 4),
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
                const SizedBox(height: 4),
                Text('Added by ${meeting.addedBy}', style: TextStyle(fontSize: 12, color: isDark ? AppColors.slate400 : AppColors.slate500)),
              ],
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Text('Meeting Summary', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? AppColors.slate200 : AppColors.slate800)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.slate900 : AppColors.slate50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.slate700 : AppColors.slate200),
                ),
                child: Text(meeting.summary!, style: TextStyle(fontSize: 14, height: 1.6, color: isDark ? AppColors.slate300 : AppColors.slate700)),
              ),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close'))],
      ),
    );
  }

  void _showAddSummaryModal(BuildContext context, WidgetRef ref, MeetingEntity meeting) {
    final summaryCtrl = TextEditingController();
    final namesCtrl = TextEditingController(text: meeting.attendees.join(', '));
    final countCtrl = TextEditingController(text: meeting.attendees.length.toString());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.slate800 : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add Meeting Summary', style: TextStyle(color: isDark ? Colors.white : AppColors.slate900)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Meeting Details', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppColors.slate300 : AppColors.slate700)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 13, color: isDark ? AppColors.slate400 : AppColors.slate500),
                    const SizedBox(width: 6),
                    Text('${AppFormatters.displayDate(meeting.date)} at ${meeting.time}', style: TextStyle(fontSize: 12, color: isDark ? AppColors.slate400 : AppColors.slate500)),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Manual Attendees Input
                Text('Who Attended?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? AppColors.slate300 : AppColors.slate700)),
                const SizedBox(height: 8),
                TextField(
                  controller: namesCtrl,
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
                    controller: countCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'e.g. 5',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    style: TextStyle(fontSize: 13, color: isDark ? Colors.white : AppColors.slate900),
                  ),
                ),
                
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                Text('Meeting Summary', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppColors.slate300 : AppColors.slate700)),
                const SizedBox(height: 8),
                TextField(
                  controller: summaryCtrl, 
                  maxLines: 4, 
                  decoration: InputDecoration(
                    hintText: 'Enter a brief summary of the meeting outcomes...', 
                    border: const OutlineInputBorder(), 
                    hintStyle: TextStyle(color: isDark ? AppColors.slate500 : AppColors.slate400)
                  )
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (summaryCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a summary'))
                );
                return;
              }
              
              // Split names by comma and clean up whitespace
              final List<String> finalAttendees = namesCtrl.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
              
              ref.read(meetingProvider.notifier).addSummary(
                meeting.id, 
                summary: summaryCtrl.text.trim(),
                attendees: finalAttendees,
              );
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue600, foregroundColor: Colors.white),
            child: const Text('Save Summary'),
          ),
        ],
      ),
    );
  }

}