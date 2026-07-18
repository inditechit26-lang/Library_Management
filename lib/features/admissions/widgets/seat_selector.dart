import 'package:flutter/material.dart';
import '../../seats/models/seat.dart';
import '../../students/models/student.dart';

class AdmissionSeatSelector extends StatelessWidget {
  final MembershipType membership;
  final List<Seat> seats;
  final String? selected;
  final ValueChanged<String> onSelected;
  final String studentName;
  const AdmissionSeatSelector({
    super.key,
    required this.membership,
    required this.seats,
    required this.selected,
    required this.onSelected,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context) {
    if (membership == MembershipType.halfTime) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: _cardDecoration,
        child: const Column(
          children: [
            _IconBox(icon: Icons.event_seat_outlined),
            SizedBox(height: 14),
            Text(
              'Flexible Seating',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 5),
            Text(
              'No permanent seat required.',
              style: TextStyle(fontSize: 11, color: Color(0xFF8F95A6)),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration,
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: seats.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 9,
              mainAxisSpacing: 9,
              childAspectRatio: 1.12,
            ),
            itemBuilder: (_, index) {
              final seat = seats[index];
              final available = seat.status == SeatStatus.available;
              final isSelected = selected == seat.number;
              return _Seat(
                seat: seat,
                enabled: available,
                selected: isSelected,
                onTap: available ? () => onSelected(seat.number) : null,
              );
            },
          ),
          if (selected != null) ...[
            const SizedBox(height: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F2FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const _IconBox(icon: Icons.person_outline, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      studentName,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(
                    selected!,
                    style: const TextStyle(
                      color: Color(0xFF5650C7),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static final _cardDecoration = BoxDecoration(
    color: Colors.white,
    border: Border.all(color: const Color(0xFFE5E7EF)),
    borderRadius: BorderRadius.circular(22),
    boxShadow: const [
      BoxShadow(color: Color(0x0A20243B), blurRadius: 28, offset: Offset(0, 9)),
    ],
  );
}

class _Seat extends StatelessWidget {
  final Seat seat;
  final bool enabled, selected;
  final VoidCallback? onTap;
  const _Seat({
    required this.seat,
    required this.enabled,
    required this.selected,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 210),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF5650C7)
              : enabled
              ? const Color(0xFFEAF7F1)
              : const Color(0xFFF0F1F5),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected ? const Color(0xFF5650C7) : const Color(0xFFE3E5EC),
          ),
        ),
        child: Center(
          child: Text(
            seat.number,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: selected
                  ? Colors.white
                  : enabled
                  ? const Color(0xFF267D61)
                  : const Color(0xFFA5A9B5),
            ),
          ),
        ),
      ),
    ),
  );
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final double size;
  const _IconBox({required this.icon, this.size = 52});
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: const Color(0xFFEAE8FF),
      borderRadius: BorderRadius.circular(size * .3),
    ),
    child: Icon(icon, color: const Color(0xFF5650C7), size: size * .48),
  );
}
