import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../students/providers/students_provider.dart';
import '../../seats/models/seat_model.dart';
import '../../seats/providers/seats_provider.dart';
import '../../payments/providers/payments_provider.dart';
import '../../settings/controllers/library_configuration_controller.dart';

class DashboardSummaryCards extends ConsumerWidget {
  final VoidCallback onManageSeats, onViewFees;
  const DashboardSummaryCards({
    super.key,
    required this.onManageSeats,
    required this.onViewFees,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsStreamProvider);
    final seatsAsync = ref.watch(seatsStreamProvider);
    final paymentsAsync = ref.watch(paymentsStreamProvider);
    final configuration = ref.watch(libraryConfigurationProvider);

    final students = (studentsAsync.asData?.value ?? []).where((student) {
      final type = student.seatType;
      if (type == null) {
        final halfTime = student.planName.toLowerCase().contains('half');
        return halfTime
            ? configuration.halfTimeEnabled
            : configuration.fullTimeEnabled;
      }
      return configuration.seatTypes.any((item) => item.name == type);
    }).toList();
    final seats = seatsAsync.asData?.value ?? [];
    final payments = paymentsAsync.asData?.value ?? [];

    final activeStudentCount = students
        .where((s) => s.status.toLowerCase() == 'active')
        .length;
    final occupiedSeatsCount = seats
        .where((s) => s.status == SeatStatus.occupied)
        .length;
    final totalSeatsCount = seats.length;
    final availableSeatsCount = seats
        .where((s) => s.status == SeatStatus.available)
        .length;
    final occupancyPercentage = totalSeatsCount > 0
        ? (occupiedSeatsCount / totalSeatsCount)
        : 0.0;

    final activeStudentIds = students
        .where((student) => student.status.toLowerCase() == 'active')
        .map((student) => student.id)
        .toSet();
    final activePayments = payments
        .where((payment) => activeStudentIds.contains(payment.studentId))
        .toList();
    final collectedRevenue = activePayments.fold(
      0.0,
      (sum, payment) => sum + payment.netAmount,
    );
    final now = DateTime.now();
    final pendingDues = students
        .where((s) => s.validUntil.isBefore(now))
        .fold(0.0, (sum, s) => sum + s.monthlyFee);
    final dueStudentsCount = students
        .where((s) => s.validUntil.isBefore(now))
        .length;
    final totalBilled = collectedRevenue + pendingDues;
    final collectionPercentage = totalBilled > 0
        ? (collectedRevenue / totalBilled)
        : 0.0;
    final paidStudentsCount = activePayments
        .map((payment) => payment.studentId)
        .where(activeStudentIds.contains)
        .toSet()
        .length;

    return Column(
      children: [
        _SeatCard(
          studentCount: activeStudentCount,
          occupiedCount: occupiedSeatsCount,
          availableCount: availableSeatsCount,
          occupancyRatio: occupancyPercentage,
          onManage: onManageSeats,
        ),
        const SizedBox(height: 16),
        _FeeCard(
          collected: collectedRevenue,
          pending: pendingDues,
          dueStudents: dueStudentsCount,
          paidStudents: paidStudentsCount,
          totalStudents: activeStudentCount,
          collectionRatio: collectionPercentage,
          onViewFees: onViewFees,
        ),
      ],
    );
  }
}

