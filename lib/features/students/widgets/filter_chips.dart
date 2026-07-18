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
    height: 42,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: values
          .map(
            (value) => Padding(
              padding: const EdgeInsets.only(right: 7),
              child: ChoiceChip(
                label: Text(value),
                selected: selected == value,
                onSelected: (_) => onSelected(value),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                side: BorderSide(
                  color: selected == value
                      ? const Color(0xFFCCC8FF)
                      : const Color(0xFFE1E4EB),
                ),
                selectedColor: const Color(0xFFF0EFFF),
                backgroundColor: Colors.white,
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
