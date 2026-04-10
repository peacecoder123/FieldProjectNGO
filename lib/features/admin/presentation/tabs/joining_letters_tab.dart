import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/core/widgets/app_badge.dart';
import 'package:ngo_volunteer_management/core/widgets/app_card.dart';
import 'package:ngo_volunteer_management/core/widgets/app_modal.dart';
import 'package:ngo_volunteer_management/core/widgets/section_header.dart';
import 'package:ngo_volunteer_management/shared/data/entities.dart';
import 'package:ngo_volunteer_management/shared/providers/feature_providers.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';
import 'package:ngo_volunteer_management/features/documents/services/pdf_generator_service.dart';
import 'package:printing/printing.dart';
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => const Center(child: Text('Error loading requests')),
      data: (requests) {
        final filtered = requests.where((r) => _statusFilter == null || r.status == _statusFilter).toList();

        return ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            const SectionHeader(
              title: 'Joining Letters',
              subtitle: 'Review and approve requests for official joining letters',
            ),
            const SizedBox(height: 16),
            _buildFilters(isDark: isDark),
            const SizedBox(height: 24),

            if (filtered.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Text('No requests found', style: TextStyle(color: isDark ? AppColors.slate400 : AppColors.slate500)),
                )
              )
            else
              ...filtered.map((req) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _JoiningRequestCard(request: req),
              )),
          ],
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
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
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
              _StatusBadge(status: request.status),
            ],
          ),
          if (request.status == RequestStatus.pending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => ref.read(joiningLetterProvider.notifier).reject(request.id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppColors.red500 : AppColors.red600,
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showApproveModal(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald600,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Approve'),
                  ),
                ),
              ],
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
                      'Approved by ${request.generatedBy} with tenure: ${request.tenure}',
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
                  Expanded(
                    child: Text(
                      'Rejected',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.red100 : AppColors.red600,
                      ),
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

  void _showApproveModal(BuildContext context, WidgetRef ref) {
    AppModal.show(
      context: context,
      title: 'Generate Joining Letter',
      child: _ApproveRequestForm(
        onSubmit: (by, tenure) {
          ref.read(joiningLetterProvider.notifier).approve(request.id, generatedBy: by, tenure: tenure);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final RequestStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      RequestStatus.pending => AppColors.amber500,
      RequestStatus.approved => AppColors.emerald500,
      RequestStatus.rejected => AppColors.red500,
    };
    return AppBadge(label: status.displayName.toUpperCase(), color: color);
  }
}

class _ApproveRequestForm extends StatefulWidget {
  const _ApproveRequestForm({required this.onSubmit});
  final Function(String, String) onSubmit;

  @override
  State<_ApproveRequestForm> createState() => _ApproveRequestFormState();
}

class _ApproveRequestFormState extends State<_ApproveRequestForm> {
  final _formKey = GlobalKey<FormState>();
  String generatedBy = '';
  String tenure = '6 Months';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Approved By (Admin Name)'),
            onSaved: (val) => generatedBy = val ?? '',
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: tenure,
            decoration: const InputDecoration(labelText: 'Tenure'),
            items: ['3 Months', '6 Months', '1 Year', 'Permanent'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (val) => setState(() => tenure = val!),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                _formKey.currentState?.save();
                widget.onSubmit(generatedBy, tenure);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emerald600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Generate & Approve'),
          ),
        ],
      ),
    );
  }
}
