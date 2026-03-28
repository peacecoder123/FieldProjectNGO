import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/core/widgets/app_card.dart';
import 'package:ngo_volunteer_management/core/widgets/section_header.dart';
import 'package:ngo_volunteer_management/shared/providers/app_providers.dart';
import 'package:ngo_volunteer_management/shared/providers/feature_providers.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';

class VolunteerMeetingsTab extends ConsumerWidget {
  const VolunteerMeetingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingsAsync = ref.watch(meetingProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Column(
      children: [
        const SectionHeader(
          title: 'Meetings',
          subtitle: 'Upcoming sessions and catchups',
        ),
        const SizedBox(height: 16),
        Expanded(
          child: meetingsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (meetings) {
              final myMeetings = meetings.where((m) => m.attendees.contains(currentUser?.name)).toList();
              if (myMeetings.isEmpty) return const Center(child: Text('No meetings scheduled'));

              return ListView.separated(
                itemCount: myMeetings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final m = myMeetings[index];
                  return AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.slate400),
                            const SizedBox(width: 4),
                            Text('${AppFormatters.displayDate(m.date)} at ${m.time}', style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}