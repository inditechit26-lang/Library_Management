import 'package:flutter/material.dart';
import '../../../core/settings/app_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/formatters.dart';
import '../widgets/receipt_bottom_sheet.dart';
import '../../students/controllers/students_controller.dart';
import '../../students/models/student.dart';
import '../../students/widgets/profile_header.dart';
import '../../students/widgets/renew_bottom_sheet.dart';

enum _MembershipFilter { all, expired, active, expiringSoon }

extension on _MembershipFilter {
  String get label => switch (this) {
    _MembershipFilter.all => 'All',
    _MembershipFilter.expired => 'Expired',
    _MembershipFilter.active => 'Currently active',
    _MembershipFilter.expiringSoon => 'Expiring in 5 days',
  };
}

class ReceiptScreen extends ConsumerStatefulWidget {
  const ReceiptScreen({super.key});
  @override
  ConsumerState<ReceiptScreen> createState() => _State();
}

class _State extends ConsumerState<ReceiptScreen> {
  String query = '';
  _MembershipFilter selectedFilter = _MembershipFilter.all;

  @override
  Widget build(BuildContext context) {
    final allStudents = ref.watch(studentsProvider);
    final students = allStudents
        .where(
          (student) =>
              student.name.toLowerCase().contains(query.toLowerCase()) &&
              _matchesFilter(student),
        )
        .toList();
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
      children: [
        _FeeOverview(
          students: allStudents,
          expiringSoon: _countExpiringSoon(allStudents),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 54,
          child: TextField(
            onChanged: (v) => setState(() => query = v),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: Color(0xFF9297A7)),
              hintText: context.tr('Search student...'),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: _MembershipFilter.values
                .map(
                  (filter) => Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: ChoiceChip(
                      label: Text(filter.label),
                      selected: selectedFilter == filter,
                      onSelected: (_) =>
                          setState(() => selectedFilter = filter),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      side: BorderSide(
                        color: selectedFilter == filter
                            ? const Color(0xFFCCC8FF)
                            : const Color(0xFFE1E4EB),
                      ),
                      selectedColor: const Color(0xFFF0EFFF),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      labelStyle: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: selectedFilter == filter
                            ? const Color(0xFF5145C8)
                            : const Color(0xFF74798A),
                      ),
                      showCheckmark: false,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Text(
              '${students.length} ${students.length == 1 ? 'student' : 'students'}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            Text(
              _countExpiringSoon(allStudents) == 0
                  ? 'No plans expiring soon'
                  : '${_countExpiringSoon(allStudents)} expiring within 5 days',
              style: const TextStyle(fontSize: 10, color: Color(0xFF858B9D)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (students.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(color: const Color(0xFFE4E7EF)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.filter_alt_off_outlined, color: Color(0xFF9297A7)),
                SizedBox(height: 8),
                Text(
                  'No students match this filter',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF666C7D),
                  ),
                ),
              ],
            ),
          )
        else
          ...students.map(
            (student) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _FeeCard(
                student: student,
                onRenew: () => _renewPlan(student),
                onSendReminder: () => _sendWhatsAppReminder(student),
                onViewReceipt: () => _viewReceipt(student),
              ),
            ),
          ),
      ],
    );
  }

  bool _matchesFilter(Student student) {
    final daysRemaining = _daysUntilExpiry(student);
    return switch (selectedFilter) {
      _MembershipFilter.all => true,
      _MembershipFilter.expired => daysRemaining < 0,
      _MembershipFilter.active => daysRemaining >= 0,
      _MembershipFilter.expiringSoon =>
        daysRemaining >= 0 && daysRemaining <= 5,
    };
  }

  int _countExpiringSoon(List<Student> students) => students.where((student) {
    final daysRemaining = _daysUntilExpiry(student);
    return daysRemaining >= 0 && daysRemaining <= 5;
  }).length;

  int _daysUntilExpiry(Student student) {
    final today = DateUtils.dateOnly(DateTime.now());
    final expiry = DateUtils.dateOnly(
      DateFormat('dd MMM yyyy').parse(student.expiry),
    );
    return expiry.difference(today).inDays;
  }

  void _renewPlan(Student student) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => RenewBottomSheet(student: student),
  );

  void _viewReceipt(Student student) => showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) =>
        ReceiptBottomSheet(student: student, newExpiry: student.expiry),
  );

  Future<void> _sendWhatsAppReminder(Student student) async {
    final phone = student.phone.replaceAll(RegExp(r'\D'), '');
    final message = Uri.encodeComponent(
      'Hi ${student.name}, your StudyDesk plan expires on ${student.expiry}. '
      'Please renew your plan for the next month to continue your membership.',
    );
    final launched = await launchUrl(
      Uri.parse('https://wa.me/$phone?text=$message'),
      mode: LaunchMode.externalApplication,
    );
    if (!launched && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp.')));
    }
  }
}

