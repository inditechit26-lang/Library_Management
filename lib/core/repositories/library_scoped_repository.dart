import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firestore_service.dart';

abstract class LibraryScopedRepository {
  const LibraryScopedRepository(this.service);
  final FirestoreService service;

  Stream<Map<String, dynamic>> watchModule(String field) =>
      service.library.snapshots().map(
        (snapshot) => Map<String, dynamic>.from(
          snapshot.data()?[field] as Map? ?? const <String, dynamic>{},
        ),
      );

  Future<void> updateModule(String field, Map<String, dynamic> values) async {
    await service.firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(service.library);
      final data = Map<String, dynamic>.from(
        snapshot.data()?[field] as Map? ?? const <String, dynamic>{},
      )..addAll(values);
      data['updatedAt'] = FieldValue.serverTimestamp();
      transaction.update(service.library, {field: data});
    });
  }

  Stream<List<Map<String, dynamic>>> watchCollection(
    String Function(String, String) path,
  ) => service
      .collection(path)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((document) => {'id': document.id, ...document.data()})
            .toList(),
      );

  Future<void> setRecord(
    String Function(String, String) path,
    String id,
    Map<String, dynamic> data,
  ) => service.collection(path).doc(id).set(data, SetOptions(merge: true));

  Future<void> deleteRecord(String Function(String, String) path, String id) =>
      service.collection(path).doc(id).delete();
}
