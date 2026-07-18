import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';

class AdmissionPaymentQrCard extends StatefulWidget {
  final double amount;
  final bool confirmed;
  final ValueChanged<bool> onConfirmed;
  const AdmissionPaymentQrCard({
    super.key,
    required this.amount,
    required this.confirmed,
    required this.onConfirmed,
  });
  @override
  State<AdmissionPaymentQrCard> createState() => _State();
}

class _State extends State<AdmissionPaymentQrCard> {
  double slide = 0;
  String get data =>
      'upi://pay?pa=${AppConstants.upiId}&pn=${Uri.encodeComponent(AppConstants.libraryName)}&am=${widget.amount}&cu=INR';

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE5E7EF)),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      children: [
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
          child: QrImageView(data: data, size: 166),
        ),
        const SizedBox(height: 12),
        const Text(
          AppConstants.upiId,
          style: TextStyle(fontSize: 11, color: Color(0xFF777D8E)),
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
              onTap: () => Clipboard.setData(
                const ClipboardData(text: AppConstants.upiId),
              ),
            ),
            _Action(
              icon: Icons.fullscreen,
              label: 'Full Screen QR',
              onTap: () => _fullScreen(context),
            ),
            _Action(
              icon: Icons.share_outlined,
              label: 'Share QR',
              onTap: () => SharePlus.instance.share(ShareParams(text: data)),
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
                    color: const Color(0xFFE8F7F0),
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
              : Stack(
                  key: const ValueKey(false),
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFEEFF),
                        border: Border.all(color: const Color(0xFFDCD9FF)),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: const Center(
                        child: Text(
                          'Slide to Confirm Payment',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF5650C7),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    Slider(
                      value: slide,
                      activeColor: const Color(0xFF5650C7),
                      inactiveColor: Colors.transparent,
                      onChanged: (value) {
                        setState(() => slide = value);
                        if (value > .95) widget.onConfirmed(true);
                      },
                    ),
                  ],
                ),
        ),
      ],
    ),
  );

  void _fullScreen(BuildContext context) => showDialog<void>(
    context: context,
    builder: (_) => Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: QrImageView(data: data, size: 280),
      ),
    ),
  );
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Action({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF686E80)),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ),
  );
}
