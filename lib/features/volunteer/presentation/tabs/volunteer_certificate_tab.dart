import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/core/widgets/app_card.dart';
import 'package:ngo_volunteer_management/core/widgets/section_header.dart';
import 'package:ngo_volunteer_management/shared/providers/app_providers.dart';
import 'package:ngo_volunteer_management/shared/providers/feature_providers.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';

class VolunteerCertificateTab extends ConsumerWidget {
  const VolunteerCertificateTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lettersAsync = ref.watch(joiningLetterProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Column(
      children: [
        const SectionHeader(
          title: 'Certificates',
          subtitle: 'Download your approved joining letters and certificates',
        ),
        const SizedBox(height: 16),
        Expanded(
          child: lettersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
            data: (letters) {
              final approved = letters.where((l) => l.name == currentUser?.name && l.status == RequestStatus.approved).toList();
              if (approved.isEmpty) return const Center(child: Text('No certificates available yet'));

              return ListView.separated(
                itemCount: approved.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final l = approved[index];
                  return AppCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.type.displayLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('Issued: ${AppFormatters.displayDate(l.requestDate)}', style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
                          ],
                        ),
                        IconButton(onPressed: () {}, icon: const Icon(Icons.download_rounded, color: AppColors.blue600)),
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