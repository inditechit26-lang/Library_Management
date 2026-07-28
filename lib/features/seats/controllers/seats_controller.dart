import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/seat_model.dart' as firestore_model;
import '../providers/seats_provider.dart' as firestore_seats;
import '../models/seat.dart';

class SeatsController extends Notifier<List<Seat>> {
  @override
  List<Seat> build() {
    final seats = ref.watch(firestore_seats.seatsProvider);
    final now = DateTime.now();
    return seats
        .map(
          (seat) => Seat(
            seatId: seat.seatNumber,
            seatLabel: seat.seatNumber,
            status: switch (seat.status) {
              firestore_model.SeatStatus.occupied => SeatStatus.occupied,
              firestore_model.SeatStatus.maintenance => SeatStatus.maintenance,
              firestore_model.SeatStatus.blocked => SeatStatus.blocked,
              firestore_model.SeatStatus.available => SeatStatus.available,
            },
            studentId:
                seat.studentId == null ? null : _legacyId(seat.studentId!),
            createdAt: seat.assignedDate ?? now,
            updatedAt: now,
          ),
        )
        .toList();
  }

  int _legacyId(String id) {
    var hash = 17;
    for (final codeUnit in id.codeUnits) {
      hash = 0x1fffffff & (hash * 37 + codeUnit);
    }
    return hash;
  }

  CollectionReference<Map<String, dynamic>>? get _seatsRef {
    final libraryId = ref.read(currentLibraryIdProvider);
    if (libraryId == null || libraryId.isEmpty) return null;
    return FirebaseFirestore.instance
        .collection('libraries')
        .doc(libraryId)
        .collection('seats');
  }

  void _persistSeat(Seat seat) {
    final seatsRef = _seatsRef;
    if (seatsRef == null) return;
    unawaited(
      seatsRef.doc(seat.seatId).set({
        'seatNumber': seat.seatLabel,
        'status': seat.status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)),
    );
  }

  void _persistCurrentState() {
    final seatsRef = _seatsRef;
    if (seatsRef == null) return;
    final batch = FirebaseFirestore.instance.batch();
    for (final seat in state) {
      batch.set(
        seatsRef.doc(seat.seatId),
        {
          'seatNumber': seat.seatLabel,
          'status': seat.status.name,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }
    unawaited(batch.commit());
  }

  void assign(String seatId, int studentId, {String? previousSeatId}) {
    final now = DateTime.now();
    state = [
      for (final seat in state)
        if (seat.seatId == previousSeatId)
          seat.copyWith(
            status: SeatStatus.available,
            clearStudent: true,
            updatedAt: now,
          )
        else if (seat.seatId == seatId)
          seat.copyWith(
            status: SeatStatus.occupied,
            studentId: studentId,
            updatedAt: now,
          )
        else
          seat,
    ];
    _persistCurrentState();
  }

  void release(String seatId) {
    _update(
      seatId,
      (seat) => seat.copyWith(status: SeatStatus.available, clearStudent: true),
    );
    _persistSeat(state.firstWhere((seat) => seat.seatId == seatId));
  }

  void setStatus(String seatId, SeatStatus status) {
    _update(
      seatId,
      (seat) => seat.copyWith(
        status: status,
        clearStudent: status != SeatStatus.occupied,
      ),
    );
    _persistSeat(state.firstWhere((seat) => seat.seatId == seatId));
  }

  void rename(String seatId, String label) {
    final trimmed = label.trim();
    if (trimmed.isEmpty || trimmed == seatId) return;
    final seatsRef = _seatsRef;
    final oldSeat = state.firstWhere((seat) => seat.seatId == seatId);
    state = [
      for (final seat in state)
        if (seat.seatId == seatId)
          Seat(
            seatId: trimmed,
            seatLabel: trimmed,
            status: seat.status,
            category: seat.category,
            studentId: seat.studentId,
            createdAt: seat.createdAt,
            updatedAt: DateTime.now(),
          )
        else
          seat,
    ];
    if (seatsRef == null) return;
    final batch = FirebaseFirestore.instance.batch();
    batch.set(seatsRef.doc(trimmed), {
      'seatNumber': trimmed,
      'status': oldSeat.status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.delete(seatsRef.doc(seatId));
    unawaited(batch.commit());
  }

  Seat add(String label) {
    final now = DateTime.now();
    final seat = Seat(
      seatId: label.trim(),
      seatLabel: label.trim(),
      status: SeatStatus.available,
      createdAt: now,
      updatedAt: now,
    );
    state = [...state, seat];
    _persistSeat(seat);
    return seat;
  }

  bool delete(String seatId) {
    final seat = state.firstWhere((item) => item.seatId == seatId);
    if (seat.studentId != null || seat.status == SeatStatus.occupied) {
      return false;
    }
    state = state.where((item) => item.seatId != seatId).toList();
    final seatsRef = _seatsRef;
    if (seatsRef != null) unawaited(seatsRef.doc(seatId).delete());
    return true;
  }

  void generateNumeric(int total) =>
      _replaceLabels(List.generate(total, (index) => '${index + 1}'));

  void generateAlphabetic(int rows, int perRow) => _replaceLabels([
    for (var row = 0; row < rows; row++)
      for (var seat = 1; seat <= perRow; seat++)
        '${String.fromCharCode(65 + row)}$seat',
  ]);

  void resetStatuses() {
    final now = DateTime.now();
    state = [
      for (final seat in state)
        seat.copyWith(
          status: SeatStatus.available,
          clearStudent: true,
          updatedAt: now,
        ),
    ];
    _persistCurrentState();
  }

  void deleteAll() {
    final existing = [...state];
    state = [];
    final seatsRef = _seatsRef;
    if (seatsRef == null) return;
    final batch = FirebaseFirestore.instance.batch();
    for (final seat in existing) {
      batch.delete(seatsRef.doc(seat.seatId));
    }
    unawaited(batch.commit());
  }

  void replaceAll(List<String> labels) => _replaceLabels(labels);

  void _replaceLabels(List<String> labels) {
    final existing = [...state];
    final now = DateTime.now();
    state = [
      for (var index = 0; index < labels.length; index++)
        Seat(
          seatId: labels[index],
          seatLabel: labels[index],
          status: SeatStatus.available,
          createdAt: now,
          updatedAt: now,
        ),
    ];
    final seatsRef = _seatsRef;
    if (seatsRef == null) return;
    final batch = FirebaseFirestore.instance.batch();
    for (final seat in existing) {
      batch.delete(seatsRef.doc(seat.seatId));
    }
    for (final seat in state) {
      batch.set(seatsRef.doc(seat.seatId), {
        'seatNumber': seat.seatLabel,
        'status': 'available',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    unawaited(batch.commit());
  }

  void _update(String seatId, Seat Function(Seat) update) {
    final now = DateTime.now();
    state = [
      for (final seat in state)
        if (seat.seatId == seatId)
          update(seat).copyWith(updatedAt: now)
        else
          seat,
    ];
  }
}

final seatsProvider = NotifierProvider<SeatsController, List<Seat>>(
  SeatsController.new,
);
