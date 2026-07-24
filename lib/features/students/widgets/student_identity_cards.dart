import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/student.dart';
import '../services/student_id_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/app_logo.dart';

class StudentIdentityCards extends StatelessWidget {
  final Student student;
  final VoidCallback onOpenId;
  const StudentIdentityCards({
    super.key,
    required this.student,
    required this.onOpenId,
  });

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(child: _SeatCard(student: student)),
      const SizedBox(width: 10),
      Expanded(
        child: Hero(
          tag: 'student-id-${student.id}',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onOpenId,
              borderRadius: BorderRadius.circular(20),
              child: StudentIdCard(student: student, compact: true),
            ),
          ),
        ),
      ),
    ],
  );
}

class _SeatCard extends StatelessWidget {
  final Student student;
  const _SeatCard({required this.student});

  @override
  Widget build(BuildContext context) {
    final flexible = student.membership == MembershipType.halfTime;
    return Container(
      height: 154,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5EF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.event_seat_outlined,
              color: Color(0xFF21765A),
              size: 20,
            ),
          ),
          const Spacer(),
          Text(
            flexible ? 'Flexible' : student.seat,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 25,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            flexible ? 'Flexible Seat' : 'Reserved Seat',
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF838899),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class StudentIdCard extends StatelessWidget {
  final Student student;
  final bool compact;
  final int revision;
  const StudentIdCard({
    super.key,
    required this.student,
    this.compact = false,
    this.revision = 0,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(compact ? 18 : 26);
    return Container(
      height: compact ? 154 : null,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D07111F),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
          BoxShadow(color: Color(0x2259D8FF), blurRadius: 24, spreadRadius: -8),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF071827),
                  Color(0xFF0B2335),
                  Color(0xFF102C3C),
                ],
                stops: [0, .55, 1],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: radius,
              border: Border.all(color: const Color(0x667ED8E9)),
            ),
            child: Stack(
              children: [
                const Positioned.fill(
                  child: CustomPaint(painter: _IdPattern()),
                ),
                Positioned(
                  top: compact ? -48 : -72,
                  right: compact ? -45 : -56,
                  child: Container(
                    width: compact ? 118 : 190,
                    height: compact ? 118 : 190,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Color(0x3359D8FF), Color(0x0059D8FF)],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(compact ? 10 : 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CardHeader(compact: compact),
                      SizedBox(height: compact ? 8 : 16),
                      Expanded(
                        child: Row(
                          children: [
                            _Photo(student: student, compact: compact),
                            SizedBox(width: compact ? 7 : 13),
                            Expanded(
                              child: _Details(
                                student: student,
                                compact: compact,
                              ),
                            ),
                            SizedBox(width: compact ? 5 : 12),
                            _QrCredential(
                              student: student,
                              revision: revision,
                              compact: compact,
                            ),
                          ],
                        ),
                      ),
                      if (!compact) ...[
                        const SizedBox(height: 10),
                        Container(height: 1, color: const Color(0x2EFFFFFF)),
                        const SizedBox(height: 9),
                        Row(
                          children: [
                            const Icon(
                              Icons.shield_outlined,
                              size: 12,
                              color: Color(0xFF70E1CA),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'SR-${student.id.toString().padLeft(5, '0')}',
                              style: _microStyle(const Color(0xFFD8E9EE)),
                            ),
                            const Spacer(),
                            Text(
                              'VALID THROUGH  ${student.expiry.toUpperCase()}',
                              style: _microStyle(const Color(0xFF9BB2BB)),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static TextStyle _microStyle(Color color) => GoogleFonts.inter(
    fontSize: 8,
    letterSpacing: .7,
    fontWeight: FontWeight.w700,
    color: color,
  );
}

class _CardHeader extends StatelessWidget {
  final bool compact;
  const _CardHeader({required this.compact});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: compact ? 25 : 38,
        height: compact ? 25 : 38,
        padding: EdgeInsets.all(compact ? 3 : 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF1FBFC),
          borderRadius: BorderRadius.circular(compact ? 8 : 12),
          boxShadow: const [
            BoxShadow(color: Color(0x3359D8FF), blurRadius: 14),
          ],
        ),
        child: AppLogo(size: compact ? 19 : 28),
      ),
      SizedBox(width: compact ? 6 : 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'THE STUDY ROOM',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: compact ? 6.5 : 11,
                letterSpacing: compact ? .45 : 1,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            Text(
              'PREMIER MEMBER CREDENTIAL',
              maxLines: 1,
              style: GoogleFonts.inter(
                fontSize: compact ? 3.8 : 6.5,
                letterSpacing: compact ? .25 : .8,
                color: const Color(0xFF79D8E9),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 5 : 8,
          vertical: compact ? 3 : 5,
        ),
        decoration: BoxDecoration(
          color: const Color(0x1F70E1CA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x6670E1CA)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.verified_rounded,
              size: compact ? 7 : 11,
              color: const Color(0xFF70E1CA),
            ),
            SizedBox(width: compact ? 2 : 4),
            Text(
              'ACTIVE',
              style: GoogleFonts.inter(
                fontSize: compact ? 4 : 6.5,
                letterSpacing: .5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFA8F4E5),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _Photo extends StatelessWidget {
  final Student student;
  final bool compact;
  const _Photo({required this.student, required this.compact});
  @override
  Widget build(BuildContext context) => Container(
    width: compact ? 39 : 66,
    height: compact ? 50 : 78,
    padding: const EdgeInsets.all(1.5),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF8DE4F2), Color(0xFF70E1CA)],
      ),
      borderRadius: BorderRadius.circular(compact ? 10 : 15),
    ),
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFF173345),
        borderRadius: BorderRadius.circular(compact ? 8.5 : 13.5),
        image: student.photoPath == null
            ? null
            : DecorationImage(
                image: FileImage(File(student.photoPath!)),
                fit: BoxFit.cover,
              ),
      ),
      alignment: Alignment.center,
      child: student.photoPath == null
          ? Text(
              student.initials,
              style: GoogleFonts.inter(
                fontSize: compact ? 9 : 15,
                color: const Color(0xFFC8F7F0),
                fontWeight: FontWeight.w900,
              ),
            )
          : null,
    ),
  );
}

class _Details extends StatelessWidget {
  final Student student;
  final bool compact;
  const _Details({required this.student, required this.compact});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        student.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: compact ? 7 : 14,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
      SizedBox(height: compact ? 2 : 5),
      Text(
        student.membership == MembershipType.fullTime
            ? 'Full Time Member'
            : 'Half Time Member',
        maxLines: 1,
        style: GoogleFonts.inter(
          fontSize: compact ? 4.5 : 8,
          color: const Color(0xFF83DDEB),
          fontWeight: FontWeight.w700,
        ),
      ),
      const Spacer(),
      Text(
        student.membership == MembershipType.fullTime
            ? 'SEAT  ${student.seat}'
            : 'FLEXIBLE SEAT',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: compact ? 5.5 : 9,
          fontWeight: FontWeight.w800,
          color: const Color(0xFFF2FBFC),
          letterSpacing: .4,
        ),
      ),
      SizedBox(height: compact ? 2 : 4),
      Text(
        'JOINED  ${student.joined}',
        maxLines: 1,
        style: GoogleFonts.inter(
          fontSize: compact ? 4.5 : 8,
          color: const Color(0xFF9BB2BB),
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _QrCredential extends StatelessWidget {
  final Student student;
  final int revision;
  final bool compact;
  const _QrCredential({
    required this.student,
    required this.revision,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(compact ? 3 : 6),
    decoration: BoxDecoration(
      color: const Color(0xFFF5FCFC),
      borderRadius: BorderRadius.circular(compact ? 7 : 12),
      boxShadow: const [BoxShadow(color: Color(0x4459D8FF), blurRadius: 14)],
    ),
    child: QrImageView(
      data: StudentIdService.payload(student, revision: revision),
      size: compact ? 35 : 61,
      padding: EdgeInsets.zero,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: Color(0xFF071827),
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: Color(0xFF071827),
      ),
    ),
  );
}

class _IdPattern extends CustomPainter {
  const _IdPattern();

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = const Color(0x0D8DE4F2)
      ..strokeWidth = 1;
    for (double x = -size.height; x < size.width; x += 18) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), line);
    }
    final accent = Paint()
      ..color = const Color(0x5570E1CA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(Offset(size.width * .82, size.height * .25), 42, accent);
    canvas.drawCircle(Offset(size.width * .82, size.height * .25), 50, accent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

final _cardDecoration = BoxDecoration(
  color: Colors.white,
  border: Border.all(color: const Color(0xFFE3E5EC)),
  borderRadius: BorderRadius.circular(20),
  boxShadow: const [
    BoxShadow(color: Color(0x0B20243B), blurRadius: 24, offset: Offset(0, 8)),
  ],
);
