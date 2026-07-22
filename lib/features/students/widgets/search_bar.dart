import 'package:flutter/material.dart';
import '../../../core/settings/app_settings.dart';

class StudentSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const StudentSearchBar({super.key, required this.onChanged});
  @override
  State<StudentSearchBar> createState() => _StudentSearchBarState();
}

class _StudentSearchBarState extends State<StudentSearchBar> {
  final focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    focusNode.addListener(_refresh);
  }

  void _refresh() => setState(() {});
  @override
  void dispose() {
    focusNode.removeListener(_refresh);
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    height: 56,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: focusNode.hasFocus
              ? const Color(0x145650C7)
              : const Color(0x0820243B),
          blurRadius: focusNode.hasFocus ? 22 : 14,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: TextField(
      focusNode: focusNode,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: context.tr('Search name, mobile or seat number'),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 5, right: 2),
          child: Icon(
            Icons.search_rounded,
            size: 21,
            color: focusNode.hasFocus
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 48),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    ),
  );
}
