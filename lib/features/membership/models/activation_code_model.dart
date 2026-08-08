import 'package:cloud_firestore/cloud_firestore.dart';

class ActivationCodeModel {
  const ActivationCodeModel({
    required this.code,
    required this.status,
    required this.plan,
    required this.durationDays,
    this.createdAt,
    this.activatedAt,
    this.assignedToUid,
    this.assignedEmail,
    this.assignedLibrary,
  });

  final String code;
  final String status;
  final String plan;
  final int durationDays;
  final DateTime? createdAt;
  final DateTime? activatedAt;
  final String? assignedToUid;
  final String? assignedEmail;
  final String? assignedLibrary;

  factory ActivationCodeModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return ActivationCodeModel(
      code: data['code'] as String? ?? snapshot.id,
      status: data['status'] as String? ?? 'unused',
      plan: data['plan'] as String? ?? 'Standard',
      durationDays: (data['durationDays'] as num?)?.toInt() ?? 365,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      activatedAt: (data['activatedAt'] as Timestamp?)?.toDate(),
      assignedToUid: data['assignedToUid'] as String?,
      assignedEmail: data['assignedEmail'] as String?,
      assignedLibrary: data['assignedLibrary'] as String?,
    );
  }
}
