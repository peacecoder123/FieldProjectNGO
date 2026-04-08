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

// /// VolunteerJoiningLetterTab: Volunteer view for requesting joining letters
// /// Mirrors React VolunteerJoiningLetterTab.tsx functionality
// class VolunteerJoiningLetterTab extends ConsumerStatefulWidget {
//   const VolunteerJoiningLetterTab({super.key});

//   @override
//   ConsumerState<VolunteerJoiningLetterTab> createState() => _VolunteerJoiningLetterTabState();
// }

// class _VolunteerJoiningLetterTabState extends ConsumerState<VolunteerJoiningLetterTab> {
//   String _selectedMonth = '';

//   @override
//   void initState() {
//     super.initState();
//     _selectedMonth = _generateMonthOptions().first['value']!;
//   }

//   List<Map<String, String>> _generateMonthOptions() {
//     final months = <Map<String, String>>[];
//     final base = DateTime(2025, 1, 1);
//     for (int i = 0; i < 24; i++) {
//       final d = DateTime(base.year, base.month + i, 1);
//       final label = '${_getMonthName(d.month)} ${d.year}';
//       months.add({'label': label, 'value': label});
//     }
//     return months;
//   }

//   String _getMonthName(int month) {
//     const months = [
//       'January', 'February', 'March', 'April', 'May', 'June',
//       'July', 'August', 'September', 'October', 'November', 'December'
//     ];
//     return months[month - 1];
//   }

//   void _handleSubmit() {
//     final currentUser = ref.read(currentUserProvider);
//     if (_selectedMonth.isEmpty || currentUser == null) return;

//     ref.read(joiningLetterProvider.notifier).add(
//       JoiningLetterRequestEntity(
//         id: DateTime.now().millisecondsSinceEpoch,
//         name: currentUser.name,
//         type: JoiningLetterType.volunteer,
//         requestDate: AppFormatters.today(),
//         status: RequestStatus.pending,
//         tenure: _selectedMonth,
//       ),
//     );

//     setState(() {
//       _selectedMonth = _generateMonthOptions().first['value']!;
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Request Submitted')),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentUser = ref.watch(currentUserProvider);
//     final lettersAsync = ref.watch(joiningLetterProvider);

//     return lettersAsync.when(
//       loading: () => const Center(child: CircularProgressIndicator()),
//       error: (e, _) => Center(child: Text('Error: $e')),
//       data: (letters) {
//         final myLetters = letters
//             .where((l) => l.name == currentUser?.name)
//             .toList()
//           ..sort((a, b) => b.requestDate.compareTo(a.requestDate));

//         return ListView(
//           padding: const EdgeInsets.all(20),
//           children: [
//             SectionHeader(
//               title: 'Joining Letter',
//               subtitle: 'Request your monthly joining/tenure letter',
//               actions: ElevatedButton.icon(
//                 onPressed: _handleSubmit,
//                 icon: const Icon(Icons.add_rounded, size: 18),
//                 label: const Text('Request Letter'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.orange500,
//                   foregroundColor: Colors.white,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Info Banner
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: AppColors.orange50,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: AppColors.orange200),
//                 boxShadow: const [
//                   BoxShadow(
//                     color: Color(0x0A000000),
//                     blurRadius: 6,
//                     spreadRadius: 1,
//                   )
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.file_present_rounded,
//                         color: AppColors.orange600,
//                         size: 20,
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Text(
//                           'Volunteer Tenure Letter',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: AppColors.orange800,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Volunteers can request a monthly joining/tenure letter. Select the month for which you need the letter.',
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: AppColors.orange700,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 24),

//             // Request History
//             if (myLetters.isEmpty)
//               const Center(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(vertical: 48),
//                   child: Text(
//                     'No requests yet',
//                     style: TextStyle(color: AppColors.slate500),
//                   ),
//                 ),
//               )
//             else
//               ...myLetters.map((letter) => _JoiningLetterCard(letter: letter)),
//           ],
//         );
//       },
//     );
//   }
// }

// // ---------------------------------------------------------------------------
// // _JoiningLetterCard – UI card for each pending/approved/rejected request
// // ---------------------------------------------------------------------------
// class _JoiningLetterCard extends StatelessWidget {
//   const _JoiningLetterCard({required this.letter});

