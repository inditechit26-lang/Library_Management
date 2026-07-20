import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../students/models/student.dart';

class ReceiptService {
  static Future<Uint8List> generate(
    Student student, {
    String? newExpiry,
  }) async {
    final document = pw.Document();
    final receipt = 'SR-2026-${student.id.toString().padLeft(4, '0')}';
    document.addPage(
      pw.Page(
        build: (_) => pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                AppConstants.libraryName,
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text('PAYMENT RECEIPT'),
              pw.Divider(height: 28),
              _line('Receipt', receipt),
              _line('Student', student.name),
              _line('Phone', student.phone),
              _line(
                'Membership',
                student.membership == MembershipType.fullTime
                    ? 'Full Time'
                    : 'Half Time',
              ),
              _line(
                'Seat',
                student.membership == MembershipType.fullTime
                    ? student.seat
                    : 'Flexible',
              ),
              _line('Joining date', student.joined),
              _line(
                'Previous expiry',
                student.previousExpiry ?? student.expiry,
              ),
              _line('New expiry', newExpiry ?? student.expiry),
              _line('Payment method', 'UPI'),
              pw.Divider(height: 28),
              _line('Amount paid', money(student.fee), strong: true),
            ],
          ),
        ),
      ),
    );
    return document.save();
  }

  static Future<void> print(Student student, {String? newExpiry}) async {
    final bytes = await generate(student, newExpiry: newExpiry);
    await Printing.layoutPdf(
      name: 'receipt-${student.id}.pdf',
      onLayout: (_) async => bytes,
    );
  }

  static Future<void> share(Student student, {String? newExpiry}) async {
    final bytes = await generate(student, newExpiry: newExpiry);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'receipt-${student.id}.pdf',
    );
  }

  static pw.Widget _line(String label, String value, {bool strong = false}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 6),
        child: pw.Row(
          children: [
            pw.Expanded(child: pw.Text(label)),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontWeight: strong ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ],
        ),
      );
}
