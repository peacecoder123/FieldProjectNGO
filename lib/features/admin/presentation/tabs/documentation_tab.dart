import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/core/widgets/app_card.dart';
import 'package:ngo_volunteer_management/core/widgets/section_header.dart';
import 'package:ngo_volunteer_management/shared/data/entities.dart';
import 'package:ngo_volunteer_management/shared/providers/feature_providers.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';

class DocumentationTab extends ConsumerWidget {
  const DocumentationTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(documentProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        SectionHeader(
          title: 'Documentation',
          subtitle: 'Access NGO policies, templates and reports',
          actions: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {}, // For future upload functionality
                icon: const Icon(Icons.upload_file_rounded, color: AppColors.blue600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: docsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (docs) {
              final grouped = <String, List<DocumentEntity>>{};
              for (var d in docs) {
                grouped.putIfAbsent(d.category, () => []).add(d);
              }

              return ListView.builder(
                itemCount: grouped.length,
                itemBuilder: (context, index) {
                  final category = grouped.keys.elementAt(index);
                  final categoryDocs = grouped[category]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Text(
                              category,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.slate700),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: AppColors.slate100, borderRadius: BorderRadius.circular(12)),
                              child: Text('${categoryDocs.length}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      ...categoryDocs.map((doc) => _DocumentCard(doc: doc, isDark: isDark)),
                      const SizedBox(height: 8),
                    ],
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

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.doc, required this.isDark});
  final DocumentEntity doc;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final iconColor = switch (doc.fileType) {
      DocumentFileType.pdf => AppColors.red500,
      DocumentFileType.doc => AppColors.blue500,
      DocumentFileType.xlsx => AppColors.emerald500,
      _ => AppColors.slate500,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening ${doc.title}... (Download simulated)')),
          );
        },
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _fileIcon(doc.fileType),
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doc.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(
                    '${doc.fileType.displayLabel} • ${doc.size} • Uploaded ${AppFormatters.displayDate(doc.uploadDate)}',
                    style: const TextStyle(color: AppColors.slate500, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.download_for_offline_rounded, color: AppColors.slate400),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  IconData _fileIcon(DocumentFileType type) {
    return switch (type) {
      DocumentFileType.pdf => Icons.picture_as_pdf_rounded,
      DocumentFileType.xlsx => Icons.table_view_rounded,
      _ => Icons.description_rounded,
    };
  }
}