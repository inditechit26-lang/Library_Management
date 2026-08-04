import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/student.dart';
import '../models/student_model.dart';
import '../../payments/models/payment_model.dart';
import '../../receipts/models/receipt_model.dart';
import '../providers/students_provider.dart' as firestore_students;

class StudentsController extends Notifier<List<Student>> {
  final Map<int, StudentModel> _modelsByLegacyId = {};

  @override
  List<Student> build() {
    final models = ref.watch(firestore_students.studentsProvider);
    _modelsByLegacyId
      ..clear()
      ..addEntries(models.map((model) => MapEntry(_legacyId(model.id), model)));
    return models.map(_toLegacyStudent).toList();
  }

  int _legacyId(String id) {
    var hash = 17;
    for (final codeUnit in id.codeUnits) {
      hash = 0x1fffffff & (hash * 37 + codeUnit);
    }
    return hash;
  }

  Student _toLegacyStudent(StudentModel model) {
    final now = DateTime.now();
    final expired =
        model.validUntil.isBefore(now) ||
        model.status.toLowerCase() == 'expired' ||
        model.status.toLowerCase() == 'inactive';
    final nameParts = model.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2);
    return Student(
      id: _legacyId(model.id),
      name: model.name,
      phone: model.phone,
      gender: model.gender,
      seat: model.assignedSeat ?? 'Flexible',
      seatId: model.assignedSeat,
      joined: DateFormat('dd MMM yyyy').format(model.joiningDate),
      expiry: DateFormat('dd MMM yyyy').format(model.validUntil),
      fee: model.monthlyFee,
      payment: expired ? PaymentStatus.expired : PaymentStatus.paid,
      membership:
          model.seatType == 'fullTimeReserved' ||
              (model.seatType == null &&
                  model.shift.toLowerCase().contains('full'))
          ? MembershipType.fullTime
          : MembershipType.halfTime,
      initials: nameParts.map((part) => part[0].toUpperCase()).join(),
      photoPath: model.photoUrl,
      sectionId: model.sectionId,
      seatType: model.seatType,
      membershipPeriod: model.membershipPeriod,
    );
  }

  void renew(
    Student value,
    String expiry, {
    double? fee,
    PaymentMode? paymentMode,
  }) {
    final model = _modelsByLegacyId[value.id];
    final parsedExpiry = DateFormat('dd MMM yyyy').tryParse(expiry);
    if (model == null || parsedExpiry == null) return;
    final now = DateTime.now();
    final paymentId = 'pay_${now.microsecondsSinceEpoch}';
    final receiptNumber = 'REC-${now.microsecondsSinceEpoch}';
    final renewed = model.copyWith(
      validUntil: parsedExpiry,
      monthlyFee: fee ?? model.monthlyFee,
      status: 'Active',
      updatedAt: now,
    );
    final payment = PaymentModel(
      id: paymentId,
      studentId: model.id,
      studentName: model.name,
      amount: fee ?? model.monthlyFee,
      netAmount: fee ?? model.monthlyFee,
      paymentMode: paymentMode?.name ?? 'cash',
      receiptNumber: receiptNumber,
      paymentDate: now,
      remarks: 'Membership renewal',
    );
    final receipt = ReceiptModel(
      receiptNumber: receiptNumber,
      studentId: model.id,
      studentName: model.name,
      paymentId: paymentId,
      amount: payment.netAmount,
      createdAt: now,
    );
    unawaited(
      ref
          .read(firestore_students.studentsRepositoryProvider)
          .renewStudent(student: renewed, payment: payment, receipt: receipt),
    );
  }

  Future<void> remove(Student value) async {
    await removeMany([value]);
  }

  Future<void> removeMany(Iterable<Student> students) async {
    final libraryId = ref.read(currentLibraryIdProvider);
    if (libraryId == null || libraryId.isEmpty) {
      throw StateError('No active library is available.');
    }

    // Resolve every backend ID before the stream refreshes. Refreshing after
    // each removal could clear this legacy-ID map before the next item is sent.
    final studentIds = <String>{};
    final legacyIds = <int>{};
    for (final student in students) {
      final model = _modelsByLegacyId[student.id];
      if (model == null) {
        throw StateError('The selected student is no longer available.');
      }
      studentIds.add(model.id);
      legacyIds.add(student.id);
    }
    if (studentIds.isEmpty) return;

    final repository = ref.read(firestore_students.studentsRepositoryProvider);
    for (final studentId in studentIds) {
      await repository.softDeleteStudent(studentId);
    }
    _modelsByLegacyId.removeWhere(
      (legacyId, _) => legacyIds.contains(legacyId),
    );
    state = state
        .where((student) => !legacyIds.contains(student.id))
        .toList(growable: false);
    ref.invalidate(firestore_students.studentsStreamProvider);
  }

  void markPaid(Student value) {
    final model = _modelsByLegacyId[value.id];
    if (model == null) return;
    unawaited(
      ref
          .read(firestore_students.studentsRepositoryProvider)
          .updateStudent(
            model.copyWith(status: 'Active', updatedAt: DateTime.now()),
          ),
    );
  }

  void add(Student value) {
    final libraryId = ref.read(currentLibraryIdProvider);
    if (libraryId == null) return;
    final now = DateTime.now();
    final joiningDate = DateFormat('dd MMM yyyy').tryParse(value.joined) ?? now;
    final validUntil = DateFormat('dd MMM yyyy').tryParse(value.expiry) ?? now;
    final model = StudentModel(
      id: now.microsecondsSinceEpoch.toString(),
      name: value.name,
      email: '',
      phone: value.phone,
      gender: value.gender,
      assignedSeat: value.seatId ?? value.seat,
      shift: value.membership == MembershipType.fullTime
          ? 'Full Day'
          : value.seat,
      planName: value.membership == MembershipType.fullTime
          ? 'Full Time'
          : 'Half Time',
      seatType: value.seatType,
      sectionId: value.sectionId,
      membershipPeriod: value.membershipPeriod,
      monthlyFee: value.fee,
      joiningDate: joiningDate,
      validUntil: validUntil,
      status: value.payment == PaymentStatus.expired ? 'Expired' : 'Active',
      photoUrl: value.photoPath,
      createdAt: now,
      updatedAt: now,
    );
    unawaited(
      ref
          .read(firestore_students.studentsRepositoryProvider)
          .createStudent(model),
    );
  }

  void update(Student value) {
    final model = _modelsByLegacyId[value.id];
    if (model == null) return;
    final expiry =
        DateFormat('dd MMM yyyy').tryParse(value.expiry) ?? model.validUntil;
    unawaited(
      ref
          .read(firestore_students.studentsRepositoryProvider)
          .updateStudent(
            model.copyWith(
              name: value.name,
              phone: value.phone,
              gender: value.gender,
              assignedSeat: value.seatId ?? value.seat,
              monthlyFee: value.fee,
              validUntil: expiry,
              status: value.payment == PaymentStatus.expired
                  ? 'Expired'
                  : 'Active',
              photoUrl: value.photoPath,
              updatedAt: DateTime.now(),
            ),
          ),
    );
  }
}

final studentsProvider = NotifierProvider<StudentsController, List<Student>>(
  StudentsController.new,
);
