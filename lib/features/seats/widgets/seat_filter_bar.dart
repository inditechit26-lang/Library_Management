import 'package:flutter/material.dart';

class SeatFilterBar extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  const SeatFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });
  static const filters = [
    'All',
    'Available',
    'Occupied',
    'Full Time',
    'Half Time',
    'Pending',
    'A',
    'B',
    'C',
    'D',
    'E',
  ];
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 40,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: filters.length,
      separatorBuilder: (context, index) => const SizedBox(width: 8),
      itemBuilder: (_, index) {
        final item = filters[index], active = item == selected;
        return ChoiceChip(
          label: Text(item.length == 1 ? '$item Row' : item),
          selected: active,
          showCheckmark: false,
          onSelected: (_) => onSelected(item),
          labelStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: active ? const Color(0xFF4F49B8) : const Color(0xFF6F7587),
          ),
        );
      },
    ),
  );
}
