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

class VolunteersTab extends ConsumerStatefulWidget {
  const VolunteersTab({super.key, required this.isSuperAdmin});
  final bool isSuperAdmin;

  @override
  ConsumerState<VolunteersTab> createState() => _VolunteersTabState();
}

class _VolunteersTabState extends ConsumerState<VolunteersTab> {
  String _searchQuery = '';
  PersonStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final volunteersAsync = ref.watch(volunteerProvider);

    return Column(
      children: [
        SectionHeader(
          title: 'Volunteers',
          subtitle: 'Manage NGO volunteers and their tasks',
          actions: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showAddVolunteerModal(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Volunteer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue600,
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
        const SizedBox(height: 16),
        Expanded(
          child: volunteersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (volunteers) {
              final filtered = volunteers.where((v) {
                final matchesSearch = v.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                                     v.email.toLowerCase().contains(_searchQuery.toLowerCase());
                final matchesStatus = _statusFilter == null || v.status == _statusFilter;
                return matchesSearch && matchesStatus;
              }).toList();

              if (filtered.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_search_rounded, size: 48, color: AppColors.slate300),
                      SizedBox(height: 12),
                      Text('No volunteers found', style: TextStyle(color: AppColors.slate500)),
                    ],
                  ),
                );
              }

              return ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final v = filtered[index];
                  return _VolunteerCard(
                    volunteer: v,
                    onTap: () => _showVolunteerDetails(context, v),
                  );
                },
              );
            },
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
            decoration: InputDecoration(
              hintText: 'Search by name or email...',
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
              icon: const Icon(Icons.filter_list_rounded, size: 18),
              onChanged: (val) => setState(() => _statusFilter = val),
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
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

  void _showAddVolunteerModal(BuildContext context) {
    AppModal.show(
      context: context,
      title: 'Add New Volunteer',
      size: ModalSize.medium,
      child: _AddVolunteerForm(
        onSubmit: (v) {
          ref.read(volunteerProvider.notifier).add(v);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showVolunteerDetails(BuildContext context, VolunteerEntity v) {
    AppModal.show(
      context: context,
      title: 'Volunteer Profile',
      size: ModalSize.large,
      child: _VolunteerDetailsContent(volunteer: v),
    );
  }
}

class _VolunteerCard extends StatelessWidget {
  const _VolunteerCard({required this.volunteer, required this.onTap});
  final VolunteerEntity volunteer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          AppAvatar(
            initials: AppFormatters.initials(volunteer.name),
            size: AvatarSize.large,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  volunteer.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Text(
                  volunteer.email,
                  style: const TextStyle(color: AppColors.slate500, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.shield_rounded, size: 14, color: AppColors.slate400),
                    const SizedBox(width: 4),
                    Text(
                      volunteer.assignedAdmin,
                      style: const TextStyle(color: AppColors.slate400, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppBadge(
            label: volunteer.status.name.toUpperCase(),
            color: volunteer.status == PersonStatus.active ? AppColors.emerald500 : AppColors.slate400,
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.slate300),
        ],
      ),
    );
  }
}

class _AddVolunteerForm extends StatefulWidget {
  const _AddVolunteerForm({required this.onSubmit});
  final Function(VolunteerEntity) onSubmit;

  @override
  State<_AddVolunteerForm> createState() => _AddVolunteerFormState();
}

class _AddVolunteerFormState extends State<_AddVolunteerForm> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String phone = '';
  String address = '';
  String skills = '';
  String assignedAdmin = '';

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
            decoration: const InputDecoration(labelText: 'Phone Number'),
            onSaved: (val) => phone = val ?? '',
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Address'),
            onSaved: (val) => address = val ?? '',
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Skills (comma separated)'),
            onSaved: (val) => skills = val ?? '',
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Assign Admin'),
            onSaved: (val) => assignedAdmin = val ?? '',
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                _formKey.currentState?.save();
                widget.onSubmit(VolunteerEntity(
                  id: DateTime.now().millisecondsSinceEpoch,
                  name: name,
                  email: email,
                  phone: phone,
                  address: address,
                  joinDate: AppFormatters.today(),
                  status: PersonStatus.active,
                  assignedAdmin: assignedAdmin,
                  taskIds: const [],
                  tenure: '0 months',
                  skills: skills.split(',').map((e) => e.trim()).toList(),
                  avatar: '',
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Add Volunteer'),
          ),
        ],
      ),
    );
  }
}

