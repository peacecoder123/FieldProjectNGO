import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/core/widgets/app_card.dart';
import 'package:ngo_volunteer_management/core/widgets/section_header.dart';
import 'package:ngo_volunteer_management/domain/entities/document_request.entity.dart';
import 'package:ngo_volunteer_management/shared/providers/feature_providers.dart';
import 'package:ngo_volunteer_management/shared/providers/app_providers.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';
import 'package:ngo_volunteer_management/features/documents/services/pdf_generator_service.dart';
import 'package:printing/printing.dart';

class DocumentApprovalsList extends ConsumerWidget {
  const DocumentApprovalsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(documentRequestProvider);
    final currentUser = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return requestsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (requests) {
        final pending = requests.where((r) => r.status == DocumentRequestStatus.pending).toList();
        final past = requests.where((r) => r.status != DocumentRequestStatus.pending).toList();

        if (requests.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Text('No certificate requests', style: TextStyle(color: isDark ? AppColors.slate400 : AppColors.slate500)),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pending.isNotEmpty) ...[
              const Text('Pending Approvals', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.slate700)),
              const SizedBox(height: 12),
              ...pending.map((req) => _RequestCard(req: req, isDark: isDark, currentUser: currentUser)),
              const SizedBox(height: 24),
            ],
            
            const Text('Past Requests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.slate700)),
            const SizedBox(height: 12),
            if (past.isEmpty) const Text('No past requests.', style: TextStyle(color: AppColors.slate500)),
            ...past.map((req) => _RequestCard(req: req, isDark: isDark, currentUser: currentUser)),
          ],
        );
      },
    );
  }
}

class _RequestCard extends ConsumerWidget {
  const _RequestCard({required this.req, required this.isDark, required this.currentUser});
  
  final DocumentRequestEntity req;
  final bool isDark;
  final dynamic currentUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color statusColor;
    IconData statusIcon;
    
    switch (req.status) {
      case DocumentRequestStatus.pending:
        statusColor = AppColors.amber500;
        statusIcon = Icons.pending_actions_rounded;
        break;
      case DocumentRequestStatus.approved:
        statusColor = AppColors.emerald500;
        statusIcon = Icons.check_circle_rounded;
        break;
      case DocumentRequestStatus.rejected:
        statusColor = AppColors.red500;
        statusIcon = Icons.cancel_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${req.documentType.displayLabel} Request', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(
                        'Requested by ${req.userName} • ${AppFormatters.displayDate(req.requestedAt.toIso8601String())}',
                        style: const TextStyle(color: AppColors.slate500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    req.status.name.toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            
            if (req.status == DocumentRequestStatus.pending && (currentUser?.role == UserRole.admin || currentUser?.role == UserRole.superAdmin)) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      ref.read(documentRequestProvider.notifier).reject(req.id);
                    },
                    style: TextButton.styleFrom(foregroundColor: AppColors.red600),
                    child: const Text('Reject'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => _CertificateDetailsModal(
                          initialName: req.userName,
                          initialCertNo: req.certificateNo ?? 'JF/CERT/${DateTime.now().year}/${req.id.substring(0, 6).toUpperCase()}',
                          initialDate: DateTime.now(),
                          userId: req.userId,
                          reqId: req.id,
                          approverName: currentUser?.name ?? 'Admin',
                          isApprovalFlow: true,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.brand),
                    child: const Text('Approve & Generate'),
                  ),
                ],
              )
            ],
            
            if (req.status == DocumentRequestStatus.approved) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                   Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('CERTIFICATE NUMBER', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1, color: AppColors.slate400)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.slate700 : AppColors.slate50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            req.certificateNo ?? 'PENDING',
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'Courier',
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.slate300 : AppColors.slate600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => _CertificateDetailsModal(
                          initialName: req.userName,
                          initialCertNo: req.certificateNo ?? '',
                          initialDate: req.approvedAt ?? DateTime.now(),
                          userId: req.userId,
                        ),
                      );
                    },
                    icon: Icon(Icons.download_for_offline_rounded, color: isDark ? AppColors.blue400 : AppColors.blue600),
                    tooltip: 'Download / Print',
                    style: IconButton.styleFrom(
                      backgroundColor: isDark ? AppColors.blue600.withValues(alpha: 0.1) : AppColors.blue50,
                      padding: const EdgeInsets.all(10),
                    ),
                  ),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }
}

// ── Certificate Details Modal ── ─────────────────────────────────────────────
class _CertificateDetailsModal extends ConsumerStatefulWidget {
  const _CertificateDetailsModal({
    required this.initialName,
    required this.initialCertNo,
    required this.initialDate,
    required this.userId,
    this.reqId,
    this.approverName,
    this.isApprovalFlow = false,
  });

