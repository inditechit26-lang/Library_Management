import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../admissions/screens/admission_screen.dart';
import '../widgets/quick_actions.dart';
import '../widgets/summary_cards.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final VoidCallback onOpenSeats, onOpenFees;
  const DashboardScreen({
    super.key,
    required this.onOpenSeats,
    required this.onOpenFees,
  });

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _refreshKey = 0;

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _refreshKey++);
    }
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: _handleRefresh,
        color: Theme.of(context).colorScheme.primary,
        child: ListView(
          key: ValueKey(_refreshKey),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: [
            DashboardSummaryCards(
              key: ValueKey(_refreshKey),
              studentCount: 128,
              onManageSeats: widget.onOpenSeats,
              onViewFees: widget.onOpenFees,
            ),
            const SizedBox(height: 32),
            DashboardQuickActions(onAddStudent: () => _openAdmission(context)),
          ],
        ),
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

