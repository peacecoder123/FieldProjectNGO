import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/core/widgets/app_card.dart';
import 'package:ngo_volunteer_management/core/widgets/section_header.dart';
import 'package:ngo_volunteer_management/shared/providers/feature_providers.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';
import 'package:ngo_volunteer_management/domain/entities/document_request.entity.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/shared/providers/app_providers.dart';
import 'package:ngo_volunteer_management/features/documents/services/pdf_generator_service.dart';
import 'package:printing/printing.dart';

class MemberCertificateTab extends ConsumerWidget {
  const MemberCertificateTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(documentRequestProvider);

    return requestsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (requests) {
        final myReqs = requests.where((l) => true).toList(); // Show all for demo
        
        return ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            SectionHeader(
              title: 'Certificates & Requests',
              subtitle: 'Request and download your official NGO documentation',
              actions: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
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
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            if (myReqs.isEmpty)
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
            else
              ...myReqs.map((req) => _DocumentRequestCard(req: req)),
          ],
        );
      },
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
              decoration: BoxDecoration(color: AppColors.blue50, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.verified_rounded, color: AppColors.blue600),
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