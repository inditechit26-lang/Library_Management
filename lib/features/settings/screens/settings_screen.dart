import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(14, 0, 14, 28),
    children: [
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE4E7EF)),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Field('Library name', 'The Study Room'),
            const _Field('Owner name', 'Om Chandrawanshi'),
            const _Field('Phone number', '+91 98765 43210'),
            const _Field('Total seats', '128'),
            const _Field('Default monthly fee', '1800', prefix: '₹'),
            const Divider(height: 28),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: const Text('Save changes'),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      const _Backup(),
      const SizedBox(height: 12),
      const _About(),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: () => context.go('/login'),
        icon: const Icon(Icons.logout),
        label: const Text('Log out'),
      ),
    ],
  );
}

class _Field extends StatelessWidget {
  final String label, value, prefix;
  const _Field(this.label, this.value, {this.prefix = ''});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFF565B6D),
          ),
        ),
        const SizedBox(height: 9),
        TextFormField(
          initialValue: value,
          decoration: InputDecoration(
            prefixText: prefix.isEmpty ? null : '$prefix  ',
            filled: true,
            fillColor: const Color(0xFFFAFBFD),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
          ),
        ),
      ],
    ),
  );
}

class _Backup extends StatelessWidget {
  const _Backup();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE4E7EF)),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F7F0),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.download_outlined, color: Color(0xFF23936B)),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Backup & restore',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 4),
              Text(
                'Keep a safe local copy of all your library data.',
                style: TextStyle(fontSize: 10, color: Color(0xFF969BAB)),
              ),
              SizedBox(height: 10),
              Text(
                'Last backup: 15 July 2026, 09:42 AM',
                style: TextStyle(fontSize: 9, color: Color(0xFFA2A6B3)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _About extends StatelessWidget {
  const _About();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE4E7EF)),
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Row(
      children: [
        Icon(Icons.info_outline, color: Color(0xFF7056B8)),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About StudyDesk',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                'Version 1.0.0 · Built for focused library owners',
                style: TextStyle(fontSize: 9, color: Color(0xFF999EAC)),
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: Color(0xFF9A9EAC)),
      ],
    ),
  );
}
