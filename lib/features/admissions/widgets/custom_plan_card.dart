import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomPlanCard extends StatefulWidget {
  final DateTime start;
  final DateTime? end;
  final int? days;
  final double? amount;
  final ValueChanged<DateTime> onStart, onEnd;
  final ValueChanged<int?> onDays;
  final ValueChanged<double?> onAmount;
  const CustomPlanCard({
    super.key,
    required this.start,
    required this.end,
    required this.days,
    required this.amount,
    required this.onStart,
    required this.onEnd,
    required this.onDays,
    required this.onAmount,
  });
  @override
  State<CustomPlanCard> createState() => _State();
}

class _State extends State<CustomPlanCard> {
  late final TextEditingController days;
  late final TextEditingController amount;
  @override
  void initState() {
    super.initState();
    days = TextEditingController(text: widget.days?.toString() ?? '');
    amount = TextEditingController(
      text: widget.amount?.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    days.dispose();
    amount.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CustomPlanCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final dayText = widget.end == null ? '' : widget.days?.toString() ?? '';
    final amountText = widget.end == null
        ? ''
        : widget.amount?.toStringAsFixed(0) ?? '';
    if (days.text != dayText) days.text = dayText;
    if (amount.text != amountText) amount.text = amountText;
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFFFBFBFE),
      border: Border.all(color: const Color(0xFFDDD9FF)),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _DateField(
                label: 'Start Date',
                value: widget.start,
                onTap: () => _pickStart(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DateField(
                label: 'End Date',
                value: widget.end,
                onTap: () => _pickEnd(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: days,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Number of Days',
            helperText: 'Calculated from dates · Editable',
            prefixIcon: Icon(Icons.timelapse_outlined),
          ),
          onChanged: (value) => widget.onDays(int.tryParse(value)),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Fee Amount',
            helperText: 'Calculated from duration · Editable',
            prefixText: '₹  ',
          ),
          onChanged: (value) => widget.onAmount(double.tryParse(value)),
        ),
      ],
    ),
  );

  Future<void> _pickStart(BuildContext context) async {
    final value = await showDatePicker(
      context: context,
      initialDate: widget.start,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (value != null) widget.onStart(value);
  }

  Future<void> _pickEnd(BuildContext context) async {
    final value = await showDatePicker(
      context: context,
      initialDate: widget.end ?? widget.start.add(const Duration(days: 30)),
      firstDate: widget.start,
      lastDate: widget.start.add(const Duration(days: 3650)),
    );
    if (value != null) {
      widget.onEnd(value);
    }
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EF)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 8, color: Color(0xFF8E93A4)),
          ),
          const SizedBox(height: 4),
          Text(
            value == null ? '—' : DateFormat('d MMM yyyy').format(value!),
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    ),
  );
}
