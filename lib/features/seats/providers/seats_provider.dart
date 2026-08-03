import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/seat_model.dart';
import '../repositories/seats_repository.dart';

final seatsRepositoryProvider = Provider<BaseSeatsRepository>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return service == null
      ? const _NoopSeatsRepository()
      : SeatsRepository(service);
});

final seatsStreamProvider = StreamProvider<List<SeatModel>>((ref) {
  final libraryId = ref.watch(currentLibraryIdProvider);
  if (libraryId == null || libraryId.isEmpty) {
    return Stream.value([]);
  }
  final repository = ref.watch(seatsRepositoryProvider);
  return repository.watchSeats();
});

class _NoopSeatsRepository implements BaseSeatsRepository {
  const _NoopSeatsRepository();
  @override
  Stream<List<SeatModel>> watchSeats() => Stream.value([]);
  @override
  Future<void> updateSeatStatus(SeatModel seat) async {}
  @override
  Future<void> transferSeat({
    required String fromSeatNumber,
    required String toSeatNumber,
    required String studentId,
    required String studentName,
  }) async {}
  @override
  Future<void> blockSeat(String seatNumber, String reason) async {}
  @override
  Future<void> unblockSeat(String seatNumber) async {}
  @override
  Future<Map<String, Map<String, dynamic>>> getSeatData() async => {};
  @override
  Future<void> setSeat(String id, Map<String, dynamic> data) async {}
  @override
  Future<void> setSeats(Map<String, Map<String, dynamic>> seats) async {}
  @override
  Future<void> deleteSeats(Iterable<String> ids) async {}
  @override
  Future<void> replaceSeats({
    required Iterable<String> deleteIds,
    required Map<String, Map<String, dynamic>> seats,
  }) async {}
}

final seatsProvider = Provider<List<SeatModel>>((ref) {
  final asyncVal = ref.watch(seatsStreamProvider);
  return asyncVal.maybeWhen(data: (seats) => seats, orElse: () => []);
});

final seatMetricsProvider = Provider<Map<String, int>>((ref) {
  final seats = ref.watch(seatsProvider);
  int occupied = seats.where((s) => s.status == SeatStatus.occupied).length;
  int available = seats.where((s) => s.status == SeatStatus.available).length;
  int maintenance = seats
      .where((s) => s.status == SeatStatus.maintenance)
      .length;
  int blocked = seats.where((s) => s.status == SeatStatus.blocked).length;
  return {
    'total': seats.length,
    'occupied': occupied,
    'available': available,
    'maintenance': maintenance,
    'blocked': blocked,
  };
});
