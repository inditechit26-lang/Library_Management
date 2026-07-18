import 'package:flutter/material.dart';
import '../models/student.dart';

class StudentProfileHeader extends StatelessWidget {
  final Student student;
  final VoidCallback onCall, onWhatsApp;
  const StudentProfileHeader({
    super.key,
    required this.student,
    required this.onCall,
    required this.onWhatsApp,
  });
  @override
  Widget build(BuildContext context) {
    final paid = student.payment == PaymentStatus.paid;
    return Column(
      children: [
        Hero(
          tag: 'student-${student.id}',
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: paid ? const Color(0xFF459A78) : const Color(0xFFC96A60),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 42,
              backgroundColor: const Color(0xFFEDECF8),
              child: Text(
                student.initials,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF514BC0),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ContactButton(
              icon: const Icon(Icons.phone_outlined, size: 18),
              label: 'Call',
              onTap: onCall,
            ),
            const SizedBox(width: 10),
            _ContactButton(
              icon: const WhatsAppLogo(size: 19),
              label: 'WhatsApp',
              onTap: onWhatsApp,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          student.name,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          alignment: WrapAlignment.center,
          children: [
            _Pill(
              student.membership == MembershipType.fullTime
                  ? 'Full Time'
                  : 'Half Time',
            ),
            _Pill(
              student.membership == MembershipType.fullTime
                  ? 'Seat ${student.seat}'
                  : 'Flexible Seating',
            ),
            _Pill(student.payment.name),
          ],
        ),
      ],
    );
  }
}

class _ContactButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;
  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onTap,
    icon: icon,
    label: Text(label),
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(112, 44),
      padding: const EdgeInsets.symmetric(horizontal: 14),
    ),
  );
}

class WhatsAppLogo extends StatelessWidget {
  final double size;
  const WhatsAppLogo({super.key, this.size = 20});
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _WhatsAppPainter());
}

class _WhatsAppPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final green = Paint()..color = const Color(0xFF25D366);
    final white = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .12
      ..strokeCap = StrokeCap.round;
    final center = Offset(size.width * .5, size.height * .47);
    canvas.drawCircle(center, size.width * .43, green);
    final tail = Path()
      ..moveTo(size.width * .22, size.height * .73)
      ..lineTo(size.width * .13, size.height * .94)
      ..lineTo(size.width * .38, size.height * .82)
      ..close();
    canvas.drawPath(tail, green);
    final phone = Path()
      ..moveTo(size.width * .34, size.height * .27)
      ..cubicTo(
        size.width * .30,
        size.height * .52,
        size.width * .48,
        size.height * .70,
        size.width * .72,
        size.height * .68,
      );
    canvas.drawPath(phone, white);
    canvas.drawLine(
      Offset(size.width * .34, size.height * .27),
      Offset(size.width * .43, size.height * .38),
      white,
    );
    canvas.drawLine(
      Offset(size.width * .62, size.height * .59),
      Offset(size.width * .72, size.height * .68),
      white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill(this.text);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFF0EFFF),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        color: Color(0xFF514BC0),
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
