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

class SeatManagementScreen extends ConsumerStatefulWidget {
  const SeatManagementScreen({super.key});
  @override
  ConsumerState<SeatManagementScreen> createState() => _SeatManagementState();
}

class _SeatManagementState extends ConsumerState<SeatManagementScreen> {
  final searchController = TextEditingController();
  final searchFocus = FocusNode();
  String filter = 'All', query = '';
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
    final visible = all.where((s) => _matches(s, students)).toList();
    return ListView(
      padding: EdgeInsets.fromLTRB(
        MediaQuery.sizeOf(context).width > 900 ? 28 : 16,
        18,
        MediaQuery.sizeOf(context).width > 900 ? 28 : 16,
        36,
      ),
      children: [
        _Header(
          onSearch: () {
            setState(() => showSearch = !showSearch);
            if (showSearch) {
              Future.delayed(
                const Duration(milliseconds: 120),
                searchFocus.requestFocus,
              );
            }
          },
          onFilter: () => setState(() => showSearch = true),
          onSort: _sortSheet,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: showSearch
              ? Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: TextField(
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
                )
              : const SizedBox.shrink(),
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
          ],
        ),
        const SizedBox(height: 14),
        SeatFilterBar(
          selected: filter,
          onSelected: (value) => setState(() => filter = value),
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: SeatMap(
            key: ValueKey('$filter-$query-${visible.length}'),
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
    final student = _student(seat, students), q = query.trim().toLowerCase();
    final searched =
        q.isEmpty ||
        '${seat.seatLabel} ${student?.name ?? ''} ${student?.phone ?? ''}'
            .toLowerCase()
            .contains(q);
    final filtered = switch (filter) {
      'Available' => seat.status == SeatStatus.available,
      'Occupied' => seat.status == SeatStatus.occupied,
      'Pending' => student != null && student.payment != PaymentStatus.paid,
      _ => true,
    };
    return searched && filtered;
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

  void _sortSheet() => showModalBottomSheet(
    context: context,
    builder: (sheet) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sort seats', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            for (final item in [
              ('Seat number', Icons.sort_by_alpha_rounded),
              ('Availability', Icons.check_circle_outline),
              ('Payment attention', Icons.payments_outlined),
            ])
              ListTile(
                leading: Icon(item.$2),
                title: Text(item.$1),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pop(sheet),
              ),
          ],
        ),
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  final VoidCallback onSearch, onFilter, onSort;
  const _Header({
    required this.onSearch,
    required this.onFilter,
    required this.onSort,
  });
  @override
  Widget build(BuildContext context) => Row(
    children: [
      FilledButton.tonalIcon(
        onPressed: onSearch,
        icon: const Icon(Icons.search_rounded, size: 19),
        label: const Text('Search'),
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 46),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
      const Spacer(),
      _HeaderAction(Icons.tune_rounded, 'Filter', onFilter),
      _HeaderAction(Icons.swap_vert_rounded, 'Sort', onSort),
    ],
  );
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _HeaderAction(this.icon, this.tooltip, this.onTap);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 5),
    child: IconButton.filledTonal(
      tooltip: tooltip,
      onPressed: onTap,
      icon: Icon(icon, size: 19),
    ),
  );
}
