import 'package:flutter/material.dart';

class DashboardSummaryCards extends StatelessWidget {
  final int unreadCount;
  final int highPriorityCount;
  final int todayActivitiesCount;
  final int completedCount;
  final VoidCallback? onUnreadTap;
  final VoidCallback? onPriorityTap;

  const DashboardSummaryCards({
    super.key,
    required this.unreadCount,
    required this.highPriorityCount,
    required this.todayActivitiesCount,
    required this.completedCount,
    this.onUnreadTap,
    this.onPriorityTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _SummaryMetricCard(
            label: 'Unread',
            value: unreadCount,
            icon: Icons.mark_email_unread_outlined,
            accentColor: const Color(0xFF5650C7),
            onTap: onUnreadTap,
          ),
          const SizedBox(width: 12),
          _SummaryMetricCard(
            label: 'High Priority',
            value: highPriorityCount,
            icon: Icons.local_fire_department_rounded,
            accentColor: const Color(0xFFFF5252),
            onTap: onPriorityTap,
          ),
          const SizedBox(width: 12),
          _SummaryMetricCard(
            label: "Today's Activities",
            value: todayActivitiesCount,
            icon: Icons.bolt_rounded,
            accentColor: const Color(0xFFFF9800),
          ),
          const SizedBox(width: 12),
          _SummaryMetricCard(
            label: 'Completed',
            value: completedCount,
            icon: Icons.task_alt_rounded,
            accentColor: const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetricCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onTap;

  const _SummaryMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.outlineVariant.withOpacity(0.8)),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 18, color: accentColor),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: value.toDouble()),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.decelerate,
                    builder: (context, val, child) {
                      return Text(
                        val.toInt().toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                          letterSpacing: -0.5,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
