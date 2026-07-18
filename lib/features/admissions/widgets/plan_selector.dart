import 'package:flutter/material.dart';
import '../../../core/settings/app_settings.dart';
import '../../students/models/student.dart';

class PlanSelector extends StatelessWidget {
  final MembershipType value;
  final ValueChanged<MembershipType> onChanged;
  const PlanSelector({super.key, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => SegmentedButton<MembershipType>(
    segments: [
      ButtonSegment(
        value: MembershipType.fullTime,
        label: Text(context.tr('Full Time')),
      ),
      ButtonSegment(
        value: MembershipType.halfTime,
        label: Text(context.tr('Half Time')),
      ),
    ],
    selected: {value},
    onSelectionChanged: (values) => onChanged(values.first),
  );
}
