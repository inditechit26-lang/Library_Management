import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../../students/models/student.dart';

class ReceiptTile extends StatelessWidget {
  final Student student;
  final VoidCallback onTap;
  const ReceiptTile({super.key, required this.student, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(color: Color(0xFFE8E9EF)),
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.all(12),
      leading: CircleAvatar(child: Text(student.initials)),
      title: Text(
        student.name,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text('SR-2026-${student.id.toString().padLeft(4, '0')} · UPI'),
      trailing: Text(
        money(student.fee),
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      onTap: onTap,
    ),
  );
}
