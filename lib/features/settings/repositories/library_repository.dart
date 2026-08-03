import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/firestore_paths.dart';

class LibraryRecord {
  const LibraryRecord({required this.id, required this.data});
  final String id;
  final Map<String, dynamic> data;
}

class LibraryRepository {
  LibraryRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<LibraryRecord>> watchLibraries(String uid) => _firestore
      .collection(FirestorePaths.libraries(uid))
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (document) =>
                  LibraryRecord(id: document.id, data: document.data()),
            )
            .toList(),
      );
}
