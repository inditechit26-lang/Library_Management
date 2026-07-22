import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/settings/app_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/documents_controller.dart';
import '../models/student_document.dart';
import '../services/document_service.dart';

class DocumentVault extends ConsumerWidget {
  final int studentId;
  const DocumentVault({super.key, required this.studentId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docs = ref.watch(studentDocumentsProvider(studentId));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A292C47),
            blurRadius: 28,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.folder_copy_outlined, color: Color(0xFF514BC0)),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Document Vault',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'Secure student documents',
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: () => _pick(context, ref, null),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (docs.isEmpty)
            const _EmptyVault()
          else
            ...docs.map(
              (doc) => _DocumentTile(
                document: doc,
                onPreview: () => _preview(context, doc),
                onReplace: () => _pick(context, ref, doc),
                onDelete: () => ref
                    .read(studentDocumentsProvider(studentId).notifier)
                    .remove(doc.id),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pick(
    BuildContext context,
    WidgetRef ref,
    StudentDocument? replacing,
  ) async {
    final type = replacing?.type ?? await _chooseType(context);
    if (type == null || !context.mounted) return;
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              title: Text(context.tr('Add document')),
              subtitle: Text(context.tr('Choose a source')),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(context.tr('Camera')),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_outlined),
              title: Text(context.tr('Gallery')),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: Text(context.tr('PDF or Image')),
              onTap: () => Navigator.pop(context, 'file'),
            ),
          ],
        ),
      ),
    );
    if (choice == null) return;
    final service = DocumentService();
    final picked = choice == 'camera'
        ? await service.fromCamera()
        : choice == 'gallery'
        ? await service.fromGallery()
        : await service.fromFiles();
    if (picked == null) return;
    final doc = StudentDocument(
      id: replacing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: _typeName(type),
      path: picked.path,
      uploadedAt: '18 Jul 2026',
      type: type,
      isImage: picked.isImage,
    );
    final notifier = ref.read(studentDocumentsProvider(studentId).notifier);
    replacing == null ? notifier.add(doc) : notifier.replace(replacing.id, doc);
  }

  Future<StudentDocumentType?> _chooseType(BuildContext context) =>
      showModalBottomSheet<StudentDocumentType>(
        context: context,
        builder: (sheet) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Document type',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                for (final type in StudentDocumentType.values)
                  ListTile(
                    leading: Icon(
                      type == StudentDocumentType.aadhaar
                          ? Icons.badge_outlined
                          : type == StudentDocumentType.collegeId
                          ? Icons.school_outlined
                          : type == StudentDocumentType.passportPhoto
                          ? Icons.photo_camera_front_outlined
                          : Icons.description_outlined,
                    ),
                    title: Text(_typeName(type)),
                    onTap: () => Navigator.pop(sheet, type),
                  ),
              ],
            ),
          ),
        ),
      );

  static String _typeName(StudentDocumentType type) => switch (type) {
    StudentDocumentType.aadhaar => 'Aadhaar Card',
    StudentDocumentType.collegeId => 'College ID',
    StudentDocumentType.passportPhoto => 'Passport Photo',
    StudentDocumentType.other => 'Other Document',
  };

  void _preview(BuildContext context, StudentDocument doc) => showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    doc.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            if (doc.isImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  File(doc.path),
                  height: 380,
                  fit: BoxFit.contain,
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.all(50),
                child: Column(
                  children: [
                    Icon(
                      Icons.picture_as_pdf_outlined,
                      size: 64,
                      color: Color(0xFF514BC0),
                    ),
                    SizedBox(height: 12),
                    Text('PDF document ready to view'),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _EmptyVault extends StatelessWidget {
  const _EmptyVault();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 22),
    child: Center(
      child: Column(
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            size: 38,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          const Text(
            'No documents uploaded',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          Text(
            'Add Aadhaar, College ID, photos or PDFs',
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );
}

class _DocumentTile extends StatelessWidget {
  final StudentDocument document;
  final VoidCallback onPreview, onReplace, onDelete;
  const _DocumentTile({
    required this.document,
    required this.onPreview,
    required this.onReplace,
    required this.onDelete,
  });
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF0EFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        document.isImage ? Icons.image_outlined : Icons.picture_as_pdf_outlined,
        color: const Color(0xFF514BC0),
      ),
    ),
    title: Text(document.name, maxLines: 1, overflow: TextOverflow.ellipsis),
    subtitle: Text(
      'Uploaded ${document.uploadedAt}',
      style: const TextStyle(fontSize: 10),
    ),
    trailing: PopupMenuButton<String>(
      onSelected: (value) => value == 'preview'
          ? onPreview()
          : value == 'replace'
          ? onReplace()
          : onDelete(),
      itemBuilder: (_) => [
        PopupMenuItem(value: 'preview', child: Text(context.tr('Preview'))),
        PopupMenuItem(value: 'replace', child: Text(context.tr('Replace'))),
        PopupMenuItem(value: 'delete', child: Text(context.tr('Delete'))),
      ],
    ),
  );
}