class _Base extends StatelessWidget {
  final Widget child;
  const _Base({required this.child});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? theme.colorScheme.outline.withOpacity(0.35)
              : const Color(0xFFE6E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.35)
                : const Color(0xFF1E2238).withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.15)
                : const Color(0xFF5145EA).withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SeatCard extends StatelessWidget {
  final int studentCount;
  final int occupiedCount;
  final int availableCount;
  final double occupancyRatio;
  final VoidCallback onManage;

  const _SeatCard({
    required this.studentCount,
    required this.occupiedCount,
    required this.availableCount,
    required this.occupancyRatio,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) => _Base(
    child: Column(
      children: [
        _Title(
          icon: Icons.grid_view_rounded,
          label: 'Seat occupancy',
          action: 'Manage',
          onTap: onManage,
        ),
        const SizedBox(height: 24),
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
            Expanded(
              child: _Metric(
                'OCCUPIED',
                '$occupiedCount',
                '${(occupancyRatio * 100).toStringAsFixed(0)}% of capacity',
                const Color(0xFFD9535C),
              ),
            ),
            const _Line(),
            Expanded(
              child: _Metric(
                'AVAILABLE',
                '$availableCount',
                'Ready to assign',
                const Color(0xFF20936B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _Progress(
          value: occupancyRatio.clamp(0.0, 1.0),
          color: const Color(0xFFE0646B),
          background: const Color(0xFFFDE8E9),
        ),
      ],
    ),
  );
}

class _FeeCard extends StatelessWidget {
  final double collected;
  final double pending;
  final int dueStudents;
  final int paidStudents;
  final int totalStudents;
  final double collectionRatio;
  final VoidCallback onViewFees;

  const _FeeCard({
    required this.collected,
    required this.pending,
    required this.dueStudents,
    required this.paidStudents,
    required this.totalStudents,
    required this.collectionRatio,
    required this.onViewFees,
  });

  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) => _Base(
    child: Column(
      children: [
        _Title(
          icon: Icons.account_balance_wallet_rounded,
          label: 'Fee collection',
          action: 'View fees',
          onTap: onViewFees,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _Metric(
                'COLLECTED',
                _formatAmount(collected),
                '$paidStudents of $totalStudents students paid',
                const Color(0xFF20936B),
              ),
            ),
            const _Line(),
            Expanded(
              child: _Metric(
                'PENDING',
                _formatAmount(pending),
                '$dueStudents students due',
                const Color(0xFFD88328),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _Progress(
          value: collectionRatio.clamp(0.0, 1.0),
          color: const Color(0xFF20936B),
          background: const Color(0xFFE2F4EC),
        ),
      ],
    ),
  );
}

class _Title extends StatelessWidget {
  final IconData icon;
  final String label, action;
  final VoidCallback onTap;
  const _Title({
    required this.icon,
    required this.label,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: primary.withOpacity(0.09),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: primary, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        const Spacer(),
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primary.withOpacity(0.2), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    action,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: primary,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.chevron_right_rounded, color: primary, size: 15),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedMetricValue extends StatelessWidget {
  final String rawValue;
  final TextStyle style;

  const _AnimatedMetricValue({required this.rawValue, required this.style});

  @override
  Widget build(BuildContext context) {
    final regex = RegExp(r'^([^0-9.]*)([0-9.]+)(.*)$');
    final match = regex.firstMatch(rawValue);

    if (match == null) {
      return Text(rawValue, style: style);
    }

    final prefix = match.group(1) ?? '';
    final numStr = match.group(2) ?? '0';
    final suffix = match.group(3) ?? '';

    final decimals = numStr.contains('.') ? numStr.split('.')[1].length : 0;
    final targetVal = double.tryParse(numStr) ?? 0.0;

    return TweenAnimationBuilder<double>(
      key: ValueKey(rawValue),
      tween: Tween<double>(begin: 0.0, end: targetVal),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, currentVal, child) {
        final formatted = decimals > 0
            ? currentVal.toStringAsFixed(decimals)
            : currentVal.toInt().toString();
        return Text('$prefix$formatted$suffix', style: style);
      },
    );
  }
}

class _Metric extends StatelessWidget {
  final String label, value, note;
  final Color color;
  const _Metric(this.label, this.value, this.note, this.color);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5,
                  letterSpacing: 0.7,
                  color: isDark
                      ? const Color(0xFF9EA6BA)
                      : const Color(0xFF83899F),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        _AnimatedMetricValue(
          rawValue: value,
          style: TextStyle(
            fontSize: 25,
            height: 1.0,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 7),
        _AnimatedMetricValue(
          rawValue: note,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFF868C9E) : const Color(0xFF7E8497),
          ),
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 1,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            (isDark ? const Color(0xFF353C4D) : const Color(0xFFE8EAF0))
                .withOpacity(0.15),
            isDark ? const Color(0xFF353C4D) : const Color(0xFFE8EAF0),
            (isDark ? const Color(0xFF353C4D) : const Color(0xFFE8EAF0))
                .withOpacity(0.15),
          ],
        ),
      ),
    );
  }
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackBg = isDark ? color.withOpacity(0.15) : background;

    return Stack(
      children: [
        Container(
          height: 7,
          width: double.infinity,
          decoration: BoxDecoration(
            color: trackBg,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: value),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeOutCubic,
          builder: (context, animatedVal, child) => FractionallySizedBox(
            widthFactor: animatedVal,
            child: Container(
              height: 7,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.82), color],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
