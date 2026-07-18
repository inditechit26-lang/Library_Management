import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../students/controllers/students_controller.dart';
import '../../students/models/student.dart';
import '../controllers/seat_view_controller.dart';
import '../controllers/seats_controller.dart';
import '../models/seat.dart';
import '../widgets/available_seat_sheet.dart';
import '../widgets/seat_card.dart';
import '../widgets/seat_filter_bar.dart';
import '../widgets/seat_map.dart';
import '../widgets/seat_status_legend.dart';
import '../widgets/seat_summary_cards.dart';

class SeatManagementScreen extends ConsumerStatefulWidget {
  const SeatManagementScreen({super.key});
  @override
  ConsumerState<SeatManagementScreen> createState() => _State();
}

class _State extends ConsumerState<SeatManagementScreen> {
  String filter = 'All', query = '';
  @override
  Widget build(BuildContext context) {
    final all = ref.watch(seatsProvider),
        students = ref.watch(studentsProvider),
        mode = ref.watch(seatViewProvider);
    final seats = all.where((seat) => _matches(seat, students)).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
      children: [
        _TitleBar(
          onSearch: () => FocusScope.of(context).requestFocus(),
          onMenu: () => _generateDialog(),
        ),
        const SizedBox(height: 18),
        SeatSummaryCards(seats: all, students: students),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (v) => setState(() => query = v),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: 'Search seat, student or mobile',
                ),
              ),
            ),
            const SizedBox(width: 10),
            _ViewSwitcher(
              mode: mode,
              onChanged: ref.read(seatViewProvider.notifier).select,
            ),
          ],
        ),
        const SizedBox(height: 13),
        SeatFilterBar(
          selected: filter,
          onSelected: (v) => setState(() => filter = v),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Floor overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              '${seats.length} seats',
              style: const TextStyle(fontSize: 10, color: Color(0xFF858B9D)),
            ),
          ],
        ),
        const SizedBox(height: 13),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          child: switch (mode) {
            SeatViewMode.floor => SeatMap(
              key: const ValueKey('floor'),
              seats: seats,
              students: students,
              onTap: _open,
              onLongPress: _quickActions,
            ),
            SeatViewMode.grid => _Grid(
              key: const ValueKey('grid'),
              seats: seats,
              students: students,
              onTap: _open,
              onLong: _quickActions,
            ),
            SeatViewMode.list => _List(
              key: const ValueKey('list'),
              seats: seats,
              students: students,
              onTap: _open,
            ),
          },
        ),
        const SizedBox(height: 18),
        const SeatStatusLegend(),
      ],
    );
  }

  bool _matches(Seat seat, List<Student> students) {
    final student = _student(seat, students);
    final q = query.toLowerCase();
    final search =
        '${seat.number} ${student?.name ?? ''} ${student?.phone ?? ''}'
            .toLowerCase()
            .contains(q);
    final match = switch (filter) {
      'All' => true,
      'Available' => seat.status == SeatStatus.available,
      'Occupied' => seat.status == SeatStatus.occupied,
      'Full Time' => student?.membership == MembershipType.fullTime,
      'Half Time' => student?.membership == MembershipType.halfTime,
      'Pending' => student?.payment != PaymentStatus.paid && student != null,
      _ => seat.row == filter,
    };
    return search && match;
  }

  Student? _student(Seat seat, List<Student> students) {
    for (final s in students) {
      if (s.seat == seat.number) return s;
    }
    return null;
  }

  void _open(Seat seat) {
    if (seat.status == SeatStatus.occupied) {
      context.push('/seats/${seat.number}');
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => AvailableSeatSheet(seat: seat),
      );
    }
  }

  void _quickActions(Seat seat) => showModalBottomSheet(
    context: context,
    builder: (_) => AvailableSeatSheet(seat: seat),
  );
  void _generateDialog() => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Generate seat layout'),
      content: const Text(
        'Create a fresh layout with 4 rows and 10 seats per row?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            ref.read(seatsProvider.notifier).generate(rows: 4, columns: 10);
            Navigator.pop(context);
          },
          child: const Text('Generate'),
        ),
      ],
    ),
  );
}

class _TitleBar extends StatelessWidget {
  final VoidCallback onSearch, onMenu;
  const _TitleBar({required this.onSearch, required this.onMenu});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seat Management',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Monitor & Manage Library Seating',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      IconButton(onPressed: onSearch, icon: const Icon(Icons.search)),
      IconButton(onPressed: () {}, icon: const Icon(Icons.tune)),
      PopupMenuButton(
        itemBuilder: (_) => [
          PopupMenuItem(onTap: onMenu, child: const Text('Generate seats')),
        ],
      ),
    ],
  );
}

class _ViewSwitcher extends StatelessWidget {
  final SeatViewMode mode;
  final ValueChanged<SeatViewMode> onChanged;
  const _ViewSwitcher({required this.mode, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: const Color(0xFFEEEFF4),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
      children: SeatViewMode.values
          .map(
            (m) => InkWell(
              onTap: () => onChanged(m),
              borderRadius: BorderRadius.circular(11),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 38,
                height: 44,
                decoration: BoxDecoration(
                  color: mode == m ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  switch (m) {
                    SeatViewMode.floor => Icons.map_outlined,
                    SeatViewMode.grid => Icons.grid_view_outlined,
                    SeatViewMode.list => Icons.format_list_bulleted,
                  },
                  size: 19,
                  color: mode == m
                      ? const Color(0xFF5650C7)
                      : const Color(0xFF9499A9),
                ),
              ),
            ),
          )
          .toList(),
    ),
  );
}

class _Grid extends StatelessWidget {
  final List<Seat> seats;
  final List<Student> students;
  final ValueChanged<Seat> onTap, onLong;
  const _Grid({
    super.key,
    required this.seats,
    required this.students,
    required this.onTap,
    required this.onLong,
  });
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, b) {
      final count = b.maxWidth > 700 ? 4 : 2;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: seats.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: count,
          childAspectRatio: 1.05,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (_, i) => SeatCard(
          seat: seats[i],
          student: _find(seats[i]),
          onTap: () => onTap(seats[i]),
          onLongPress: () => onLong(seats[i]),
        ),
      );
    },
  );
  Student? _find(Seat seat) {
    for (final s in students) {
      if (s.seat == seat.number) return s;
    }
    return null;
  }
}

class _List extends StatelessWidget {
  final List<Seat> seats;
  final List<Student> students;
  final ValueChanged<Seat> onTap;
  const _List({
    super.key,
    required this.seats,
    required this.students,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE5E7EF)),
    ),
    child: Column(
      children: seats.map((seat) {
        final student = _find(seat);
        return ListTile(
          onTap: () => onTap(seat),
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFF0EFFF),
            child: Text(
              seat.number,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
            ),
          ),
          title: Text(
            student?.name ?? seat.status.name,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(student?.phone ?? 'Seat ${seat.number}'),
          trailing: const Icon(Icons.chevron_right),
        );
      }).toList(),
    ),
  );
  Student? _find(Seat seat) {
    for (final s in students) {
      if (s.seat == seat.number) return s;
    }
    return null;
  }
}
