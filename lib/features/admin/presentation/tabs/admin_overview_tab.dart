import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:ngo_volunteer_management/domain/entities/donation.entity.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';
import '../../../../core/widgets/app_card.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../shared/data/entities.dart';
import '../../../../shared/providers/feature_providers.dart';

class AdminOverviewTab extends ConsumerWidget {
  const AdminOverviewTab({super.key, required this.isSuperAdmin});
  final bool isSuperAdmin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volunteersAsync = ref.watch(volunteerProvider);
    final membersAsync    = ref.watch(memberProvider);
    final tasksAsync      = ref.watch(taskProvider);
    final donationsAsync  = ref.watch(donationProvider);
    final monthlyDonations = ref.watch(monthlyDonationAggregationProvider);
    final joiningAsync    = ref.watch(joiningLetterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return volunteersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:   (e, _) => Center(child: Text('Error: $e')),
      data: (volunteers) => membersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:   (e, _) => Center(child: Text('Error: $e')),
        data: (members) => tasksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error:   (e, _) => Center(child: Text('Error: $e')),
          data: (tasks) => donationsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error:   (e, _) => Center(child: Text('Error: $e')),
            data: (donations) {
              final activeVols    = volunteers.where((v) => v.status == PersonStatus.active).length;
              final activeMems    = members.where((m) => m.status == PersonStatus.active).length;
              final totalDonation = donations.where((d) => d.paymentStatus != PaymentStatus.failed).fold(0, (s, d) => s + d.amount);
              final donationCount = donations.where((d) => d.paymentStatus != PaymentStatus.failed).length;
              final onlineCount   = donations.where((d) => d.type == DonationType.online && d.paymentStatus == PaymentStatus.success).length;
              final pendingReqs   = joiningAsync.value?.where((r) => r.status == RequestStatus.pending).length ?? 0;
              final pendingTasks  = tasks.where((t) => t.status == TaskStatus.submitted).length;

              final taskStatusData = [
                _ChartPoint('Pending',   tasks.where((t) => t.status == TaskStatus.pending).length,   AppColors.amber500),
                _ChartPoint('Submitted', tasks.where((t) => t.status == TaskStatus.submitted).length, AppColors.blue500),
                _ChartPoint('Approved',  tasks.where((t) => t.status == TaskStatus.approved).length,  AppColors.emerald500),
                _ChartPoint('Rejected',  tasks.where((t) => t.status == TaskStatus.rejected).length,  AppColors.red500),
              ];

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(volunteerProvider);
                  ref.invalidate(memberProvider);
                  ref.invalidate(taskProvider);
                  ref.invalidate(donationProvider);
                  ref.invalidate(joiningLetterProvider);
                  await Future.delayed(const Duration(milliseconds: 800));
                },
                child: ListView(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                  children: [
                    // ── Hero banner ────────────────────────────────────────
                  _HeroBanner(
                    isSuperAdmin:     isSuperAdmin,
                    activeVolunteers: activeVols,
                    activeMembers:    activeMems,
                    pendingRequests:  pendingReqs,
                  ),
                  const SizedBox(height: 12),

                  // ── Stat cards ─────────────────────────────────────────
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossCount = constraints.maxWidth > 900 ? 5 : (constraints.maxWidth > 600 ? 3 : 2);
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossCount,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: crossCount == 4 ? 1.4 : 1.5,
                        children: [
                          StatCard(
                            title:          'Active Volunteers',
                            value:          '$activeVols',
                            subtitle:       '${volunteers.length} total',
                            icon:           const Icon(Icons.volunteer_activism_rounded, size: 20, color: AppColors.blue600),
                            iconBackground: AppColors.blue100,
                            trend:          '12%',
                            trendUp:        true,
                          ),
                          StatCard(
                            title:          'Active Members',
                            value:          '$activeMems',
                            subtitle:       '${members.where((m) => m.membershipType == MembershipType.eightyG).length} with 80G',
                            icon:           const Icon(Icons.people_rounded, size: 20, color: AppColors.emerald600),
                            iconBackground: AppColors.emerald100,
                            trend:          '8%',
                            trendUp:        true,
                          ),
                          StatCard(
                            title:          'Total Donations',
                            value:          AppFormatters.inr(totalDonation),
                            subtitle:       '${donations.where((d) => !d.receiptGenerated).length} receipts pending',
                            icon:           const Icon(Icons.currency_rupee_rounded, size: 20, color: AppColors.purple600),
                            iconBackground: AppColors.purple100,
                            trend:          '23%',
                            trendUp:        true,
                          ),
                          StatCard(
                            title:          'Online Payments',
                            value:          '$onlineCount',
                            subtitle:       'Via Razorpay checkout',
                            icon:           const Icon(Icons.credit_card_rounded, size: 20, color: AppColors.rose600),
                            iconBackground: AppColors.rose100,
                            trend:          '15%',
                            trendUp:        true,
                          ),
                          StatCard(
                            title:          'Pending Requests',
                            value:          '$pendingReqs',
                            subtitle:       '$pendingTasks tasks need review',
                            icon:           const Icon(Icons.inbox_rounded, size: 20, color: AppColors.amber600),
                            iconBackground: AppColors.amber100,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // ── Charts ─────────────────────────────────────────────
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 700;
                      
                      final Map<String, int> monthlyTotals = {};
                      for (final d in donations) {
                        final month = AppFormatters.displayDate(d.date).split(' ')[1];
                        monthlyTotals[month] = (monthlyTotals[month] ?? 0) + d.amount;
                      }
                      final List<MonthlyDonationPoint> chartData = monthlyTotals.entries
                          .map((e) => MonthlyDonationPoint(month: e.key, amount: e.value))
                          .toList();

                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: _DonationChart(
                                data: monthlyDonations,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _TaskPieChart(
                                data:       taskStatusData,
                                totalTasks: tasks.length,
                                isDark:     isDark,
                              ),
                            ),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          _DonationChart(
                            data: monthlyDonations,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 12),
                          _TaskPieChart(
                            data:       taskStatusData,
                            totalTasks: tasks.length,
                            isDark:     isDark,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // ── Bottom row ─────────────────────────────────────────
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 700;
                      final activity = _ActivityFeed(isDark: isDark);
                      final quickOverview = _QuickOverview(
                        tasks:     tasks,
                        donations: donations,
                        members:   members,
                        joiningPending: pendingReqs,
                        isDark:    isDark,
                      );
                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: activity),
                            const SizedBox(width: 12),
                            Expanded(child: quickOverview),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          activity,
                          const SizedBox(height: 12),
                          quickOverview,
                        ],
                      );
                    },
                  ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Hero banner ───────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.isSuperAdmin,
    required this.activeVolunteers,
    required this.activeMembers,
    required this.pendingRequests,
  });

