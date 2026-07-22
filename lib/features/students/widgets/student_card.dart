import 'package:flutter/material.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
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
      ? const Color(0xFF318B6B)
      : student.payment == PaymentStatus.pending
      ? const Color(0xFFC78A36)
      : const Color(0xFFC95C65);
  String get status => student.payment == PaymentStatus.expired
      ? 'Overdue'
      : '${student.payment.name[0].toUpperCase()}${student.payment.name.substring(1)}';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
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
            color: colors.surface,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: hovered
                    ? const Color(0x1420243B)
                    : const Color(0x0A20243B),
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
              borderRadius: BorderRadius.circular(22),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 16, 12, 16),
                child: Row(
                  children: [
                    _Avatar(student: student, statusColor: statusColor),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _Details(
                        student: student,
                        status: status,
                        statusColor: statusColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _QuickAction(
                          tooltip: 'Call',
                          icon: const Icon(Icons.phone_outlined, size: 19),
                          onTap: () => launchUrl(
                            Uri.parse(
                              'tel:${student.phone.replaceAll(' ', '')}',
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _QuickAction(
                          tooltip: 'WhatsApp',
                          icon: const WhatsAppLogo(size: 19),
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
  Widget build(BuildContext context) => Stack(
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
            border: Border.all(color: statusColor.withAlpha(150), width: 1.5),
          ),
          child: CircleAvatar(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primaryContainer.withAlpha(120),
            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            backgroundImage: student.photoPath == null
                ? null
                : FileImage(File(student.photoPath!)),
            child: student.photoPath == null
                ? Text(
                    student.initials,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .3,
                    ),
                  )
                : null,
          ),
        ),
      ),
      Positioned(
        right: -3,
        bottom: -3,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(color: Color(0x1820243B), blurRadius: 8),
            ],
          ),
          child: Icon(
            student.membership == MembershipType.fullTime
                ? Icons.workspace_premium_rounded
                : Icons.schedule_rounded,
            size: 12,
            color: const Color(0xFF625BCD),
          ),
        ),
      ),
    ],
  );
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
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        student.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w800,
          letterSpacing: -.15,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        student.phone,
        style: TextStyle(
          fontSize: 9.5,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
      const SizedBox(height: 9),
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
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Expires ${student.expiry}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8.5,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

class _Badge extends StatelessWidget {
  final String label;
  final IconData icon;
  const _Badge({required this.label, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(9),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
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
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: Colors.transparent,
      shape: CircleBorder(
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(width: 44, height: 44, child: Center(child: icon)),
      ),
    ),
  );
}
