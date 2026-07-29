import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../students/controllers/students_controller.dart';
import '../../seats/controllers/seats_controller.dart';
import '../../settings/controllers/owner_profile_controller.dart';
import '../services/report_service.dart';
import '../widgets/monthly_report_sheet.dart';
import '../widgets/yearly_report_sheet.dart';
import '../widgets/custom_report_sheet.dart';
import 'report_preview_screen.dart';
import '../../settings/controllers/library_configuration_controller.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  void _generateAndNavigate({
    required BuildContext context,
    required WidgetRef ref,
    required String reportType,
    required String periodTitle,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final configuration = ref.read(libraryConfigurationProvider);
    final students = ref.read(studentsProvider).where((student) {
      return student.membership.name == 'halfTime'
          ? configuration.halfTimeEnabled
          : configuration.fullTimeEnabled;
    }).toList();
    final seats = ref.read(seatsProvider);
    final ownerProfile = ref.read(ownerProfileProvider);

    final reportData = ReportService.buildReportData(
      reportType: reportType,
      selectedPeriod: periodTitle,
      startDate: startDate,
      endDate: endDate,
      allStudents: students,
      allSeats: seats,
      ownerProfile: ownerProfile,
      sectionNames: {
        for (final section in configuration.sections) section.id: section.name,
      },
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportPreviewScreen(reportData: reportData),
      ),
    );
  }

  void _showMonthlySheet(
    BuildContext context,
    WidgetRef ref,
    String creationDate,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MonthlyReportSheet(
        creationDateStr: creationDate,
        onGenerate: (start, end, periodTitle) {
          _generateAndNavigate(
            context: context,
            ref: ref,
            reportType: 'Monthly Report',
            periodTitle: periodTitle,
            startDate: start,
            endDate: end,
          );
        },
      ),
    );
  }

  void _showYearlySheet(
    BuildContext context,
    WidgetRef ref,
    String creationDate,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => YearlyReportSheet(
        creationDateStr: creationDate,
        onGenerate: (start, end, periodTitle) {
          _generateAndNavigate(
            context: context,
            ref: ref,
            reportType: 'Yearly Report',
            periodTitle: periodTitle,
            startDate: start,
            endDate: end,
          );
        },
      ),
    );
  }

  void _showCustomSheet(
    BuildContext context,
    WidgetRef ref,
    String creationDate,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomReportSheet(
        creationDateStr: creationDate,
        onGenerate: (start, end, periodTitle) {
          _generateAndNavigate(
            context: context,
            ref: ref,
            reportType: 'Custom Report',
            periodTitle: periodTitle,
            startDate: start,
            endDate: end,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final ownerProfile = ref.watch(ownerProfileProvider);

    return Scaffold(
      backgroundColor: isDark ? colors.surface : const Color(0xFFF8F9FD),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? colors.surfaceContainerHighest : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: colors.onSurface,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: const Text(
          'Generate Reports',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 23,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF5145EA).withValues(alpha: 0.15)
                      : const Color(0xFF5145EA).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF5145EA).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF5145EA),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.analytics_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Create PDF reports of your library data.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? colors.onSurface
                              : const Color(0xFF2C324A),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Monthly Report Card
              _buildReportCard(
                context: context,
                icon: Icons.calendar_month_rounded,
                brandGradient: const LinearGradient(
                  colors: [Color(0xFF5145EA), Color(0xFF6C61F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                accentColor: const Color(0xFF5145EA),
                title: '📅 Monthly Report',
                description: 'Generate report for a selected month.',
                onPressed: () =>
                    _showMonthlySheet(context, ref, ownerProfile.joinDate),
              ),
              const SizedBox(height: 20),

              // Yearly Report Card
              _buildReportCard(
                context: context,
                icon: Icons.calendar_today_rounded,
                brandGradient: const LinearGradient(
                  colors: [Color(0xFF00B894), Color(0xFF00CEC9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                accentColor: const Color(0xFF00B894),
                title: '📆 Yearly Report',
                description: 'Generate report for a selected year.',
                onPressed: () =>
                    _showYearlySheet(context, ref, ownerProfile.joinDate),
              ),
              const SizedBox(height: 20),

              // Custom Report Card
              _buildReportCard(
                context: context,
                icon: Icons.description_rounded,
                brandGradient: const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                accentColor: const Color(0xFF6C5CE7),
                title: '📄 Custom Report',
                description: 'Generate report for any custom date range.',
                onPressed: () =>
                    _showCustomSheet(context, ref, ownerProfile.joinDate),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard({
    required BuildContext context,
    required IconData icon,
    required LinearGradient brandGradient,
    required Color accentColor,
    required String title,
    required String description,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? theme.colorScheme.outline.withValues(alpha: 0.35)
              : const Color(0xFFE6E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : const Color(0xFF1E2238).withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.15)
                : accentColor.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: brandGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? theme.colorScheme.onSurfaceVariant
                        : const Color(0xFF5A607F),
                    fontSize: 14.5,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: brandGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.28),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: onPressed,
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 17,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Generate',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
