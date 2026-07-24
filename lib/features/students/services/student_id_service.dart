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
              color: PdfColor.fromHex('#0B2335'),
              border: pw.Border.all(color: PdfColor.fromHex('#7ED8E9')),
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
                        color: PdfColor.fromHex('#F1FBFC'),
                        borderRadius: pw.BorderRadius.circular(7),
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          'SR',
                          style: pw.TextStyle(
                            color: PdfColor.fromHex('#0B2335'),
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
                            color: PdfColors.white,
                          ),
                        ),
                        pw.Text(
                          'PREMIER MEMBER CREDENTIAL',
                          style: const pw.TextStyle(
                            fontSize: 5,
                            color: PdfColor(0.48, 0.85, 0.91),
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
                          color: PdfColor.fromHex('#173345'),
                          border: pw.Border.all(
                            color: PdfColor.fromHex('#70E1CA'),
                          ),
                          borderRadius: pw.BorderRadius.circular(7),
                        ),
                        child: photo == null
                            ? pw.Center(
                                child: pw.Text(
                                  student.initials,
                                  style: pw.TextStyle(
                                    fontSize: 15,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColor.fromHex('#C8F7F0'),
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
                      pw.Container(
                        width: 57,
                        height: 57,
                        padding: const pw.EdgeInsets.all(4),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          borderRadius: pw.BorderRadius.circular(7),
                        ),
                        child: pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          data: payload(student, revision: revision),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Divider(color: PdfColor.fromHex('#365365'), height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'ID  SR-${student.id.toString().padLeft(5, '0')}',
                      style: pw.TextStyle(
                        fontSize: 6,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#D8E9EE'),
                      ),
                    ),
                    pw.Text(
                      'Valid until ${student.expiry}',
                      style: const pw.TextStyle(
                        fontSize: 6,
                        color: PdfColor(0.61, 0.70, 0.73),
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
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
      pw.SizedBox(height: 3),
      pw.Text(
        student.membership == MembershipType.fullTime
            ? 'Full Time Member'
            : 'Half Time Member',
        style: pw.TextStyle(fontSize: 6, color: PdfColor.fromHex('#83DDEB')),
      ),
      pw.SizedBox(height: 6),
      pw.Text(
        'SEAT  ${student.seat}',
        style: pw.TextStyle(
          fontSize: 7,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
      pw.SizedBox(height: 3),
      pw.Text(
        'JOINED  ${student.joined}',
        style: const pw.TextStyle(
          fontSize: 6,
          color: PdfColor(0.61, 0.70, 0.73),
        ),
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
