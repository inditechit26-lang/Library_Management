import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shelf_flutter/features/payments/models/payment_model.dart';
import 'package:shelf_flutter/features/receipts/services/receipt_service.dart';
import 'package:shelf_flutter/features/settings/models/billing_details.dart';
import 'package:shelf_flutter/features/students/models/student.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('generates a complete reference-style payment receipt', () async {
    final bytes = await ReceiptService.generate(
      const Student(
        id: 1,
        sourceId: 'STU-0001',
        name: 'Rahul Sharma',
        phone: '+91 98765 43210',
        email: 'rahul.sharma@email.com',
        gender: 'Male',
        emergencyContact: '+91 99887 76655',
        seat: 'A1',
        joined: '18 Jan 2026',
        previousExpiry: '18 Aug 2026',
        expiry: '18 Sep 2026',
        fee: 1800,
        payment: PaymentStatus.paid,
        membership: MembershipType.fullTime,
        category: SeatCategory.ac,
        paymentMode: PaymentMode.upi,
        initials: 'RS',
      ),
      payment: PaymentModel(
        id: 'pay-1',
        studentId: 'STU-0001',
        studentName: 'Rahul Sharma',
        amount: 1800,
        netAmount: 1800,
        paymentMode: 'UPI / Digital Transfer',
        receiptNumber: 'SH-2026-0001',
        paymentDate: DateTime(2026, 7, 23, 23, 12),
      ),
      billingDetails: const BillingDetails(
        businessName: 'StudyHub',
        address: '456, Knowledge Street, Connaught Place, New Delhi - 110001',
        phone: '+91 98765 43210',
        email: 'info@studyhub.com',
        website: 'www.studyhub.com',
        taxId: 'GSTIN 07ABCDE1234F1Z5',
        receiptPrefix: 'SH',
      ),
    );

    expect(bytes.length, greaterThan(5000));
    final output = Directory('output/pdf')..createSync(recursive: true);
    File(
      '${output.path}/payment_receipt_reference_sample.pdf',
    ).writeAsBytesSync(bytes);
  });
}
