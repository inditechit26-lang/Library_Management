import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/student.dart';

class StudentIdService {
  static String payload(Student student, {int revision = 0}) =>
      'shelf://students/${student.id}?name=${Uri.encodeComponent(student.name)}'
      '&seat=${Uri.encodeComponent(student.seat)}'
      '&membership=${student.membership.name}'
      '&status=${student.payment.name}&revision=$revision';

  static Future<Uint8List> buildPdf(Student student, {int revision = 0}) async {
    final document = pw.Document();
    pw.MemoryImage? photo;
    if (student.photoPath != null) {
      final file = File(student.photoPath!);
      if (await file.exists()) photo = pw.MemoryImage(await file.readAsBytes());
    }
    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Center(
          child: pw.Container(
            width: 242.65,
            height: 153.07,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              border: pw.Border.all(color: PdfColor.fromHex('#D8DAE3')),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Container(
                      width: 25,
                      height: 25,
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#5145C8'),
                        borderRadius: pw.BorderRadius.circular(7),
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          'SR',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'THE STUDY ROOM',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                        pw.Text(
                          'DIGITAL MEMBER ID',
                          style: const pw.TextStyle(
                            fontSize: 5,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 9),
                pw.Expanded(
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: 48,
                        height: 58,
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#EEEFFC'),
                          borderRadius: pw.BorderRadius.circular(7),
                        ),
                        child: photo == null
                            ? pw.Center(
                                child: pw.Text(
                                  student.initials,
                                  style: pw.TextStyle(
                                    fontSize: 15,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColor.fromHex('#5145C8'),
                                  ),
                                ),
                              )
                            : pw.ClipRRect(
                                horizontalRadius: 7,
                                verticalRadius: 7,
                                child: pw.Image(photo, fit: pw.BoxFit.cover),
                              ),
                      ),
                      pw.SizedBox(width: 10),
                      pw.Expanded(child: _details(student)),
                      pw.SizedBox(width: 8),
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: payload(student, revision: revision),
                        width: 51,
                        height: 51,
                      ),
                    ],
                  ),
                ),
                pw.Divider(color: PdfColor.fromHex('#E3E4EA'), height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'ID  SR-${student.id.toString().padLeft(5, '0')}',
                      style: pw.TextStyle(
                        fontSize: 6,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Valid until ${student.expiry}',
                      style: const pw.TextStyle(
                        fontSize: 6,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return document.save();
  }

  static pw.Widget _details(Student student) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        student.name,
        maxLines: 1,
        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 3),
      pw.Text(
        student.membership == MembershipType.fullTime
            ? 'Full Time Member'
            : 'Half Time Member',
        style: pw.TextStyle(fontSize: 6, color: PdfColor.fromHex('#5145C8')),
      ),
      pw.SizedBox(height: 6),
      pw.Text(
        'SEAT  ${student.seat}',
        style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 3),
      pw.Text(
        'JOINED  ${student.joined}',
        style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey700),
      ),
    ],
  );

  static Future<void> download(Student student, {int revision = 0}) async {
    final bytes = await buildPdf(student, revision: revision);
    await FilePicker.platform.saveFile(
      dialogTitle: 'Save Digital Student ID',
      fileName: 'student-id-${student.id}.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      bytes: bytes,
    );
  }

  static Future<void> printCard(Student student, {int revision = 0}) async =>
      Printing.layoutPdf(
        name: 'student-id-${student.id}.pdf',
        onLayout: (_) => buildPdf(student, revision: revision),
      );

  static Future<void> share(Student student, {int revision = 0}) async =>
      Printing.sharePdf(
        bytes: await buildPdf(student, revision: revision),
        filename: 'student-id-${student.id}.pdf',
      );
}
