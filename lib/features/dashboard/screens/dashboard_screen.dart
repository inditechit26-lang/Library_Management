import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/quick_actions.dart';
import '../widgets/summary_cards.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 26, 16, 28),
    children: [
      DashboardSummaryCards(studentCount: 128),
      const SizedBox(height: 42),
      const DashboardQuickActions(),
    ],
  );
}
