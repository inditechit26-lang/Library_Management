import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/notification_controller.dart';
import '../models/notification_item.dart';
import '../widgets/notification_app_bar.dart';
import '../widgets/notification_card.dart';
import '../widgets/notification_search_sheet.dart';
import '../widgets/smart_filters.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationControllerProvider);
    final controller = ref.read(notificationControllerProvider.notifier);
    final colors = Theme.of(context).colorScheme;

    // Filter items based on selected category & unread/priority flags
    final filteredItems = state.items.where((item) {
      if (state.showOnlyUnread && item.isRead) return false;
      if (state.showOnlyPriority &&
          item.priority != NotificationPriority.urgent &&
          item.priority != NotificationPriority.high) {
        return false;
      }
      if (state.selectedCategory != NotificationCategory.all &&
          item.category != state.selectedCategory) {
        return false;
      }
      return true;
    }).toList();

    // Group filtered items by date
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
      appBar: NotificationAppBar(
        unreadCount: state.unreadCount,
        onSearchPressed: () => _openSearchSheet(context, ref, state.items),
        onFilterPressed: () {},
        onMarkAllReadPressed: () {
          controller.markAllAsRead();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('All notifications marked as read'),
                ],
              ),
              backgroundColor: colors.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
        onSettingsPressed: () => context.push('/notifications/settings'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24, top: 8),
          children: [
            // Category & Status Filter Chips
            SmartFilters(
              selectedCategory: state.selectedCategory,
              isUnreadOnly: state.showOnlyUnread,
              isPriorityOnly: state.showOnlyPriority,
              onSelectFilter: (cat, {unreadOnly, priorityOnly}) {
                controller.applyFilter(cat, unreadOnly: unreadOnly, priorityOnly: priorityOnly);
              },
            ),
            const SizedBox(height: 8),

            // Notification List Sections
            if (filteredItems.isEmpty)
              _EmptyStateView(
                isUnreadOnly: state.showOnlyUnread,
                onResetFilters: () => controller.applyFilter(NotificationCategory.all),
              )
            else ...[
              if (todayItems.isNotEmpty)
                _NotificationSectionGroup(
                  title: 'TODAY',
                  items: todayItems,
                  onAction: (item, action) => _handleAction(context, ref, item, action),
                  onDismiss: (id) => controller.dismissNotification(id),
                  onMarkRead: (id) => controller.markAsRead(id),
                ),
              if (yesterdayItems.isNotEmpty)
                _NotificationSectionGroup(
                  title: 'YESTERDAY',
                  items: yesterdayItems,
                  onAction: (item, action) => _handleAction(context, ref, item, action),
                  onDismiss: (id) => controller.dismissNotification(id),
                  onMarkRead: (id) => controller.markAsRead(id),
                ),
              if (earlierItems.isNotEmpty)
                _NotificationSectionGroup(
                  title: 'EARLIER',
                  items: earlierItems,
                  onAction: (item, action) => _handleAction(context, ref, item, action),
                  onDismiss: (id) => controller.dismissNotification(id),
                  onMarkRead: (id) => controller.markAsRead(id),
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

  void _openSearchSheet(BuildContext context, WidgetRef ref, List<NotificationItem> items) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NotificationSearchSheet(
        items: items,
        onActionTap: (item, action) => _handleAction(context, ref, item, action),
      ),
    );
  }

  void _handleAction(
    BuildContext context,
    WidgetRef ref,
    NotificationItem item,
    NotificationAction action,
  ) {
    ref.read(notificationControllerProvider.notifier).markAsRead(item.id);

    if (action.actionKey == 'view_student' && item.studentId != null) {
      context.push('/students/${item.studentId}');
      return;
    }

    if (action.actionKey == 'renew' && item.studentId != null) {
      context.push('/students/${item.studentId}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening Renewal for ${item.studentName ?? 'Student'}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (action.actionKey == 'whatsapp') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('WhatsApp reminder queued for ${item.studentName ?? 'member'}'),
          backgroundColor: const Color(0xFF25D366),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (action.actionKey == 'collect_fee') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Collecting fee for ${item.studentName ?? 'member'} (${item.amount != null ? '₹${item.amount!.toInt()}' : ''})'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Action executed: "${action.label}"'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _NotificationSectionGroup extends StatelessWidget {
  final String title;
  final List<NotificationItem> items;
  final Function(NotificationItem item, NotificationAction action) onAction;
  final Function(String id) onDismiss;
  final Function(String id) onMarkRead;

  const _NotificationSectionGroup({
    required this.title,
    required this.items,
    required this.onAction,
    required this.onDismiss,
    required this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 6),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: colors.primary,
              letterSpacing: 1.1,
            ),
          ),
        ),
        ...items.map(
          (item) => NotificationCard(
            item: item,
            onActionTap: (action) => onAction(item, action),
            onDismiss: () => onDismiss(item.id),
            onMarkRead: () => onMarkRead(item.id),
          ),
        ),
      ],
    );
  }
}

class _EmptyStateView extends StatelessWidget {
  final bool isUnreadOnly;
  final VoidCallback onResetFilters;

  const _EmptyStateView({
    required this.isUnreadOnly,
    required this.onResetFilters,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 44,
              color: colors.outline,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            isUnreadOnly ? 'No Unread Notifications' : 'No Notifications Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isUnreadOnly
                ? "You have marked all notifications as read."
                : "There are no notifications matching your active filter.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onResetFilters,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Show All Notifications'),
          ),
        ],
      ),
    );
  }
}
