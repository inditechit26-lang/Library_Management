import '../../../core/repositories/library_scoped_repository.dart';
import '../../../core/services/firestore_paths.dart';
import '../../../core/services/firestore_service.dart';

class DocumentRepository extends LibraryScopedRepository {
  const DocumentRepository(FirestoreService service) : super(service);
  Stream<List<Map<String, dynamic>>> watchDocuments() =>
      watchCollection(FirestorePaths.documents);
  Future<void> saveDocument(String id, Map<String, dynamic> data) =>
      setRecord(FirestorePaths.documents, id, data);
  Future<void> deleteDocument(String id) =>
      deleteRecord(FirestorePaths.documents, id);
}
