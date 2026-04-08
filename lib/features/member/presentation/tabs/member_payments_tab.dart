import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/core/widgets/app_card.dart';
import 'package:ngo_volunteer_management/core/widgets/section_header.dart';
import 'package:ngo_volunteer_management/shared/providers/app_providers.dart';
import 'package:ngo_volunteer_management/shared/providers/feature_providers.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';
import 'package:ngo_volunteer_management/features/documents/services/pdf_generator_service.dart';
import 'package:printing/printing.dart';

class MemberPaymentsTab extends ConsumerWidget {
  const MemberPaymentsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donationsAsync = ref.watch(donationProvider);
    final currentUser = ref.watch(currentUserProvider);

    return donationsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (donations) {
        final myPayments = donations.where((d) => d.donorName == currentUser?.name).toList();

        return ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            const SectionHeader(
              title: 'My Payments',
              subtitle: 'History of membership fees and donations',
            ),
            const SizedBox(height: 24),
            
            if (myPayments.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_rounded, size: 64, color: AppColors.slate200),
                      SizedBox(height: 16),
                      Text('No payment history found', style: TextStyle(color: AppColors.slate500)),
                    ],
                  ),
                ),
              )
            else
              ...myPayments.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.payment_rounded, color: AppColors.slate600),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.purpose, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text(AppFormatters.displayDate(p.date), style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            AppFormatters.inr(p.amount),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.emerald600),
                          ),
                          if (p.receiptGenerated) ...[
                            const SizedBox(height: 4),
                            TextButton.icon(
                              onPressed: () async {
                                final parsedDate = DateTime.parse(p.date);
                                final pdfData = await PdfGeneratorService.generateReceiptPdf(
                                  receiptNo: 'REC-${parsedDate.year}-${p.id}',
                                  date: parsedDate,
                                  donorName: p.donorName,
                                  amount: p.amount.toDouble(),
                                  amountWords: 'Rupees ${p.amount} only',
                                  paymentMode: p.type.name.toUpperCase(),
                                  purpose: p.purpose,
                                );
                                await Printing.layoutPdf(onLayout: (format) => pdfData);
                              },
                              icon: const Icon(Icons.download_rounded, size: 14),
                              label: const Text('Receipt', style: TextStyle(fontSize: 12)),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.blue600,
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ]
                        ],
                      ),
                    ],
                  ),
                ),
              )),
          ],
        );
      },
    );
  }
}