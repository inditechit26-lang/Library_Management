import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String gender;
  final String? assignedSeat;
  final String shift;
  final String planName;
  final String? membershipPeriod;
  final String? seatType;
  final String? sectionId;
  final double monthlyFee;
  final DateTime joiningDate;
  final DateTime validUntil;
  final String status;
  final String? photoUrl;
  final String? aadhaarFrontUrl;
  final String? aadhaarBackUrl;
  final String? documentUrl;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StudentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    this.assignedSeat,
    required this.shift,
    required this.planName,
    this.membershipPeriod,
    this.seatType,
    this.sectionId,
    required this.monthlyFee,
    required this.joiningDate,
    required this.validUntil,
    required this.status,
    this.photoUrl,
    this.aadhaarFrontUrl,
    this.aadhaarBackUrl,
    this.documentUrl,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return StudentModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      gender: data['gender'] ?? 'Male',
      assignedSeat: data['assignedSeat'],
      shift: data['shift'] ?? 'Full Day',
      planName: data['planName'] ?? 'Monthly Standard',
      membershipPeriod: data['membershipPeriod'],
      seatType: data['seatType'],
      sectionId: data['sectionId'],
      monthlyFee: (data['monthlyFee'] as num?)?.toDouble() ?? 0.0,
      joiningDate:
          (data['joiningDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      validUntil:
          (data['validUntil'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(days: 30)),
      status: data['status'] ?? 'Active',
      photoUrl: data['photoUrl'],
      aadhaarFrontUrl: data['aadhaarFrontUrl'],
      aadhaarBackUrl: data['aadhaarBackUrl'],
      documentUrl: data['documentUrl'],
      isDeleted: data['isDeleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'gender': gender,
      'assignedSeat': assignedSeat,
      'shift': shift,
      'planName': planName,
      'membershipPeriod': membershipPeriod,
      'seatType': seatType,
      'sectionId': sectionId,
      'monthlyFee': monthlyFee,
      'joiningDate': Timestamp.fromDate(joiningDate),
      'validUntil': Timestamp.fromDate(validUntil),
      'status': status,
      'photoUrl': photoUrl,
      'aadhaarFrontUrl': aadhaarFrontUrl,
      'aadhaarBackUrl': aadhaarBackUrl,
      'documentUrl': documentUrl,
      'isDeleted': isDeleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  StudentModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? gender,
    String? assignedSeat,
    String? shift,
    String? planName,
    String? membershipPeriod,
    String? seatType,
    String? sectionId,
    double? monthlyFee,
    DateTime? joiningDate,
    DateTime? validUntil,
    String? status,
    String? photoUrl,
    String? aadhaarFrontUrl,
    String? aadhaarBackUrl,
    String? documentUrl,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      assignedSeat: assignedSeat ?? this.assignedSeat,
      shift: shift ?? this.shift,
      planName: planName ?? this.planName,
      membershipPeriod: membershipPeriod ?? this.membershipPeriod,
      seatType: seatType ?? this.seatType,
      sectionId: sectionId ?? this.sectionId,
      monthlyFee: monthlyFee ?? this.monthlyFee,
      joiningDate: joiningDate ?? this.joiningDate,
      validUntil: validUntil ?? this.validUntil,
      status: status ?? this.status,
      photoUrl: photoUrl ?? this.photoUrl,
      aadhaarFrontUrl: aadhaarFrontUrl ?? this.aadhaarFrontUrl,
      aadhaarBackUrl: aadhaarBackUrl ?? this.aadhaarBackUrl,
      documentUrl: documentUrl ?? this.documentUrl,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
