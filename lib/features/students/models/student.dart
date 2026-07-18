enum PaymentStatus { paid, pending, expired }

enum MembershipType { fullTime, halfTime }

class Student {
  final int id;
  final String name, phone, seat, joined, expiry, initials;
  final double fee;
  final PaymentStatus payment;
  final MembershipType membership;
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
  });
  Student copyWith({
    String? name,
    String? phone,
    String? seat,
    String? expiry,
    double? fee,
    PaymentStatus? payment,
    MembershipType? membership,
  }) => Student(
    id: id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    seat: seat ?? this.seat,
    joined: joined,
    expiry: expiry ?? this.expiry,
    fee: fee ?? this.fee,
    payment: payment ?? this.payment,
    membership: membership ?? this.membership,
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
