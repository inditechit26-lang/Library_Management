import 'package:flutter/material.dart';

class SeatFilter extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  const SeatFilter({
    super.key,
    required this.selected,
    required this.onSelected,
  });
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 36,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: ['All', 'Available', 'Occupied', 'Reserved', 'A', 'B', 'C']
          .map(
            (value) => Padding(
              padding: const EdgeInsets.only(right: 7),
              child: ChoiceChip(
                label: Text(value.length == 1 ? '$value Row' : value),
                selected: selected == value,
                onSelected: (_) => onSelected(value),
              ),
            ),
          )
          .toList(),
    ),
  );
}
