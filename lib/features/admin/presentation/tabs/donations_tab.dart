import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/core/widgets/app_badge.dart';
import 'package:ngo_volunteer_management/core/widgets/app_card.dart';
import 'package:ngo_volunteer_management/core/widgets/app_modal.dart';
import 'package:ngo_volunteer_management/core/widgets/section_header.dart';
import 'package:ngo_volunteer_management/core/widgets/stat_card.dart';
import 'package:ngo_volunteer_management/shared/data/entities.dart';
import 'package:ngo_volunteer_management/shared/data/mock_data_source.dart';
import 'package:ngo_volunteer_management/shared/providers/feature_providers.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';
import 'package:ngo_volunteer_management/domain/entities/donation.entity.dart';

class DonationsTab extends ConsumerStatefulWidget {
  const DonationsTab({super.key});

  @override
  ConsumerState<DonationsTab> createState() => _DonationsTabState();
}

class _DonationsTabState extends ConsumerState<DonationsTab> {
  String _searchQuery = '';
  DonationType? _typeFilter;

  @override
  Widget build(BuildContext context) {
    final donationsAsync = ref.watch(donationProvider);
    final monthlyDonations = ref.watch(monthlyDonationAggregationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return donationsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (donations) {
        final totalAmount = donations.fold(0, (sum, d) => sum + d.amount);
        final filtered = donations.where((d) {
          final matchesSearch = d.donorName.toLowerCase().contains(_searchQuery.toLowerCase());
          final matchesType = _typeFilter == null || d.type == _typeFilter;
          return matchesSearch && matchesType;
        }).toList();

        return ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            SectionHeader(
              title: 'Donations',
              subtitle: 'Track financial contributions and generate receipts',
              actions: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showAddDonationModal(context),
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                    label: const Text('Add Donation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Stats Row
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isWide ? 3 : 1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: isWide ? 2.5 : 4,
                  children: [
                    StatCard(
                      title: 'Total Donations',
                      value: AppFormatters.inr(totalAmount),
                      icon: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.purple600),
                      iconBackground: AppColors.purple100,
                    ),
                    StatCard(
                      title: 'Receipts Pending',
                      value: '${donations.where((d) => !d.receiptGenerated).length}',
                      icon: const Icon(Icons.receipt_long_rounded, color: AppColors.amber600),
                      iconBackground: AppColors.amber100,
                    ),
                    StatCard(
                      title: '80G Donations',
                      value: '${donations.where((d) => d.is80G).length}',
                      icon: const Icon(Icons.verified_rounded, color: AppColors.emerald600),
                      iconBackground: AppColors.emerald100,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // Charts
            _DonationTrendChart(data: monthlyDonations, isDark: isDark),
            const SizedBox(height: 20),

            // Filters
            _buildFilters(),
            const SizedBox(height: 16),

            // Donations List
            if (filtered.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Text('No donations found', style: TextStyle(color: AppColors.slate400)),
                )
              )
            else
              ...filtered.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DonationItem(donation: d),
              )),
          ],
        );
      },
    );
  }

  Widget _buildFilters() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search donor name...',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: isDark ? AppColors.slate800 : AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: isDark ? AppColors.slate700 : AppColors.slate200),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.slate800 : AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDark ? AppColors.slate700 : AppColors.slate200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<DonationType?>(
              value: _typeFilter,
              hint: const Text('Mode'),
              onChanged: (val) => setState(() => _typeFilter = val),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Types')),
                ...DonationType.values.map((t) => DropdownMenuItem(
                  value: t,
                  child: Text(t.name[0].toUpperCase() + t.name.substring(1)),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddDonationModal(BuildContext context) {
    AppModal.show(
      context: context,
      title: 'Record New Donation',
      child: _AddDonationForm(
        onSubmit: (d) {
          ref.read(donationProvider.notifier).add(d);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _DonationTrendChart extends StatelessWidget {
  const _DonationTrendChart({required this.data, required this.isDark});
  final List<MonthlyDonationPoint> data;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Donation Monthly Trend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: SfCartesianChart(
              margin: EdgeInsets.zero,
              plotAreaBorderWidth: 0,
              primaryXAxis: const CategoryAxis(
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                labelStyle: const TextStyle(fontSize: 10, color: AppColors.slate400),
              ),
              primaryYAxis: const NumericAxis(
                isVisible: false,
              ),
              series: <CartesianSeries>[
                ColumnSeries<MonthlyDonationPoint, String>(
                  dataSource: data,
                  xValueMapper: (d, _) => d.month,
                  yValueMapper: (d, _) => d.amount,
                  color: AppColors.purple500,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  width: 0.6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DonationItem extends ConsumerWidget {
  const _DonationItem({required this.donation});
  final DonationEntity donation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppColors.purple100, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.currency_rupee_rounded, color: AppColors.purple600),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(donation.donorName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                Row(
                  children: [
                    Text(
                      '${AppFormatters.displayDate(donation.date)} • ${donation.type.name.toUpperCase()}',
                      style: const TextStyle(color: AppColors.slate500, fontSize: 12),
                    ),
                    if (donation.type == DonationType.online) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: donation.paymentStatus == PaymentStatus.success ? AppColors.emerald50 : AppColors.red50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: donation.paymentStatus == PaymentStatus.success ? AppColors.emerald200 : AppColors.red100,
                          ),
                        ),
                        child: Text(
                          donation.paymentStatus.displayName,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: donation.paymentStatus == PaymentStatus.success ? AppColors.emerald700 : AppColors.red600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppFormatters.inr(donation.amount),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.slate900),
              ),
              const SizedBox(height: 4),
              if (donation.receiptGenerated)
                AppBadge(label: 'Receipt: ${donation.receiptNumber}', color: AppColors.emerald500)
              else
                TextButton(
                  onPressed: () => ref.read(donationProvider.notifier).generateReceipt(donation.id),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Generate Receipt', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddDonationForm extends StatefulWidget {
  const _AddDonationForm({required this.onSubmit});
  final Function(DonationEntity) onSubmit;

  @override
  State<_AddDonationForm> createState() => _AddDonationFormState();
}

class _AddDonationFormState extends State<_AddDonationForm> {
  final _formKey = GlobalKey<FormState>();
  String donorName = '';
  int amount = 0;
  DonationType selectedType = DonationType.online;
  bool is80G = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Donor Name'),
            onSaved: (val) => donorName = val ?? '',
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Amount (₹)', prefixText: '₹ '),
            keyboardType: TextInputType.number,
            onSaved: (val) => amount = int.tryParse(val ?? '0') ?? 0,
            validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter valid amount' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<DonationType>(
            initialValue: selectedType,
            decoration: const InputDecoration(labelText: 'Payment Mode'),
            items: DonationType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name.toUpperCase()))).toList(),
            onChanged: (val) => setState(() => selectedType = val!),
          ),
          CheckboxListTile(
            title: const Text('80G Tax Benefit'),
            value: is80G,
            onChanged: (val) => setState(() => is80G = val ?? false),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                _formKey.currentState?.save();
                widget.onSubmit(DonationEntity(
                  id: DateTime.now().millisecondsSinceEpoch,
                  donorName: donorName,
                  amount: amount,
                  date: AppFormatters.today(),
                  type: selectedType,
                  receiptGenerated: false,
                  purpose: 'General Donation',
                  is80G: is80G,
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Record Donation'),
          ),
        ],
      ),
    );
  }
}