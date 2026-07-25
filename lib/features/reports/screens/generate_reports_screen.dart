import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../students/controllers/students_controller.dart';
import '../../seats/controllers/seats_controller.dart';
import '../../settings/controllers/owner_profile_controller.dart';
import '../report_generator.dart';
import '../models/report_data.dart';
import '../widgets/monthly_selector_sheet.dart';
import '../widgets/year_selector_sheet.dart';
import '../widgets/report_generation_dialog.dart';
import 'report_preview_screen.dart';

class GenerateReportsScreen extends ConsumerStatefulWidget {
  const GenerateReportsScreen({super.key});

  @override
  ConsumerState<GenerateReportsScreen> createState() =>
      _GenerateReportsScreenState();
}

class _GenerateReportsScreenState
    extends ConsumerState<GenerateReportsScreen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedMonthlyYear = DateTime.now().year;
  int _selectedYear = DateTime.now().year;

  final List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: colors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Generate Reports',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtitle header
            Text(
              'Create professional business reports with one tap.',
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            // Top Summary Card (Large Glass-style card)
            _buildTopSummaryCard(context),

            const SizedBox(height: 28),

            Text(
              'Select Report Type',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 14),

            // Card 1: Monthly Report
            _buildReportCard(
              context,
              icon: Icons.calendar_month_rounded,
              title: 'Monthly Report',
              subtitle: 'Generate a complete report for a selected month.',
              badgeText: '${_monthNames[_selectedMonth - 1]} $_selectedMonthlyYear',
              accentGradient: const [Color(0xFF6E62FF), Color(0xFF574DEB)],
              onSelectClick: () => _openMonthlyPicker(context),
              onGenerateClick: () => _startGeneration(isMonthly: true),
            ),

            const SizedBox(height: 18),

            // Card 2: Yearly Report
            _buildReportCard(
              context,
              icon: Icons.analytics_rounded,
              title: 'Yearly Report',
              subtitle: 'Generate annual performance report.',
              badgeText: 'Year $_selectedYear',
              accentGradient: const [Color(0xFF00B4DB), Color(0xFF0083B0)],
              onSelectClick: () => _openYearlyPicker(context),
              onGenerateClick: () => _startGeneration(isMonthly: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSummaryCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [colors.surfaceContainerHighest, colors.surface]
              : [
                  const Color(0xFF574DEB).withValues(alpha: 0.08),
                  colors.surfaceContainerLowest,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '📊 Reports',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Generate detailed reports of your library including students, memberships, payments, occupancy and revenue.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // PDF Icon Illustration Graphic
          Container(
            width: 72,
            height: 88,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6E62FF), Color(0xFF574DEB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF574DEB).withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Colors.white,
                  size: 38,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String badgeText,
    required List<Color> accentGradient,
    required VoidCallback onSelectClick,
    required VoidCallback onGenerateClick,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onSelectClick,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: accentGradient),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: accentGradient.last.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Selection Chip + Action Row
                Row(
                  children: [
                    InkWell(
                      onTap: onSelectClick,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: accentGradient.first.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: accentGradient.first.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              badgeText,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: accentGradient.first,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: accentGradient.first,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: onGenerateClick,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentGradient.last,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: accentGradient.last.withValues(alpha: 0.4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.bolt_rounded, size: 18),
                      label: const Text(
                        'Generate',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openMonthlyPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MonthlySelectorSheet(
        initialMonth: _selectedMonth,
        initialYear: _selectedMonthlyYear,
        onSelected: (month, year) {
          setState(() {
            _selectedMonth = month;
            _selectedMonthlyYear = year;
          });
        },
      ),
    );
  }

  void _openYearlyPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => YearSelectorSheet(
        initialYear: _selectedYear,
        onSelected: (year) {
          setState(() {
            _selectedYear = year;
          });
        },
      ),
    );
  }

  Future<void> _startGeneration({required bool isMonthly}) async {
    // Show animated step-by-step progress dialog
    final ReportData? reportData = await showDialog<ReportData>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ReportGenerationDialog(
        isMonthly: isMonthly,
        selectedMonth: _selectedMonth,
        selectedYear: isMonthly ? _selectedMonthlyYear : _selectedYear,
        onFetchData: () async {
          final students = ref.read(studentsProvider);
          final seats = ref.read(seatsProvider);
          final ownerProfile = ref.read(ownerProfileProvider);

          return ReportGenerator.buildReport(
            isMonthly: isMonthly,
            selectedMonth: _selectedMonth,
            selectedYear: isMonthly ? _selectedMonthlyYear : _selectedYear,
            students: students,
            seats: seats,
            ownerProfile: ownerProfile,
          );
        },
      ),
    );

    if (reportData != null && mounted) {
      // Navigate to Report Preview Screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReportPreviewScreen(reportData: reportData),
        ),
      );
    }
  }
}
