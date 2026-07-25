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
          const SizedBox(height: 18),

          if (hasAadhaar) ...[
            _AadhaarVaultSection(
              frontDoc: effectiveFront,
              backDoc: effectiveBack,
              onPickAadhaar: () => _pickAadhaar(
                context,
                ref,
                frontDoc: effectiveFront,
                backDoc: effectiveBack,
              ),
              onPickSingleSlot: (type) => _pickSingleAadhaarSlot(
                context,
                ref,
                type,
                type == StudentDocumentType.aadhaarFront ? effectiveFront : effectiveBack,
              ),
              onPreview: (doc) => _preview(context, doc),
              onDeleteSlot: (doc) => ref
                  .read(studentDocumentsProvider(studentId).notifier)
                  .remove(doc.id),
              onDeleteAll: () => _confirmRemoveAadhaar(context, () {
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
          ],

          if (otherDocs.isNotEmpty) ...[
            if (hasAadhaar) const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Other Documents',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${otherDocs.length}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...otherDocs.map(
              (doc) => _DocumentTile(
                document: doc,
                onPreview: () => _preview(context, doc),
                onReplace: () => _pick(context, ref, doc, docs),
                onDelete: () => ref
                    .read(studentDocumentsProvider(studentId).notifier)
                    .remove(doc.id),
              ),
            ),
          ] else if (!hasAadhaar) ...[
            const SizedBox(height: 8),
            const _EmptyVault(),
          ],
        ],
      ),
    );
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
                          'Select up to 2 images (Front & Back side)',
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
                  'Automatically sets Front & Back images in order',
                  style: TextStyle(fontSize: 10.5),
                ),
                onTap: () => Navigator.pop(context, 'multi_gallery'),
              ),
              const SizedBox(height: 8),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text(
                  'Take Photo (Front Side)',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                onTap: () => Navigator.pop(context, 'camera_front'),
              ),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text(
                  'Take Photo (Back Side)',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                onTap: () => Navigator.pop(context, 'camera_back'),
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

      // 1st Image -> Front
      final frontPicked = pickedList[0];
      final docFront = StudentDocument(
        id: frontDoc?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        name: 'Aadhaar Card (Front)',
        path: frontPicked.path,
        uploadedAt: nowStr,
        type: StudentDocumentType.aadhaarFront,
        isImage: true,
      );
      frontDoc == null ? notifier.add(docFront) : notifier.replace(frontDoc.id, docFront);

      // 2nd Image -> Back (if selected)
      if (pickedList.length > 1) {
        final backPicked = pickedList[1];
        final docBack = StudentDocument(
          id: backDoc?.id ?? (DateTime.now().microsecondsSinceEpoch + 1).toString(),
          name: 'Aadhaar Card (Back)',
          path: backPicked.path,
          uploadedAt: nowStr,
          type: StudentDocumentType.aadhaarBack,
          isImage: true,
        );
        backDoc == null ? notifier.add(docBack) : notifier.replace(backDoc.id, docBack);
      }
    } else if (choice == 'camera_front') {
      await _pickSingleAadhaarSlot(
        context,
        ref,
        StudentDocumentType.aadhaarFront,
        frontDoc,
      );
    } else if (choice == 'camera_back') {
      await _pickSingleAadhaarSlot(
        context,
        ref,
        StudentDocumentType.aadhaarBack,
        backDoc,
      );
    }
  }

  Future<void> _pickSingleAadhaarSlot(
    BuildContext context,
    WidgetRef ref,
    StudentDocumentType type,
    StudentDocument? replacing,
  ) async {
    final label = type == StudentDocumentType.aadhaarFront ? 'Front Side' : 'Back Side';
    await _pickWithType(
      context,
      ref,
      type,
      replacing,
      'Aadhaar ($label)',
      'Upload image for Aadhaar $label',
    );
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
          'Both Front & Back images saved with this Aadhaar card will be removed from the student record.',
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
    StudentDocumentType.aadhaarFront => 'Aadhaar Card (Front)',
    StudentDocumentType.aadhaarBack => 'Aadhaar Card (Back)',
    StudentDocumentType.aadhaar => 'Aadhaar Card',
    StudentDocumentType.collegeId => 'College ID',
    StudentDocumentType.passportPhoto => 'Passport Photo',
    StudentDocumentType.other => 'Other Document',
  };

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
            if (doc.isImage)
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

class _AadhaarVaultSection extends StatelessWidget {
  final StudentDocument? frontDoc;
  final StudentDocument? backDoc;
  final VoidCallback onPickAadhaar;
  final ValueChanged<StudentDocumentType> onPickSingleSlot;
  final ValueChanged<StudentDocument> onPreview;
  final ValueChanged<StudentDocument> onDeleteSlot;
  final VoidCallback onDeleteAll;

