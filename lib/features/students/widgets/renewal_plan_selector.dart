import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/formatters.dart';
import '../../settings/models/pricing_settings.dart';

class RenewalPlanSelector extends StatelessWidget {
  final MembershipPeriod selected;
  final PlanPricing pricing;
  final ValueChanged<MembershipPeriod> onSelected;
  const RenewalPlanSelector({
    super.key,
    required this.selected,
    required this.pricing,
    required this.onSelected,
  });
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = (constraints.maxWidth - 10) / 2;
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: MembershipPeriod.values
            .map(
              (period) => SizedBox(
                width: period == MembershipPeriod.custom
                    ? constraints.maxWidth
                    : width,
                child: _Plan(
                  period: period,
                  amount: period == MembershipPeriod.custom
                      ? null
                      : pricing.priceFor(period),
                  selected: selected == period,
                  onTap: () => onSelected(period),
                ),
              ),
            )
            .toList(),
      );
    },
  );
}

class _Plan extends StatelessWidget {
  final MembershipPeriod period;
  final double? amount;
  final bool selected;
  final VoidCallback onTap;
  const _Plan({
    required this.period,
    required this.amount,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => AnimatedScale(
    scale: selected ? 1 : .98,
    duration: const Duration(milliseconds: 200),
    child: Material(
      color: selected ? const Color(0xFFF3F2FF) : Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 86,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: selected
                  ? const Color(0xFF625BCD)
                  : const Color(0xFFE5E7EF),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                period == MembershipPeriod.custom
                    ? Icons.edit_calendar_outlined
                    : Icons.calendar_month_outlined,
                color: const Color(0xFF5650C7),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      period.label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      amount == null ? period.duration : money(amount!),
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFF858B9C),
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF5650C7),
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class RenewalCustomFields extends StatelessWidget {
  final DateTime currentExpiry;
  final DateTime? selectedExpiry;
  final TextEditingController amount;
  final ValueChanged<DateTime> onExpiry;
  final ValueChanged<String> onAmount;
  const RenewalCustomFields({
    super.key,
    required this.currentExpiry,
    required this.selectedExpiry,
    required this.amount,
    required this.onExpiry,
    required this.onAmount,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: const Color(0xFFFBFBFE),
      border: Border.all(color: const Color(0xFFDDD9FF)),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      children: [
        InkWell(
          onTap: () => _pick(context),
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE5E7EF)),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const Icon(Icons.event_outlined, color: Color(0xFF5650C7)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedExpiry == null
                        ? 'Select Expiry Date'
                        : DateFormat('dd MMM yyyy').format(selectedExpiry!),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
        const SizedBox(height: 11),
        TextField(
          controller: amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Amount',
            prefixText: '₹  ',
          ),
          onChanged: onAmount,
        ),
      ],
    ),
  );

  Future<void> _pick(BuildContext context) async {
    final value = await showDatePicker(
      context: context,
      initialDate:
          selectedExpiry ?? currentExpiry.add(const Duration(days: 30)),
      firstDate: currentExpiry.add(const Duration(days: 1)),
      lastDate: DateTime(
        currentExpiry.year + 10,
        currentExpiry.month,
        currentExpiry.day,
      ),
    );
    if (value != null) onExpiry(value);
  }
}
