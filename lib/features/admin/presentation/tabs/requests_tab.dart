import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/core/widgets/app_badge.dart';
import 'package:ngo_volunteer_management/core/widgets/app_card.dart';
import 'package:ngo_volunteer_management/core/widgets/section_header.dart';
import 'package:ngo_volunteer_management/shared/providers/app_providers.dart';
import 'package:ngo_volunteer_management/shared/providers/feature_providers.dart';
import 'package:ngo_volunteer_management/shared/data/entities.dart';
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
    _tabController = TabController(length: 4, vsync: this);
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
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: Colors.white,
          unselectedLabelColor: isDark ? AppColors.slate400 : AppColors.slate500,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          indicator: BoxDecoration(
            color: isDark ? AppColors.brand : AppColors.brand,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.brand.withValues(alpha: isDark ? 0.4 : 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          onTap: (_) => setState(() {}),
          tabs: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Tab(text: 'General'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Tab(text: 'MOU'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Tab(text: 'Certificates'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Tab(text: 'Hospitals'),
            ),
          ],
        ),
        const SizedBox(height: 24),

        if (_tabController.index == 0)
          _GeneralRequestsList()
        else if (_tabController.index == 1)
          _MouRequestsList()
        else if (_tabController.index == 2)
          const DocumentApprovalsList()
        else
          const _HospitalManagementList(),
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
      skipLoadingOnRefresh: true,
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
                  const SizedBox(height: 16),
                  Text(req.details, style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? AppColors.white : AppColors.slate900,
                  )),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.slate800.withValues(alpha: 0.5) : AppColors.slate50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? AppColors.slate700 : AppColors.slate100),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 280;
                        return Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.person_pin_rounded, size: 14, color: AppColors.brand),
                                const SizedBox(width: 8),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: isNarrow ? 120 : 180),
                                  child: Text(
                                    req.requesterName, 
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12, 
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.slate300 : AppColors.slate700
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.calendar_month_rounded, size: 14, color: AppColors.brand),
                                const SizedBox(width: 8),
                                Text(AppFormatters.displayDate(req.requestDate), style: TextStyle(
                                  fontSize: 12, 
                                  color: isDark ? AppColors.slate400 : AppColors.slate500
                                )),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  if (req.status == RequestStatus.pending || req.status == RequestStatus.waitingAdmin) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => ref.read(generalRequestProvider.notifier).reject(req.id),
                            icon: const Icon(Icons.close_rounded, size: 14),
                            label: const Text('Reject', style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? AppColors.red500 : AppColors.red600,
                              side: BorderSide(color: isDark ? AppColors.red500.withValues(alpha: 0.5) : AppColors.red100),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final adminName = ref.read(currentUserProvider)?.name ?? 'Admin';
                              ref.read(generalRequestProvider.notifier).approve(req.id, approvedBy: adminName);
                            },
                            icon: const Icon(Icons.check_rounded, size: 14),
                            label: const Text('Approve', style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brand, 
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
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
      skipLoadingOnRefresh: true,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.rose500.withValues(alpha: isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.emergency_rounded, color: AppColors.rose500, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(req.patientName, style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isDark ? AppColors.white : AppColors.slate900,
                            )),
                            const SizedBox(height: 2),
                            Text(req.hospital, style: TextStyle(
                              color: isDark ? AppColors.rose500.withValues(alpha: 0.8) : AppColors.rose600,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            )),
                          ],
                        ),
                      ),
                      _StatusBadge(status: req.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.slate900.withValues(alpha: 0.5) : AppColors.slate50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isDark ? AppColors.slate700 : AppColors.slate200),
                    ),
                    child: Column(
                      children: [
                        _MouInfoRow(label: 'Diagnosis', value: req.disease, icon: Icons.health_and_safety_rounded),
                        const SizedBox(height: 10),
                        _MouInfoRow(label: 'Volunteer', value: req.requesterName, icon: Icons.person_rounded),
                        const SizedBox(height: 10),
                        _MouInfoRow(label: 'Contact', value: req.phone, icon: Icons.phone_rounded),
                      ],
                    ),
                  ),
                  if (req.status == RequestStatus.pending || req.status == RequestStatus.waitingAdmin) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => ref.read(mouRequestProvider.notifier).reject(req.id),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? AppColors.red500 : AppColors.red600,
                              side: BorderSide(color: isDark ? AppColors.red500.withValues(alpha: 0.5) : AppColors.red100),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Reject Case'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final adminName = ref.read(currentUserProvider)?.name ?? 'Admin';
                              ref.read(mouRequestProvider.notifier).approve(req.id, approvedBy: adminName);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brand, 
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: const Text('Approve MOU'),
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
  const _MouInfoRow({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.brand),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(fontSize: 12, color: isDark ? AppColors.slate400 : AppColors.slate500)),
        Expanded(
          child: Text(value, style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.slate200 : AppColors.slate800,
          )),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (color, bgColor) = switch (status) {
      RequestStatus.pending      => (AppColors.amber600, AppColors.amber100),
      RequestStatus.waitingAdmin => (AppColors.brand, AppColors.blue100),
      RequestStatus.approved     => (AppColors.emerald600, AppColors.emerald100),
      RequestStatus.rejected      => (AppColors.red600, AppColors.red100),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.15) : bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? color.withValues(alpha: 1.5) : color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.displayName.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDark ? color : color.withValues(alpha: 0.8),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _HospitalManagementList extends ConsumerWidget {
  const _HospitalManagementList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hospitalsAsync = ref.watch(hospitalProvider);

    return Column(
      children: [
        AppCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Manage Partner Hospitals', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? AppColors.white : AppColors.slate900,
                    )),
                    const SizedBox(height: 4),
                    Text('Add or remove hospitals eligible for MOU', style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.slate400 : AppColors.slate500,
                    )),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddHospitalDialog(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Hospital'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        hospitalsAsync.when(
          skipLoadingOnRefresh: true,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (list) {
            if (list.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Text('No hospitals found', style: TextStyle(color: isDark ? AppColors.slate400 : AppColors.slate500)),
                ),
              );
            }
            return Column(
              children: list.map((h) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.rose500.withValues(alpha: isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.local_hospital_rounded, color: AppColors.rose500, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(h.name, style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isDark ? AppColors.white : AppColors.slate900,
                            )),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.location_on_rounded, size: 12, color: isDark ? AppColors.slate500 : AppColors.slate400),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text('${h.address}, ${h.city}', style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.slate400 : AppColors.slate500,
                                  )),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => ref.read(hospitalProvider.notifier).delete(h.id),
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.red500.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.delete_outline_rounded, color: AppColors.red500, size: 18),
                        ),
                        tooltip: 'Remove Hospital',
                      ),
                    ],
                  ),
                ),
              )).toList(),
            );
          },
        ),
      ],
    );
  }

  void _showAddHospitalDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final cityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Partner Hospital'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Hospital Name')),
            const SizedBox(height: 12),
            TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address')),
            const SizedBox(height: 12),
            TextField(controller: cityController, decoration: const InputDecoration(labelText: 'City')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                ref.read(hospitalProvider.notifier).add(HospitalEntity(
                  id: '',
                  name: nameController.text,
                  address: addressController.text,
                  city: cityController.text.isEmpty ? 'Mumbai' : cityController.text,
                ));
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
