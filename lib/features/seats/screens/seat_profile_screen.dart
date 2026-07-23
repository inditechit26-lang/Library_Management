import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../receipts/widgets/receipt_bottom_sheet.dart';
import '../../receipts/screens/receipt_pdf_viewer_screen.dart';
import '../../students/controllers/students_controller.dart';
import '../../students/models/student.dart';
import '../../students/widgets/edit_student_sheet.dart';
import '../../students/widgets/document_vault.dart';
import '../../students/widgets/activity_timeline.dart';
import '../../students/widgets/membership_card.dart';
import '../../students/widgets/profile_header.dart';
import '../../students/widgets/profile_information.dart';
import '../../students/widgets/renew_bottom_sheet.dart';
import '../controllers/seats_controller.dart';

class SeatProfileScreen extends ConsumerWidget {
  final String seatId;
  const SeatProfileScreen({super.key, required this.seatId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seats = ref.watch(seatsProvider);
    if (seats.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Seat Profile')),
        body: const Center(child: Text('No seat found')),
      );
    }
    final seat = seats.firstWhere(
      (item) => item.seatId == seatId,
      orElse: () => seats.first,
    );
    Student? student;
    for (final s in ref.watch(studentsProvider)) {
      if (s.id == seat.studentId) student = s;
    }
    if (student == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Seat ${seat.seatLabel}')),
        body: const Center(child: Text('No student assigned')),
      );
    }
    final value = student;
    return Scaffold(
      appBar: AppBar(
        title: Text('Seat ${seat.seatLabel}'),
        actions: [
          IconButton(
            onPressed: () => context.push('/seats/$seatId/change'),
            icon: const Icon(Icons.swap_horiz_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 110),
        children: [
          StudentProfileHeader(
            student: value,
            onCall: () => _call(value),
            onWhatsApp: () => _whatsApp(value),
          ),
          const SizedBox(height: 16),
          Hero(
            tag: 'seat-$seatId',
            child: Material(
              color: Colors.transparent,
              child: _SeatInformation(number: seat.seatLabel),
            ),
          ),
          const SizedBox(height: 14),
          MembershipCard(
            student: value,
            onRenew: () => _renew(context, value),
            onReceipt: () => _receipt(context, value),
          ),
          const SizedBox(height: 14),
          StudentInformationCard(student: value),
          const SizedBox(height: 14),
          PaymentInformationCard(
            student: value,
            onReceipt: () => _receipt(context, value),
          ),
          const SizedBox(height: 14),
          DocumentVault(studentId: value.id),
          const SizedBox(height: 14),
          const ActivityTimeline(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(10),
          color: Colors.white,
          child: Row(
            children: [
              _action(Icons.phone_outlined, 'Call', () => _call(value)),
              _action(Icons.chat_outlined, 'WhatsApp', () => _whatsApp(value)),
              _action(Icons.refresh, 'Renew', () => _renew(context, value)),
              _action(
                Icons.edit_outlined,
                'Edit',
                () => _edit(context, ref, value),
              ),
              _action(
                Icons.delete_outline,
                'Remove',
                () => _remove(context, ref, value),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _action(IconData icon, String label, VoidCallback tap) => Expanded(
    child: InkWell(
      onTap: tap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ),
  );
  void _renew(BuildContext c, Student s) => showModalBottomSheet(
    context: c,
    isScrollControlled: true,
    builder: (_) => RenewBottomSheet(student: s),
  );
  void _receipt(BuildContext c, Student s) =>
      ReceiptPdfViewerScreen.open(c, s);

  void _edit(BuildContext c, WidgetRef ref, Student s) => showModalBottomSheet(
    context: c,
    isScrollControlled: true,
    builder: (_) => EditStudentSheet(
      student: s,
      onSave: ref.read(studentsProvider.notifier).update,
    ),
  );
  Future<void> _remove(BuildContext c, WidgetRef ref, Student s) async {
    final ok = await showDialog<bool>(
      context: c,
      builder: (dialog) => AlertDialog(
        title: const Text('Remove assignment?'),
        content: Text('${s.name} will be removed from this seat.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok == true && c.mounted) {
      ref.read(seatsProvider.notifier).release(seatId);
      ref.read(studentsProvider.notifier).update(s.copyWith(seat: 'Flexible'));
      c.pop();
    }
  }

  Future<void> _call(Student s) => launchUrl(
    Uri.parse('tel:${s.phone.replaceAll(' ', '')}'),
    mode: LaunchMode.externalApplication,
  );
  Future<void> _whatsApp(Student s) => launchUrl(
    Uri.parse('https://wa.me/${s.phone.replaceAll(RegExp(r'\D'), '')}'),
    mode: LaunchMode.externalApplication,
  );
}

class _SeatInformation extends StatelessWidget {
  final String number;
  const _SeatInformation({required this.number});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE5E7EF)),
    ),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFEFEEFF),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.event_seat_outlined,
            color: Color(0xFF5650C7),
          ),
        ),
        const SizedBox(width: 13),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seat $number',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const Text(
              'Occupied - Reserved seating',
              style: TextStyle(fontSize: 10, color: Color(0xFF858B9D)),
            ),
          ],
        ),
      ],
    ),
  );
}
