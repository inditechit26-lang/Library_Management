import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class DocumentUploadCard extends StatelessWidget {
  final Set<String> uploaded;
  final ValueChanged<String> onToggle;
  const DocumentUploadCard({
    super.key,
    required this.uploaded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outline),
        borderRadius: BorderRadius.circular(22),
      ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.folder_copy_outlined,
              color: Color(0xFF5650C7),
              size: 20,
            ),
            SizedBox(width: 9),
            Text(
              'Upload Documents',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            Spacer(),
            Text(
              'Optional',
              style: TextStyle(fontSize: 10, color: Color(0xFF979CAC)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.35,
          children:
              const [
                    ('Aadhaar', Icons.badge_outlined),
                    ('Passport Photo', Icons.photo_camera_outlined),
                    ('College ID', Icons.school_outlined),
                    ('Other', Icons.description_outlined),
                  ]
                  .map(
                    (item) => _Document(
                      label: item.$1,
                      icon: item.$2,
                      selected: uploaded.contains(item.$1),
                      onTap: () => _chooseSource(context, item.$1),
                    ),
                  )
                  .toList(),
        ),
      ],
    ),
  );
  }

  Future<void> _chooseSource(BuildContext context, String label) async {
    final source = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9DBE4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              ...const [
                ('Camera', Icons.photo_camera_outlined, 'camera'),
                ('Gallery', Icons.photo_library_outlined, 'gallery'),
                ('PDF', Icons.picture_as_pdf_outlined, 'pdf'),
                ('Image', Icons.image_outlined, 'image'),
              ].map(
                (item) => ListTile(
                  leading: Icon(item.$2),
                  title: Text(item.$1),
                  onTap: () => Navigator.pop(sheetContext, item.$3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;
    bool selected = false;
    if (source == 'camera' || source == 'gallery') {
      final file = await ImagePicker().pickImage(
        source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
      );
      selected = file != null;
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: source == 'pdf' ? FileType.custom : FileType.image,
        allowedExtensions: source == 'pdf' ? const ['pdf'] : null,
      );
      selected = result != null;
    }
    if (selected && !uploaded.contains(label)) onToggle(label);
  }
}

class _Document extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _Document({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bg = selected
        ? (isDark ? colors.primaryContainer.withValues(alpha: 0.35) : const Color(0xFFF0EFFF))
        : (isDark ? colors.surfaceContainerLow : const Color(0xFFFAFAFD));

    final border = selected
        ? colors.primary
        : (isDark ? colors.outlineVariant : const Color(0xFFE8E9EF));

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.check_circle : icon,
                size: 19,
                color: selected
                    ? colors.primary
                    : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
