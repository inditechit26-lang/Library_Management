import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/formatters.dart';
import '../../receipts/widgets/receipt_bottom_sheet.dart';
import '../../settings/controllers/pricing_controller.dart';
import '../../settings/models/pricing_settings.dart';
import '../controllers/students_controller.dart';
import '../models/student.dart';
import 'renewal_plan_selector.dart';
import 'renewal_payment_widgets.dart';

class RenewBottomSheet extends ConsumerStatefulWidget {
  final Student student;
  const RenewBottomSheet({super.key, required this.student});
  @override
  ConsumerState<RenewBottomSheet> createState() => _State();
}

class _State extends ConsumerState<RenewBottomSheet> {
  MembershipPeriod period = MembershipPeriod.monthly;
  DateTime? customExpiry;
  final customAmount = TextEditingController();
  double slide = 0;
  bool done = false;
  late final DateTime currentExpiry;

  @override
  void initState() {
    super.initState();
    currentExpiry = DateFormat('dd MMM yyyy').parse(widget.student.expiry);
  }

  @override
  void dispose() {
    customAmount.dispose();
    super.dispose();
  }

  PlanPricing get pricing =>
      ref.read(pricingProvider).forMembership(widget.student.membership);
  double get amount => period == MembershipPeriod.custom
      ? double.tryParse(customAmount.text) ?? -1
      : pricing.priceFor(period);
  DateTime get expiryDate => period == MembershipPeriod.custom
      ? customExpiry ?? currentExpiry
      : DateTime(
          currentExpiry.year,
          currentExpiry.month + period.months,
          currentExpiry.day,
        );
  String get expiry => DateFormat('dd MMM yyyy').format(expiryDate);
  bool get valid =>
      period != MembershipPeriod.custom ||
      (customExpiry != null && amount >= 0);

  @override
  Widget build(BuildContext context) => SizedBox(
    height: MediaQuery.sizeOf(context).height * .92,
    child: AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      child: done ? _success() : _payment(),
    ),
  );

  Widget _payment() {
    final livePricing = ref
        .watch(pricingProvider)
        .forMembership(widget.student.membership);
    return Column(
      key: const ValueKey(false),
      children: [
        const SizedBox(height: 10),
        const _Handle(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Renew Membership',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${widget.student.name} · ${widget.student.membership == MembershipType.fullTime ? 'Full Time' : 'Half Time'}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8B90A1),
                  ),
                ),
                const SizedBox(height: 18),
                RenewalPlanSelector(
                  selected: period,
                  pricing: livePricing,
                  onSelected: (value) => setState(() {
                    period = value;
                    slide = 0;
                  }),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  child: period == MembershipPeriod.custom
                      ? Padding(
                          key: const ValueKey(true),
                          padding: const EdgeInsets.only(top: 12),
                          child: RenewalCustomFields(
                            currentExpiry: currentExpiry,
                            selectedExpiry: customExpiry,
                            amount: customAmount,
                            onExpiry: (value) =>
                                setState(() => customExpiry = value),
                            onAmount: (_) => setState(() => slide = 0),
                          ),
                        )
                      : const SizedBox(key: ValueKey(false)),
                ),
                const SizedBox(height: 12),
                RenewalDateSummary(
                  current: widget.student.expiry,
                  expiry: expiry,
                  plan: period.label,
                  amount: valid ? amount : 0,
                ),
                const SizedBox(height: 12),
                RenewalPaymentCard(amount: valid ? amount : 0),
                const SizedBox(height: 14),
                RenewalSlideConfirm(
                  value: slide,
                  enabled: valid,
                  onChanged: (value) {
                    setState(() => slide = value);
                    if (value > .95) _complete();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _complete() {
    ref
        .read(studentsProvider.notifier)
        .renew(widget.student, expiry, fee: amount);
    setState(() => done = true);
  }

  Widget _success() {
    final receiptStudent = widget.student.copyWith(
      expiry: expiry,
      fee: amount,
      payment: PaymentStatus.paid,
    );
    return SingleChildScrollView(
      key: const ValueKey(true),
      padding: EdgeInsets.fromLTRB(
        22,
        10,
        22,
        MediaQuery.paddingOf(context).bottom + 20,
      ),
      child: Column(
        children: [
          const _Handle(),
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE8F7F0),
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 38,
              color: Color(0xFF2B8F69),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Membership Renewed Successfully',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          _Surface(
            child: Column(
              children: [
                _line('Plan', period.label),
                _line('Amount', money(amount)),
                _line('New expiry', expiry),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => ReceiptBottomSheet(
                  student: receiptStudent,
                  newExpiry: expiry,
                ),
              ),
              child: const Text('View Receipt'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _line(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: Color(0xFF858B9C))),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    ),
  );
}

class _Handle extends StatelessWidget {
  const _Handle();
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 38,
      height: 4,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFD9DBE4),
        borderRadius: BorderRadius.circular(4),
      ),
    ),
  );
}

class _Surface extends StatelessWidget {
  final Widget child;
  const _Surface({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE5E7EF)),
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0920243B),
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: child,
  );
}
