import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/seat.dart';

class SeatsController extends Notifier<List<Seat>> {
  @override
  List<Seat> build() => List.generate(40, (i) {
    final n = '${String.fromCharCode(65 + i ~/ 10)}${i % 10 + 1}';
    return Seat(
      n,
      ['A1', 'A2', 'B1', 'B3', 'C2', 'D1'].contains(n)
          ? SeatStatus.occupied
          : ['C9', 'D8'].contains(n)
          ? SeatStatus.reserved
          : n == 'D10'
          ? SeatStatus.unavailable
          : SeatStatus.available,
    );
  });
}

final seatsProvider = NotifierProvider<SeatsController, List<Seat>>(
  SeatsController.new,
);
