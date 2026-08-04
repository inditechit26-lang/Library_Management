import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/constants/app_constants.dart';
import '../../payments/models/payment_model.dart';
import '../../settings/models/billing_details.dart';
import '../../students/models/student.dart';

class ReceiptService {
  static Future<Uint8List> generate(
    Student student, {
    PaymentModel? payment,
    BillingDetails billingDetails = const BillingDetails(),
    String? newExpiry,
  }) async {
    final document = pw.Document(
      title: 'Payment Receipt - ${student.name}',
      author: AppConstants.libraryName,
    );

    final receiptNo = payment?.receiptNumber.isNotEmpty == true
        ? payment!.receiptNumber
        : 'SR-2026-${student.id.toString().padLeft(4, '0')}';
    final paidAt = payment?.paymentDate ?? DateTime.now();
    final issueDate = DateFormat('dd MMM yyyy, hh:mm a').format(paidAt);
    final subtotal = payment?.amount ?? student.fee;
    final discount = payment?.discount ?? 0;
    final fine = payment?.fine ?? 0;
    final totalPaid = payment?.netAmount ?? student.fee;
    final paidToName = billingDetails.businessName.trim().isNotEmpty
        ? billingDetails.businessName.trim()
        : AppConstants.libraryName;
    final primaryColor = PdfColor.fromHex('#08244D');
    final accentColor = PdfColor.fromHex('#4D9A34');
    final lightBg = PdfColor.fromHex('#F8FAFC');
    final borderColor = PdfColor.fromHex('#CBD5E1');
    final textMuted = PdfColor.fromHex('#475569');

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
                padding: const pw.EdgeInsets.only(bottom: 16),
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: borderColor)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 44,
                          height: 44,
                          alignment: pw.Alignment.center,
                          decoration: pw.BoxDecoration(
                            color: primaryColor,
                            borderRadius: pw.BorderRadius.circular(12),
                          ),
                          child: pw.Text(
                            paidToName.isEmpty ? 'L' : paidToName[0].toUpperCase(),
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 22,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 10),
                        pw.Text(
                          paidToName,
                          style: pw.TextStyle(
                            color: primaryColor,
                            fontSize: 23,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: pw.BoxDecoration(
                        color: primaryColor,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Text(
                        'PAYMENT RECEIPT',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 1,
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
                    _metaItem(
                      'Payment Mode',
                      payment?.paymentMode ?? student.paymentMode.fullLabel,
                      null,
                    ),
                    _metaItem('Status', 'SUCCESSFUL', accentColor),
                  ],
                ),
              ),

              pw.SizedBox(height: 24),

              // --- BILLING / PAID TO ---
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: lightBg,
                  borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(color: borderColor),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'PAID TO',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                        letterSpacing: .7,
                      ),
                    ),
                    pw.SizedBox(height: 7),
                    pw.Text(
                      paidToName,
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    if (billingDetails.address.trim().isNotEmpty) ...[
                      pw.SizedBox(height: 3),
                      pw.Text(billingDetails.address.trim(), style: const pw.TextStyle(fontSize: 9)),
                    ],
                    if (billingDetails.phone.trim().isNotEmpty) ...[
                      pw.SizedBox(height: 3),
                      pw.Text('Phone: ${billingDetails.phone.trim()}', style: const pw.TextStyle(fontSize: 9)),
                    ],
                    if (billingDetails.email.trim().isNotEmpty) ...[
                      pw.SizedBox(height: 3),
                      pw.Text('Email: ${billingDetails.email.trim()}', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ],
                ),
              ),

              pw.SizedBox(height: 16),

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
                          if (student.email.trim().isNotEmpty)
                            _infoRow('Email ID', student.email),
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
                            '${student.membership == MembershipType.fullTime ? 'Full Time' : 'Half Time'} (${student.category.label})',
                            isBold: true,
                          ),
                          _infoRow(
                            student.membership == MembershipType.fullTime
                                ? 'Assigned Seat'
                                : 'Assigned Seat / Shift',
                            student.membership == MembershipType.fullTime
                                ? student.seat
                                : student.seat.isNotEmpty
                                ? student.seat
                                : 'Flexi Desk',
                          ),
                          _infoRow(
                            'Previous Expiry',
                            student.previousExpiry ?? student.expiry,
                          ),
                          _infoRow('Valid From', student.joined),
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
                              'Rs. ${totalPaid.toStringAsFixed(2)}',
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

              pw.SizedBox(height: 14),

              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    _amountRow('Subtotal', subtotal),
                    if (discount > 0) _amountRow('Discount', -discount),
                    if (fine > 0) _amountRow('Late fee', fine),
                  ],
                ),
              ),

              pw.SizedBox(height: 12),

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
                          'Rs. ${totalPaid.toStringAsFixed(2)}',
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

  static pw.Widget _amountRow(String label, double amount) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 3),
    child: pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text('$label: ', style: const pw.TextStyle(fontSize: 9)),
        pw.Text(
          'Rs. ${amount.toStringAsFixed(2)}',
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
      ],
    ),
  );

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
