import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class CustomPdfViewerScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final String pdfFileName;
  final Future<Uint8List> Function(PdfPageFormat format) buildPdf;

  const CustomPdfViewerScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.pdfFileName,
    required this.buildPdf,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Native Android PDF Viewer style (Dark Top Header Bar, Dark Canvas background, Clean Android Icons)
    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFF323639),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: isDark
            ? const Color(0xFF1E1E1E)
            : const Color(0xFF202124),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: Color(0xFF9AA0A6)),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Share',
            icon: const Icon(
              Icons.share_outlined,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () async {
              final pdfBytes = await buildPdf(PdfPageFormat.a4);
              await Printing.sharePdf(bytes: pdfBytes, filename: pdfFileName);
            },
          ),
          IconButton(
            tooltip: 'Print / Download',
            icon: const Icon(
              Icons.print_outlined,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () async {
              final pdfBytes = await buildPdf(PdfPageFormat.a4);
              await Printing.layoutPdf(
                onLayout: (format) async => pdfBytes,
                name: pdfFileName.replaceAll('.pdf', ''),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: PdfPreview(
        build: buildPdf,
        allowPrinting: false,
        allowSharing: false,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        useActions: false,
        pdfFileName: pdfFileName,
        scrollViewDecoration: BoxDecoration(
          color: isDark ? const Color(0xFF121212) : const Color(0xFF323639),
        ),
        pdfPreviewPageDecoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        loadingWidget: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }
}
