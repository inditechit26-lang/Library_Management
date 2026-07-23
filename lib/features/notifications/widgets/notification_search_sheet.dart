import 'package:flutter/material.dart';
import '../models/notification_item.dart';

class NotificationSearchSheet extends StatefulWidget {
  final List<NotificationItem> items;
  final Function(NotificationItem item, NotificationAction action) onActionTap;

  const NotificationSearchSheet({
    super.key,
    required this.items,
    required this.onActionTap,
  });

  @override
  State<NotificationSearchSheet> createState() => _NotificationSearchSheetState();
}

class _NotificationSearchSheetState extends State<NotificationSearchSheet> {
  final TextEditingController _queryController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final filtered = widget.items.where((item) {
      if (_query.trim().isEmpty) return true;
      final q = _query.toLowerCase();
      final titleMatch = item.title.toLowerCase().contains(q);
      final descMatch = item.description.toLowerCase().contains(q);
      final studentMatch = item.studentName?.toLowerCase().contains(q) ?? false;
      final studentIdMatch = item.studentId?.toString().contains(q) ?? false;
      final seatMatch = item.seatNumber?.toLowerCase().contains(q) ?? false;
      final receiptMatch = item.receiptNumber?.toLowerCase().contains(q) ?? false;
      return titleMatch || descMatch || studentMatch || studentIdMatch || seatMatch || receiptMatch;
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: colors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _queryController,
              autofocus: true,
              onChanged: (val) => setState(() => _query = val),
              decoration: InputDecoration(
                hintText: 'Search Student, Seat, Receipt, or ID...',
                prefixIcon: Icon(Icons.search_rounded, color: colors.primary),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _queryController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: colors.surfaceContainerLow,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colors.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colors.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colors.primary, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Search Results (${filtered.length})',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Search by Name, Seat, Receipt, ID',
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.outline,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 16),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: colors.outline),
                        const SizedBox(height: 12),
                        Text(
                          'No matching notifications found',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final action = item.actions.firstOrNull;
                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: colors.primaryContainer,
                            child: Icon(Icons.notifications_outlined, color: colors.primary, size: 20),
                          ),
                          title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text(item.description, style: const TextStyle(fontSize: 11)),
                          trailing: action != null
                              ? TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    widget.onActionTap(item, action);
                                  },
                                  child: Text(action.label),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
