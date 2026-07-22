import 'package:flutter/material.dart';
import '../models/notification_item.dart';

class FilterChipData {
  final String label;
  final NotificationCategory category;
  final IconData icon;
  final bool isSpecialUnread;
  final bool isSpecialPriority;

  const FilterChipData({
    required this.label,
    required this.category,
    required this.icon,
    this.isSpecialUnread = false,
    this.isSpecialPriority = false,
  });
}

class SmartFilters extends StatelessWidget {
  final NotificationCategory selectedCategory;
  final bool isUnreadOnly;
  final bool isPriorityOnly;
  final Function(NotificationCategory category, {bool? unreadOnly, bool? priorityOnly}) onSelectFilter;

  const SmartFilters({
    super.key,
    required this.selectedCategory,
    required this.isUnreadOnly,
    required this.isPriorityOnly,
    required this.onSelectFilter,
  });

  static const filters = <FilterChipData>[
    FilterChipData(label: 'All', category: NotificationCategory.all, icon: Icons.grid_view_rounded),
    FilterChipData(label: 'Priority', category: NotificationCategory.all, icon: Icons.local_fire_department_rounded, isSpecialPriority: true),
    FilterChipData(label: 'Payments', category: NotificationCategory.payments, icon: Icons.payments_outlined),
    FilterChipData(label: 'Renewals', category: NotificationCategory.renewals, icon: Icons.history_toggle_off_rounded),
    FilterChipData(label: 'Admissions', category: NotificationCategory.admissions, icon: Icons.person_add_alt_1_outlined),
    FilterChipData(label: 'Seats', category: NotificationCategory.seats, icon: Icons.event_seat_outlined),
    FilterChipData(label: 'Announcements', category: NotificationCategory.announcements, icon: Icons.campaign_outlined),
    FilterChipData(label: 'System', category: NotificationCategory.system, icon: Icons.tune_rounded),
    FilterChipData(label: 'Unread', category: NotificationCategory.all, icon: Icons.mark_email_unread_outlined, isSpecialUnread: true),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: filters.map((data) {
          final isSelected = _checkIsSelected(data);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _AnimatedFilterChip(
              data: data,
              isSelected: isSelected,
              onTap: () {
                if (data.isSpecialUnread) {
                  onSelectFilter(NotificationCategory.all, unreadOnly: true, priorityOnly: false);
                } else if (data.isSpecialPriority) {
                  onSelectFilter(NotificationCategory.all, unreadOnly: false, priorityOnly: true);
                } else {
                  onSelectFilter(data.category, unreadOnly: false, priorityOnly: false);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  bool _checkIsSelected(FilterChipData data) {
    if (data.isSpecialUnread) return isUnreadOnly;
    if (data.isSpecialPriority) return isPriorityOnly;
    return !isUnreadOnly && !isPriorityOnly && selectedCategory == data.category;
  }
}

class _AnimatedFilterChip extends StatelessWidget {
  final FilterChipData data;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedFilterChip({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final primary = colors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? primary : colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? primary : colors.outlineVariant,
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primary.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                data.icon,
                size: 16,
                color: isSelected ? Colors.white : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                data.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
