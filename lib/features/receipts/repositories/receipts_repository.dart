import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/error_handler.dart';
import '../models/receipt_model.dart';

abstract class BaseReceiptsRepository {
  Stream<List<ReceiptModel>> watchReceipts(String libraryId);
  Future<ReceiptModel?> getReceiptByNumber(String libraryId, String receiptNumber);
  Future<void> updateReceiptPdfUrl(String libraryId, String receiptNumber, String pdfUrl);
}

class ReceiptsRepository implements BaseReceiptsRepository {
  final FirebaseFirestore _firestore;

  ReceiptsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _receiptsRef(String libraryId) {
    return _firestore.collection('libraries').doc(libraryId).collection('receipts');
  }

  @override
  Stream<List<ReceiptModel>> watchReceipts(String libraryId) {
    return _receiptsRef(libraryId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ReceiptModel.fromFirestore(doc)).toList());
  }

  @override
  Future<ReceiptModel?> getReceiptByNumber(String libraryId, String receiptNumber) async {
    try {
      final doc = await _receiptsRef(libraryId).doc(receiptNumber).get();
      if (!doc.exists) return null;
      return ReceiptModel.fromFirestore(doc);
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<void> updateReceiptPdfUrl(String libraryId, String receiptNumber, String pdfUrl) async {
    try {
      await _receiptsRef(libraryId).doc(receiptNumber).update({'pdfStorageUrl': pdfUrl});
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }
}
