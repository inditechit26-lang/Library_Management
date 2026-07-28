import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../repositories/notifications_repository.dart';

final notificationsRepositoryProvider = Provider<BaseNotificationsRepository>((ref) {
  return NotificationsRepository();
});

final notificationsStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final libraryId = ref.watch(currentLibraryIdProvider);
  if (libraryId == null || libraryId.isEmpty) {
    return Stream.value([]);
  }
  final repository = ref.watch(notificationsRepositoryProvider);
  return repository.watchNotifications(libraryId);
});
