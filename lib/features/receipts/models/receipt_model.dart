import 'package:cloud_firestore/cloud_firestore.dart';

class ReceiptModel {
  final String receiptNumber;
  final String studentId;
  final String studentName;
  final String paymentId;
  final double amount;
  final String? pdfStorageUrl;
  final DateTime createdAt;

  const ReceiptModel({
    required this.receiptNumber,
    required this.studentId,
    required this.studentName,
    required this.paymentId,
    required this.amount,
    this.pdfStorageUrl,
    required this.createdAt,
  });

  factory ReceiptModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ReceiptModel(
      receiptNumber: doc.id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      paymentId: data['paymentId'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      pdfStorageUrl: data['pdfStorageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'receiptNumber': receiptNumber,
      'studentId': studentId,
      'studentName': studentName,
      'paymentId': paymentId,
      'amount': amount,
      'pdfStorageUrl': pdfStorageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
