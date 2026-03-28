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

class VolunteerJoiningLetterTab extends ConsumerStatefulWidget {
  const VolunteerJoiningLetterTab({super.key});

  @override
  ConsumerState<VolunteerJoiningLetterTab> createState() => _VolunteerJoiningLetterTabState();
}

class _VolunteerJoiningLetterTabState extends ConsumerState<VolunteerJoiningLetterTab> {
  JoiningLetterType? _selectedType = JoiningLetterType.volunteer;

  @override
  Widget build(BuildContext context) {
    final lettersAsync = ref.watch(joiningLetterProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: 'Request Letter',
          subtitle: 'Apply for official joining letters or certificates',
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Start New Request', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              DropdownButtonFormField<JoiningLetterType>(
                value: _selectedType,
                items: JoiningLetterType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.displayLabel))).toList(),
                onChanged: (val) => setState(() => _selectedType = val),
                decoration: const InputDecoration(labelText: 'Document Type'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_selectedType != null && currentUser != null) {
                    ref.read(joiningLetterProvider.notifier).add(JoiningLetterRequestEntity(
                      id: DateTime.now().millisecondsSinceEpoch,
                      name: currentUser.name,
                      type: _selectedType!,
                      requestDate: AppFormatters.today(),
                      status: RequestStatus.pending,
                      tenure: 'Pending',
                    ));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request Submitted')));
                  }
                },
                child: const Text('Submit Request'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Request History', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Expanded(
          child: lettersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
            data: (letters) {
              final myLetters = letters.where((l) => l.name == currentUser?.name).toList();
              if (myLetters.isEmpty) return const Text('No history found');
              return ListView.separated(
                itemCount: myLetters.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final l = myLetters[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l.type.displayLabel),
                        Text(l.status.displayName, style: TextStyle(color: l.status == RequestStatus.approved ? AppColors.emerald600 : AppColors.amber600)),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}