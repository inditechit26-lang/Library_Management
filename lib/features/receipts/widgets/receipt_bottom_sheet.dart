import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../students/models/student.dart';
import '../../../core/utils/formatters.dart';
import '../services/receipt_service.dart';

class ReceiptBottomSheet extends StatelessWidget {
  final Student student;
  final String? newExpiry;
  const ReceiptBottomSheet({super.key, required this.student, this.newExpiry});
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      24,
      12,
      24,
      MediaQuery.paddingOf(context).bottom + 22,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFD9DBE4),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFFBFBFD),
            border: Border.all(color: const Color(0xFFE5E7EF)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.menu_book_rounded, color: Color(0xFF5650C7)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppConstants.libraryName,
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'PAYMENT RECEIPT',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.black45,
                            letterSpacing: .8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 28),
              _line(
                'Receipt',
                'SR-2026-${student.id.toString().padLeft(4, '0')}',
              ),
              _line('Student', student.name),
              _line('Phone', student.phone),
              _line(
                'Membership',
                student.membership == MembershipType.fullTime
                    ? 'Full Time'
                    : 'Half Time',
              ),
              _line(
                'Seat',
                student.membership == MembershipType.fullTime
                    ? student.seat
                    : 'Flexible',
              ),
              _line('Joining date', student.joined),
              _line('Previous expiry', student.expiry),
              _line('New expiry', newExpiry ?? student.expiry),
              _line('Payment method', 'UPI'),
              _line('Amount paid', money(student.fee), strong: true),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    ReceiptService.print(student, newExpiry: newExpiry),
                icon: const Icon(Icons.print_outlined),
                label: const Text('Print'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    ReceiptService.share(student, newExpiry: newExpiry),
                icon: const Icon(Icons.share_outlined),
                label: const Text('Share'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ),
      ],
    ),
  );
  static Widget _line(String a, String b, {bool strong = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          child: Text(a, style: const TextStyle(color: Colors.black54)),
        ),
        Text(
          b,
          style: TextStyle(
            fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
            fontSize: strong ? 16 : 13,
          ),
        ),
      ],
    ),
  );
}
