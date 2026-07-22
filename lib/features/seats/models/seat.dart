enum SeatStatus { available, occupied, reserved, maintenance, blocked }

enum SeatViewMode { floor, grid, list }

/// A seat's identity is always [seatId]. [seatLabel] is presentation data and
/// can be changed without breaking assignments, routes, or history.
class Seat {
  final String seatId;
  final String seatLabel;
  final SeatStatus status;
  final int? studentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Seat({
    required this.seatId,
    required this.seatLabel,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.studentId,
  });

  Seat copyWith({
    String? seatLabel,
    SeatStatus? status,
    int? studentId,
    bool clearStudent = false,
    DateTime? updatedAt,
  }) => Seat(
    seatId: seatId,
    seatLabel: seatLabel ?? this.seatLabel,
    status: status ?? this.status,
    studentId: clearStudent ? null : studentId ?? this.studentId,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
