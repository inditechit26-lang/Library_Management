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
    final all = ref.watch(studentsProvider);
    final students = StudentFilter.apply(all, query: query, filter: filter);
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAdmission,
        icon: const Icon(Icons.add),
        label: Text(context.tr('New Admission')),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                StudentSummaryCards(students: all),
                const SizedBox(height: 20),
                StudentSearchBar(
                  onChanged: (value) => setState(() => query = value),
                ),
                const SizedBox(height: 10),
                StudentFilterChips(
                  selected: filter,
                  onSelected: (value) => setState(() => filter = value),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Text(
                      '${students.length} students',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Updated just now',
                      style: TextStyle(fontSize: 9, color: Color(0xFF9BA0AF)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (students.isEmpty)
                  const StudentsEmptyState()
                else
                  ...students.map(
                    (student) => Padding(
                      padding: const EdgeInsets.only(bottom: 9),
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