  final bool isSuperAdmin;
  final int  activeVolunteers;
  final int  activeMembers;
  final int  pendingRequests;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.blue600, AppColors.indigo600, AppColors.violet600],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt_rounded, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(
                isSuperAdmin ? 'Super Admin Dashboard' : 'Admin Dashboard',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Jayashree Foundation',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Overview of all activities, people and finances.',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Pill('$activeVolunteers Active Volunteers'),
              _Pill('$activeMembers Active Members'),
              if (pendingRequests > 0)
                _Pill('$pendingRequests Pending Requests', warning: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text, {this.warning = false});
  final String text;
  final bool   warning;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: warning
            ? AppColors.amber400.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: warning
            ? Border.all(color: AppColors.amber300.withValues(alpha: 0.5))
            : null,
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}

// ── Donation bar chart ────────────────────────────────────────────────────────

class _DonationChart extends StatelessWidget {
  const _DonationChart({required this.data, required this.isDark});
  final List<MonthlyDonationPoint> data;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
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
                  Text('Donation Trend',
                      style: Theme.of(context).textTheme.titleSmall),
                  const Text('Last 6 months',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.slate400)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.emerald100,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.trending_up_rounded,
                        size: 12, color: AppColors.emerald600),
                    SizedBox(width: 4),
                    Text('+23% vs last period',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.emerald600,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: const CategoryAxis(
                axisLine: AxisLine(width: 0),
                majorTickLines: MajorTickLines(size: 0),
                labelStyle: TextStyle(
                    fontSize: 10, color: AppColors.slate400),
              ),
              primaryYAxis: NumericAxis(
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                majorGridLines: MajorGridLines(
                  color: isDark
                      ? AppColors.slate700
                      : AppColors.slate200,
                ),
                labelStyle: const TextStyle(
                    fontSize: 10, color: AppColors.slate400),
                numberFormat: _kNumberFormat,
              ),
              series: <CartesianSeries>[
                ColumnSeries<MonthlyDonationPoint, String>(
                  dataSource:   data,
                  xValueMapper: (d, _) => d.month,
                  yValueMapper: (d, _) => d.amount,
                  color:        AppColors.chartBlue,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  dataLabelSettings:
                      const DataLabelSettings(isVisible: false),
                ),
              ],
              tooltipBehavior: TooltipBehavior(
                enable: true,
                format: 'point.x : ₹point.y',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Reused number format (no flutter_intl dep in chart)
final _kNumberFormat =
    RegExp(r'').hasMatch('') ? null : null; // placeholder — handled by tooltip

// ── Task pie chart ────────────────────────────────────────────────────────────

class _ChartPoint {
  const _ChartPoint(this.label, this.value, this.color);
  final String label;
  final int    value;
  final Color  color;
}

class _TaskPieChart extends StatelessWidget {
  const _TaskPieChart({
    required this.data,
    required this.totalTasks,
    required this.isDark,
  });

  final List<_ChartPoint> data;
  final int               totalTasks;
  final bool              isDark;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Task Status', style: Theme.of(context).textTheme.titleSmall),
          Text('$totalTasks total tasks',
              style: const TextStyle(
                  fontSize: 11, color: AppColors.slate400)),
          const SizedBox(height: 8),
          SizedBox(
            height: 140,
            child: SfCircularChart(
              series: <CircularSeries>[
                DoughnutSeries<_ChartPoint, String>(
                  dataSource:        data,
                  xValueMapper:      (d, _) => d.label,
                  yValueMapper:      (d, _) => d.value,
                  pointColorMapper:  (d, _) => d.color,
                  innerRadius:       '60%',
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: false,
                  ),
                ),
              ],
              tooltipBehavior: TooltipBehavior(enable: true),
            ),
          ),
          const SizedBox(height: 8),
          ...data.map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color:        d.color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      d.label,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.slate500),
                    ),
                  ),
                  Text(
                    '${d.value}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Activity feed ────────────────────────────────────────────────────────────

class _ActivityFeed extends StatelessWidget {
  const _ActivityFeed({required this.isDark});
  final bool isDark;

  static const _activities = [
    ('Rahul Sharma submitted Food Drive task',        '2h ago',  AppColors.blue500),
    ('Neha Joshi applied for new membership',         '3h ago',  AppColors.emerald500),
    ('TechCorp donation of ₹5,00,000 received',       '5h ago',  AppColors.purple500),
    ('Priya Patel requested joining letter',          '1d ago',  AppColors.amber500),
    ('Medical MOU request by Dr. Anjali Mehta',       '1d ago',  AppColors.rose500),
    ('Health Camp task approved',                     '2d ago',  AppColors.blue500),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Activity',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 24),
          const Center(
            child: Column(
              children: [
                Icon(Icons.history_rounded, size: 40, color: AppColors.slate300),
                SizedBox(height: 12),
                Text(
                  'Activity tracking coming soon',
                  style: TextStyle(color: AppColors.slate400, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Quick overview ────────────────────────────────────────────────────────────

class _QuickOverview extends StatelessWidget {
  const _QuickOverview({
    required this.tasks,
    required this.donations,
    required this.members,
    required this.joiningPending,
    required this.isDark,
  });

  final List<TaskEntity>     tasks;
  final List<DonationEntity> donations;
  final List<MemberEntity>   members;
  final int                  joiningPending;
  final bool                 isDark;

  @override
  Widget build(BuildContext context) {
    final rows = [
      (Icons.check_circle_outline_rounded, AppColors.emerald500,
       'Tasks Approved This Month',
       tasks.where((t) => t.status == TaskStatus.approved).length),
      (Icons.schedule_rounded, AppColors.amber500,
       'Tasks Pending Review',
       tasks.where((t) => t.status == TaskStatus.submitted).length),
      (Icons.cancel_outlined, AppColors.red500,
       'Tasks Rejected',
       tasks.where((t) => t.status == TaskStatus.rejected).length),
      (Icons.receipt_long_rounded, AppColors.blue500,
       'Receipts Pending Generation',
       donations.where((d) => !d.receiptGenerated).length),
      (Icons.file_present_rounded, AppColors.purple500,
       'Joining Letter Requests',
       joiningPending),
      (Icons.people_outlined, AppColors.rose500,
       'Members with Due Payments',
       members.where((m) => !m.isPaid).length),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Overview',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 16),
          ...rows.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.slate700.withValues(alpha: 0.5)
                      : AppColors.slate50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(r.$1, size: 16, color: r.$2),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        r.$3,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.slate500),
                      ),
                    ),
                    Text(
                      '${r.$4}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}