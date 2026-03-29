import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/core/widgets/app_card.dart';
import 'package:ngo_volunteer_management/core/widgets/section_header.dart';
import 'package:ngo_volunteer_management/shared/providers/feature_providers.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';

class MemberCertificateTab extends ConsumerWidget {
  const MemberCertificateTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lettersAsync = ref.watch(joiningLetterProvider);

    return lettersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (letters) {
        final myApproved = letters.where((l) => l.status.name == 'approved').toList();

        return ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            const SectionHeader(
              title: 'Certificates & Letters',
              subtitle: 'Download your official NGO documentation',
            ),
            const SizedBox(height: 24),
            
            if (myApproved.isEmpty)
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
              ...myApproved.map((letter) => Padding(
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
                            Text(letter.type.displayLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 4),
                            Text(
                              'Issued on ${AppFormatters.displayDate(letter.requestDate)}',
                              style: const TextStyle(fontSize: 12, color: AppColors.slate500),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.download_rounded, color: AppColors.blue600),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Downloading Certificate...'), backgroundColor: AppColors.emerald500,),
                          );
                        },
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