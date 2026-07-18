import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/formatters.dart';
import '../models/student.dart';

class StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onOpen;
  const StudentCard({super.key, required this.student, required this.onOpen});
  Color get statusColor => student.payment == PaymentStatus.paid
      ? const Color(0xFF3FA37B)
      : student.payment == PaymentStatus.pending
      ? const Color(0xFFD09A49)
      : const Color(0xFFD26A70);
  String get status => student.payment == PaymentStatus.expired
      ? 'Overdue'
      : student.payment.name[0].toUpperCase() +
            student.payment.name.substring(1);
  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 152,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE4E7EE)),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x09262B44),
              blurRadius: 22,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 61,
                  height: 61,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    border: Border.all(color: statusColor, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F1EC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        student.initials,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF527765),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -5,
                  bottom: -5,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(color: Color(0x18262B44), blurRadius: 8),
                      ],
                    ),
                    child: Icon(
                      student.membership == MembershipType.fullTime
                          ? Icons.auto_awesome
                          : Icons.schedule,
                      size: 12,
                      color: const Color(0xFF625BCD),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    student.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    student.phone,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF969BAB),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: student.membership == MembershipType.fullTime
                              ? const Color(0xFFF0EFFF)
                              : const Color(0xFFF7F2E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          student.membership == MembershipType.fullTime
                              ? 'Full Time'
                              : 'Half Time',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: student.membership == MembershipType.fullTime
                                ? const Color(0xFF5953C2)
                                : const Color(0xFF937247),
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          student.membership == MembershipType.fullTime
                              ? 'Seat ${student.seat}'
                              : 'Flexible Seating',
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF616678),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Expires ${student.expiry}',
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF9A9FAE),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _Status(text: status, color: statusColor),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _IconButton(
                  Icons.phone_outlined,
                  () => launchUrl(
                    Uri.parse('tel:${student.phone.replaceAll(' ', '')}'),
                  ),
                ),
                const SizedBox(height: 8),
                _IconButton(
                  Icons.chat_bubble_outline,
                  () => launchUrl(
                    Uri.parse('https://wa.me/${phoneDigits(student.phone)}'),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _Status extends StatelessWidget {
  final String text;
  final Color color;
  const _Status({required this.text, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withAlpha(26),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 3, backgroundColor: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    ),
  );
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback tap;
  const _IconButton(this.icon, this.tap);
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: tap,
    borderRadius: BorderRadius.circular(13),
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E5EC)),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, size: 19, color: const Color(0xFF686D7D)),
    ),
  );
}
