import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../controllers/payment_settings_controller.dart';

class PaymentSettingsScreen extends ConsumerStatefulWidget {
  const PaymentSettingsScreen({super.key});

  @override
  ConsumerState<PaymentSettingsScreen> createState() =>
      _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState extends ConsumerState<PaymentSettingsScreen> {
  final _newUpiController = TextEditingController();
  final _payeeNameController = TextEditingController();
  bool _isEditingPayee = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(paymentSettingsProvider);
    _payeeNameController.text = settings.payeeName;
  }

  @override
  void dispose() {
    _newUpiController.dispose();
    _payeeNameController.dispose();
    super.dispose();
  }

  void _addUpiId() {
    final text = _newUpiController.text.trim();
    if (text.isEmpty) return;
    if (!text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid UPI ID (e.g. name@upi)'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    ref.read(paymentSettingsProvider.notifier).addUpiId(text);
    _newUpiController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added and selected "$text" as active UPI ID'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _savePayeeName() {
    final text = _payeeNameController.text.trim();
    if (text.isNotEmpty) {
      ref.read(paymentSettingsProvider.notifier).setPayeeName(text);
      setState(() => _isEditingPayee = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Business/Payee name updated successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _uploadQrImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    final file = result?.files.single;
    final bytes = file?.bytes;
    if (file == null || bytes == null || !mounted) return;

    try {
      final extension = file.extension?.toLowerCase() ?? 'png';
      final contentType = extension == 'jpg' || extension == 'jpeg'
          ? 'image/jpeg'
          : 'image/$extension';
      await ref
          .read(paymentSettingsProvider.notifier)
          .uploadCustomQr(
            bytes: bytes,
            fileName: file.name,
            contentType: contentType,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('UPI QR image uploaded.')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to upload the UPI QR image.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentSettings = ref.watch(paymentSettingsProvider);
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Payment Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // Live QR Preview Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF232936), const Color(0xFF191D26)]
                    : [const Color(0xFFF4F6FD), const Color(0xFFEBEFFC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.qr_code_2_rounded,
                            size: 16,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Active Payment QR Preview',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x15000000),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: paymentSettings.customQrUrl.isNotEmpty
                      ? Image.network(
                          paymentSettings.customQrUrl,
                          width: 170,
                          height: 170,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => QrImageView(
                            data: paymentSettings.getQrData(),
                            size: 170,
                          ),
                        )
                      : QrImageView(
                          data: paymentSettings.getQrData(),
                          size: 170,
                        ),
                ),
                const SizedBox(height: 14),
                Text(
                  paymentSettings.payeeName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      paymentSettings.activeUpiId,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      tooltip: 'Copy UPI ID',
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: paymentSettings.activeUpiId),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Copied ${paymentSettings.activeUpiId} to clipboard',
                            ),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'This QR code will be dynamically generated and shown during Student Admissions & Renewal payments.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Business / Payee Name Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Payee / Business Name',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                    if (!_isEditingPayee)
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: () => setState(() {
                          _payeeNameController.text = paymentSettings.payeeName;
                          _isEditingPayee = true;
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'The payee name shown on UPI payment apps during scan.',
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                if (_isEditingPayee) ...[
                  TextField(
                    controller: _payeeNameController,
                    decoration: InputDecoration(
                      hintText: 'Enter Business / Library Name',
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
                        ),
                        onPressed: _savePayeeName,
                      ),
                    ),
                    onSubmitted: (_) => _savePayeeName(),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => setState(() => _isEditingPayee = false),
                      child: const Text('Cancel'),
                    ),
                  ),
                ] else ...[
                  Text(
                    paymentSettings.payeeName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Manage UPI IDs Header
          Text(
            'UPI Payment Accounts',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select which UPI ID is active for QR code generation across the app.',
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),

          // List of UPI IDs
          ...paymentSettings.upiIds.map((upiId) {
            final isActive = upiId == paymentSettings.activeUpiId;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isActive
                    ? colors.primaryContainer.withValues(alpha: 0.25)
                    : colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive ? colors.primary : colors.outlineVariant,
                  width: isActive ? 1.8 : 1.0,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                leading: Radio<String>(
                  value: upiId,
                  groupValue: paymentSettings.activeUpiId,
                  activeColor: colors.primary,
                  onChanged: (val) {
                    if (val != null) {
                      ref
                          .read(paymentSettingsProvider.notifier)
                          .setActiveUpiId(val);
                    }
                  },
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        upiId,
                        style: TextStyle(
                          fontWeight: isActive
                              ? FontWeight.w800
                              : FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'ACTIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      tooltip: 'Copy',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: upiId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Copied $upiId'),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    if (paymentSettings.upiIds.length > 1)
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: Colors.redAccent,
                        ),
                        tooltip: 'Delete',
                        onPressed: () => _confirmDelete(upiId),
                      ),
                  ],
                ),
                onTap: () {
                  ref
                      .read(paymentSettingsProvider.notifier)
                      .setActiveUpiId(upiId);
                },
              ),
            );
          }),

          const SizedBox(height: 12),

          // Add New UPI ID Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New UPI ID',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newUpiController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. mylibrary@upi',
                          prefixIcon: Icon(
                            Icons.account_balance_wallet_outlined,
                          ),
                        ),
                        onSubmitted: (_) => _addUpiId(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _addUpiId,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _uploadQrImage,
            icon: const Icon(Icons.upload_file_outlined),
            label: const Text('Upload UPI QR Image'),
          ),
          if (paymentSettings.customQrUrl.isNotEmpty)
            TextButton.icon(
              onPressed: () =>
                  ref.read(paymentSettingsProvider.notifier).removeCustomQr(),
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Use generated UPI QR instead'),
            ),
        ],
      ),
    );
  }

  void _confirmDelete(String upiId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete UPI ID'),
        content: Text('Are you sure you want to delete "$upiId"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(paymentSettingsProvider.notifier).removeUpiId(upiId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
