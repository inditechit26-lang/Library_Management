import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../admissions/screens/admission_screen.dart';
import '../../settings/providers/active_library_provider.dart';
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
  Widget build(BuildContext context) {
    final activeLibrary = ref.watch(activeLibraryProvider);
    final colors = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: colors.primary,
      child: ListView(
        key: ValueKey('${activeLibrary.id}_$_refreshKey'),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          // Active Library Header Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    activeLibrary.icon,
                    size: 20,
                    color: colors.onPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeLibrary.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Active Branch • ${activeLibrary.ownerName}',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => context.push('/settings/libraries'),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colors.outlineVariant,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Switch',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.swap_horiz_rounded,
                          size: 14,
                          color: colors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          DashboardSummaryCards(
            key: ValueKey('${activeLibrary.id}_$_refreshKey'),
            onManageSeats: widget.onOpenSeats,
            onViewFees: widget.onOpenFees,
          ),
          const SizedBox(height: 32),
          DashboardQuickActions(onAddStudent: () => _openAdmission(context)),
        ],
      ),
    );
  }

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
