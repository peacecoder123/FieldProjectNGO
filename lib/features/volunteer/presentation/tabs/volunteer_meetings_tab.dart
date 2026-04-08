// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
// import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
// import 'package:ngo_volunteer_management/core/widgets/app_badge.dart';
// import 'package:ngo_volunteer_management/core/widgets/app_card.dart';
// import 'package:ngo_volunteer_management/core/widgets/section_header.dart';
// import 'package:ngo_volunteer_management/shared/data/entities.dart';
// import 'package:ngo_volunteer_management/shared/providers/app_providers.dart';
// import 'package:ngo_volunteer_management/shared/providers/feature_providers.dart';
// import 'package:ngo_volunteer_management/utils/app_formatters.dart';

// /// VolunteerMeetingsTab - Volunteer view for meetings
// /// Mirrors React VolunteerMeetingsTab.tsx functionality
// class VolunteerMeetingsTab extends ConsumerStatefulWidget {
//   const VolunteerMeetingsTab({super.key});

//   @override
//   ConsumerState<VolunteerMeetingsTab> createState() => _VolunteerMeetingsTabState();
// }

// class _VolunteerMeetingsTabState extends ConsumerState<VolunteerMeetingsTab> {
//   MeetingEntity? _selectedMeeting;

//   void _showMeetingDetails(BuildContext context, MeetingEntity meeting) {
//     setState(() => _selectedMeeting = meeting);
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return DraggableScrollableSheet(
//           initialChildSize: 0.6,
//           minChildSize: 0.4,
//           maxChildSize: 0.9,
//           builder: (_, controller) {
//             return Container(
//               decoration: BoxDecoration(
//                 color: isDark ? AppColors.slate900 : Colors.white,
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//               ),
//               padding: const EdgeInsets.all(24),
//               child: ListView(
//                 controller: controller,
//                 children: [
//                   // Drag Handle
//                   Center(
//                     child: Container(
//                       width: 40,
//                       height: 4,
//                       margin: const EdgeInsets.only(bottom: 24),
//                       decoration: BoxDecoration(
//                         color: isDark ? AppColors.slate700 : AppColors.slate300,
//                         borderRadius: BorderRadius.circular(2),
//                       ),
//                     ),
//                   ),
                  
//                   // Header
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         child: Text(
//                           meeting.title,
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: isDark ? AppColors.slate100 : AppColors.slate900,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       if (meeting.status == MeetingStatus.upcoming)
//                         const AppBadge(
//                           label: 'UPCOMING',
//                           color: AppColors.blue500,
//                         )
//                       else
//                         const AppBadge(
//                           label: 'COMPLETED',
//                           color: AppColors.emerald500,
//                         ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),

//                   // Date & Time
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.calendar_today_rounded,
//                         size: 18,
//                         color: isDark ? AppColors.slate400 : AppColors.slate500,
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         '${AppFormatters.displayDate(meeting.date)} at ${meeting.time}',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: isDark ? AppColors.slate300 : AppColors.slate600,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                   const Divider(),
//                   const SizedBox(height: 16),

//                   // Attendees List
//                   Text(
//                     'Attendees (${meeting.attendees.length})',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: isDark ? AppColors.slate200 : AppColors.slate800,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: meeting.attendees.map(
//                       (a) => Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 6,
//                         ),
//                         decoration: BoxDecoration(
//                           color: isDark ? AppColors.slate800 : AppColors.slate100,
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(
//                             color: isDark ? AppColors.slate700 : AppColors.slate200,
//                           ),
//                         ),
//                         child: Text(
//                           a,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: isDark ? AppColors.slate300 : AppColors.slate700,
//                           ),
//                         ),
//                       ),
//                     ).toList(),
//                   ),
//                   const SizedBox(height: 24),

//                   // Minutes of Meeting (MOM)
//                   if (meeting.summary != null && meeting.summary!.isNotEmpty) ...[
//                     const Divider(),
//                     const SizedBox(height: 16),
//                     Row(
//                       children: [
//                         const Icon(Icons.description_rounded, size: 20, color: AppColors.emerald600),
//                         const SizedBox(width: 8),
//                         Text(
//                           'Minutes of Meeting',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: isDark ? AppColors.slate200 : AppColors.slate800,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Added by ${meeting.addedBy ?? 'Admin'}',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: isDark ? AppColors.slate400 : AppColors.slate500,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: isDark ? AppColors.slate800 : AppColors.slate50,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: isDark ? AppColors.slate700 : AppColors.slate200,
//                         ),
//                       ),
//                       child: Text(
//                         meeting.summary!,
//                         style: TextStyle(
//                           fontSize: 14,
//                           height: 1.5,
//                           color: isDark ? AppColors.slate300 : AppColors.slate700,
//                         ),
//                       ),
//                     ),
//                   ],
//                   const SizedBox(height: 40), // Bottom padding
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentUser = ref.watch(currentUserProvider);
//     final meetingsAsync = ref.watch(meetingProvider);

//     return meetingsAsync.when(
//       loading: () => const Center(child: CircularProgressIndicator()),
//       error: (e, _) => Center(child: Text('Error: $e')),
//       data: (meetings) {
//         final myMeetings = meetings
//             .where((m) => m.attendees.contains(currentUser?.name))
//             .toList();

//         final upcoming = myMeetings
//             .where((m) => m.status == MeetingStatus.upcoming)
//             .toList();
//         final completed = myMeetings
//             .where((m) => m.status == MeetingStatus.completed)
//             .toList();

//         return ListView(
//           padding: const EdgeInsets.all(20),
//           children: [
//             // Header
//             SectionHeader(
//               title: 'Minutes of Meeting',
//               subtitle:
//                   '${upcoming.length} upcoming · ${completed.length} completed (view only)',
//             ),
//             const SizedBox(height: 16),

//             // View-only notice
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: AppColors.blue50,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: AppColors.blue100),
//                 boxShadow: const [
//                   BoxShadow(
//                     color: Color(0x0A000000),
//                     blurRadius: 6,
//                     spreadRadius: 1,
//                   )
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   const Icon(Icons.info_outline_rounded,
//                       color: AppColors.blue600, size: 20),
//                   const SizedBox(width: 12),
//                   const Expanded(
//                     child: Text(
//                       'Meetings are visible to you in view-only mode. '
//                       'Meeting summaries can be added by Members.',
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: AppColors.blue500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),

//             // Upcoming Meetings
//             if (upcoming.isNotEmpty) ...[
//               const Text(
//                 'Upcoming Meetings',
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                   color: AppColors.slate500,
//                   letterSpacing: 0.5,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               ...upcoming.map((m) => _MeetingCard(
//                     meeting: m,
//                     onTap: () => _showMeetingDetails(context, m),
//                   )),
//               const SizedBox(height: 24),
//             ],

//             // Past Meetings
//             if (completed.isNotEmpty) ...[
//               const Text(
//                 'Past Meetings',
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                   color: AppColors.slate500,
//                   letterSpacing: 0.5,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               ...completed.map((m) => _MeetingCard(
//                     meeting: m,
//                     onTap: () => _showMeetingDetails(context, m),
//                   )),
//             ],

//             // No meetings message
//             if (myMeetings.isEmpty)
//               const Center(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(vertical: 48),
//                   child: Text(
//                     'No meetings scheduled',
//                     style: TextStyle(color: AppColors.slate500),
//                   ),
//                 ),
//               ),
//           ],
//         );
//       },
//     );
//   }
// }

// // Meeting card - UI for each meeting entry
// class _MeetingCard extends StatelessWidget {
//   const _MeetingCard({
//     required this.meeting,
//     required this.onTap,
//   });

//   final MeetingEntity meeting;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return AppCard(
//       onTap: onTap,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       meeting.title,
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 15,
//                         color: isDark ? AppColors.slate100 : AppColors.slate900,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.calendar_today_rounded,
//                           size: 14,
//                           color: isDark ? AppColors.slate400 : AppColors.slate500,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           '${AppFormatters.displayDate(meeting.date)} at ${meeting.time}',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: isDark ? AppColors.slate400 : AppColors.slate500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               if (meeting.status == MeetingStatus.upcoming)
//                 const AppBadge(
//                   label: 'UPCOMING',
//                   color: AppColors.blue500,
//                 )
//               else
//                 const AppBadge(
//                   label: 'COMPLETED',
//                   color: AppColors.emerald500,
//                 ),
//             ],
//           ),
//           const SizedBox(height: 12),

//           // Attendees
//           Wrap(
//             spacing: 6,
//             runSpacing: 6,
//             children: [
//               ...meeting.attendees.take(3).map(
//                 (a) => Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 10,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: isDark ? AppColors.slate700 : AppColors.slate100,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: isDark ? AppColors.slate700 : AppColors.slate200,
//                     ),
//                   ),
//                   child: Text(
//                     a,
//                     style: TextStyle(
//                       fontSize: 11,
//                       color: isDark ? AppColors.slate300 : AppColors.slate600,
//                     ),
//                   ),
//                 ),
//               ),
//               if (meeting.attendees.length > 3)
//                 Text(
//                   '+${meeting.attendees.length - 3} more',
//                   style: TextStyle(
//                     fontSize: 11,
//                     color: isDark ? AppColors.slate400 : AppColors.slate500,
//                   ),
//                 ),
//             ],
//           ),

//           // MOM indicator
//           if (meeting.summary != null && meeting.summary!.isNotEmpty) ...[
//             const SizedBox(height: 12),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: AppColors.emerald50,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: AppColors.emerald200),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(Icons.description_rounded,
//                       size: 16, color: AppColors.emerald600),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'MOM added by ${meeting.addedBy ?? 'Admin'}',
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: AppColors.emerald500,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                   const Icon(Icons.visibility_rounded,
//                       size: 16, color: AppColors.emerald600),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/core/widgets/app_badge.dart';
import 'package:ngo_volunteer_management/core/widgets/app_card.dart';
import 'package:ngo_volunteer_management/core/widgets/section_header.dart';
import 'package:ngo_volunteer_management/shared/data/entities.dart';
import 'package:ngo_volunteer_management/shared/providers/app_providers.dart';
import 'package:ngo_volunteer_management/shared/providers/feature_providers.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';

class VolunteerMeetingsTab extends ConsumerStatefulWidget {
  const VolunteerMeetingsTab({super.key});

  @override
  ConsumerState<VolunteerMeetingsTab> createState() => _VolunteerMeetingsTabState();
}

class _VolunteerMeetingsTabState extends ConsumerState<VolunteerMeetingsTab> {
  void _showMeetingDetails(BuildContext context, MeetingEntity meeting) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.slate900 : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(24),
              child: ListView(
                controller: controller,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.slate700 : AppColors.slate300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          meeting.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.slate100 : AppColors.slate900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (meeting.status == MeetingStatus.upcoming)
                        const AppBadge(label: 'UPCOMING', color: AppColors.blue500)
                      else
                        const AppBadge(label: 'COMPLETED', color: AppColors.emerald500),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 18, color: isDark ? AppColors.slate400 : AppColors.slate500),
                      const SizedBox(width: 8),
                      Text(
                        '${AppFormatters.displayDate(meeting.date)} at ${meeting.time}',
                        style: TextStyle(fontSize: 14, color: isDark ? AppColors.slate300 : AppColors.slate600),
                      ),
                    ],
                  ),
                  if (meeting.link != null && meeting.link!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.link_rounded, size: 18, color: AppColors.blue500),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            meeting.link!,
                            style: const TextStyle(fontSize: 14, color: AppColors.blue600, decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Attendees (${meeting.attendees.length})',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppColors.slate200 : AppColors.slate800),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: meeting.attendees.map(
                      (a) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.slate800 : AppColors.slate100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? AppColors.slate700 : AppColors.slate200),
                        ),
                        child: Text(a, style: TextStyle(fontSize: 12, color: isDark ? AppColors.slate300 : AppColors.slate700)),
                      ),
                    ).toList(),
                  ),
                  const SizedBox(height: 24),
                  if (meeting.summary != null && meeting.summary!.isNotEmpty) ...[
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.description_rounded, size: 20, color: AppColors.emerald600),
                        const SizedBox(width: 8),
                        Text(
                          'Minutes of Meeting',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? AppColors.slate200 : AppColors.slate800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Added by ${meeting.addedBy ?? 'Admin'}',
                      style: TextStyle(fontSize: 12, color: isDark ? AppColors.slate400 : AppColors.slate500),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.slate800 : AppColors.slate50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? AppColors.slate700 : AppColors.slate200),
                      ),
                      child: Text(
                        meeting.summary!,
                        style: TextStyle(fontSize: 14, height: 1.5, color: isDark ? AppColors.slate300 : AppColors.slate700),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final meetingsAsync = ref.watch(meetingProvider);

    return meetingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (meetings) {
        final myMeetings = meetings.where((m) => m.attendees.contains(currentUser?.name)).toList();
        final upcoming = myMeetings.where((m) => m.status == MeetingStatus.upcoming).toList();
        final completed = myMeetings.where((m) => m.status == MeetingStatus.completed).toList();

        return ListView(
          shrinkWrap: true, // Fixes unbounded height crash
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            SectionHeader(
              title: 'Minutes of Meeting',
              subtitle: '${upcoming.length} upcoming · ${completed.length} completed',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.blue50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.blue100),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.blue600, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Meetings are visible to you in view-only mode. Meeting summaries can be added by Members.',
                      style: TextStyle(fontSize: 13, color: AppColors.blue500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (upcoming.isNotEmpty) ...[
              const Text('Upcoming Meetings', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.slate500)),
              const SizedBox(height: 12),
              ...upcoming.map((m) => _MeetingCard(meeting: m, onTap: () => _showMeetingDetails(context, m))),
              const SizedBox(height: 24),
            ],
            if (completed.isNotEmpty) ...[
              const Text('Past Meetings', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.slate500)),
              const SizedBox(height: 12),
              ...completed.map((m) => _MeetingCard(meeting: m, onTap: () => _showMeetingDetails(context, m))),
            ],
            if (myMeetings.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 48), child: Text('No meetings scheduled', style: TextStyle(color: AppColors.slate500)))),
          ],
        );
      },
    );
  }
}

