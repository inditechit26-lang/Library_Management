import 'package:flutter/material.dart';

class MonthlySelectorSheet extends StatefulWidget {
  final int initialMonth;
  final int initialYear;
  final Function(int month, int year) onSelected;

  const MonthlySelectorSheet({
    super.key,
    required this.initialMonth,
    required this.initialYear,
    required this.onSelected,
  });

  @override
  State<MonthlySelectorSheet> createState() => _MonthlySelectorSheetState();
}

class _MonthlySelectorSheetState extends State<MonthlySelectorSheet> {
  late int _selectedMonth;
  late int _selectedYear;

  final List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  final List<int> _years = [2024, 2025, 2026, 2027];

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.initialMonth;
    _selectedYear = widget.initialYear;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_month_rounded, color: Color(0xFF574DEB)),
                const SizedBox(width: 10),
                Text(
                  'Select Month & Year',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Year selector tabs
            Row(
              children: _years.map((y) {
                final isSelected = y == _selectedYear;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(
                        '$y',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : colors.onSurface,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFF574DEB),
                      onSelected: (val) {
                        if (val) setState(() => _selectedYear = y);
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Month Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.8,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 12,
              itemBuilder: (ctx, index) {
                final monthNum = index + 1;
                final isSelected = monthNum == _selectedMonth;

                return InkWell(
                  onTap: () => setState(() => _selectedMonth = monthNum),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF574DEB)
                          : colors.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF574DEB)
                            : colors.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _months[index],
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                        color: isSelected ? Colors.white : colors.onSurface,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF574DEB),
                    ),
                    onPressed: () {
                      widget.onSelected(_selectedMonth, _selectedYear);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
