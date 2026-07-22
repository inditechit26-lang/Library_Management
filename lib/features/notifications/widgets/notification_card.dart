import 'package:flutter/material.dart';

import '../models/notification_item.dart';

class NotificationCard extends StatelessWidget {
  final NotificationItem item;
  final Function(NotificationAction action) onActionTap;
  final VoidCallback onDismiss;
  final VoidCallback onMarkRead;

  const NotificationCard({
    super.key,
    required this.item,
    required this.onActionTap,
    required this.onDismiss,
    required this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.horizontal,
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDismiss();
        } else {
          onMarkRead();
        }
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text('Mark Read', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFF5252),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Dismiss', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Icon(Icons.delete_outline_rounded, color: Colors.white),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: item.isRead ? colors.surfaceContainerLow : colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: item.isRead ? colors.outlineVariant.withOpacity(0.5) : colors.primary.withOpacity(0.25),
            width: item.isRead ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: item.isRead ? Colors.transparent : colors.primary.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CategoryAvatar(category: item.category),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800,
                                color: colors.onSurface,
                              ),
                            ),
                          ),
                          _PriorityBadge(priority: item.priority),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatTime(item.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: colors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (item.actions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: item.actions.map((act) {
                  return FilledButton.icon(
                    onPressed: () => onActionTap(act),
                    icon: Icon(act.icon, size: 14),
                    label: Text(
                      act.label,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: act.isPrimary ? colors.primary : colors.surfaceContainerHighest,
                      foregroundColor: act.isPrimary ? Colors.white : colors.onSurface,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }
}

class _CategoryAvatar extends StatelessWidget {
  final NotificationCategory category;

  const _CategoryAvatar({required this.category});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (category) {
      case NotificationCategory.payments:
        icon = Icons.payments_rounded;
        color = const Color(0xFF4CAF50);
        break;
      case NotificationCategory.renewals:
        icon = Icons.history_toggle_off_rounded;
        color = const Color(0xFFFF9800);
        break;
      case NotificationCategory.admissions:
        icon = Icons.person_add_alt_1_rounded;
        color = const Color(0xFF5650C7);
        break;
      case NotificationCategory.seats:
        icon = Icons.event_seat_rounded;
        color = const Color(0xFF00BCD4);
        break;
      case NotificationCategory.announcements:
        icon = Icons.campaign_rounded;
        color = const Color(0xFFE91E63);
        break;
      default:
        icon = Icons.notifications_active_rounded;
        color = const Color(0xFF607D8B);
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final NotificationPriority priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    if (priority == NotificationPriority.low) return const SizedBox.shrink();

    String label;
    Color bg;
    Color fg;

    switch (priority) {
      case NotificationPriority.urgent:
        label = 'Urgent';
        bg = const Color(0xFFFFEBEE);
        fg = const Color(0xFFFF5252);
        break;
      case NotificationPriority.high:
        label = 'High';
        bg = const Color(0xFFFFF3E0);
        fg = const Color(0xFFFF9800);
        break;
      default:
        label = 'Normal';
        bg = const Color(0xFFE8EAF6);
        fg = const Color(0xFF3F51B5);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}
