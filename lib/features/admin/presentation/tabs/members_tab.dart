import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/core/widgets/app_avatar.dart';
import 'package:ngo_volunteer_management/core/widgets/app_badge.dart';
import 'package:ngo_volunteer_management/core/widgets/app_card.dart';
import 'package:ngo_volunteer_management/core/widgets/app_modal.dart';
import 'package:ngo_volunteer_management/core/widgets/section_header.dart';
import 'package:ngo_volunteer_management/features/admin/presentation/widgets/task_details_modal.dart';
import 'package:ngo_volunteer_management/shared/data/entities.dart';
import 'package:ngo_volunteer_management/shared/providers/feature_providers.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';

class MembersTab extends ConsumerStatefulWidget {
  const MembersTab({super.key});

  @override
  ConsumerState<MembersTab> createState() => _MembersTabState();
}

class _MembersTabState extends ConsumerState<MembersTab> {
  String _searchQuery = '';
  PersonStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(memberProvider);

    return Column(
      children: [
        SectionHeader(
          title: 'Members',
          subtitle: 'Manage NGO members, memberships and renewals',
          actions: ElevatedButton.icon(
            onPressed: () => _showAddMemberModal(context),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Member'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brand,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: const StadiumBorder(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildFilters(),
        const SizedBox(height: 16),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(memberProvider);
              await Future.delayed(const Duration(milliseconds: 800));
            },
            child: membersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (members) {
                final filtered = members.where((m) {
                  final matchesSearch = m.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                                       m.email.toLowerCase().contains(_searchQuery.toLowerCase());
                  final matchesStatus = _statusFilter == null || m.status == _statusFilter;
                  return matchesSearch && matchesStatus;
                }).toList();
  
                if (filtered.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group_off_rounded, size: 48, color: AppColors.slate300),
                        SizedBox(height: 12),
                        Text('No members found', style: TextStyle(color: AppColors.slate500)),
                      ],
                    ),
                  );
                }
  
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final m = filtered[index];
                    return _MemberCard(
                      member: m,
                      onTap: () => _showMemberDetails(context, m),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search members...',
              prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.slate400),
              filled: true,
              fillColor: isDark ? AppColors.slate800 : AppColors.slate50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
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
            child: DropdownButton<PersonStatus?>(
              value: _statusFilter,
              hint: const Text('Status'),
              onChanged: (val) => setState(() => _statusFilter = val),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Status')),
                ...PersonStatus.values.map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(s.name[0].toUpperCase() + s.name.substring(1)),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddMemberModal(BuildContext context) {
    AppModal.show(
      context: context,
      title: 'Add New Member',
      size: ModalSize.medium,
      child: _AddMemberForm(
        onSubmit: (m) async {
          try {
            await ref.read(memberProvider.notifier).add(m);
            if (!context.mounted) return;
            
            Navigator.pop(context);
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text('${m.name} has been added as a member.')),
                  ],
                ),
                backgroundColor: AppColors.emerald500,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          } catch (e) {
            if (!context.mounted) return;
            
            String errorMsg = e.toString();
            if (errorMsg.contains('Exception:')) {
              errorMsg = errorMsg.split('Exception:').last.trim();
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(errorMsg)),
                  ],
                ),
                backgroundColor: AppColors.red500,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
      ),
    );
  }

  void _showMemberDetails(BuildContext context, MemberEntity m) {
    AppModal.show(
      context: context,
      title: 'Member Profile',
      size: ModalSize.large,
      child: _MemberDetailsContent(member: m),
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member, required this.onTap});
  final MemberEntity member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final daysToRenewal = AppFormatters.daysUntil(member.renewalDate);
    final isExpiringSoon = daysToRenewal >= 0 && daysToRenewal <= 30;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          AppAvatar(
            initials: AppFormatters.initials(member.name),
            size: AvatarSize.large,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  member.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                Text(
                  member.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.slate500, fontSize: 12),
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      AppBadge(
                        label: member.membershipType.displayLabel,
                        color: member.membershipType == MembershipType.eightyG ? AppColors.primary : AppColors.purple500,
                      ),
                      if (isExpiringSoon) ...[
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, size: 12, color: AppColors.amber600),
                            const SizedBox(width: 4),
                            Text(
                              '$daysToRenewal d',
                              style: const TextStyle(color: AppColors.amber600, fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBadge(
                label: member.status.name.toUpperCase(),
                color: member.status == PersonStatus.active ? AppColors.emerald500 : AppColors.slate400,
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: member.isPaid ? AppColors.emerald500 : AppColors.amber500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    member.isPaid ? 'PAID' : 'UNPAID',
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 0.5,
                      color: isDark ? AppColors.slate400 : AppColors.slate500,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: AppColors.slate300),
        ],
      ),
    );
  }
}

