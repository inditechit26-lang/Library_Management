import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String id;
  final String studentId;
  final String studentName;
  final double amount;
  final double discount;
  final double fine;
  final double netAmount;
  final String paymentMode; // Cash, UPI, Bank
  final String receiptNumber;
  final DateTime paymentDate;
  final String? remarks;

  const PaymentModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.amount,
    this.discount = 0.0,
    this.fine = 0.0,
    required this.netAmount,
    required this.paymentMode,
    required this.receiptNumber,
    required this.paymentDate,
    this.remarks,
  });

  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PaymentModel(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      discount: (data['discount'] as num?)?.toDouble() ?? 0.0,
      fine: (data['fine'] as num?)?.toDouble() ?? 0.0,
      netAmount: (data['netAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMode: data['paymentMode'] ?? 'Cash',
      receiptNumber: data['receiptNumber'] ?? '',
      paymentDate: (data['paymentDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      remarks: data['remarks'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'amount': amount,
      'discount': discount,
      'fine': fine,
      'netAmount': netAmount,
      'paymentMode': paymentMode,
      'receiptNumber': receiptNumber,
      'paymentDate': Timestamp.fromDate(paymentDate),
      'remarks': remarks,
    };
  }
}
