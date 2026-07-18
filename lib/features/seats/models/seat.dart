enum SeatStatus { available, occupied, reserved, maintenance, blocked }

enum SeatViewMode { floor, grid, list }

class Seat {
  final String number;
  final SeatStatus status;
  const Seat(this.number, this.status);

  String get row => number.replaceAll(RegExp(r'\d'), '');
  Seat copyWith({SeatStatus? status}) => Seat(number, status ?? this.status);
}
