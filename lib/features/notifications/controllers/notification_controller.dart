import 'package:flutter/material.dart';
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
    this.completedTodayCount = 18,
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

  int get unreadCount => items.where((i) => !i.isRead).length;
  int get highPriorityCount =>
      items.where((i) => i.priority == NotificationPriority.urgent || i.priority == NotificationPriority.high).length;
  int get todayCount => items.where((i) => _isToday(i.timestamp)).length;

  static bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}

final notificationControllerProvider =
    NotifierProvider<NotificationController, NotificationState>(
  NotificationController.new,
);

class NotificationController extends Notifier<NotificationState> {
  @override
  NotificationState build() {
    return _initialState();
  }

  static NotificationState _initialState() {
    final now = DateTime.now();
    return NotificationState(
      items: [
        NotificationItem(
          id: 'n1',
          title: 'Plan Expiring Today',
          description: 'Rahul Sharma (Seat A-12) plan expires today at 11:59 PM.',
          timestamp: now.subtract(const Duration(minutes: 5)),
          category: NotificationCategory.renewals,
          priority: NotificationPriority.high,
          studentName: 'Rahul Sharma',
          studentId: 1,
          seatNumber: 'A-12',
          actions: const [
            NotificationAction(
              label: 'Renew',
              icon: Icons.autorenew_rounded,
              actionKey: 'renew',
              isPrimary: true,
            ),
            NotificationAction(
              label: 'WhatsApp Reminder',
              icon: Icons.chat_bubble_outline_rounded,
              actionKey: 'whatsapp',
            ),
          ],
        ),
        NotificationItem(
          id: 'n2',
          title: 'Pending Payment: Plan Expired',
          description: 'Arjun Mehta (Seat B1) plan expired. ₹1,200 pending payment due.',
          timestamp: now.subtract(const Duration(minutes: 15)),
          category: NotificationCategory.payments,
          priority: NotificationPriority.urgent,
          studentName: 'Arjun Mehta',
          studentId: 3,
          seatNumber: 'B1',
          amount: 1200,
          actions: const [
            NotificationAction(
              label: 'Collect Fee',
              icon: Icons.account_balance_wallet_outlined,
              actionKey: 'collect_fee',
              isPrimary: true,
            ),
            NotificationAction(
              label: 'WhatsApp Reminder',
              icon: Icons.chat_bubble_outline_rounded,
              actionKey: 'whatsapp',
            ),
          ],
        ),
        NotificationItem(
          id: 'n3',
          title: 'Pending Payment: Plan Expired',
          description: 'Sneha Kapoor (Seat B3) plan expired 2 days ago. ₹1,500 due.',
          timestamp: now.subtract(const Duration(hours: 1)),
          category: NotificationCategory.payments,
          priority: NotificationPriority.high,
          studentName: 'Sneha Kapoor',
          studentId: 4,
          seatNumber: 'B3',
          amount: 1500,
          actions: const [
            NotificationAction(
              label: 'Collect Fee',
              icon: Icons.account_balance_wallet_outlined,
              actionKey: 'collect_fee',
              isPrimary: true,
            ),
          ],
        ),
        NotificationItem(
          id: 'n4',
          title: 'Payment Received',
          description: 'Rahul Sharma paid ₹800 via UPI.',
          timestamp: now.subtract(const Duration(hours: 2)),
          category: NotificationCategory.payments,
          priority: NotificationPriority.medium,
          studentName: 'Rahul Sharma',
          studentId: 1,
          receiptNumber: 'AEW1023',
          amount: 800,
          isRead: true,
          actions: const [
            NotificationAction(
              label: 'View Receipt',
              icon: Icons.receipt_long_rounded,
              actionKey: 'view_receipt',
              isPrimary: true,
            ),
          ],
        ),
        NotificationItem(
          id: 'n5',
          title: 'New Admission',
          description: 'Priya Verma assigned to Seat A2.',
          timestamp: now.subtract(const Duration(hours: 4)),
          category: NotificationCategory.admissions,
          priority: NotificationPriority.medium,
          studentName: 'Priya Verma',
          studentId: 2,
          seatNumber: 'A2',
          actions: const [
            NotificationAction(
              label: 'View Student',
              icon: Icons.person_outline_rounded,
              actionKey: 'view_student',
              isPrimary: true,
            ),
          ],
        ),
        NotificationItem(
          id: 'n6',
          title: 'Seat Changed',
          description: 'Rahul moved from Seat A1 to B1.',
          timestamp: now.subtract(const Duration(hours: 6)),
          category: NotificationCategory.seats,
          priority: NotificationPriority.low,
          studentName: 'Rahul Sharma',
          studentId: 1,
          seatNumber: 'B1',
          isRead: true,
          actions: const [
            NotificationAction(
              label: 'View Student',
              icon: Icons.person_outline_rounded,
              actionKey: 'view_student',
            ),
          ],
        ),
        NotificationItem(
          id: 'n7',
          title: 'Announcement Sent',
          description: 'Holiday notice delivered to 185 Students.',
          timestamp: now.subtract(const Duration(days: 1)),
          category: NotificationCategory.announcements,
          priority: NotificationPriority.low,
          isRead: true,
          actions: const [
            NotificationAction(
              label: 'View Report',
              icon: Icons.insights_rounded,
              actionKey: 'view_report',
            ),
          ],
        ),
      ],
      tasks: const [
        TaskItem(
          id: 't1',
          title: 'Collect Fees (4)',
          subtitle: '₹3,200 Pending',
          actionLabel: 'Collect',
          actionKey: 'collect_fees',
          icon: Icons.account_balance_wallet_rounded,
          color: Color(0xFFFF5252),
          count: 4,
        ),
        TaskItem(
          id: 't2',
          title: 'Renew Memberships (3)',
          subtitle: 'Expires Today',
          actionLabel: 'Renew',
          actionKey: 'renew_memberships',
          icon: Icons.history_toggle_off_rounded,
          color: Color(0xFFFF9800),
          count: 3,
        ),
        TaskItem(
          id: 't3',
          title: 'Send Reminder (2)',
          subtitle: '7 Expiring Tomorrow',
          actionLabel: 'Send',
          actionKey: 'send_reminders',
          icon: Icons.send_rounded,
          color: Color(0xFF5650C7),
          count: 2,
        ),
        TaskItem(
          id: 't4',
          title: 'Assign Seats (1)',
          subtitle: '2 Seats Available',
          actionLabel: 'Assign',
          actionKey: 'assign_seats',
          icon: Icons.event_seat_rounded,
          color: Color(0xFF4CAF50),
          count: 1,
        ),
      ],
      insights: const [
        SmartInsightItem(
          id: 'i1',
          title: '5 memberships expire tomorrow. Send reminders now.',
          actionLabel: 'Send All Reminders',
          actionKey: 'send_all_reminders',
          icon: Icons.lightbulb_outline_rounded,
        ),
        SmartInsightItem(
          id: 'i2',
          title: '₹12,400 pending collection. Collect today to maintain 95%+ efficiency.',
          actionLabel: 'Collect Pending',
          actionKey: 'collect_pending',
          icon: Icons.trending_up_rounded,
        ),
        SmartInsightItem(
          id: 'i3',
          title: '3 seats became available. Assign waiting list students.',
          actionLabel: 'Assign Waiting',
          actionKey: 'assign_waiting',
          icon: Icons.event_seat_rounded,
        ),
        SmartInsightItem(
          id: 'i4',
          title: 'Monthly collection reached 92%. Only ₹3,000 remaining to target.',
          actionLabel: 'View Goal',
          actionKey: 'view_goal',
          icon: Icons.verified_rounded,
        ),
      ],
      activities: [
        ActivityLogItem(
          id: 'a1',
          timeText: '10:20 AM',
          title: 'Payment Received',
          subtitle: '₹800 paid by Rahul Sharma',
          icon: Icons.payments_outlined,
          accentColor: const Color(0xFF4CAF50),
        ),
        ActivityLogItem(
          id: 'a2',
          timeText: '10:05 AM',
          title: 'Admission Added',
          subtitle: 'Priya Verma joined (Seat A-12)',
          icon: Icons.person_add_alt_1_outlined,
          accentColor: const Color(0xFF5650C7),
        ),
        ActivityLogItem(
          id: 'a3',
          timeText: '09:48 AM',
          title: 'Seat Changed',
          subtitle: 'Rahul moved A-12 → B-04',
          icon: Icons.swap_horiz_rounded,
          accentColor: const Color(0xFFFF9800),
        ),
        ActivityLogItem(
          id: 'a4',
          timeText: '09:10 AM',
          title: 'Membership Renewed',
          subtitle: 'Amit Patel renewed for 1 Month',
          icon: Icons.verified_outlined,
          accentColor: const Color(0xFF00BCD4),
        ),
      ],
    );
  }

  void selectTab(int index) {
    state = state.copyWith(selectedTab: index);
  }

  void selectCategory(NotificationCategory cat) {
    state = state.copyWith(selectedCategory: cat, showOnlyUnread: false, showOnlyPriority: false);
  }

  void applyFilter(NotificationCategory category, {bool? unreadOnly, bool? priorityOnly}) {
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
      items: state.items.map((i) => i.id == id ? i.copyWith(isRead: true) : i).toList(),
    );
  }

  void markAllAsRead() {
    state = state.copyWith(
      items: state.items.map((i) => i.copyWith(isRead: true)).toList(),
    );
  }

  void dismissNotification(String id) {
    state = state.copyWith(
      items: state.items.where((i) => i.id != id).toList(),
    );
  }

  void dismissInsight(String insightId) {
    state = state.copyWith(
      insights: state.insights.where((i) => i.id != insightId).toList(),
    );
  }

  void completeTask(String taskId) {
    state = state.copyWith(
      tasks: state.tasks.where((t) => t.id != taskId).toList(),
      completedTodayCount: state.completedTodayCount + 1,
    );
  }

  void updateSettings(NotificationSettingsState newSettings) {
    state = state.copyWith(settings: newSettings);
  }
}
