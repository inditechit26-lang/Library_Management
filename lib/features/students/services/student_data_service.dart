import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/student_model.dart';

class ParsedImportResult {
  final List<StudentModel> validStudents;
  final List<String> errorMessages;
  final int totalRows;

  const ParsedImportResult({
    required this.validStudents,
    required this.errorMessages,
    required this.totalRows,
  });
}

class StudentDataService {
  final FirebaseFirestore _firestore;

  StudentDataService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const List<String> csvHeaders = [
    'Student ID',
    'Name',
    'Phone',
    'Email',
    'Gender',
    'Assigned Seat',
    'Shift',
    'Plan Name',
    'Seat Type',
    'Monthly Fee',
    'Joining Date',
    'Valid Until',
    'Status',
  ];

  /// Generates sample CSV template for import
  static String generateSampleCsv() {
    final buffer = StringBuffer();
    buffer.writeln(csvHeaders.join(','));
    buffer.writeln(
      'STU1001,Rahul Sharma,9876543210,rahul@example.com,Male,A-12,Full Day,Monthly Standard,fullTimeReserved,1500,01 Jan 2026,01 Feb 2026,Active',
    );
    buffer.writeln(
      'STU1002,Priya Patel,9812345678,priya@example.com,Female,B-05,Half Day,Monthly Flex,halfTimeFlexible,1000,15 Jan 2026,15 Feb 2026,Active',
    );
    return buffer.toString();
  }

  /// Converts student models into clean CSV string
  String exportToCsv(List<StudentModel> students) {
    final DateFormat formatter = DateFormat('dd MMM yyyy');
    final buffer = StringBuffer();

    buffer.writeln(csvHeaders.join(','));

    for (final s in students) {
      final row = [
        _cleanCsvValue(s.id),
        _cleanCsvValue(s.name),
        _cleanCsvValue(s.phone),
        _cleanCsvValue(s.email),
        _cleanCsvValue(s.gender),
        _cleanCsvValue(s.assignedSeat ?? ''),
        _cleanCsvValue(s.shift),
        _cleanCsvValue(s.planName),
        _cleanCsvValue(s.seatType ?? ''),
        s.monthlyFee.toStringAsFixed(2),
        formatter.format(s.joiningDate),
        formatter.format(s.validUntil),
        _cleanCsvValue(s.status),
      ];
      buffer.writeln(row.join(','));
    }

    return buffer.toString();
  }

  /// Converts student models into clean formatted JSON string
  String exportToJson(List<StudentModel> students) {
    final list = students.map((s) => s.toFirestore()).toList();
    // Format timestamp objects to ISO strings for portable JSON
    final formattedList = list.map((map) {
      final copy = Map<String, dynamic>.from(map);
      if (copy['joiningDate'] is Timestamp) {
        copy['joiningDate'] = (copy['joiningDate'] as Timestamp).toDate().toIso8601String();
      }
      if (copy['validUntil'] is Timestamp) {
        copy['validUntil'] = (copy['validUntil'] as Timestamp).toDate().toIso8601String();
      }
      if (copy['createdAt'] is Timestamp) {
        copy['createdAt'] = (copy['createdAt'] as Timestamp).toDate().toIso8601String();
      }
      if (copy['updatedAt'] is Timestamp) {
        copy['updatedAt'] = (copy['updatedAt'] as Timestamp).toDate().toIso8601String();
      }
      return copy;
    }).toList();

    return const JsonEncoder.withIndent('  ').convert(formattedList);
  }

