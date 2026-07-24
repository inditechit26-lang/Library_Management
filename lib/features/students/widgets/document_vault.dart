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
            studentId: studentId,
            frontDoc: aadhaarFront,
            backDoc: aadhaarBack,
            legacyDoc: legacyAadhaar,
            onAddOrReplaceFront: () => _pickWithType(
              context,
              ref,
              StudentDocumentType.aadhaarFront,
              aadhaarFront ?? legacyAadhaar,
            ),
            onAddOrReplaceBack: () => _pickWithType(
              context,
              ref,
              StudentDocumentType.aadhaarBack,
              aadhaarBack,
            ),
            onPreview: (doc) => _preview(context, doc),
            onDelete: (id) => ref
                .read(studentDocumentsProvider(studentId).notifier)
                .remove(id),
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

    await _pickWithType(context, ref, type, targetReplacing);
  }

  Future<void> _pickWithType(
    BuildContext context,
    WidgetRef ref,
    StudentDocumentType type,
    StudentDocument? replacing,
  ) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              title: Text('${context.tr('Add')} ${_typeName(type)}'),
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

  Future<StudentDocumentType?> _chooseType(
    BuildContext context,
    List<StudentDocument> docs,
  ) {
    final hasFront = docs.any((d) => d.type == StudentDocumentType.aadhaarFront);
    final hasBack = docs.any((d) => d.type == StudentDocumentType.aadhaarBack);

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
              for (final type in StudentDocumentType.values)
                if (type != StudentDocumentType.aadhaar)
                  ListTile(
                    leading: Icon(
                      type == StudentDocumentType.aadhaarFront ||
                              type == StudentDocumentType.aadhaarBack
                          ? Icons.badge_outlined
                          : type == StudentDocumentType.collegeId
                          ? Icons.school_outlined
                          : type == StudentDocumentType.passportPhoto
                          ? Icons.photo_camera_front_outlined
                          : Icons.description_outlined,
                    ),
                    title: Text(_typeName(type)),
                    subtitle: type == StudentDocumentType.aadhaarFront && hasFront
                        ? const Text('Already uploaded (Tap to replace)', style: TextStyle(fontSize: 10))
                        : type == StudentDocumentType.aadhaarBack && hasBack
                        ? const Text('Already uploaded (Tap to replace)', style: TextStyle(fontSize: 10))
                        : null,
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
  final int studentId;
  final StudentDocument? frontDoc;
  final StudentDocument? backDoc;
  final StudentDocument? legacyDoc;
  final VoidCallback onAddOrReplaceFront;
  final VoidCallback onAddOrReplaceBack;
  final ValueChanged<StudentDocument> onPreview;
  final ValueChanged<String> onDelete;

  const _AadhaarVaultSection({
    required this.studentId,
    required this.frontDoc,
    required this.backDoc,
    required this.legacyDoc,
    required this.onAddOrReplaceFront,
    required this.onAddOrReplaceBack,
    required this.onPreview,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainer : const Color(0xFFF7F7FD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.badge_outlined, size: 18, color: Color(0xFF514BC0)),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Aadhaar Card (Max 2 Photos)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Front & Back',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _AadhaarSlotCard(
                  label: 'Front Side',
                  document: frontDoc ?? legacyDoc,
                  onTap: onAddOrReplaceFront,
                  onPreview: () {
                    final doc = frontDoc ?? legacyDoc;
                    if (doc != null) onPreview(doc);
                  },
                  onDelete: () {
                    final doc = frontDoc ?? legacyDoc;
                    if (doc != null) onDelete(doc.id);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AadhaarSlotCard(
                  label: 'Back Side',
                  document: backDoc,
                  onTap: onAddOrReplaceBack,
                  onPreview: () {
                    if (backDoc != null) onPreview(backDoc!);
                  },
                  onDelete: () {
                    if (backDoc != null) onDelete(backDoc!.id);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AadhaarSlotCard extends StatelessWidget {
  final String label;
  final StudentDocument? document;
  final VoidCallback onTap;
  final VoidCallback? onPreview;
  final VoidCallback? onDelete;

  const _AadhaarSlotCard({
    required this.label,
    required this.document,
    required this.onTap,
    this.onPreview,
    this.onDelete,
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
