import 'package:flutter/material.dart';
import '../../seats/models/seat.dart';
import '../../students/models/student.dart';

class AdmissionSeatSelector extends StatelessWidget {
  final SeatCategory category;
  final MembershipType membership;
  final List<Seat> seats;
  final String? selected;
  final String? selectedShift;
  final ValueChanged<String> onSelected;
  final String studentName;

  const AdmissionSeatSelector({
    super.key,
    required this.category,
    required this.membership,
    required this.seats,
    required this.selected,
    this.selectedShift,
    required this.onSelected,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (membership == MembershipType.halfTime) {
      return Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(color: colors.outline),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            const _IconBox(icon: Icons.access_time_rounded, size: 52),
            const SizedBox(height: 14),
            Text(
              'Flexible Seating (${category.label})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 5),
            Text(
              selectedShift != null
                  ? 'Assigned Shift: $selectedShift'
                  : 'No permanent seat required.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    selectedShift != null ? FontWeight.w700 : FontWeight.w500,
                color:
                    selectedShift != null
                        ? colors.primary
                        : colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final categorySeats =
        seats.where((s) => s.category == category).toList();
    final displaySeats = categorySeats.isNotEmpty ? categorySeats : seats;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outline),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : const Color(0x0A20243B),
            blurRadius: 28,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                category == SeatCategory.ac
                    ? Icons.ac_unit_rounded
                    : Icons.air_rounded,
                size: 18,
                color: colors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Select ${category.label} Seat',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${displaySeats.where((s) => s.status == SeatStatus.available).length} Available',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displaySeats.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 9,
              mainAxisSpacing: 9,
              childAspectRatio: 1.12,
            ),
            itemBuilder: (_, index) {
              final seat = displaySeats[index];
              final available = seat.status == SeatStatus.available;
              final isSelected = selected == seat.seatLabel;
              return _Seat(
                seat: seat,
                enabled: available,
                selected: isSelected,
                isDark: isDark,
                onTap: available ? () => onSelected(seat.seatLabel) : null,
              );
            },
          ),
          if (selected != null) ...[
            const SizedBox(height: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? colors.primaryContainer.withValues(alpha: 0.35)
                    : const Color(0xFFF3F2FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const _IconBox(icon: Icons.person_outline, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      studentName.isEmpty ? 'Student' : studentName,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(
                    'Selected: $selected (${category.shortLabel})',
                    style: TextStyle(
                      color: colors.primary,
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
}

class _Seat extends StatelessWidget {
  final Seat seat;
  final bool enabled, selected, isDark;
  final VoidCallback? onTap;

  const _Seat({
    required this.seat,
    required this.enabled,
    required this.selected,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final bg = selected
        ? colors.primary
        : enabled
        ? (isDark ? const Color(0xFF1E3A2F) : const Color(0xFFCDEBDE))
        : (isDark ? const Color(0xFF2A2E3B) : const Color(0xFFD6D8DE));

    final border = selected
        ? colors.primary
        : enabled
        ? (isDark ? const Color(0xFF2D5E4A) : const Color(0xFF72B79B))
        : (isDark ? const Color(0xFF3B4052) : const Color(0xFFB6BAC4));

    final text = selected
        ? colors.onPrimary
        : enabled
        ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF155E46))
        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF686D78));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 210),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: border, width: selected ? 1.5 : 1),
          ),
          child: Center(
            child: Text(
              seat.seatLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final double size;

  const _IconBox({required this.icon, this.size = 52});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
            : const Color(0xFFEAE8FF),
        borderRadius: BorderRadius.circular(size * .3),
      ),
      child: Icon(icon, color: theme.colorScheme.primary, size: size * .48),
    );
  }
}
