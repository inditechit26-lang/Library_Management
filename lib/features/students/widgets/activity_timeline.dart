import 'package:flutter/material.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/widgets/premium_card.dart';

class ActivityTimeline extends StatelessWidget {
  const ActivityTimeline({super.key});
  @override
  Widget build(BuildContext context) => PremiumCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history, color: Color(0xFF514BC0)),
            const SizedBox(width: 9),
            Text(
              context.tr('Activity'),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...const [
          ('Membership Renewed', '05 Jul 2026 · 10:32 AM'),
          ('Payment Received', '05 Jul 2026 · 10:31 AM'),
          ('Seat Changed', '11 Apr 2026 · 09:15 AM'),
          ('Admission Created', '18 Jan 2026 · 08:42 AM'),
        ].map((event) => _Event(event.$1, event.$2)),
      ],
    ),
  );
}

class _Event extends StatelessWidget {
  final String title, date;
  const _Event(this.title, this.date);
  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: Color(0xFF6963C9),
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Container(width: 1, color: const Color(0xFFE4E4EA)),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
