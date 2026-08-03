import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firestore_paths.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/utils/error_handler.dart';
import '../models/receipt_model.dart';

abstract class BaseReceiptsRepository {
  Stream<List<ReceiptModel>> watchReceipts();
  Future<ReceiptModel?> getReceiptByNumber(String receiptNumber);
  Future<void> updateReceiptPdfUrl(String receiptNumber, String pdfUrl);
}

class ReceiptsRepository implements BaseReceiptsRepository {
  ReceiptsRepository(this._service);
  final FirestoreService _service;
  CollectionReference get _receiptsRef =>
      _service.collection(FirestorePaths.receipts);

  @override
  Stream<List<ReceiptModel>> watchReceipts() {
    return _receiptsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ReceiptModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<ReceiptModel?> getReceiptByNumber(String receiptNumber) async {
    try {
      final doc = await _receiptsRef.doc(receiptNumber).get();
      if (!doc.exists) return null;
      return ReceiptModel.fromFirestore(doc);
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<void> updateReceiptPdfUrl(String receiptNumber, String pdfUrl) async {
    try {
      await _receiptsRef.doc(receiptNumber).update({'pdfStorageUrl': pdfUrl});
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }
}
