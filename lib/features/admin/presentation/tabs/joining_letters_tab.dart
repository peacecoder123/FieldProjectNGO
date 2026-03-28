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

class JoiningLettersTab extends ConsumerStatefulWidget {
  const JoiningLettersTab({super.key});

  @override
  ConsumerState<JoiningLettersTab> createState() => _JoiningLettersTabState();
}

class _JoiningLettersTabState extends ConsumerState<JoiningLettersTab> {
  RequestStatus? _statusFilter = RequestStatus.pending;

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(joiningLetterProvider);

    return Column(
      children: [
        const SectionHeader(
          title: 'Joining Letters',
          subtitle: 'Review and approve requests for official joining letters',
        ),
        const SizedBox(height: 16),
        _buildFilters(),
        const SizedBox(height: 16),
        Expanded(
          child: requestsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (requests) {
              final filtered = requests.where((r) => _statusFilter == null || r.status == _statusFilter).toList();

              if (filtered.isEmpty) {
                return const Center(child: Text('No requests found', style: TextStyle(color: AppColors.slate400)));
              }

              return ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final req = filtered[index];
                  return _JoiningRequestCard(request: req);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            isSelected: _statusFilter == null,
            onSelected: () => setState(() => _statusFilter = null),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Pending',
            isSelected: _statusFilter == RequestStatus.pending,
            onSelected: () => setState(() => _statusFilter = RequestStatus.pending),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Approved',
            isSelected: _statusFilter == RequestStatus.approved,
            onSelected: () => setState(() => _statusFilter = RequestStatus.approved),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Rejected',
            isSelected: _statusFilter == RequestStatus.rejected,
            onSelected: () => setState(() => _statusFilter = RequestStatus.rejected),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.isSelected, required this.onSelected});
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.blue100,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.blue600 : AppColors.slate600,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class _JoiningRequestCard extends ConsumerWidget {
  const _JoiningRequestCard({required this.request});
  final JoiningLetterRequestEntity request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  Text(request.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(
                    'Requested for ${request.type.displayLabel} on ${AppFormatters.displayDate(request.requestDate)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.slate500),
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
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.red500),
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_rounded, size: 16, color: AppColors.emerald500),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Approved by ${request.generatedBy} with tenure: ${request.tenure}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Approved By (Admin Name)'),
            onSaved: (val) => generatedBy = val ?? '',
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: tenure,
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