class _AddMemberForm extends StatefulWidget {
  const _AddMemberForm({required this.onSubmit});
  final Future<void> Function(MemberEntity) onSubmit;

  @override
  State<_AddMemberForm> createState() => _AddMemberFormState();
}

class _AddMemberFormState extends State<_AddMemberForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String name = '';
  String email = '';
  String phone = '';
  String address = '';
  MembershipType membershipType = MembershipType.nonEightyG;
  DateTime renewalDate = DateTime.now().add(const Duration(days: 365));
  bool isPaid = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Full Name'),
            onSaved: (val) => name = val ?? '',
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Email Address'),
            onSaved: (val) => email = val ?? '',
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Phone'),
            onSaved: (val) => phone = val ?? '',
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<MembershipType>(
            value: membershipType,
            decoration: const InputDecoration(labelText: 'Membership Type'),
            items: MembershipType.values.map((t) => DropdownMenuItem(
              value: t,
              child: Text(t.displayLabel),
            )).toList(),
            onChanged: (val) => setState(() => membershipType = val!),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Renewal Date'),
            subtitle: Text(AppFormatters.displayDate(AppFormatters.toIso(renewalDate))),
            trailing: const Icon(Icons.calendar_today_rounded),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: renewalDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 730)),
              );
              if (picked != null) setState(() => renewalDate = picked);
            },
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Membership Amount Paid'),
            subtitle: const Text('Mark if the initial fee has already been collected'),
            value: isPaid,
            activeColor: AppColors.emerald500,
            onChanged: (val) => setState(() => isPaid = val),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brand,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Create Membership'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      setState(() => _isLoading = true);
      try {
        await widget.onSubmit(MemberEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name.trim(),
          email: email.trim(),
          phone: phone.trim(),
          address: address.trim(),
          joinDate: AppFormatters.today(),
          renewalDate: AppFormatters.toIso(renewalDate),
          status: PersonStatus.active,
          membershipType: membershipType,
          taskIds: const [],
          isPaid: isPaid,
          avatar: '',
        ));
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
}

