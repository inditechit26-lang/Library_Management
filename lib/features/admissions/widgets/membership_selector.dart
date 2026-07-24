import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../../students/models/student.dart';

class MembershipSelector extends StatelessWidget {
  final MembershipType selected;
  final double fullTimeMonthly, halfTimeMonthly;
  final List<String> shifts;
  final String? selectedShift;
  final ValueChanged<MembershipType> onChanged;
  final ValueChanged<String>? onShiftChanged;

  const MembershipSelector({
    super.key,
    required this.selected,
    required this.fullTimeMonthly,
    required this.halfTimeMonthly,
    this.shifts = const [],
    this.selectedShift,
    required this.onChanged,
    this.onShiftChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _PlanCard(
        title: 'FULL TIME',
        subtitle: 'Reserved Seat',
        fee: money(fullTimeMonthly),
        icon: Icons.workspace_premium_outlined,
        benefits: const [
          'Reserved Seat',
          'Unlimited Access',
          'Priority Seating',
        ],
        selected: selected == MembershipType.fullTime,
        onTap: () => onChanged(MembershipType.fullTime),
      ),
      const SizedBox(height: 14),
      _PlanCard(
        title: 'HALF TIME',
        subtitle: 'Flexible Seating',
        fee: money(halfTimeMonthly),
        icon: Icons.schedule_outlined,
        benefits: const ['Affordable', 'Flexible Seating', 'Shared Seats'],
        selected: selected == MembershipType.halfTime,
        onTap: () => onChanged(MembershipType.halfTime),
      ),
      if (selected == MembershipType.halfTime && shifts.isNotEmpty) ...[
        const SizedBox(height: 14),
        _HalfTimeShiftSelector(
          shifts: shifts,
          selectedShift: selectedShift,
          onShiftChanged: onShiftChanged,
        ),
      ],
    ],
  );
}

class _HalfTimeShiftSelector extends StatefulWidget {
  final List<String> shifts;
  final String? selectedShift;
  final ValueChanged<String>? onShiftChanged;

  const _HalfTimeShiftSelector({
    required this.shifts,
    required this.selectedShift,
    required this.onShiftChanged,
  });

  @override
  State<_HalfTimeShiftSelector> createState() => _HalfTimeShiftSelectorState();
}

class _HalfTimeShiftSelectorState extends State<_HalfTimeShiftSelector> {
  bool _isCustomMode = false;
  final _customTimeController = TextEditingController();

  @override
  void dispose() {
    _customTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickCustomTimeRange() async {
    final start = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      helpText: 'Select Half-Time Shift Start Time',
    );
    if (start == null || !mounted) return;

    final end = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: (start.hour + 6) % 24, minute: start.minute),
      helpText: 'Select Half-Time Shift End Time',
    );
    if (end == null || !mounted) return;

    final formatted =
        'Custom (${start.format(context)} - ${end.format(context)})';
    _customTimeController.text = formatted;
    widget.onShiftChanged?.call(formatted);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeShift = widget.selectedShift ?? widget.shifts.first;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF7069DC).withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.access_time_filled_rounded,
                size: 20,
                color: Color(0xFF5650C7),
              ),
              const SizedBox(width: 8),
              const Text(
                'Set Half-Time Shift Time',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2C2E3E),
                ),
              ),
              const Spacer(),
              Text(
                'Required',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...widget.shifts.map((shift) {
                final isSelected = !_isCustomMode && activeShift == shift;
                return ChoiceChip(
                  label: Text(shift),
                  selected: isSelected,
                  selectedColor: const Color(0xFF5650C7),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : const Color(0xFF4B4F5E),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF5650C7)
                          : const Color(0xFFE2E4EC),
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _isCustomMode = false);
                      widget.onShiftChanged?.call(shift);
                    }
                  },
                );
              }),
              ChoiceChip(
                label: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.more_time_rounded, size: 14),
                    SizedBox(width: 4),
                    Text('Set Custom Time'),
                  ],
                ),
                selected: _isCustomMode,
                selectedColor: const Color(0xFF5650C7),
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: _isCustomMode ? Colors.white : const Color(0xFF4B4F5E),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _isCustomMode
                        ? const Color(0xFF5650C7)
                        : const Color(0xFFE2E4EC),
                  ),
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _isCustomMode = true);
                    _pickCustomTimeRange();
                  }
                },
              ),
            ],
          ),
          if (_isCustomMode) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickCustomTimeRange,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF5650C7)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.time_to_leave_rounded,
                        size: 18, color: Color(0xFF5650C7)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _customTimeController.text.isEmpty
                            ? 'Tap to pick shift timing...'
                            : _customTimeController.text,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: _customTimeController.text.isEmpty
                              ? Colors.grey.shade600
                              : const Color(0xFF2C2E3E),
                        ),
                      ),
                    ),
                    const Icon(Icons.edit_calendar_rounded,
                        size: 18, color: Color(0xFF5650C7)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title, subtitle, fee;
  final IconData icon;
  final List<String> benefits;
  final bool selected;
  final VoidCallback onTap;
  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.fee,
    required this.icon,
    required this.benefits,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => AnimatedScale(
    scale: selected ? 1 : .985,
    duration: const Duration(milliseconds: 220),
    curve: Curves.easeOutCubic,
    child: Material(
      color: selected ? const Color(0xFFF5F4FF) : Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected
                  ? const Color(0xFF7069DC)
                  : const Color(0xFFE5E7EF),
              width: selected ? 1.5 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A20243B),
                blurRadius: 26,
                offset: Offset(0, 9),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFE7E5FF)
                      : const Color(0xFFF3F4F8),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: const Color(0xFF5650C7)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .7,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF858B9D),
                      ),
                    ),
                    const SizedBox(height: 13),
                    Wrap(
                      spacing: 6,
                      runSpacing: 7,
                      children: benefits.map((item) => _Benefit(item)).toList(),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: selected
                        ? const Icon(
                            Icons.check_circle,
                            key: ValueKey(true),
                            color: Color(0xFF5650C7),
                            size: 22,
                          )
                        : const Icon(
                            Icons.circle_outlined,
                            key: ValueKey(false),
                            color: Color(0xFFB7BBC7),
                            size: 22,
                          ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    fee,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Benefit extends StatelessWidget {
  final String label;
  const _Benefit(this.label);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .8),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: const Color(0xFFE9EAF1)),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 8,
        fontWeight: FontWeight.w700,
        color: Color(0xFF676C7E),
      ),
    ),
  );
}
