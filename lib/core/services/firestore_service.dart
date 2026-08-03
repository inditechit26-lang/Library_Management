import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../exceptions/app_exception.dart';
import 'firestore_paths.dart';

/// Authenticated, library-scoped gateway used by every Firestore repository.
/// A scoped instance is recreated whenever the active library changes.
class FirestoreService {
  FirestoreService({
    required this.uid,
    required this.libraryId,
    FirebaseFirestore? firestore,
  }) : firestore = firestore ?? FirebaseFirestore.instance;

  final String uid;
  final String libraryId;
  final FirebaseFirestore firestore;

  factory FirestoreService.current({
    required String libraryId,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) {
    final uid = (auth ?? FirebaseAuth.instance).currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw const AuthException('Your session has expired.');
    }
    if (libraryId.isEmpty) {
      throw const ValidationException('No library is selected.');
    }
    return FirestoreService(
      uid: uid,
      libraryId: libraryId,
      firestore: firestore,
    );
  }

  DocumentReference<Map<String, dynamic>> get user =>
      firestore.doc(FirestorePaths.user(uid));

  CollectionReference<Map<String, dynamic>> get libraries =>
      firestore.collection(FirestorePaths.libraries(uid));

  DocumentReference<Map<String, dynamic>> get library =>
      firestore.doc(FirestorePaths.library(uid, libraryId));

  CollectionReference<Map<String, dynamic>> collection(
    String Function(String uid, String libraryId) path,
  ) => firestore.collection(path(uid, libraryId));
}
