import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/core/widgets/app_badge.dart';
import 'package:ngo_volunteer_management/core/widgets/app_card.dart';
import 'package:ngo_volunteer_management/core/widgets/section_header.dart';
import 'package:ngo_volunteer_management/shared/data/entities.dart';
import 'package:ngo_volunteer_management/shared/providers/app_providers.dart';
import 'package:ngo_volunteer_management/shared/providers/feature_providers.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';
import 'package:ngo_volunteer_management/features/documents/services/pdf_generator_service.dart';
import 'package:ngo_volunteer_management/services/download_service.dart';

class JoiningLettersTab extends ConsumerStatefulWidget {
  const JoiningLettersTab({super.key});

  @override
  ConsumerState<JoiningLettersTab> createState() => _JoiningLettersTabState();
}

class _JoiningLettersTabState extends ConsumerState<JoiningLettersTab> {
  RequestStatus? _statusFilter = RequestStatus.pending;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final requestsAsync = ref.watch(joiningLetterProvider);

    return requestsAsync.when(
      skipLoadingOnRefresh: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error loading requests: $e')),
      data: (requests) {
        final filtered = requests
            .where((r) => _statusFilter == null || r.status == _statusFilter)
            .toList();

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(joiningLetterProvider);
            await Future.delayed(const Duration(milliseconds: 800));
          },
          child: ListView(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              SectionHeader(
              title: 'Joining Letters',
              subtitle: 'Review and approve requests for official joining letters',
              actions: ElevatedButton.icon(
                onPressed: () => _showGenerateCertificateModal(context),
                icon: const Icon(Icons.workspace_premium_rounded, size: 18),
                label: const Text('Generate Certificate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: const StadiumBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildFilters(isDark: isDark),
            const SizedBox(height: 24),

            if (filtered.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      Icon(Icons.file_present_rounded, size: 48, color: isDark ? AppColors.slate600 : AppColors.slate300),
                      const SizedBox(height: 12),
                      Text(
                        'No requests found',
                        style: TextStyle(color: isDark ? AppColors.slate400 : AppColors.slate500),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: filtered
                    .map((req) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _JoiningRequestCard(request: req),
                        ))
                    .toList(),
              ),
          ],
        ),
      );
    },
  );
}

  Widget _buildFilters({required bool isDark}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            isSelected: _statusFilter == null,
            isDark: isDark,
            onSelected: () => setState(() => _statusFilter = null),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Pending',
            isSelected: _statusFilter == RequestStatus.pending,
            isDark: isDark,
            onSelected: () => setState(() => _statusFilter = RequestStatus.pending),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Waiting Admin',
            isSelected: _statusFilter == RequestStatus.waitingAdmin,
            isDark: isDark,
            onSelected: () => setState(() => _statusFilter = RequestStatus.waitingAdmin),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Approved',
            isSelected: _statusFilter == RequestStatus.approved,
            isDark: isDark,
            onSelected: () => setState(() => _statusFilter = RequestStatus.approved),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Rejected',
            isSelected: _statusFilter == RequestStatus.rejected,
            isDark: isDark,
            onSelected: () => setState(() => _statusFilter = RequestStatus.rejected),
          ),
        ],
      ),
    );
  }

  void _showGenerateCertificateModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const _GenerateCertificateModal(),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.isSelected, required this.isDark, required this.onSelected});
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label, style: TextStyle(
        color: isSelected
          ? (isDark ? AppColors.white : AppColors.blue600)
          : (isDark ? AppColors.slate400 : AppColors.slate600),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      )),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: isDark ? AppColors.blue600.withValues(alpha: 0.2) : AppColors.blue100,
      backgroundColor: isDark ? AppColors.slate800 : AppColors.slate100,
      side: BorderSide(color: isSelected
        ? (isDark ? AppColors.blue500 : AppColors.blue600.withValues(alpha: 0.3))
        : Colors.transparent,
      ),
    );
  }
}

