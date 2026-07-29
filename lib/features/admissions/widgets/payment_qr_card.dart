import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/payment_confirmation_slider.dart';
import '../../settings/controllers/payment_settings_controller.dart';
import '../../students/models/student.dart';

class AdmissionPaymentQrCard extends ConsumerStatefulWidget {
  final double amount;
  final bool confirmed;
  final ValueChanged<bool> onConfirmed;
  final PaymentMode mode;
  final ValueChanged<PaymentMode>? onModeChanged;

  const AdmissionPaymentQrCard({
    super.key,
    required this.amount,
    required this.confirmed,
    required this.onConfirmed,
    this.mode = PaymentMode.upi,
    this.onModeChanged,
  });

  @override
  ConsumerState<AdmissionPaymentQrCard> createState() => _State();
}

class _State extends ConsumerState<AdmissionPaymentQrCard> {
  late PaymentMode _currentMode;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.mode;
  }

  @override
  void didUpdateWidget(AdmissionPaymentQrCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) {
      _currentMode = widget.mode;
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentSettings = ref.watch(paymentSettingsProvider);
    final data = paymentSettings.getQrData(widget.amount);
    final upiId = paymentSettings.activeUpiId;
    final customQrUrl = paymentSettings.customQrUrl;
    final colors = Theme.of(context).colorScheme;
    final isCash = _currentMode == PaymentMode.cash;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outline),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          if (!isCash) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1020243B),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: customQrUrl.isNotEmpty
                  ? Image.network(
                      customQrUrl,
                      width: 166,
                      height: 166,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) =>
                          QrImageView(data: data, size: 166),
                    )
                  : QrImageView(data: data, size: 166),
            ),
            const SizedBox(height: 12),
            Text(
              upiId,
              style: const TextStyle(fontSize: 11, color: Color(0xFF777D8E)),
            ),
            const SizedBox(height: 4),
            Text(
              money(widget.amount),
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 13),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Action(
                  icon: Icons.copy_outlined,
                  label: 'Copy UPI',
                  onTap: () => Clipboard.setData(ClipboardData(text: upiId)),
                ),
                _Action(
                  icon: Icons.fullscreen,
                  label: 'Full Screen QR',
                  onTap: () => _fullScreen(context, data, customQrUrl),
                ),
                _Action(
                  icon: Icons.share_outlined,
                  label: 'Share QR',
                  onTap: () =>
                      SharePlus.instance.share(ShareParams(text: data)),
                ),
              ],
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.payments_rounded,
                      size: 36,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Cash Payment Mode',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Collect ${money(widget.amount)} in cash from student.',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),

          // Payment Mode Toggle Chips
          Row(
            children: [
              Expanded(
                child: _ModeChip(
                  label: 'UPI / QR',
                  icon: Icons.qr_code_2_rounded,
                  selected: _currentMode == PaymentMode.upi,
                  onTap: () {
                    setState(() => _currentMode = PaymentMode.upi);
                    widget.onModeChanged?.call(PaymentMode.upi);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ModeChip(
                  label: 'Cash Payment',
                  icon: Icons.payments_outlined,
                  selected: _currentMode == PaymentMode.cash,
                  onTap: () {
                    setState(() => _currentMode = PaymentMode.cash);
                    widget.onModeChanged?.call(PaymentMode.cash);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: widget.confirmed
                ? Container(
                    key: const ValueKey(true),
                    height: 54,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1B3D31)
                          : const Color(0xFFE8F7F0),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_circle,
                        color: Color(0xFF288C68),
                        size: 28,
                      ),
                    ),
                  )
                : PaymentConfirmationSlider(
                    key: const ValueKey(false),
                    onConfirmed: () => widget.onConfirmed(true),
                  ),
          ),
        ],
      ),
    );
  }

  void _fullScreen(BuildContext context, String qrData, String customQrUrl) =>
      showDialog<void>(
        context: context,
        builder: (_) => Dialog(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: customQrUrl.isNotEmpty
                ? Image.network(
                    customQrUrl,
                    width: 280,
                    height: 280,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) =>
                        QrImageView(data: qrData, size: 280),
                  )
                : QrImageView(data: qrData, size: 280),
          ),
        ),
      );
}

class _ModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? colors.primary.withValues(alpha: 0.12)
                : colors.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? colors.primary
                  : colors.outlineVariant.withValues(alpha: 0.5),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? colors.primary : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Action({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Icon(icon, size: 18, color: colors.primary),
              const SizedBox(height: 5),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
