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

class VolunteerCertificateTab extends ConsumerWidget {
  const VolunteerCertificateTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lettersAsync = ref.watch(joiningLetterProvider);
    final currentUser = ref.watch(currentUserProvider);

    return lettersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (letters) {
        final approved = letters
            .where((l) => l.name == currentUser?.name && l.status == RequestStatus.approved)
            .toList()
          ..sort((a, b) => b.requestDate.compareTo(a.requestDate));

        if (approved.isEmpty) {
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
          shrinkWrap: true, // Fixes unbounded height crash
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          itemCount: approved.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return const _CertificateHeader();
            }
            final cert = approved[index - 1];
            return _CertificateRow(certificate: cert);
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

class _CertificateRow extends StatelessWidget {
  const _CertificateRow({required this.certificate});

  final JoiningLetterRequestEntity certificate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textSecondary = isDark ? AppColors.slate400 : AppColors.slate500;
    final iconColor = AppColors.blue600;

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
                  certificate.type.displayLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Issued: ${AppFormatters.displayDate(certificate.requestDate)}',
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
              icon: Icon(Icons.download_rounded, color: iconColor),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Certificate downloaded!'),
                    backgroundColor: AppColors.emerald500,
                  ),
                );
              },
              style: IconButton.styleFrom(padding: EdgeInsets.zero),
            ),
          ),
        ],
      ),
    );
  }
}