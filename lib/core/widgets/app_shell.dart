import 'package:flutter/material.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/students/screens/students_screen.dart';
import '../../features/seats/screens/seat_management_screen.dart';
import '../../features/receipts/screens/receipt_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  static const labels = ['Dashboard', 'Students', 'Seats', 'Fees', 'Settings'];
  static const icons = [
    Icons.home_outlined,
    Icons.people_outline,
    Icons.grid_view_outlined,
    Icons.account_balance_wallet_outlined,
    Icons.settings_outlined,
  ];
  final screens = const [
    DashboardScreen(),
    StudentsScreen(),
    SeatManagementScreen(),
    ReceiptScreen(),
    SettingsScreen(),
  ];
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: index == 0,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop && index != 0) setState(() => index = 0);
    },
    child: Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(title: labels[index]),
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
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE6E8F0))),
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
                  onTap: () => setState(() => index = item),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (index == item)
                        const Positioned(
                          top: 0,
                          child: SizedBox(
                            width: 30,
                            child: Divider(
                              height: 3,
                              thickness: 3,
                              color: Color(0xFF5145EA),
                            ),
                          ),
                        ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icons[item],
                            color: index == item
                                ? const Color(0xFF5145EA)
                                : const Color(0xFF969BAB),
                            size: 25,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            labels[item],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: index == item
                                  ? const Color(0xFF5145EA)
                                  : const Color(0xFF969BAB),
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

class _Header extends StatelessWidget {
  final String title;
  const _Header({required this.title});
  @override
  Widget build(BuildContext context) => Container(
    height: 86,
    padding: const EdgeInsets.symmetric(horizontal: 18),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: Color(0xFFE4E7EF))),
    ),
    child: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE4E7EF)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.menu_rounded, size: 25),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'THE STUDY ROOM',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2,
                  color: Color(0xFF9196A8),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 23,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF191C2D),
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
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE4E7EF)),
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
