import 'package:flutter/material.dart';

class AdmissionSuccessScreen extends StatefulWidget {
  final String student, seat, receipt, membership, expiry;
  final VoidCallback onProfile, onPrint, onShare, onDone;
  const AdmissionSuccessScreen({
    super.key,
    required this.student,
    required this.seat,
    required this.receipt,
    required this.membership,
    required this.expiry,
    required this.onProfile,
    required this.onPrint,
    required this.onShare,
    required this.onDone,
  });
  @override
  State<AdmissionSuccessScreen> createState() => _State();
}

class _State extends State<AdmissionSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> scale;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    scale = CurvedAnimation(parent: controller, curve: Curves.elasticOut);
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(22, 30, 22, 28),
    child: Column(
      children: [
        ScaleTransition(
          scale: scale,
          child: Container(
            width: 82,
            height: 82,
            decoration: const BoxDecoration(
              color: Color(0xFFE5F7EF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Color(0xFF288C68),
              size: 44,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Admission Created Successfully',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -.35,
          ),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE5E7EF)),
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0B20243B),
                blurRadius: 28,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              _Row('Student Name', widget.student),
              _Row('Seat Number', widget.seat),
              _Row('Receipt Number', widget.receipt),
              _Row('Membership', widget.membership),
              _Row('Expiry Date', widget.expiry, last: true),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: widget.onProfile,
            child: const Text('View Student Profile'),
          ),
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.onPrint,
                icon: const Icon(Icons.print_outlined),
                label: const Text('Print Receipt'),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.onShare,
                icon: const Icon(Icons.share_outlined),
                label: const Text('Share Receipt'),
              ),
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: widget.onDone,
            child: const Text('Done'),
          ),
        ),
      ],
    ),
  );
}

class _Row extends StatelessWidget {
  final String label, value;
  final bool last;
  const _Row(this.label, this.value, {this.last = false});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 11),
    decoration: BoxDecoration(
      border: last
          ? null
          : const Border(bottom: BorderSide(color: Color(0xFFEEEFF4))),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF858B9C)),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    ),
  );
}
