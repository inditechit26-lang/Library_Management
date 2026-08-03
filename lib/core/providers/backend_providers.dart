import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/admissions/repositories/admission_repository.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/dashboard/repositories/dashboard_repository.dart';
import '../../features/reports/repositories/report_repository.dart';
import '../../features/settings/repositories/automation_repository.dart';
import '../../features/settings/repositories/configuration_repository.dart';
import '../../features/settings/repositories/template_repository.dart';
import '../../features/students/repositories/document_repository.dart';

final authenticationProvider = authStateProvider;
final currentLibraryProvider = currentLibraryIdProvider;

final admissionRepositoryProvider = Provider<AdmissionRepository>(
  (ref) => AdmissionRepository(ref.watch(firestoreServiceProvider)!),
);
final admissionProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  if (ref.watch(currentLibraryIdProvider) == null) return Stream.value([]);
  return ref.watch(admissionRepositoryProvider).watchAdmissions();
});

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => DashboardRepository(ref.watch(firestoreServiceProvider)!),
);
final dashboardProvider = StreamProvider<Map<String, dynamic>>((ref) {
  if (ref.watch(currentLibraryIdProvider) == null) return Stream.value({});
  return ref.watch(dashboardRepositoryProvider).watchDashboard();
});

final configurationRepositoryProvider = Provider<ConfigurationRepository>(
  (ref) => ConfigurationRepository(ref.watch(firestoreServiceProvider)!),
);
final configurationProvider = StreamProvider<Map<String, dynamic>>((ref) {
  if (ref.watch(currentLibraryIdProvider) == null) return Stream.value({});
  return ref.watch(configurationRepositoryProvider).watchConfiguration();
});

final documentRepositoryProvider = Provider<DocumentRepository>(
  (ref) => DocumentRepository(ref.watch(firestoreServiceProvider)!),
);
final documentProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  if (ref.watch(currentLibraryIdProvider) == null) return Stream.value([]);
  return ref.watch(documentRepositoryProvider).watchDocuments();
});

final automationRepositoryProvider = Provider<AutomationRepository>(
  (ref) => AutomationRepository(ref.watch(firestoreServiceProvider)!),
);
final automationProvider = StreamProvider<Map<String, dynamic>>((ref) {
  if (ref.watch(currentLibraryIdProvider) == null) return Stream.value({});
  return ref.watch(automationRepositoryProvider).watchAutomation();
});

final templateRepositoryProvider = Provider<TemplateRepository>(
  (ref) => TemplateRepository(ref.watch(firestoreServiceProvider)!),
);
final templateProvider = StreamProvider<Map<String, dynamic>>((ref) {
  if (ref.watch(currentLibraryIdProvider) == null) return Stream.value({});
  return ref.watch(templateRepositoryProvider).watchTemplates();
});

final reportRepositoryProvider = Provider<ReportRepository>(
  (ref) => ReportRepository(ref.watch(firestoreServiceProvider)!),
);
final reportProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  if (ref.watch(currentLibraryIdProvider) == null) return Stream.value([]);
  return ref.watch(reportRepositoryProvider).watchReports();
});
