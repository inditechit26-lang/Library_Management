import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/activity_log_model.dart';
import '../../../core/services/firestore_paths.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../receipts/models/receipt_model.dart';
import '../models/payment_model.dart';

abstract class BasePaymentsRepository {
  Stream<List<PaymentModel>> watchPayments();
  Future<void> addPayment({
    required PaymentModel payment,
    required ReceiptModel receipt,
  });
}

class PaymentsRepository implements BasePaymentsRepository {
  PaymentsRepository(this._service);
  final FirestoreService _service;
  FirebaseFirestore get _firestore => _service.firestore;
  CollectionReference get _paymentsRef =>
      _service.collection(FirestorePaths.payments);

  @override
  Stream<List<PaymentModel>> watchPayments() {
    return _paymentsRef
        .orderBy('paymentDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PaymentModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<void> addPayment({
    required PaymentModel payment,
    required ReceiptModel receipt,
  }) async {
    try {
      final batch = _firestore.batch();

      final payDoc = _paymentsRef.doc(payment.id);
      batch.set(payDoc, payment.toFirestore());

      final receiptDoc = _service
          .collection(FirestorePaths.receipts)
          .doc(receipt.receiptNumber);
      batch.set(receiptDoc, receipt.toFirestore());

      final activityDoc = _service
          .collection(FirestorePaths.activityLogs)
          .doc();
      batch.set(
        activityDoc,
        ActivityLogModel(
          id: activityDoc.id,
          title: 'Payment Received',
          description:
              'Payment ₹${payment.netAmount} received from ${payment.studentName} via ${payment.paymentMode}.',
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
