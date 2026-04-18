import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/core/widgets/app_card.dart';
import 'package:ngo_volunteer_management/core/widgets/section_header.dart';
import 'package:ngo_volunteer_management/shared/data/entities.dart';
import 'package:ngo_volunteer_management/shared/providers/app_providers.dart';
import 'package:ngo_volunteer_management/shared/providers/feature_providers.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';
import 'package:ngo_volunteer_management/domain/entities/document_request.entity.dart';
import 'package:printing/printing.dart';
import 'package:ngo_volunteer_management/features/documents/services/pdf_generator_service.dart';

class VolunteerCertificateTab extends ConsumerWidget {
  const VolunteerCertificateTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lettersAsync  = ref.watch(joiningLetterProvider);
    final documentAsync = ref.watch(documentRequestProvider);
    final currentUser   = ref.watch(currentUserProvider);

    return lettersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (letters) {
        return documentAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (docs) {
            final approvedLetters = letters
                .where((l) => l.name == currentUser?.name && l.status == RequestStatus.approved)
                .toList();

            final approvedDocs = docs
                .where((d) => d.userId == currentUser?.id.toString() && d.status == DocumentRequestStatus.approved)
                .toList();

            final allApproved = [
              ...approvedLetters.map((l) => _CertItem.letter(l)),
              ...approvedDocs.map((d) => _CertItem.doc(d)),
            ]..sort((a, b) => b.date.compareTo(a.date));

            if (allApproved.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Prevents full-screen stretch issues
              children: [
                SectionHeader(
                  title: 'Certificates',
                  subtitle: 'Download your approved joining letters and certificates',
                ),
                SizedBox(height: 48),
                Center(
                  child: Text(
                    'No certificates available yet',
                    style: TextStyle(color: AppColors.slate500),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          itemCount: allApproved.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return const _CertificateHeader();
            }
            final item = allApproved[index - 1];
            return _CertificateRow(item: item);
          },
        );
      },
    );
  },
);
  }
}

class _CertificateHeader extends StatelessWidget {
  const _CertificateHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Certificates',
          subtitle: 'Download your approved joining letters and certificates',
        ),
        SizedBox(height: 16),
      ],
    );
  }
}

class _CertItem {
  final String title;
  final String date;
  final String typeLabel;
  final dynamic original;
  final bool isLetter;

  _CertItem.letter(JoiningLetterRequestEntity l)
      : title = 'Joining Letter – ${l.tenure}',
        date = l.requestDate,
        typeLabel = l.type.displayLabel,
        original = l,
        isLetter = true;

  _CertItem.doc(DocumentRequestEntity d)
      : title = d.documentType.displayLabel,
        date = MyDateUtils.formatIso(d.requestedAt.toIso8601String()), // Helper for sorting
        typeLabel = d.documentType.displayLabel,
        original = d,
        isLetter = false;
}

class MyDateUtils {
  static String formatIso(String iso) => iso.split('T')[0];
}

class _CertificateRow extends StatelessWidget {
  const _CertificateRow({required this.item});

  final _CertItem item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.slate400 : AppColors.slate500;

    return AppCard(
      elevation: 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Issued: ${AppFormatters.displayDate(item.date)}',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: IconButton(
              icon: const Icon(Icons.download_rounded, color: AppColors.blue600),
              onPressed: () async {
                if (item.isLetter) {
                  final l = item.original as JoiningLetterRequestEntity;
                  final pdfBytes = await PdfGeneratorService.generateJoiningLetterPdf(
                    name: l.name,
                    tenure: l.tenure,
                    requestDate: AppFormatters.displayDate(l.requestDate),
                    approvedBy: l.generatedBy,
                  );
                  await Printing.sharePdf(
                    bytes: pdfBytes,
                    filename: 'Joining_Letter_${l.tenure.replaceAll(' ', '_')}.pdf',
                  );
                } else {
                  final d = item.original as DocumentRequestEntity;
                  final pdfData = await PdfGeneratorService.generateCertificatePdf(
                    certificateNo: d.certificateNo ?? 'PENDING',
                    date: d.approvedAt ?? DateTime.now(),
                    recipientName: d.userName,
                  );
                  await Printing.layoutPdf(onLayout: (format) => pdfData);
                }
              },
              style: IconButton.styleFrom(padding: EdgeInsets.zero),
            ),
          ),
        ],
      ),
    );
  }
}