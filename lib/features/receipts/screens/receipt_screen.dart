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
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        _FeeOverview(
          students: allStudents,
          expiringSoon: _countExpiringSoon(allStudents),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 52,
          child: TextField(
            onChanged: (v) => setState(() => query = v),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded, size: 22),
              hintText: context.tr('Search student...'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: _MembershipFilter.values
                .map(
                  (filter) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter.label),
                      selected: selectedFilter == filter,
                      onSelected: (_) =>
                          setState(() => selectedFilter = filter),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      side: BorderSide(
                        color: selectedFilter == filter
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.4)
                            : Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(context).colorScheme.outline.withOpacity(0.3)
                                : const Color(0xFFE2E5EE),
                        width: 1.2,
                      ),
                      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: selectedFilter == filter
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF9FA6B8)
                                : const Color(0xFF6E7487),
                      ),
                      showCheckmark: false,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Text(
              '${students.length} ${students.length == 1 ? 'student' : 'students'}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: -0.3,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF2A2E3B)
                    : const Color(0xFFF0F2F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _countExpiringSoon(allStudents) == 0
                    ? 'No plans expiring soon'
                    : '${_countExpiringSoon(allStudents)} expiring within 5 days',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFFA1A8B9)
                      : const Color(0xFF767C8E),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (students.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.outline.withOpacity(0.3)
                    : const Color(0xFFE4E7EF),
                width: 1.2,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.filter_alt_off_rounded,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'No students match this filter',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          )
        else
          ...students.map(
            (student) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
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
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => RenewBottomSheet(student: student),
  );

  void _viewReceipt(Student student) => showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) =>
        ReceiptBottomSheet(student: student, newExpiry: student.expiry),
  );

  Future<void> _sendWhatsAppReminder(Student student) async {
    final digits = student.phone.replaceAll(RegExp(r'\D'), '');
    final phone = digits.length == 10 ? '91$digits' : digits;
    final message = Uri.encodeComponent(
      'Hello ${student.name},\n\n'
      'This is a friendly reminder from The Study Room. Your membership is '
      'scheduled to expire on ${student.expiry}. To ensure uninterrupted access '
      'to your study space and services, kindly renew your membership at your '
      'earliest convenience.\n\n'
      'If you have already completed the payment, please disregard this message. '
      'For any assistance, feel free to reply here.\n\n'
      'Warm regards,\nThe Study Room Team',
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    final collected = students
        .where((student) => student.payment == PaymentStatus.paid)
        .fold<double>(0, (total, student) => total + student.fee);
    final pending = students
        .where((student) => student.payment != PaymentStatus.paid)
        .fold<double>(0, (total, student) => total + student.fee);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? theme.colorScheme.outline.withOpacity(0.35)
              : const Color(0xFFE6E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.35)
                : const Color(0xFF1E2238).withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.insights_rounded, size: 18, color: primary),
              ),
              const SizedBox(width: 10),
              Text(
                'Collection overview',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primary.withOpacity(0.18)),
                ),
                child: Text(
                  'This month',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
                  color: const Color(0xFF5145EA),
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5,
                  letterSpacing: 0.7,
                  color: isDark
                      ? const Color(0xFF9EA6BA)
                      : const Color(0xFF83899F),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          note ?? 'received',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFF868C9E) : const Color(0xFF7E8497),
          ),
        ),
      ],
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 1,
      height: 54,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            (isDark ? const Color(0xFF353C4D) : const Color(0xFFE8EAF0)).withOpacity(0.15),
            isDark ? const Color(0xFF353C4D) : const Color(0xFFE8EAF0),
            (isDark ? const Color(0xFF353C4D) : const Color(0xFFE8EAF0)).withOpacity(0.15),
          ],
        ),
      ),
    );
  }
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final paid = student.payment == PaymentStatus.paid,
        overdue = student.payment == PaymentStatus.expired;
    final statusColor = paid
        ? const Color(0xFF23936B)
        : overdue
        ? const Color(0xFFD3545D)
        : const Color(0xFFC47D25);
    final avatarBg = isDark
        ? theme.colorScheme.primary.withOpacity(0.18)
        : const Color(0xFFEAE8FA);
    final avatarTextColor = isDark
        ? theme.colorScheme.primary
        : const Color(0xFF5145EA);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? theme.colorScheme.outline.withOpacity(0.35)
              : const Color(0xFFE6E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : const Color(0xFF1E2238).withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: avatarBg,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: avatarTextColor.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    student.initials,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: avatarTextColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Plan expires ${student.expiry} · ${money(student.fee)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFF8F96A8)
                            : const Color(0xFF7E8497),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: statusColor.withOpacity(0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      paid
                          ? 'Paid'
                          : overdue
                          ? 'Overdue'
                          : 'Pending',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF2C3242) : const Color(0xFFEEF0F5),
          ),
          const SizedBox(height: 14),
          if (student.hasRenewedPlan)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onViewReceipt,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  backgroundColor: theme.colorScheme.primary,
                ),
                icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                label: const Text(
                  'View payment receipt (PDF)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
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
                      minimumSize: const Size.fromHeight(42),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      foregroundColor: theme.colorScheme.primary,
                      side: BorderSide(
                        color: theme.colorScheme.primary.withOpacity(0.35),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 17),
                    label: const Text(
                      'Renew plan',
                      style: TextStyle(
                        fontSize: 12,
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
                      minimumSize: const Size.fromHeight(42),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      backgroundColor: const Color(0xFF23936B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const WhatsAppLogo(size: 17),
                    label: const Text(
                      'WhatsApp reminder',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
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

