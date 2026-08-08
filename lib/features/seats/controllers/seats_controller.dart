import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/seat_model.dart' as firestore_model;
import '../providers/seats_provider.dart' as firestore_seats;
import '../repositories/seats_repository.dart';
import '../models/seat.dart';
import '../../settings/models/library_configuration.dart';
import '../../students/models/student.dart';
import '../../students/models/student_model.dart';
import '../../students/providers/students_provider.dart' as student_records;

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
            studentId: seat.studentId == null
                ? null
                : _legacyId(seat.studentId!),
            sectionId: seat.sectionId,
            createdAt: seat.assignedDate ?? now,
            updatedAt: now,
          ),
        )
        .toList()
      ..sort((a, b) => _compareLabels(a.seatLabel, b.seatLabel));
  }

  int _legacyId(String id) {
    var hash = 17;
    for (final codeUnit in id.codeUnits) {
      hash = 0x1fffffff & (hash * 37 + codeUnit);
    }
    return hash;
  }

  BaseSeatsRepository get _repository =>
      ref.read(firestore_seats.seatsRepositoryProvider);

  void _persistSeat(Seat seat) {
    unawaited(_repository.setSeat(seat.seatId, _seatData(seat)));
  }

  void _persistCurrentState() {
    unawaited(
      _repository.setSeats({
        for (final seat in state) seat.seatId: _seatData(seat),
      }),
    );
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
    unawaited(
      _repository.replaceSeats(
        deleteIds: [seatId],
        seats: {
          trimmed: {..._seatData(oldSeat), 'seatNumber': trimmed},
        },
      ),
    );
  }

  Seat add(String label, {String? sectionId}) {
    final now = DateTime.now();
    final seat = Seat(
      seatId: label.trim(),
      seatLabel: label.trim(),
      status: SeatStatus.available,
      sectionId: sectionId,
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
    unawaited(_repository.deleteSeats([seatId]));
    return true;
  }

  void generateNumeric(int total, {int startingNumber = 1}) => _replaceLabels(
    List.generate(total, (index) => '${startingNumber + index}'),
  );

  void generateAlphabetic(
    int rows,
    int perRow, {
    String prefix = 'A',
    int startingNumber = 1,
  }) => _replaceLabels([
    for (var row = 0; row < rows; row++)
      for (var seat = 0; seat < perRow; seat++)
        '${String.fromCharCode((prefix.isEmpty ? 65 : prefix.codeUnitAt(0)) + row)}${startingNumber + seat}',
  ]);

  Future<void> applyNumbering(SeatNumberingConfiguration numbering) async {
    final defaultSectionId = state.isNotEmpty && state.first.sectionId != null
        ? state.first.sectionId!
        : 'default';
    await applySectionNumbering(defaultSectionId, numbering);
  }

  Future<void> applySectionNumbering(
    String sectionId,
    SeatNumberingConfiguration numbering,
  ) async {
    final otherSectionSeats = state
        .where((seat) => seat.sectionId != sectionId)
        .toList();
    final thisSectionOccupied = state
        .where((seat) => seat.sectionId == sectionId && seat.status == SeatStatus.occupied)
        .toList();
    final thisSectionMutable = state
        .where((seat) => seat.sectionId == sectionId && seat.status != SeatStatus.occupied)
        .toList();

    final labels = _numberingLabels(
      numbering,
      thisSectionOccupied.map((seat) => seat.seatLabel).toSet(),
    );

    final now = DateTime.now();
    final newSectionSeats = [
      for (var index = 0; index < labels.length; index++)
        Seat(
          seatId: '${sectionId}_${labels[index]}',
          seatLabel: labels[index],
          status: index < thisSectionMutable.length
              ? thisSectionMutable[index].status
              : SeatStatus.available,
          sectionId: sectionId,
          createdAt: index < thisSectionMutable.length
              ? thisSectionMutable[index].createdAt
              : now,
          updatedAt: now,
        ),
    ];

    state = [...otherSectionSeats, ...thisSectionOccupied, ...newSectionSeats]
      ..sort((a, b) => _compareLabels(a.seatLabel, b.seatLabel));

    final sourceData = await _repository.getSeatData();
    final replacements = <String, Map<String, dynamic>>{};
    for (var index = 0; index < newSectionSeats.length; index++) {
      final newSeat = newSectionSeats[index];
      final data = Map<String, dynamic>.from(
        index < thisSectionMutable.length
            ? sourceData[thisSectionMutable[index].seatId] ?? const <String, dynamic>{}
            : const <String, dynamic>{},
      );
      data['seatNumber'] = newSeat.seatLabel;
      data['status'] = newSeat.status.name;
      data['sectionId'] = sectionId;
      data['updatedAt'] = DateTime.now();
      replacements[newSeat.seatId] = data;
    }

    await _repository.replaceSeats(
      deleteIds: thisSectionMutable.map((seat) => seat.seatId),
      seats: replacements,
    );
  }

  List<String> _numberingLabels(
    SeatNumberingConfiguration numbering,
    Set<String> excluded,
  ) {
    final labels = <String>[];
    if (numbering.style == SeatNumberingStyle.numeric) {
      for (
        var number = numbering.startingNumber;
        number <= numbering.endingNumber;
        number++
      ) {
        final label = '$number';
        if (!excluded.contains(label)) labels.add(label);
      }
      return labels;
    }

    for (
      var prefixCode = numbering.startPrefixCode;
      prefixCode <= numbering.endPrefixCode;
      prefixCode++
    ) {
      for (
        var number = numbering.startingNumber;
        number < numbering.startingNumber + numbering.numbersPerPrefix;
        number++
      ) {
        final label = '${String.fromCharCode(prefixCode)}$number';
        if (!excluded.contains(label)) labels.add(label);
      }
    }
    return labels;
  }

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
    unawaited(_repository.deleteSeats(existing.map((seat) => seat.seatId)));
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
    unawaited(
      _repository.replaceSeats(
        deleteIds: existing.map((seat) => seat.seatId),
        seats: {
          for (final seat in state)
            seat.seatId: {
              'seatNumber': seat.seatLabel,
              'status': 'available',
              'updatedAt': DateTime.now(),
            },
        },
      ),
    );
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

  Map<String, dynamic> _seatData(Seat seat) {
    StudentModel? student;
    if (seat.studentId != null) {
      for (final record in ref.read(student_records.studentsProvider)) {
        if (_legacyId(record.id) == seat.studentId) {
          student = record;
          break;
        }
      }
    }
    return {
      'seatNumber': seat.seatLabel,
      'status': seat.status.name,
      'studentId': student?.id,
      'studentName': student?.name,
      'studentPhone': student?.phone,
      'shift': student?.shift,
      'expiryDate': student?.validUntil,
      'sectionId': seat.sectionId ?? student?.sectionId,
      'updatedAt': DateTime.now(),
    };
  }
}

int _compareLabels(String first, String second) {
  final cleanFirst = first.trim();
  final cleanSecond = second.trim();

  final pattern = RegExp(r'^([A-Za-z\s\-_]*?)(\d+)$');
  final firstMatch = pattern.firstMatch(cleanFirst);
  final secondMatch = pattern.firstMatch(cleanSecond);

  if (firstMatch != null && secondMatch != null) {
    final prefix1 = firstMatch.group(1)!.replaceAll(RegExp(r'[\s\-_]'), '').toLowerCase();
    final prefix2 = secondMatch.group(1)!.replaceAll(RegExp(r'[\s\-_]'), '').toLowerCase();

    if (prefix1 != prefix2) {
      return prefix1.compareTo(prefix2);
    }
    final num1 = int.parse(firstMatch.group(2)!);
    final num2 = int.parse(secondMatch.group(2)!);
    return num1.compareTo(num2);
  }

  // Fallback natural chunk comparison
  return cleanFirst.compareTo(cleanSecond);
}

final seatsProvider = NotifierProvider<SeatsController, List<Seat>>(
  SeatsController.new,
);
