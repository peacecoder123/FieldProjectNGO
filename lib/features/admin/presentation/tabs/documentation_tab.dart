import 'package:file_picker/file_picker.dart';
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
import 'package:url_launcher/url_launcher.dart' hide launch;
import 'package:ngo_volunteer_management/features/documents/services/pdf_generator_service.dart';
import 'package:ngo_volunteer_management/services/download_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Main tab – now a StatefulWidget so we can hold the search query locally
// ─────────────────────────────────────────────────────────────────────────────
class DocumentationTab extends ConsumerStatefulWidget {
  const DocumentationTab({super.key});

  @override
  ConsumerState<DocumentationTab> createState() => _DocumentationTabState();
}

class _DocumentationTabState extends ConsumerState<DocumentationTab> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final docsAsync = ref.watch(documentStorageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = ref.watch(currentUserProvider);

    return docsAsync.when(
      skipLoadingOnRefresh: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (docs) {
        // ── apply search filter ──────────────────────────────────────────────
        final filtered = _query.isEmpty
            ? docs
            : docs.where((d) => d.title.toLowerCase().contains(_query)).toList();

        final grouped = <String, List<DocumentEntity>>{};
        for (var d in filtered) {
          grouped.putIfAbsent(d.category, () => []).add(d);
        }

        return RefreshIndicator(
          onRefresh: () => ref.refresh(documentStorageProvider.future),
          child: ListView(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              SectionHeader(
                subtitle: 'Upload and access NGO policies, templates and reports',
                actions: ElevatedButton.icon(
                  onPressed: () => _startUploadFlow(context, currentUser?.name ?? 'Admin'),
                  icon: const Icon(Icons.upload_file_rounded, size: 18),
                  label: const Text('Upload Document'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brand,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Search bar ──────────────────────────────────────────────────
              TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Search documents by name…',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () => _searchCtrl.clear(),
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? AppColors.slate800 : AppColors.slate50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                ),
              ),
              const SizedBox(height: 20),

              // ── Document list ───────────────────────────────────────────────
              if (filtered.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Column(
                      children: [
                        Icon(
                          _query.isNotEmpty ? Icons.search_off_rounded : Icons.folder_open_rounded,
                          size: 56,
                          color: isDark ? AppColors.slate600 : AppColors.slate300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _query.isNotEmpty ? 'No results for "$_query"' : 'No documents yet',
                          style: TextStyle(
                            color: isDark ? AppColors.slate400 : AppColors.slate500,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_query.isEmpty)
                          Text(
                            'Click "Upload Document" to add your first document',
                            style: TextStyle(
                              color: isDark ? AppColors.slate500 : AppColors.slate400,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                )
              else
                ...grouped.keys.map((category) {
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
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDark ? AppColors.slate200 : AppColors.slate700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.slate700 : AppColors.slate100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${categoryDocs.length}',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...categoryDocs.map((doc) => _DocumentCard(
                            doc: doc,
                            isDark: isDark,
                            onReplace: () => _replaceDocument(context, doc, currentUser?.name ?? 'Admin'),
                            onDelete: () => _confirmDelete(context, doc),
                          )),
                      const SizedBox(height: 8),
                    ],
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  // ── Upload flow: pick → rename popup → upload with loader ──────────────────
  Future<void> _startUploadFlow(BuildContext context, String uploadedBy) async {
    // Step 1: pick file (no upload yet)
    final repo = ref.read(documentStorageRepoProvider);
    PlatformFile? pickedFile;
    try {
      pickedFile = await repo.pickFile();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open file picker: $e'), backgroundColor: AppColors.red500),
        );
      }
      return;
    }

    if (pickedFile == null || !context.mounted) return;

    // Step 2: show rename + confirm dialog
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _RenameUploadDialog(
        pickedFile: pickedFile!,
        uploadedBy: uploadedBy,
        repo: repo,
        onSuccess: () => ref.invalidate(documentStorageProvider),
      ),
    );
  }

  Future<void> _replaceDocument(BuildContext context, DocumentEntity doc, String uploadedBy) async {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      const SnackBar(
        content: Row(children: [
          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
          SizedBox(width: 12),
          Text('Replacing document…'),
        ]),
      ),
    );
    try {
      await ref.read(documentStorageRepoProvider).replaceDocument(existing: doc, uploadedBy: uploadedBy);
      ref.invalidate(documentStorageProvider);
      scaffold.hideCurrentSnackBar();
      scaffold.showSnackBar(
        const SnackBar(content: Text('Document replaced successfully'), backgroundColor: AppColors.brand),
      );
    } catch (e) {
      scaffold.hideCurrentSnackBar();
      scaffold.showSnackBar(SnackBar(content: Text('Replace failed: $e'), backgroundColor: AppColors.red500));
    }
  }

  void _confirmDelete(BuildContext context, DocumentEntity doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document?'),
        content: Text('Are you sure you want to delete "${doc.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(documentStorageRepoProvider).deleteDocument(doc);
                ref.invalidate(documentStorageProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Document deleted'), backgroundColor: AppColors.red600),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Delete failed: $e'), backgroundColor: AppColors.red500),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red600, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rename + upload dialog with live upload progress loader
// ─────────────────────────────────────────────────────────────────────────────
class _RenameUploadDialog extends StatefulWidget {
  const _RenameUploadDialog({
    required this.pickedFile,
    required this.uploadedBy,
    required this.repo,
    required this.onSuccess,
  });

  final PlatformFile pickedFile;
  final String uploadedBy;
  final dynamic repo; // FirebaseDocumentStorageRepository
  final VoidCallback onSuccess;

  @override
  State<_RenameUploadDialog> createState() => _RenameUploadDialogState();
}

class _RenameUploadDialogState extends State<_RenameUploadDialog> {
  late final TextEditingController _nameCtrl;
  bool _uploading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Pre-fill with original file name (without extension)
    final originalName = widget.pickedFile.name;
    final dotIdx = originalName.lastIndexOf('.');
    _nameCtrl = TextEditingController(
      text: dotIdx > 0 ? originalName.substring(0, dotIdx) : originalName,
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _doUpload() async {
    final title = _nameCtrl.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Please enter a document name');
      return;
    }

    setState(() {
      _uploading = true;
      _error = null;
    });

    try {
      await widget.repo.uploadFile(
        file: widget.pickedFile,
        customTitle: title,
        uploadedBy: widget.uploadedBy,
      );
      widget.onSuccess();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ "$title" uploaded successfully'),
            backgroundColor: AppColors.brand,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _uploading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ext = widget.pickedFile.extension?.toUpperCase() ?? 'FILE';
    final size = _formatBytes(widget.pickedFile.size);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.brand.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.drive_file_rename_outline_rounded, color: AppColors.brand, size: 20),
          ),
          const SizedBox(width: 12),
          const Text('Name your document', style: TextStyle(fontSize: 16)),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File info pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.slate700 : AppColors.slate100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.insert_drive_file_rounded,
                      size: 18,
                      color: isDark ? AppColors.slate300 : AppColors.slate500),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.pickedFile.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.slate300 : AppColors.slate600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$ext • $size',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.slate400 : AppColors.slate500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Name field
            TextField(
              controller: _nameCtrl,
              enabled: !_uploading,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Document Name',
                hintText: 'e.g. Annual Report 2026',
                errorText: _error,
                prefixIcon: const Icon(Icons.label_outline_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onSubmitted: (_) => _uploading ? null : _doUpload(),
            ),

            // Upload progress
            if (_uploading) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Uploading to Firebase Storage…',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.slate300 : AppColors.slate600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _uploading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _uploading ? null : _doUpload,
          icon: _uploading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.cloud_upload_rounded, size: 18),
          label: Text(_uploading ? 'Uploading…' : 'Upload'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brand,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Document card
// ─────────────────────────────────────────────────────────────────────────────
class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.doc,
    required this.isDark,
    required this.onReplace,
    required this.onDelete,
  });

  final DocumentEntity doc;
  final bool isDark;
  final VoidCallback onReplace;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final iconColor = switch (doc.fileType) {
      DocumentFileType.pdf => AppColors.red500,
      DocumentFileType.doc => AppColors.blue500,
      DocumentFileType.xlsx => AppColors.emerald500,
      _ => AppColors.slate500,
    };

    Future<void> handleDownload() async {
      final pdfData = await PdfGeneratorService.generateGenericDocumentPdf(
        title: doc.title,
        category: doc.category,
        date: AppFormatters.displayDate(doc.uploadDate),
      );
      DownloadService.downloadBytes(
        pdfData,
        '${doc.title.replaceAll(' ', '_')}.pdf',
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: handleDownload,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_fileIcon(doc.fileType), color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isDark ? AppColors.white : AppColors.slate900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${doc.fileType.displayLabel} • ${doc.size} • ${AppFormatters.displayDate(doc.uploadDate)}',
                    style: TextStyle(color: isDark ? AppColors.slate400 : AppColors.slate500, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (doc.downloadUrl != null)
              IconButton(
                icon: const Icon(Icons.download_for_offline_rounded, color: AppColors.blue500),
                tooltip: 'Download',
                onPressed: () async {
                  final uri = Uri.parse(doc.downloadUrl!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
            IconButton(
              icon: Icon(Icons.swap_horiz_rounded, color: isDark ? AppColors.slate400 : AppColors.slate500),
              tooltip: 'Replace',
              onPressed: onReplace,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.red500),
              tooltip: 'Delete',
              onPressed: onDelete,
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