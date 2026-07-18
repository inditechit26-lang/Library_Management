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
          ? SeatStatus.maintenance
          : SeatStatus.available,
    );
  });

  void assign(String number, {String? previousSeat}) {
    state = [
      for (final seat in state)
        if (seat.number == previousSeat)
          seat.copyWith(status: SeatStatus.available)
        else if (seat.number == number)
          seat.copyWith(status: SeatStatus.occupied)
        else
          seat,
    ];
  }

  void release(String number) => setStatus(number, SeatStatus.available);

  void setStatus(String number, SeatStatus status) => state = [
    for (final seat in state)
      if (seat.number == number) seat.copyWith(status: status) else seat,
  ];

  void generate({required int rows, required int columns}) {
    state = List.generate(rows * columns, (index) {
      final row = String.fromCharCode(65 + index ~/ columns);
      return Seat('$row${index % columns + 1}', SeatStatus.available);
    });
  }
}

final seatsProvider = NotifierProvider<SeatsController, List<Seat>>(
  SeatsController.new,
);