  const _AadhaarVaultSection({
    required this.frontDoc,
    required this.backDoc,
    required this.onPickAadhaar,
    required this.onPickSingleSlot,
    required this.onPreview,
    required this.onDeleteSlot,
    required this.onDeleteAll,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final count = (frontDoc != null ? 1 : 0) + (backDoc != null ? 1 : 0);
    final isComplete = count == 2;
    final hasAny = count > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerLow : const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasAny
              ? colors.primary.withValues(alpha: 0.3)
              : colors.outlineVariant.withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.badge_outlined,
                size: 20,
                color: colors.primary,
              ),
              const SizedBox(width: 8),
              const Text(
                'Aadhaar Card',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isComplete
                      ? const Color(0xFFE8F5E9)
                      : hasAny
                          ? const Color(0xFFFFF3E0)
                          : colors.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count/2 Uploaded',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isComplete
                        ? const Color(0xFF2E7D32)
                        : hasAny
                            ? const Color(0xFFE65100)
                            : colors.primary,
                  ),
                ),
              ),
              const Spacer(),
              if (hasAny)
                PopupMenuButton<String>(
                  iconSize: 20,
                  onSelected: (value) {
                    if (value == 'upload') onPickAadhaar();
                    if (value == 'delete') onDeleteAll();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'upload', child: Text('Re-upload / Change')),
                    PopupMenuItem(value: 'delete', child: Text('Remove Aadhaar')),
                  ],
                )
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Keep front & back images uniform for instant verification.',
            style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 14),

          // Side-by-Side Uniform Cards
          Row(
            children: [
              Expanded(
                child: _UniformAadhaarCardSlot(
                  label: 'FRONT SIDE',
                  document: frontDoc,
                  onTap: () => frontDoc != null
                      ? onPreview(frontDoc!)
                      : onPickSingleSlot(StudentDocumentType.aadhaarFront),
                  onUpload: () => onPickSingleSlot(StudentDocumentType.aadhaarFront),
                  onDelete: frontDoc != null ? () => onDeleteSlot(frontDoc!) : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _UniformAadhaarCardSlot(
                  label: 'BACK SIDE',
                  document: backDoc,
                  onTap: () => backDoc != null
                      ? onPreview(backDoc!)
                      : onPickSingleSlot(StudentDocumentType.aadhaarBack),
                  onUpload: () => onPickSingleSlot(StudentDocumentType.aadhaarBack),
                  onDelete: backDoc != null ? () => onDeleteSlot(backDoc!) : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                side: BorderSide(color: colors.primary.withValues(alpha: 0.3)),
              ),
              onPressed: onPickAadhaar,
              icon: Icon(
                hasAny ? Icons.photo_library_outlined : Icons.file_upload_outlined,
                size: 17,
              ),
              label: Text(
                hasAny ? 'Select / Update 2 Images (Gallery)' : 'Upload Aadhaar (Max 2 Photos)',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UniformAadhaarCardSlot extends StatelessWidget {
  final String label;
  final StudentDocument? document;
  final VoidCallback onTap;
  final VoidCallback onUpload;
  final VoidCallback? onDelete;

  const _UniformAadhaarCardSlot({
    required this.label,
    required this.document,
    required this.onTap,
    required this.onUpload,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUploaded = document != null;

    return Container(
      height: 105,
      decoration: BoxDecoration(
        color: isUploaded
            ? (isDark ? colors.surface : Colors.white)
            : (isDark ? colors.surfaceContainer : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUploaded
              ? colors.primary.withValues(alpha: 0.4)
              : colors.outlineVariant.withValues(alpha: 0.6),
          width: isUploaded ? 1.5 : 1,
        ),
        boxShadow: isUploaded
            ? [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: isUploaded
          ? Stack(
              children: [
                Positioned.fill(
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: document!.isImage && File(document!.path).existsSync()
                          ? Image.file(
                              File(document!.path),
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: Icon(
                                Icons.picture_as_pdf_rounded,
                                color: colors.primary,
                                size: 32,
                              ),
                            ),
                    ),
                  ),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.45),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Top Tag
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                // Top Right Menu
                Positioned(
                  top: 4,
                  right: 4,
                  child: PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.white,
                      size: 18,
                    ),
                    padding: EdgeInsets.zero,
                    onSelected: (val) {
                      if (val == 'preview') onTap();
                      if (val == 'replace') onUpload();
                      if (val == 'delete') onDelete?.call();
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'preview', child: Text(context.tr('Preview'))),
                      PopupMenuItem(value: 'replace', child: Text(context.tr('Replace'))),
                      PopupMenuItem(value: 'delete', child: Text(context.tr('Delete'))),
                    ],
                  ),
                ),
                // Bottom Tap to view hint
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Row(
                    children: [
                      const Icon(Icons.remove_red_eye_outlined, size: 12, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        'Tap to view',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : InkWell(
              onTap: onUpload,
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_a_photo_rounded,
                        size: 20,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '+ $label',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: colors.primary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
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
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
              'No additional documents',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: colors.onSurface),
            ),
            const SizedBox(height: 2),
            Text(
              'Add College ID, Passport Photo or PDF files',
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
  final VoidCallback onPreview, onReplace, onDelete;
  const _DocumentTile({
    required this.document,
    required this.onPreview,
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
      ),
    );
  }
}
