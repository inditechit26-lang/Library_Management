import 'package:flutter/material.dart';
import '../../../core/settings/app_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/formatters.dart';
import '../../students/controllers/students_controller.dart';
import '../../students/models/student.dart';
import '../../students/widgets/renew_bottom_sheet.dart';

enum _MembershipFilter { all, expired, active, expiringSoon }

extension on _MembershipFilter {
  String get label => switch (this) {
    _MembershipFilter.all => 'All students',
    _MembershipFilter.expired => 'Expired membership',
    _MembershipFilter.active => 'Currently active',
    _MembershipFilter.expiringSoon => 'Expiring in 5 days',
  };

  IconData get icon => switch (this) {
    _MembershipFilter.all => Icons.groups_rounded,
    _MembershipFilter.expired => Icons.error_outline_rounded,
    _MembershipFilter.active => Icons.verified_outlined,
    _MembershipFilter.expiringSoon => Icons.timer_outlined,
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
    final students = ref
        .watch(studentsProvider)
        .where(
          (student) =>
              student.name.toLowerCase().contains(query.toLowerCase()) &&
              _matchesFilter(student),
        )
        .toList();
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
      child: ListView(
        physics: const ClampingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        children: [
          SizedBox(
            height: 86,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _Summary(
                  'TOTAL COLLECTED',
                  '₹86,200',
                  '12.5%',
                  Icons.currency_rupee,
                  Color(0xFF24926B),
                  Color(0xFFE9F7F1),
                ),
                _Summary(
                  'PENDING AMOUNT',
                  '₹23,800',
                  '12 students',
                  Icons.schedule,
                  Color(0xFFC6812C),
                  Color(0xFFFFF1E2),
                ),
                _Summary(
                  'THIS MONTH',
                  '47 payments',
                  '78% collected',
                  Icons.calendar_month_outlined,
                  Color(0xFF5B55C9),
                  Color(0xFFF0EFFF),
                ),
              ],
            ),
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
          Row(
            children: [
              const Text(
                'MEMBERSHIP FILTER',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF8F94A3),
                ),
              ),
              const Spacer(),
              if (selectedFilter != _MembershipFilter.all)
                TextButton(
                  onPressed: () =>
                      setState(() => selectedFilter = _MembershipFilter.all),
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Clear filter',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _MembershipFilter.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _MembershipFilter.values[index];
                final selected = selectedFilter == filter;
                return ChoiceChip(
                  selected: selected,
                  onSelected: (_) => setState(() => selectedFilter = filter),
                  avatar: Icon(
                    filter.icon,
                    size: 16,
                    color: selected ? Colors.white : const Color(0xFF777D91),
                  ),
                  label: Text(
                    filter.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : const Color(0xFF4D5365),
                    ),
                  ),
                  selectedColor: const Color(0xFF5145EA),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  side: BorderSide(
                    color: selected
                        ? const Color(0xFF5145EA)
                        : const Color(0xFFE0E3EB),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
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
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _matchesFilter(Student student) {
    final today = DateUtils.dateOnly(DateTime.now());
    final expiry = DateUtils.dateOnly(
      DateFormat('dd MMM yyyy').parse(student.expiry),
    );
    final daysRemaining = expiry.difference(today).inDays;
    return switch (selectedFilter) {
      _MembershipFilter.all => true,
      _MembershipFilter.expired => daysRemaining < 0,
      _MembershipFilter.active => daysRemaining >= 0,
      _MembershipFilter.expiringSoon =>
        daysRemaining >= 0 && daysRemaining <= 5,
    };
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

class _Summary extends StatelessWidget {
  final String label, value, note;
  final IconData icon;
  final Color color, bg;
  const _Summary(
    this.label,
    this.value,
    this.note,
    this.icon,
    this.color,
    this.bg,
  );
  @override
  Widget build(BuildContext context) => Container(
    width: 235,
    margin: const EdgeInsets.only(right: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: const Color(0xFFE4E7EF)),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 8, color: Color(0xFF999EAC)),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            Text(note, style: TextStyle(fontSize: 8, color: color)),
          ],
        ),
      ],
    ),
  );
}

class _FeeCard extends StatelessWidget {
  final Student student;
  final VoidCallback onRenew, onSendReminder;
  const _FeeCard({
    required this.student,
    required this.onRenew,
    required this.onSendReminder,
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
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
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
                  icon: const Icon(Icons.chat_outlined, size: 17),
                  label: const Text(
                    'WhatsApp reminder',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
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
