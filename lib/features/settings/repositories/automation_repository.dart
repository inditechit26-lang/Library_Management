import '../../../core/repositories/library_scoped_repository.dart';
import '../../../core/services/firestore_service.dart';

class AutomationRepository extends LibraryScopedRepository {
  const AutomationRepository(FirestoreService service) : super(service);
  Stream<Map<String, dynamic>> watchAutomation() => watchModule('automation');
  Future<void> updateAutomation(Map<String, dynamic> data) =>
      updateModule('automation', data);
}
