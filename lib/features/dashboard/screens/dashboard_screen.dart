import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../admissions/screens/admission_screen.dart';
import '../../payments/providers/payments_provider.dart';
import '../../seats/providers/seats_provider.dart';
import '../../settings/providers/active_library_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../students/providers/students_provider.dart';
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
    ref.invalidate(librariesProvider);
    ref.invalidate(libraryInfoProvider);
    ref.invalidate(studentsStreamProvider);
    ref.invalidate(seatsStreamProvider);
    ref.invalidate(paymentsStreamProvider);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (mounted) {
      setState(() => _refreshKey++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedLibrary = ref.watch(activeLibraryProvider);
    final liveLibraryInfo = ref.watch(libraryInfoProvider).value;
    final activeLibrary = selectedLibrary.copyWith(
      name: liveLibraryInfo?['name'] as String?,
      ownerName: liveLibraryInfo?['ownerName'] as String?,
    );
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

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
          _ActiveLibraryCard(
            library: activeLibrary,
            isDark: isDark,
            onSwitch: () => context.push('/settings/libraries'),
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

class _ActiveLibraryCard extends StatelessWidget {
  const _ActiveLibraryCard({
    required this.library,
    required this.isDark,
    required this.onSwitch,
  });

  final LibraryModel library;
  final bool isDark;
  final VoidCallback onSwitch;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onSwitch,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: .08)
                  : const Color(0xFFE5E8F1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? .16 : .045),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1D2B58), Color(0xFF5B4FD8)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(library.icon, size: 22, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        _LiveDot(),
                        SizedBox(width: 6),
                        Text(
                          'ACTIVE LIBRARY',
                          style: TextStyle(
                            color: Color(0xFF13836A),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      library.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.25,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      library.ownerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: .075),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Switch',
                      style: TextStyle(
                        color: colors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: colors.primary,
                      size: 15,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveDot extends StatelessWidget {
  const _LiveDot();

  @override
  Widget build(BuildContext context) => Container(
    width: 7,
    height: 7,
    decoration: const BoxDecoration(
      color: Color(0xFF20B58D),
      shape: BoxShape.circle,
    ),
  );
}
