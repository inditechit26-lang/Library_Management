import 'dart:async';
import 'package:flutter/material.dart';
import '../models/report_data.dart';

class ReportGenerationDialog extends StatefulWidget {
  final bool isMonthly;
  final int selectedMonth;
  final int selectedYear;
  final Future<ReportData> Function() onFetchData;

  const ReportGenerationDialog({
    super.key,
    required this.isMonthly,
    required this.selectedMonth,
    required this.selectedYear,
    required this.onFetchData,
  });

  @override
  State<ReportGenerationDialog> createState() => _ReportGenerationDialogState();
}

class _ReportGenerationDialogState extends State<ReportGenerationDialog> {
  int _currentStepIndex = 0;
  double _progress = 0.0;
  ReportData? _resultData;

  final List<String> _steps = [
    'Collecting Students Data...',
    'Preparing Payments & Receipts...',
    'Calculating Revenue & Deposits...',
    'Generating Charts & Seat Analytics...',
    'Creating Business PDF Report...',
    'Almost Ready...',
  ];

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    final reportTask = widget.onFetchData();

    for (int i = 0; i < _steps.length; i++) {
      if (!mounted) return;
      setState(() {
        _currentStepIndex = i;
        _progress = (i + 1) / _steps.length;
      });
      await Future.delayed(const Duration(milliseconds: 320));
    }

    _resultData = await reportTask;

    if (mounted) {
      Navigator.of(context).pop(_resultData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 10,
      backgroundColor: colors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF574DEB).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.5,
                    color: Color(0xFF574DEB),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Generating Business Report',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 6),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _steps[_currentStepIndex],
                key: ValueKey<int>(_currentStepIndex),
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 22),

            // Animated progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 8,
                backgroundColor: colors.surfaceContainerHighest,
                color: const Color(0xFF574DEB),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
