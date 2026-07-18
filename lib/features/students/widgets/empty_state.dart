import 'package:flutter/material.dart';
import '../../../core/settings/app_settings.dart';

class StudentsEmptyState extends StatelessWidget {
  const StudentsEmptyState({super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(60),
    child: Column(
      children: [
        Icon(
          Icons.people_outline,
          size: 54,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 12),
        Text(
          context.tr('No Students Found'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        Text(
          context.tr('Try another search or add a new admission.'),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    ),
  );
}
