enum SeatStatus { available, occupied, reserved, unavailable }

class Seat {
  final String number;
  final SeatStatus status;
  const Seat(this.number, this.status);
}