//   final JoiningLetterRequestEntity letter;

//   @override
//   Widget build(BuildContext context) {
//     final statusColor = switch (letter.status) {
//       RequestStatus.approved => AppColors.emerald500,
//       RequestStatus.rejected => AppColors.red500,
//       RequestStatus.pending => AppColors.orange500,
//     };

//     final statusBgColor = switch (letter.status) {
//       RequestStatus.approved => AppColors.emerald50,
//       RequestStatus.rejected => AppColors.red50,
//       RequestStatus.pending => AppColors.orange50,
//     };

//     final statusIcon = switch (letter.status) {
//       RequestStatus.approved => Icons.check_circle_rounded,
//       RequestStatus.rejected => Icons.cancel_rounded,
//       RequestStatus.pending => Icons.schedule_rounded,
//     };

//     return AppCard(
//       elevation: letter.status == RequestStatus.pending ? 2 : 0,
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: statusBgColor,
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(color: statusColor, width: 1.5),
//             ),
//             child: Icon(statusIcon, color: statusColor, size: 20),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Joining Letter – ${letter.tenure}',
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 15,
//                   ),
//                 ),
//                 const SizedBox(height: 8),

//                 // Type badge
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: AppColors.orange100,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Text(
//                     'Monthly',
//                     style: TextStyle(
//                       fontSize: 11,
//                       color: AppColors.orange700,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),

//                 // Date row
//                 Row(
//                   children: [
//                     Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.slate400),
//                     const SizedBox(width: 4),
//                     Text(
//                       'Requested ${AppFormatters.displayDate(letter.requestDate)}',
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: AppColors.slate500,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),

//                 AppBadge.requestStatus(letter.status),

//                 const SizedBox(height: 12),

