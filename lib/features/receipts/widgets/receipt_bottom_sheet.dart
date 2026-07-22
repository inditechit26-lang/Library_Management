import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../students/models/student.dart';
import '../../students/widgets/profile_header.dart';
import '../../../core/utils/formatters.dart';
import '../services/receipt_service.dart';

class ReceiptBottomSheet extends StatelessWidget {
  final Student student;
  final String? newExpiry;
  const ReceiptBottomSheet({super.key, required this.student, this.newExpiry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        22,
        14,
        22,
        MediaQuery.paddingOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF3E4556) : const Color(0xFFD4D7E2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainer
                  : const Color(0xFFFAFAFE),
              border: Border.all(
                color: isDark
                    ? theme.colorScheme.outline.withOpacity(0.35)
                    : const Color(0xFFE5E7EF),
                width: 1.2,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.3)
                      : const Color(0xFF1E2238).withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        color: primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.libraryName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'PAYMENT RECEIPT',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? const Color(0xFF9EA6BA)
                                  : const Color(0xFF83899F),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(
                  height: 1,
                  color: isDark
                      ? const Color(0xFF333948)
                      : const Color(0xFFEAEDF3),
                ),
                const SizedBox(height: 14),
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
                _line(
                  context,
                  'Previous expiry',
                  student.previousExpiry ?? student.expiry,
                ),
                _line(context, 'New expiry', newExpiry ?? student.expiry),
                _line(context, 'Payment method', 'UPI'),
                const SizedBox(height: 6),
                _line(
                  context,
                  'Amount paid',
                  money(student.fee),
                  strong: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      ReceiptService.print(student, newExpiry: newExpiry),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    side: BorderSide(
                      color: isDark
                          ? theme.colorScheme.outline.withOpacity(0.4)
                          : const Color(0xFFD9DCFA),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.print_rounded, size: 19),
                  label: const Text(
                    'Print',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      ReceiptService.share(student, newExpiry: newExpiry),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    foregroundColor: const Color(0xFF23936B),
                    side: BorderSide(
                      color: const Color(0xFF23936B).withOpacity(0.35),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const WhatsAppLogo(size: 19),
                  label: const Text(
                    'Share to WhatsApp',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Close',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _line(
    BuildContext context,
    String a,
    String b, {
    bool strong = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              a,
              style: TextStyle(
                fontSize: strong ? 13 : 12,
                fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
                color: isDark
                    ? const Color(0xFF9AA1B2)
                    : const Color(0xFF727888),
              ),
            ),
          ),
          Text(
            b,
            style: TextStyle(
              fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
              fontSize: strong ? 17 : 13,
              color: strong
                  ? (isDark ? theme.colorScheme.primary : const Color(0xFF5145EA))
                  : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

