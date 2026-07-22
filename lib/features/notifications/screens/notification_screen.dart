import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/notification_controller.dart';
import '../models/notification_item.dart';
import '../widgets/dashboard_summary_cards.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationControllerProvider);
    final controller = ref.read(notificationControllerProvider.notifier);
    final colors = Theme.of(context).colorScheme;

    // Filter notifications
    final filteredItems = state.items.where((item) {
      if (state.showOnlyUnread && item.isRead) return false;
      if (state.selectedCategory != NotificationCategory.all &&
          item.category != state.selectedCategory) {
        return false;
      }
      return true;
    }).toList();

    // Group items by date
    final now = DateTime.now();
    final todayItems = filteredItems.where((i) => _isSameDay(i.timestamp, now)).toList();
    final yesterdayItems = filteredItems
        .where((i) => _isSameDay(i.timestamp, now.subtract(const Duration(days: 1))))
        .toList();
    final earlierItems = filteredItems
        .where((i) =>
            !_isSameDay(i.timestamp, now) &&
            !_isSameDay(i.timestamp, now.subtract(const Duration(days: 1))))
        .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              '${state.unreadCount} unread alerts',
              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
            ),
          ],
        ),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Mark All as Read',
            icon: const Icon(Icons.done_all_rounded, size: 20),
            onPressed: () {
              controller.markAllAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read')),
              );
            },
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined, size: 20),
            onPressed: () => context.push('/notifications/settings'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 400));
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Compact Summary Metrics
            DashboardSummaryCards(
              unreadCount: state.unreadCount,
              highPriorityCount: state.highPriorityCount,
              todayActivitiesCount: state.todayCount,
              completedCount: state.completedTodayCount,
              onUnreadTap: () => controller.toggleUnreadFilter(),
              onPriorityTap: () => controller.togglePriorityFilter(),
            ),
            const SizedBox(height: 16),

            // Simple Filter Chips
            _SimpleFilterChips(
              selectedCategory: state.selectedCategory,
              isUnreadOnly: state.showOnlyUnread,
              onSelect: (cat, isUnread) {
                if (isUnread) {
                  controller.toggleUnreadFilter();
                } else {
                  controller.selectCategory(cat);
                }
              },
            ),
            const SizedBox(height: 16),

            // Notifications List
            if (filteredItems.isEmpty)
              _SimpleEmptyState()
            else ...[
              if (todayItems.isNotEmpty)
                _NotificationSection(
                  title: 'Today',
                  items: todayItems,
                  onAction: (item, action) => _handleAction(context, ref, item, action),
                  onDismiss: (id) => controller.dismissNotification(id),
                ),
              if (yesterdayItems.isNotEmpty)
                _NotificationSection(
                  title: 'Yesterday',
                  items: yesterdayItems,
                  onAction: (item, action) => _handleAction(context, ref, item, action),
                  onDismiss: (id) => controller.dismissNotification(id),
                ),
              if (earlierItems.isNotEmpty)
                _NotificationSection(
                  title: 'Earlier',
                  items: earlierItems,
                  onAction: (item, action) => _handleAction(context, ref, item, action),
                  onDismiss: (id) => controller.dismissNotification(id),
                ),
            ],
          ],
        ),
      ),
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _handleAction(
    BuildContext context,
    WidgetRef ref,
    NotificationItem item,
    NotificationAction action,
  ) {
    ref.read(notificationControllerProvider.notifier).markAsRead(item.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Executing "${action.label}" for ${item.title}')),
    );
  }
}

class _SimpleFilterChips extends StatelessWidget {
  final NotificationCategory selectedCategory;
  final bool isUnreadOnly;
  final Function(NotificationCategory cat, bool isUnread) onSelect;

  const _SimpleFilterChips({
    required this.selectedCategory,
    required this.isUnreadOnly,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final chips = [
      (label: 'All', cat: NotificationCategory.all, isUnread: false),
      (label: 'Unread', cat: NotificationCategory.all, isUnread: true),
      (label: 'Payments', cat: NotificationCategory.payments, isUnread: false),
      (label: 'Renewals', cat: NotificationCategory.renewals, isUnread: false),
      (label: 'Admissions', cat: NotificationCategory.admissions, isUnread: false),
      (label: 'Seats', cat: NotificationCategory.seats, isUnread: false),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips.map((c) {
          final isSelected = c.isUnread
              ? isUnreadOnly
              : (!isUnreadOnly && selectedCategory == c.cat);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(c.label),
              selected: isSelected,
              onSelected: (_) => onSelect(c.cat, c.isUnread),
              selectedColor: colors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : colors.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NotificationSection extends StatelessWidget {
  final String title;
  final List<NotificationItem> items;
  final Function(NotificationItem item, NotificationAction action) onAction;
  final Function(String id) onDismiss;

  const _NotificationSection({
    required this.title,
    required this.items,
    required this.onAction,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: colors.primary,
              letterSpacing: 0.8,
            ),
          ),
        ),
        ...items.map(
          (item) => _SimpleNotificationCard(
            item: item,
            onAction: (act) => onAction(item, act),
            onDismiss: () => onDismiss(item.id),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _SimpleNotificationCard extends StatelessWidget {
  final NotificationItem item;
  final Function(NotificationAction action) onAction;
  final VoidCallback onDismiss;

  const _SimpleNotificationCard({
    required this.item,
    required this.onAction,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    IconData icon;
    Color iconColor;
    switch (item.category) {
      case NotificationCategory.payments:
        icon = Icons.payments_rounded;
        iconColor = Colors.green;
        break;
      case NotificationCategory.renewals:
        icon = Icons.event_repeat_rounded;
        iconColor = Colors.orange;
        break;
      case NotificationCategory.admissions:
        icon = Icons.person_add_alt_1_rounded;
        iconColor = colors.primary;
        break;
      case NotificationCategory.seats:
        icon = Icons.event_seat_rounded;
        iconColor = Colors.teal;
        break;
      default:
        icon = Icons.notifications_rounded;
        iconColor = Colors.blueGrey;
    }

    return Dismissible(
      key: Key(item.id),
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.red),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 0,
        color: item.isRead ? colors.surfaceContainerLow : colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: item.isRead
                ? colors.outlineVariant
                : colors.primary.withOpacity(0.3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
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
                              fontWeight: item.isRead
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                        Text(
                          _formatTime(item.timestamp),
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    if (item.actions.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton.tonal(
                          onPressed: () => onAction(item.actions.first),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            item.actions.first.label,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _SimpleEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 48, color: colors.outline),
          const SizedBox(height: 12),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "You're all caught up for now",
            style: TextStyle(
              fontSize: 12,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
