import 'package:flutter_test/flutter_test.dart';
import 'package:shelf_flutter/features/students/models/student_model.dart';
import 'package:shelf_flutter/features/students/services/student_data_service.dart';

void main() {
  group('StudentDataService Excel, CSV & JSON Tests', () {
    final service = StudentDataService();
    final now = DateTime(2026, 1, 15);
    final sampleStudent = StudentModel(
      id: 'STU101',
      name: 'Aarav Mehta',
      email: 'aarav@example.com',
      phone: '9876543210',
      gender: 'Male',
      assignedSeat: 'A-01',
      shift: 'Full Day',
      planName: 'Monthly Standard',
      monthlyFee: 1500.0,
      joiningDate: now,
      validUntil: now.add(const Duration(days: 30)),
      status: 'Active',
      createdAt: now,
      updatedAt: now,
    );

    test('exportToExcel and parseExcel should format and decode correctly', () {
      final bytes = service.exportToExcel([sampleStudent]);
      expect(bytes.isNotEmpty, isTrue);

      final parseResult = service.parseExcel(bytes);
      expect(parseResult.validStudents.length, equals(1));
      expect(parseResult.validStudents.first.name, equals('Aarav Mehta'));
      expect(parseResult.validStudents.first.phone, equals('9876543210'));
    });

    test('generateSampleExcel should generate valid non-empty byte list', () {
      final bytes = StudentDataService.generateSampleExcel();
      expect(bytes.isNotEmpty, isTrue);
    });

    test('exportToCsv and parseCsv should format and decode correctly', () {
      final csv = service.exportToCsv([sampleStudent]);
      expect(csv.contains('Aarav Mehta'), isTrue);

      final parseResult = service.parseCsv(csv);
      expect(parseResult.validStudents.length, equals(1));
      expect(parseResult.validStudents.first.name, equals('Aarav Mehta'));
    });

    test('exportToJson and parseJson should format and decode correctly', () {
      final jsonStr = service.exportToJson([sampleStudent]);
      expect(jsonStr.contains('Aarav Mehta'), isTrue);

      final parseResult = service.parseJson(jsonStr);
      expect(parseResult.validStudents.length, equals(1));
      expect(parseResult.validStudents.first.name, equals('Aarav Mehta'));
    });
  });
}
