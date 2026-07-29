import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/student_model.dart';
import '../repositories/students_repository.dart';

final studentsRepositoryProvider = Provider<BaseStudentsRepository>((ref) {
  return StudentsRepository();
});

final studentsStreamProvider = StreamProvider<List<StudentModel>>((ref) {
  final libraryId = ref.watch(currentLibraryIdProvider);
  if (libraryId == null || libraryId.isEmpty) {
    return Stream.value([]);
  }
  final repository = ref.watch(studentsRepositoryProvider);
  return repository.watchStudents(libraryId);
});

final studentsProvider = Provider<List<StudentModel>>((ref) {
  final asyncVal = ref.watch(studentsStreamProvider);
  return asyncVal.maybeWhen(data: (list) => list, orElse: () => []);
});

final activeStudentsCountProvider = Provider<int>((ref) {
  final students = ref.watch(studentsProvider);
  return students.where((s) => s.status == 'Active').length;
});
