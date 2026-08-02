import 'package:flutter/material.dart';
import '../../../core/settings/app_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../admissions/screens/admission_screen.dart';
import '../controllers/student_filter.dart';
import '../controllers/students_controller.dart';
import '../models/student.dart';
import '../widgets/empty_state.dart';
import '../widgets/filter_chips.dart';
import '../widgets/search_bar.dart';
import '../widgets/student_card.dart';
import '../widgets/summary_cards.dart';
import '../../settings/controllers/library_configuration_controller.dart';

class StudentsScreen extends ConsumerStatefulWidget {
  const StudentsScreen({super.key});
  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
  String query = '', filter = 'All';
  final Set<int> _selectedStudentIds = {};

  bool get _selectionMode => _selectedStudentIds.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final all = ref.watch(studentsProvider);
    final students = StudentFilter.apply(all, query: query, filter: filter);
    final configuration = ref.watch(libraryConfigurationProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _selectionMode
          ? FloatingActionButton(
              tooltip: 'Delete selected students',
              backgroundColor: Colors.red,
              onPressed: () => _deleteSelected(all),
              child: const Icon(Icons.delete_outline_rounded),
            )
          : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: _openAdmission,
                backgroundColor: Colors.transparent,
                elevation: 0,
                highlightElevation: 0,
                icon: const Icon(
                  Icons.person_add_alt_1_rounded,
                  color: Colors.white,
                ),
                label: Text(
                  context.tr('New Admission'),
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 108),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                StudentSummaryCards(students: all),
                const SizedBox(height: 20),
                if (_selectionMode) ...[
                  _SelectionToolbar(
                    count: _selectedStudentIds.length,
                    onClear: () => setState(_selectedStudentIds.clear),
                    onDelete: () => _deleteSelected(all),
                  ),
                  const SizedBox(height: 16),
                ],
                StudentSearchBar(
                  onChanged: (value) => setState(() => query = value),
                ),
                const SizedBox(height: 14),
                StudentFilterChips(
                  selected: filter,
                  fullTimeEnabled: configuration.fullTimeEnabled,
                  halfTimeEnabled: configuration.halfTimeEnabled,
                  onSelected: (value) => setState(() => filter = value),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Text(
                      '${students.length} students',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Updated just now',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (students.isEmpty)
                  const StudentsEmptyState()
                else
                  ...students.map(
                    (student) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: StudentCard(
                        student: student,
                        onOpen: () => _openStudent(student),
                        selectionMode: _selectionMode,
                        selected: _selectedStudentIds.contains(student.id),
                        onSelect: () => _toggleSelection(student.id),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _openAdmission() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => const AdmissionScreen(),
  );

  void _openStudent(Student student) => context.push('/students/${student.id}');

  void _toggleSelection(int studentId) => setState(() {
    if (!_selectedStudentIds.add(studentId)) {
      _selectedStudentIds.remove(studentId);
    }
  });

  Future<void> _deleteSelected(List<Student> students) async {
    final selected = students
        .where((student) => _selectedStudentIds.contains(student.id))
        .toList();
    if (selected.isEmpty) return;
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text('Delete ${selected.length} students?'),
            content: const Text(
              'The selected students will be removed from the active Students and Fees lists.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(dialogContext, true),
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Delete selected'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;

    try {
      await ref.read(studentsProvider.notifier).removeMany(selected);
      if (mounted) setState(_selectedStudentIds.clear);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to delete selected students.')),
      );
    }
  }
}

class _SelectionToolbar extends StatelessWidget {
  const _SelectionToolbar({
    required this.count,
    required this.onClear,
    required this.onDelete,
  });

  final int count;
  final VoidCallback onClear;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        '$count selected',
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
      const Spacer(),
      IconButton(
        tooltip: 'Clear selection',
        onPressed: onClear,
        icon: const Icon(Icons.close_rounded),
      ),
      IconButton(
        tooltip: 'Delete selected students',
        color: Colors.red,
        onPressed: onDelete,
        icon: const Icon(Icons.delete_outline_rounded),
      ),
    ],
  );
}
