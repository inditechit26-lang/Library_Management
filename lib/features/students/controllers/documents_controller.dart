import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/backend_providers.dart';
import '../models/student_document.dart';

class DocumentsController extends Notifier<List<StudentDocument>> {
  DocumentsController(this.studentId);
  final int studentId;

  @override
  List<StudentDocument> build() {
    final records = ref.watch(documentProvider).value ?? const [];
    return records
        .where((record) => record['studentId'] == studentId.toString())
        .map(_fromRecord)
        .toList();
  }

  void add(StudentDocument document) {
    state = [...state, document];
    unawaited(_save(document));
  }

  void replace(String id, StudentDocument document) {
    state = [
      for (final item in state)
        if (item.id == id) document else item,
    ];
    unawaited(_save(document));
  }

  void remove(String id) {
    state = state.where((item) => item.id != id).toList();
    unawaited(ref.read(documentRepositoryProvider).deleteDocument(id));
  }

  Future<void> _save(StudentDocument document) =>
      ref.read(documentRepositoryProvider).saveDocument(document.id, {
        'studentId': studentId.toString(),
        'name': document.name,
        'path': document.path,
        'uploadedAt': document.uploadedAt,
        'type': document.type.name,
        'isImage': document.isImage,
      });

  StudentDocument _fromRecord(Map<String, dynamic> record) {
    final typeName = record['type'] as String? ?? 'other';
    return StudentDocument(
      id: record['id'] as String? ?? '',
      name: record['name'] as String? ?? 'Document',
      path: record['path'] as String? ?? '',
      uploadedAt: record['uploadedAt'] as String? ?? '',
      type: StudentDocumentType.values.firstWhere(
        (type) => type.name == typeName,
        orElse: () => StudentDocumentType.other,
      ),
      isImage: record['isImage'] as bool? ?? false,
    );
  }
}

final studentDocumentsProvider =
    NotifierProvider.family<DocumentsController, List<StudentDocument>, int>(
      DocumentsController.new,
    );
