import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../models/student.dart';
import '../../../core/utils/formatters.dart';
import '../controllers/students_controller.dart';
import '../../receipts/widgets/receipt_bottom_sheet.dart';

class RenewBottomSheet extends ConsumerStatefulWidget {
  final Student student;
  const RenewBottomSheet({super.key, required this.student});
  @override
  ConsumerState<RenewBottomSheet> createState() => _State();
}

class _State extends ConsumerState<RenewBottomSheet> {
  double slide = 0;
  bool done = false;
  late final String expiry;
  @override
  void initState() {
    super.initState();
    final current = DateFormat('dd MMM yyyy').parse(widget.student.expiry);
    expiry = DateFormat(
      'dd MMM yyyy',
    ).format(DateTime(current.year, current.month + 1, current.day));
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      8,
      20,
      MediaQuery.paddingOf(context).bottom + 20,
    ),
    child: AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: done ? _success() : _payment(),
    ),
  );
  Widget _payment() => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _Handle(),
      Text(
        'Renew Membership',
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
      Text(
        '${widget.student.name} · ${widget.student.membership == MembershipType.fullTime ? 'Full Time' : 'Half Time'}',
        style: const TextStyle(color: Colors.black54),
      ),
      const SizedBox(height: 16),
      _Box(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _Data('CURRENT EXPIRY', widget.student.expiry),
            const Icon(Icons.arrow_forward, color: Colors.black38),
            _Data('NEW EXPIRY', expiry),
          ],
        ),
      ),
      const SizedBox(height: 10),
      _Box(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total amount'),
                Text(
                  money(widget.student.fee),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            QrImageView(
              data:
                  'upi://pay?pa=${AppConstants.upiId}&pn=${Uri.encodeComponent(AppConstants.libraryName)}&am=${widget.student.fee}&cu=INR',
              size: 180,
            ),
            const Text(
              AppConstants.libraryName,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const Text(
              AppConstants.upiId,
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ask the student to scan this QR to complete payment.',
              style: TextStyle(fontSize: 10, color: Colors.black54),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFEFEEFF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Text(
                'Slide to Mark Payment Received',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF514BC0),
                ),
              ),
            ),
          ),
          Slider(
            value: slide,
            onChanged: (v) {
              setState(() => slide = v);
              if (v > .95) {
                ref
                    .read(studentsProvider.notifier)
                    .renew(widget.student, expiry);
                setState(() => done = true);
              }
            },
            activeColor: const Color(0xFF514BC0),
            inactiveColor: Colors.transparent,
          ),
        ],
      ),
    ],
  );
  Widget _success() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const _Handle(),
      Container(
        width: 72,
        height: 72,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFE8F7F0),
        ),
        child: const Icon(
          Icons.check_rounded,
          size: 38,
          color: Color(0xFF2B8F69),
        ),
      ),
      const SizedBox(height: 16),
      const Text(
        'Membership Renewed Successfully',
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 18),
      _Box(
        child: Column(
          children: [
            _line(
              'Receipt',
              'SR-2026-${widget.student.id.toString().padLeft(4, '0')}',
            ),
            _line('Amount', money(widget.student.fee)),
            _line('New expiry', expiry),
          ],
        ),
      ),
      const SizedBox(height: 12),
      FilledButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          builder: (_) =>
              ReceiptBottomSheet(student: widget.student, newExpiry: expiry),
        ),
        child: const Text('View Receipt'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Done'),
      ),
    ],
  );
  Widget _line(String a, String b) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(a, style: const TextStyle(color: Colors.black54)),
        Text(b, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );
}

class _Handle extends StatelessWidget {
  const _Handle();
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 42,
      height: 4,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(4),
      ),
    ),
  );
}

class _Box extends StatelessWidget {
  final Widget child;
  const _Box({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE7E8EE)),
      borderRadius: BorderRadius.circular(20),
    ),
    child: child,
  );
}

class _Data extends StatelessWidget {
  final String a, b;
  const _Data(this.a, this.b);
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(a, style: const TextStyle(fontSize: 9, color: Colors.black45)),
      Text(b, style: const TextStyle(fontWeight: FontWeight.w700)),
    ],
  );
}
