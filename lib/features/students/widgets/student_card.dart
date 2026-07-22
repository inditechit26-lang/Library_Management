import 'package:flutter/material.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/utils/formatters.dart';
import '../models/student.dart';
import 'profile_header.dart';

class StudentCard extends StatefulWidget {
  final Student student;
  final VoidCallback onOpen;
  const StudentCard({super.key, required this.student, required this.onOpen});

  @override
  State<StudentCard> createState() => _StudentCardState();
}

class _StudentCardState extends State<StudentCard> {
  bool hovered = false, pressed = false;
  Student get student => widget.student;

  Color get statusColor => student.payment == PaymentStatus.paid
      ? const Color(0xFF10B981)
      : student.payment == PaymentStatus.pending
      ? const Color(0xFFF59E0B)
      : const Color(0xFFEF4444);

  String get status => student.payment == PaymentStatus.expired
      ? 'Overdue'
      : '${student.payment.name[0].toUpperCase()}${student.payment.name.substring(1)}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedScale(
        scale: pressed ? .988 : 1,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF181C2B) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: hovered
                  ? theme.colorScheme.primary.withOpacity(0.4)
                  : isDark
                      ? const Color(0xFF262C40)
                      : const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : const Color(0xFF1E2238).withOpacity(hovered ? 0.08 : 0.04),
                blurRadius: hovered ? 28 : 20,
                offset: Offset(0, hovered ? 10 : 7),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onOpen,
              onHighlightChanged: (value) => setState(() => pressed = value),
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
                child: Row(
                  children: [
                    _Avatar(student: student, statusColor: statusColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Details(
                        student: student,
                        status: status,
                        statusColor: statusColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _QuickAction(
                          tooltip: 'Call',
                          icon: Icon(
                            Icons.phone_outlined,
                            size: 19,
                            color: theme.colorScheme.primary,
                          ),
                          onTap: () => launchUrl(
                            Uri.parse(
                              'tel:${student.phone.replaceAll(' ', '')}',
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _QuickAction(
                          tooltip: 'WhatsApp',
                          icon: const FaIcon(
                            FontAwesomeIcons.whatsapp,
                            size: 19,
                            color: Color(0xFF25D366),
                          ),
                          onTap: () => launchUrl(
                            Uri.parse(
                              'https://wa.me/${phoneDigits(student.phone)}',
                            ),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final Student student;
  final Color statusColor;
  const _Avatar({required this.student, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Hero(
          tag: 'student-${student.id}',
          child: Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: statusColor.withOpacity(0.6), width: 1.8),
            ),
            child: CircleAvatar(
              backgroundColor: isDark
                  ? theme.colorScheme.primary.withOpacity(0.2)
                  : const Color(0xFFEEF2FF),
              foregroundColor: theme.colorScheme.primary,
              backgroundImage: student.photoPath == null
                  ? null
                  : FileImage(File(student.photoPath!)),
              child: student.photoPath == null
                  ? Text(
                      student.initials,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .3,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : null,
            ),
          ),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF181C2B) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? const Color(0xFF262C40) : const Color(0xFFE2E8F0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Icon(
              student.membership == MembershipType.fullTime
                  ? Icons.workspace_premium_rounded
                  : Icons.schedule_rounded,
              size: 13,
              color: const Color(0xFF6366F1),
            ),
          ),
        ),
      ],
    );
  }
}

class _Details extends StatelessWidget {
  final Student student;
  final String status;
  final Color statusColor;
  const _Details({
    required this.student,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          student.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.onSurface,
            letterSpacing: -.3,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          student.phone,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 5,
          children: [
            _Badge(
              label: student.membership == MembershipType.fullTime
                  ? 'Full Time'
                  : 'Half Time',
              icon: student.membership == MembershipType.fullTime
                  ? Icons.workspace_premium_outlined
                  : Icons.schedule_outlined,
            ),
            _Badge(
              label: student.membership == MembershipType.fullTime
                  ? 'Seat ${student.seat}'
                  : 'Flexible Seating',
              icon: Icons.event_seat_outlined,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '· Expires ${student.expiry}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final IconData icon;
  const _Badge({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.primary.withOpacity(0.12)
            : const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? theme.colorScheme.primary.withOpacity(0.25)
              : const Color(0xFFC7D2FE),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String tooltip;
  final Widget icon;
  final VoidCallback onTap;
  const _QuickAction({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        shape: CircleBorder(
          side: BorderSide(
            color: isDark ? const Color(0xFF262C40) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(width: 38, height: 38, child: Center(child: icon)),
        ),
      ),
    );
  }
}