class _FeeOverview extends StatelessWidget {
  final List<Student> students;
  final int expiringSoon;
  const _FeeOverview({required this.students, required this.expiringSoon});

  @override
  Widget build(BuildContext context) {
    final collected = students
        .where((student) => student.payment == PaymentStatus.paid)
        .fold<double>(0, (total, student) => total + student.fee);
    final pending = students
        .where((student) => student.payment != PaymentStatus.paid)
        .fold<double>(0, (total, student) => total + student.fee);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: const Color(0xFFE4E7EF)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights_outlined, size: 18, color: Color(0xFF5145EA)),
              SizedBox(width: 8),
              Text(
                'Collection overview',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              ),
              Spacer(),
              Text(
                'This month',
                style: TextStyle(fontSize: 10, color: Color(0xFF858B9D)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _OverviewMetric(
                  label: 'COLLECTED',
                  value: money(collected),
                  color: const Color(0xFF24926B),
                ),
              ),
              const _MetricDivider(),
              Expanded(
                child: _OverviewMetric(
                  label: 'PENDING',
                  value: money(pending),
                  color: const Color(0xFFC6812C),
                  note: 'to collect',
                ),
              ),
              const _MetricDivider(),
              Expanded(
                child: _OverviewMetric(
                  label: 'EXPIRING',
                  value: '$expiringSoon',
                  color: const Color(0xFF5B55C9),
                  note: 'within 5 days',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  final String label;
  final String value;
  final String? note;
  final Color color;
  const _OverviewMetric({
    required this.label,
    required this.value,
    required this.color,
    this.note,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 8,
          color: Color(0xFF9297A7),
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        value,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
      Text(
        note ?? 'received',
        style: const TextStyle(fontSize: 8, color: Color(0xFF9297A7)),
      ),
    ],
  );
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 46,
    margin: const EdgeInsets.symmetric(horizontal: 10),
    color: const Color(0xFFE9EBF1),
  );
}

class _FeeCard extends StatelessWidget {
  final Student student;
  final VoidCallback onRenew, onSendReminder, onViewReceipt;
  const _FeeCard({
    required this.student,
    required this.onRenew,
    required this.onSendReminder,
    required this.onViewReceipt,
  });

  @override
  Widget build(BuildContext context) {
    final paid = student.payment == PaymentStatus.paid,
        overdue = student.payment == PaymentStatus.expired;
    final color = paid
        ? const Color(0xFF23936B)
        : overdue
        ? const Color(0xFFD3545D)
        : const Color(0xFFC47D25);
    return Container(
      height: 190,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: const Color(0xFFE4E7EF)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAE8FA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              student.initials,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF625CA6),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          student.name,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Plan expires ${student.expiry} · ${money(student.fee)}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF8F94A3),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: color.withAlpha(22),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(radius: 3, backgroundColor: color),
                          const SizedBox(width: 6),
                          Text(
                            paid
                                ? 'Paid'
                                : overdue
                                ? 'Overdue'
                                : 'Pending',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 18, color: Color(0xFFEAECEF)),
          if (student.hasRenewedPlan)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onViewReceipt,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(38),
                  backgroundColor: const Color(0xFF5145EA),
                ),
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                label: const Text(
                  'View payment receipt (PDF)',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRenew,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(38),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      foregroundColor: const Color(0xFF5145EA),
                      side: const BorderSide(color: Color(0xFFD9D6FA)),
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 17),
                    label: const Text(
                      'Renew plan',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onSendReminder,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(38),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      backgroundColor: const Color(0xFF23936B),
                    ),
                    icon: const WhatsAppLogo(size: 17),
                    label: const Text(
                      'WhatsApp reminder',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
