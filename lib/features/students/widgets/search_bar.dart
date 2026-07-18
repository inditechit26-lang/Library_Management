import 'package:flutter/material.dart';
import '../../../core/settings/app_settings.dart';

class StudentSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const StudentSearchBar({super.key, required this.onChanged});
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 54,
    child: TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: context.tr('Search name, mobile or seat number'),
        prefixIcon: const Icon(Icons.search, color: Color(0xFF8F95A6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
    ),
  );
}
