import 'package:flutter/material.dart';
import '../models/notification_item.dart';

class PriorityAlertCard extends StatelessWidget {
  final List<NotificationItem> priorityItems;
  final Function(NotificationItem item, NotificationAction action) onActionTap;

  const PriorityAlertCard({
    super.key,
    required this.priorityItems,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (priorityItems.isEmpty) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFCDD2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5252).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  size: 18,
                  color: Color(0xFFFF5252),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'HIGH PRIORITY ALERTS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: Color(0xFFD32F2F),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5252),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${priorityItems.length} Urgent',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...priorityItems.map((item) => _PriorityItemTile(
                item: item,
                onActionTap: (action) => onActionTap(item, action),
              )),
        ],
      ),
    );
  }
}

class _PriorityItemTile extends StatelessWidget {
  final NotificationItem item;
  final Function(NotificationAction action) onActionTap;

  const _PriorityItemTile({
    required this.item,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCDD2).withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF263238),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF546E7A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (item.actions.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: item.actions.map((action) {
                return FilledButton.icon(
                  onPressed: () => onActionTap(action),
                  icon: Icon(action.icon, size: 14),
                  label: Text(
                    action.label,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: action.isPrimary ? const Color(0xFFFF5252) : const Color(0xFFFFEBEE),
                    foregroundColor: action.isPrimary ? Colors.white : const Color(0xFFD32F2F),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    );
  }
}
