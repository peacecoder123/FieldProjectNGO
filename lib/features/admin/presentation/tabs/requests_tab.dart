import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/core/widgets/app_badge.dart';
import 'package:ngo_volunteer_management/core/widgets/app_card.dart';
import 'package:ngo_volunteer_management/core/widgets/section_header.dart';
import 'package:ngo_volunteer_management/shared/providers/app_providers.dart';
import 'package:ngo_volunteer_management/shared/providers/feature_providers.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';
import 'package:ngo_volunteer_management/features/admin/presentation/tabs/document_approvals_tab.dart';

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
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(generalRequestProvider);
        ref.invalidate(mouRequestProvider);
        ref.invalidate(joiningLetterProvider);
        await Future.delayed(const Duration(milliseconds: 800));
      },
      child: ListView(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          const SectionHeader(
          title: 'Requests & Inquiries',
          subtitle: 'Handle formal documents, MOU requests and general inquiries',
        ),
        const SizedBox(height: 24),
        TabBar(
          controller: _tabController,
          labelColor: isDark ? AppColors.blue400 : AppColors.blue600,
          unselectedLabelColor: AppColors.slate400,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          indicator: BoxDecoration(
            color: AppColors.blue600.withValues(alpha: isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          onTap: (_) => setState(() {}),
          tabs: const [
            Tab(text: 'General Requests'),
            Tab(text: 'MOU Requests'),
            Tab(text: 'Certificates'),
          ],
        ),
        const SizedBox(height: 24),

        if (_tabController.index == 0)
          _GeneralRequestsList()
        else if (_tabController.index == 1)
          _MouRequestsList()
        else
          const DocumentApprovalsList(),
        ],
      ),
    );
  }
}

class _GeneralRequestsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final requestsAsync = ref.watch(generalRequestProvider);

    return requestsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Error: $e', style: TextStyle(color: isDark ? AppColors.red500 : AppColors.red600)),
      ),
      data: (requests) {
        if (requests.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Text('No general requests', style: TextStyle(color: isDark ? AppColors.slate400 : AppColors.slate500)),
            ),
          );
        }

        return Column(
          children: requests.map((req) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
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
                  Text(req.details, style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: isDark ? AppColors.slate200 : AppColors.slate900,
                  )),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded, size: 14, color: isDark ? AppColors.slate500 : AppColors.slate400),
                      const SizedBox(width: 4),
                      Text(req.requesterName, style: TextStyle(fontSize: 12, color: isDark ? AppColors.slate400 : AppColors.slate500)),
                      const SizedBox(width: 12),
                      Icon(Icons.calendar_today_rounded, size: 14, color: isDark ? AppColors.slate500 : AppColors.slate400),
                      const SizedBox(width: 4),
                      Text(AppFormatters.displayDate(req.requestDate), style: TextStyle(fontSize: 12, color: isDark ? AppColors.slate400 : AppColors.slate500)),
                    ],
                  ),
                  if (req.status == RequestStatus.pending) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => ref.read(generalRequestProvider.notifier).reject(req.id),
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
                              final adminName = ref.read(currentUserProvider)?.name ?? 'Admin';
                              ref.read(generalRequestProvider.notifier).approve(req.id, approvedBy: adminName);
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.brand, foregroundColor: Colors.white),
                            child: const Text('Approve'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          )).toList(),
        );
      },
    );
  }
}

class _MouRequestsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final requestsAsync = ref.watch(mouRequestProvider);

    return requestsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Error: $e', style: TextStyle(color: isDark ? AppColors.red500 : AppColors.red600)),
      ),
      data: (requests) {
        if (requests.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Text('No MOU requests', style: TextStyle(color: isDark ? AppColors.slate400 : AppColors.slate500)),
            ),
          );
        }

        return Column(
          children: requests.map((req) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Patient: ${req.patientName}', style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? AppColors.white : AppColors.slate900,
                          )),
                          Text(req.hospital, style: TextStyle(
                            color: isDark ? AppColors.rose500 : AppColors.rose600,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          )),
                        ],
                      ),
                      _StatusBadge(status: req.status),
                    ],
                  ),
                  Divider(height: 24, color: isDark ? AppColors.slate700 : AppColors.slate200),
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
                            onPressed: () {
                              final adminName = ref.read(currentUserProvider)?.name ?? 'Admin';
                              ref.read(mouRequestProvider.notifier).approve(req.id, approvedBy: adminName);
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.brand, foregroundColor: Colors.white),
                            child: const Text('Approve'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          )).toList(),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: TextStyle(fontSize: 12, color: isDark ? AppColors.slate400 : AppColors.slate500)),
          Expanded(
            child: Text(value, style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.slate200 : AppColors.slate800,
            )),
          ),
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
