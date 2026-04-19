import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/domain/entities/donation.entity.dart';
import 'package:ngo_volunteer_management/services/payment/razorpay_config.dart';
import 'package:ngo_volunteer_management/shared/providers/payment_provider.dart';
import 'package:ngo_volunteer_management/shared/providers/feature_providers.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';
import 'package:ngo_volunteer_management/services/document_generation/document_generator.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:ngo_volunteer_management/features/documents/services/pdf_generator_service.dart';

/// A full-featured donation dialog that collects donor info and triggers
/// Razorpay checkout. Can be shown via [DonationDialog.show].
class DonationDialog extends ConsumerStatefulWidget {
  const DonationDialog({super.key});

  /// Convenience method to open the dialog.
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const DonationDialog(),
    );
  }

  @override
  ConsumerState<DonationDialog> createState() => _DonationDialogState();
}

class _DonationDialogState extends ConsumerState<DonationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _donorName = '';
  String _email = '';
  String _phone = '';
  bool _is80G = false;
  int? _selectedPreset;
  bool _isProcessing = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  int get _amount => int.tryParse(_amountController.text) ?? 0;

  void _selectPreset(int amount) {
    setState(() {
      _selectedPreset = amount;
      _amountController.text = amount.toString();
    });
  }

  Future<void> _handleDonate() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState?.save();

    if (_amount < RazorpayConfig.minimumDonationAmount) {
      _showSnackBar('Minimum donation is ₹${RazorpayConfig.minimumDonationAmount}');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final outcome = await ref.read(paymentStateProvider.notifier).processDonation(
        amount: _amount,
        donorName: _donorName,
        email: _email,
        phone: _phone,
        purpose: 'General Donation',
      );

      if (!mounted) return;

      if (outcome.isSuccess) {
        // Save donation to Firestore
        final donationId = DateTime.now().millisecondsSinceEpoch.toString();
        final donation = DonationEntity(
          id: donationId,
          donorName: _donorName,
          amount: _amount,
          date: AppFormatters.today(),
          type: DonationType.online,
          receiptGenerated: true,
          receiptNumber: 'REC-${DateTime.now().year}-$donationId',
          purpose: 'General Donation',
          is80G: _is80G,
          razorpayPaymentId: outcome.paymentId,
          razorpayOrderId: outcome.orderId,
          paymentStatus: PaymentStatus.success,
          donorEmail: _email,
          donorPhone: _phone,
        );

        await ref.read(donationProvider.notifier).add(donation);

        if (!mounted) return;
        Navigator.of(context).pop();
        _showSuccessDialog(donation);
      } else {
        setState(() => _isProcessing = false);
        _showSnackBar(outcome.errorMessage ?? 'Payment failed. Please try again.');
      }
    } catch (e, st) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      
      // Truncate stack trace if present in error message
      String errMsg = e.toString();
      if (errMsg.length > 100) {
        errMsg = errMsg.substring(0, 100) + '...';
      }
      debugPrint('Donation processing error: $e\n$st');
      _showSnackBar('Error processing payment: $errMsg');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _showSuccessDialog(DonationEntity donation) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.emerald100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: AppColors.emerald600, size: 48),
            ),
            const SizedBox(height: 20),
            const Text(
              'Thank You!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Your donation of ₹${donation.amount} has been received successfully.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.slate500, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Transaction ID: ${donation.razorpayPaymentId}',
              style: const TextStyle(color: AppColors.slate400, fontSize: 12),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _downloadReceipt(donation);
                },
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Download Receipt'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.slate600,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadReceipt(DonationEntity donation) async {
    try {
      // Generate the professional PDF bytes using our refined service
      final bytes = await PdfGeneratorService.generateReceiptPdf(
        receiptNo: donation.receiptNumber ?? 'REC-PENDING',
        date: DateTime.parse(donation.date),
        donorName: donation.donorName,
        amount: donation.amount.toDouble(),
        paymentMode: donation.type.name,
        purpose: donation.purpose,
        is80G: donation.is80G,
        contactNo: donation.donorPhone,
        email: donation.donorEmail,
      );

      await Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name: 'Receipt_${donation.receiptNumber}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not generate receipt: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 500 ? 460.0 : screenWidth * 0.92;

    return Dialog(
      backgroundColor: isDark ? AppColors.slate800 : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: dialogWidth,
        constraints: const BoxConstraints(maxHeight: 620),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header ──────────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.blue600, AppColors.indigo600],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Make a Donation',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.slate900,
                            ),
                          ),
                          Text(
                            'Support Jayashree Foundation',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.slate400 : AppColors.slate500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDark ? AppColors.slate400 : AppColors.slate500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Preset amounts ──────────────────────────────────────
                Text(
                  'Choose Amount',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.slate300 : AppColors.slate700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: RazorpayConfig.presetDonationAmounts.map((amt) {
                    final isSelected = _selectedPreset == amt;
                    return ChoiceChip(
                      label: Text('₹$amt'),
                      selected: isSelected,
                      onSelected: (_) => _selectPreset(amt),
                      selectedColor: AppColors.blue600,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : (isDark ? AppColors.slate300 : AppColors.slate700),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      backgroundColor: isDark ? AppColors.slate700 : AppColors.slate100,
                      side: BorderSide(
                        color: isSelected ? AppColors.blue600 : (isDark ? AppColors.slate600 : AppColors.slate200),
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // ── Custom amount ────────────────────────────────────────
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Amount (₹)',
                    prefixText: '₹ ',
                    filled: true,
                    fillColor: isDark ? AppColors.slate700 : AppColors.slate50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: isDark ? AppColors.slate600 : AppColors.slate200),
                    ),
                  ),
                  onChanged: (_) => setState(() => _selectedPreset = null),
                  validator: (v) {
                    final val = int.tryParse(v ?? '') ?? 0;
                    if (val < RazorpayConfig.minimumDonationAmount) {
                      return 'Minimum ₹${RazorpayConfig.minimumDonationAmount}';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // ── Donor name ───────────────────────────────────────────
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Your Name',
                    prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                    filled: true,
                    fillColor: isDark ? AppColors.slate700 : AppColors.slate50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: isDark ? AppColors.slate600 : AppColors.slate200),
                    ),
                  ),
                  onSaved: (v) => _donorName = v ?? '',
                  validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                ),
                const SizedBox(height: 14),

                // ── Email ────────────────────────────────────────────────
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20),
                    filled: true,
                    fillColor: isDark ? AppColors.slate700 : AppColors.slate50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: isDark ? AppColors.slate600 : AppColors.slate200),
                    ),
                  ),
                  onSaved: (v) => _email = v ?? '',
                  validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                ),
                const SizedBox(height: 14),

                // ── Phone ────────────────────────────────────────────────
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                    filled: true,
                    fillColor: isDark ? AppColors.slate700 : AppColors.slate50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: isDark ? AppColors.slate600 : AppColors.slate200),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                  onSaved: (v) => _phone = v ?? '',
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.length != 10) return 'Must be exactly 10 digits';
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // ── 80G checkbox ─────────────────────────────────────────
                CheckboxListTile(
                  title: Text(
                    '80G Tax Benefit Receipt',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.slate300 : AppColors.slate700,
                    ),
                  ),
                  subtitle: Text(
                    'Get tax deduction under Section 80G',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.slate500 : AppColors.slate400,
                    ),
                  ),
                  value: _is80G,
                  onChanged: (v) => setState(() => _is80G = v ?? false),
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.blue600,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                const SizedBox(height: 20),

                // ── Pay button ───────────────────────────────────────────
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _handleDonate,
                    icon: _isProcessing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.lock_rounded, size: 18),
                    label: Text(
                      _isProcessing ? 'Processing...' : 'Donate Securely',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue600,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.blue400,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Powered by ───────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shield_rounded, size: 14, color: isDark ? AppColors.slate500 : AppColors.slate400),
                    const SizedBox(width: 4),
                    Text(
                      'Secured by Razorpay',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.slate500 : AppColors.slate400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
