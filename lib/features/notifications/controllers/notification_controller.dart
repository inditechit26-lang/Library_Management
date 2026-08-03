import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_item.dart';
import '../providers/notifications_provider.dart';

class NotificationState {
  final List<NotificationItem> items;
  final List<ActivityLogItem> activities;
  final List<SmartInsightItem> insights;
  final List<TaskItem> tasks;
  final NotificationCategory selectedCategory;
  final String searchQuery;
  final bool showOnlyUnread;
  final bool showOnlyPriority;
  final int completedTodayCount;
  final int selectedTab;
  final NotificationSettingsState settings;

  const NotificationState({
    required this.items,
    required this.activities,
    required this.insights,
    required this.tasks,
    this.selectedCategory = NotificationCategory.all,
    this.searchQuery = '',
    this.showOnlyUnread = false,
    this.showOnlyPriority = false,
    this.completedTodayCount = 0,
    this.selectedTab = 0,
    this.settings = const NotificationSettingsState(),
  });

  NotificationState copyWith({
    List<NotificationItem>? items,
    List<ActivityLogItem>? activities,
    List<SmartInsightItem>? insights,
    List<TaskItem>? tasks,
    NotificationCategory? selectedCategory,
    String? searchQuery,
    bool? showOnlyUnread,
    bool? showOnlyPriority,
    int? completedTodayCount,
    int? selectedTab,
    NotificationSettingsState? settings,
  }) {
    return NotificationState(
      items: items ?? this.items,
      activities: activities ?? this.activities,
      insights: insights ?? this.insights,
      tasks: tasks ?? this.tasks,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      showOnlyUnread: showOnlyUnread ?? this.showOnlyUnread,
      showOnlyPriority: showOnlyPriority ?? this.showOnlyPriority,
      completedTodayCount: completedTodayCount ?? this.completedTodayCount,
      selectedTab: selectedTab ?? this.selectedTab,
      settings: settings ?? this.settings,
    );
  }

  int get unreadCount => items.where((item) => !item.isRead).length;
  int get highPriorityCount => items
      .where(
        (item) =>
            item.priority == NotificationPriority.urgent ||
            item.priority == NotificationPriority.high,
      )
      .length;
  int get todayCount => items.where((item) => _isToday(item.timestamp)).length;

  static bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

final notificationControllerProvider =
    NotifierProvider<NotificationController, NotificationState>(
      NotificationController.new,
    );

class NotificationController extends Notifier<NotificationState> {
  @override
  NotificationState build() {
    final records = ref.watch(notificationsStreamProvider).value ?? const [];
    final items = records.map(_notificationFromRecord).toList();
    final activities = records.map(_activityFromRecord).toList();
    return NotificationState(
      items: items,
      activities: activities,
      insights: [],
      tasks: [],
    );
  }

  void selectTab(int index) {
    state = state.copyWith(selectedTab: index);
  }

  void selectCategory(NotificationCategory category) {
    state = state.copyWith(
      selectedCategory: category,
      showOnlyUnread: false,
      showOnlyPriority: false,
    );
  }

  void applyFilter(
    NotificationCategory category, {
    bool? unreadOnly,
    bool? priorityOnly,
  }) {
    state = state.copyWith(
      selectedCategory: category,
      showOnlyUnread: unreadOnly ?? false,
      showOnlyPriority: priorityOnly ?? false,
    );
  }

  void toggleUnreadFilter() {
    state = state.copyWith(
      showOnlyUnread: !state.showOnlyUnread,
      showOnlyPriority: false,
    );
  }

  void togglePriorityFilter() {
    state = state.copyWith(
      showOnlyPriority: !state.showOnlyPriority,
      showOnlyUnread: false,
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void markAsRead(String id) {
    state = state.copyWith(
      items: state.items
          .map((item) => item.id == id ? item.copyWith(isRead: true) : item)
          .toList(),
    );
    unawaited(ref.read(notificationsRepositoryProvider).markAsRead(id));
  }

  void markAllAsRead() {
    final unreadIds = state.items
        .where((item) => !item.isRead)
        .map((item) => item.id)
        .toList();
    state = state.copyWith(
      items: state.items.map((item) => item.copyWith(isRead: true)).toList(),
    );
    for (final id in unreadIds) {
      unawaited(ref.read(notificationsRepositoryProvider).markAsRead(id));
    }
  }

  void dismissNotification(String id) {
    state = state.copyWith(
      items: state.items.where((item) => item.id != id).toList(),
    );
    unawaited(ref.read(notificationsRepositoryProvider).dismiss(id));
  }

  void dismissInsight(String insightId) {
    state = state.copyWith(
      insights: state.insights
          .where((insight) => insight.id != insightId)
          .toList(),
    );
  }

  void completeTask(String taskId) {
    state = state.copyWith(
      tasks: state.tasks.where((task) => task.id != taskId).toList(),
      completedTodayCount: state.completedTodayCount + 1,
    );
  }

  void updateSettings(NotificationSettingsState newSettings) {
    state = state.copyWith(settings: newSettings);
  }

  NotificationItem _notificationFromRecord(Map<String, dynamic> record) {
    final type = record['type'] as String? ?? 'system';
    return NotificationItem(
      id: record['id'] as String? ?? '',
      title: record['title'] as String? ?? 'Activity',
      description: record['description'] as String? ?? '',
      timestamp:
          (record['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      category: _category(type),
      priority: NotificationPriority.medium,
      isRead: record['isRead'] as bool? ?? false,
    );
  }

  ActivityLogItem _activityFromRecord(Map<String, dynamic> record) =>
      ActivityLogItem(
        id: record['id'] as String? ?? '',
        timeText: _timeText(record['timestamp'] as Timestamp?),
        title: record['title'] as String? ?? 'Activity',
        subtitle: record['description'] as String? ?? '',
        icon: Icons.history_rounded,
        accentColor: const Color(0xFF6366F1),
      );

  NotificationCategory _category(String type) {
    if (type.contains('payment')) return NotificationCategory.payments;
    if (type.contains('renew')) return NotificationCategory.renewals;
    if (type.contains('student')) return NotificationCategory.admissions;
    if (type.contains('seat')) return NotificationCategory.seats;
    return NotificationCategory.system;
  }

  String _timeText(Timestamp? timestamp) {
    if (timestamp == null) return 'Now';
    final difference = DateTime.now().difference(timestamp.toDate());
    if (difference.inMinutes < 1) return 'Now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}
