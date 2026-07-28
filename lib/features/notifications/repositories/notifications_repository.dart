import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/error_handler.dart';

abstract class BaseNotificationsRepository {
  Stream<List<Map<String, dynamic>>> watchNotifications(String libraryId);
  Future<void> markAsRead(String libraryId, String notificationId);
}

class NotificationsRepository implements BaseNotificationsRepository {
  final FirebaseFirestore _firestore;

  NotificationsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _notificationsRef(String libraryId) {
    return _firestore.collection('libraries').doc(libraryId).collection('notifications');
  }

  @override
  Stream<List<Map<String, dynamic>>> watchNotifications(String libraryId) {
    return _notificationsRef(libraryId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  @override
  Future<void> markAsRead(String libraryId, String notificationId) async {
    try {
      await _notificationsRef(libraryId).doc(notificationId).update({'isRead': true});
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }
}
