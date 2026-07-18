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
  Student copyWith({String? expiry, PaymentStatus? payment}) => Student(
    id: id,
    name: name,
    phone: phone,
    seat: seat,
    joined: joined,
    expiry: expiry ?? this.expiry,
    fee: fee,
    payment: payment ?? this.payment,
    membership: membership,
    initials: initials,
  );
}