class _MeetingCard extends StatelessWidget {
  const _MeetingCard({required this.meeting, required this.onTap});
  final MeetingEntity meeting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(meeting.title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: isDark ? AppColors.slate100 : AppColors.slate900)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 14, color: isDark ? AppColors.slate400 : AppColors.slate500),
                        const SizedBox(width: 4),
                        Text('${AppFormatters.displayDate(meeting.date)} at ${meeting.time}', style: TextStyle(fontSize: 12, color: isDark ? AppColors.slate400 : AppColors.slate500)),
                      ],
                    ),
                    if (meeting.link != null && meeting.link!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.link_rounded, size: 14, color: AppColors.blue500),
                          const SizedBox(width: 4),
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
                  ],
                ),
              ),
              if (meeting.status == MeetingStatus.upcoming)
                const AppBadge(label: 'UPCOMING', color: AppColors.blue500)
              else
                const AppBadge(label: 'COMPLETED', color: AppColors.emerald500),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ...meeting.attendees.take(3).map(
                (a) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.slate700 : AppColors.slate100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppColors.slate700 : AppColors.slate200),
                  ),
                  child: Text(a, style: TextStyle(fontSize: 11, color: isDark ? AppColors.slate300 : AppColors.slate600)),
                ),
              ),
              if (meeting.attendees.length > 3)
                Text('+${meeting.attendees.length - 3} more', style: TextStyle(fontSize: 11, color: isDark ? AppColors.slate400 : AppColors.slate500)),
            ],
          ),
          if (meeting.summary != null && meeting.summary!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.emerald50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.emerald200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description_rounded, size: 16, color: AppColors.emerald600),
                  const SizedBox(width: 8),
                  Expanded(child: Text('MOM added by ${meeting.addedBy ?? 'Admin'}', style: const TextStyle(fontSize: 12, color: AppColors.emerald500, fontWeight: FontWeight.w500))),
                  const Icon(Icons.visibility_rounded, size: 16, color: AppColors.emerald600),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}