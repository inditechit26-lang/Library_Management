import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
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
    final aadhaarFront = docs.cast<StudentDocument?>().firstWhere(
      (d) => d?.type == StudentDocumentType.aadhaarFront,
      orElse: () => null,
    );
    final aadhaarBack = docs.cast<StudentDocument?>().firstWhere(
      (d) => d?.type == StudentDocumentType.aadhaarBack,
      orElse: () => null,
    );
    final legacyAadhaar = docs.cast<StudentDocument?>().firstWhere(
      (d) => d?.type == StudentDocumentType.aadhaar,
      orElse: () => null,
    );

    final effectiveFront = aadhaarFront ?? legacyAadhaar;
    final effectiveBack = aadhaarBack;
    final hasAadhaar = effectiveFront != null || effectiveBack != null;

    final otherDocs = docs.where(
      (d) =>
          d.type != StudentDocumentType.aadhaarFront &&
          d.type != StudentDocumentType.aadhaarBack &&
          d.type != StudentDocumentType.aadhaar,
    ).toList();

    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isEmpty = !hasAadhaar && otherDocs.isEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? colors.surface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? colors.outline.withValues(alpha: 0.35)
              : const Color(0xFFE6E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : const Color(0xFF1E2238).withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.folder_special_rounded,
                  color: colors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Document Vault',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Verified student identification & records',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _pick(context, ref, null, docs),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 16, color: colors.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (isEmpty) ...[
            const _EmptyVault(),
          ] else ...[
            if (hasAadhaar)
              _AadhaarTile(
                frontDoc: effectiveFront,
                backDoc: effectiveBack,
                onPreview: () => _previewAadhaar(context, effectiveFront, effectiveBack),
                onDownload: () => _downloadAadhaar(context, effectiveFront, effectiveBack),
                onReupload: () => _pickAadhaar(
                  context,
                  ref,
                  frontDoc: effectiveFront,
                  backDoc: effectiveBack,
                ),
                onDelete: () => _confirmRemoveAadhaar(context, () {
                  final notifier = ref.read(studentDocumentsProvider(studentId).notifier);
                  for (final doc in [
                    aadhaarFront,
                    aadhaarBack,
                    legacyAadhaar,
                  ].whereType<StudentDocument>()) {
                    notifier.remove(doc.id);
                  }
                }),
              ),

            ...otherDocs.map(
              (doc) => _DocumentTile(
                document: doc,
                onPreview: () => _preview(context, doc),
                onDownload: () => _downloadDocument(context, doc),
                onReplace: () => _pick(context, ref, doc, docs),
                onDelete: () => ref
                    .read(studentDocumentsProvider(studentId).notifier)
                    .remove(doc.id),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _downloadDocument(BuildContext context, StudentDocument doc) async {
    final file = File(doc.path);
    if (!file.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Document file "${doc.name}" not found locally.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${doc.name}...'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
    // ignore: deprecated_member_use
    await Share.shareXFiles([XFile(doc.path)], text: doc.name);
  }

  Future<void> _downloadAadhaar(
    BuildContext context,
    StudentDocument? frontDoc,
    StudentDocument? backDoc,
  ) async {
    final docs = [frontDoc, backDoc].whereType<StudentDocument>().toList();
    final xFiles = <XFile>[];
    for (final d in docs) {
      if (File(d.path).existsSync()) {
        xFiles.add(XFile(d.path));
      }
    }
    if (xFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aadhaar card image files not found locally.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Downloading Aadhaar Card...'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
    // ignore: deprecated_member_use
    await Share.shareXFiles(xFiles, text: 'Aadhaar Card');
  }

  Future<void> _pick(
    BuildContext context,
    WidgetRef ref,
    StudentDocument? replacing,
    List<StudentDocument> docs,
  ) async {
    final type = replacing?.type ?? await _chooseType(context, docs);
    if (type == null || !context.mounted) return;

    if (type == StudentDocumentType.aadhaar) {
      final frontDoc = docs.cast<StudentDocument?>().firstWhere(
        (d) =>
            d?.type == StudentDocumentType.aadhaarFront ||
            d?.type == StudentDocumentType.aadhaar,
        orElse: () => null,
      );
      final backDoc = docs.cast<StudentDocument?>().firstWhere(
        (d) => d?.type == StudentDocumentType.aadhaarBack,
        orElse: () => null,
      );
      await _pickAadhaar(context, ref, frontDoc: frontDoc, backDoc: backDoc);
      return;
    }

    StudentDocument? targetReplacing = replacing;
    if (targetReplacing == null) {
      if (type == StudentDocumentType.aadhaarFront) {
        targetReplacing = docs.cast<StudentDocument?>().firstWhere(
          (d) => d?.type == StudentDocumentType.aadhaarFront,
          orElse: () => null,
        );
      } else if (type == StudentDocumentType.aadhaarBack) {
        targetReplacing = docs.cast<StudentDocument?>().firstWhere(
          (d) => d?.type == StudentDocumentType.aadhaarBack,
          orElse: () => null,
        );
      }
    }

    await _pickWithType(context, ref, type, targetReplacing, null, null);
  }

  Future<void> _pickAadhaar(
    BuildContext context,
    WidgetRef ref, {
    required StudentDocument? frontDoc,
    required StudentDocument? backDoc,
  }) async {
    final colors = Theme.of(context).colorScheme;

    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.badge_rounded, color: colors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Upload Aadhaar Card',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Select up to 2 images from Gallery or Camera',
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                tileColor: colors.primaryContainer.withValues(alpha: 0.4),
                leading: Icon(Icons.photo_library_rounded, color: colors.primary),
                title: const Text(
                  'Gallery (Select up to 2 images)',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                subtitle: const Text(
                  'Multi-select up to 2 images at once',
                  style: TextStyle(fontSize: 10.5),
                ),
                onTap: () => Navigator.pop(context, 'multi_gallery'),
              ),
              const SizedBox(height: 8),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text(
                  'Take Photo with Camera',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                onTap: () => Navigator.pop(context, 'camera'),
              ),
            ],
          ),
        ),
      ),
    );

    if (choice == null || !context.mounted) return;
    final service = DocumentService();

    if (choice == 'multi_gallery') {
      final pickedList = await service.multiFromGallery(maxImages: 2);
      if (pickedList.isEmpty) return;

      final notifier = ref.read(studentDocumentsProvider(studentId).notifier);
      final nowStr = '18 Jul 2026';

      final frontPicked = pickedList[0];
      final docFront = StudentDocument(
        id: frontDoc?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        name: 'Aadhaar Card (Page 1)',
        path: frontPicked.path,
        uploadedAt: nowStr,
        type: StudentDocumentType.aadhaarFront,
        isImage: true,
      );
      frontDoc == null ? notifier.add(docFront) : notifier.replace(frontDoc.id, docFront);

      if (pickedList.length > 1) {
        final backPicked = pickedList[1];
        final docBack = StudentDocument(
          id: backDoc?.id ?? (DateTime.now().microsecondsSinceEpoch + 1).toString(),
          name: 'Aadhaar Card (Page 2)',
          path: backPicked.path,
          uploadedAt: nowStr,
          type: StudentDocumentType.aadhaarBack,
          isImage: true,
        );
        backDoc == null ? notifier.add(docBack) : notifier.replace(backDoc.id, docBack);
      }
    } else if (choice == 'camera') {
      final picked = await service.fromCamera();
      if (picked == null) return;
      final notifier = ref.read(studentDocumentsProvider(studentId).notifier);
      final doc = StudentDocument(
        id: frontDoc?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        name: 'Aadhaar Card',
        path: picked.path,
        uploadedAt: '18 Jul 2026',
        type: frontDoc == null ? StudentDocumentType.aadhaarFront : StudentDocumentType.aadhaarBack,
        isImage: true,
      );
      frontDoc == null ? notifier.add(doc) : notifier.replace(frontDoc.id, doc);
    }
  }

  Future<void> _pickWithType(
    BuildContext context,
    WidgetRef ref,
    StudentDocumentType type,
    StudentDocument? replacing,
    String? displayName,
    String? helperText,
  ) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              title: Text('${context.tr('Add')} ${displayName ?? _typeName(type)}'),
              subtitle: Text(helperText ?? context.tr('Choose a source')),
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
            if (displayName != 'Aadhaar Card')
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
      name: displayName ?? _typeName(type),
      path: picked.path,
      uploadedAt: '18 Jul 2026',
      type: type,
      isImage: picked.isImage,
    );
    final notifier = ref.read(studentDocumentsProvider(studentId).notifier);
    replacing == null ? notifier.add(doc) : notifier.replace(replacing.id, doc);
  }

  Future<void> _confirmRemoveAadhaar(
    BuildContext context,
    VoidCallback onConfirm,
  ) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Aadhaar card?'),
        content: const Text(
          'Both saved pages of this Aadhaar card will be removed from the student record.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (shouldRemove == true) onConfirm();
  }

  Future<StudentDocumentType?> _chooseType(
    BuildContext context,
    List<StudentDocument> docs,
  ) {
    return showModalBottomSheet<StudentDocumentType>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Document type',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              for (final type in [
                StudentDocumentType.aadhaar,
                StudentDocumentType.collegeId,
                StudentDocumentType.passportPhoto,
                StudentDocumentType.other,
              ])
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  leading: Icon(
                    type == StudentDocumentType.aadhaar
                        ? Icons.badge_outlined
                        : type == StudentDocumentType.collegeId
                        ? Icons.school_outlined
                        : type == StudentDocumentType.passportPhoto
                        ? Icons.photo_camera_front_outlined
                        : Icons.description_outlined,
                  ),
                  title: Text(
                    _typeName(type),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () => Navigator.pop(sheet, type),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static String _typeName(StudentDocumentType type) => switch (type) {
    StudentDocumentType.aadhaarFront => 'Aadhaar Card (Page 1)',
    StudentDocumentType.aadhaarBack => 'Aadhaar Card (Page 2)',
    StudentDocumentType.aadhaar => 'Aadhaar Card',
    StudentDocumentType.collegeId => 'College ID',
    StudentDocumentType.passportPhoto => 'Passport Photo',
    StudentDocumentType.other => 'Other Document',
  };

  void _previewAadhaar(
    BuildContext context,
    StudentDocument? frontDoc,
    StudentDocument? backDoc,
  ) {
    final docs = [frontDoc, backDoc].whereType<StudentDocument>().toList();
    if (docs.isEmpty) return;

    showDialog(
      context: context,
      builder: (_) => _MultiDocumentPreviewDialog(documents: docs),
    );
  }

  void _preview(BuildContext context, StudentDocument doc) => showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (doc.isImage && File(doc.path).existsSync())
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(doc.path),
                  height: 360,
                  fit: BoxFit.contain,
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.picture_as_pdf_rounded,
                      size: 64,
                      color: Color(0xFF514BC0),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'PDF document ready to view',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _AadhaarTile extends StatelessWidget {
  final StudentDocument? frontDoc;
  final StudentDocument? backDoc;
  final VoidCallback onPreview;
  final VoidCallback onDownload;
  final VoidCallback onReupload;
  final VoidCallback onDelete;

  const _AadhaarTile({
    required this.frontDoc,
    required this.backDoc,
    required this.onPreview,
    required this.onDownload,
    required this.onReupload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final count = (frontDoc != null ? 1 : 0) + (backDoc != null ? 1 : 0);
    final uploadedAt = frontDoc?.uploadedAt ?? backDoc?.uploadedAt ?? '18 Jul 2026';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerLow : const Color(0xFFF9FAFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: ListTile(
        onTap: onPreview,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.badge_rounded,
            color: colors.primary,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            const Text(
              'Aadhaar Card',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count ${count == 1 ? 'page' : 'pages'}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          'Uploaded $uploadedAt',
          style: TextStyle(fontSize: 10.5, color: colors.onSurfaceVariant),
        ),
        trailing: PopupMenuButton<String>(
          iconSize: 20,
          onSelected: (value) {
            if (value == 'preview') onPreview();
            if (value == 'download') onDownload();
            if (value == 'reupload') onReupload();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'preview',
              child: Row(
                children: [
                  const Icon(Icons.remove_red_eye_outlined, size: 18),
                  const SizedBox(width: 10),
                  Text(context.tr('Preview')),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'download',
              child: Row(
                children: [
                  const Icon(Icons.download_rounded, size: 18),
                  const SizedBox(width: 10),
                  const Text('Download'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'reupload',
              child: Row(
                children: [
                  const Icon(Icons.sync_rounded, size: 18),
                  const SizedBox(width: 10),
                  const Text('Re-upload'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                  const SizedBox(width: 10),
                  Text(context.tr('Delete'), style: const TextStyle(color: Colors.redAccent)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MultiDocumentPreviewDialog extends StatefulWidget {
  final List<StudentDocument> documents;
  const _MultiDocumentPreviewDialog({required this.documents});

  @override
  State<_MultiDocumentPreviewDialog> createState() => _MultiDocumentPreviewDialogState();
}

class _MultiDocumentPreviewDialogState extends State<_MultiDocumentPreviewDialog> {
  int _currentPage = 0;
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final docs = widget.documents;

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Aadhaar Card',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      if (docs.length > 1)
                        Text(
                          'Page ${_currentPage + 1} of ${docs.length}',
                          style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 360,
              child: PageView.builder(
                controller: _controller,
                itemCount: docs.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: doc.isImage && File(doc.path).existsSync()
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              File(doc.path),
                              fit: BoxFit.contain,
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.picture_as_pdf_rounded,
                              size: 64,
                              color: colors.primary,
                            ),
                          ),
                  );
                },
              ),
            ),
            if (docs.length > 1) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  docs.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == i ? 18 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == i
                          ? colors.primary
                          : colors.outlineVariant.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyVault extends StatelessWidget {
  const _EmptyVault();
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 32,
              color: colors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 8),
            Text(
              'No documents uploaded',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: colors.onSurface),
            ),
            const SizedBox(height: 2),
            Text(
              'Tap "+ Add" to upload Aadhaar Card, College ID or files',
              style: TextStyle(
                fontSize: 11,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final StudentDocument document;
  final VoidCallback onPreview, onDownload, onReplace, onDelete;
  const _DocumentTile({
    required this.document,
    required this.onPreview,
    required this.onDownload,
    required this.onReplace,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerLow : const Color(0xFFF9FAFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: ListTile(
        onTap: onPreview,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            document.isImage
                ? Icons.image_outlined
                : Icons.picture_as_pdf_outlined,
            color: colors.primary,
            size: 20,
          ),
        ),
        title: Text(
          document.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        subtitle: Text(
          'Uploaded ${document.uploadedAt}',
          style: TextStyle(fontSize: 10.5, color: colors.onSurfaceVariant),
        ),
        trailing: PopupMenuButton<String>(
          iconSize: 20,
          onSelected: (value) {
            if (value == 'preview') onPreview();
            if (value == 'download') onDownload();
            if (value == 'replace') onReplace();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'preview',
              child: Row(
                children: [
                  const Icon(Icons.remove_red_eye_outlined, size: 18),
                  const SizedBox(width: 10),
                  Text(context.tr('Preview')),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'download',
              child: Row(
                children: [
                  const Icon(Icons.download_rounded, size: 18),
                  const SizedBox(width: 10),
                  const Text('Download'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'replace',
              child: Row(
                children: [
                  const Icon(Icons.sync_rounded, size: 18),
                  const SizedBox(width: 10),
                  Text(context.tr('Replace')),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                  const SizedBox(width: 10),
                  Text(context.tr('Delete'), style: const TextStyle(color: Colors.redAccent)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
