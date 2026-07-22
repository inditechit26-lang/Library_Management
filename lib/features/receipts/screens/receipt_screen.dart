import 'package:flutter/material.dart';
import '../../../core/settings/app_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/utils/formatters.dart';
import '../widgets/receipt_bottom_sheet.dart';
import '../../students/controllers/students_controller.dart';
import '../../students/models/student.dart';
import '../../students/widgets/profile_header.dart';
import '../../students/widgets/renew_bottom_sheet.dart';

enum _MembershipFilter { all, expired, active, expiringSoon }

extension on _MembershipFilter {
  String get label => switch (this) {
    _MembershipFilter.all => 'All Fees',
    _MembershipFilter.expired => 'Expired Plans',
    _MembershipFilter.active => 'Active Members',
    _MembershipFilter.expiringSoon => 'Expiring Soon (5 Days)',
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 36),
      children: [
        // Ultra-Premium Fee Overview Hero Card
        _FeeOverview(
          students: allStudents,
          expiringSoon: _countExpiringSoon(allStudents),
        ),
        const SizedBox(height: 22),

        // Search Bar with M3 Rounded Styling & Clear Action
        SizedBox(
          height: 52,
          child: TextField(
            onChanged: (v) => setState(() => query = v),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 22,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
              hintText: 'Search student by name or room...',
              hintStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF181C2B) : const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF262C40) : const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.8,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Modern Segmented Filter Pills
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
                        horizontal: 14,
                        vertical: 9,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: BorderSide(
                        color: selectedFilter == filter
                            ? theme.colorScheme.primary
                            : isDark
                                ? const Color(0xFF262C40)
                                : const Color(0xFFE2E8F0),
                        width: 1.2,
                      ),
                      selectedColor: theme.colorScheme.primary.withOpacity(0.18),
                      backgroundColor: isDark
                          ? const Color(0xFF181C2B)
                          : const Color(0xFFF8FAFC),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: selectedFilter == filter
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: selectedFilter == filter
                            ? theme.colorScheme.primary
                            : isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                      ),
                      showCheckmark: false,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 22),

        // Subheader count summary
        Text(
          '${students.length} ${students.length == 1 ? 'record found' : 'records found'}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 16),

        if (students.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF181C2B) : Colors.white,
              border: Border.all(
                color: isDark ? const Color(0xFF262C40) : const Color(0xFFE2E8F0),
                width: 1.2,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.payments_outlined,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'No fee records found',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Try adjusting your search or active filter.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          )
        else
          ...students.map(
            (student) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
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

    bool launched = false;
    for (final uri in urisToTry) {
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (launched) break;
      } catch (_) {}
    }

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('WhatsApp reminder ready for ${student.name}'),
          backgroundColor: const Color(0xFF25D366),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181C2B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF262C40) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.35)
                : const Color(0xFF1E2238).withOpacity(0.06),
            blurRadius: 22,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _OverviewMetric(
              label: 'COLLECTED',
              value: money(collected),
              color: const Color(0xFF10B981),
              icon: Icons.check_circle_outline_rounded,
            ),
          ),
          const _MetricDivider(),
          Expanded(
            child: _OverviewMetric(
              label: 'PENDING',
              value: money(pending),
              color: const Color(0xFFF59E0B),
              note: 'to collect',
              icon: Icons.pending_actions_rounded,
            ),
          ),
          const _MetricDivider(),
          Expanded(
            child: _OverviewMetric(
              label: 'EXPIRING',
              value: '$expiringSoon',
              color: const Color(0xFF6366F1),
              note: 'in 5 days',
              icon: Icons.timer_outlined,
            ),
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
  final IconData icon;

  const _OverviewMetric({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
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
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5,
                  letterSpacing: 0.8,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          note ?? 'received',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
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
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF262C40) : const Color(0xFFE2E8F0),
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
        ? const Color(0xFF10B981)
        : overdue
        ? const Color(0xFFEF4444)
        : const Color(0xFFF59E0B);

    final avatarBg = isDark
        ? theme.colorScheme.primary.withOpacity(0.18)
        : const Color(0xFFEEF2FF);

    final avatarTextColor = isDark
        ? theme.colorScheme.primary
        : const Color(0xFF6366F1);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181C2B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF262C40) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : const Color(0xFF1E2238).withOpacity(0.04),
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
              // Modern Student Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: avatarBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: avatarTextColor.withOpacity(0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    student.initials,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: avatarTextColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Expires ${student.expiry} · ${money(student.fee)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: statusColor.withOpacity(0.3),
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
                    const SizedBox(width: 6),
                    Text(
                      paid
                          ? 'Paid'
                          : overdue
                          ? 'Overdue'
                          : 'Pending',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF262C40) : const Color(0xFFE2E8F0),
          ),
          const SizedBox(height: 16),
          if (student.hasRenewedPlan)
            SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton.icon(
                onPressed: onViewReceipt,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: theme.colorScheme.primary,
                ),
                icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                label: const Text(
                  'View Payment Receipt (PDF)',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
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
                      minimumSize: const Size.fromHeight(44),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      foregroundColor: theme.colorScheme.primary,
                      side: BorderSide(
                        color: theme.colorScheme.primary.withOpacity(0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text(
                      'Renew Plan',
                      style: TextStyle(
                        fontSize: 12.5,
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
                      minimumSize: const Size.fromHeight(44),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      backgroundColor: const Color(0xFF25D366),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 17, color: Colors.white),
                    label: const Text(
                      'WhatsApp',
                      style: TextStyle(
                        fontSize: 12,
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
