import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../admissions/screens/admission_screen.dart';
import '../widgets/quick_actions.dart';
import '../widgets/summary_cards.dart';

class DashboardScreen extends ConsumerWidget {
  final VoidCallback onOpenSeats, onOpenFees;
  const DashboardScreen({
    super.key,
    required this.onOpenSeats,
    required this.onOpenFees,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 26, 16, 28),
    children: [
      DashboardSummaryCards(
        studentCount: 128,
        onManageSeats: onOpenSeats,
        onViewFees: onOpenFees,
      ),
      const SizedBox(height: 42),
      DashboardQuickActions(onAddStudent: () => _openAdmission(context)),
    ],
  );

  void _openAdmission(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => const AdmissionScreen(),
  );
}
