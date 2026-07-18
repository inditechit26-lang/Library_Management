import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../receipts/widgets/receipt_bottom_sheet.dart';
import '../controllers/students_controller.dart';
import '../models/student.dart';
import '../widgets/document_vault.dart';
import '../widgets/edit_student_sheet.dart';
import '../widgets/membership_card.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_information.dart';
import '../widgets/renew_bottom_sheet.dart';

class StudentProfileScreen extends ConsumerWidget {
  final int studentId;
  const StudentProfileScreen({super.key, required this.studentId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref
        .watch(studentsProvider)
        .firstWhere((item) => item.id == studentId);
    return Scaffold(
      appBar: AppBar(title: const Text('Student Profile')),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 116),
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
      bottomNavigationBar: _ProfileActions(
        onRenew: () => _renew(context, student),
        onEdit: () => _edit(context, ref, student),
        onReceipt: () => _receipt(context, student),
        onDelete: () => _delete(context, ref, student),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text(student.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    ref.read(studentsProvider.notifier).remove(student);
    context.pop();
  }

  Future<void> _call(Student student) => launchUrl(
    Uri.parse('tel:${student.phone.replaceAll(' ', '')}'),
    mode: LaunchMode.externalApplication,
  );

  Future<void> _whatsApp(Student student) => launchUrl(
    Uri.parse('https://wa.me/${student.phone.replaceAll(RegExp(r'\D'), '')}'),
    mode: LaunchMode.externalApplication,
  );
}

class _ProfileActions extends StatelessWidget {
  final VoidCallback onRenew, onEdit, onReceipt, onDelete;
  const _ProfileActions({
    required this.onRenew,
    required this.onEdit,
    required this.onReceipt,
    required this.onDelete,
  });
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1420243B),
            blurRadius: 30,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: Row(
        children: [
          _action(Icons.refresh, 'Renew', onRenew),
          _action(Icons.edit_outlined, 'Edit', onEdit),
          _action(Icons.receipt_long_outlined, 'Receipt', onReceipt),
          _action(Icons.delete_outline, 'Delete', onDelete),
        ],
      ),
    ),
  );
  Widget _action(IconData icon, String label, VoidCallback tap) => Expanded(
    child: InkWell(
      onTap: tap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ),
  );
}
