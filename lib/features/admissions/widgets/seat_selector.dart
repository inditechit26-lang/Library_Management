import 'package:flutter/material.dart';
import '../../seats/models/seat.dart';
import '../../students/models/student.dart';
import '../../settings/models/library_configuration.dart';

class _SectionGroup {
  final LibrarySection? section;
  final List<Seat> seats;
  _SectionGroup({required this.section, required this.seats});
}

class AdmissionSeatSelector extends StatefulWidget {
  final SeatCategory category;
  final MembershipType membership;
  final List<LibrarySection> sections;
  final String? selectedSectionId;
  final List<Seat> seats;
  final List<Student> students;
  final String? selected;
  final String? selectedShift;
  final ValueChanged<String> onSelected;
  final String studentName;
  final bool requiresSeat;

  const AdmissionSeatSelector({
    super.key,
    required this.category,
    required this.membership,
    this.sections = const [],
    this.selectedSectionId,
    required this.seats,
    this.students = const [],
    required this.selected,
    this.selectedShift,
    required this.onSelected,
    required this.studentName,
    this.requiresSeat = true,
  });

  @override
  State<AdmissionSeatSelector> createState() => _AdmissionSeatSelectorState();
}

class _AdmissionSeatSelectorState extends State<AdmissionSeatSelector> {
  late String? activeSectionId;

  @override
  void initState() {
    super.initState();
    activeSectionId = widget.selectedSectionId;
  }

  Student? _studentFor(Seat seat) {
    for (final student in widget.students) {
      if (student.id == seat.studentId || (student.seat != null && student.seat == seat.seatLabel)) {
        return student;
      }
    }
    return null;
  }

