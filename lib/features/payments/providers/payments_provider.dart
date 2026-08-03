import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/payment_model.dart';
import '../repositories/payments_repository.dart';

final paymentsRepositoryProvider = Provider<BasePaymentsRepository>((ref) {
  return PaymentsRepository(ref.watch(firestoreServiceProvider)!);
});

final paymentsStreamProvider = StreamProvider<List<PaymentModel>>((ref) {
  final libraryId = ref.watch(currentLibraryIdProvider);
  if (libraryId == null || libraryId.isEmpty) {
    return Stream.value([]);
  }
  final repository = ref.watch(paymentsRepositoryProvider);
  return repository.watchPayments();
});

final totalRevenueProvider = Provider<double>((ref) {
  final paymentsAsync = ref.watch(paymentsStreamProvider);
  return paymentsAsync.maybeWhen(
    data: (payments) => payments.fold(0.0, (sum, p) => sum + p.netAmount),
    orElse: () => 0.0,
  );
});
