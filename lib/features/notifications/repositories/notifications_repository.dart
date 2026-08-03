import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/firestore_paths.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/utils/error_handler.dart';

abstract class BaseNotificationsRepository {
  Stream<List<Map<String, dynamic>>> watchNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> dismiss(String notificationId);
}

/// Notifications are projections of the real per-library activity log.
/// This avoids an unused notification map while keeping the screen persistent.
class NotificationsRepository implements BaseNotificationsRepository {
  NotificationsRepository(this._service);
  final FirestoreService _service;

  CollectionReference<Map<String, dynamic>> get _activities =>
      _service.collection(FirestorePaths.activityLogs);

  @override
  Stream<List<Map<String, dynamic>>> watchNotifications() => _activities
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((document) => {'id': document.id, ...document.data()})
            .toList(),
      );

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _activities.doc(notificationId).update({'isRead': true});
    } catch (error, stackTrace) {
      throw ErrorHandler.handle(error, stackTrace);
    }
  }

  @override
  Future<void> dismiss(String notificationId) async {
    try {
      await _activities.doc(notificationId).delete();
    } catch (error, stackTrace) {
      throw ErrorHandler.handle(error, stackTrace);
    }
  }
}
