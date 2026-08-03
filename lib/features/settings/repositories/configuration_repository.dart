import '../../../core/repositories/library_scoped_repository.dart';
import '../../../core/services/firestore_service.dart';

class ConfigurationRepository extends LibraryScopedRepository {
  const ConfigurationRepository(FirestoreService service) : super(service);
  Stream<Map<String, dynamic>> watchConfiguration() =>
      watchModule('configuration');
  Future<void> updateConfiguration(Map<String, dynamic> data) =>
      updateModule('configuration', data);
}
