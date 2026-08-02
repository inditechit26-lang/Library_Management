import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utils/formatters.dart';
import '../../auth/providers/auth_provider.dart';
import '../../students/providers/students_provider.dart';
import '../../students/services/student_data_service.dart';

enum ExportFormat { excel, csv, json }

class StudentDataManagementScreen extends ConsumerStatefulWidget {
  const StudentDataManagementScreen({super.key});

  @override
  ConsumerState<StudentDataManagementScreen> createState() =>
      _StudentDataManagementScreenState();
}

class _StudentDataManagementScreenState
    extends ConsumerState<StudentDataManagementScreen> {
  ExportFormat _selectedFormat = ExportFormat.excel;
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
      final extension = switch (_selectedFormat) {
        ExportFormat.excel => 'xlsx',
        ExportFormat.csv => 'csv',
        ExportFormat.json => 'json',
      };
      final fileName =
          'students_backup_${DateTime.now().millisecondsSinceEpoch}.$extension';

      if (_selectedFormat == ExportFormat.excel) {
        final bytes = service.exportToExcel(students);
        if (isShare) {
          final xFile = XFile.fromData(
            Uint8List.fromList(bytes),
            name: fileName,
            mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          );
          await Share.shareXFiles([xFile], text: 'Student Data Excel Backup');
        } else {
          final result = await FilePicker.platform.saveFile(
            dialogTitle: 'Save Student Data Excel File',
            fileName: fileName,
            bytes: Uint8List.fromList(bytes),
            type: FileType.custom,
            allowedExtensions: ['xlsx'],
          );
          if (result != null && mounted) {
            _showSuccessSnackBar(students.length, 'Excel (.xlsx)');
          }
        }
      } else {
        final content = _selectedFormat == ExportFormat.csv
            ? service.exportToCsv(students)
            : service.exportToJson(students);

        if (isShare) {
          final params = ShareParams(
            text: content,
            subject: 'Student Data Backup ($fileName)',
          );
          await SharePlus.instance.share(params);
        } else {
          final bytes = utf8.encode(content);
          final result = await FilePicker.platform.saveFile(
            dialogTitle: 'Save Student Data File',
            fileName: fileName,
            bytes: bytes,
            type: FileType.custom,
            allowedExtensions: [extension],
          );
          if (result != null && mounted) {
            _showSuccessSnackBar(students.length, extension.toUpperCase());
          }
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

  void _showSuccessSnackBar(int count, String formatLabel) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully exported $count student records to $formatLabel!'),
        backgroundColor: const Color(0xFF288C68),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleImport() async {
    final libraryId = ref.read(currentLibraryIdProvider) ?? 'default_library';
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'csv', 'json'],
      withData: true,
    );

    final file = result?.files.single;
    if (file == null || !mounted) return;

    final ext = file.extension?.toLowerCase() ?? '';
    final service = StudentDataService();
    ParsedImportResult parsedResult;

    if (ext == 'xlsx' || ext == 'xls') {
      final bytes = file.bytes;
      if (bytes == null) {
        _showErrorSnackBar('Unable to read Excel file bytes.');
        return;
      }
      parsedResult = service.parseExcel(bytes);
    } else {
      final content = file.bytes != null ? utf8.decode(file.bytes!) : '';
      if (content.isEmpty) {
        _showErrorSnackBar('File is empty.');
        return;
      }
      parsedResult = ext == 'csv'
          ? service.parseCsv(content)
          : service.parseJson(content);
    }

    if (!mounted) return;

    _showImportPreviewSheet(
      libraryId: libraryId,
      parsedResult: parsedResult,
      service: service,
    );
  }

  void _showErrorSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _downloadSampleExcelTemplate() async {
    final bytes = StudentDataService.generateSampleExcel();
    await FilePicker.platform.saveFile(
      dialogTitle: 'Save Sample Excel Template',
      fileName: 'student_import_template.xlsx',
      bytes: Uint8List.fromList(bytes),
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
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
        title: const Text('Student Excel & Data Backup'),
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
                    ? [const Color(0xFF1E3A2E), const Color(0xFF16251F)]
                    : [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.table_view_rounded,
                        color: Color(0xFF2E7D32),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Excel Student Data Suite',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Export or import full student details in Microsoft Excel (.xlsx) format.',
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
                      label: 'Primary Format',
                      value: 'Excel (.xlsx)',
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
                    const Icon(
                      Icons.file_download_outlined,
                      color: Color(0xFF2E7D32),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Export Student Excel Data',
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
                  'Download your complete student list in formatted Excel spreadsheet (.xlsx).',
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
                        label: 'Excel (.xlsx)',
                        icon: Icons.grid_on_rounded,
                        selected: _selectedFormat == ExportFormat.excel,
                        onTap: () => setState(
                          () => _selectedFormat = ExportFormat.excel,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _FormatChip(
                        label: 'CSV File',
                        icon: Icons.table_chart_outlined,
                        selected: _selectedFormat == ExportFormat.csv,
                        onTap: () => setState(
                          () => _selectedFormat = ExportFormat.csv,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _FormatChip(
                        label: 'JSON Data',
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
                        label: const Text('Export Excel File'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
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
                    const Icon(
                      Icons.file_upload_outlined,
                      color: Color(0xFF2E7D32),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Import Excel Student Records',
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
                  'Upload an Excel (.xlsx) file to batch import student profiles into your library database.',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),

                OutlinedButton.icon(
                  onPressed: _downloadSampleExcelTemplate,
                  icon: const Icon(Icons.description_outlined, size: 18),
                  label: const Text('Download Sample Excel Template (.xlsx)'),
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
                    label: const Text('Select Excel File to Import'),
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
            Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
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
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF2E7D32).withValues(alpha: 0.15)
                : colors.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? const Color(0xFF2E7D32)
                  : colors.outlineVariant.withValues(alpha: 0.5),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? const Color(0xFF2E7D32) : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? const Color(0xFF2E7D32) : colors.onSurfaceVariant,
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
            'Excel Import Audit & Validation',
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
              color: const Color(0xFF2E7D32),
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
                    backgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                    child: Text(
                      student.name.isNotEmpty ? student.name[0] : 'S',
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
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
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
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
