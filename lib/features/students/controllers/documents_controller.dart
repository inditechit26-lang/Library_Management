import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student_document.dart';

class DocumentsController extends Notifier<List<StudentDocument>> {
  final int studentId;
  DocumentsController(this.studentId);
  @override
  List<StudentDocument> build() => const [];
  void add(StudentDocument document) => state = [...state, document];
  void replace(String id, StudentDocument document) => state = [
    for (final item in state)
      if (item.id == id) document else item,
  ];
  void remove(String id) =>
      state = state.where((item) => item.id != id).toList();
}

final studentDocumentsProvider =
    NotifierProvider.family<DocumentsController, List<StudentDocument>, int>(
      DocumentsController.new,
    );
