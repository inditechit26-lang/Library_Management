import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/activity_log_model.dart';
import '../../../core/services/firestore_paths.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../payments/models/payment_model.dart';
import '../../receipts/models/receipt_model.dart';
import '../../seats/models/seat_model.dart';
import '../models/student_model.dart';

abstract class BaseStudentsRepository {
  Stream<List<StudentModel>> watchStudents();
  Future<List<StudentModel>> getStudents({int limit = 50});
  Future<StudentModel?> getStudentById(String studentId);
  Future<void> createStudent(StudentModel student);
  Future<void> updateStudent(StudentModel student);
  Future<void> renewStudent({
    required StudentModel student,
    required PaymentModel payment,
    required ReceiptModel receipt,
  });
  Future<void> softDeleteStudent(String studentId);
  Future<void> importStudents(List<StudentModel> students);

  /// Multi-document Atomic Firestore Transaction for Admission
  Future<void> processAdmissionTransaction({
    required StudentModel student,
    required String? seatNumber,
    required PaymentModel payment,
    required ReceiptModel receipt,
  });
}

class StudentsRepository implements BaseStudentsRepository {
  StudentsRepository(this._service);
  final FirestoreService _service;
  FirebaseFirestore get _firestore => _service.firestore;
  CollectionReference get _studentsRef =>
      _service.collection(FirestorePaths.students);

  @override
  Stream<List<StudentModel>> watchStudents() {
    return _studentsRef.where('isDeleted', isEqualTo: false).snapshots().map((
      snapshot,
    ) {
      final students = snapshot.docs
          .map((doc) => StudentModel.fromFirestore(doc))
          .toList();
      students.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return students;
    });
  }

