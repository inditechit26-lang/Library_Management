import '../../../core/repositories/library_scoped_repository.dart';
import '../../../core/services/firestore_service.dart';

class TemplateRepository extends LibraryScopedRepository {
  const TemplateRepository(FirestoreService service) : super(service);
  Stream<Map<String, dynamic>> watchTemplates() => watchModule('templates');
  Future<void> updateTemplates(Map<String, dynamic> data) =>
      updateModule('templates', data);
}
