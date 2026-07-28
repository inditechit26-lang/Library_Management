import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_item.dart';

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
    return const NotificationState(
      items: [],
      activities: [],
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
  }

  void markAllAsRead() {
    state = state.copyWith(
      items: state.items
          .map((item) => item.copyWith(isRead: true))
          .toList(),
    );
  }

  void dismissNotification(String id) {
    state = state.copyWith(
      items: state.items.where((item) => item.id != id).toList(),
    );
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
}
