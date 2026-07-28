import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/activity_log_model.dart';
import '../../../core/utils/error_handler.dart';
import '../../payments/models/payment_model.dart';
import '../../receipts/models/receipt_model.dart';
import '../../seats/models/seat_model.dart';
import '../models/student_model.dart';

abstract class BaseStudentsRepository {
  Stream<List<StudentModel>> watchStudents(String libraryId);
  Future<List<StudentModel>> getStudents(String libraryId, {int limit = 50});
  Future<StudentModel?> getStudentById(String libraryId, String studentId);
  Future<void> createStudent(String libraryId, StudentModel student);
  Future<void> updateStudent(String libraryId, StudentModel student);
  Future<void> softDeleteStudent(String libraryId, String studentId);

  /// Multi-document Atomic Firestore Transaction for Admission
  Future<void> processAdmissionTransaction({
    required String libraryId,
    required StudentModel student,
    required String? seatNumber,
    required PaymentModel payment,
    required ReceiptModel receipt,
  });
}

class StudentsRepository implements BaseStudentsRepository {
  final FirebaseFirestore _firestore;

  StudentsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _studentsRef(String libraryId) {
    return _firestore.collection('libraries').doc(libraryId).collection('students');
  }

  @override
  Stream<List<StudentModel>> watchStudents(String libraryId) {
    return _studentsRef(libraryId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => StudentModel.fromFirestore(doc)).toList());
  }

  @override
  Future<List<StudentModel>> getStudents(String libraryId, {int limit = 50}) async {
    try {
      final snapshot = await _studentsRef(libraryId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => StudentModel.fromFirestore(doc)).toList();
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<StudentModel?> getStudentById(String libraryId, String studentId) async {
    try {
      final doc = await _studentsRef(libraryId).doc(studentId).get();
      if (!doc.exists) return null;
      return StudentModel.fromFirestore(doc);
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<void> createStudent(String libraryId, StudentModel student) async {
    try {
      await _studentsRef(libraryId).doc(student.id).set(student.toFirestore());
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<void> updateStudent(String libraryId, StudentModel student) async {
    try {
      await _studentsRef(libraryId).doc(student.id).update(student.toFirestore());
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<void> softDeleteStudent(String libraryId, String studentId) async {
    try {
      final batch = _firestore.batch();
      final studentDoc = _studentsRef(libraryId).doc(studentId);
      batch.update(studentDoc, {
        'isDeleted': true,
        'status': 'Inactive',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Log activity
      final activityRef = _firestore
          .collection('libraries')
          .doc(libraryId)
          .collection('activity')
          .doc();

      batch.set(
        activityRef,
        ActivityLogModel(
          id: activityRef.id,
          title: 'Student Deleted',
          description: 'Student ID #$studentId soft deleted.',
          type: 'student_deleted',
          timestamp: DateTime.now(),
        ).toFirestore(),
      );

      await batch.commit();
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<void> processAdmissionTransaction({
    required String libraryId,
    required StudentModel student,
    required String? seatNumber,
    required PaymentModel payment,
    required ReceiptModel receipt,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final libRef = _firestore.collection('libraries').doc(libraryId);

        // 1. Check seat availability if seatNumber is specified
        if (seatNumber != null && seatNumber.isNotEmpty) {
          final seatDocRef = libRef.collection('seats').doc(seatNumber);
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
        final studentDocRef = libRef.collection('students').doc(student.id);
        transaction.set(studentDocRef, student.toFirestore());

        // 3. Create Payment record
        final paymentDocRef = libRef.collection('payments').doc(payment.id);
        transaction.set(paymentDocRef, payment.toFirestore());

        // 4. Create Receipt record
        final receiptDocRef = libRef.collection('receipts').doc(receipt.receiptNumber);
        transaction.set(receiptDocRef, receipt.toFirestore());

        // 5. Create Membership History record
        final historyRef = libRef.collection('membership_history').doc();
        transaction.set(historyRef, {
          'id': historyRef.id,
          'studentId': student.id,
          'studentName': student.name,
          'planName': student.planName,
          'amount': payment.netAmount,
          'validFrom': Timestamp.fromDate(student.joiningDate),
          'validUntil': Timestamp.fromDate(student.validUntil),
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 6. Create Activity Log
        final activityRef = libRef.collection('activity').doc();
        transaction.set(
          activityRef,
          ActivityLogModel(
            id: activityRef.id,
            title: 'New Student Admission',
            description: '${student.name} admitted with Plan ${student.planName}.',
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
