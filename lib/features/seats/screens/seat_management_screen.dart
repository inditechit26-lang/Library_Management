import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../students/controllers/students_controller.dart';
import '../../students/models/student.dart';
import '../controllers/seats_controller.dart';
import '../models/seat.dart';
import '../widgets/available_seat_sheet.dart';
import '../widgets/seat_filter_bar.dart';
import '../widgets/seat_map.dart';
import '../widgets/seat_status_legend.dart';
import '../widgets/seat_summary_cards.dart';
import '../../settings/controllers/library_configuration_controller.dart';

class SeatManagementScreen extends ConsumerStatefulWidget {
  const SeatManagementScreen({super.key});
  @override
  ConsumerState<SeatManagementScreen> createState() => _SeatManagementState();
}

class _SeatManagementState extends ConsumerState<SeatManagementScreen> {
  final searchController = TextEditingController();
  final searchFocus = FocusNode();
  String filter = 'All', query = '';
  String? selectedSectionId;
  bool showSearch = false;

  @override
  void dispose() {
    searchController.dispose();
    searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(seatsProvider);
    final students = ref.watch(studentsProvider);
    final configuration = ref.watch(libraryConfigurationProvider);
    final visible = all.where((s) => _matches(s, students)).toList();
    return ListView(
      padding: EdgeInsets.fromLTRB(
        MediaQuery.sizeOf(context).width > 900 ? 28 : 16,
        18,
        MediaQuery.sizeOf(context).width > 900 ? 28 : 16,
        36,
      ),
      children: [
        TextField(
          controller: searchController,
          focusNode: searchFocus,
          onChanged: (value) => setState(() => query = value),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search_rounded),
            hintText: 'Search seat, student or mobile number',
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      searchController.clear();
                      setState(() => query = '');
                    },
                  ),
          ),
        ),
        const SizedBox(height: 14),
        SeatSummaryCards(seats: all, students: students),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Smart Seat Map',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Tap any seat to view details or assign a student',
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${visible.length} seats',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 6),
            IconButton.filledTonal(
              tooltip: 'Add Seat',
              onPressed: () {
                final label = configuration.nextSeatLabel(
                  all.map((seat) => seat.seatLabel),
                );
                ref.read(seatsProvider.notifier).add(label, sectionId: selectedSectionId);
              },
              icon: const Icon(Icons.add_rounded, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (configuration.enabledSections.isNotEmpty) ...[
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ChoiceChip(
                  label: Text('All Sections (${all.length})'),
                  selected: selectedSectionId == null,
                  onSelected: (_) => setState(() => selectedSectionId = null),
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: selectedSectionId == null
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                ...configuration.enabledSections.map((section) {
                  final active = selectedSectionId == section.id;
                  final count = all.where((s) {
                    final st = _student(s, students);
                    return (s.sectionId != null && s.sectionId == section.id) ||
                        (st?.sectionId != null && st?.sectionId == section.id) ||
                        (s.sectionId == null && st?.sectionId == null && section.id == configuration.enabledSections.first.id);
                  }).length;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      avatar: CircleAvatar(
                        radius: 5,
                        backgroundColor: section.color,
                      ),
                      label: Text('${section.name} ($count)'),
                      selected: active,
                      onSelected: (_) => setState(() => selectedSectionId = section.id),
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: active
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        SeatFilterBar(
          selected: filter,
          onSelected: (value) => setState(() => filter = value),
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: SeatMap(
            key: ValueKey('$selectedSectionId-$filter-$query-${visible.length}'),
            seats: visible,
            students: students,
            onTap: _open,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const SeatStatusLegend(),
        ),
      ],
    );
  }

  bool _matches(Seat seat, List<Student> students) {
    final student = _student(seat, students);
    final q = query.trim().toLowerCase();

    final searched = q.isEmpty ||
        '${seat.seatLabel} ${student?.name ?? ''} ${student?.phone ?? ''}'
            .toLowerCase()
            .contains(q);

    final filtered = switch (filter) {
      'Available' => seat.status == SeatStatus.available,
      'Occupied' => seat.status == SeatStatus.occupied,
      'Pending' => student != null && student.payment != PaymentStatus.paid,
      _ => true,
    };

    if (selectedSectionId == null) return searched && filtered;

    final seatSec = seat.sectionId;
    final studentSec = student?.sectionId;

    final sectionMatch = (seatSec != null && seatSec == selectedSectionId) ||
        (studentSec != null && studentSec == selectedSectionId) ||
        (seatSec == null && studentSec == null);

    return searched && filtered && sectionMatch;
  }

  Student? _student(Seat seat, List<Student> students) {
    for (final s in students) {
      if (s.id == seat.studentId) return s;
    }
    return null;
  }

  void _open(Seat seat) {
    if (seat.status == SeatStatus.occupied) {
      context.push('/seats/${seat.seatId}');
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AvailableSeatSheet(seat: seat),
    );
  }
}
