import 'package:flutter/material.dart';
import '../../students/models/student.dart';

class PlanSelector extends StatelessWidget {
  final MembershipType value;
  final ValueChanged<MembershipType> onChanged;
  const PlanSelector({super.key, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => SegmentedButton<MembershipType>(
    segments: const [
      ButtonSegment(value: MembershipType.fullTime, label: Text('Full Time')),
      ButtonSegment(value: MembershipType.halfTime, label: Text('Half Time')),
    ],
    selected: {value},
    onSelectionChanged: (values) => onChanged(values.first),
  );
}
