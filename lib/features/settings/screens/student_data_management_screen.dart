import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utils/formatters.dart';
import '../../auth/providers/auth_provider.dart';
import '../../students/models/student_model.dart';
import '../../students/providers/students_provider.dart';
import '../../students/services/student_data_service.dart';

enum ExportFormat { csv, json }

class StudentDataManagementScreen extends ConsumerStatefulWidget {
  const StudentDataManagementScreen({super.key});

  @override
  ConsumerState<StudentDataManagementScreen> createState() =>
      _StudentDataManagementScreenState();
}

class _StudentDataManagementScreenState
    extends ConsumerState<StudentDataManagementScreen> {
  ExportFormat _selectedFormat = ExportFormat.csv;
  bool _isExporting = false;
  bool _isImporting = false;

  Future<void> _handleExport({bool isShare = false}) async {
    final libraryId = ref.read(currentLibraryIdProvider) ?? 'default_library';
    setState(() => _isExporting = true);

    try {
      final repository = ref.read(studentsRepositoryProvider);
      final students = await repository.getStudents(libraryId, limit: 1000);

      if (students.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No student records found to export.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _isExporting = false);
        return;
      }

      final service = StudentDataService();
      final content = _selectedFormat == ExportFormat.csv
          ? service.exportToCsv(students)
          : service.exportToJson(students);

      final extension = _selectedFormat == ExportFormat.csv ? 'csv' : 'json';
      final fileName =
          'students_backup_${DateTime.now().millisecondsSinceEpoch}.$extension';

      if (isShare) {
        final params = ShareParams(
          text: content,
          subject: 'Student Data Backup ($fileName)',
        );
        await SharePlus.instance.share(params);
      } else {
        final bytes = utf8.encode(content);
        final result = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Student Data Backup',
          fileName: fileName,
          bytes: bytes,
          type: FileType.custom,
          allowedExtensions: [extension],
        );

        if (result != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully exported ${students.length} student records!'),
              backgroundColor: const Color(0xFF288C68),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _handleImport() async {
    final libraryId = ref.read(currentLibraryIdProvider) ?? 'default_library';
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'json'],
      withData: true,
    );

    final file = result?.files.single;
    if (file == null || !mounted) return;

    String content = '';
    if (file.bytes != null) {
      content = utf8.decode(file.bytes!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to read file content.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final service = StudentDataService();
    final isCsv = file.extension?.toLowerCase() == 'csv';
    final parsedResult =
        isCsv ? service.parseCsv(content) : service.parseJson(content);

    if (!mounted) return;

    _showImportPreviewSheet(
      libraryId: libraryId,
      parsedResult: parsedResult,
      service: service,
    );
  }

  void _downloadSampleTemplate() async {
    final content = StudentDataService.generateSampleCsv();
    final bytes = utf8.encode(content);
    await FilePicker.platform.saveFile(
      dialogTitle: 'Save Sample CSV Template',
      fileName: 'student_import_template.csv',
      bytes: bytes,
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
  }

  void _showImportPreviewSheet({
    required String libraryId,
    required ParsedImportResult parsedResult,
    required StudentDataService service,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ImportPreviewSheet(
        libraryId: libraryId,
        parsedResult: parsedResult,
        service: service,
        onImportComplete: () {
          ref.invalidate(studentsProvider);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Imported ${parsedResult.validStudents.length} student records successfully!',
                ),
                backgroundColor: const Color(0xFF288C68),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final students = ref.watch(studentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Data Backup & Import'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF252A36), const Color(0xFF1B1F2A)]
                    : [const Color(0xFFEEF2FE), const Color(0xFFE2E9FB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.swap_vert_circle_outlined,
                        color: colors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Data Backup & Transfer Suite',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Seamlessly export or bulk import library student records.',
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
                Row(
                  children: [
                    _StatBadge(
                      icon: Icons.people_outline_rounded,
                      label: 'Total Students',
                      value: '${students.length} Records',
                    ),
                    const SizedBox(width: 12),
                    const _StatBadge(
                      icon: Icons.verified_outlined,
                      label: 'Formats',
                      value: 'CSV & JSON',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Export Section Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.file_download_outlined,
                      color: colors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Export Student Records',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Download your active student list to standard CSV spreadsheet or structured JSON.',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),

                // Format Selector Chips
                Row(
                  children: [
                    Expanded(
                      child: _FormatChip(
                        label: 'CSV Spreadsheet',
                        icon: Icons.table_chart_outlined,
                        selected: _selectedFormat == ExportFormat.csv,
                        onTap: () => setState(
                          () => _selectedFormat = ExportFormat.csv,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _FormatChip(
                        label: 'JSON Data Backup',
                        icon: Icons.code_rounded,
                        selected: _selectedFormat == ExportFormat.json,
                        onTap: () => setState(
                          () => _selectedFormat = ExportFormat.json,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _isExporting
                            ? null
                            : () => _handleExport(isShare: false),
                        icon: _isExporting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.download_rounded),
                        label: const Text('Export File'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: _isExporting
                          ? null
                          : () => _handleExport(isShare: true),
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Share'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Import Section Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.file_upload_outlined,
                      color: colors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Bulk Import Students',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Upload a CSV or JSON file to batch import student profiles into your library.',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),

                OutlinedButton.icon(
                  onPressed: _downloadSampleTemplate,
                  icon: const Icon(Icons.description_outlined, size: 18),
                  label: const Text('Download Sample CSV Template'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isImporting ? null : _handleImport,
                    icon: const Icon(Icons.drive_folder_upload_rounded),
                    label: const Text('Select File to Import'),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.secondaryContainer,
                      foregroundColor: colors.onSecondaryContainer,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
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
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatBadge({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: colors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _FormatChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? colors.primary.withValues(alpha: 0.12)
                : colors.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? colors.primary
                  : colors.outlineVariant.withValues(alpha: 0.5),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? colors.primary : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImportPreviewSheet extends StatefulWidget {
  final String libraryId;
  final ParsedImportResult parsedResult;
  final StudentDataService service;
  final VoidCallback onImportComplete;

  const _ImportPreviewSheet({
    required this.libraryId,
    required this.parsedResult,
    required this.service,
    required this.onImportComplete,
  });

  @override
  State<_ImportPreviewSheet> createState() => _ImportPreviewSheetState();
}

class _ImportPreviewSheetState extends State<_ImportPreviewSheet> {
  bool _isImporting = false;
  int _processed = 0;

  Future<void> _confirmImport() async {
    if (widget.parsedResult.validStudents.isEmpty) return;
    setState(() {
      _isImporting = true;
      _processed = 0;
    });

    try {
      await widget.service.batchImportStudents(
        libraryId: widget.libraryId,
        students: widget.parsedResult.validStudents,
        onProgress: (processed, total) {
          if (mounted) setState(() => _processed = processed);
        },
      );

      if (!mounted) return;
      Navigator.pop(context);
      widget.onImportComplete();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import error: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
      setState(() => _isImporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final validList = widget.parsedResult.validStudents;
    final total = validList.length;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: colors.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Import Audit & Validation',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            'Review records before committing to your library database.',
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),

          // Audit Summary Row
          Row(
            children: [
              _AuditCard(
                label: 'Valid Records',
                value: '$total',
                color: Colors.green,
              ),
              const SizedBox(width: 10),
              _AuditCard(
                label: 'Skipped Rows',
                value: '${widget.parsedResult.errorMessages.length}',
                color: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_isImporting) ...[
            LinearProgressIndicator(
              value: total > 0 ? _processed / total : 0,
              backgroundColor: colors.surfaceContainerHighest,
            ),
            const SizedBox(height: 8),
            Text(
              'Importing $_processed of $total records...',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
          ],

          const Text(
            'Parsed Student Preview',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: ListView.separated(
              itemCount: validList.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, idx) {
                final student = validList[idx];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: colors.primaryContainer,
                    child: Text(
                      student.name.isNotEmpty ? student.name[0] : 'S',
                      style: TextStyle(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    student.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    '${student.phone} · Seat ${student.assignedSeat ?? 'Flexible'} · ${money(student.monthlyFee)}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Ready',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.green,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isImporting || total == 0 ? null : _confirmImport,
              icon: const Icon(Icons.check_circle_outline),
              label: Text('Import $total Student Records'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _AuditCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
