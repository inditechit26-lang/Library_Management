import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
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
        builder: (_) => ReceiptPdfViewerScreen(
          student: student,
          newExpiry: newExpiry,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final receiptNo = 'SR-2026-${student.id.toString().padLeft(4, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Receipt Preview',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '$receiptNo • ${student.name}',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.65),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Share PDF',
            icon: const Icon(Icons.share_rounded),
            onPressed: () => ReceiptService.share(student, newExpiry: newExpiry),
          ),
          IconButton(
            tooltip: 'Print Receipt',
            icon: const Icon(Icons.print_rounded),
            onPressed: () => ReceiptService.print(student, newExpiry: newExpiry),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PdfPreview(
        build: (format) => ReceiptService.generate(student, newExpiry: newExpiry),
        allowPrinting: true,
        allowSharing: true,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        pdfFileName: 'Receipt_${student.name.replaceAll(' ', '_')}_$receiptNo.pdf',
        loadingWidget: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
