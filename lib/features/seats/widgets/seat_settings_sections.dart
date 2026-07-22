import 'package:flutter/material.dart';
import '../services/seat_configuration_service.dart';
import '../models/seat.dart';

class LibrarySeatStats extends StatelessWidget {
  final List<Seat> seats;
  const LibrarySeatStats({super.key, required this.seats});
  @override
  Widget build(BuildContext context) {
    final stats = [
      ('Total', seats.length, Icons.event_seat_outlined),
      (
        'Occupied',
        seats.where((s) => s.status == SeatStatus.occupied).length,
        Icons.person_outline,
      ),
      (
        'Available',
        seats.where((s) => s.status == SeatStatus.available).length,
        Icons.check_circle_outline,
      ),
      (
        'Blocked',
        seats.where((s) => s.status == SeatStatus.blocked).length,
        Icons.lock_outline,
      ),
      (
        'Maintenance',
        seats.where((s) => s.status == SeatStatus.maintenance).length,
        Icons.build_outlined,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < 520
            ? (constraints.maxWidth - 8) / 2
            : (constraints.maxWidth - 16) / 3;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in stats)
              SizedBox(
                width: width,
                child: Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        item.$3,
                        size: 17,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${item.$2}',
                        style: const TextStyle(
                          fontSize: 23,
                          height: 1,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.$1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

Future<SeatFileFormat?> showSeatExportFormatSheet(BuildContext context) =>
    showModalBottomSheet<SeatFileFormat>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Export format',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              for (final format in SeatFileFormat.values)
                ListTile(
                  leading: Icon(
                    format == SeatFileFormat.excel
                        ? Icons.table_chart_outlined
                        : format == SeatFileFormat.csv
                        ? Icons.grid_on_outlined
                        : Icons.data_object_rounded,
                  ),
                  title: Text(format.name.toUpperCase()),
                  onTap: () => Navigator.pop(sheet, format),
                ),
            ],
          ),
        ),
      ),
    );

class SeatSettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const SeatSettingsSection({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(22),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0920243B),
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 9),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    ),
  );
}

class SeatDangerZone extends StatelessWidget {
  final VoidCallback onReset, onDelete, onGenerate;
  const SeatDangerZone({
    super.key,
    required this.onReset,
    required this.onDelete,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.errorContainer.withAlpha(70),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            const Text(
              'Danger Zone',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton(
              onPressed: onReset,
              child: const Text('Reset All Seats'),
            ),
            OutlinedButton(
              onPressed: onGenerate,
              child: const Text('Generate Again'),
            ),
            FilledButton(
              onPressed: onDelete,
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete All Seats'),
            ),
          ],
        ),
      ],
    ),
  );
}
