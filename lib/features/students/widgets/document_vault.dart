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

    final otherDocs = docs.where(
      (d) =>
          d.type != StudentDocumentType.aadhaarFront &&
          d.type != StudentDocumentType.aadhaarBack &&
          d.type != StudentDocumentType.aadhaar,
    ).toList();

    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
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
              Icon(
                Icons.folder_copy_outlined,
                color: colors.primary,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Document Vault',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'Secure student documents',
                      style: TextStyle(
                        fontSize: 10,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: () => _pick(context, ref, null, docs),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Aadhaar Section (Max 2 Photos: Front & Back)
          _AadhaarVaultSection(
            documents: [
              ?aadhaarFront,
              ?aadhaarBack,
              if (aadhaarFront == null) ?legacyAadhaar,
            ],
            onAddOrReplace: () => _pickAadhaar(
              context,
              ref,
              frontDoc: aadhaarFront ?? legacyAadhaar,
              backDoc: aadhaarBack,
            ),
            onPreview: (doc) => _preview(context, doc),
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

          if (otherDocs.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Other Documents',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
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
          ] else if (aadhaarFront == null && aadhaarBack == null && legacyAadhaar == null) ...[
            const SizedBox(height: 12),
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

  Future<void> _pickAadhaar(
    BuildContext context,
    WidgetRef ref, {
    required StudentDocument? frontDoc,
    required StudentDocument? backDoc,
  }) async {
    final type = frontDoc == null
        ? StudentDocumentType.aadhaarFront
        : StudentDocumentType.aadhaarBack;
    final replacing = type == StudentDocumentType.aadhaarFront ? frontDoc : backDoc;
    final helperText = frontDoc == null
        ? 'Choose a clear card image. You can add one more image afterwards.'
        : backDoc == null
        ? 'Add the second image to complete this Aadhaar card.'
        : 'Choose a replacement image for this Aadhaar card.';

    await _pickWithType(
      context,
      ref,
      type,
      replacing,
      'Aadhaar Card',
      helperText,
    );
  }

  Future<void> _confirmRemoveAadhaar(
    BuildContext context,
    VoidCallback onConfirm,
  ) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Aadhaar card?'),
        content: const Text(
          'All images saved with this Aadhaar card will be removed from the student record.',
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
              for (final type in [
                StudentDocumentType.aadhaar,
                StudentDocumentType.collegeId,
                StudentDocumentType.passportPhoto,
                StudentDocumentType.other,
              ])
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

class _AadhaarVaultSection extends StatelessWidget {
  final List<StudentDocument> documents;
  final VoidCallback onAddOrReplace;
  final ValueChanged<StudentDocument> onPreview;
  final VoidCallback onDeleteAll;

  const _AadhaarVaultSection({
    required this.documents,
    required this.onAddOrReplace,
    required this.onPreview,
    required this.onDeleteAll,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hasDocuments = documents.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainer : const Color(0xFFF7F7FD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasDocuments
              ? colors.primary.withValues(alpha: 0.35)
              : colors.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.badge_outlined, size: 18, color: Color(0xFF514BC0)),
              const SizedBox(width: 6),
              Expanded(
                child: const Text(
                  'Aadhaar Card',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ),
              if (hasDocuments)
                PopupMenuButton<String>(
                  iconSize: 20,
                  onSelected: (value) {
                    if (value == 'replace') onAddOrReplace();
                    if (value == 'delete') onDeleteAll();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'replace', child: Text('Manage images')),
                    PopupMenuItem(value: 'delete', child: Text('Remove Aadhaar card')),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Optional',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            hasDocuments
                ? '${documents.length} of 2 images securely saved. Tap an image to preview it.'
                : 'Upload up to two images. They will stay together in one secure record.',
            style: TextStyle(fontSize: 11, height: 1.35, color: colors.onSurfaceVariant),
          ),
          if (hasDocuments) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 76,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: documents.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  final document = documents[index];
                  return InkWell(
                    onTap: () => onPreview(document),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 116,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colors.outlineVariant),
                      ),
                      child: document.isImage && File(document.path).existsSync()
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: Image.file(File(document.path), fit: BoxFit.cover),
                            )
                          : Icon(Icons.picture_as_pdf_outlined, color: colors.primary),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onAddOrReplace,
              icon: Icon(
                hasDocuments ? Icons.add_photo_alternate_outlined : Icons.upload_rounded,
                size: 18,
              ),
              label: Text(
                hasDocuments ? 'Add or replace image' : 'Upload Aadhaar images',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Retained for existing document preview layouts that may be restored later.
// ignore: unused_element
class _AadhaarSlotCard extends StatelessWidget {
  final String label;
  final StudentDocument? document;
  final VoidCallback onTap;
  // ignore: unused_element_parameter
  final VoidCallback? onPreview;
  // ignore: unused_element_parameter
  final VoidCallback? onDelete;

  // ignore: unused_element_parameter
  const _AadhaarSlotCard({
    required this.label,
    required this.document,
    required this.onTap,
    required this.onPreview,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isUploaded = document != null;

    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: isUploaded
            ? colors.surface
            : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUploaded
              ? colors.primary.withValues(alpha: 0.4)
              : colors.outlineVariant,
        ),
      ),
      child: isUploaded
          ? InkWell(
              onTap: onPreview,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            label,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          iconSize: 18,
                          onSelected: (val) {
                            if (val == 'preview') onPreview?.call();
                            if (val == 'replace') onTap();
                            if (val == 'delete') onDelete?.call();
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(value: 'preview', child: Text(context.tr('Preview'))),
                            PopupMenuItem(value: 'replace', child: Text(context.tr('Replace'))),
                            PopupMenuItem(value: 'delete', child: Text(context.tr('Delete'))),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (document!.isImage && File(document!.path).existsSync())
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.file(
                          File(document!.path),
                          height: 34,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Row(
                        children: [
                          Icon(
                            document!.isImage
                                ? Icons.image_outlined
                                : Icons.picture_as_pdf_outlined,
                            size: 16,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              document!.name,
                              style: TextStyle(
                                fontSize: 9,
                                color: colors.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            )
          : InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_a_photo_outlined,
                      size: 18,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '+ $label',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _EmptyVault extends StatelessWidget {
  const _EmptyVault();
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 32,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 6),
              const Text(
                'No other documents uploaded',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
              Text(
                'Add College ID, photos or PDFs',
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
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? colors.primaryContainer : const Color(0xFFF0EFFF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          document.isImage
              ? Icons.image_outlined
              : Icons.picture_as_pdf_outlined,
          color: isDark ? colors.onPrimaryContainer : const Color(0xFF514BC0),
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
}
