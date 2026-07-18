import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../students/controllers/students_controller.dart';
import '../controllers/seats_controller.dart';
import '../models/seat.dart';
import '../widgets/seat_bottom_sheet.dart';
import '../widgets/seat_filter.dart';
import '../widgets/seat_grid.dart';
import '../widgets/seat_summary.dart';

class SeatManagementScreen extends ConsumerStatefulWidget {
  const SeatManagementScreen({super.key});
  @override
  ConsumerState<SeatManagementScreen> createState() => _State();
}

class _State extends ConsumerState<SeatManagementScreen> {
  String filter = 'All', query = '';
  bool grid = true;
  @override
  Widget build(BuildContext context) {
    final all = ref.watch(seatsProvider),
        students = ref.watch(studentsProvider);
    final seats = all.where((seat) {
      final student = students.where((s) => s.seat == seat.number).firstOrNull;
      final matches =
          filter == 'All' ||
          seat.status.name == filter.toLowerCase() ||
          filter.length == 1 && seat.number.startsWith(filter);
      return matches &&
          '${seat.number} ${student?.name ?? ''}'.toLowerCase().contains(
            query.toLowerCase(),
          );
    }).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
      children: [
        SeatSummary(seats: all),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: TextField(
                  onChanged: (value) => setState(() => query = value),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Color(0xFF8E94A5)),
                    hintText: 'Search seat or student',
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              height: 52,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFEEEFF4),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _View(
                    Icons.grid_view_outlined,
                    grid,
                    () => setState(() => grid = true),
                  ),
                  _View(
                    Icons.format_list_bulleted,
                    !grid,
                    () => setState(() => grid = false),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SeatFilter(
          selected: filter,
          onSelected: (value) => setState(() => filter = value),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE4E7EF)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FLOOR PLAN',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.6,
                          color: Color(0xFF9095A6),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        'All seats',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${seats.length} results',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFF999EAC),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SeatGrid(seats: seats, students: students, onSeatTap: _openSeat),
            ],
          ),
        ),
      ],
    );
  }

  void _openSeat(Seat seat) => showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => SeatBottomSheet(seat: seat),
  );
}

class _View extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback tap;
  const _View(this.icon, this.selected, this.tap);
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: tap,
    borderRadius: BorderRadius.circular(11),
    child: Container(
      width: 42,
      height: 44,
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        boxShadow: selected
            ? const [BoxShadow(color: Color(0x12262B44), blurRadius: 12)]
            : null,
      ),
      child: Icon(
        icon,
        color: selected ? const Color(0xFF5145EA) : const Color(0xFF969BAB),
        size: 20,
      ),
    ),
  );
}
