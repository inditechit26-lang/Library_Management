import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/custom_pdf_viewer_screen.dart';
import '../../payments/providers/payments_provider.dart';
import '../../settings/controllers/owner_profile_controller.dart';
import '../../students/models/student.dart';
import '../services/receipt_service.dart';

class ReceiptPdfViewerScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(paymentsStreamProvider).value ?? const [];
    final matchingPayments = payments.where(
      (item) => item.studentId == student.sourceId,
    );
    final payment = matchingPayments.isEmpty ? null : matchingPayments.first;
    final receiptNo = payment?.receiptNumber.isNotEmpty == true
        ? payment!.receiptNumber
        : 'SR-2026-${student.id.toString().padLeft(4, '0')}';
    final billingDetails = ref.watch(ownerProfileProvider).billingDetails;

    return CustomPdfViewerScreen(
      title: 'Receipt Preview',
      subtitle: '$receiptNo • ${student.name}',
      pdfFileName:
          'Receipt_${student.name.replaceAll(' ', '_')}_$receiptNo.pdf',
      buildPdf: (format) =>
          ReceiptService.generate(
            student,
            payment: payment,
            billingDetails: billingDetails,
            newExpiry: newExpiry,
          ),
    );
  }
}