class _JoiningRequestCard extends ConsumerWidget {
  const _JoiningRequestCard({required this.request});
  final JoiningLetterRequestEntity request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = ref.watch(currentUserProvider);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.name, style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? AppColors.white : AppColors.slate900,
                    )),
                    const SizedBox(height: 2),
                    Text(
                      'Requested for ${request.type.displayLabel} on ${AppFormatters.displayDate(request.requestDate)}',
                      style: TextStyle(fontSize: 12, color: isDark ? AppColors.slate400 : AppColors.slate500),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: request.status),
            ],
          ),

          if (request.status == RequestStatus.pending || request.status == RequestStatus.waitingAdmin) ...[
            const SizedBox(height: 16),
            _TenureSelector(
              request: request,
              approverName: currentUser?.name ?? 'Admin',
            ),
          ] else if (request.status == RequestStatus.approved) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.emerald700.withValues(alpha: 0.2) : AppColors.emerald50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? AppColors.emerald600.withValues(alpha: 0.5) : AppColors.emerald200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_rounded, size: 16, color: AppColors.emerald400),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Approved by ${request.generatedBy} • Tenure: ${request.tenure}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.emerald200 : AppColors.emerald700,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final pdfData = await PdfGeneratorService.generateJoiningLetterPdf(
                        name: request.name,
                        tenure: request.tenure ?? '6 Months',
                        requestDate: AppFormatters.displayDate(request.requestDate),
                        approvedBy: request.generatedBy,
                      );
                      DownloadService.downloadBytes(
                        pdfData, 
                        'Joining_Letter_${request.name.replaceAll(' ', '_')}.pdf',
                      );
                    },
                    icon: const Icon(Icons.download_rounded, size: 14),
                    label: const Text('Download Letter', style: TextStyle(fontSize: 11)),
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? AppColors.emerald400 : AppColors.emerald700,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (request.status == RequestStatus.rejected) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.red.shade900.withValues(alpha: 0.2) : AppColors.red50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? Colors.red.shade700.withValues(alpha: 0.5) : AppColors.red100),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cancel_rounded, size: 16, color: AppColors.red500),
                  const SizedBox(width: 8),
                  Text(
                    'Rejected',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.red100 : AppColors.red600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Inline tenure selector + approve/reject (avoids "Approved By" text prompt)
class _TenureSelector extends ConsumerStatefulWidget {
  const _TenureSelector({required this.request, required this.approverName});
  final JoiningLetterRequestEntity request;
  final String approverName;

  @override
  ConsumerState<_TenureSelector> createState() => _TenureSelectorState();
}

class _TenureSelectorState extends ConsumerState<_TenureSelector> {
  String _tenure = '6 Months';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _tenure,
          decoration: InputDecoration(
            labelText: 'Tenure',
            filled: true,
            fillColor: isDark ? AppColors.slate800 : AppColors.slate50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          items: ['3 Months', '6 Months', '1 Year', 'Permanent']
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (val) => setState(() => _tenure = val!),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => ref.read(joiningLetterProvider.notifier).reject(widget.request.id),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? AppColors.red500 : AppColors.red600,
                ),
                child: const Text('Reject'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  ref.read(joiningLetterProvider.notifier).approve(
                    widget.request.id,
                    generatedBy: widget.approverName,
                    tenure: _tenure,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Approve'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final RequestStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      RequestStatus.pending      => AppColors.amber500,
      RequestStatus.waitingAdmin => AppColors.brand,
      RequestStatus.approved     => AppColors.emerald500,
      RequestStatus.rejected      => AppColors.red500,
    };
    return AppBadge(label: status.displayName.toUpperCase(), color: color);
  }
}

// ── Generate Certificate Modal ──────────────────────────────────────────────
class _GenerateCertificateModal extends StatefulWidget {
  const _GenerateCertificateModal();

  @override
  State<_GenerateCertificateModal> createState() => _GenerateCertificateModalState();
}

class _GenerateCertificateModalState extends State<_GenerateCertificateModal> {
  final _formKey = GlobalKey<FormState>();
  bool _isGenerating = false;

  final _refCtrl      = TextEditingController();
  final _nameCtrl     = TextEditingController();
  final _ngoCtrl      = TextEditingController(text: 'Jayashree Foundation');
  final _regCtrl      = TextEditingController(text: 'MAH/509/2021/THANE');
  DateTime _issueDate = DateTime.now();
  String _tenure      = '6 Months';

  @override
  void dispose() {
    _refCtrl.dispose();
    _nameCtrl.dispose();
    _ngoCtrl.dispose();
    _regCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isGenerating = true);

    try {
      final pdfData = await PdfGeneratorService.generateJoiningLetterPdf(
        name: _nameCtrl.text.trim(),
        tenure: _tenure,
        requestDate: '${_issueDate.day.toString().padLeft(2, '0')}/'
            '${_issueDate.month.toString().padLeft(2, '0')}/'
            '${_issueDate.year}',
        approvedBy: 'Admin',
      );

      DownloadService.downloadBytes(
        pdfData,
        'JoiningLetter_${_nameCtrl.text.trim().replaceAll(' ', '_')}.pdf',
      );

      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.slate800 : Colors.white;
    final borderColor  = isDark ? AppColors.slate700 : AppColors.slate200;

    return Dialog(
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Title ──
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.brand.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.workspace_premium_rounded, color: AppColors.brand, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Generate Joining Letter',
                            style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.white : AppColors.slate900,
                            )),
                          Text('Fill in the details to produce the PDF',
                            style: TextStyle(fontSize: 12, color: isDark ? AppColors.slate400 : AppColors.slate500)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: isDark ? AppColors.slate400 : AppColors.slate500),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Divider(color: borderColor, height: 1),
                const SizedBox(height: 20),

                // ── Fields ──
                _field(
                  controller: _nameCtrl,
                  label: 'Volunteer Name',
                  hint: 'e.g. Radhe Wankhade',
                  icon: Icons.person_rounded,
                  isDark: isDark,
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _field(
                        controller: _refCtrl,
                        label: 'Reference Number',
                        hint: 'e.g. JF/JL/2026/001',
                        icon: Icons.tag_rounded,
                        isDark: isDark,
                        required: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _issueDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) setState(() => _issueDate = picked);
                        },
                        child: InputDecorator(
                          decoration: _inputDecoration(
                            label: 'Issue Date',
                            icon: Icons.calendar_today_rounded,
                            isDark: isDark,
                          ),
                          child: Text(
                            '${_issueDate.day.toString().padLeft(2, '0')}/'
                            '${_issueDate.month.toString().padLeft(2, '0')}/'
                            '${_issueDate.year}',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.white : AppColors.slate900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Tenure dropdown
                DropdownButtonFormField<String>(
                  value: _tenure,
                  decoration: _inputDecoration(label: 'Tenure Duration', icon: Icons.schedule_rounded, isDark: isDark),
                  dropdownColor: isDark ? AppColors.slate800 : Colors.white,
                  items: ['1 Month', '3 Months', '6 Months', '1 Year', 'Permanent']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (val) => setState(() => _tenure = val!),
                ),
                const SizedBox(height: 14),

                _field(
                  controller: _ngoCtrl,
                  label: 'NGO Name',
                  hint: 'Jayashree Foundation',
                  icon: Icons.apartment_rounded,
                  isDark: isDark,
                ),
                const SizedBox(height: 14),

                _field(
                  controller: _regCtrl,
                  label: 'NGO Registration Number',
                  hint: 'e.g. MAH/509/2021/THANE',
                  icon: Icons.numbers_rounded,
                  isDark: isDark,
                ),

                const SizedBox(height: 24),

                // ── Generate Button ──
                ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generate,
                  icon: _isGenerating
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.download_rounded, size: 18),
                  label: Text(_isGenerating ? 'Generating…' : 'Generate & Download PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brand,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(fontSize: 14, color: isDark ? AppColors.white : AppColors.slate900),
      decoration: _inputDecoration(label: label, hint: hint, icon: icon, isDark: isDark),
      validator: required ? (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null : null,
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    required IconData icon,
    required bool isDark,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 18, color: isDark ? AppColors.slate400 : AppColors.slate500),
      filled: true,
      fillColor: isDark ? AppColors.slate700.withValues(alpha: 0.5) : AppColors.slate50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? AppColors.slate600 : AppColors.slate200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? AppColors.slate600 : AppColors.slate200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.brand, width: 1.5),
      ),
    );
  }
}
