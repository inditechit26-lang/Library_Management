import 'package:flutter/material.dart';

enum NotificationCategory {
  all,
  payments,
  renewals,
  admissions,
  seats,
  announcements,
  system,
}

enum NotificationPriority {
  low,
  medium,
  high,
  urgent,
}

class NotificationAction {
  final String label;
  final IconData icon;
  final String actionKey;
  final bool isPrimary;

  const NotificationAction({
    required this.label,
    required this.icon,
    required this.actionKey,
    this.isPrimary = false,
  });
}

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final NotificationCategory category;
  final NotificationPriority priority;
  final String? studentName;
  final int? studentId;
  final String? seatNumber;
  final String? receiptNumber;
  final double? amount;
  final bool isRead;
  final bool isCompleted;
  final List<NotificationAction> actions;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.category,
    required this.priority,
    this.studentName,
    this.studentId,
    this.seatNumber,
    this.receiptNumber,
    this.amount,
    this.isRead = false,
    this.isCompleted = false,
    this.actions = const [],
  });

  NotificationItem copyWith({
    bool? isRead,
    bool? isCompleted,
  }) {
    return NotificationItem(
      id: id,
      title: title,
      description: description,
      timestamp: timestamp,
      category: category,
      priority: priority,
      studentName: studentName,
      studentId: studentId,
      seatNumber: seatNumber,
      receiptNumber: receiptNumber,
      amount: amount,
      isRead: isRead ?? this.isRead,
      isCompleted: isCompleted ?? this.isCompleted,
      actions: actions,
    );
  }
}

class ActivityLogItem {
  final String id;
  final String timeText;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  const ActivityLogItem({
    required this.id,
    required this.timeText,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });
}

class SmartInsightItem {
  final String id;
  final String title;
  final String actionLabel;
  final String actionKey;
  final IconData icon;

  const SmartInsightItem({
    required this.id,
    required this.title,
    required this.actionLabel,
    required this.actionKey,
    required this.icon,
  });
}

class TaskItem {
  final String id;
  final String title;
  final String subtitle;
  final String actionLabel;
  final String actionKey;
  final IconData icon;
  final Color color;
  final int count;

  const TaskItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.actionKey,
    required this.icon,
    required this.color,
    required this.count,
  });
}

class NotificationSettingsState {
  final bool paymentAlerts;
  final bool renewalAlerts;
  final bool admissionAlerts;
  final bool seatAlerts;
  final bool announcements;
  final bool systemNotifications;
  final bool whatsappReports;
  final bool automationAlerts;

  const NotificationSettingsState({
    this.paymentAlerts = true,
    this.renewalAlerts = true,
    this.admissionAlerts = true,
    this.seatAlerts = true,
    this.announcements = true,
    this.systemNotifications = true,
    this.whatsappReports = true,
    this.automationAlerts = true,
  });

  NotificationSettingsState copyWith({
    bool? paymentAlerts,
    bool? renewalAlerts,
    bool? admissionAlerts,
    bool? seatAlerts,
    bool? announcements,
    bool? systemNotifications,
    bool? whatsappReports,
    bool? automationAlerts,
  }) {
    return NotificationSettingsState(
      paymentAlerts: paymentAlerts ?? this.paymentAlerts,
      renewalAlerts: renewalAlerts ?? this.renewalAlerts,
      admissionAlerts: admissionAlerts ?? this.admissionAlerts,
      seatAlerts: seatAlerts ?? this.seatAlerts,
      announcements: announcements ?? this.announcements,
      systemNotifications: systemNotifications ?? this.systemNotifications,
      whatsappReports: whatsappReports ?? this.whatsappReports,
      automationAlerts: automationAlerts ?? this.automationAlerts,
    );
  }
}
