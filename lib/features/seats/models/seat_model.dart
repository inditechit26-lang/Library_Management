import 'package:cloud_firestore/cloud_firestore.dart';

enum SeatStatus { available, occupied, maintenance, blocked }

class SeatModel {
  final String seatNumber;
  final SeatStatus status;
  final String? studentId;
  final String? studentName;
  final String? studentPhone;
  final String? shift;
  final DateTime? assignedDate;
  final DateTime? expiryDate;
  final String? blockReason;

  const SeatModel({
    required this.seatNumber,
    this.status = SeatStatus.available,
    this.studentId,
    this.studentName,
    this.studentPhone,
    this.shift,
    this.assignedDate,
    this.expiryDate,
    this.blockReason,
  });

  factory SeatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final statusStr = data['status'] ?? 'available';
    SeatStatus statusEnum = SeatStatus.available;
    if (statusStr == 'occupied') statusEnum = SeatStatus.occupied;
    if (statusStr == 'maintenance') statusEnum = SeatStatus.maintenance;
    if (statusStr == 'blocked') statusEnum = SeatStatus.blocked;

    return SeatModel(
      seatNumber: doc.id,
      status: statusEnum,
      studentId: data['studentId'],
      studentName: data['studentName'],
      studentPhone: data['studentPhone'],
      shift: data['shift'],
      assignedDate: (data['assignedDate'] as Timestamp?)?.toDate(),
      expiryDate: (data['expiryDate'] as Timestamp?)?.toDate(),
      blockReason: data['blockReason'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'seatNumber': seatNumber,
      'status': status.name,
      'studentId': studentId,
      'studentName': studentName,
      'studentPhone': studentPhone,
      'shift': shift,
      'assignedDate': assignedDate != null
          ? Timestamp.fromDate(assignedDate!)
          : null,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'blockReason': blockReason,
    };
  }

  SeatModel copyWith({
    String? seatNumber,
    SeatStatus? status,
    String? studentId,
    String? studentName,
    String? studentPhone,
    String? shift,
    DateTime? assignedDate,
    DateTime? expiryDate,
    String? blockReason,
  }) {
    return SeatModel(
      seatNumber: seatNumber ?? this.seatNumber,
      status: status ?? this.status,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentPhone: studentPhone ?? this.studentPhone,
      shift: shift ?? this.shift,
      assignedDate: assignedDate ?? this.assignedDate,
      expiryDate: expiryDate ?? this.expiryDate,
      blockReason: blockReason ?? this.blockReason,
    );
  }
}