//                 // Approved actions
//                 if (letter.status == RequestStatus.approved && letter.generatedBy != null)
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         '✓ Generated by ${letter.generatedBy}',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: AppColors.emerald600,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       ElevatedButton.icon(
//                         onPressed: () {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text('Letter downloaded!'),
//                               backgroundColor: AppColors.emerald500,
//                             ),
//                           );
//                         },
//                         icon: const Icon(Icons.download_rounded, size: 16),
//                         label: const Text('Download Letter'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.emerald50,
//                           foregroundColor: AppColors.emerald600,
//                           elevation: 0,
//                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                         ),
//                       ),
//                     ],
//                   ),

//                 // Pending notice
//                 if (letter.status == RequestStatus.pending)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8),
//                     child: Row(
//                       children: [
//                         Icon(Icons.schedule_rounded, size: 12, color: AppColors.amber600),
//                         const SizedBox(width: 4),
//                         Text(
//                           'Awaiting admin review',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: AppColors.amber600,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                 // Rejected notice
//                 if (letter.status == RequestStatus.rejected)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8),
//                     child: Text(
//                       'Request rejected. Please contact your assigned admin.',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: AppColors.red500,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
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
import 'package:printing/printing.dart';
import 'package:ngo_volunteer_management/features/documents/services/pdf_generator_service.dart';



class VolunteerJoiningLetterTab extends ConsumerStatefulWidget {
  const VolunteerJoiningLetterTab({super.key});

  @override
  ConsumerState<VolunteerJoiningLetterTab> createState() => _VolunteerJoiningLetterTabState();
}

class _VolunteerJoiningLetterTabState extends ConsumerState<VolunteerJoiningLetterTab> {
  String _selectedMonth = '';

  @override
  void initState() {
    super.initState();
    _selectedMonth = _generateMonthOptions().first['value']!;
  }

  List<Map<String, String>> _generateMonthOptions() {
    final months = <Map<String, String>>[];
    final base = DateTime(2025, 1, 1);
    for (int i = 0; i < 24; i++) {
      final d = DateTime(base.year, base.month + i, 1);
      final label = '${_getMonthName(d.month)} ${d.year}';
      months.add({'label': label, 'value': label});
    }
    return months;
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  void _handleSubmit() {
    final currentUser = ref.read(currentUserProvider);
    if (_selectedMonth.isEmpty || currentUser == null) return;

    ref.read(joiningLetterProvider.notifier).add(
      JoiningLetterRequestEntity(
        id: DateTime.now().millisecondsSinceEpoch,
        name: currentUser.name,
        type: JoiningLetterType.volunteer,
        requestDate: AppFormatters.today(),
        status: RequestStatus.pending,
        tenure: _selectedMonth,
      ),
    );

    setState(() {
      _selectedMonth = _generateMonthOptions().first['value']!;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request Submitted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final lettersAsync = ref.watch(joiningLetterProvider);

    return lettersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (letters) {
        final myLetters = letters
            .where((l) => l.name == currentUser?.name)
            .toList()
          ..sort((a, b) => b.requestDate.compareTo(a.requestDate));

        return ListView(
          shrinkWrap: true, // Fixes unbounded height crash
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            SectionHeader(
              title: 'Joining Letter',
              subtitle: 'Request your monthly joining/tenure letter',
              actions: ElevatedButton.icon(
                onPressed: _handleSubmit,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Request Letter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange500,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.orange50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.orange200),
                boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 6, spreadRadius: 1)],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.file_present_rounded, color: AppColors.orange600, size: 20),
                      SizedBox(width: 12),
                      Expanded(child: Text('Volunteer Tenure Letter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.orange800))),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Volunteers can request a monthly joining/tenure letter. Select the month for which you need the letter.',
                    style: TextStyle(fontSize: 13, color: AppColors.orange700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (myLetters.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Text('No requests yet', style: TextStyle(color: AppColors.slate500)),
                ),
              )
            else
              ...myLetters.map((letter) => _JoiningLetterCard(letter: letter)),
          ],
        );
      },
    );
  }
}

class _JoiningLetterCard extends StatelessWidget {
  const _JoiningLetterCard({required this.letter});
  final JoiningLetterRequestEntity letter;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (letter.status) {
      RequestStatus.approved => AppColors.emerald500,
      RequestStatus.rejected => AppColors.red500,
      RequestStatus.pending => AppColors.orange500,
    };

    final statusBgColor = switch (letter.status) {
      RequestStatus.approved => AppColors.emerald50,
      RequestStatus.rejected => AppColors.red50,
      RequestStatus.pending => AppColors.orange50,
    };

    final statusIcon = switch (letter.status) {
      RequestStatus.approved => Icons.check_circle_rounded,
      RequestStatus.rejected => Icons.cancel_rounded,
      RequestStatus.pending => Icons.schedule_rounded,
    };

    return AppCard(
      elevation: letter.status == RequestStatus.pending ? 2 : 0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: statusColor, width: 1.5),
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Joining Letter – ${letter.tenure}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.orange100, borderRadius: BorderRadius.circular(12)),
                  child: const Text('Monthly', style: TextStyle(fontSize: 11, color: AppColors.orange700, fontWeight: FontWeight.w500)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.slate400),
                    const SizedBox(width: 4),
                    Text('Requested ${AppFormatters.displayDate(letter.requestDate)}', style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
                  ],
                ),
                const SizedBox(height: 8),
                AppBadge.requestStatus(letter.status),
                const SizedBox(height: 12),
                if (letter.status == RequestStatus.approved && letter.generatedBy != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('✓ Generated by ${letter.generatedBy}', style: const TextStyle(fontSize: 12, color: AppColors.emerald600)),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final pdfBytes = await PdfGeneratorService.generateJoiningLetterPdf(
                            name: letter.name,
                            tenure: letter.tenure,
                            requestDate: AppFormatters.displayDate(letter.requestDate),
                            approvedBy: letter.generatedBy,
                          );
                          await Printing.sharePdf(
                            bytes: pdfBytes,
                            filename: 'Joining_Letter_${letter.tenure.replaceAll(' ', '_')}.pdf',
                          );
                        },
                        icon: const Icon(Icons.download_rounded, size: 16),
                        label: const Text('Download Letter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.emerald50,
                          foregroundColor: AppColors.emerald600,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),

                    ],
                  ),
                if (letter.status == RequestStatus.pending)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(Icons.schedule_rounded, size: 12, color: AppColors.amber600),
                        SizedBox(width: 4),
                        Text('Awaiting admin review', style: TextStyle(fontSize: 12, color: AppColors.amber600, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                if (letter.status == RequestStatus.rejected)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('Request rejected. Please contact your assigned admin.', style: TextStyle(fontSize: 12, color: AppColors.red500, fontWeight: FontWeight.w500)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}