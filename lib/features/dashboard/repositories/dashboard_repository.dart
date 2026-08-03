import '../../../core/repositories/library_scoped_repository.dart';
import '../../../core/services/firestore_service.dart';

class DashboardRepository extends LibraryScopedRepository {
  const DashboardRepository(FirestoreService service) : super(service);
  Stream<Map<String, dynamic>> watchDashboard() => watchModule('dashboard');
  Future<void> updateDashboard(Map<String, dynamic> data) =>
      updateModule('dashboard', data);
}