  @override
  Future<List<StudentModel>> getStudents({int limit = 50}) async {
    try {
      final snapshot = await _studentsRef
          .where('isDeleted', isEqualTo: false)
          .get();

      final students = snapshot.docs
          .map((doc) => StudentModel.fromFirestore(doc))
          .toList();
      students.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return students.take(limit).toList();
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<StudentModel?> getStudentById(String studentId) async {
    try {
      final doc = await _studentsRef.doc(studentId).get();
      if (!doc.exists) return null;
      return StudentModel.fromFirestore(doc);
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<void> createStudent(StudentModel student) async {
    try {
      await _studentsRef.doc(student.id).set(student.toFirestore());
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<void> updateStudent(StudentModel student) async {
    try {
      await _studentsRef.doc(student.id).update(student.toFirestore());
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<void> renewStudent({
    required StudentModel student,
    required PaymentModel payment,
    required ReceiptModel receipt,
  }) async {
    try {
      final batch = _firestore.batch();
      batch.update(_studentsRef.doc(student.id), student.toFirestore());
      batch.set(
        _service.collection(FirestorePaths.payments).doc(payment.id),
        payment.toFirestore(),
      );
      batch.set(
        _service.collection(FirestorePaths.receipts).doc(receipt.receiptNumber),
        receipt.toFirestore(),
      );
      final activity = _service.collection(FirestorePaths.activityLogs).doc();
      batch.set(activity, {
        'id': activity.id,
        'title': 'Membership Renewed',
        'description': '${student.name} renewed until ${student.validUntil}.',
        'type': 'membership_renewed',
        'timestamp': FieldValue.serverTimestamp(),
      });
      await batch.commit();
    } catch (error, stackTrace) {
      throw ErrorHandler.handle(error, stackTrace);
    }
  }

  @override
  Future<void> softDeleteStudent(String studentId) async {
    try {
      final studentDoc = _studentsRef.doc(studentId);
      final seats = _service.collection(FirestorePaths.seats);
      final occupiedSeatSnapshot = await seats
          .where('studentId', isEqualTo: studentId)
          .get();
      final activityRef = _service
          .collection(FirestorePaths.activityLogs)
          .doc();
      await _firestore.runTransaction((transaction) async {
        final studentSnapshot = await transaction.get(studentDoc);
        if (!studentSnapshot.exists) return;
        final data = studentSnapshot.data() as Map<String, dynamic>? ?? {};
        final assignedSeat = data['assignedSeat'] as String?;

        transaction.update(studentDoc, {
          'isDeleted': true,
          'status': 'Inactive',
          'assignedSeat': null,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        final seatDocuments = <String, DocumentReference>{
          for (final document in occupiedSeatSnapshot.docs)
            document.id: document.reference,
          if (assignedSeat != null && assignedSeat.trim().isNotEmpty)
            assignedSeat: seats.doc(assignedSeat),
        };
        for (final entry in seatDocuments.entries) {
          final seatDoc = entry.value;
          transaction.set(seatDoc, {
            'seatNumber': entry.key,
            'status': 'available',
            'studentId': null,
            'studentName': null,
            'studentPhone': null,
            'shift': null,
            'assignedDate': null,
            'expiryDate': null,
          }, SetOptions(merge: true));
        }

        transaction.set(
          activityRef,
          ActivityLogModel(
            id: activityRef.id,
            title: 'Student Deleted',
            description: 'Student ID #$studentId soft deleted.',
            type: 'student_deleted',
            timestamp: DateTime.now(),
          ).toFirestore(),
        );
      });
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<void> importStudents(List<StudentModel> students) async {
    const chunkSize = 400;
    for (var start = 0; start < students.length; start += chunkSize) {
      final end = (start + chunkSize).clamp(0, students.length);
      final batch = _firestore.batch();
      for (final student in students.sublist(start, end)) {
        batch.set(
          _studentsRef.doc(student.id),
          student.toFirestore(),
          SetOptions(merge: true),
        );
      }
      await batch.commit();
    }
  }

  @override
  Future<void> processAdmissionTransaction({
    required StudentModel student,
    required String? seatNumber,
    required PaymentModel payment,
    required ReceiptModel receipt,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // 1. Check seat availability if seatNumber is specified
        if (seatNumber != null && seatNumber.isNotEmpty) {
          final seatDocRef = _service
              .collection(FirestorePaths.seats)
              .doc(seatNumber);
          final seatSnap = await transaction.get(seatDocRef);

          if (seatSnap.exists) {
            final seatData = seatSnap.data() as Map<String, dynamic>;
            if (seatData['status'] == 'occupied') {
              throw Exception('Seat #$seatNumber is already occupied.');
            }
          }

          // Assign Seat
          transaction.set(
            seatDocRef,
            SeatModel(
              seatNumber: seatNumber,
              status: SeatStatus.occupied,
              studentId: student.id,
              studentName: student.name,
              studentPhone: student.phone,
              shift: student.shift,
              assignedDate: student.joiningDate,
              expiryDate: student.validUntil,
            ).toFirestore(),
            SetOptions(merge: true),
          );
        }

        // 2. Create Student
        final studentDocRef = _studentsRef.doc(student.id);
        transaction.set(studentDocRef, student.toFirestore());

        // 3. Create Payment record
        final paymentDocRef = _service
            .collection(FirestorePaths.payments)
            .doc(payment.id);
        transaction.set(paymentDocRef, payment.toFirestore());

        // 4. Create Receipt record
        final receiptDocRef = _service
            .collection(FirestorePaths.receipts)
            .doc(receipt.receiptNumber);
        transaction.set(receiptDocRef, receipt.toFirestore());

        // 5. Create the admission record used for admission history/reports.
        final admissionRef = _service
            .collection(FirestorePaths.admissions)
            .doc();
        transaction.set(admissionRef, {
          'id': admissionRef.id,
          'studentId': student.id,
          'studentName': student.name,
          'seatNumber': seatNumber,
          'planName': student.planName,
          'amount': payment.netAmount,
          'paymentId': payment.id,
          'receiptNumber': receipt.receiptNumber,
          'admittedAt': Timestamp.fromDate(student.joiningDate),
          'validUntil': Timestamp.fromDate(student.validUntil),
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 6. Create Activity Log
        final activityRef = _service
            .collection(FirestorePaths.activityLogs)
            .doc();
        transaction.set(
          activityRef,
          ActivityLogModel(
            id: activityRef.id,
            title: 'New Student Admission',
            description:
                '${student.name} admitted with Plan ${student.planName}.',
            type: 'student_added',
            timestamp: DateTime.now(),
          ).toFirestore(),
        );
      });
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }
}
