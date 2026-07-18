import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../../students/models/student.dart';

class MembershipSelector extends StatelessWidget {
  final MembershipType selected;
  final double fullTimeMonthly, halfTimeMonthly;
  final ValueChanged<MembershipType> onChanged;
  const MembershipSelector({
    super.key,
    required this.selected,
    required this.fullTimeMonthly,
    required this.halfTimeMonthly,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _PlanCard(
        title: 'FULL TIME',
        subtitle: 'Reserved Seat',
        fee: money(fullTimeMonthly),
        icon: Icons.workspace_premium_outlined,
        benefits: const [
          'Reserved Seat',
          'Unlimited Access',
          'Priority Seating',
        ],
        selected: selected == MembershipType.fullTime,
        onTap: () => onChanged(MembershipType.fullTime),
      ),
      const SizedBox(height: 14),
      _PlanCard(
        title: 'HALF TIME',
        subtitle: 'Flexible Seating',
        fee: money(halfTimeMonthly),
        icon: Icons.schedule_outlined,
        benefits: const ['Affordable', 'Flexible Seating', 'Shared Seats'],
        selected: selected == MembershipType.halfTime,
        onTap: () => onChanged(MembershipType.halfTime),
      ),
    ],
  );
}

class _PlanCard extends StatelessWidget {
  final String title, subtitle, fee;
  final IconData icon;
  final List<String> benefits;
  final bool selected;
  final VoidCallback onTap;
  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.fee,
    required this.icon,
    required this.benefits,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => AnimatedScale(
    scale: selected ? 1 : .985,
    duration: const Duration(milliseconds: 220),
    curve: Curves.easeOutCubic,
    child: Material(
      color: selected ? const Color(0xFFF5F4FF) : Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected
                  ? const Color(0xFF7069DC)
                  : const Color(0xFFE5E7EF),
              width: selected ? 1.5 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A20243B),
                blurRadius: 26,
                offset: Offset(0, 9),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFE7E5FF)
                      : const Color(0xFFF3F4F8),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: const Color(0xFF5650C7)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .7,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF858B9D),
                      ),
                    ),
                    const SizedBox(height: 13),
                    Wrap(
                      spacing: 6,
                      runSpacing: 7,
                      children: benefits.map((item) => _Benefit(item)).toList(),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: selected
                        ? const Icon(
                            Icons.check_circle,
                            key: ValueKey(true),
                            color: Color(0xFF5650C7),
                            size: 22,
                          )
                        : const Icon(
                            Icons.circle_outlined,
                            key: ValueKey(false),
                            color: Color(0xFFB7BBC7),
                            size: 22,
                          ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    fee,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Benefit extends StatelessWidget {
  final String label;
  const _Benefit(this.label);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .8),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: const Color(0xFFE9EAF1)),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 8,
        fontWeight: FontWeight.w700,
        color: Color(0xFF676C7E),
      ),
    ),
  );
}
