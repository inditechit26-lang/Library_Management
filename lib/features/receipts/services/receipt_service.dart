import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
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
    final document = pw.Document(
      title: 'Payment Receipt - ${student.name}',
      author: AppConstants.libraryName,
    );

    final receiptNo = 'SR-2026-${student.id.toString().padLeft(4, '0')}';
    final issueDate = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
    final primaryColor = PdfColor.fromHex('#4F46E5'); // Modern Indigo Accent
    final darkHeader = PdfColor.fromHex('#0F172A'); // Slate 900
    final lightBg = PdfColor.fromHex('#F8FAFC'); // Slate 50
    final borderColor = PdfColor.fromHex('#E2E8F0'); // Slate 200
    final textMuted = PdfColor.fromHex('#64748B'); // Slate 500

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- HEADER SECTION ---
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: darkHeader,
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          AppConstants.libraryName.toUpperCase(),
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Premium Study Lounge & Library Desk Services',
                          style: const pw.TextStyle(
                            color: PdfColors.grey400,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: pw.BoxDecoration(
                        color: primaryColor,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Text(
                        'PAYMENT RECEIPT',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // --- METADATA STRIP ---
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: pw.BoxDecoration(
                  color: lightBg,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: borderColor),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _metaItem('Receipt No.', receiptNo, primaryColor),
                    _metaItem('Date & Time', issueDate, null),
                    _metaItem('Payment Mode', 'UPI / Digital Transfer', null),
                    _metaItem('Status', 'SUCCESSFUL', PdfColors.green700),
                  ],
                ),
              ),

              pw.SizedBox(height: 24),

              // --- STUDENT & MEMBERSHIP DETAILS GRID ---
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left Box: Student Details
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(16),
                      decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(10),
                        border: pw.Border.all(color: borderColor),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'STUDENT DETAILS',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: textMuted,
                              letterSpacing: 0.8,
                            ),
                          ),
                          pw.SizedBox(height: 10),
                          _infoRow('Full Name', student.name, isBold: true),
                          _infoRow('Phone Number', student.phone),
                          _infoRow(
                            'Student ID',
                            'STU-${student.id.toString().padLeft(4, '0')}',
                          ),
                          _infoRow('Joining Date', student.joined),
                        ],
                      ),
                    ),
                  ),

                  pw.SizedBox(width: 16),

                  // Right Box: Subscription & Seat Details
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(16),
                      decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(10),
                        border: pw.Border.all(color: borderColor),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'MEMBERSHIP DETAILS',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: textMuted,
                              letterSpacing: 0.8,
                            ),
                          ),
                          pw.SizedBox(height: 10),
                          _infoRow(
                            'Plan Type',
                            student.membership == MembershipType.fullTime
                                ? 'Full Time (Dedicated)'
                                : 'Half Time (Flexible)',
                            isBold: true,
                          ),
                          _infoRow(
                            'Assigned Seat',
                            student.membership == MembershipType.fullTime
                                ? student.seat
                                : 'Flexi Desk',
                          ),
                          _infoRow(
                            'Previous Expiry',
                            student.previousExpiry ?? student.expiry,
                          ),
                          _infoRow(
                            'Valid Until',
                            newExpiry ?? student.expiry,
                            isBold: true,
                            valueColor: primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 24),

              // --- ITEMIZED BREAKDOWN TABLE ---
              pw.Container(
                decoration: pw.BoxDecoration(
                  borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(color: borderColor),
                ),
                child: pw.Column(
                  children: [
                    // Table Header
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: pw.BoxDecoration(
                        color: lightBg,
                        borderRadius: const pw.BorderRadius.vertical(
                          top: pw.Radius.circular(9),
                        ),
                      ),
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 4,
                            child: pw.Text(
                              'DESCRIPTION',
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: textMuted,
                              ),
                            ),
                          ),
                          pw.Expanded(
                            flex: 3,
                            child: pw.Text(
                              'VALIDITY PERIOD',
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: textMuted,
                              ),
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Text(
                              'AMOUNT',
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.Divider(height: 1, color: borderColor),
                    // Table Row
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 4,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'Library Desk Subscription Fee',
                                  style: pw.TextStyle(
                                    fontSize: 11,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.SizedBox(height: 2),
                                pw.Text(
                                  'Seat: ${student.membership == MembershipType.fullTime ? student.seat : "Flexi Desk"} (${student.membership == MembershipType.fullTime ? "Full Time" : "Half Time"})',
                                  style: const pw.TextStyle(
                                    fontSize: 9,
                                    color: PdfColors.grey700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          pw.Expanded(
                            flex: 3,
                            child: pw.Text(
                              '${student.previousExpiry ?? student.expiry} to ${newExpiry ?? student.expiry}',
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Text(
                              'Rs. ${student.fee}',
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontSize: 11,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // --- TOTAL AMOUNT BANNER ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Note: This is a computer-generated digital receipt.',
                        style: const pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'No physical signature required.',
                        style: const pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    width: 220,
                    padding: const pw.EdgeInsets.all(14),
                    decoration: pw.BoxDecoration(
                      color: primaryColor,
                      borderRadius: pw.BorderRadius.circular(10),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'TOTAL PAID:',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Rs. ${student.fee}',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // --- FOOTER & AUTHORIZED SEAL ---
              pw.Divider(height: 1, color: borderColor),
              pw.SizedBox(height: 14),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        AppConstants.libraryName,
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Thank you for being a valued member of our learning community!',
                        style: const pw.TextStyle(
                          fontSize: 8.5,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: primaryColor, width: 1),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Text(
                      'VERIFIED & AUTHORIZED',
                      style: pw.TextStyle(
                        color: primaryColor,
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
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

  static pw.Widget _metaItem(String label, String value, PdfColor? valColor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label.toUpperCase(),
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: valColor ?? PdfColors.black,
          ),
        ),
      ],
    );
  }

  static pw.Widget _infoRow(
    String label,
    String value, {
    bool isBold = false,
    PdfColor? valueColor,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey700),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 9.5,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: valueColor ?? PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }
}

