import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../students/controllers/students_controller.dart';
import '../../students/models/student.dart';
import '../controllers/seats_controller.dart';
import '../models/seat.dart';
import '../services/seat_configuration_service.dart';
import '../widgets/seat_admin_list.dart';
import '../widgets/seat_generator_panel.dart';
import '../widgets/seat_settings_sections.dart';

class SeatSettingsScreen extends ConsumerStatefulWidget {
  const SeatSettingsScreen({super.key});
  @override
  ConsumerState<SeatSettingsScreen> createState() => _SeatSettingsScreenState();
}

class _SeatSettingsScreenState extends ConsumerState<SeatSettingsScreen> {
  String query = '';
  final service = SeatConfigurationService();
  @override
  Widget build(BuildContext context) {
    final seats = ref.watch(seatsProvider),
        students = ref.watch(studentsProvider);
    final visible = seats
        .where(
          (seat) => '${seat.seatLabel} ${_student(seat, students)?.name ?? ''}'
              .toLowerCase()
              .contains(query.toLowerCase()),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seat Management'),
        actions: [
          IconButton(
            tooltip: 'Add seat',
            onPressed: _addSeat,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSeat,
        icon: const Icon(Icons.add),
        label: const Text('Add Seat'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
        children: [
          Text(
            'Configure seats',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Labels are flexible. Internal seat IDs and student assignments remain safe.',
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          SeatSettingsSection(
            title: 'Library Information',
            icon: Icons.analytics_outlined,
            child: LibrarySeatStats(seats: seats),
          ),
          const SizedBox(height: 14),
          SeatSettingsSection(
            title: 'Seat Generator',
            icon: Icons.auto_awesome_outlined,
            child: SeatGeneratorPanel(
              onNumeric: (total) => _confirmGenerate(
                () => ref.read(seatsProvider.notifier).generateNumeric(total),
              ),
              onAlphabetic: (rows, perRow) => _confirmGenerate(
                () => ref
                    .read(seatsProvider.notifier)
                    .generateAlphabetic(rows.clamp(1, 26), perRow),
              ),
              onCustom: _addSeat,
            ),
          ),
          const SizedBox(height: 14),
          SeatSettingsSection(
            title: 'Seat Labels',
            icon: Icons.label_outline_rounded,
            child: Column(
              children: [
                TextField(
                  onChanged: (value) => setState(() => query = value),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search label or assigned student',
                  ),
                ),
                const SizedBox(height: 12),
                SeatAdminList(
                  seats: visible,
                  students: students,
                  onEdit: _rename,
                  onDelete: _delete,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SeatSettingsSection(
            title: 'Import / Export',
            icon: Icons.import_export_rounded,
            child: Wrap(
              spacing: 9,
              runSpacing: 9,
              children: [
                OutlinedButton.icon(
                  onPressed: _import,
                  icon: const Icon(Icons.upload_file_outlined),
                  label: const Text('Import Configuration'),
                ),
                FilledButton.icon(
                  onPressed: _export,
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Export Configuration'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SeatDangerZone(
            onReset: () => _danger(
              'Reset all seat statuses?',
              'Assignments will be removed and every seat will become available.',
              ref.read(seatsProvider.notifier).resetStatuses,
            ),
            onDelete: () => _danger(
              'Delete all seats?',
              'This permanently removes the complete seat configuration.',
              ref.read(seatsProvider.notifier).deleteAll,
            ),
            onGenerate: () => _confirmGenerate(
              () => ref.read(seatsProvider.notifier).generateNumeric(100),
            ),
          ),
        ],
      ),
    );
  }

  Student? _student(Seat seat, List<Student> students) {
    for (final s in students) {
      if (s.id == seat.studentId) return s;
    }
    return null;
  }

  Future<String?> _labelDialog(String title, [String value = '']) async {
    var label = value;
    return showDialog<String>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(title),
        content: TextFormField(
          initialValue: value,
          autofocus: true,
          onChanged: (text) => label = text,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (text) {
            final clean = text.trim();
            if (clean.isNotEmpty) Navigator.pop(dialog, clean);
          },
          decoration: const InputDecoration(
            labelText: 'Seat label',
            hintText: 'VIP01, Reading01, L12…',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final clean = label.trim();
              if (clean.isNotEmpty) {
                Navigator.pop(dialog, clean);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _addSeat() async {
    final label = await _labelDialog('Add new seat');
    if (label != null) ref.read(seatsProvider.notifier).add(label);
  }

  Future<void> _rename(Seat seat) async {
    final label = await _labelDialog('Rename seat', seat.seatLabel);
    if (label == null) return;
    ref.read(seatsProvider.notifier).rename(seat.seatId, label);
    if (seat.studentId != null) {
      final student = ref
          .read(studentsProvider)
          .firstWhere((s) => s.id == seat.studentId);
      ref.read(studentsProvider.notifier).update(student.copyWith(seat: label));
    }
  }

  Future<void> _delete(Seat seat) async {
    final student = _student(seat, ref.read(studentsProvider));
    if (student != null) {
      await showDialog<void>(
        context: context,
        builder: (dialog) => AlertDialog(
          icon: const Icon(Icons.warning_amber_rounded),
          title: const Text('Seat is occupied'),
          content: Text(
            'This seat is currently assigned to ${student.name}.\n\nPlease reassign or remove the student before deleting.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialog),
              child: const Text('Understood'),
            ),
          ],
        ),
      );
      return;
    }
    final ok = await _confirm(
      'Delete ${seat.seatLabel}?',
      'This seat will be permanently removed.',
    );
    if (ok) ref.read(seatsProvider.notifier).delete(seat.seatId);
  }

  Future<void> _confirmGenerate(VoidCallback generate) async {
    final ok = await _confirm(
      'Replace seat configuration?',
      'This creates a fresh configuration and removes current seat assignments.',
    );
    if (ok) generate();
  }

  Future<bool> _confirm(String title, String message) async =>
      await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialog, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialog, true),
              child: const Text('Continue'),
            ),
          ],
        ),
      ) ??
      false;
  Future<void> _danger(
    String title,
    String message,
    VoidCallback action,
  ) async {
    if (await _confirm(title, message)) action();
  }

  Future<void> _export() async {
    try {
      final format = await showSeatExportFormatSheet(context);
      if (format == null) return;
      final path = await service.export(ref.read(seatsProvider), format);
      if (mounted && path != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Exported to $path')));
      }
    } catch (error) {
      if (mounted) _showError('Could not export seats. Please try again.');
    }
  }

  Future<void> _import() async {
    try {
      final labels = await service.import();
      if (labels == null || labels.isEmpty || !mounted) return;
      if (await _confirm(
        'Import ${labels.length} seats?',
        'The current configuration will be replaced.',
      )) {
        ref.read(seatsProvider.notifier).replaceAll(labels);
      }
    } catch (error) {
      if (mounted) {
        _showError(
          'This file could not be read. Choose a valid CSV, JSON or Excel file.',
        );
      }
    }
  }

  void _showError(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}
