import 'package:flutter/material.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'SHORTCUTS',
        style: TextStyle(
          fontSize: 10,
          letterSpacing: 2,
          color: Color(0xFF9095A6),
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'Quick actions',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 16),
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.6,
        children: const [
          _Action(
            Icons.person_add_alt_1_outlined,
            'Add student',
            Color(0xFFECEBFF),
            Color(0xFF5145EA),
          ),
          _Action(
            Icons.grid_view_outlined,
            'Assign seat',
            Color(0xFFE8F7F0),
            Color(0xFF23936B),
          ),
          _Action(
            Icons.currency_rupee,
            'Mark fee paid',
            Color(0xFFFFF1E2),
            Color(0xFFD9832A),
          ),
          _Action(
            Icons.insert_chart_outlined,
            'Generate report',
            Color(0xFFF3ECFF),
            Color(0xFF8553C6),
          ),
        ],
      ),
    ],
  );
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg, color;
  const _Action(this.icon, this.label, this.bg, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE5E7EF)),
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A20243B),
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: color, size: 21),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}
