import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/activity_log_model.dart';
import '../../../core/utils/error_handler.dart';
import '../models/seat_model.dart';

abstract class BaseSeatsRepository {
  Stream<List<SeatModel>> watchSeats(String libraryId);
  Future<void> updateSeatStatus(String libraryId, SeatModel seat);
  Future<void> transferSeat({
    required String libraryId,
    required String fromSeatNumber,
    required String toSeatNumber,
    required String studentId,
    required String studentName,
  });
  Future<void> blockSeat(String libraryId, String seatNumber, String reason);
  Future<void> unblockSeat(String libraryId, String seatNumber);
}

class SeatsRepository implements BaseSeatsRepository {
  final FirebaseFirestore _firestore;

  SeatsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _seatsRef(String libraryId) {
    return _firestore.collection('libraries').doc(libraryId).collection('seats');
  }

  @override
  Stream<List<SeatModel>> watchSeats(String libraryId) {
    return _seatsRef(libraryId).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => SeatModel.fromFirestore(doc)).toList());
  }

  @override
  Future<void> updateSeatStatus(String libraryId, SeatModel seat) async {
    try {
      await _seatsRef(libraryId).doc(seat.seatNumber).set(
            seat.toFirestore(),
            SetOptions(merge: true),
          );
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<void> transferSeat({
    required String libraryId,
    required String fromSeatNumber,
    required String toSeatNumber,
    required String studentId,
    required String studentName,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final libRef = _firestore.collection('libraries').doc(libraryId);
        final targetSeatRef = libRef.collection('seats').doc(toSeatNumber);
        final currentSeatRef = libRef.collection('seats').doc(fromSeatNumber);
        final studentRef = libRef.collection('students').doc(studentId);

        final targetSnap = await transaction.get(targetSeatRef);
        if (targetSnap.exists) {
          final targetData = targetSnap.data() as Map<String, dynamic>;
          if (targetData['status'] == 'occupied') {
            throw Exception('Target seat #$toSeatNumber is currently occupied.');
          }
        }

        final currentSnap = await transaction.get(currentSeatRef);
        final currentData = currentSnap.data() as Map<String, dynamic>? ?? {};

        // 1. Vacate old seat
        transaction.set(currentSeatRef, {
          'seatNumber': fromSeatNumber,
          'status': 'available',
          'studentId': null,
          'studentName': null,
          'studentPhone': null,
          'shift': null,
          'assignedDate': null,
          'expiryDate': null,
        });

        // 2. Assign new seat
        transaction.set(targetSeatRef, {
          'seatNumber': toSeatNumber,
          'status': 'occupied',
          'studentId': studentId,
          'studentName': studentName,
          'studentPhone': currentData['studentPhone'],
          'shift': currentData['shift'],
          'assignedDate': currentData['assignedDate'] ?? FieldValue.serverTimestamp(),
          'expiryDate': currentData['expiryDate'],
        });

        // 3. Update student assigned seat
        transaction.update(studentRef, {
          'assignedSeat': toSeatNumber,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 4. Log Activity
        final activityRef = libRef.collection('activity').doc();
        transaction.set(
          activityRef,
          ActivityLogModel(
            id: activityRef.id,
            title: 'Seat Transferred',
            description: '$studentName transferred from Seat #$fromSeatNumber to #$toSeatNumber.',
            type: 'seat_assigned',
            timestamp: DateTime.now(),
          ).toFirestore(),
        );
      });
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<void> blockSeat(String libraryId, String seatNumber, String reason) async {
    try {
      await _seatsRef(libraryId).doc(seatNumber).set({
        'seatNumber': seatNumber,
        'status': 'blocked',
        'blockReason': reason,
      }, SetOptions(merge: true));
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<void> unblockSeat(String libraryId, String seatNumber) async {
    try {
      await _seatsRef(libraryId).doc(seatNumber).set({
        'seatNumber': seatNumber,
        'status': 'available',
        'blockReason': null,
      }, SetOptions(merge: true));
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }
}
