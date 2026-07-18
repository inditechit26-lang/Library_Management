import 'package:flutter/material.dart';

class StudentsEmptyState extends StatelessWidget {
  const StudentsEmptyState({super.key});
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(60),
    child: Column(
      children: [
        Icon(Icons.people_outline, size: 54, color: Colors.black26),
        SizedBox(height: 12),
        Text(
          'No Students Found',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        Text(
          'Try another search or add a new admission.',
          style: TextStyle(color: Colors.black54, fontSize: 11),
        ),
      ],
    ),
  );
}
