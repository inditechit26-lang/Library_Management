import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/plan_model.dart';
import '../repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<BaseSettingsRepository>((ref) {
  return SettingsRepository(ref.watch(firestoreServiceProvider)!);
});

final libraryInfoProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final libraryId = ref.watch(currentLibraryIdProvider);
  if (libraryId == null || libraryId.isEmpty) {
    return Stream.value({});
  }
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.watchLibraryInfo();
});

final libraryConfigProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final libraryId = ref.watch(currentLibraryIdProvider);
  if (libraryId == null || libraryId.isEmpty) {
    return Stream.value({});
  }
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.watchLibraryConfig();
});

final plansStreamProvider = StreamProvider<List<PlanModel>>((ref) {
  final libraryId = ref.watch(currentLibraryIdProvider);
  if (libraryId == null || libraryId.isEmpty) {
    return Stream.value([]);
  }
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.watchPlans();
});