  final String initialName;
  final String initialCertNo;
  final DateTime initialDate;
  final String userId;
  final String? reqId;
  final String? approverName;
  final bool isApprovalFlow;

  @override
  ConsumerState<_CertificateDetailsModal> createState() => _CertificateDetailsModalState();
}

class _CertificateDetailsModalState extends ConsumerState<_CertificateDetailsModal> {
  final _formKey = GlobalKey<FormState>();
  bool _isGenerating = false;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _certNoCtrl;
  late final TextEditingController _orgCtrl;
  late final TextEditingController _positionCtrl;
  late DateTime _date;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _nameCtrl     = TextEditingController(text: widget.initialName);
    _certNoCtrl   = TextEditingController(text: widget.initialCertNo);
    _orgCtrl      = TextEditingController(text: 'Jayashree Foundation');
    _positionCtrl = TextEditingController(text: 'Social Welfare & Community Development');
    _date         = widget.initialDate;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _certNoCtrl.dispose();
    _orgCtrl.dispose();
    _positionCtrl.dispose();
    super.dispose();
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<DateTime?> _pickDate(DateTime initial) => showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(2015),
        lastDate: DateTime(2035),
      );

  Future<void> _generate() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_fromDate == null || _toDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select internship From and To dates.')),
      );
      return;
    }
    setState(() => _isGenerating = true);
    try {
      final name   = _nameCtrl.text.trim();
      final certNo = _certNoCtrl.text.trim();
      final org    = _orgCtrl.text.trim();
      final area   = _positionCtrl.text.trim();
      final duration = '${_fmt(_fromDate!)} to ${_fmt(_toDate!)}';

      // 1. Approve the request first (only in approval flow) — persist all details
      if (widget.isApprovalFlow && widget.reqId != null) {
        await ref.read(documentRequestProvider.notifier).approve(
          widget.reqId!,
          approvedBy: widget.approverName ?? 'Admin',
          certificateNo: certNo,
          organisation: org,
          internshipArea: area,
          internshipDuration: duration,
        );
      }

      // 2. Generate PDF with entered details
      final pdfData = await PdfGeneratorService.generateCertificatePdf(
        certificateNo: certNo,
        date: _date,
        recipientName: name,
        organisation: org,
        internshipArea: area,
        internshipDuration: duration,
      );

      // 3. Open print/preview window
      await Printing.layoutPdf(onLayout: (format) => pdfData);

      // 4. Notify member via Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('notifications')
          .add({
        'title': 'Your Internship Certificate is Ready',
        'body':
            'Your internship completion certificate (No. $certNo) from $org '
            'for the period $duration has been generated.',
        'type': 'certificate_ready',
        'certNo': certNo,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isApprovalFlow
                ? 'Request approved, certificate generated & member notified!'
                : 'Certificate generated & member notified!'),
            backgroundColor: AppColors.emerald500,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.red500),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.slate800 : Colors.white;
    final border  = isDark ? AppColors.slate700 : AppColors.slate200;

    return Dialog(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ──
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.emerald500.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.workspace_premium_rounded,
                          color: AppColors.emerald500, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isApprovalFlow
                                ? 'Approve & Generate Certificate'
                                : 'Internship Certificate',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.white : AppColors.slate900,
                            ),
                          ),
                          Text(
                            'Fill in the details to generate the PDF',
                            style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.slate400 : AppColors.slate500),
                          ),
                        ],
                      ),
                    ),
                    if (!widget.isApprovalFlow)
                      IconButton(
                        icon: Icon(Icons.close_rounded,
                            color: isDark ? AppColors.slate400 : AppColors.slate500),
                        onPressed: () => Navigator.pop(context),
                      ),
                  ],
                ),

                const SizedBox(height: 20),
                Divider(color: border, height: 1),
                const SizedBox(height: 20),

                // ── Recipient Name ──
                _buildField(
                  controller: _nameCtrl,
                  label: 'Recipient Name',
                  hint: 'Full name of the intern',
                  icon: Icons.person_rounded,
                  isDark: isDark,
                ),
                const SizedBox(height: 14),

                // ── Certificate Number (frozen in approval flow) + Issue Date ──
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _certNoCtrl,
                        readOnly: widget.isApprovalFlow,
                        style: TextStyle(
                          fontSize: 13,
                          color: widget.isApprovalFlow
                              ? (isDark ? AppColors.slate400 : AppColors.slate500)
                              : (isDark ? AppColors.white : AppColors.slate900),
                          fontFamily: 'Courier',
                        ),
                        decoration: _decoration(
                          label: 'Certificate No.',
                          icon: Icons.tag_rounded,
                          isDark: isDark,
                        ).copyWith(
                          suffixIcon: widget.isApprovalFlow
                              ? const Icon(Icons.lock_rounded, size: 14, color: AppColors.slate400)
                              : null,
                          fillColor: widget.isApprovalFlow
                              ? (isDark
                                  ? AppColors.slate700.withValues(alpha: 0.3)
                                  : AppColors.slate100)
                              : null,
                        ),
                        validator: (v) =>
                            (v?.trim().isEmpty ?? true) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final p = await _pickDate(_date);
                          if (p != null) setState(() => _date = p);
                        },
                        child: InputDecorator(
                          decoration: _decoration(
                              label: 'Issue Date',
                              icon: Icons.calendar_today_rounded,
                              isDark: isDark),
                          child: Text(
                            _fmt(_date),
                            style: TextStyle(
                                fontSize: 14,
                                color: isDark ? AppColors.white : AppColors.slate900),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Organisation ──
                _buildField(
                  controller: _orgCtrl,
                  label: 'Organisation',
                  hint: 'Jayashree Foundation',
                  icon: Icons.apartment_rounded,
                  isDark: isDark,
                ),
                const SizedBox(height: 14),

                // ── Internship Area ──
                _buildField(
                  controller: _positionCtrl,
                  label: 'Internship Area / Position',
                  hint: 'e.g. Community Development',
                  icon: Icons.work_outline_rounded,
                  isDark: isDark,
                ),
                const SizedBox(height: 14),

                // ── Internship Duration (From – To) ──
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.slate700.withValues(alpha: 0.35)
                        : AppColors.slate50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: isDark ? AppColors.slate600 : AppColors.slate200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.date_range_rounded,
                              size: 16,
                              color: isDark ? AppColors.slate400 : AppColors.slate500),
                          const SizedBox(width: 6),
                          Text(
                            'Internship Duration',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.slate300 : AppColors.slate700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final p = await _pickDate(
                                    _fromDate ?? DateTime.now().subtract(const Duration(days: 180)));
                                if (p != null) setState(() => _fromDate = p);
                              },
                              child: InputDecorator(
                                decoration: _decoration(
                                    label: 'From Date',
                                    icon: Icons.calendar_month_rounded,
                                    isDark: isDark),
                                child: Text(
                                  _fromDate != null ? _fmt(_fromDate!) : 'Select date',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: _fromDate != null
                                          ? (isDark ? AppColors.white : AppColors.slate900)
                                          : (isDark ? AppColors.slate500 : AppColors.slate400)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final p = await _pickDate(_toDate ?? DateTime.now());
                                if (p != null) setState(() => _toDate = p);
                              },
                              child: InputDecorator(
                                decoration: _decoration(
                                    label: 'To Date',
                                    icon: Icons.calendar_month_rounded,
                                    isDark: isDark),
                                child: Text(
                                  _toDate != null ? _fmt(_toDate!) : 'Select date',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: _toDate != null
                                          ? (isDark ? AppColors.white : AppColors.slate900)
                                          : (isDark ? AppColors.slate500 : AppColors.slate400)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── Info note ──
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.emerald500.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.emerald500.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 16, color: AppColors.emerald500),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.isApprovalFlow
                              ? 'This will approve the request, generate the certificate PDF, and notify the member.'
                              : 'The certificate will open in a print/preview window where you can save it as PDF.',
                          style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.emerald400 : AppColors.emerald700),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Action Buttons ──
                if (widget.isApprovalFlow)
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? AppColors.slate400 : AppColors.slate600,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isGenerating ? null : _generate,
                          icon: _isGenerating
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.picture_as_pdf_rounded, size: 18),
                          label: Text(_isGenerating
                              ? 'Approving & Generating…'
                              : 'Approve & Generate PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brand,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generate,
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.picture_as_pdf_rounded, size: 18),
                    label:
                        Text(_isGenerating ? 'Generating…' : 'Generate Certificate PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(
          fontSize: 14, color: isDark ? AppColors.white : AppColors.slate900),
      decoration: _decoration(label: label, hint: hint, icon: icon, isDark: isDark),
      validator: (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null,
    );
  }

  InputDecoration _decoration({
    required String label,
    String? hint,
    required IconData icon,
    required bool isDark,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon:
          Icon(icon, size: 18, color: isDark ? AppColors.slate400 : AppColors.slate500),
      filled: true,
      fillColor:
          isDark ? AppColors.slate700.withValues(alpha: 0.5) : AppColors.slate50,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: isDark ? AppColors.slate600 : AppColors.slate200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: isDark ? AppColors.slate600 : AppColors.slate200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.emerald500, width: 1.5),
      ),
    );
  }
}
