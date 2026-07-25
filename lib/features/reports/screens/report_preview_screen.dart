import 'package:flutter/material.dart';
import '../../../core/widgets/custom_pdf_viewer_screen.dart';
import '../models/report_data.dart';
import '../services/pdf_generator.dart';

class ReportPreviewScreen extends StatelessWidget {
  final ReportData reportData;

  const ReportPreviewScreen({
    super.key,
    required this.reportData,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPdfViewerScreen(
      title: 'Report Preview',
      subtitle: reportData.selectedPeriod,
      pdfFileName: '${reportData.reportType}_${reportData.selectedPeriod.replaceAll(' ', '_')}.pdf',
      buildPdf: (format) => PdfGenerator.generatePdf(reportData),
    );
  }
}
