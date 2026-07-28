import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/seat_model.dart';
import '../repositories/seats_repository.dart';

final seatsRepositoryProvider = Provider<BaseSeatsRepository>((ref) {
  return SeatsRepository();
});

final seatsStreamProvider = StreamProvider<List<SeatModel>>((ref) {
  final libraryId = ref.watch(currentLibraryIdProvider);
  if (libraryId == null || libraryId.isEmpty) {
    return Stream.value([]);
  }
  final repository = ref.watch(seatsRepositoryProvider);
  return repository.watchSeats(libraryId);
});

final seatsProvider = Provider<List<SeatModel>>((ref) {
  final asyncVal = ref.watch(seatsStreamProvider);
  return asyncVal.maybeWhen(
    data: (seats) => seats,
    orElse: () => [],
  );
});

final seatMetricsProvider = Provider<Map<String, int>>((ref) {
  final seats = ref.watch(seatsProvider);
  int occupied = seats.where((s) => s.status == SeatStatus.occupied).length;
  int available = seats.where((s) => s.status == SeatStatus.available).length;
  int maintenance = seats.where((s) => s.status == SeatStatus.maintenance).length;
  int blocked = seats.where((s) => s.status == SeatStatus.blocked).length;
  return {
    'total': seats.length,
    'occupied': occupied,
    'available': available,
    'maintenance': maintenance,
    'blocked': blocked,
  };
});