  /// Parses CSV string content into student models
  ParsedImportResult parseCsv(String csvContent) {
    final lines = LineSplitter.split(csvContent)
        .where((l) => l.trim().isNotEmpty)
        .toList();
    if (lines.isEmpty) {
      return const ParsedImportResult(
        validStudents: [],
        errorMessages: ['File is empty'],
        totalRows: 0,
      );
    }

    final validStudents = <StudentModel>[];
    final errorMessages = <String>[];
    final now = DateTime.now();

    // Check if line 0 is a header
    int startIndex = 0;
    final firstLine = lines.first.toLowerCase();
    if (firstLine.contains('name') || firstLine.contains('phone')) {
      startIndex = 1;
    }

    for (int i = startIndex; i < lines.length; i++) {
      final rowNum = i + 1;
      final line = lines[i];
      final columns = _parseCsvLine(line);

      if (columns.length < 2) {
        errorMessages.add('Row $rowNum: Insufficient columns');
        continue;
      }

      final name = columns.length > 1 ? columns[1].trim() : columns[0].trim();
      final phone = columns.length > 2 ? columns[2].trim() : '';

      if (name.isEmpty) {
        errorMessages.add('Row $rowNum: Name cannot be empty');
        continue;
      }

      final id = (columns.isNotEmpty && columns[0].trim().isNotEmpty)
          ? columns[0].trim()
          : 'imp_${now.microsecondsSinceEpoch}_$i';

      final email = columns.length > 3 ? columns[3].trim() : '';
      final gender = columns.length > 4 ? columns[4].trim() : 'Male';
      final assignedSeat = (columns.length > 5 && columns[5].trim().isNotEmpty)
          ? columns[5].trim()
          : null;
      final shift = columns.length > 6 ? columns[6].trim() : 'Full Day';
      final planName = columns.length > 7 ? columns[7].trim() : 'Monthly Standard';
      final seatType = columns.length > 8 ? columns[8].trim() : null;
      final monthlyFee = columns.length > 9 ? double.tryParse(columns[9].trim()) ?? 0.0 : 0.0;
      final joiningDate = columns.length > 10 ? _parseDate(columns[10].trim()) ?? now : now;
      final validUntil = columns.length > 11 ? _parseDate(columns[11].trim()) ?? now.add(const Duration(days: 30)) : now.add(const Duration(days: 30));
      final status = columns.length > 12 ? columns[12].trim() : 'Active';

      validStudents.add(
        StudentModel(
          id: id,
          name: name,
          email: email,
          phone: phone,
          gender: gender,
          assignedSeat: assignedSeat,
          shift: shift,
          planName: planName,
          seatType: seatType,
          monthlyFee: monthlyFee,
          joiningDate: joiningDate,
          validUntil: validUntil,
          status: status.isEmpty ? 'Active' : status,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    return ParsedImportResult(
      validStudents: validStudents,
      errorMessages: errorMessages,
      totalRows: lines.length - startIndex,
    );
  }

  /// Parses JSON string content into student models
  ParsedImportResult parseJson(String jsonContent) {
    try {
      final decoded = jsonDecode(jsonContent);
      final List<dynamic> items = decoded is List ? decoded : [decoded];
      final validStudents = <StudentModel>[];
      final errorMessages = <String>[];
      final now = DateTime.now();

      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        if (item is! Map<String, dynamic>) {
          errorMessages.add('Item ${i + 1}: Invalid record format');
          continue;
        }

        final name = item['name'] as String? ?? '';
        if (name.trim().isEmpty) {
          errorMessages.add('Item ${i + 1}: Name is required');
          continue;
        }

        final id = (item['id'] as String? ?? '').isNotEmpty
            ? item['id'] as String
            : 'imp_${now.microsecondsSinceEpoch}_$i';

        validStudents.add(
          StudentModel(
            id: id,
            name: name.trim(),
            email: item['email'] as String? ?? '',
            phone: item['phone'] as String? ?? '',
            gender: item['gender'] as String? ?? 'Male',
            assignedSeat: item['assignedSeat'] as String?,
            shift: item['shift'] as String? ?? 'Full Day',
            planName: item['planName'] as String? ?? 'Monthly Standard',
            membershipPeriod: item['membershipPeriod'] as String?,
            seatType: item['seatType'] as String?,
            sectionId: item['sectionId'] as String?,
            monthlyFee: (item['monthlyFee'] as num?)?.toDouble() ?? 0.0,
            joiningDate: item['joiningDate'] is String
                ? DateTime.tryParse(item['joiningDate'] as String) ?? now
                : now,
            validUntil: item['validUntil'] is String
                ? DateTime.tryParse(item['validUntil'] as String) ?? now.add(const Duration(days: 30))
                : now.add(const Duration(days: 30)),
            status: item['status'] as String? ?? 'Active',
            photoUrl: item['photoUrl'] as String?,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }

      return ParsedImportResult(
        validStudents: validStudents,
        errorMessages: errorMessages,
        totalRows: items.length,
      );
    } catch (e) {
      return ParsedImportResult(
        validStudents: [],
        errorMessages: ['Invalid JSON format: $e'],
        totalRows: 0,
      );
    }
  }

  /// Batch imports student models into Firestore in chunks of 400 documents
  Future<void> batchImportStudents({
    required String libraryId,
    required List<StudentModel> students,
    void Function(int processed, int total)? onProgress,
  }) async {
    const chunkSize = 400;
    int processed = 0;

    for (int i = 0; i < students.length; i += chunkSize) {
      final chunk = students.sublist(
        i,
        i + chunkSize > students.length ? students.length : i + chunkSize,
      );

      final batch = _firestore.batch();
      for (final student in chunk) {
        final ref = _firestore
            .collection('libraries')
            .doc(libraryId)
            .collection('students')
            .doc(student.id);
        batch.set(ref, student.toFirestore(), SetOptions(merge: true));
      }

      await batch.commit();
      processed += chunk.length;
      onProgress?.call(processed, students.length);
    }
  }

  String _cleanCsvValue(String val) {
    if (val.contains(',') || val.contains('"') || val.contains('\n')) {
      return '"${val.replaceAll('"', '""')}"';
    }
    return val;
  }

  List<String> _parseCsvLine(String line) {
    final List<String> result = [];
    final StringBuffer current = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          current.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        result.add(current.toString());
        current.clear();
      } else {
        current.write(char);
      }
    }
    result.add(current.toString());
    return result;
  }

  DateTime? _parseDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    final formats = [
      'dd MMM yyyy',
      'yyyy-MM-dd',
      'dd/MM/yyyy',
      'MM/dd/yyyy',
      'd MMM yyyy',
    ];
    for (final fmt in formats) {
      try {
        return DateFormat(fmt).parse(dateStr);
      } catch (_) {}
    }
    return DateTime.tryParse(dateStr);
  }
}
