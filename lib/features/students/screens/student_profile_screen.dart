import 'package:flutter/material.dart';
import '../../../core/settings/app_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../receipts/widgets/receipt_bottom_sheet.dart';
import '../controllers/students_controller.dart';
import '../models/student.dart';
import '../widgets/activity_timeline.dart';
import '../widgets/document_vault.dart';
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
      appBar: AppBar(
        title: Text(context.tr('Student Profile')),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                StudentProfileHeader(student: student),
                const SizedBox(height: 22),
                StudentInformationCard(student: student),
                const SizedBox(height: 12),
                PaymentInformationCard(
                  student: student,
                  onReceipt: () => _receipt(context, student),
                ),
                const SizedBox(height: 12),
                DocumentVault(studentId: student.id),
                const SizedBox(height: 12),
                MembershipCard(
                  student: student,
                  onRenew: () => _renew(context, student),
                ),
                const SizedBox(height: 12),
                const ActivityTimeline(),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _ProfileActions(
        student: student,
        onRenew: () => _renew(context, student),
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
  void _receipt(BuildContext context, Student student) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => ReceiptBottomSheet(student: student),
  );
}

class _ProfileActions extends StatelessWidget {
  final Student student;
  final VoidCallback onRenew;
  const _ProfileActions({required this.student, required this.onRenew});
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Color(0x14292C47),
            blurRadius: 24,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          _action(
            Icons.phone_outlined,
            'Call',
            () => launchUrl(
              Uri.parse('tel:${student.phone.replaceAll(' ', '')}'),
            ),
          ),
          _action(
            Icons.chat_bubble_outline,
            'WhatsApp',
            () => launchUrl(
              Uri.parse(
                'https://wa.me/${student.phone.replaceAll(RegExp(r'\D'), '')}',
              ),
              mode: LaunchMode.externalApplication,
            ),
          ),
          _action(Icons.refresh, 'Renew', onRenew),
          _action(Icons.edit_outlined, 'Edit', () {}),
        ],
      ),
    ),
  );
  Widget _action(IconData icon, String label, VoidCallback tap) => Expanded(
    child: InkWell(
      onTap: tap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
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
