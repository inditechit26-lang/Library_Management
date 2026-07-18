import 'package:flutter/material.dart';

class DashboardSummaryCards extends StatelessWidget {
  final int studentCount;
  const DashboardSummaryCards({super.key, required this.studentCount});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      _SeatCard(studentCount: studentCount),
      const SizedBox(height: 12),
      const _FeeCard(),
    ],
  );
}

class _Base extends StatelessWidget {
  final Widget child;
  const _Base({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE5E7EF)),
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D20243B),
          blurRadius: 30,
          offset: Offset(0, 10),
        ),
      ],
    ),
    child: child,
  );
}

class _SeatCard extends StatelessWidget {
  final int studentCount;
  const _SeatCard({required this.studentCount});
  @override
  Widget build(BuildContext context) => _Base(
    child: Column(
      children: [
        const _Title(
          icon: Icons.grid_view_outlined,
          label: 'Seat occupancy',
          action: 'Manage',
        ),
        const SizedBox(height: 26),
        Row(
          children: [
            Expanded(
              child: _Metric(
                'TOTAL STUDENTS',
                '$studentCount',
                'Active members',
                const Color(0xFF5145EA),
              ),
            ),
            const _Line(),
            const Expanded(
              child: _Metric(
                'OCCUPIED',
                '96',
                '75% of capacity',
                Color(0xFFD9535C),
              ),
            ),
            const _Line(),
            const Expanded(
              child: _Metric(
                'AVAILABLE',
                '32',
                'Ready to assign',
                Color(0xFF20936B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const _Progress(
          value: .75,
          color: Color(0xFFE0646B),
          background: Color(0xFFDDF2E9),
        ),
      ],
    ),
  );
}

class _FeeCard extends StatelessWidget {
  const _FeeCard();
  @override
  Widget build(BuildContext context) => const _Base(
    child: Column(
      children: [
        _Title(
          icon: Icons.account_balance_wallet_outlined,
          label: 'Fee collection',
          action: 'View fees',
        ),
        SizedBox(height: 26),
        Row(
          children: [
            Expanded(
              child: _Metric(
                'COLLECTED',
                '₹86.2K',
                '78% received',
                Color(0xFF20936B),
              ),
            ),
            _Line(),
            Expanded(
              child: _Metric(
                'PENDING',
                '₹23.8K',
                '12 students due',
                Color(0xFFD88328),
              ),
            ),
          ],
        ),
        SizedBox(height: 18),
        _Progress(
          value: .78,
          color: Color(0xFF35AD7C),
          background: Color(0xFFFFEBD7),
        ),
      ],
    ),
  );
}

class _Title extends StatelessWidget {
  final IconData icon;
  final String label, action;
  const _Title({required this.icon, required this.label, required this.action});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: const Color(0xFF5145EA), size: 20),
      const SizedBox(width: 9),
      Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
      const Spacer(),
      Text(
        action,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Color(0xFF5145EA),
        ),
      ),
      const Icon(Icons.chevron_right, color: Color(0xFF5145EA), size: 16),
    ],
  );
}

class _Metric extends StatelessWidget {
  final String label, value, note;
  final Color color;
  const _Metric(this.label, this.value, this.note, this.color);
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          letterSpacing: .8,
          color: Color(0xFF9A9FAF),
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        value,
        style: TextStyle(
          fontSize: 24,
          height: 1,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
      const SizedBox(height: 7),
      Text(note, style: const TextStyle(fontSize: 8, color: Color(0xFFA2A7B6))),
    ],
  );
}

class _Line extends StatelessWidget {
  const _Line();
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 58,
    margin: const EdgeInsets.symmetric(horizontal: 12),
    color: const Color(0xFFE8EAF0),
  );
}

class _Progress extends StatelessWidget {
  final double value;
  final Color color, background;
  const _Progress({
    required this.value,
    required this.color,
    required this.background,
  });
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(5),
    child: LinearProgressIndicator(
      value: value,
      minHeight: 6,
      color: color,
      backgroundColor: background,
    ),
  );
}
