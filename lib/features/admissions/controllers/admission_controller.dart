import '../../students/models/student.dart';

class AdmissionController {
  static Student create({
    required int id,
    required String name,
    required String phone,
    required String seat,
    required String fee,
    required MembershipType membership,
  }) {
    final names = name.trim().split(' ');
    return Student(
      id: id,
      name: name.trim(),
      phone: phone.trim(),
      seat: membership == MembershipType.fullTime ? seat.trim() : 'Flexible',
      joined: '18 Jul 2026',
      expiry: '18 Aug 2026',
      fee: double.tryParse(fee) ?? 1800,
      payment: PaymentStatus.pending,
      membership: membership,
      initials: names.take(2).map((part) => part[0].toUpperCase()).join(),
    );
  }
}
