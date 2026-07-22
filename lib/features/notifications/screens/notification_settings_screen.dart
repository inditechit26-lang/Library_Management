import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/notification_controller.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationControllerProvider);
    final controller = ref.read(notificationControllerProvider.notifier);
    final settings = state.settings;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Notification Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(title: 'ALERT CATEGORIES'),
          _SwitchTile(
            title: 'Payment Alerts',
            subtitle: 'Instant alerts for fee collection, due dates & receipts',
            icon: Icons.payments_outlined,
            value: settings.paymentAlerts,
            onChanged: (val) => controller.updateSettings(settings.copyWith(paymentAlerts: val)),
          ),
          _SwitchTile(
            title: 'Renewal Alerts',
            subtitle: 'Expirations, upcoming renewals & overdue members',
            icon: Icons.history_toggle_off_rounded,
            value: settings.renewalAlerts,
            onChanged: (val) => controller.updateSettings(settings.copyWith(renewalAlerts: val)),
          ),
          _SwitchTile(
            title: 'Admission Alerts',
            subtitle: 'New student registrations & seat assignments',
            icon: Icons.person_add_alt_1_outlined,
            value: settings.admissionAlerts,
            onChanged: (val) => controller.updateSettings(settings.copyWith(admissionAlerts: val)),
          ),
          _SwitchTile(
            title: 'Seat Alerts',
            subtitle: 'Seat changes, vacancy alerts & shift movements',
            icon: Icons.event_seat_outlined,
            value: settings.seatAlerts,
            onChanged: (val) => controller.updateSettings(settings.copyWith(seatAlerts: val)),
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: 'COMMUNICATION & SYSTEM'),
          _SwitchTile(
            title: 'Announcements',
            subtitle: 'Broadcast alerts & library notice delivery logs',
            icon: Icons.campaign_outlined,
            value: settings.announcements,
            onChanged: (val) => controller.updateSettings(settings.copyWith(announcements: val)),
          ),
          _SwitchTile(
            title: 'System Notifications',
            subtitle: 'App updates, backup logs & security alerts',
            icon: Icons.tune_rounded,
            value: settings.systemNotifications,
            onChanged: (val) => controller.updateSettings(settings.copyWith(systemNotifications: val)),
          ),
          _SwitchTile(
            title: 'WhatsApp Delivery Reports',
            subtitle: 'Delivery & read confirmations for automated WhatsApp messages',
            icon: Icons.chat_bubble_outline_rounded,
            value: settings.whatsappReports,
            onChanged: (val) => controller.updateSettings(settings.copyWith(whatsappReports: val)),
          ),
          _SwitchTile(
            title: 'Automation Alerts',
            subtitle: 'Auto-reminder triggers & automated fee follow-up status',
            icon: Icons.smart_toy_outlined,
            value: settings.automationAlerts,
            onChanged: (val) => controller.updateSettings(settings.copyWith(automationAlerts: val)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: colors.primary,
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: SwitchListTile(
        secondary: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: colors.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: colors.primary,
      ),
    );
  }
}
