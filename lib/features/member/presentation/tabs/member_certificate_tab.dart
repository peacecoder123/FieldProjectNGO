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

    return Column(
      children: [
        const SectionHeader(
          title: 'Certificates & Letters',
          subtitle: 'Download your official NGO documentation',
        ),
        const SizedBox(height: 16),
        Expanded(
          child: lettersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (letters) {
              final myApproved = letters.where((l) => l.status.name == 'approved').toList();

              if (myApproved.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.badge_rounded, size: 64, color: AppColors.slate200),
                      SizedBox(height: 16),
                      Text('No approved certificates yet', style: TextStyle(color: AppColors.slate500)),
                    ],
                  ),
                );
              }

              return ListView.separated(
                itemCount: myApproved.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final letter = myApproved[index];
                  return AppCard(
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
                              const SnackBar(content: Text('Downloading Certificate...')),
                            );
                          },
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