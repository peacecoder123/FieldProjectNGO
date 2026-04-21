import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/core/widgets/app_card.dart';
import 'package:ngo_volunteer_management/core/widgets/section_header.dart';
import 'package:ngo_volunteer_management/shared/providers/feature_providers.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';
import 'package:ngo_volunteer_management/domain/entities/document_request.entity.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/shared/data/entities.dart';
import 'package:ngo_volunteer_management/shared/providers/app_providers.dart';
import 'package:ngo_volunteer_management/features/documents/services/pdf_generator_service.dart';
import 'package:printing/printing.dart';

class MemberCertificateTab extends ConsumerWidget {
  const MemberCertificateTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(documentRequestProvider);
    final lettersAsync  = ref.watch(joiningLetterProvider);
    final mouAsync      = ref.watch(mouRequestProvider);
    final currentUser   = ref.watch(currentUserProvider);

    return requestsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (requests) {
        return lettersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (letters) {
            return mouAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (mous) {
                final approvedCertificates = requests.where((r) => 
                   r.userId == currentUser?.id.toString() && 
                   r.status == DocumentRequestStatus.approved
                ).toList();
                
                final approvedLetters = letters.where((l) => 
                   l.name == currentUser?.name && 
                   l.status == RequestStatus.approved
                ).toList();

                final approvedMous = mous.where((m) =>
                   m.requesterName == currentUser?.name &&
                   m.status == RequestStatus.approved &&
                   m.certificateUrl != null
                ).toList();

                final isEmpty = approvedCertificates.isEmpty && approvedLetters.isEmpty && approvedMous.isEmpty;
                
                return ListView(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  children: [
                    SectionHeader(
                      title: 'Certificates & Requests',
                      subtitle: 'Request and download your official documentation',
                      actions: ElevatedButton.icon(
                        onPressed: () {
                          final currentUser = ref.read(currentUserProvider);
                          final req = DocumentRequestEntity(
                            id: '',
                            userId: currentUser?.id.toString() ?? 'user_1',
                            userName: currentUser?.name ?? 'Member',
                            documentType: DocumentType.certificate,
                            requestedAt: DateTime.now(),
                          );
                          ref.read(documentRequestProvider.notifier).add(req);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Certificate Requested')));
                        },
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Request Certificate'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brand,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: const StadiumBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    if (isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: Column(
                            children: [
                              Icon(Icons.badge_rounded, size: 64, color: AppColors.slate200),
                              SizedBox(height: 16),
                              Text('No approved certificates yet', style: TextStyle(color: AppColors.slate500)),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      ...approvedCertificates.map((req) => _DocumentRequestCard(req: req)),
                      ...approvedLetters.map((letter) => _JoiningLetterDocCard(letter: letter)),
                      ...approvedMous.map((mou) => _MouAcceptanceDocCard(mou: mou)),
                    ],
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _JoiningLetterDocCard extends StatelessWidget {
  const _JoiningLetterDocCard({required this.letter});
  final JoiningLetterRequestEntity letter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.emerald100.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.description_rounded, color: AppColors.emerald600, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Joining Letter – ${letter.tenure}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(
                    'Issued on ${AppFormatters.displayDate(letter.requestDate)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.slate500),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.download_rounded, color: AppColors.emerald600),
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
            ),
          ],
        ),
      ),
    );
  }
}

class _MouAcceptanceDocCard extends StatelessWidget {
  const _MouAcceptanceDocCard({required this.mou});
  final MouRequestEntity mou;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.rose100.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.local_hospital_rounded, color: AppColors.rose600, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MOU Acceptance – ${mou.hospital}', 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  const Text('Hospital MOU Acceptance Letter', 
                      style: TextStyle(fontSize: 12, color: AppColors.slate500)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.print_rounded, color: AppColors.rose600),
              onPressed: () async {
                 await Printing.layoutPdf(
                   onLayout: (_) => PdfGeneratorService.generateMouAcceptancePdf(
                     patientName: mou.patientName,
                     hospitalName: mou.hospital,
                     address: mou.address,
                     date: AppFormatters.displayDate(mou.approvedAt ?? mou.requestDate),
                   ),
                 );
              },
            ),
            IconButton(
              icon: const Icon(Icons.download_rounded, color: AppColors.rose600),
              onPressed: () async {
                final pdfBytes = await PdfGeneratorService.generateMouAcceptancePdf(
                  patientName: mou.patientName,
                  hospitalName: mou.hospital,
                  address: mou.address,
                  date: AppFormatters.displayDate(mou.approvedAt ?? mou.requestDate),
                );
                await Printing.sharePdf(bytes: pdfBytes, filename: 'MOU_Acceptance_${mou.patientName.replaceAll(' ', '_')}.pdf');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentRequestCard extends ConsumerWidget {
  const _DocumentRequestCard({required this.req});
  final DocumentRequestEntity req;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.blue100.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.workspace_premium_rounded, color: AppColors.blue600, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Internship Certificate', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(
                    'Requested on ${AppFormatters.displayDate(req.requestedAt.toIso8601String())}',
                    style: const TextStyle(fontSize: 12, color: AppColors.slate500),
                  ),
                ],
              ),
            ),
            if (req.status == DocumentRequestStatus.approved)
              IconButton(
                icon: const Icon(Icons.download_rounded, color: AppColors.blue600),
                onPressed: () async {
                  final pdfData = await PdfGeneratorService.generateCertificatePdf(
                    certificateNo: req.certificateNo ?? 'PENDING',
                    date: req.approvedAt ?? DateTime.now(),
                    recipientName: req.userName,
                    organisation: req.organisation ?? 'Jayashree Foundation',
                    internshipArea: req.internshipArea ?? 'Social Welfare & Community Development',
                    internshipDuration: req.internshipDuration ?? '',
                  );
                  await Printing.layoutPdf(onLayout: (format) => pdfData);
                },
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: req.status == DocumentRequestStatus.pending ? AppColors.amber100 : AppColors.red100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  req.status.name.toUpperCase(),
                  style: TextStyle(
                    color: req.status == DocumentRequestStatus.pending ? Colors.amber[700] : Colors.red[700],
                    fontSize: 10,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}