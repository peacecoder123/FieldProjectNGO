import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/core/widgets/app_card.dart';
import 'package:ngo_volunteer_management/core/widgets/section_header.dart';
import 'package:ngo_volunteer_management/shared/providers/app_providers.dart';
import 'package:ngo_volunteer_management/shared/providers/feature_providers.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';

class MemberPaymentsTab extends ConsumerWidget {
  const MemberPaymentsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donationsAsync = ref.watch(donationProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Column(
      children: [
        const SectionHeader(
          title: 'My Payments',
          subtitle: 'History of membership fees and donations',
        ),
        const SizedBox(height: 16),
        Expanded(
          child: donationsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (donations) {
              // In this mock, we'll assume "donations" contains all payments
              final myPayments = donations.where((d) => d.donorName == currentUser?.name).toList();

              if (myPayments.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_rounded, size: 64, color: AppColors.slate200),
                      SizedBox(height: 16),
                      Text('No payment history found', style: TextStyle(color: AppColors.slate500)),
                    ],
                  ),
                );
              }

              return ListView.separated(
                itemCount: myPayments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final p = myPayments[index];
                  return AppCard(
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
                            if (p.receiptGenerated)
                              const Text('Receipt Available', style: TextStyle(fontSize: 10, color: AppColors.blue600, fontWeight: FontWeight.bold)),
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