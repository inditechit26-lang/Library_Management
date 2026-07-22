import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/seat.dart';

class SeatsController extends Notifier<List<Seat>> {
  @override
  List<Seat> build() {
    final now = DateTime.now();
    const assignments = {'A1': 1, 'A2': 2, 'B1': 3, 'B3': 4, 'C2': 5, 'D1': 6};
    return List.generate(40, (index) {
      final label = '${String.fromCharCode(65 + index ~/ 10)}${index % 10 + 1}';
      final studentId = assignments[label];
      final status = studentId != null
          ? SeatStatus.occupied
          : {'C9', 'D8'}.contains(label)
          ? SeatStatus.reserved
          : label == 'D10'
          ? SeatStatus.maintenance
          : SeatStatus.available;
      return Seat(
        seatId: 'seat-${index + 1}',
        seatLabel: label,
        status: status,
        studentId: studentId,
        createdAt: now,
        updatedAt: now,
      );
    });
  }

  String _newId() => 'seat-${DateTime.now().microsecondsSinceEpoch}';

  void assign(String seatId, int studentId, {String? previousSeatId}) {
    final now = DateTime.now();
    state = [
      for (final seat in state)
        if (seat.seatId == previousSeatId)
          seat.copyWith(
            status: SeatStatus.available,
            clearStudent: true,
            updatedAt: now,
          )
        else if (seat.seatId == seatId)
          seat.copyWith(
            status: SeatStatus.occupied,
            studentId: studentId,
            updatedAt: now,
          )
        else
          seat,
    ];
  }

  void release(String seatId) => _update(
    seatId,
    (seat) => seat.copyWith(status: SeatStatus.available, clearStudent: true),
  );

  void setStatus(String seatId, SeatStatus status) => _update(
    seatId,
    (seat) => seat.copyWith(
      status: status,
      clearStudent: status != SeatStatus.occupied,
    ),
  );

  void rename(String seatId, String label) =>
      _update(seatId, (seat) => seat.copyWith(seatLabel: label.trim()));

  Seat add(String label) {
    final now = DateTime.now();
    final seat = Seat(
      seatId: _newId(),
      seatLabel: label.trim(),
      status: SeatStatus.available,
      createdAt: now,
      updatedAt: now,
    );
    state = [...state, seat];
    return seat;
  }

  bool delete(String seatId) {
    final seat = state.firstWhere((item) => item.seatId == seatId);
    if (seat.studentId != null || seat.status == SeatStatus.occupied) {
      return false;
    }
    state = state.where((item) => item.seatId != seatId).toList();
    return true;
  }

  void generateNumeric(int total) =>
      _replaceLabels(List.generate(total, (index) => '${index + 1}'));

  void generateAlphabetic(int rows, int perRow) => _replaceLabels([
    for (var row = 0; row < rows; row++)
      for (var seat = 1; seat <= perRow; seat++)
        '${String.fromCharCode(65 + row)}$seat',
  ]);

  void resetStatuses() {
    final now = DateTime.now();
    state = [
      for (final seat in state)
        seat.copyWith(
          status: SeatStatus.available,
          clearStudent: true,
          updatedAt: now,
        ),
    ];
  }

  void deleteAll() => state = [];

  void replaceAll(List<String> labels) => _replaceLabels(labels);

  void _replaceLabels(List<String> labels) {
    final now = DateTime.now();
    state = [
      for (var index = 0; index < labels.length; index++)
        Seat(
          seatId: '${_newId()}-$index',
          seatLabel: labels[index],
          status: SeatStatus.available,
          createdAt: now,
          updatedAt: now,
        ),
    ];
  }

  void _update(String seatId, Seat Function(Seat) update) {
    final now = DateTime.now();
    state = [
      for (final seat in state)
        if (seat.seatId == seatId)
          update(seat).copyWith(updatedAt: now)
        else
          seat,
    ];
  }
}

final seatsProvider = NotifierProvider<SeatsController, List<Seat>>(
  SeatsController.new,
);
