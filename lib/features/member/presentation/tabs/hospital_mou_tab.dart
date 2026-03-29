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

class HospitalMouTab extends ConsumerStatefulWidget {
  const HospitalMouTab({super.key});

  @override
  ConsumerState<HospitalMouTab> createState() => _HospitalMouTabState();
}

class _HospitalMouTabState extends ConsumerState<HospitalMouTab> {
  final _formKey = GlobalKey<FormState>();
  String patientName = '';
  int patientAge = 0;
  String disease = '';
  String hospital = '';
  String phone = '';
  String address = '';
  String bloodGroup = '';

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final mouRequestsAsync = ref.watch(mouRequestProvider);

    return ListView(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        const SectionHeader(
          title: 'Hospital MOU',
          subtitle: 'Apply for medical concessions at partner hospitals',
        ),
        const SizedBox(height: 24),
        
        // Request Form
        AppCard(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Submit New Request', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Patient Name', prefixIcon: Icon(Icons.person_outline_rounded)),
                        onSaved: (val) => patientName = val ?? '',
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 90,
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Age'),
                        keyboardType: TextInputType.number,
                        onSaved: (val) => patientAge = int.tryParse(val ?? '0') ?? 0,
                        validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0 ? '!' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Disease/Condition', prefixIcon: Icon(Icons.healing_rounded)),
                        onSaved: (val) => disease = val ?? '',
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 110,
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Blood Group'),
                        onSaved: (val) => bloodGroup = val ?? '',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Hospital Name', prefixIcon: Icon(Icons.local_hospital_rounded)),
                  onSaved: (val) => hospital = val ?? '',
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Patient Address', prefixIcon: Icon(Icons.location_on_rounded)),
                  onSaved: (val) => address = val ?? '',
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Contact Phone', prefixIcon: Icon(Icons.phone_android_rounded)),
                  onSaved: (val) => phone = val ?? '',
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _formKey.currentState?.save();
                      ref.read(mouRequestProvider.notifier).add(MouRequestEntity(
                        id: DateTime.now().millisecondsSinceEpoch,
                        requesterName: currentUser?.name ?? 'Member',
                        patientName: patientName,
                        patientAge: patientAge,
                        disease: disease,
                        hospital: hospital,
                        phone: phone,
                        address: address,
                        bloodGroup: bloodGroup,
                        status: RequestStatus.pending,
                        requestDate: AppFormatters.today(),
                      ));
                      _formKey.currentState!.reset();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('MOU Request Submitted Successfully')));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.rose600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Submit Application'),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 32),
        const Text('My Recent Requests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        
        mouRequestsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
          data: (requests) {
            final myRequests = requests.where((r) => r.requesterName == (currentUser?.name ?? 'Member')).toList();
            if (myRequests.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('No previous MOU requests found.', style: TextStyle(color: AppColors.slate400, fontSize: 13)),
                ),
              );
            }
            return Column(
              children: myRequests.map((r) => _MouHistoryItem(request: r)).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _MouHistoryItem extends StatelessWidget {
  const _MouHistoryItem({required this.request});
  final MouRequestEntity request;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (request.status) {
      RequestStatus.pending => AppColors.amber500,
      RequestStatus.approved => AppColors.emerald500,
      RequestStatus.rejected => AppColors.red500,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request.hospital, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text('Patient: ${request.patientName}', style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          AppBadge(label: request.status.displayName.toUpperCase(), color: statusColor),
        ],
      ),
    );
  }
}