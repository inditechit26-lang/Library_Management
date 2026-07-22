import 'package:flutter/material.dart';

class StudentFilterChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  const StudentFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });
  static const values = [
    'All',
    'Full Time',
    'Half Time',
    'Paid',
    'Pending',
    'Expiring',
    'Expired',
    'Newest',
    'Oldest',
  ];
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 44,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: values
          .map(
            (value) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(value),
                selected: selected == value,
                onSelected: (_) => onSelected(value),
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 9,
                ),
                side: BorderSide(
                  color: selected == value
                      ? Colors.transparent
                      : Theme.of(context).colorScheme.outlineVariant,
                ),
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
                backgroundColor: Theme.of(context).colorScheme.surface,
                labelStyle: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: selected == value
                      ? const Color(0xFF5145C8)
                      : const Color(0xFF74798A),
                ),
                showCheckmark: false,
              ),
            ),
          )
          .toList(),
    ),
  );
}
