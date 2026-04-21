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

class DocumentationTab extends ConsumerStatefulWidget {
  const DocumentationTab({super.key});

  @override
  ConsumerState<DocumentationTab> createState() => _DocumentationTabState();
}

class _DocumentationTabState extends ConsumerState<DocumentationTab> {
  String _searchQuery = '';
  bool _isActionInProgress = false;

  @override
  Widget build(BuildContext context) {
    final docsAsync = ref.watch(documentStorageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = ref.watch(currentUserProvider);

    return Stack(
      children: [
        docsAsync.when(
          skipLoadingOnRefresh: true,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (allDocs) {
            // Apply search filter
            final docs = allDocs.where((d) {
              if (_searchQuery.isEmpty) return true;
              return d.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                     d.category.toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();

            final grouped = <String, List<DocumentEntity>>{};
            for (var d in docs) {
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
                    title: 'Documentation Storage',
                    subtitle: 'Upload and access NGO policies, templates and reports',
                    actions: ElevatedButton.icon(
                      onPressed: () => _uploadNewDocument(context, ref, currentUser?.name ?? 'Admin'),
                      icon: const Icon(Icons.upload_file_rounded, size: 18),
                      label: const Text('Upload Document'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brand,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Search Bar ---
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.slate800 : AppColors.slate100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Search documents by name or category...',
                        hintStyle: TextStyle(color: isDark ? AppColors.slate500 : AppColors.slate400, fontSize: 13),
                        prefixIcon: Icon(Icons.search_rounded, color: isDark ? AppColors.slate500 : AppColors.slate400, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (docs.isEmpty && _searchQuery.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Column(
                        children: [
                          Icon(Icons.search_off_rounded, size: 48, color: isDark ? AppColors.slate600 : AppColors.slate300),
                          const SizedBox(height: 16),
                          Text(
                            'No documents match your search',
                            style: TextStyle(color: isDark ? AppColors.slate400 : AppColors.slate500, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  else if (docs.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 60),
                        child: Column(
                          children: [
                            Icon(Icons.folder_open_rounded, size: 56, color: isDark ? AppColors.slate600 : AppColors.slate300),
                            const SizedBox(height: 16),
                            Text(
                              'No documents yet',
                              style: TextStyle(color: isDark ? AppColors.slate400 : AppColors.slate500, fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Click "Upload Document" to add your first document',
                              style: TextStyle(color: isDark ? AppColors.slate500 : AppColors.slate400, fontSize: 13),
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
                            onRename: () => _showRenameDialog(context, ref, doc),
                            onReplace: () => _replaceDocument(context, ref, doc, currentUser?.name ?? 'Admin'),
                            onDelete: () => _confirmDelete(context, ref, doc),
                          )),
                          const SizedBox(height: 8),
                        ],
                      );
                    }),
            ],
          ),
        );
      },
    ),
    if (_isActionInProgress)
      Container(
        color: Colors.black26,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.brand),
        ),
      ),
  ],
);
}

  Future<void> _uploadNewDocument(BuildContext context, WidgetRef ref, String uploadedBy) async {
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

  Future<void> _replaceDocument(BuildContext context, WidgetRef ref, DocumentEntity doc, String uploadedBy) async {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      const SnackBar(content: Row(children: [
        SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
        SizedBox(width: 12),
        Text('Replacing document...'),
      ])),
    );
    try {
      await ref.read(documentStorageRepoProvider).replaceDocument(existing: doc, uploadedBy: uploadedBy);
      scaffold.hideCurrentSnackBar();
      scaffold.showSnackBar(
        const SnackBar(content: Text('Document replaced successfully'), backgroundColor: AppColors.brand),
      );
    } catch (e) {
      scaffold.hideCurrentSnackBar();
      scaffold.showSnackBar(SnackBar(content: Text('Replace failed: $e'), backgroundColor: AppColors.red500));
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, DocumentEntity doc) {
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
              setState(() => _isActionInProgress = true);
              try {
                await ref.read(documentStorageRepoProvider).deleteDocument(doc);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Document deleted'), backgroundColor: AppColors.red600),
                  );
                }
              } finally {
                if (mounted) setState(() => _isActionInProgress = false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red600, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, DocumentEntity doc) {
    final ctrl = TextEditingController(text: doc.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter a new name for this document:', style: TextStyle(fontSize: 13, color: AppColors.slate500)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Document Title',
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark ? AppColors.slate800 : AppColors.slate50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newTitle = ctrl.text.trim();
              if (newTitle.isEmpty || newTitle == doc.title) {
                Navigator.pop(ctx);
                return;
              }
              Navigator.pop(ctx);
              setState(() => _isActionInProgress = true);
              try {
                await ref.read(documentStorageRepoProvider).updateTitle(doc.id, newTitle);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('✅ Renamed to "$newTitle"'), backgroundColor: AppColors.brand),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rename failed: $e'), backgroundColor: AppColors.red500));
                }
              } finally {
                if (mounted) setState(() => _isActionInProgress = false);
              }
            },
            child: const Text('Rename'),
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
  final dynamic repo;
  final VoidCallback onSuccess;

  @override
  State<_RenameUploadDialog> createState() => _RenameUploadDialogState();
}

class _RenameUploadDialogState extends State<_RenameUploadDialog> {
  late final TextEditingController _nameCtrl;
  bool _uploading = false;
  double _progress = 0.0;
  String? _error;

  @override
  void initState() {
    super.initState();
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
    setState(() { _uploading = true; _progress = 0.0; _error = null; });
    try {
      await widget.repo.uploadFile(
        file: widget.pickedFile,
        customTitle: title,
        uploadedBy: widget.uploadedBy,
        onProgress: (p) => { if (mounted) setState(() => _progress = p) },
      );
      widget.onSuccess();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() { _uploading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ext = widget.pickedFile.extension?.toUpperCase() ?? 'FILE';
    final size = _formatBytes(widget.pickedFile.size);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Name your document', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate800 : AppColors.slate50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? AppColors.slate700 : AppColors.slate200),
            ),
            child: Row(
              children: [
                Icon(Icons.insert_drive_file_rounded, size: 18, color: isDark ? AppColors.slate300 : AppColors.slate500),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.pickedFile.name,
                    style: TextStyle(fontSize: 12, color: isDark ? AppColors.slate300 : AppColors.slate600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text('$ext • $size', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppColors.slate400 : AppColors.slate500)),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
          if (_uploading) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _progress < 1.0 ? 'Uploading to Firebase Storage… ${(_progress * 100).toStringAsFixed(0)}%' : 'Saving to database…',
                        style: TextStyle(fontSize: 13, color: isDark ? AppColors.slate300 : AppColors.slate600),
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: _progress > 0 ? _progress : null,
                        backgroundColor: isDark ? AppColors.slate700 : AppColors.slate200,
                        color: AppColors.brand,
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: _uploading ? null : () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton.icon(
          onPressed: _uploading ? null : _doUpload,
          icon: _uploading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.cloud_upload_rounded, size: 18),
          label: Text(_uploading ? 'Uploading…' : 'Upload'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.brand, foregroundColor: Colors.white),
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

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.doc,
    required this.isDark,
    required this.onRename,
    required this.onReplace,
    required this.onDelete,
  });

  final DocumentEntity doc;
  final bool isDark;
  final VoidCallback onRename;
  final VoidCallback onReplace;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final iconColor = switch (doc.fileType) {
      DocumentFileType.pdf  => AppColors.red500,
      DocumentFileType.doc  => AppColors.blue500,
      DocumentFileType.xlsx => AppColors.emerald500,
      _                     => AppColors.slate500,
    };

    Future<void> _handleDownload() async {
      if (doc.downloadUrl != null && doc.downloadUrl!.isNotEmpty) {
        final uri = Uri.parse(doc.downloadUrl!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open document link')),
            );
          }
        }
        return;
      }

      // Fallback for docs without URL (mostly generated ones or old mocks)
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
        onTap: _handleDownload,
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
            // Action Buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Download (Primary Action)
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
                
                // More Actions Menu
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, color: isDark ? AppColors.slate400 : AppColors.slate500),
                  onSelected: (value) {
                    switch (value) {
                      case 'rename': onRename(); break;
                      case 'replace': onReplace(); break;
                      case 'delete': onDelete(); break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'rename',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20),
                          SizedBox(width: 12),
                          Text('Rename'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'replace',
                      child: Row(
                        children: [
                          Icon(Icons.swap_horiz_rounded, size: 20),
                          SizedBox(width: 12),
                          Text('Replace'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.red500),
                          const SizedBox(width: 12),
                          const Text('Delete', style: TextStyle(color: AppColors.red500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _fileIcon(DocumentFileType type) {
    return switch (type) {
      DocumentFileType.pdf  => Icons.picture_as_pdf_rounded,
      DocumentFileType.xlsx => Icons.table_view_rounded,
      _                     => Icons.description_rounded,
    };
  }
}