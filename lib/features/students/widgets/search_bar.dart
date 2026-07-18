import 'package:flutter/material.dart';

class StudentSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const StudentSearchBar({super.key, required this.onChanged});
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 54,
    child: TextField(
      onChanged: onChanged,
      decoration: const InputDecoration(
        hintText: 'Search name, mobile or seat number',
        prefixIcon: Icon(Icons.search, color: Color(0xFF8F95A6)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        filled: true,
        fillColor: Colors.white,
      ),
    ),
  );
}
