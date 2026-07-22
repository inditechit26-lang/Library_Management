import 'package:flutter/material.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/students/screens/students_screen.dart';
import '../../features/seats/screens/seat_management_screen.dart';
import '../../features/receipts/screens/receipt_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../settings/app_settings.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});
  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int index = 0;
  static const labels = ['Dashboard', 'Students', 'Seats', 'Fees', 'Settings'];
  static const icons = [
    Icons.home_outlined,
    Icons.people_outline,
    Icons.grid_view_outlined,
    Icons.account_balance_wallet_outlined,
    Icons.settings_outlined,
  ];
  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appSettingsProvider).language;
    final translatedLabels = labels
        .map((label) => translate(label, language))
        .toList();
    final colors = Theme.of(context).colorScheme;
    final screens = [
      DashboardScreen(
        onOpenSeats: () => _selectTab(2),
        onOpenFees: () => _selectTab(3),
      ),
      const StudentsScreen(),
      const SeatManagementScreen(),
      const ReceiptScreen(),
      const SettingsScreen(),
    ];
    return PopScope(
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && index != 0) setState(() => index = 0);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _Header(title: translatedLabels[index]),
              Expanded(
                child: IndexedStack(index: index, children: screens),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            height: 82,
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(top: BorderSide(color: colors.outlineVariant)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x0C242943),
                  blurRadius: 20,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: List.generate(
                labels.length,
                (item) => Expanded(
                  child: InkWell(
                    onTap: () => _selectTab(item),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (index == item)
                          Positioned(
                            top: 0,
                            child: SizedBox(
                              width: 30,
                              child: Divider(
                                height: 3,
                                thickness: 3,
                                color: colors.primary,
                              ),
                            ),
                          ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              icons[item],
                              color: index == item
                                  ? colors.primary
                                  : colors.onSurfaceVariant,
                              size: 25,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              translatedLabels[item],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: index == item
                                    ? colors.primary
                                    : colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _selectTab(int value) => setState(() => index = value);
}

class _Header extends StatelessWidget {
  final String title;
  const _Header({required this.title});
  @override
  Widget build(BuildContext context) => Container(
    height: 86,
    padding: const EdgeInsets.symmetric(horizontal: 18),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border(
        bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 25,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        Stack(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF656A7C),
              ),
            ),
            const Positioned(
              right: 9,
              top: 9,
              child: CircleAvatar(
                radius: 2.5,
                backgroundColor: Color(0xFFFF626B),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
