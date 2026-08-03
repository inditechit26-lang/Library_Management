import '../../../core/repositories/library_scoped_repository.dart';
import '../../../core/services/firestore_paths.dart';
import '../../../core/services/firestore_service.dart';

class ReportRepository extends LibraryScopedRepository {
  const ReportRepository(FirestoreService service) : super(service);
  Stream<List<Map<String, dynamic>>> watchReports() =>
      watchCollection(FirestorePaths.reports);
  Future<void> saveReport(String id, Map<String, dynamic> data) =>
      setRecord(FirestorePaths.reports, id, data);
  Future<void> deleteReport(String id) =>
      deleteRecord(FirestorePaths.reports, id);
}
