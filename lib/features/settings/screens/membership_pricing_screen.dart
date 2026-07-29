import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../students/models/student.dart';
import '../controllers/pricing_controller.dart';
import '../models/pricing_settings.dart';

class MembershipPricingScreen extends ConsumerStatefulWidget {
  const MembershipPricingScreen({super.key});

  @override
  ConsumerState<MembershipPricingScreen> createState() =>
      _MembershipPricingScreenState();
}

class _MembershipPricingScreenState
    extends ConsumerState<MembershipPricingScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  SeatCategory _selectedCategory = SeatCategory.ac;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pricing = ref.watch(pricingProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Membership & Pricing',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 36),
        children: [
          // Header Hero Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E2438), const Color(0xFF161A29)]
                    : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
              ),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2E3752)
                    : const Color(0xFFC7D2FE),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plan Rate Configuration',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Customize AC & Non-AC rates for monthly, quarterly & annual plans.',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // AC / Non-AC Section Switcher Bar
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF191D2C) : const Color(0xFFEFF1F7),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2A2F45)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _CategoryPillTab(
                    label: 'AC Section',
                    icon: Icons.ac_unit_rounded,
                    isSelected: _selectedCategory == SeatCategory.ac,
                    onTap: () => setState(() => _selectedCategory = SeatCategory.ac),
                  ),
                ),
                Expanded(
                  child: _CategoryPillTab(
                    label: 'Non-AC Section',
                    icon: Icons.air_rounded,
                    isSelected: _selectedCategory == SeatCategory.nonAc,
                    onTap: () => setState(() => _selectedCategory = SeatCategory.nonAc),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Custom Segmented Pill Tab Bar (Full Time / Half Time)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF191D2C) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2A2F45)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: isDark
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF64748B),
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Full Time (24 Hours)'),
                Tab(text: 'Half Time (12 Hours)'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tab Contents
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              final isHalfTime = _tabController.index == 1;
              return SizedBox(
                height: isHalfTime ? 1080 : 720,
                child: TabBarView(
                  controller: _tabController,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _PlanEditorGroup(
                      category: _selectedCategory,
                      membership: MembershipType.fullTime,
                      pricing: pricing.forMembershipAndCategory(
                        MembershipType.fullTime,
                        _selectedCategory,
                      ),
                      shifts: pricing.halfTimeShifts,
                    ),
                    _PlanEditorGroup(
                      category: _selectedCategory,
                      membership: MembershipType.halfTime,
                      pricing: pricing.forMembershipAndCategory(
                        MembershipType.halfTime,
                        _selectedCategory,
                      ),
                      shifts: pricing.halfTimeShifts,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryPillTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryPillTab({
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
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? colors.surface : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
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
                size: 17,
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

class _PlanEditorGroup extends ConsumerWidget {
  final SeatCategory category;
  final MembershipType membership;
  final PlanPricing pricing;
  final List<String> shifts;

  const _PlanEditorGroup({
    required this.category,
    required this.membership,
    required this.pricing,
    required this.shifts,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final periods = [
      (MembershipPeriod.monthly, Icons.calendar_view_month_rounded),
      (MembershipPeriod.quarterly, Icons.grid_view_rounded),
      (MembershipPeriod.halfYearly, Icons.date_range_rounded),
      (MembershipPeriod.annual, Icons.workspace_premium_rounded),
    ];

    return Column(
      children: [
        for (final item in periods) ...[
          _PricingCard(
            period: item.$1,
            icon: item.$2,
            price: pricing.priceFor(item.$1),
            badge: pricing.badgeFor(item.$1),
            isDark: isDark,
            onPriceChanged: (val) {
              final amount = double.tryParse(val) ?? 0;
              ref
                  .read(pricingProvider.notifier)
                  .update(membership, item.$1, amount, category: category);
            },
            onBadgeChanged: (val) {
              ref
                  .read(pricingProvider.notifier)
                  .updateBadge(membership, item.$1, val, category: category);
            },
          ),
          const SizedBox(height: 14),
        ],
        if (membership == MembershipType.halfTime) ...[
          const SizedBox(height: 6),
          _HalfTimeShiftConfigCard(shifts: shifts, isDark: isDark),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}

class _HalfTimeShiftConfigCard extends ConsumerStatefulWidget {
  final List<String> shifts;
  final bool isDark;

  const _HalfTimeShiftConfigCard({required this.shifts, required this.isDark});

  @override
  ConsumerState<_HalfTimeShiftConfigCard> createState() =>
      __HalfTimeShiftConfigCardState();
}

class __HalfTimeShiftConfigCardState
    extends ConsumerState<_HalfTimeShiftConfigCard> {
  TimeOfDay _startTime = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 14, minute: 0);
  int? _editingIndex;
  String? _editingLabel;

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  String _suggestedShiftLabel(TimeOfDay time) {
    if (time.hour >= 5 && time.hour < 12) return 'Morning Shift';
    if (time.hour >= 12 && time.hour < 17) return 'Afternoon Shift';
    if (time.hour >= 17 && time.hour < 21) return 'Evening Shift';
    return 'Night Shift';
  }

  String _shiftValue() {
    final label = _editingLabel ?? _suggestedShiftLabel(_startTime);
    return '$label (${_formatTime(_startTime)} - ${_formatTime(_endTime)})';
  }

  TimeOfDay _timeFromParts(String hour, String minute, String period) {
    final hour12 = int.parse(hour);
    final hour24 = (hour12 % 12) + (period.toUpperCase() == 'PM' ? 12 : 0);
    return TimeOfDay(hour: hour24, minute: int.parse(minute));
  }

  void _editShift(int index) {
    final shift = widget.shifts[index];
    final match = RegExp(
      r'^(.*?)\s*\((\d{1,2}):(\d{2})\s*(AM|PM)\s*-\s*(\d{1,2}):(\d{2})\s*(AM|PM)\)$',
      caseSensitive: false,
    ).firstMatch(shift);

    setState(() {
      _editingIndex = index;
      _editingLabel = match?.group(1)?.trim();
      if (match != null) {
        _startTime = _timeFromParts(
          match.group(2)!,
          match.group(3)!,
          match.group(4)!,
        );
        _endTime = _timeFromParts(
          match.group(5)!,
          match.group(6)!,
          match.group(7)!,
        );
      }
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingIndex = null;
      _editingLabel = null;
      _startTime = const TimeOfDay(hour: 6, minute: 0);
      _endTime = const TimeOfDay(hour: 14, minute: 0);
    });
  }

  void _saveShift() {
    final notifier = ref.read(pricingProvider.notifier);
    if (_editingIndex case final index?) {
      notifier.updateHalfTimeShift(index, _shiftValue());
    } else {
      notifier.addHalfTimeShift(_shiftValue());
    }
    _cancelEditing();
  }

  Future<TimeOfDay?> _showWheelTimePicker(
    BuildContext context,
    TimeOfDay initialTime,
    String title,
  ) async {
    var selectedHour = initialTime.hourOfPeriod == 0
        ? 12
        : initialTime.hourOfPeriod;
    var selectedMinute = initialTime.minute;
    var selectedPeriod = initialTime.period == DayPeriod.am ? 0 : 1;
    final hourController = FixedExtentScrollController(
      initialItem: selectedHour - 1,
    );
    final minuteController = FixedExtentScrollController(
      initialItem: selectedMinute,
    );
    final periodController = FixedExtentScrollController(
      initialItem: selectedPeriod,
    );

    final result = await showModalBottomSheet<TimeOfDay>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return SafeArea(
          child: SizedBox(
            height: 350,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 12, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(
                          sheetContext,
                          TimeOfDay(
                            hour:
                                (selectedHour % 12) +
                                (selectedPeriod == 1 ? 12 : 0),
                            minute: selectedMinute,
                          ),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'HOUR',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'MINUTE',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'AM / PM',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: hourController,
                          itemExtent: 46,
                          useMagnifier: true,
                          magnification: 1.15,
                          onSelectedItemChanged: (index) {
                            selectedHour = index + 1;
                          },
                          children: [
                            for (var hour = 1; hour <= 12; hour++)
                              Center(
                                child: Text(
                                  hour.toString().padLeft(2, '0'),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Text(
                        ':',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker.builder(
                          scrollController: minuteController,
                          itemExtent: 46,
                          useMagnifier: true,
                          magnification: 1.15,
                          childCount: 60,
                          onSelectedItemChanged: (index) {
                            selectedMinute = index;
                          },
                          itemBuilder: (context, minute) => Center(
                            child: Text(
                              minute.toString().padLeft(2, '0'),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: periodController,
                          itemExtent: 46,
                          useMagnifier: true,
                          magnification: 1.15,
                          onSelectedItemChanged: (index) {
                            selectedPeriod = index;
                          },
                          children: const [
                            Center(
                              child: Text(
                                'AM',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                'PM',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    hourController.dispose();
    minuteController.dispose();
    periodController.dispose();
    return result;
  }

  Future<void> _pickStartTime() async {
    final time = await _showWheelTimePicker(
      context,
      _startTime,
      'Select Start Time',
    );
    if (time != null && mounted) setState(() => _startTime = time);
  }

  Future<void> _pickEndTime() async {
    final time = await _showWheelTimePicker(
      context,
      _endTime,
      'Select End Time',
    );
    if (time != null && mounted) setState(() => _endTime = time);
  }

  Widget _timeField({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: widget.isDark
              ? const Color(0xFF131724)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.isDark
                ? const Color(0xFF242A3E)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.schedule_rounded,
              size: 20,
              color: Color(0xFF8B5CF6),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTime(time),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.unfold_more_rounded,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = widget.isDark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : const Color(0xFF1E2238).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.access_time_filled_rounded,
                  size: 20,
                  color: Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Half Time Shift Options',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Configured shift times selectable during half time student admission',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              for (int i = 0; i < widget.shifts.length; i++) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF131724)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF242A3E)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 18,
                        color: Color(0xFF8B5CF6),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.shifts[i],
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_rounded,
                          size: 19,
                          color: Color(0xFF8B5CF6),
                        ),
                        onPressed: () => _editShift(i),
                        tooltip: 'Edit Shift Time',
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(6),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline_rounded,
                          size: 20,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => ref
                            .read(pricingProvider.notifier)
                            .removeHalfTimeShift(i),
                        tooltip: 'Remove Shift',
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _timeField(
                  label: 'START TIME',
                  time: _startTime,
                  onTap: _pickStartTime,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: Color(0xFF8B5CF6),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _timeField(
                  label: 'END TIME',
                  time: _endTime,
                  onTap: _pickEndTime,
                ),
              ),
            ],
          ),
          if (_editingIndex != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.edit_note_rounded,
                  size: 16,
                  color: Color(0xFF8B5CF6),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Editing ${_editingLabel ?? 'selected shift'}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _cancelEditing,
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _saveShift,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(
                _editingIndex == null ? Icons.add_rounded : Icons.check_rounded,
                size: 18,
              ),
              label: Text(
                _editingIndex == null ? 'Add Shift' : 'Save Shift Time',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  final MembershipPeriod period;
  final IconData icon;
  final double price;
  final String badge;
  final bool isDark;
  final ValueChanged<String> onPriceChanged;
  final ValueChanged<String> onBadgeChanged;

  const _PricingCard({
    required this.period,
    required this.icon,
    required this.price,
    required this.badge,
    required this.isDark,
    required this.onPriceChanged,
    required this.onBadgeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : const Color(0xFF1E2238).withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${period.label} Plan',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    period.duration,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (badge.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: TextFormField(
                  initialValue: price.toStringAsFixed(0),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Price Amount',
                    prefixText: '₹  ',
                    prefixStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF131724)
                        : const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDark
                            ? const Color(0xFF242A3E)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 1.8,
                      ),
                    ),
                  ),
                  onChanged: onPriceChanged,
                ),
              ),
              if (period != MembershipPeriod.monthly) ...[
                const SizedBox(width: 10),
                Expanded(
                  flex: 5,
                  child: TextFormField(
                    initialValue: badge,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Promo Badge Tag',
                      hintText: 'e.g. Popular',
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF131724)
                          : const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF242A3E)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 1.8,
                        ),
                      ),
                    ),
                    onChanged: onBadgeChanged,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
