enum PaymentStatus { paid, pending, expired }

enum MembershipType { fullTime, halfTime }

enum SeatCategory { ac, nonAc }

enum PaymentMode { upi, cash }

extension SeatCategoryX on SeatCategory {
  String get label => this == SeatCategory.ac ? 'AC Section' : 'Non-AC Section';
  String get shortLabel => this == SeatCategory.ac ? 'AC' : 'Non-AC';
}

extension PaymentModeX on PaymentMode {
  String get label => this == PaymentMode.cash ? 'Cash' : 'UPI';
  String get fullLabel =>
      this == PaymentMode.cash ? 'Cash Payment' : 'UPI / Digital Transfer';
}

class Student {
  final int id;
  final String name, phone, seat, joined, expiry, initials;
  final String email;
  final String gender;
  final String? seatId;
  final String? photoPath;
  final String emergencyContact, notes;
  final String? previousExpiry;
  final double fee;
  final PaymentStatus payment;
  final MembershipType membership;
  final SeatCategory category;
  final PaymentMode paymentMode;
  final bool hasRenewedPlan;
  final String? sectionId;
  final String? seatType;
  final String? membershipPeriod;
  final String? sourceId;

  const Student({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    required this.seat,
    required this.joined,
    required this.expiry,
    required this.fee,
    required this.payment,
    required this.membership,
    this.gender = 'Male',
    this.category = SeatCategory.ac,
    this.paymentMode = PaymentMode.upi,
    required this.initials,
    this.seatId,
    this.photoPath,
    this.emergencyContact = '',
    this.notes = '',
    this.previousExpiry,
    this.hasRenewedPlan = false,
    this.sectionId,
    this.seatType,
    this.membershipPeriod,
    this.sourceId,
  });

  Student copyWith({
    String? name,
    String? phone,
    String? email,
    String? gender,
    String? seat,
    String? seatId,
    String? photoPath,
    String? emergencyContact,
    String? notes,
    String? expiry,
    double? fee,
    PaymentStatus? payment,
    MembershipType? membership,
    SeatCategory? category,
    PaymentMode? paymentMode,
    String? previousExpiry,
    bool? hasRenewedPlan,
    String? sectionId,
    String? seatType,
    String? membershipPeriod,
    String? sourceId,
  }) => Student(
    id: id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    gender: gender ?? this.gender,
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
    category: category ?? this.category,
    paymentMode: paymentMode ?? this.paymentMode,
    previousExpiry: previousExpiry ?? this.previousExpiry,
    hasRenewedPlan: hasRenewedPlan ?? this.hasRenewedPlan,
    sectionId: sectionId ?? this.sectionId,
    seatType: seatType ?? this.seatType,
    membershipPeriod: membershipPeriod ?? this.membershipPeriod,
    sourceId: sourceId ?? this.sourceId,
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

extension StudentShiftX on Student {
  String? get halfTimeShiftTime {
    if (membership != MembershipType.halfTime) return null;
    if (seat.startsWith('Flexible (') && seat.endsWith(')')) {
      return seat.substring(10, seat.length - 1);
    }
    if (seat.isNotEmpty && seat != 'Flexible' && seat != 'Flexible Seating') {
      return seat;
    }
    return null;
  }
}
