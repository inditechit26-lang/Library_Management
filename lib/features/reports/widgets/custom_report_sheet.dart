import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/report_service.dart';

class CustomReportSheet extends StatefulWidget {
  final String creationDateStr;
  final Function(DateTime startDate, DateTime endDate, String periodTitle)
  onGenerate;

  const CustomReportSheet({
    super.key,
    required this.creationDateStr,
    required this.onGenerate,
  });

  @override
  State<CustomReportSheet> createState() => _CustomReportSheetState();
}

class _CustomReportSheetState extends State<CustomReportSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  late DateTime _creationDate;

  final DateFormat _displayFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _creationDate =
        ReportService.parseDate(widget.creationDateStr) ?? DateTime(2025, 1, 1);
    final now = DateTime.now();
    _startDate = now.isAfter(_creationDate)
        ? now.subtract(const Duration(days: 30))
        : _creationDate;
    if (_startDate!.isBefore(_creationDate)) {
      _startDate = _creationDate;
    }
    _endDate = now;
  }

  bool get _isValidRange {
    if (_startDate == null || _endDate == null) return false;
    if (_startDate!.isBefore(_creationDate)) return false;
    return !_endDate!.isBefore(_startDate!);
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate:
          _creationDate, // Enforce library creation date as earliest selectable date
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? _creationDate,
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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
                Icon(Icons.description_rounded, color: colors.primary),
                const SizedBox(width: 10),
                Text(
                  'Custom Report',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickStartDate,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Start Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _startDate != null
                            ? _displayFormat.format(_startDate!)
                            : 'Select',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _pickEndDate,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'End Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _endDate != null
                            ? _displayFormat.format(_endDate!)
                            : 'Select',
                      ),
                    ),
                  ),
                ),
              ],
            ),

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
                    onPressed: _isValidRange
                        ? () {
                            Navigator.pop(context);
                            final title =
                                '${_displayFormat.format(_startDate!)} - ${_displayFormat.format(_endDate!)}';
                            widget.onGenerate(_startDate!, _endDate!, title);
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
