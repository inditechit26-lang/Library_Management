import 'package:flutter/material.dart';
import '../../../core/widgets/custom_pdf_viewer_screen.dart';
import '../../students/models/student.dart';
import '../services/receipt_service.dart';

class ReceiptPdfViewerScreen extends StatelessWidget {
  final Student student;
  final String? newExpiry;

  const ReceiptPdfViewerScreen({
    super.key,
    required this.student,
    this.newExpiry,
  });

  static Future<void> open(
    BuildContext context,
    Student student, {
    String? newExpiry,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ReceiptPdfViewerScreen(student: student, newExpiry: newExpiry),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final receiptNo = 'SR-2026-${student.id.toString().padLeft(4, '0')}';

    return CustomPdfViewerScreen(
      title: 'Receipt Preview',
      subtitle: '$receiptNo • ${student.name}',
      pdfFileName:
          'Receipt_${student.name.replaceAll(' ', '_')}_$receiptNo.pdf',
      buildPdf: (format) =>
          ReceiptService.generate(student, newExpiry: newExpiry),
    );
  }
}