class _MemberDetailsContent extends ConsumerWidget {
  const _MemberDetailsContent({required this.member});
  final MemberEntity member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskProvider);
    final daysToRenewal = AppFormatters.daysUntil(member.renewalDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppAvatar(
              initials: AppFormatters.initials(member.name),
              size: AvatarSize.xlarge,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(member.email, style: const TextStyle(color: AppColors.slate500)),
                  const SizedBox(height: 8),
                  AppBadge(
                    label: member.membershipType.displayLabel,
                    color: member.membershipType == MembershipType.eightyG ? AppColors.primary : AppColors.purple500,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const Text('Membership Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatBox(
                label: 'Renewal Date',
                value: AppFormatters.displayDate(member.renewalDate),
                subtitle: daysToRenewal < 0 ? 'Expired' : '$daysToRenewal days left',
                color: daysToRenewal < 30 ? AppColors.red500 : AppColors.emerald500,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatBox(
                label: 'Fees Payment',
                value: member.isPaid ? 'Paid' : 'Pending',
                subtitle: member.isPaid ? 'FY 2024-25' : 'Action Required',
                color: member.isPaid ? AppColors.emerald500 : AppColors.amber500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const Text('Contact Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            children: [
              _InfoTile(label: 'Phone', value: member.phone, icon: Icons.phone_android_rounded),
              const Divider(height: 24),
              _InfoTile(label: 'Address', value: member.address, icon: Icons.location_on_rounded),
              const Divider(height: 24),
              _InfoTile(label: 'Joined On', value: AppFormatters.displayDate(member.joinDate), icon: Icons.verified_user_rounded),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Guided Volunteers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: () => _showAssignVolunteerModal(context, ref),
              icon: const Icon(Icons.person_add_rounded, size: 18),
              label: const Text('Assign Volunteer'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _GuidedVolunteersList(memberId: member.id),

        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Assigned Tasks', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: () => _showAddTaskModal(context, ref),
              icon: const Icon(Icons.add_task_rounded, size: 18),
              label: const Text('Assign Task'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        tasksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error loading tasks: $e'),
          data: (tasks) {
            final memberTasks = tasks.where((t) => t.assignedToId == member.id && t.assignedToType == AssigneeType.member).toList();
            if (memberTasks.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('No tasks assigned', style: TextStyle(color: AppColors.slate400)),
                ),
              );
            }
            return Column(
              children: memberTasks.map((t) => _TaskItem(task: t)).toList(),
            );
          },
        ),
      ],
    );
  }

  void _showAddTaskModal(BuildContext context, WidgetRef ref) {
    AppModal.show(
      context: context,
      title: 'Assign Task to ${member.name}',
      child: _AddTaskForm(
        member: member,
        onSubmit: (task) {
          ref.read(taskProvider.notifier).add(task);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showAssignVolunteerModal(BuildContext context, WidgetRef ref) {
    AppModal.show(
      context: context,
      title: 'Assign Volunteer to ${member.name}',
      child: _AssignVolunteerForm(
        member: member,
        onAssign: (volunteer) async {
          final updated = volunteer.copyWith(
            mentorId: member.id,
            mentorName: member.name,
          );
          await ref.read(volunteerProvider.notifier).update(updated);
        },
      ),
    );
  }
}

class _GuidedVolunteersList extends ConsumerWidget {
  const _GuidedVolunteersList({required this.memberId});
  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volunteersAsync = ref.watch(volunteerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return volunteersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error loading volunteers: $e'),
      data: (volunteers) {
        final mentored = volunteers.where((v) => v.mentorId == memberId).toList();
        if (mentored.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate800 : AppColors.slate50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('No volunteers assigned for guidance',
                  style: TextStyle(color: AppColors.slate400, fontSize: 13)),
            ),
          );
        }
        return Column(
          children: mentored.map((v) => _MentoredVolunteerItem(volunteer: v)).toList(),
        );
      },
    );
  }
}

class _MentoredVolunteerItem extends ConsumerWidget {
  const _MentoredVolunteerItem({required this.volunteer});
  final VolunteerEntity volunteer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppColors.slate700 : AppColors.slate200),
      ),
      child: Row(
        children: [
          AppAvatar(initials: AppFormatters.initials(volunteer.name), size: AvatarSize.medium, role: UserRole.volunteer),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(volunteer.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(volunteer.email, style: const TextStyle(color: AppColors.slate500, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_remove_rounded, size: 18, color: AppColors.red500),
            onPressed: () => _unassign(ref),
            tooltip: 'Remove from guidance',
          ),
        ],
      ),
    );
  }

  Future<void> _unassign(WidgetRef ref) async {
    final updated = volunteer.copyWith(mentorId: '', mentorName: '');
    await ref.read(volunteerProvider.notifier).update(updated);
  }
}

class _AssignVolunteerForm extends StatefulWidget {
  const _AssignVolunteerForm({required this.member, required this.onAssign});
  final MemberEntity member;
  final Function(VolunteerEntity) onAssign;

  @override
  State<_AssignVolunteerForm> createState() => _AssignVolunteerFormState();
}

