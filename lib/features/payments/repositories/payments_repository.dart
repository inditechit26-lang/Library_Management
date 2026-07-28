import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/activity_log_model.dart';
import '../../../core/utils/error_handler.dart';
import '../../receipts/models/receipt_model.dart';
import '../models/payment_model.dart';

abstract class BasePaymentsRepository {
  Stream<List<PaymentModel>> watchPayments(String libraryId);
  Future<void> addPayment({
    required String libraryId,
    required PaymentModel payment,
    required ReceiptModel receipt,
  });
}

class PaymentsRepository implements BasePaymentsRepository {
  final FirebaseFirestore _firestore;

  PaymentsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _paymentsRef(String libraryId) {
    return _firestore.collection('libraries').doc(libraryId).collection('payments');
  }

  @override
  Stream<List<PaymentModel>> watchPayments(String libraryId) {
    return _paymentsRef(libraryId)
        .orderBy('paymentDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PaymentModel.fromFirestore(doc)).toList());
  }

  @override
  Future<void> addPayment({
    required String libraryId,
    required PaymentModel payment,
    required ReceiptModel receipt,
  }) async {
    try {
      final batch = _firestore.batch();
      final libRef = _firestore.collection('libraries').doc(libraryId);

      final payDoc = libRef.collection('payments').doc(payment.id);
      batch.set(payDoc, payment.toFirestore());

      final receiptDoc = libRef.collection('receipts').doc(receipt.receiptNumber);
      batch.set(receiptDoc, receipt.toFirestore());

      final activityDoc = libRef.collection('activity').doc();
      batch.set(
        activityDoc,
        ActivityLogModel(
          id: activityDoc.id,
          title: 'Payment Received',
          description: 'Payment ₹${payment.netAmount} received from ${payment.studentName} via ${payment.paymentMode}.',
          type: 'payment_added',
          timestamp: DateTime.now(),
        ).toFirestore(),
      );

      await batch.commit();
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }
}
