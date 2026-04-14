import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/core/widgets/app_card.dart';
import 'package:ngo_volunteer_management/core/widgets/section_header.dart';
import 'package:ngo_volunteer_management/domain/entities/document_request.entity.dart';
import 'package:ngo_volunteer_management/shared/providers/feature_providers.dart';
import 'package:ngo_volunteer_management/shared/providers/app_providers.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';
import 'package:ngo_volunteer_management/features/documents/services/pdf_generator_service.dart';
import 'package:printing/printing.dart';

class DocumentApprovalsList extends ConsumerWidget {
  const DocumentApprovalsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(documentRequestProvider);
    final currentUser = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return requestsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (requests) {
        final pending = requests.where((r) => r.status == DocumentRequestStatus.pending).toList();
        final past = requests.where((r) => r.status != DocumentRequestStatus.pending).toList();

        if (requests.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Text('No certificate requests', style: TextStyle(color: isDark ? AppColors.slate400 : AppColors.slate500)),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pending.isNotEmpty) ...[
              const Text('Pending Approvals', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.slate700)),
              const SizedBox(height: 12),
              ...pending.map((req) => _RequestCard(req: req, isDark: isDark, currentUser: currentUser)),
              const SizedBox(height: 24),
            ],
            
            const Text('Past Requests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.slate700)),
            const SizedBox(height: 12),
            if (past.isEmpty) const Text('No past requests.', style: TextStyle(color: AppColors.slate500)),
            ...past.map((req) => _RequestCard(req: req, isDark: isDark, currentUser: currentUser)),
          ],
        );
      },
    );
  }
}

class _RequestCard extends ConsumerWidget {
  const _RequestCard({required this.req, required this.isDark, required this.currentUser});
  
  final DocumentRequestEntity req;
  final bool isDark;
  final dynamic currentUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color statusColor;
    IconData statusIcon;
    
    switch (req.status) {
      case DocumentRequestStatus.pending:
        statusColor = AppColors.amber500;
        statusIcon = Icons.pending_actions_rounded;
        break;
      case DocumentRequestStatus.approved:
        statusColor = AppColors.emerald500;
        statusIcon = Icons.check_circle_rounded;
        break;
      case DocumentRequestStatus.rejected:
        statusColor = AppColors.red500;
        statusIcon = Icons.cancel_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${req.documentType.displayLabel} Request', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(
                        'Requested by ${req.userName} • ${AppFormatters.displayDate(req.requestedAt.toIso8601String())}',
                        style: const TextStyle(color: AppColors.slate500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    req.status.name.toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            
            if (req.status == DocumentRequestStatus.pending && (currentUser?.role == UserRole.admin || currentUser?.role == UserRole.superAdmin)) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      ref.read(documentRequestProvider.notifier).reject(req.id);
                    },
                    style: TextButton.styleFrom(foregroundColor: AppColors.red600),
                    child: const Text('Reject'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      await ref.read(documentRequestProvider.notifier).approve(req.id, approvedBy: currentUser?.name ?? 'Admin');
                      // Wait briefly for firebase sync, then maybe present a message
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request Approved.')));
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.brand),
                    child: const Text('Approve & Generate'),
                  ),
                ],
              )
            ],
            
            if (req.status == DocumentRequestStatus.approved) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Cert No: ${req.certificateNo}', style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
                  TextButton.icon(
                    onPressed: () async {
                      final pdfData = await PdfGeneratorService.generateCertificatePdf(
                        certificateNo: req.certificateNo ?? 'PENDING',
                        date: req.approvedAt ?? DateTime.now(),
                        recipientName: req.userName,
                      );
                      await Printing.layoutPdf(onLayout: (format) => pdfData);
                    },
                    icon: const Icon(Icons.print_rounded, size: 16),
                    label: const Text('Print / Download'),
                  ),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }
}
