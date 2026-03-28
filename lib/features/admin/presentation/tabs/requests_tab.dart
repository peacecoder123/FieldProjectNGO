import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/core/widgets/app_badge.dart';
import 'package:ngo_volunteer_management/core/widgets/app_card.dart';
import 'package:ngo_volunteer_management/core/widgets/section_header.dart';
import 'package:ngo_volunteer_management/shared/providers/feature_providers.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';

class RequestsTab extends ConsumerStatefulWidget {
  const RequestsTab({super.key});

  @override
  ConsumerState<RequestsTab> createState() => _RequestsTabState();
}

class _RequestsTabState extends ConsumerState<RequestsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionHeader(
          title: 'Requests & Inquiries',
          subtitle: 'Handle MOU requests and general inquiries from members and volunteers',
        ),
        const SizedBox(height: 8),
        TabBar(
          controller: _tabController,
          labelColor: AppColors.blue600,
          unselectedLabelColor: AppColors.slate500,
          indicatorColor: AppColors.blue600,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: 'General Requests'),
            Tab(text: 'MOU Requests'),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _GeneralRequestsList(),
              _MouRequestsList(),
            ],
          ),
        ),
      ],
    );
  }
}

class _GeneralRequestsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(generalRequestProvider);

    return requestsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (requests) {
        if (requests.isEmpty) {
          return const Center(child: Text('No general requests', style: TextStyle(color: AppColors.slate400)));
        }

        return ListView.separated(
          itemCount: requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final req = requests[index];
            return AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppBadge(label: req.requestType.displayLabel, color: AppColors.blue500),
                      _StatusBadge(status: req.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(req.details, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.slate400),
                      const SizedBox(width: 4),
                      Text(req.requesterName, style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
                      const SizedBox(width: 12),
                      const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.slate400),
                      const SizedBox(width: 4),
                      Text(AppFormatters.displayDate(req.requestDate), style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
                    ],
                  ),
                  if (req.status == RequestStatus.pending) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => ref.read(generalRequestProvider.notifier).reject(req.id),
                            style: OutlinedButton.styleFrom(foregroundColor: AppColors.red500),
                            child: const Text('Reject'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => ref.read(generalRequestProvider.notifier).approve(req.id),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald600, foregroundColor: Colors.white),
                            child: const Text('Approve'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _MouRequestsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(mouRequestProvider);

    return requestsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (requests) {
        if (requests.isEmpty) {
          return const Center(child: Text('No MOU requests', style: TextStyle(color: AppColors.slate400)));
        }

        return ListView.separated(
          itemCount: requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final req = requests[index];
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
                          Text('Patient: ${req.patientName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(req.hospital, style: const TextStyle(color: AppColors.rose500, fontWeight: FontWeight.w600, fontSize: 12)),
                        ],
                      ),
                      _StatusBadge(status: req.status),
                    ],
                  ),
                  const Divider(height: 24),
                  _MouInfoRow(label: 'Disease', value: req.disease),
                  _MouInfoRow(label: 'Requested By', value: req.requesterName),
                  _MouInfoRow(label: 'Contact', value: req.phone),
                  if (req.status == RequestStatus.pending) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => ref.read(mouRequestProvider.notifier).reject(req.id),
                            child: const Text('Reject'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => ref.read(mouRequestProvider.notifier).approve(req.id),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald600, foregroundColor: Colors.white),
                            child: const Text('Approve'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _MouInfoRow extends StatelessWidget {
  const _MouInfoRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontSize: 12, color: AppColors.slate400)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
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