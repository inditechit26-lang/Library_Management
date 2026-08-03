import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
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
  final FirebaseFirestore? _overrideFirestore;

  StudentDataService({FirebaseFirestore? firestore})
      : _overrideFirestore = firestore;

  FirebaseFirestore get _firestore =>
      _overrideFirestore ?? FirebaseFirestore.instance;

  static const List<String> excelHeaders = [
    'Student Name',
    'Mobile Number',
    'Emergency Contact',
    'Section',
    'Seat Number',
    'Shift Timing',
    'Membership Plan',
    'Fee Amount (₹)',
    'Payment Mode',
    'Payment Status',
    'Joining Date',
    'Expiry Date',
    'Notes / Remarks',
  ];

  /// Generates sample Excel (.xlsx) template for import
  static List<int> generateSampleExcel() {
    final excel = Excel.createExcel();
    final sheet = excel['Students'];
    excel.setDefaultSheet('Students');

    sheet.appendRow(excelHeaders.map((e) => TextCellValue(e)).toList());
    sheet.appendRow([
      TextCellValue('Rahul Sharma'),
      TextCellValue('9876543210'),
      TextCellValue('9876500000'),
      TextCellValue('AC Section'),
      TextCellValue('A-12'),
      TextCellValue('Full-Time (24 Hrs)'),
      TextCellValue('Monthly'),
      DoubleCellValue(1800),
      TextCellValue('UPI'),
      TextCellValue('Paid'),
      TextCellValue('2026-08-01'),
      TextCellValue('2026-09-01'),
      TextCellValue('Prepares for UPSC'),
    ]);
    sheet.appendRow([
      TextCellValue('Ananya Verma'),
      TextCellValue('9123456789'),
      TextCellValue('9123400000'),
      TextCellValue('Non-AC Section'),
      TextCellValue('B-05'),
      TextCellValue('Morning Shift (6 AM - 2 PM)'),
      TextCellValue('Quarterly'),
      DoubleCellValue(4500),
      TextCellValue('Cash'),
      TextCellValue('Paid'),
      TextCellValue('2026-07-15'),
      TextCellValue('2026-10-15'),
      TextCellValue('High Priority'),
    ]);
    sheet.appendRow([
      TextCellValue('Amit Patel'),
      TextCellValue('9988776655'),
      TextCellValue('9988700000'),
      TextCellValue('Cabin'),
      TextCellValue('C-01'),
      TextCellValue('Evening Shift (2 PM - 10 PM)'),
      TextCellValue('Monthly'),
      DoubleCellValue(2000),
      TextCellValue('UPI'),
      TextCellValue('Pending'),
      TextCellValue('2026-08-03'),
      TextCellValue('2026-09-03'),
      TextCellValue('Fees due by 5th Aug'),
    ]);
    sheet.appendRow([
      TextCellValue('Priya Singh'),
      TextCellValue('9811223344'),
      TextCellValue('9811200000'),
      TextCellValue('AC Section'),
      TextCellValue('Flexible'),
      TextCellValue('Full-Time (24 Hrs)'),
      TextCellValue('Half-Yearly'),
      DoubleCellValue(9500),
      TextCellValue('UPI'),
      TextCellValue('Paid'),
      TextCellValue('2026-06-01'),
      TextCellValue('2026-12-01'),
      TextCellValue('Non-reserved seat'),
    ]);
    return excel.encode() ?? [];
  }

  /// Converts student models into clean Excel (.xlsx) bytes
  List<int> exportToExcel(List<StudentModel> students) {
    final excel = Excel.createExcel();
    final sheet = excel['Students'];
    excel.setDefaultSheet('Students');

    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    sheet.appendRow(excelHeaders.map((e) => TextCellValue(e)).toList());

    for (final s in students) {
      sheet.appendRow([
        TextCellValue(s.name),
        TextCellValue(s.phone),
        TextCellValue(s.email),
        TextCellValue(s.sectionId ?? 'AC Section'),
        TextCellValue(s.assignedSeat ?? ''),
        TextCellValue(s.shift),
        TextCellValue(s.planName),
        DoubleCellValue(s.monthlyFee),
        TextCellValue('UPI'),
        TextCellValue(s.status),
        TextCellValue(formatter.format(s.joiningDate)),
        TextCellValue(formatter.format(s.validUntil)),
        TextCellValue(''),
      ]);
    }

    return excel.encode() ?? [];
  }

  /// Parses Excel (.xlsx / .xls) byte content into student models
  ParsedImportResult parseExcel(List<int> bytes) {
    try {
      final excel = Excel.decodeBytes(bytes);
      final validStudents = <StudentModel>[];
      final errorMessages = <String>[];
      final now = DateTime.now();

      for (final table in excel.tables.keys) {
        final rows = excel.tables[table]!.rows;
        if (rows.isEmpty) continue;

        int startIndex = 0;
        final firstRowCells = rows.first.map((c) => c?.value?.toString()?.trim() ?? '').toList();
        final firstRowText = firstRowCells.join(' ').toLowerCase();

        Map<String, int> headerMap = {};
        if (firstRowText.contains('name') || firstRowText.contains('phone') || firstRowText.contains('mobile')) {
          startIndex = 1;
          for (int c = 0; c < firstRowCells.length; c++) {
            final h = firstRowCells[c].toLowerCase();
            if (h.contains('student name') || (h.contains('name') && !h.contains('plan'))) headerMap['name'] = c;
            if (h.contains('mobile') || h.contains('phone')) headerMap['phone'] = c;
            if (h.contains('emergency') || h.contains('email')) headerMap['email'] = c;
            if (h.contains('section') || h.contains('category')) headerMap['section'] = c;
            if (h.contains('seat number') || h.contains('assigned seat') || (h.contains('seat') && !h.contains('type'))) headerMap['seat'] = c;
            if (h.contains('shift')) headerMap['shift'] = c;
            if (h.contains('membership plan') || h.contains('plan name') || h.contains('plan')) headerMap['plan'] = c;
            if (h.contains('seat type')) headerMap['seatType'] = c;
            if (h.contains('fee') || h.contains('amount')) headerMap['fee'] = c;
            if (h.contains('joining')) headerMap['joining'] = c;
            if (h.contains('expiry') || h.contains('valid until')) headerMap['expiry'] = c;
            if (h.contains('status')) headerMap['status'] = c;
            if (h.contains('id') && !h.contains('valid') && !h.contains('paid')) headerMap['id'] = c;
          }
        }

        for (int i = startIndex; i < rows.length; i++) {
          final rowNum = i + 1;
          final row = rows[i];
          final columns = row.map((c) => c?.value?.toString()?.trim() ?? '').toList();

          if (columns.every((c) => c.isEmpty)) continue;

          String getCol(String key, int defaultIndex) {
            final idx = headerMap[key] ?? defaultIndex;
            return (idx >= 0 && idx < columns.length) ? columns[idx] : '';
          }

          final name = getCol('name', columns.length > 1 ? 1 : 0);
          if (name.isEmpty) {
            errorMessages.add('Row $rowNum: Name cannot be empty');
            continue;
          }

          final phone = getCol('phone', columns.length > 2 ? 2 : 1);
          final email = getCol('email', 2);
          final sectionId = getCol('section', 3);
          final assignedSeat = getCol('seat', 4).isNotEmpty ? getCol('seat', 4) : null;
          final shift = getCol('shift', 5).isNotEmpty ? getCol('shift', 5) : 'Full Day';
          final planName = getCol('plan', 6).isNotEmpty ? getCol('plan', 6) : 'Monthly Standard';
          final feeStr = getCol('fee', 7);
          final monthlyFee = double.tryParse(feeStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
          final status = getCol('status', 9).isNotEmpty ? getCol('status', 9) : 'Active';
          final joiningDate = _parseDate(getCol('joining', 10)) ?? now;
          final validUntil = _parseDate(getCol('expiry', 11)) ?? now.add(const Duration(days: 30));
          final idStr = getCol('id', 0);
          final id = idStr.isNotEmpty ? idStr : 'imp_${now.microsecondsSinceEpoch}_$i';

          validStudents.add(
            StudentModel(
              id: id,
              name: name,
              email: email,
              phone: phone,
              gender: 'Male',
              assignedSeat: assignedSeat,
              shift: shift,
              planName: planName,
              seatType: getCol('seatType', -1).isNotEmpty ? getCol('seatType', -1) : null,
              sectionId: sectionId.isNotEmpty ? sectionId : null,
              monthlyFee: monthlyFee,
              joiningDate: joiningDate,
              validUntil: validUntil,
              status: status,
              createdAt: now,
              updatedAt: now,
            ),
          );
        }
      }

      return ParsedImportResult(
        validStudents: validStudents,
        errorMessages: errorMessages,
        totalRows: validStudents.length + errorMessages.length,
      );
    } catch (e) {
      return ParsedImportResult(
        validStudents: [],
        errorMessages: ['Invalid Excel format: $e'],
        totalRows: 0,
      );
    }
  }

  /// Converts student models into clean CSV string
  String exportToCsv(List<StudentModel> students) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final buffer = StringBuffer();

    buffer.writeln(excelHeaders.join(','));

    for (final s in students) {
      final row = [
        _cleanCsvValue(s.name),
        _cleanCsvValue(s.phone),
        _cleanCsvValue(s.email),
        _cleanCsvValue(s.sectionId ?? 'AC Section'),
        _cleanCsvValue(s.assignedSeat ?? ''),
        _cleanCsvValue(s.shift),
        _cleanCsvValue(s.planName),
        s.monthlyFee.toStringAsFixed(2),
        'UPI',
        _cleanCsvValue(s.status),
        formatter.format(s.joiningDate),
        formatter.format(s.validUntil),
        '',
      ];
      buffer.writeln(row.join(','));
    }

    return buffer.toString();
  }

  /// Converts student models into clean formatted JSON string
  String exportToJson(List<StudentModel> students) {
    final list = students.map((s) => s.toFirestore()).toList();
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

    int startIndex = 0;
    final firstLineCells = _parseCsvLine(lines.first).map((c) => c.trim()).toList();
    final firstLineText = firstLineCells.join(' ').toLowerCase();

    Map<String, int> headerMap = {};
    if (firstLineText.contains('name') || firstLineText.contains('phone') || firstLineText.contains('mobile')) {
      startIndex = 1;
      for (int c = 0; c < firstLineCells.length; c++) {
        final h = firstLineCells[c].toLowerCase();
        if (h.contains('student name') || (h.contains('name') && !h.contains('plan'))) headerMap['name'] = c;
        if (h.contains('mobile') || h.contains('phone')) headerMap['phone'] = c;
        if (h.contains('emergency') || h.contains('email')) headerMap['email'] = c;
        if (h.contains('section') || h.contains('category')) headerMap['section'] = c;
        if (h.contains('seat number') || h.contains('assigned seat') || (h.contains('seat') && !h.contains('type'))) headerMap['seat'] = c;
        if (h.contains('shift')) headerMap['shift'] = c;
        if (h.contains('membership plan') || h.contains('plan name') || h.contains('plan')) headerMap['plan'] = c;
        if (h.contains('seat type')) headerMap['seatType'] = c;
        if (h.contains('fee') || h.contains('amount')) headerMap['fee'] = c;
        if (h.contains('joining')) headerMap['joining'] = c;
        if (h.contains('expiry') || h.contains('valid until')) headerMap['expiry'] = c;
        if (h.contains('status')) headerMap['status'] = c;
        if (h.contains('id') && !h.contains('valid') && !h.contains('paid')) headerMap['id'] = c;
      }
    }

    for (int i = startIndex; i < lines.length; i++) {
      final rowNum = i + 1;
      final line = lines[i];
      final columns = _parseCsvLine(line).map((c) => c.trim()).toList();

      if (columns.every((c) => c.isEmpty)) continue;

      String getCol(String key, int defaultIndex) {
        final idx = headerMap[key] ?? defaultIndex;
        return (idx >= 0 && idx < columns.length) ? columns[idx] : '';
      }

      final name = getCol('name', columns.length > 1 ? 1 : 0);
      if (name.isEmpty) {
        errorMessages.add('Row $rowNum: Name cannot be empty');
        continue;
      }

      final phone = getCol('phone', columns.length > 2 ? 2 : 1);
      final email = getCol('email', 2);
      final sectionId = getCol('section', 3);
      final assignedSeat = getCol('seat', 4).isNotEmpty ? getCol('seat', 4) : null;
      final shift = getCol('shift', 5).isNotEmpty ? getCol('shift', 5) : 'Full Day';
      final planName = getCol('plan', 6).isNotEmpty ? getCol('plan', 6) : 'Monthly Standard';
      final feeStr = getCol('fee', 7);
      final monthlyFee = double.tryParse(feeStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
      final status = getCol('status', 9).isNotEmpty ? getCol('status', 9) : 'Active';
      final joiningDate = _parseDate(getCol('joining', 10)) ?? now;
      final validUntil = _parseDate(getCol('expiry', 11)) ?? now.add(const Duration(days: 30));
      final idStr = getCol('id', 0);
      final id = idStr.isNotEmpty ? idStr : 'imp_${now.microsecondsSinceEpoch}_$i';

      validStudents.add(
        StudentModel(
          id: id,
          name: name,
          email: email,
          phone: phone,
          gender: 'Male',
          assignedSeat: assignedSeat,
          shift: shift,
          planName: planName,
          seatType: getCol('seatType', -1).isNotEmpty ? getCol('seatType', -1) : null,
          sectionId: sectionId.isNotEmpty ? sectionId : null,
          monthlyFee: monthlyFee,
          joiningDate: joiningDate,
          validUntil: validUntil,
          status: status,
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
