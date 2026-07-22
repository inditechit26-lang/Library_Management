import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../students/controllers/students_controller.dart';
import '../../students/models/student.dart';
import '../controllers/seats_controller.dart';
import '../models/seat.dart';

class AssignStudentSheet extends ConsumerStatefulWidget {
  final Seat seat;
  const AssignStudentSheet({super.key, required this.seat});
  @override
  ConsumerState<AssignStudentSheet> createState() => _State();
}

class _State extends ConsumerState<AssignStudentSheet> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final occupied = ref
        .watch(seatsProvider)
        .where((e) => e.status == SeatStatus.occupied)
        .map((e) => e.studentId)
        .toSet();
    final students = ref
        .watch(studentsProvider)
        .where(
          (s) =>
              !occupied.contains(s.id) &&
              '${s.name} ${s.phone}'.toLowerCase().contains(
                query.toLowerCase(),
              ),
        )
        .toList();
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD9DCE5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assign ${widget.seat.seatLabel}',
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Text(
                        'Select a student without a reserved seat',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF858B9D),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (v) => setState(() => query = v),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search student or mobile',
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: students.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(30),
                      child: Text('No eligible students found'),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: students.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final student = students[i];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 4,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFE9E7FA),
                            child: Text(
                              student.initials,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          title: Text(
                            student.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(student.phone),
                          trailing: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 19,
                          ),
                          onTap: () => _assign(student),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _assign(Student student) {
    final old = student.seatId;
    ref
        .read(seatsProvider.notifier)
        .assign(widget.seat.seatId, student.id, previousSeatId: old);
    ref
        .read(studentsProvider.notifier)
        .update(
          student.copyWith(
            seat: widget.seat.seatLabel,
            seatId: widget.seat.seatId,
            membership: MembershipType.fullTime,
          ),
        );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${student.name} assigned to ${widget.seat.seatLabel}'),
      ),
    );
  }
}
