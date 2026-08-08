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
  final String? sectionId;

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
    this.sectionId,
  });

  factory SeatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    // Section-based seat documents use an internal ID such as `room_a_A1`
    // so that two rooms may both contain `A1`. The configured seat label is
    // stored in `seatNumber` and is the only value that should be shown in
    // the Seats tab.
    final configuredLabel = (data['seatNumber'] as String?)?.trim();
    final statusStr = data['status'] ?? 'available';
    SeatStatus statusEnum = SeatStatus.available;
    if (statusStr == 'occupied') statusEnum = SeatStatus.occupied;
    if (statusStr == 'maintenance') statusEnum = SeatStatus.maintenance;
    if (statusStr == 'blocked') statusEnum = SeatStatus.blocked;

    return SeatModel(
      seatNumber: configuredLabel?.isNotEmpty == true
          ? configuredLabel!
          : doc.id,
      status: statusEnum,
      studentId: data['studentId'],
      studentName: data['studentName'],
      studentPhone: data['studentPhone'],
      shift: data['shift'],
      assignedDate: (data['assignedDate'] as Timestamp?)?.toDate(),
      expiryDate: (data['expiryDate'] as Timestamp?)?.toDate(),
      blockReason: data['blockReason'],
      sectionId: data['sectionId'],
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
      'sectionId': sectionId,
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
