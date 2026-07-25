import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/report_service.dart';

class YearlyReportSheet extends StatefulWidget {
  final String creationDateStr;
  final Function(DateTime startDate, DateTime endDate, String periodTitle) onGenerate;

  const YearlyReportSheet({
    super.key,
    required this.creationDateStr,
    required this.onGenerate,
  });

  @override
  State<YearlyReportSheet> createState() => _YearlyReportSheetState();
}

class _YearlyReportSheetState extends State<YearlyReportSheet> {
  late int _selectedYear;
  late DateTime _creationDate;

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
    _creationDate = ReportService.parseDate(widget.creationDateStr) ?? DateTime(2025, 1, 1);
  }

  bool get _isValidSelection {
    final endOfYear = DateTime(_selectedYear, 12, 31, 23, 59, 59);
    return !endOfYear.isBefore(_creationDate);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final formattedCreation = DateFormat('dd MMMM yyyy').format(_creationDate);

    final yearsList = List.generate(
      (DateTime.now().year - _creationDate.year + 3).clamp(1, 10),
      (index) => _creationDate.year + index,
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, color: colors.primary),
                const SizedBox(width: 10),
                Text(
                  'Yearly Report',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'Select Year',
              style: theme.textTheme.labelMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _selectedYear,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: yearsList.map((y) {
                return DropdownMenuItem<int>(
                  value: y,
                  child: Text('Year $y'),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedYear = val);
              },
            ),

            if (!_isValidSelection) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.errorContainer.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.error.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: colors.error, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'No data is available because your library was created on $formattedCreation.',
                        style: TextStyle(fontSize: 12, color: colors.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _isValidSelection
                        ? () {
                            Navigator.pop(context);
                            final startDate = DateTime(_selectedYear, 1, 1);
                            final endDate = DateTime(_selectedYear, 12, 31, 23, 59, 59);
                            final periodTitle = 'Year $_selectedYear';
                            widget.onGenerate(startDate, endDate, periodTitle);
                          }
                        : null,
                    child: const Text('Generate'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
