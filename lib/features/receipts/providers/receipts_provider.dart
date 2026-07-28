import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/receipt_model.dart';
import '../repositories/receipts_repository.dart';

final receiptsRepositoryProvider = Provider<BaseReceiptsRepository>((ref) {
  return ReceiptsRepository();
});

final receiptsStreamProvider = StreamProvider<List<ReceiptModel>>((ref) {
  final libraryId = ref.watch(currentLibraryIdProvider);
  if (libraryId == null || libraryId.isEmpty) {
    return Stream.value([]);
  }
  final repository = ref.watch(receiptsRepositoryProvider);
  return repository.watchReceipts(libraryId);
});
