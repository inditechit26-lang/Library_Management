import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../receipts/screens/receipt_pdf_viewer_screen.dart';
import '../controllers/students_controller.dart';
import '../models/student.dart';
import '../widgets/document_vault.dart';
import '../widgets/edit_student_sheet.dart';
import '../widgets/membership_card.dart';
import '../widgets/payment_history_sheet.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_information.dart';
import '../widgets/renew_bottom_sheet.dart';
import '../widgets/student_identity_cards.dart';
import 'student_id_screen.dart';
import '../../settings/controllers/library_configuration_controller.dart';
import '../../settings/models/pricing_settings.dart';
import '../../settings/models/library_configuration.dart';

class StudentProfileScreen extends ConsumerWidget {
  final int studentId;
  const StudentProfileScreen({super.key, required this.studentId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final students = ref.watch(studentsProvider);
    if (students.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Student Profile')),
        body: const Center(child: Text('No student found')),
      );
    }
    Student? student;
    for (final item in students) {
      if (item.id == studentId) {
        student = item;
        break;
      }
    }
    if (student == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Student Profile')),
        body: const Center(child: Text('Student not found')),
      );
    }
    final st = student;
    final configuration = ref.watch(libraryConfigurationProvider);
    LibrarySection? section;
    for (final item in configuration.sections) {
      if (item.id == st.sectionId) section = item;
    }
    MembershipPeriod? period;
    for (final item in MembershipPeriod.values) {
      if (item.name == st.membershipPeriod) period = item;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
        actions: [
          IconButton(
            tooltip: 'Edit profile',
            onPressed: () => _edit(context, ref, st),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Delete student',
            onPressed: () => _delete(context, ref, st),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                StudentProfileHeader(
                  student: st,
                  onCall: () => _call(st),
                  onWhatsApp: () => _whatsApp(st),
                ),
                const SizedBox(height: 20),
                MembershipCard(
                  student: st,
                  onRenew: () => _renew(context, st),
                  onSendReminder: () => _sendWhatsAppReminder(context, st),
                  onReceipt: () => _receiptOptions(context, st),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 154,
                  child: StudentIdentityCards(
                    student: st,
                    onOpenId: () => _openId(context, st),
                  ),
                ),
                const SizedBox(height: 14),
                StudentInformationCard(
                  student: st,
                  sectionName: section?.name,
                  membershipPlanName: period?.label,
                ),
                const SizedBox(height: 14),
                PaymentInformationCard(
                  student: st,
                  onPaymentHistory: () =>
                      PaymentHistorySheet.open(context, st),
                  basePlanPrice: period == null
                      ? null
                      : configuration.priceFor(
                          period,
                          sectionId: st.sectionId,
                          isFullTime:
                              st.membership == MembershipType.fullTime,
                        ),
                ),
                if (configuration.requiredDocuments.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  DocumentVault(studentId: student.id),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _renew(BuildContext context, Student student) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => RenewBottomSheet(student: student),
  );
  void _receipt(BuildContext context, Student student) =>
      ReceiptPdfViewerScreen.open(context, student);

  void _receiptOptions(BuildContext context, Student student) =>
      _receipt(context, student);

  void _edit(BuildContext context, WidgetRef ref, Student student) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => EditStudentSheet(
          student: student,
          onSave: ref.read(studentsProvider.notifier).update,
        ),
      );

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Student student,
  ) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text('Delete ${student.name}?'),
            content: const Text(
              'This student will be removed from the active Students and Fees lists.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(dialogContext, true),
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !context.mounted) return;

    try {
      await ref.read(studentsProvider.notifier).remove(student);
      if (context.mounted) Navigator.pop(context);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to delete this student.')),
      );
    }
  }

  Future<void> _call(Student student) => launchUrl(
    Uri.parse('tel:${student.phone.replaceAll(' ', '')}'),
    mode: LaunchMode.externalApplication,
  );

  void _openId(BuildContext context, Student student) => Navigator.push(
    context,
    PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        child: StudentIdScreen(student: student),
      ),
    ),
  );

  Future<void> _whatsApp(Student student) => launchUrl(
    Uri.parse('https://wa.me/${student.phone.replaceAll(RegExp(r'\D'), '')}'),
    mode: LaunchMode.externalApplication,
  );

  Future<void> _sendWhatsAppReminder(
    BuildContext context,
    Student student,
  ) async {
    final digits = student.phone.replaceAll(RegExp(r'\D'), '');
    final phone = digits.length == 10 ? '91$digits' : digits;
    final message = Uri.encodeComponent(
      'Hello ${student.name},\n\n'
      'This is a friendly reminder from StudyDesk. Your library membership is '
      'scheduled to expire on ${student.expiry}. To ensure uninterrupted access '
      'to your study space and services, kindly renew your membership at your '
      'earliest convenience.\n\n'
      'Warm regards,\nStudyDesk Management',
    );
    final urisToTry = [
      Uri.parse('https://wa.me/$phone?text=$message'),
      Uri.parse('whatsapp://send?phone=$phone&text=$message'),
      Uri.parse('https://api.whatsapp.com/send?phone=$phone&text=$message'),
    ];

    var launched = false;
    for (final uri in urisToTry) {
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (launched) break;
      } catch (_) {}
    }

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('WhatsApp reminder ready for ${student.name}'),
          backgroundColor: const Color(0xFF25D366),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}
