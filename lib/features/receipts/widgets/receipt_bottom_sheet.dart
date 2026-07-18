import 'package:flutter/material.dart';
import '../../../core/settings/app_settings.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_constants.dart';
import '../../students/models/student.dart';
import '../../../core/utils/formatters.dart';

class ReceiptBottomSheet extends StatelessWidget {
  final Student student;
  final String? newExpiry;
  const ReceiptBottomSheet({super.key, required this.student, this.newExpiry});
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      22,
      12,
      22,
      MediaQuery.paddingOf(context).bottom + 22,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 4,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Icon(Icons.menu_book_rounded, color: Color(0xFF514BC0)),
            const SizedBox(width: 10),
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
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Divider(height: 28),
        _line(
          context,
          'Receipt',
          'SR-2026-${student.id.toString().padLeft(4, '0')}',
        ),
        _line(context, 'Student', student.name),
        _line(context, 'Phone', student.phone),
        _line(
          context,
          'Membership',
          student.membership == MembershipType.fullTime
              ? 'Full Time'
              : 'Half Time',
        ),
        _line(
          context,
          'Seat',
          student.membership == MembershipType.fullTime
              ? student.seat
              : 'Flexible',
        ),
        _line(context, 'Joining date', student.joined),
        _line(context, 'Previous expiry', student.expiry),
        _line(context, 'New expiry', newExpiry ?? student.expiry),
        _line(context, 'Payment method', 'UPI'),
        _line(context, 'Amount paid', money(student.fee), strong: true),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.print_outlined),
                label: Text(context.tr('Print')),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => SharePlus.instance.share(
                  ShareParams(
                    text:
                        '${AppConstants.libraryName} receipt ${money(student.fee)} for ${student.name}',
                  ),
                ),
                icon: const Icon(Icons.share_outlined),
                label: Text(context.tr('Share')),
              ),
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('Close')),
          ),
        ),
      ],
    ),
  );
  static Widget _line(
    BuildContext context,
    String a,
    String b, {
    bool strong = false,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          child: Text(
            a,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
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
