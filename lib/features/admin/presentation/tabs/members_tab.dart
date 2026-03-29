import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/core/widgets/app_avatar.dart';
import 'package:ngo_volunteer_management/core/widgets/app_badge.dart';
import 'package:ngo_volunteer_management/core/widgets/app_card.dart';
import 'package:ngo_volunteer_management/core/widgets/app_modal.dart';
import 'package:ngo_volunteer_management/core/widgets/section_header.dart';
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

    return membersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (members) {
        final filtered = members.where((m) {
          final matchesSearch = m.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                                m.email.toLowerCase().contains(_searchQuery.toLowerCase());
          final matchesStatus = _statusFilter == null || m.status == _statusFilter;
          return matchesSearch && matchesStatus;
        }).toList();

        return ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            SectionHeader(
              title: 'Members',
              subtitle: 'Manage NGO members, memberships and renewals',
              actions: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showAddMemberModal(context),
                    icon: const Icon(Icons.person_add_rounded, size: 18),
                    label: const Text('Add Member'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildFilters(),
            const SizedBox(height: 24),

            if (filtered.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.group_off_rounded, size: 48, color: AppColors.slate300),
                      SizedBox(height: 12),
                      Text('No members found', style: TextStyle(color: AppColors.slate500)),
                    ],
                  ),
                ),
              )
            else
              ...filtered.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MemberCard(
                  member: m,
                  onTap: () => _showMemberDetails(context, m),
                ),
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
              hintText: 'Search members...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              filled: true,
              fillColor: isDark ? AppColors.slate800 : AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: isDark ? AppColors.slate700 : AppColors.slate200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: isDark ? AppColors.slate700 : AppColors.slate200),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        onSubmit: (m) {
          ref.read(memberProvider.notifier).add(m);
          Navigator.pop(context);
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
              children: [
                Text(
                  member.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Text(
                  member.email,
                  style: const TextStyle(color: AppColors.slate500, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    AppBadge(
                      label: member.membershipType.displayLabel,
                      color: member.membershipType == MembershipType.eightyG ? AppColors.primary : AppColors.purple500,
                    ),
                    const SizedBox(width: 8),
                    if (isExpiringSoon)
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.amber600),
                          const SizedBox(width: 4),
                          Text(
                            'Renews in $daysToRenewal days',
                            style: const TextStyle(color: AppColors.amber600, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppBadge(
                label: member.status.name.toUpperCase(),
                color: member.status == PersonStatus.active ? AppColors.emerald500 : AppColors.slate400,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    member.isPaid ? Icons.check_circle_rounded : Icons.pending_rounded,
                    size: 14,
                    color: member.isPaid ? AppColors.emerald500 : AppColors.amber500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    member.isPaid ? 'Paid' : 'Unpaid',
                    style: TextStyle(
                      fontSize: 11,
                      color: member.isPaid ? AppColors.emerald600 : AppColors.amber600,
                      fontWeight: FontWeight.w600,
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
  final Function(MemberEntity) onSubmit;

  @override
  State<_AddMemberForm> createState() => _AddMemberFormState();
}

class _AddMemberFormState extends State<_AddMemberForm> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String phone = '';
  String address = '';
  MembershipType membershipType = MembershipType.nonEightyG;
  DateTime renewalDate = DateTime.now().add(const Duration(days: 365));

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                _formKey.currentState?.save();
                widget.onSubmit(MemberEntity(
                  id: DateTime.now().millisecondsSinceEpoch,
                  name: name,
                  email: email,
                  phone: phone,
                  address: address,
                  joinDate: AppFormatters.today(),
                  renewalDate: AppFormatters.toIso(renewalDate),
                  status: PersonStatus.active,
                  membershipType: membershipType,
                  taskIds: const [],
                  isPaid: false,
                  avatar: '',
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emerald600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Create Membership'),
          ),
        ],
      ),
    );
  }
}

class _MemberDetailsContent extends ConsumerWidget {
  const _MemberDetailsContent({required this.member});
  final MemberEntity member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskProvider);
    final daysToRenewal = AppFormatters.daysUntil(member.renewalDate);

    return SingleChildScrollView(
      child: Column(
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
                children: memberTasks.map((t) => _TaskTile(task: t)).toList(),
              );
            },
          ),
        ],
      ),
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

class _TaskTile extends ConsumerWidget {
  const _TaskTile({required this.task});
  final TaskEntity task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                Text(task.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text('Deadline: ${AppFormatters.displayDate(task.deadline)}', style: const TextStyle(fontSize: 11, color: AppColors.slate500)),
              ],
            ),
          ),
          _TaskStatusChip(status: task.status),
          if (task.status == TaskStatus.submitted) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.check_rounded, color: AppColors.emerald500, size: 20),
              onPressed: () => ref.read(taskProvider.notifier).updateStatus(task.id, TaskStatus.approved),
              constraints: const BoxConstraints(),
              style: IconButton.styleFrom(padding: EdgeInsets.zero),
            ),
          ]
        ],
      ),
    );
  }
}

class _TaskStatusChip extends StatelessWidget {
  const _TaskStatusChip({required this.status});
  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      TaskStatus.pending => AppColors.amber500,
      TaskStatus.submitted => AppColors.blue500,
      TaskStatus.approved => AppColors.emerald500,
      TaskStatus.rejected => AppColors.red500,
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
                  id: DateTime.now().millisecondsSinceEpoch,
                  title: title,
                  description: '',
                  deadline: AppFormatters.toIso(deadline),
                  assignedToId: widget.member.id,
                  assignedToName: widget.member.name,
                  assignedToType: AssigneeType.member,
                  status: TaskStatus.pending,
                  requiresUpload: false,
                  createdAt: AppFormatters.today(),
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue600,
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