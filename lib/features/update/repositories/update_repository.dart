import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/update_info.dart';

class UpdateRepository {
  final FirebaseFirestore _firestore;

  UpdateRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<UpdateInfo?> getAndroidUpdateInfo() async {
    try {
      final doc = await _firestore.collection('appUpdate').doc('android').get();
      if (!doc.exists) return null;
      return UpdateInfo.fromFirestore(doc);
    } catch (_) {
      return null;
    }
  }

  Stream<UpdateInfo?> watchAndroidUpdateInfo() {
    return _firestore
        .collection('appUpdate')
        .doc('android')
        .snapshots()
        .map((doc) => doc.exists ? UpdateInfo.fromFirestore(doc) : null);
  }
}