  List<_SectionGroup> _buildGroups(List<Seat> displaySeats) {
    if (widget.sections.isEmpty) {
      return [_SectionGroup(section: null, seats: displaySeats)];
    }

    final groups = <_SectionGroup>[];
    final processedSeatIds = <String>{};

    for (final section in widget.sections) {
      if (activeSectionId != null && activeSectionId != section.id) continue;

      final sectionSeats = displaySeats.where((s) {
        if (s.sectionId != null) return s.sectionId == section.id;
        final st = _studentFor(s);
        if (st?.sectionId != null) return st!.sectionId == section.id;
        return widget.sections.first.id == section.id;
      }).toList();

      if (sectionSeats.isNotEmpty) {
        processedSeatIds.addAll(sectionSeats.map((s) => s.seatId));
        groups.add(_SectionGroup(section: section, seats: sectionSeats));
      }
    }

    final unassigned = displaySeats.where((s) => !processedSeatIds.contains(s.seatId)).toList();
    if (unassigned.isNotEmpty) {
      groups.add(_SectionGroup(section: null, seats: unassigned));
    }

    return groups.isEmpty ? [_SectionGroup(section: null, seats: displaySeats)] : groups;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (!widget.requiresSeat) {
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
              'Flexible Seating (${widget.category.label})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 5),
            Text(
              widget.selectedShift != null
                  ? 'Assigned Shift: ${widget.selectedShift}'
                  : 'No permanent seat required.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: widget.selectedShift != null
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: widget.selectedShift != null
                    ? colors.primary
                    : colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final sectionFiltered = widget.seats.where((seat) {
      if (activeSectionId == null) return true;
      return seat.sectionId == activeSectionId;
    }).toList();

    final categorySeats = sectionFiltered.where((s) => s.category == widget.category).toList();
    final displaySeats = categorySeats.isNotEmpty ? categorySeats : sectionFiltered;
    final sectionGroups = _buildGroups(displaySeats);

    final availableCount = displaySeats.where((s) => s.status == SeatStatus.available).length;
    final boysCount = displaySeats.where((s) {
      final st = _studentFor(s);
      return s.status == SeatStatus.occupied && (st == null || st.gender.toLowerCase() != 'female');
    }).length;
    final girlsCount = displaySeats.where((s) {
      final st = _studentFor(s);
      return s.status == SeatStatus.occupied && st != null && st.gender.toLowerCase() == 'female';
    }).length;

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
                widget.category == SeatCategory.ac
                    ? Icons.ac_unit_rounded
                    : Icons.air_rounded,
                size: 18,
                color: colors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Select ${widget.category.label} Seat',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$availableCount Available',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Status Legend Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2235) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _LegendItem('Free', const Color(0xFF10B981)),
                _LegendItem('Boys ($boysCount)', const Color(0xFF2563EB)),
                _LegendItem('Girls ($girlsCount)', const Color(0xFFDB2777)),
                _LegendItem('Selected', colors.primary),
              ],
            ),
          ),

          if (widget.sections.isNotEmpty) ...[
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All Sections'),
                    selected: activeSectionId == null,
                    onSelected: (_) => setState(() => activeSectionId = null),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: activeSectionId == null
                          ? colors.onPrimary
                          : colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  for (final section in widget.sections) ...[
                    ChoiceChip(
                      avatar: CircleAvatar(
                        radius: 5,
                        backgroundColor: section.color,
                      ),
                      label: Text(section.name),
                      selected: activeSectionId == section.id,
                      onSelected: (_) => setState(() => activeSectionId = section.id),
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: activeSectionId == section.id
                            ? colors.onPrimary
                            : colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Render Section-Wise Seat Groups
          Column(
            children: sectionGroups.map((group) {
              final section = group.section;
              final sectionSeats = group.seats;
              final freeInSec = sectionSeats.where((s) => s.status == SeatStatus.available).length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Name Heading Card
                  Container(
                    margin: const EdgeInsets.only(bottom: 10, top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? (section?.color.withOpacity(0.14) ?? const Color(0xFF2E354C).withOpacity(0.5))
                          : (section?.color.withOpacity(0.08) ?? const Color(0xFFF8FAFC)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: section?.color.withOpacity(0.35) ?? (isDark ? const Color(0xFF2E354C) : const Color(0xFFE2E8F0)),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: section?.color ?? colors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (section?.color ?? colors.primary).withOpacity(0.5),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          section?.name ?? 'General Room',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: (section?.color ?? colors.primary).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${sectionSeats.length} seats • $freeInSec free',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: section?.color ?? colors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Section Grid View
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sectionSeats.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.05,
                    ),
                    itemBuilder: (_, index) {
                      final seat = sectionSeats[index];
                      final available = seat.status == SeatStatus.available;
                      final isSelected = widget.selected == seat.seatLabel;
                      final student = _studentFor(seat);

                      return _Seat(
                        seat: seat,
                        student: student,
                        sectionColor: section?.color,
                        enabled: available,
                        selected: isSelected,
                        isDark: isDark,
                        onTap: available ? () => widget.onSelected(seat.seatLabel) : null,
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                ],
              );
            }).toList(),
          ),

          if (widget.selected != null) ...[
            const SizedBox(height: 8),
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
                      widget.studentName.isEmpty ? 'Student' : widget.studentName,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(
                    'Selected: ${widget.selected} (${widget.category.shortLabel})',
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

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;
  const _LegendItem(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Seat extends StatelessWidget {
  final Seat seat;
  final Student? student;
  final Color? sectionColor;
  final bool enabled, selected, isDark;
  final VoidCallback? onTap;

  const _Seat({
    required this.seat,
    this.student,
    this.sectionColor,
    required this.enabled,
    required this.selected,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isOccupied = seat.status == SeatStatus.occupied || student != null;
    final isFemale = student?.gender.toLowerCase() == 'female';

    final Color bg;
    final Color border;
    final Color text;
    Widget? genderBadge;

    if (selected) {
      bg = colors.primary;
      border = colors.primary;
      text = colors.onPrimary;
    } else if (isOccupied) {
      if (isFemale) {
        // Soft Light Pink for Girls
        bg = isDark ? const Color(0xFF2E1A24) : const Color(0xFFFDF2F8);
        border = isDark ? const Color(0xFF5B2138) : const Color(0xFFFBCFE8);
        text = const Color(0xFFDB2777);
        genderBadge = const Icon(Icons.female_rounded, size: 10, color: Color(0xFFDB2777));
      } else {
        // Soft Light Blue for Boys
        bg = isDark ? const Color(0xFF1B2436) : const Color(0xFFEFF6FF);
        border = isDark ? const Color(0xFF233554) : const Color(0xFFBFDBFE);
        text = const Color(0xFF2563EB);
        genderBadge = const Icon(Icons.male_rounded, size: 10, color: Color(0xFF2563EB));
      }
    } else if (enabled) {
      final secCol = sectionColor ?? const Color(0xFF10B981);
      bg = isDark ? Color.alphaBlend(secCol.withOpacity(0.14), const Color(0xFF121824)) : Color.alphaBlend(secCol.withOpacity(0.1), Colors.white);
      border = secCol.withOpacity(0.4);
      text = isDark ? secCol : Color.alphaBlend(secCol, Colors.black87);
    } else {
      bg = isDark ? const Color(0xFF2A2E3B) : const Color(0xFFD6D8DE);
      border = isDark ? const Color(0xFF3B4052) : const Color(0xFFB6BAC4);
      text = isDark ? const Color(0xFF94A3B8) : const Color(0xFF686D78);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 210),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: selected ? 2.0 : 1.2),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: colors.primary.withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 1,
                    )
                  ]
                : [],
          ),
          child: Stack(
            children: [
              if (selected)
                const Positioned(
                  top: 3,
                  right: 3,
                  child: Icon(Icons.check_circle_rounded, size: 10, color: Colors.white),
                )
              else if (genderBadge != null)
                Positioned(
                  top: 3,
                  right: 3,
                  child: genderBadge,
                ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      seat.seatLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: text,
                      ),
                    ),
                    if (isOccupied && student != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          student!.name.split(' ').first,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w700,
                            color: text.withOpacity(0.85),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
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