class _VolunteerDetailsContent extends ConsumerWidget {
  const _VolunteerDetailsContent({required this.volunteer});
  final VolunteerEntity volunteer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppAvatar(
              initials: AppFormatters.initials(volunteer.name),
              size: AvatarSize.xlarge,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    volunteer.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    volunteer.email,
                    style: const TextStyle(color: AppColors.slate500),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: volunteer.skills.map((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.blue600.withOpacity(0.2) : AppColors.blue50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.blue100),
                      ),
                      child: Text(
                        s,
                        style: const TextStyle(fontSize: 11, color: AppColors.blue600, fontWeight: FontWeight.w600),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const Text(
          'Profile Information',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            children: [
              _InfoRow(label: 'Phone', value: volunteer.phone, icon: Icons.phone_rounded),
              const Divider(height: 24),
              _InfoRow(label: 'Address', value: volunteer.address, icon: Icons.location_on_rounded),
              const Divider(height: 24),
              _InfoRow(label: 'Join Date', value: AppFormatters.displayDate(volunteer.joinDate), icon: Icons.calendar_today_rounded),
              const Divider(height: 24),
              _InfoRow(label: 'Assigned Admin', value: volunteer.assignedAdmin, icon: Icons.shield_rounded),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Assigned Tasks',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            TextButton.icon(
              onPressed: () => _showAddTaskModal(context, ref),
              icon: const Icon(Icons.add_task_rounded, size: 18),
              label: const Text('Add Task'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        tasksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error loading tasks: $e'),
          data: (tasks) {
            final volunteerTasks = tasks.where((t) => t.assignedToId == volunteer.id && t.assignedToType == AssigneeType.volunteer).toList();
            if (volunteerTasks.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('No tasks assigned yet', style: TextStyle(color: AppColors.slate400)),
                ),
              );
            }
            return Column(
              children: volunteerTasks.map((t) => _TaskItem(task: t)).toList(),
            );
          },
        ),
      ],
    );
  }

  void _showAddTaskModal(BuildContext context, WidgetRef ref) {
    AppModal.show(
      context: context,
      title: 'Assign New Task',
      child: _AddTaskForm(
        onSubmit: (task) {
          ref.read(taskProvider.notifier).add(task);
          Navigator.pop(context);
        },
        volunteer: volunteer,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.slate400),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.slate400)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppColors.slate800 : AppColors.slate50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
              _TaskStatusBadge(status: task.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            task.description,
            style: const TextStyle(fontSize: 12, color: AppColors.slate500),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 14, color: AppColors.amber600),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${AppFormatters.displayDate(task.deadline)}',
                    style: const TextStyle(fontSize: 11, color: AppColors.slate500),
                  ),
                ],
              ),
              if (task.status == TaskStatus.submitted)
                Row(
                  children: [
                    if (task.uploadedImage != null)
                      TextButton(
                        onPressed: () => _showImagePreview(context, task.uploadedImage!),
                        child: const Text('View Image', style: TextStyle(fontSize: 11)),
                      ),
                    IconButton(
                      icon: const Icon(Icons.check_circle_rounded, color: AppColors.emerald500, size: 20),
                      onPressed: () => ref.read(taskProvider.notifier).updateStatus(task.id, TaskStatus.approved),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel_rounded, color: AppColors.red500, size: 20),
                      onPressed: () => ref.read(taskProvider.notifier).updateStatus(task.id, TaskStatus.rejected),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Task Evidence'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.network(
                imageUrl,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Text('Image path: mock_image.jpg'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskStatusBadge extends StatelessWidget {
  const _TaskStatusBadge({required this.status});
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
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status.displayName.toUpperCase(),
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

class _AddTaskForm extends StatefulWidget {
  const _AddTaskForm({required this.onSubmit, required this.volunteer});
  final Function(TaskEntity) onSubmit;
  final VolunteerEntity volunteer;

  @override
  State<_AddTaskForm> createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<_AddTaskForm> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  DateTime deadline = DateTime.now().add(const Duration(days: 7));
  bool requiresUpload = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Task Title'),
            onSaved: (val) => title = val ?? '',
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 3,
            onSaved: (val) => description = val ?? '',
          ),
          const SizedBox(height: 12),
          ListTile(
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
          SwitchListTile(
            title: const Text('Requires Image Upload'),
            value: requiresUpload,
            onChanged: (val) => setState(() => requiresUpload = val),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                _formKey.currentState?.save();
                widget.onSubmit(TaskEntity(
                  id: DateTime.now().millisecondsSinceEpoch,
                  title: title,
                  description: description,
                  deadline: AppFormatters.toIso(deadline),
                  assignedToId: widget.volunteer.id,
                  assignedToName: widget.volunteer.name,
                  assignedToType: AssigneeType.volunteer,
                  status: TaskStatus.pending,
                  requiresUpload: requiresUpload,
                  createdAt: AppFormatters.today(),
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Assign Task'),
          ),
        ],
      ),
    );
  }
}