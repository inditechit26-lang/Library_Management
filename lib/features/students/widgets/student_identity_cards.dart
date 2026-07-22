import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/student.dart';
import '../services/student_id_service.dart';

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
  Widget build(BuildContext context) => Container(
    height: compact ? 154 : null,
    padding: EdgeInsets.all(compact ? 11 : 18),
    decoration: _cardDecoration.copyWith(
      border: Border.all(color: const Color(0xFFD9D7F2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: compact ? 24 : 36,
              height: compact ? 24 : 36,
              decoration: BoxDecoration(
                color: const Color(0xFF5145C8),
                borderRadius: BorderRadius.circular(compact ? 7 : 11),
              ),
              alignment: Alignment.center,
              child: Text(
                'SR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 7 : 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            SizedBox(width: compact ? 6 : 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'THE STUDY ROOM',
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: compact ? 6.5 : 11,
                      letterSpacing: .4,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'DIGITAL MEMBER ID',
                    style: TextStyle(
                      fontSize: compact ? 5 : 7,
                      color: const Color(0xFF8C91A1),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? 9 : 16),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Photo(student: student, compact: compact),
              SizedBox(width: compact ? 7 : 13),
              Expanded(
                child: _Details(student: student, compact: compact),
              ),
              SizedBox(width: compact ? 4 : 9),
              QrImageView(
                data: StudentIdService.payload(student, revision: revision),
                size: compact ? 36 : 70,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        if (!compact) ...[
          const Divider(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ID  SR-${student.id.toString().padLeft(5, '0')}',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Valid until ${student.expiry}',
                style: const TextStyle(fontSize: 9, color: Color(0xFF777C8D)),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}

class _Photo extends StatelessWidget {
  final Student student;
  final bool compact;
  const _Photo({required this.student, required this.compact});
  @override
  Widget build(BuildContext context) => Container(
    width: compact ? 36 : 64,
    height: compact ? 46 : 78,
    decoration: BoxDecoration(
      color: const Color(0xFFEDECFB),
      borderRadius: BorderRadius.circular(compact ? 8 : 12),
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
            style: TextStyle(
              fontSize: compact ? 9 : 15,
              color: const Color(0xFF5145C8),
              fontWeight: FontWeight.w900,
            ),
          )
        : null,
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
        style: TextStyle(
          fontSize: compact ? 7 : 13,
          fontWeight: FontWeight.w900,
        ),
      ),
      SizedBox(height: compact ? 2 : 5),
      Text(
        student.membership == MembershipType.fullTime
            ? 'Full Time Member'
            : 'Half Time Member',
        maxLines: 1,
        style: TextStyle(
          fontSize: compact ? 5 : 9,
          color: const Color(0xFF5145C8),
          fontWeight: FontWeight.w700,
        ),
      ),
      const Spacer(),
      Text(
        'SEAT  ${student.seat}',
        maxLines: 1,
        style: TextStyle(
          fontSize: compact ? 6 : 10,
          fontWeight: FontWeight.w800,
        ),
      ),
      SizedBox(height: compact ? 2 : 4),
      Text(
        'JOINED  ${student.joined}',
        maxLines: 1,
        style: TextStyle(
          fontSize: compact ? 4.5 : 8,
          color: const Color(0xFF838899),
        ),
      ),
    ],
  );
}

final _cardDecoration = BoxDecoration(
  color: Colors.white,
  border: Border.all(color: const Color(0xFFE3E5EC)),
  borderRadius: BorderRadius.circular(20),
  boxShadow: const [
    BoxShadow(color: Color(0x0B20243B), blurRadius: 24, offset: Offset(0, 8)),
  ],
);
