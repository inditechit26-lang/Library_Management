enum PaymentStatus { paid, pending, expired }

enum MembershipType { fullTime, halfTime }

class Student {
  final int id;
  final String name, phone, seat, joined, expiry, initials;
  final String? seatId;
  final String? photoPath;
  final String emergencyContact, notes;
  final String? previousExpiry;
  final double fee;
  final PaymentStatus payment;
  final MembershipType membership;
  final bool hasRenewedPlan;
  const Student({
    required this.id,
    required this.name,
    required this.phone,
    required this.seat,
    required this.joined,
    required this.expiry,
    required this.fee,
    required this.payment,
    required this.membership,
    required this.initials,
    this.seatId,
    this.photoPath,
    this.emergencyContact = '',
    this.notes = '',
    this.previousExpiry,
    this.hasRenewedPlan = false,
  });
  Student copyWith({
    String? name,
    String? phone,
    String? seat,
    String? seatId,
    String? photoPath,
    String? emergencyContact,
    String? notes,
    String? expiry,
    double? fee,
    PaymentStatus? payment,
    MembershipType? membership,
    String? previousExpiry,
    bool? hasRenewedPlan,
  }) => Student(
    id: id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    seat: seat ?? this.seat,
    seatId: seatId ?? this.seatId,
    photoPath: photoPath ?? this.photoPath,
    emergencyContact: emergencyContact ?? this.emergencyContact,
    notes: notes ?? this.notes,
    joined: joined,
    expiry: expiry ?? this.expiry,
    fee: fee ?? this.fee,
    payment: payment ?? this.payment,
    membership: membership ?? this.membership,
    previousExpiry: previousExpiry ?? this.previousExpiry,
    hasRenewedPlan: hasRenewedPlan ?? this.hasRenewedPlan,
    initials: name == null
        ? initials
        : name
              .trim()
              .split(RegExp(r'\s+'))
              .where((part) => part.isNotEmpty)
              .take(2)
              .map((part) => part[0].toUpperCase())
              .join(),
  );
}
