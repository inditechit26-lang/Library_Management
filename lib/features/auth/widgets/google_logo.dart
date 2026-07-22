import 'package:flutter/material.dart';

class GoogleLogoWidget extends StatelessWidget {
  final double size;
  const GoogleLogoWidget({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _OfficialGooglePainter(),
      ),
    );
  }
}

class _OfficialGooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    final red = Paint()..color = const Color(0xFFEA4335);
    final blue = Paint()..color = const Color(0xFF4285F4);
    final yellow = Paint()..color = const Color(0xFFFBBC05);
    final green = Paint()..color = const Color(0xFF34A853);

    // Official G segments
    final rect = Rect.fromCircle(center: center, radius: radius * 0.95);

    // Red top arc
    canvas.drawArc(rect, -0.7, 1.8, true, red);
    // Yellow bottom left arc
    canvas.drawArc(rect, 1.1, 1.0, true, yellow);
    // Green bottom right arc
    canvas.drawArc(rect, 2.1, 1.1, true, green);
    // Blue right arc
    canvas.drawArc(rect, 3.2, 1.7, true, blue);

    // Cutout inner circle
    canvas.drawCircle(center, radius * 0.54, Paint()..color = Colors.white);

    // Blue horizontal bar
    final barRect = Rect.fromLTWH(
      w * 0.44,
      h * 0.40,
      w * 0.52,
      h * 0.20,
    );
    canvas.drawRect(barRect, blue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
