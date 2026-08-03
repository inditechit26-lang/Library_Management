import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/activity_log_model.dart';
import '../../../core/services/firestore_paths.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/utils/error_handler.dart';
import '../models/seat_model.dart';

abstract class BaseSeatsRepository {
  Stream<List<SeatModel>> watchSeats();
  Future<void> updateSeatStatus(SeatModel seat);
  Future<void> transferSeat({
    required String fromSeatNumber,
    required String toSeatNumber,
    required String studentId,
    required String studentName,
  });
  Future<void> blockSeat(String seatNumber, String reason);
  Future<void> unblockSeat(String seatNumber);
  Future<Map<String, Map<String, dynamic>>> getSeatData();
  Future<void> setSeat(String id, Map<String, dynamic> data);
  Future<void> setSeats(Map<String, Map<String, dynamic>> seats);
  Future<void> deleteSeats(Iterable<String> ids);
  Future<void> replaceSeats({
    required Iterable<String> deleteIds,
    required Map<String, Map<String, dynamic>> seats,
  });
}

class SeatsRepository implements BaseSeatsRepository {
  SeatsRepository(this._service);
  final FirestoreService _service;
  FirebaseFirestore get _firestore => _service.firestore;
  CollectionReference get _seatsRef =>
      _service.collection(FirestorePaths.seats);

  @override
  Stream<List<SeatModel>> watchSeats() {
    return _seatsRef.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => SeatModel.fromFirestore(doc)).toList(),
    );
  }

  @override
  Future<void> updateSeatStatus(SeatModel seat) async {
    try {
      await _seatsRef
          .doc(seat.seatNumber)
          .set(seat.toFirestore(), SetOptions(merge: true));
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<void> transferSeat({
    required String fromSeatNumber,
    required String toSeatNumber,
    required String studentId,
    required String studentName,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final targetSeatRef = _seatsRef.doc(toSeatNumber);
        final currentSeatRef = _seatsRef.doc(fromSeatNumber);
        final studentRef = _service
            .collection(FirestorePaths.students)
            .doc(studentId);

        final targetSnap = await transaction.get(targetSeatRef);
        if (targetSnap.exists) {
          final targetData = targetSnap.data() as Map<String, dynamic>;
          if (targetData['status'] == 'occupied') {
            throw Exception(
              'Target seat #$toSeatNumber is currently occupied.',
            );
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
          'assignedDate':
              currentData['assignedDate'] ?? FieldValue.serverTimestamp(),
          'expiryDate': currentData['expiryDate'],
        });

        // 3. Update student assigned seat
        transaction.update(studentRef, {
          'assignedSeat': toSeatNumber,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 4. Log Activity
        final activityRef = _service
            .collection(FirestorePaths.activityLogs)
            .doc();
        transaction.set(
          activityRef,
          ActivityLogModel(
            id: activityRef.id,
            title: 'Seat Transferred',
            description:
                '$studentName transferred from Seat #$fromSeatNumber to #$toSeatNumber.',
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
  Future<void> blockSeat(String seatNumber, String reason) async {
    try {
      await _seatsRef.doc(seatNumber).set({
        'seatNumber': seatNumber,
        'status': 'blocked',
        'blockReason': reason,
      }, SetOptions(merge: true));
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<void> unblockSeat(String seatNumber) async {
    try {
      await _seatsRef.doc(seatNumber).set({
        'seatNumber': seatNumber,
        'status': 'available',
        'blockReason': null,
      }, SetOptions(merge: true));
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<Map<String, Map<String, dynamic>>> getSeatData() async {
    final snapshot = await _seatsRef.get();
    return {
      for (final document in snapshot.docs)
        document.id: Map<String, dynamic>.from(document.data() as Map),
    };
  }

  @override
  Future<void> setSeat(String id, Map<String, dynamic> data) =>
      _seatsRef.doc(id).set(data, SetOptions(merge: true));

  @override
  Future<void> setSeats(Map<String, Map<String, dynamic>> seats) async {
    final batch = _firestore.batch();
    for (final entry in seats.entries) {
      batch.set(_seatsRef.doc(entry.key), entry.value, SetOptions(merge: true));
    }
    await batch.commit();
  }

  @override
  Future<void> deleteSeats(Iterable<String> ids) async {
    final batch = _firestore.batch();
    for (final id in ids) {
      batch.delete(_seatsRef.doc(id));
    }
    await batch.commit();
  }

  @override
  Future<void> replaceSeats({
    required Iterable<String> deleteIds,
    required Map<String, Map<String, dynamic>> seats,
  }) async {
    final batch = _firestore.batch();
    for (final id in deleteIds) {
      batch.delete(_seatsRef.doc(id));
    }
    for (final entry in seats.entries) {
      batch.set(_seatsRef.doc(entry.key), entry.value);
    }
    await batch.commit();
  }
}
