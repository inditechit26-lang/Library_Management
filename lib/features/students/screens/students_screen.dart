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

class StudentsScreen extends ConsumerStatefulWidget {
  const StudentsScreen({super.key});
  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
  String query = '', filter = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final all = ref.watch(studentsProvider);
    final students = StudentFilter.apply(all, query: query, filter: filter);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF6366F1),
              Color(0xFF4F46E5),
            ],
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
          icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
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
                StudentSearchBar(
                  onChanged: (value) => setState(() => query = value),
                ),
                const SizedBox(height: 14),
                StudentFilterChips(
                  selected: filter,
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
}