class _AssignVolunteerFormState extends State<_AssignVolunteerForm> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final volunteersAsync = ref.watch(volunteerProvider);
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search volunteers...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (val) => setState(() => _search = val),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: volunteersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
                data: (volunteers) {
                  final filtered = volunteers.where((v) {
                    final matchesSearch = v.name.toLowerCase().contains(_search.toLowerCase()) ||
                                         v.email.toLowerCase().contains(_search.toLowerCase());
                    final isNotAlreadyMentored = v.mentorId != widget.member.id;
                    return matchesSearch && isNotAlreadyMentored;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('No matching volunteers found'));
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final v = filtered[index];
                      return ListTile(
                        leading: AppAvatar(initials: AppFormatters.initials(v.name), size: AvatarSize.small, role: UserRole.volunteer),
                        title: Text(v.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        subtitle: Text(v.mentorId != null && v.mentorId!.isNotEmpty 
                          ? 'Guided by: ${v.mentorName}' 
                          : 'No guide assigned',
                          style: const TextStyle(fontSize: 11)),
                        trailing: const Icon(Icons.add_circle_outline_rounded, color: AppColors.brand),
                        onTap: () {
                          widget.onAssign(v);
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value, required this.subtitle, required this.color});
  final String label;
  final String value;
  final String subtitle;
  final Color  color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8), fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          Text(subtitle, style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.6))),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.slate100, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: AppColors.slate600),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: AppColors.slate400, fontWeight: FontWeight.w600)),
              Text(value.isEmpty ? 'Not provided' : value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}

class _TaskItem extends ConsumerWidget {
  const _TaskItem({required this.task});
  final TaskEntity task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => _showDetails(context),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.slate800 : AppColors.slate50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isDark ? AppColors.slate700 : AppColors.slate200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.event_rounded, size: 10, color: AppColors.slate400),
                          const SizedBox(width: 4),
                          Text(
                            'Due: ${AppFormatters.displayDate(task.deadline)}',
                            style: const TextStyle(fontSize: 10, color: AppColors.slate500),
                          ),
                          if (task.geotag != null && task.geotag!.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            const Icon(Icons.location_on_rounded, size: 10, color: AppColors.red500),
                            const SizedBox(width: 2),
                            const Text('Geotagged', style: TextStyle(fontSize: 10, color: AppColors.slate500)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                _TaskStatusChip(status: task.status),
              ],
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                task.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: AppColors.slate500),
              ),
            ],
            if (task.status == TaskStatus.submitted) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => _showDetails(context),
                    icon: const Icon(Icons.visibility_rounded, size: 14),
                    label: const Text('View Evidence'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.brand,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle_rounded, color: AppColors.emerald500, size: 24),
                        onPressed: () => ref.read(taskProvider.notifier).updateStatus(task.id, TaskStatus.approved),
                        tooltip: 'Approve',
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel_rounded, color: AppColors.red500, size: 24),
                        onPressed: () => ref.read(taskProvider.notifier).updateStatus(task.id, TaskStatus.rejected),
                        tooltip: 'Reject',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    AppModal.show(
      context: context,
      title: 'Task Overview',
      child: TaskDetailsModal(task: task),
    );
  }
}

class _TaskStatusChip extends StatelessWidget {
  const _TaskStatusChip({required this.status});
  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      TaskStatus.pending      => AppColors.amber500,
      TaskStatus.submitted    => AppColors.blue500,
      TaskStatus.waitingAdmin => AppColors.brand,
      TaskStatus.approved     => AppColors.emerald500,
      TaskStatus.rejected      => AppColors.red500,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(status.displayName.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
    );
  }
}

class _AddTaskForm extends StatefulWidget {
  const _AddTaskForm({required this.onSubmit, required this.member});
  final Function(TaskEntity) onSubmit;
  final MemberEntity member;

  @override
  State<_AddTaskForm> createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<_AddTaskForm> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  DateTime deadline = DateTime.now().add(const Duration(days: 7));

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Task Title'),
            onSaved: (val) => title = val ?? '',
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Deadline'),
            subtitle: Text(AppFormatters.displayDate(AppFormatters.toIso(deadline))),
            trailing: const Icon(Icons.calendar_month_rounded),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: deadline,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) setState(() => deadline = picked);
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                _formKey.currentState?.save();
                widget.onSubmit(TaskEntity(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: title,
                  description: '',
                  deadline: AppFormatters.toIso(deadline),
                  assignedToId: widget.member.id,
                  assignedToName: widget.member.name,
                  assignedToEmail: widget.member.email,
                  assignedToType: AssigneeType.member,
                  status: TaskStatus.pending,
                  requiresUpload: false,
                  createdAt: AppFormatters.today(),
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brand,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Create Task'),
          ),
        ],
      ),
    );
  }
}