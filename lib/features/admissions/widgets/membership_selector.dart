import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../../students/models/student.dart';
import '../../settings/models/library_configuration.dart';

class MembershipSelector extends StatelessWidget {
  final SeatCategory selectedCategory;
  final MembershipType selected;
  final double fullTimeMonthly, halfTimeMonthly;
  final List<String> shifts;
  final String? selectedShift;
  final ValueChanged<SeatCategory>? onCategoryChanged;
  final ValueChanged<MembershipType> onChanged;
  final ValueChanged<String>? onShiftChanged;
  final bool fullTimeEnabled;
  final bool halfTimeEnabled;
  final bool showCategorySelector;
  final Set<LibrarySeatType> enabledSeatTypes;
  final LibrarySeatType selectedSeatType;
  final ValueChanged<LibrarySeatType> onSeatTypeChanged;

  const MembershipSelector({
    super.key,
    required this.selectedCategory,
    required this.selected,
    required this.fullTimeMonthly,
    required this.halfTimeMonthly,
    this.shifts = const [],
    this.selectedShift,
    this.onCategoryChanged,
    required this.onChanged,
    this.onShiftChanged,
    this.fullTimeEnabled = true,
    this.halfTimeEnabled = true,
    this.showCategorySelector = true,
    required this.enabledSeatTypes,
    required this.selectedSeatType,
    required this.onSeatTypeChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (showCategorySelector) ...[
        _CategorySectionBar(
          selected: selectedCategory,
          onChanged: onCategoryChanged,
        ),
        const SizedBox(height: 16),
      ],
      if (enabledSeatTypes.contains(LibrarySeatType.fullTimeReserved))
        _PlanCard(
          title: 'FULL-TIME RESERVED',
          subtitle: 'Reserved Seat',
          fee: money(fullTimeMonthly),
          icon: Icons.workspace_premium_outlined,
          benefits: const [
            'Reserved Seat',
            'Unlimited Access',
            'Priority Seating',
          ],
          selected: selectedSeatType == LibrarySeatType.fullTimeReserved,
          onTap: () {
            onSeatTypeChanged(LibrarySeatType.fullTimeReserved);
            onChanged(MembershipType.fullTime);
          },
        ),
      if (enabledSeatTypes.contains(LibrarySeatType.fullTimeReserved) &&
          enabledSeatTypes.length > 1)
        const SizedBox(height: 14),
      if (enabledSeatTypes.contains(LibrarySeatType.halfTimeOpenSeating))
        _PlanCard(
          title: 'HALF-TIME OPEN SEATING',
          subtitle: 'Flexible shared seating',
          fee: money(halfTimeMonthly),
          icon: Icons.schedule_outlined,
          benefits: const ['Affordable', 'Flexible Seating', 'Shared Seats'],
          selected: selectedSeatType == LibrarySeatType.halfTimeOpenSeating,
          onTap: () {
            onSeatTypeChanged(LibrarySeatType.halfTimeOpenSeating);
            onChanged(MembershipType.halfTime);
          },
        ),
      if (enabledSeatTypes.contains(LibrarySeatType.halfTimeOpenSeating) &&
          enabledSeatTypes.contains(LibrarySeatType.halfTimeReserved))
        const SizedBox(height: 14),
      if (enabledSeatTypes.contains(LibrarySeatType.halfTimeReserved))
        _PlanCard(
          title: 'HALF-TIME RESERVED',
          subtitle: 'Dedicated seat during a shift',
          fee: money(halfTimeMonthly),
          icon: Icons.event_seat_outlined,
          benefits: const [
            'Reserved Seat',
            'Fixed Shift',
            'Predictable Access',
          ],
          selected: selectedSeatType == LibrarySeatType.halfTimeReserved,
          onTap: () {
            onSeatTypeChanged(LibrarySeatType.halfTimeReserved);
            onChanged(MembershipType.halfTime);
          },
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

class _CategorySectionBar extends StatelessWidget {
  final SeatCategory selected;
  final ValueChanged<SeatCategory>? onChanged;

  const _CategorySectionBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? theme.colorScheme.surfaceContainerHigh
            : const Color(0xFFEFF1F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SectionTab(
              label: 'AC Section',
              icon: Icons.ac_unit_rounded,
              isSelected: selected == SeatCategory.ac,
              onTap: () => onChanged?.call(SeatCategory.ac),
            ),
          ),
          Expanded(
            child: _SectionTab(
              label: 'Non-AC Section',
              icon: Icons.air_rounded,
              isSelected: selected == SeatCategory.nonAc,
              onTap: () => onChanged?.call(SeatCategory.nonAc),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SectionTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? colors.surface : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? colors.primary : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? colors.primary : colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const WheelTimeRangePickerDialog(),
    );
    if (result != null && mounted) {
      _customTimeController.text = result;
      widget.onShiftChanged?.call(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeShift = widget.selectedShift ?? widget.shifts.first;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.25)
            : const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time_filled_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Set Half-Time Shift Time',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
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
                final colors = Theme.of(context).colorScheme;
                return ChoiceChip(
                  label: Text(shift),
                  selected: isSelected,
                  selectedColor: colors.primary,
                  backgroundColor: colors.surface,
                  labelStyle: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? colors.onPrimary
                        : colors.onSurfaceVariant,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? colors.primary : colors.outline,
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
                selectedColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(context).colorScheme.surface,
                labelStyle: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: _isCustomMode
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _isCustomMode
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.time_to_leave_rounded,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
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
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.edit_calendar_rounded,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
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

class WheelTimeRangePickerDialog extends StatefulWidget {
  const WheelTimeRangePickerDialog({super.key});

  @override
  State<WheelTimeRangePickerDialog> createState() =>
      _WheelTimeRangePickerDialogState();
}

class _WheelTimeRangePickerDialogState
    extends State<WheelTimeRangePickerDialog> {
  int _startHour = 6;
  int _startMinute = 0;
  String _startPeriod = 'AM';

  int _endHour = 2;
  int _endMinute = 0;
  String _endPeriod = 'PM';

  late final FixedExtentScrollController _startHourCtrl;
  late final FixedExtentScrollController _startMinCtrl;
  late final FixedExtentScrollController _startPeriodCtrl;
  late final FixedExtentScrollController _endHourCtrl;
  late final FixedExtentScrollController _endMinCtrl;
  late final FixedExtentScrollController _endPeriodCtrl;

  @override
  void initState() {
    super.initState();
    _startHourCtrl = FixedExtentScrollController(initialItem: _startHour - 1);
    _startMinCtrl = FixedExtentScrollController(initialItem: _startMinute ~/ 5);
    _startPeriodCtrl = FixedExtentScrollController(initialItem: 0);

    _endHourCtrl = FixedExtentScrollController(initialItem: _endHour - 1);
    _endMinCtrl = FixedExtentScrollController(initialItem: _endMinute ~/ 5);
    _endPeriodCtrl = FixedExtentScrollController(initialItem: 1);
  }

  @override
  void dispose() {
    _startHourCtrl.dispose();
    _startMinCtrl.dispose();
    _startPeriodCtrl.dispose();
    _endHourCtrl.dispose();
    _endMinCtrl.dispose();
    _endPeriodCtrl.dispose();
    super.dispose();
  }

  String _formatTime(int hour, int minute, String period) {
    final m = minute.toString().padLeft(2, '0');
    return '$hour:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? colors.surface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.watch_later_outlined, color: colors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Half-Time Shift Wheel Picker',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      Text(
                        'Scroll the wheels to pick start and end time',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _TimeWheelColumn(
                    title: 'Start Time',
                    hourController: _startHourCtrl,
                    minuteController: _startMinCtrl,
                    periodController: _startPeriodCtrl,
                    onHourChanged: (val) => setState(() => _startHour = val + 1),
                    onMinuteChanged: (val) =>
                        setState(() => _startMinute = val * 5),
                    onPeriodChanged: (val) =>
                        setState(() => _startPeriod = val == 0 ? 'AM' : 'PM'),
                  ),
                ),
                Container(
                  height: 120,
                  width: 1,
                  color: colors.outlineVariant,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                Expanded(
                  child: _TimeWheelColumn(
                    title: 'End Time',
                    hourController: _endHourCtrl,
                    minuteController: _endMinCtrl,
                    periodController: _endPeriodCtrl,
                    onHourChanged: (val) => setState(() => _endHour = val + 1),
                    onMinuteChanged: (val) =>
                        setState(() => _endMinute = val * 5),
                    onPeriodChanged: (val) =>
                        setState(() => _endPeriod = val == 0 ? 'AM' : 'PM'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.schedule_rounded, size: 18, color: colors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Selected Shift: ${_formatTime(_startHour, _startMinute, _startPeriod)} - ${_formatTime(_endHour, _endMinute, _endPeriod)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    final startStr = _formatTime(_startHour, _startMinute, _startPeriod);
                    final endStr = _formatTime(_endHour, _endMinute, _endPeriod);
                    Navigator.pop(context, 'Shift ($startStr - $endStr)');
                  },
                  child: const Text('Set Shift'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeWheelColumn extends StatelessWidget {
  final String title;
  final FixedExtentScrollController hourController;
  final FixedExtentScrollController minuteController;
  final FixedExtentScrollController periodController;
  final ValueChanged<int> onHourChanged;
  final ValueChanged<int> onMinuteChanged;
  final ValueChanged<int> onPeriodChanged;

  const _TimeWheelColumn({
    required this.title,
    required this.hourController,
    required this.minuteController,
    required this.periodController,
    required this.onHourChanged,
    required this.onMinuteChanged,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 36,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      controller: hourController,
                      itemExtent: 32,
                      perspective: 0.005,
                      diameterRatio: 1.2,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: onHourChanged,
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 12,
                        builder: (context, index) => Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Text(':', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      controller: minuteController,
                      itemExtent: 32,
                      perspective: 0.005,
                      diameterRatio: 1.2,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: onMinuteChanged,
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 12,
                        builder: (context, index) => Center(
                          child: Text(
                            (index * 5).toString().padLeft(2, '0'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      controller: periodController,
                      itemExtent: 32,
                      perspective: 0.005,
                      diameterRatio: 1.2,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: onPeriodChanged,
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 2,
                        builder: (context, index) => Center(
                          child: Text(
                            index == 0 ? 'AM' : 'PM',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bg = selected
        ? (isDark
              ? colors.primaryContainer.withValues(alpha: 0.35)
              : const Color(0xFFF5F4FF))
        : colors.surface;

    return AnimatedScale(
      scale: selected ? 1 : .985,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: Material(
        color: bg,
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
                color: selected ? colors.primary : colors.outline,
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
                        children: benefits
                            .map((item) => _Benefit(item))
                            .toList(),
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
