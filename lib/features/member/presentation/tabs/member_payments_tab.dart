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
import 'package:ngo_volunteer_management/shared/data/entities.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/domain/entities/donation.entity.dart';
import 'package:ngo_volunteer_management/services/payment/razorpay_config.dart';
import 'package:ngo_volunteer_management/shared/providers/payment_provider.dart';

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
        
        // Find current member entity to check if they've paid
        final memberState = ref.watch(memberProvider);
        final currentMember = memberState.value?.cast<MemberEntity?>().firstWhere(
            (m) => m?.id == currentUser?.id || m?.email == currentUser?.email,
            orElse: () => null);
            
        final isPaid = currentMember?.isPaid ?? true; // Default true so we don't show button if we can't find member
        final membershipType = currentMember?.membershipType ?? MembershipType.nonEightyG;
        final feeAmount = membershipType == MembershipType.eightyG 
                ? RazorpayConfig.membershipFee80G 
                : RazorpayConfig.membershipFeeNon80G;
                
        final paymentState = ref.watch(paymentStateProvider);

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
            
            // ── Unpaid Membership Banner Card ──
            if (!isPaid) Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.rose500.withOpacity(0.05),
                  border: Border.all(color: AppColors.rose500.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.rose500.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.warning_amber_rounded, color: AppColors.rose500, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Membership Fee Due', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.slate900)),
                              const SizedBox(height: 4),
                              Text('Please pay your annual membership fee to maintain active status.', style: TextStyle(fontSize: 13, color: Theme.of(context).brightness == Brightness.dark ? AppColors.slate400 : AppColors.slate600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${membershipType.displayLabel} Membership', style: TextStyle(fontSize: 12, color: Theme.of(context).brightness == Brightness.dark ? AppColors.slate400 : AppColors.slate500)),
                            Text(AppFormatters.inr(feeAmount), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.slate900)),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: paymentState.isProcessing ? null : () async {
                              if (currentUser == null || currentMember == null) return;
                              
                              final outcome = await ref.read(paymentStateProvider.notifier).processMembershipPayment(
                                amount: feeAmount,
                                memberName: currentUser.name,
                                email: currentUser.email,
                                phone: currentMember.phone,
                                membershipType: membershipType.displayLabel,
                              );
                              
                              if (!context.mounted) return;
                              
                              if (outcome.isSuccess) {
                                // Save to donations collection
                                final donation = DonationEntity(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                  donorName: currentUser.name,
                                  amount: feeAmount,
                                  date: AppFormatters.today(),
                                  type: DonationType.online,
                                  receiptGenerated: false,
                                  purpose: 'Membership Fee - ${membershipType.displayLabel}',
                                  is80G: membershipType == MembershipType.eightyG,
                                  razorpayPaymentId: outcome.paymentId,
                                  razorpayOrderId: outcome.orderId,
                                  paymentStatus: PaymentStatus.success,
                                  donorEmail: currentUser.email,
                                  donorPhone: currentMember.phone,
                                );
                                
                                await ref.read(donationProvider.notifier).add(donation);
                                
                                // Update member status to paid
                                final updatedMember = currentMember.copyWith(isPaid: true);
                                await ref.read(memberProvider.notifier).update(updatedMember);
                                
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment successful!')));
                                }
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(outcome.errorMessage ?? 'Payment failed.')));
                                }
                              }
                          },
                          icon: paymentState.isProcessing 
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.payment_rounded, size: 18),
                          label: Text(paymentState.isProcessing ? 'Processing...' : 'Pay Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.rose500,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
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
                            Row(
                              children: [
                                Text(AppFormatters.displayDate(p.date), style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
                                if (p.razorpayPaymentId != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: AppColors.emerald50, borderRadius: BorderRadius.circular(4), border: Border.all(color: AppColors.emerald200)),
                                    child: const Text('Online', style: TextStyle(fontSize: 9, color: AppColors.emerald700, fontWeight: FontWeight.bold)),
                                  ),
                                ]
                              ]
                            )
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
                          ] else if (p.paymentStatus == PaymentStatus.failed) ...[
                             const SizedBox(height: 4),
                             const Text('Failed', style: TextStyle(fontSize: 10, color: AppColors.rose600, fontWeight: FontWeight.bold)),
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