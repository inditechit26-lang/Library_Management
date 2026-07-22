import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../receipts/widgets/receipt_bottom_sheet.dart';
import '../../receipts/services/receipt_service.dart';
import '../controllers/students_controller.dart';
import '../models/student.dart';
import '../widgets/document_vault.dart';
import '../widgets/edit_student_sheet.dart';
import '../widgets/membership_card.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_information.dart';
import '../widgets/renew_bottom_sheet.dart';
import '../widgets/student_identity_cards.dart';
import 'student_id_screen.dart';

class StudentProfileScreen extends ConsumerWidget {
  final int studentId;
  const StudentProfileScreen({super.key, required this.studentId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref
        .watch(studentsProvider)
        .firstWhere((item) => item.id == studentId);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
        actions: [
          IconButton(
            tooltip: 'Edit profile',
            onPressed: () => _edit(context, ref, student),
            icon: const Icon(Icons.edit_outlined),
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
                  student: student,
                  onCall: () => _call(student),
                  onWhatsApp: () => _whatsApp(student),
                ),
                const SizedBox(height: 20),
                MembershipCard(
                  student: student,
                  onRenew: () => _renew(context, student),
                  onReceipt: () => _receiptOptions(context, student),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 154,
                  child: StudentIdentityCards(
                    student: student,
                    onOpenId: () => _openId(context, student),
                  ),
                ),
                const SizedBox(height: 14),
                StudentInformationCard(student: student),
                const SizedBox(height: 14),
                PaymentInformationCard(
                  student: student,
                  onReceipt: () => _receipt(context, student),
                ),
                const SizedBox(height: 14),
                DocumentVault(studentId: student.id),
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
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => RenewBottomSheet(student: student),
  );
  void _receipt(BuildContext context, Student student) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => ReceiptBottomSheet(student: student),
  );

  void _receiptOptions(BuildContext context, Student student) =>
      showModalBottomSheet<void>(
        context: context,
        builder: (sheet) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.visibility_outlined),
                  title: const Text('Preview Receipt'),
                  onTap: () {
                    Navigator.pop(sheet);
                    _receipt(context, student);
                  },
                ),
                ListTile(
                  leading: const WhatsAppLogo(size: 21),
                  title: const Text('Send Receipt'),
                  onTap: () {
                    Navigator.pop(sheet);
                    ReceiptService.share(student);
                  },
                ),
              ],
            ),
          ),
        ),
      );

  void _edit(BuildContext context, WidgetRef ref, Student student) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => EditStudentSheet(
          student: student,
          onSave: ref.read(studentsProvider.notifier).update,
        ),
      );

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
}
