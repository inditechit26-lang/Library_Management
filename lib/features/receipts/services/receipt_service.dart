import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/constants/app_constants.dart';
import '../../payments/models/payment_model.dart';
import '../../settings/models/billing_details.dart';
import '../../students/models/student.dart';

class ReceiptService {
  static final _navy = PdfColor.fromHex('#07264F');
  static final _green = PdfColor.fromHex('#2F7D32');
  static final _gold = PdfColor.fromHex('#C49A4A');
  static final _paleGreen = PdfColor.fromHex('#E7F5E7');
  static final _line = PdfColor.fromHex('#C9CDD3');
  static final _ivory = PdfColor.fromHex('#FBFAF7');
  static final _navySoft = PdfColor.fromHex('#F2F5F9');

  static Future<Uint8List> generate(
    Student student, {
    PaymentModel? payment,
    BillingDetails billingDetails = const BillingDetails(),
    String? newExpiry,
  }) async {
    final businessName = billingDetails.businessName.trim().isNotEmpty
        ? billingDetails.businessName.trim()
        : AppConstants.libraryName;
    final prefix = billingDetails.receiptPrefix.trim().isNotEmpty
        ? billingDetails.receiptPrefix.trim().toUpperCase()
        : 'SH';
    final paidAt = payment?.paymentDate ?? DateTime.now();
    final receiptNo = payment?.receiptNumber.isNotEmpty == true
        ? payment!.receiptNumber
        : '$prefix-${paidAt.year}-${student.id.toString().padLeft(4, '0')}';
    final validFrom = student.previousExpiry ?? student.joined;
    final validUntil = newExpiry ?? student.expiry;
    final days = _daysBetween(validFrom, validUntil);
    final subtotal = payment?.amount ?? student.fee;
    final discount = payment?.discount ?? 0;
    final fine = payment?.fine ?? 0;
    final totalPaid = payment?.netAmount ?? student.fee;
    final paymentMode = payment?.paymentMode ?? student.paymentMode.fullLabel;
    final studentId = student.sourceId?.trim().isNotEmpty == true
        ? student.sourceId!
        : 'STU-${student.id.toString().padLeft(4, '0')}';
    final qrData = [
      'receipt=$receiptNo',
      'student=$studentId',
      'name=${student.name}',
      'amount=${totalPaid.toStringAsFixed(2)}',
      'paidAt=${paidAt.toIso8601String()}',
    ].join('|');
    final regularFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Inter-Regular.ttf'),
    );
    final semiBoldFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Inter-SemiBold.ttf'),
    );
    final boldFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Inter-Bold.ttf'),
    );
    final displayFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/PlayfairDisplay-Regular.ttf'),
    );
    final displayBoldFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/PlayfairDisplay-Bold.ttf'),
    );
    final logoData = await rootBundle.load('assets/images/app_logo.png');
    final logo = pw.MemoryImage(logoData.buffer.asUint8List());

    final document = pw.Document(
      title: 'Payment Receipt - $receiptNo',
      author: businessName,
      subject: 'Payment receipt for ${student.name}',
    );

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(18, 16, 18, 14),
        theme: pw.ThemeData.withFont(
          base: regularFont,
          bold: boldFont,
          italic: semiBoldFont,
          boldItalic: boldFont,
        ),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _header(businessName, logo, displayBoldFont),
            pw.SizedBox(height: 12),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: _paymentSummary(
                    receiptNo,
                    DateFormat('dd MMM yyyy, hh:mm a').format(paidAt),
                    paymentMode,
                  ),
                ),
                pw.Container(width: 1, height: 126, color: _line),
                pw.SizedBox(width: 18),
                pw.Expanded(
                  child: _paidTo(businessName, billingDetails, displayBoldFont),
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            _section(
              'STUDENT DETAILS',
              displayBoldFont,
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      children: [
                        _detail('FULL NAME', student.name),
                        _detail('PHONE NUMBER', student.phone),
                        _detail('STUDENT ID', studentId),
                      ],
                    ),
                  ),
                  pw.Container(width: 1, height: 48, color: _line),
                  pw.SizedBox(width: 14),
                  pw.Expanded(
                    child: pw.Column(
                      children: [_detail('JOINING DATE', student.joined)],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 8),
            _section(
              'MEMBERSHIP DETAILS',
              displayBoldFont,
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      children: [
                        _detail('PLAN TYPE', _planName(student)),
                        _detail('ASSIGNED SEAT', _seatName(student)),
                      ],
                    ),
                  ),
                  pw.Container(width: 1, height: 58, color: _line),
                  pw.SizedBox(width: 14),
                  pw.Expanded(
                    child: pw.Column(
                      children: [
                        if (student.previousExpiry?.trim().isNotEmpty == true)
                          _detail('PREVIOUS EXPIRY', student.previousExpiry!),
                        _detail('VALID FROM', validFrom),
                        _detail('VALID UNTIL', validUntil),
                        _detail('TOTAL DAYS', '$days Days'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 9),
            _chargesTable(student, validFrom, validUntil, days, subtotal),
            pw.SizedBox(height: 8),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.SizedBox(
                width: 235,
                child: pw.Column(
                  children: [
                    _amountLine('SUBTOTAL', subtotal),
                    _amountLine('DISCOUNT', discount),
                    if (fine > 0) _amountLine('LATE FEE', fine),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            'TOTAL PAID',
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                              color: _navy,
                              font: displayBoldFont,
                              fontSize: 13,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 14),
                        pw.Container(
                          width: 116,
                          padding: const pw.EdgeInsets.symmetric(vertical: 6),
                          color: _navy,
                          child: pw.Text(
                            '₹ ${totalPaid.toStringAsFixed(2)}',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              color: _gold,
                              font: displayBoldFont,
                              fontSize: 13,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            pw.SizedBox(height: 8),
            _notes(qrData, billingDetails, payment?.remarks),
            pw.Spacer(),
            pw.Row(
              children: [
                pw.Expanded(child: pw.Container(height: .7, color: _line)),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                  child: pw.Text(
                    billingDetails.footerMessage.trim().isNotEmpty
                        ? billingDetails.footerMessage.trim()
                        : 'Thank you for being a valued member of our learning community!',
                    style: pw.TextStyle(
                      color: _navy,
                      font: displayFont,
                      fontSize: 9.5,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ),
                pw.Expanded(child: pw.Container(height: .7, color: _line)),
              ],
            ),
          ],
        ),
      ),
    );
    return document.save();
  }

  static pw.Widget _header(
    String businessName,
    pw.MemoryImage logo,
    pw.Font displayBoldFont,
  ) => pw.Container(
    padding: const pw.EdgeInsets.only(bottom: 10),
    decoration: pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: _gold, width: 1.2)),
    ),
    child: pw.Row(
      children: [
        pw.Container(
          width: 58,
          height: 58,
          padding: const pw.EdgeInsets.all(3),
          child: pw.Image(logo, fit: pw.BoxFit.contain),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                businessName,
                style: pw.TextStyle(
                  color: _navy,
                  font: displayBoldFont,
                  fontSize: 25,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Container(width: 86, height: 2, color: _gold),
            ],
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 13),
          decoration: pw.BoxDecoration(
            color: _navy,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Container(width: 18, height: 1, color: _gold),
              pw.SizedBox(width: 10),
              pw.Text(
                'PAYMENT RECEIPT',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 12.5,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: .5,
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Container(width: 18, height: 1, color: _gold),
            ],
          ),
        ),
      ],
    ),
  );

  static pw.Widget _paymentSummary(String no, String date, String mode) =>
      pw.Padding(
        padding: const pw.EdgeInsets.only(right: 18, top: 2),
        child: pw.Column(
          children: [
            _summaryLine('RECEIPT NO.', no),
            _summaryLine('DATE & TIME', date),
            _summaryLine('PAYMENT MODE', mode),
            _summaryLine('STATUS', 'SUCCESSFUL', success: true),
          ],
        ),
      );

  static pw.Widget _summaryLine(
    String label,
    String value, {
    bool success = false,
  }) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 6),
    child: pw.Row(
      children: [
        pw.SizedBox(
          width: 105,
          child: pw.Text(
            label,
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Text(':', style: const pw.TextStyle(fontSize: 8)),
        pw.SizedBox(width: 12),
        pw.Expanded(
          child: success
              ? pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  color: _paleGreen,
                  child: pw.Text(
                    value,
                    style: pw.TextStyle(
                      color: _green,
                      fontSize: 8.5,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                )
              : pw.Text(value, style: const pw.TextStyle(fontSize: 8.5)),
        ),
      ],
    ),
  );

  static pw.Widget _paidTo(
    String name,
    BillingDetails details,
    pw.Font displayBoldFont,
  ) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'PAID TO',
        style: pw.TextStyle(
          color: _navy,
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      pw.Container(width: 56, height: 1.2, color: PdfColors.blue600),
      pw.SizedBox(height: 7),
      pw.Text(
        name,
        style: pw.TextStyle(
          font: displayBoldFont,
          fontSize: 13,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      pw.SizedBox(height: 7),
      if (details.address.trim().isNotEmpty)
        _contact('ADDRESS', details.address),
      if (details.phone.trim().isNotEmpty) _contact('PHONE', details.phone),
      if (details.email.trim().isNotEmpty) _contact('EMAIL', details.email),
      if (details.website.trim().isNotEmpty) _contact('WEB', details.website),
      if (details.taxId.trim().isNotEmpty)
        _contact('GST / TAX ID', details.taxId),
    ],
  );

  static pw.Widget _contact(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 3),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 53,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              color: _navy,
              fontSize: 6.5,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 7.5)),
        ),
      ],
    ),
  );

  static pw.Widget _section(
    String title,
    pw.Font displayBoldFont,
    pw.Widget child,
  ) => pw.Container(
    decoration: pw.BoxDecoration(
      color: _ivory,
      border: pw.Border.all(color: _line),
      borderRadius: pw.BorderRadius.circular(5),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 13, vertical: 6),
          decoration: pw.BoxDecoration(
            color: _navySoft,
            border: pw.Border(bottom: pw.BorderSide(color: _line)),
          ),
          child: pw.Row(
            children: [
              pw.Container(width: 2.5, height: 14, color: _gold),
              pw.SizedBox(width: 8),
              pw.Text(
                title,
                style: pw.TextStyle(
                  color: _navy,
                  font: displayBoldFont,
                  fontSize: 10.5,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: .3,
                ),
              ),
            ],
          ),
        ),
        pw.Padding(padding: const pw.EdgeInsets.all(12), child: child),
      ],
    ),
  );

  static pw.Widget _detail(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 3),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 96,
          child: pw.Text(
            label,
            style: pw.TextStyle(fontSize: 7.2, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Text(':', style: const pw.TextStyle(fontSize: 7.2)),
        pw.SizedBox(width: 9),
        pw.Expanded(
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 7.5)),
        ),
      ],
    ),
  );

  static pw.Widget _chargesTable(
    Student student,
    String from,
    String until,
    int days,
    double amount,
  ) => pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: _line),
      borderRadius: pw.BorderRadius.circular(4),
    ),
    child: pw.Column(
      children: [
        pw.Container(
          color: _navy,
          padding: const pw.EdgeInsets.symmetric(vertical: 7, horizontal: 10),
          child: pw.Row(
            children: [
              _tableCell('DESCRIPTION', 4, white: true),
              _tableCell('VALIDITY PERIOD', 3, white: true, center: true),
              _tableCell('DAYS', 1, white: true, center: true),
              _tableCell('AMOUNT (₹)', 2, white: true, center: true),
            ],
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 9, horizontal: 10),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Expanded(
                flex: 4,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Library Desk Subscription Fee',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.Text(
                      'Seat: ${_seatName(student)}',
                      style: const pw.TextStyle(fontSize: 7),
                    ),
                  ],
                ),
              ),
              _tableCell('$from to $until', 3, center: true),
              _tableCell('$days', 1, center: true),
              _tableCell(
                amount.toStringAsFixed(2),
                2,
                center: true,
                bold: true,
              ),
            ],
          ),
        ),
      ],
    ),
  );

  static pw.Widget _tableCell(
    String text,
    int flex, {
    bool white = false,
    bool center = false,
    bool bold = false,
  }) => pw.Expanded(
    flex: flex,
    child: pw.Text(
      text,
      textAlign: center ? pw.TextAlign.center : pw.TextAlign.left,
      style: pw.TextStyle(
        color: white ? PdfColors.white : PdfColors.black,
        fontSize: 7.5,
        fontWeight: white || bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
    ),
  );

  static pw.Widget _amountLine(String label, double value) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.SizedBox(
          width: 92,
          child: pw.Text(
            label,
            style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(
          width: 110,
          child: pw.Text(
            '₹ ${value.toStringAsFixed(2)}',
            textAlign: pw.TextAlign.right,
            style: const pw.TextStyle(fontSize: 8),
          ),
        ),
      ],
    ),
  );

  static pw.Widget _notes(
    String qrData,
    BillingDetails details,
    String? remarks,
  ) => pw.Container(
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: _line),
      borderRadius: pw.BorderRadius.circular(5),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'NOTES',
                style: pw.TextStyle(
                  color: _navy,
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              _note('This is a computer-generated digital receipt.'),
              _note('No physical signature is required.'),
              _note(
                'For any queries, contact the billing phone or email above.',
              ),
              if (remarks?.trim().isNotEmpty == true)
                _note('Remarks: ${remarks!.trim()}'),
            ],
          ),
        ),
        pw.Container(width: 1, height: 55, color: _line),
        pw.SizedBox(width: 14),
        pw.BarcodeWidget(
          barcode: pw.Barcode.qrCode(),
          data: qrData,
          width: 62,
          height: 62,
          color: _navy,
        ),
      ],
    ),
  );

  static pw.Widget _note(String text) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 3),
    child: pw.Row(
      children: [
        pw.Text(
          'OK',
          style: pw.TextStyle(
            color: _green,
            fontSize: 6,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(width: 7),
        pw.Expanded(
          child: pw.Text(text, style: const pw.TextStyle(fontSize: 7.2)),
        ),
      ],
    ),
  );

  static String _planName(Student student) {
    final type = student.membership == MembershipType.fullTime
        ? 'Full Time'
        : 'Half Time';
    return '$type (${student.category.label})';
  }

  static String _seatName(Student student) => student.seat.trim().isNotEmpty
      ? student.seat.trim()
      : student.membership == MembershipType.fullTime
      ? 'Dedicated Seat'
      : 'Flexible Desk';

  static int _daysBetween(String from, String until) {
    final parser = DateFormat('dd MMM yyyy');
    final start = parser.tryParse(from);
    final end = parser.tryParse(until);
    if (start == null || end == null) return 0;
    return end.difference(start).inDays.abs().clamp(1, 9999);
  }

  static Future<void> print(
    Student student, {
    BillingDetails billingDetails = const BillingDetails(),
    String? newExpiry,
  }) async {
    final bytes = await generate(
      student,
      billingDetails: billingDetails,
      newExpiry: newExpiry,
    );
    await Printing.layoutPdf(
      name: 'receipt-${student.id}.pdf',
      onLayout: (_) async => bytes,
    );
  }

  static Future<void> share(
    Student student, {
    BillingDetails billingDetails = const BillingDetails(),
    String? newExpiry,
  }) async {
    final bytes = await generate(
      student,
      billingDetails: billingDetails,
      newExpiry: newExpiry,
    );
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'receipt-${student.id}.pdf',
    );
  }
}
