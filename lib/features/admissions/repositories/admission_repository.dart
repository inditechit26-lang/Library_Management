import '../../../core/repositories/library_scoped_repository.dart';
import '../../../core/services/firestore_paths.dart';
import '../../../core/services/firestore_service.dart';

class AdmissionRepository extends LibraryScopedRepository {
  const AdmissionRepository(FirestoreService service) : super(service);
  Stream<List<Map<String, dynamic>>> watchAdmissions() =>
      watchCollection(FirestorePaths.admissions);
  Future<void> saveAdmission(String id, Map<String, dynamic> data) =>
      setRecord(FirestorePaths.admissions, id, data);
  Future<void> deleteAdmission(String id) =>
      deleteRecord(FirestorePaths.admissions, id);
}
