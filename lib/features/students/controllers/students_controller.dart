import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student.dart';

class StudentsController extends Notifier<List<Student>> {
  @override
  List<Student> build() => const [
    Student(
      id: 1,
      name: 'Rahul Sharma',
      phone: '+91 98765 43210',
      seat: 'A1',
      joined: '18 Jan 2026',
      expiry: '18 Aug 2026',
      fee: 1800,
      payment: PaymentStatus.paid,
      membership: MembershipType.fullTime,
      initials: 'RS',
    ),
    Student(
      id: 2,
      name: 'Priya Verma',
      phone: '+91 98231 45670',
      seat: 'A2',
      joined: '05 Mar 2026',
      expiry: '05 Aug 2026',
      fee: 1200,
      payment: PaymentStatus.pending,
      membership: MembershipType.halfTime,
      initials: 'PV',
    ),
    Student(
      id: 3,
      name: 'Arjun Mehta',
      phone: '+91 99876 12045',
      seat: 'B1',
      joined: '22 Feb 2026',
      expiry: '22 Jul 2026',
      fee: 2000,
      payment: PaymentStatus.expired,
      membership: MembershipType.fullTime,
      initials: 'AM',
    ),
    Student(
      id: 4,
      name: 'Sneha Kapoor',
      phone: '+91 97654 32108',
      seat: 'B3',
      joined: '11 Apr 2026',
      expiry: '11 Sep 2026',
      fee: 1800,
      payment: PaymentStatus.paid,
      membership: MembershipType.fullTime,
      initials: 'SK',
    ),
    Student(
      id: 5,
      name: 'Kunal Singh',
      phone: '+91 98901 23876',
      seat: 'C2',
      joined: '27 Mar 2026',
      expiry: '27 Jul 2026',
      fee: 1100,
      payment: PaymentStatus.pending,
      membership: MembershipType.halfTime,
      initials: 'KS',
    ),
    Student(
      id: 6,
      name: 'Neha Joshi',
      phone: '+91 93012 45678',
      seat: 'D1',
      joined: '14 May 2026',
      expiry: '14 Oct 2026',
      fee: 2200,
      payment: PaymentStatus.paid,
      membership: MembershipType.fullTime,
      initials: 'NJ',
    ),
  ];
  void renew(Student value, String expiry) => state = [
    for (final s in state)
      if (s.id == value.id)
        s.copyWith(expiry: expiry, payment: PaymentStatus.paid)
      else
        s,
  ];
  void remove(Student value) =>
      state = state.where((s) => s.id != value.id).toList();
  void markPaid(Student value) => state = [
    for (final student in state)
      if (student.id == value.id)
        student.copyWith(payment: PaymentStatus.paid)
      else
        student,
  ];
  void add(Student value) => state = [...state, value];
}

final studentsProvider = NotifierProvider<StudentsController, List<Student>>(
  StudentsController.new,
);
