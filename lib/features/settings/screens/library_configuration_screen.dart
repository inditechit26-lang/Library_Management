import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/widgets/custom_qr_image_view.dart';
import '../../auth/providers/auth_provider.dart';
import '../../students/providers/students_provider.dart';
import '../controllers/library_configuration_controller.dart';
import '../controllers/payment_settings_controller.dart';
import '../models/library_configuration.dart';
import '../models/pricing_settings.dart';
import '../../seats/controllers/seats_controller.dart';

class LibraryConfigurationScreen extends ConsumerWidget {
  const LibraryConfigurationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configuration = ref.watch(libraryConfigurationProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library Configuration'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: constraints.maxWidth > 920 ? 920 : double.infinity,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  constraints.maxWidth < 600 ? 16 : 24,
                  12,
                  constraints.maxWidth < 600 ? 16 : 24,
                  32,
                ),
                children: [
                  Text(
                    'Configure how your library operates',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Only enabled options appear in daily workflows. Existing records are always preserved.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _ConfigurationCard(
                    icon: Icons.space_dashboard_outlined,
                    title: 'Sections',
                    description:
                        'Configure membership plans and pricing for each section.',
                    child: _SectionsEditor(configuration: configuration),
                  ),
                  const SizedBox(height: 16),
                  _ConfigurationCard(
                    icon: Icons.event_seat_outlined,
                    title: 'Seat Types',
                    description:
                        'Choose the seating models used by your library.',
                    child: _SeatTypeChips(configuration: configuration),
                  ),
                  const SizedBox(height: 16),
                  _ConfigurationCard(
                    icon: Icons.schedule_rounded,
                    title: 'Shift Timing',
                    description: 'Set the operating time for each seat shift.',
                    child: _ShiftTiming(configuration: configuration),
                  ),
                  const SizedBox(height: 16),
                  const _ConfigurationCard(
                    icon: Icons.payments_outlined,
                    title: 'Payment Settings',
                    description:
                        'Manage payee details and UPI payment accounts.',
                    child: _PaymentConfiguration(),
                  ),
                  const SizedBox(height: 16),
                  _ConfigurationCard(
                    icon: Icons.folder_outlined,
                    title: 'Student Documents',
                    description:
                        'Choose optional upload fields shown during admission.',
                    child: _DocumentRequirements(configuration: configuration),
                  ),
                  const SizedBox(height: 16),
                  _ConfigurationCard(
                    icon: Icons.pin_outlined,
                    title: 'Seat Numbering Style',
                    description:
                        'Unoccupied seats update in sequence. Occupied seats remain unchanged.',
                    child: _SeatNumbering(configuration: configuration),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfigurationCard extends StatefulWidget {
  const _ConfigurationCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.child,
    this.initiallyExpanded = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget child;
  final bool initiallyExpanded;

  @override
  State<_ConfigurationCard> createState() => _ConfigurationCardState();
}

class _ConfigurationCardState extends State<_ConfigurationCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shadowColor: colors.shadow.withValues(alpha: .12),
      color: colors.surface,
      surfaceTintColor: colors.surfaceTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 21,
                      color: colors.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.description,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: colors.onSurfaceVariant,
                                height: 1.35,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                    child: widget.child,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _SeatTypeChips extends ConsumerWidget {
  const _SeatTypeChips({required this.configuration});
  final LibraryConfiguration configuration;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: LibrarySeatType.values.map((type) {
      final selected = configuration.seatTypes.contains(type);
      return FilterChip(
        label: Text(type.label),
        selected: selected,
        onSelected: (enabled) async {
          if (!enabled && configuration.seatTypes.length == 1) {
            _message(context, 'At least one seat type must remain enabled.');
            return;
          }
          if (!enabled &&
              !await _confirmIfUsed(
                context,
                ref,
                title: 'Disable ${type.label}?',
                field: 'seatType',
                match: type.name,
              )) {
            return;
          }
          final types = {...configuration.seatTypes};
          enabled ? types.add(type) : types.remove(type);
          await ref
              .read(libraryConfigurationProvider.notifier)
              .save(configuration.copyWith(seatTypes: types));
        },
      );
    }).toList(),
  );
}

class _ShiftTiming extends ConsumerWidget {
  const _ShiftTiming({required this.configuration});
  final LibraryConfiguration configuration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timings = configuration.shiftTimings;
    return Column(
      children: [
        _ShiftTimingRow(
          title: 'Full-Time',
          start: timings.fullTimeStart,
          end: timings.fullTimeEnd,
          onStartChanged: (value) =>
              _save(ref, timings.copyWith(fullTimeStart: value)),
          onEndChanged: (value) =>
              _save(ref, timings.copyWith(fullTimeEnd: value)),
        ),
        const SizedBox(height: 12),
        _ShiftTimingRow(
          title: 'Half-Time',
          start: timings.halfTimeStart,
          end: timings.halfTimeEnd,
          onStartChanged: (value) =>
              _save(ref, timings.copyWith(halfTimeStart: value)),
          onEndChanged: (value) =>
              _save(ref, timings.copyWith(halfTimeEnd: value)),
        ),
      ],
    );
  }

  Future<void> _save(WidgetRef ref, ShiftTimingConfiguration timings) => ref
      .read(libraryConfigurationProvider.notifier)
      .save(configuration.copyWith(shiftTimings: timings));
}

class _ShiftTimingRow extends StatelessWidget {
  const _ShiftTimingRow({
    required this.title,
    required this.start,
    required this.end,
    required this.onStartChanged,
    required this.onEndChanged,
  });

  final String title;
  final String start;
  final String end;
  final ValueChanged<String> onStartChanged;
  final ValueChanged<String> onEndChanged;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final controls = [
        _TimeSelector(
          label: 'Start Time',
          value: start,
          onChanged: onStartChanged,
        ),
        _TimeSelector(label: 'End Time', value: end, onChanged: onEndChanged),
      ];
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (constraints.maxWidth >= 480)
              Row(
                children: [
                  Expanded(child: controls[0]),
                  const SizedBox(width: 10),
                  Expanded(child: controls[1]),
                ],
              )
            else
              Column(
                children: [
                  controls[0],
                  const SizedBox(height: 10),
                  controls[1],
                ],
              ),
          ],
        ),
      );
    },
  );
}

class _TimeSelector extends StatelessWidget {
  const _TimeSelector({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: () async {
      final parts = value.split(':');
      final selected = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(
          hour: int.tryParse(parts.first) ?? 6,
          minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
        ),
      );
      if (selected == null) return;
      onChanged(
        '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}',
      );
    },
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.schedule_rounded),
      ),
      child: Text(
        TimeOfDay(
          hour: int.tryParse(value.split(':').first) ?? 6,
          minute: value.split(':').length > 1
              ? int.tryParse(value.split(':')[1]) ?? 0
              : 0,
        ).format(context),
      ),
    ),
  );
}

class _PaymentConfiguration extends ConsumerWidget {
  const _PaymentConfiguration();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(paymentSettingsProvider);
    final controller = ref.read(paymentSettingsProvider.notifier);
    final usesCustomQr = settings.usesCustomQr;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          key: ValueKey('payee-${settings.payeeName}'),
          initialValue: settings.payeeName,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Payee / Business Name',
            prefixIcon: Icon(Icons.storefront_outlined),
          ),
          onFieldSubmitted: controller.setPayeeName,
        ),
        const SizedBox(height: 16),
        Text(
          'UPI Payment Accounts',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        if (settings.upiIds.isNotEmpty)
          IgnorePointer(
            ignoring: usesCustomQr,
            child: Opacity(
              opacity: usesCustomQr ? 0.5 : 1,
              child: RadioGroup<String>(
                groupValue: settings.activeUpiId,
                onChanged: (value) {
                  if (value != null) controller.setActiveUpiId(value);
                },
                child: Column(
                  children: [
                    for (final upiId in settings.upiIds)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Radio<String>(value: upiId),
                        title: Text(
                          upiId,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        trailing: settings.upiIds.length > 1
                            ? IconButton(
                                tooltip: 'Delete',
                                icon: const Icon(Icons.delete_outline_rounded),
                                onPressed: usesCustomQr
                                    ? null
                                    : () => controller.removeUpiId(upiId),
                              )
                            : null,
                        onTap: usesCustomQr
                            ? null
                            : () => controller.setActiveUpiId(upiId),
                      ),
                  ],
                ),
              ),
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: usesCustomQr
                ? null
                : () => _addUpiId(context, controller),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add New UPI ID'),
          ),
        ),
        const SizedBox(height: 8),
        if (usesCustomQr)
          Text(
            'An uploaded QR image is active. Remove it to manage UPI IDs.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        if (usesCustomQr) const SizedBox(height: 8),
        if (usesCustomQr || settings.activeUpiId.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  usesCustomQr ? 'Uploaded UPI QR Preview' : 'UPI QR Preview',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 12),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(10),
                  child: CustomQrImageView(
                    url: settings.customQrUrl,
                    width: 160,
                    height: 160,
                    fallback: QrImageView(
                      data: settings.getQrData(),
                      size: 160,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => _uploadQr(context, controller),
            icon: const Icon(Icons.upload_file_outlined),
            label: const Text('Upload UPI QR Image'),
          ),
        ),
        if (settings.customQrUrl.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: controller.removeCustomQr,
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Use generated UPI QR instead'),
            ),
          ),
      ],
    );
  }

  Future<void> _addUpiId(
    BuildContext context,
    PaymentSettingsController controller,
  ) async {
    final textController = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add New UPI ID'),
        content: TextField(
          controller: textController,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(hintText: 'e.g. mylibrary@upi'),
          onSubmitted: (value) {
            if (value.trim().contains('@')) {
              Navigator.pop(dialogContext, value.trim());
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = textController.text.trim();
              if (value.contains('@')) Navigator.pop(dialogContext, value);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 320));
    textController.dispose();
    if (value != null) await controller.addUpiId(value);
  }

  Future<void> _uploadQr(
    BuildContext context,
    PaymentSettingsController controller,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    final file = result?.files.single;
    if (file == null) return;

    Uint8List? bytes = file.bytes;
    if (bytes == null && file.path != null && file.path!.isNotEmpty) {
      try {
        bytes = await File(file.path!).readAsBytes();
      } catch (_) {}
    }

    if (bytes == null || !context.mounted) return;

    try {
      final extension = file.extension?.toLowerCase() ?? 'png';
      final contentType = extension == 'jpg' || extension == 'jpeg'
          ? 'image/jpeg'
          : 'image/$extension';
      await controller.uploadCustomQr(
        bytes: bytes,
        fileName: file.name,
        contentType: contentType,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('UPI QR image uploaded.')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to upload QR: $e')));
    }
  }
}

class _SectionsEditor extends ConsumerStatefulWidget {
  const _SectionsEditor({required this.configuration});
  final LibraryConfiguration configuration;

  @override
  ConsumerState<_SectionsEditor> createState() => _SectionsEditorState();
}

class _SectionsEditorState extends ConsumerState<_SectionsEditor> {
  late String _selectedSectionId;
  bool _isFullTime = true;

  @override
  void initState() {
    super.initState();
    _selectedSectionId = widget.configuration.sections.first.id;
  }

  @override
  void didUpdateWidget(covariant _SectionsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.configuration.sections.any(
      (section) => section.id == _selectedSectionId,
    )) {
      _selectedSectionId = widget.configuration.sections.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final section = widget.configuration.sections.firstWhere(
      (item) => item.id == _selectedSectionId,
    );
    final periods = [
      MembershipPeriod.monthly,
      MembershipPeriod.quarterly,
      MembershipPeriod.halfYearly,
      MembershipPeriod.annual,
      if (section.membershipPeriods.contains(MembershipPeriod.custom))
        MembershipPeriod.custom,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.primaryContainer.withValues(alpha: .38),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.sell_outlined, color: colors.onPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plan Rate Configuration',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Set separate full-time and half-time rates for each section.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final item in widget.configuration.sections) ...[
                GestureDetector(
                  onLongPress: () => _confirmDeleteSection(context, item),
                  child: ChoiceChip(
                    avatar: CircleAvatar(radius: 5, backgroundColor: item.color),
                    label: Text(item.name),
                    selected: _selectedSectionId == item.id,
                    onSelected: (_) => setState(() => _selectedSectionId = item.id),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              ActionChip(
                avatar: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add Section'),
                onPressed: () => _addSection(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(
              value: true,
              icon: Icon(Icons.wb_sunny_outlined),
              label: Text('Full Time (24 Hours)'),
            ),
            ButtonSegment(
              value: false,
              icon: Icon(Icons.schedule_outlined),
              label: Text('Half Time (12 Hours)'),
            ),
          ],
          selected: {_isFullTime},
          showSelectedIcon: false,
          onSelectionChanged: (value) {
            setState(() => _isFullTime = value.first);
          },
        ),
        const SizedBox(height: 14),
        for (final period in periods) ...[
          _SectionPlanCard(
            key: ValueKey('${section.id}-${_isFullTime}-${period.name}'),
            section: section,
            period: period,
            isFullTime: _isFullTime,
            onSaved: (price) =>
                _savePlan(section, period, price, isFullTime: _isFullTime),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Future<void> _savePlan(
    LibrarySection section,
    MembershipPeriod period,
    double price, {
    required bool isFullTime,
  }) {
    final prices = {
      ...section.pricesFor(isFullTime: isFullTime),
      period: price,
    };
    final updated = section.copyWith(
      membershipPeriods: {...section.membershipPeriods, period},
      fullTimePlanPrices: isFullTime ? prices : section.fullTimePlanPrices,
      halfTimePlanPrices: isFullTime ? section.halfTimePlanPrices : prices,
    );
    final sections = [
      for (final item in widget.configuration.sections)
        if (item.id == updated.id) updated else item,
    ];
    return ref
        .read(libraryConfigurationProvider.notifier)
        .save(widget.configuration.copyWith(sections: sections));
  }

  Future<void> _addSection(BuildContext context) async {
    final textController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Hall Section'),
        content: TextField(
          controller: textController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Section Name',
            hintText: 'e.g. Girls Section, Boys Section',
          ),
          onSubmitted: (val) {
            if (val.trim().isNotEmpty) Navigator.pop(dialogContext, val.trim());
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final val = textController.text.trim();
              if (val.isNotEmpty) Navigator.pop(dialogContext, val);
            },
            child: const Text('Add Section'),
          ),
        ],
      ),
    );
    textController.dispose();
    if (name == null || name.trim().isEmpty) return;
    final id = name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    if (widget.configuration.sections.any((s) => s.id == id)) return;

    final colors = [
      0xFFE91E63, // Pink (Girls)
      0xFF2196F3, // Blue (Boys)
      0xFF4CAF50, // Green (General)
      0xFFFF9800, // Orange
      0xFF9C27B0, // Purple
    ];
    final color = colors[widget.configuration.sections.length % colors.length];

    final newSection = LibrarySection(
      id: id,
      name: name.trim(),
      colorValue: color,
    );

    final updatedSections = [...widget.configuration.sections, newSection];
    await ref
        .read(libraryConfigurationProvider.notifier)
        .save(widget.configuration.copyWith(sections: updatedSections));
    if (mounted) {
      setState(() => _selectedSectionId = id);
    }
  }

  Future<void> _confirmDeleteSection(
    BuildContext context,
    LibrarySection section,
  ) async {
    if (widget.configuration.sections.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one section must remain enabled.')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete ${section.name}?'),
        content: Text(
          'Are you sure you want to delete "${section.name}"? This section will be removed from library settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete Section'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    final updatedSections = widget.configuration.sections
        .where((s) => s.id != section.id)
        .toList();

    await ref
        .read(libraryConfigurationProvider.notifier)
        .save(widget.configuration.copyWith(sections: updatedSections));

    if (mounted) {
      setState(() {
        _selectedSectionId = updatedSections.first.id;
      });
    }
  }
}

class _SectionPlanCard extends StatelessWidget {
  const _SectionPlanCard({
    super.key,
    required this.section,
    required this.period,
    required this.isFullTime,
    required this.onSaved,
  });

  final LibrarySection section;
  final MembershipPeriod period;
  final bool isFullTime;
  final Future<void> Function(double price) onSaved;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final title = period == MembershipPeriod.annual
        ? 'Yearly Plan'
        : '${period.label} Plan';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: section.color.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_planIcon(period), color: section.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      period.duration,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _MoneyField(
            label: 'Price Amount',
            value: section.pricesFor(isFullTime: isFullTime)[period] ?? 0,
            helperText: period == MembershipPeriod.custom
                ? 'This amount can be overridden during admission.'
                : null,
            onSaved: onSaved,
          ),
        ],
      ),
    );
  }
}

class _DocumentRequirements extends ConsumerWidget {
  const _DocumentRequirements({required this.configuration});
  final LibraryConfiguration configuration;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    children: StudentDocumentRequirement.values.map((document) {
      final enabled = configuration.requiredDocuments.contains(document);
      return _SettingRow(
        icon: _documentIcon(document),
        title: document.label,
        description: document.description,
        trailing: Switch(
          value: enabled,
          onChanged: (value) async {
            final documents = {...configuration.requiredDocuments};
            value ? documents.add(document) : documents.remove(document);
            await ref
                .read(libraryConfigurationProvider.notifier)
                .save(configuration.copyWith(requiredDocuments: documents));
          },
        ),
      );
    }).toList(),
  );
}

class _SeatNumbering extends ConsumerStatefulWidget {
  const _SeatNumbering({required this.configuration});
  final LibraryConfiguration configuration;

  @override
  ConsumerState<_SeatNumbering> createState() => _SeatNumberingState();
}

class _SeatNumberingState extends ConsumerState<_SeatNumbering> {
  String? _selectedSectionId;
  late int startingNumber;
  late int endingNumber;
  late String prefix;
  late String endingPrefix;
  late int numbersPerPrefix;

  void _updateFieldsForSelectedSection() {
    final sections = widget.configuration.enabledSections;
    _selectedSectionId ??= sections.isEmpty ? null : sections.first.id;
    final section = sections.firstWhere(
      (s) => s.id == _selectedSectionId,
      orElse: () => sections.first,
    );
    final numbering = section.seatNumbering ?? widget.configuration.seatNumbering;
    startingNumber = numbering.startingNumber;
    endingNumber = numbering.endingNumber;
    prefix = numbering.prefix;
    endingPrefix = numbering.endingPrefix;
    numbersPerPrefix = numbering.numbersPerPrefix;
  }

  @override
  void initState() {
    super.initState();
    _updateFieldsForSelectedSection();
  }

  @override
  void didUpdateWidget(covariant _SeatNumbering oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateFieldsForSelectedSection();
  }

  @override
  Widget build(BuildContext context) {
    final sections = widget.configuration.enabledSections;
    _selectedSectionId ??= sections.isEmpty ? null : sections.first.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sections.isNotEmpty) ...[
          Text(
            'Select Hall Section to Configure',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final section in sections) ...[
                  ChoiceChip(
                    avatar: CircleAvatar(radius: 5, backgroundColor: section.color),
                    label: Text(section.name),
                    selected: _selectedSectionId == section.id,
                    onSelected: (_) {
                      setState(() {
                        _selectedSectionId = section.id;
                        _updateFieldsForSelectedSection();
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        RadioGroup<SeatNumberingStyle>(
          groupValue: widget.configuration.seatNumbering.style,
          onChanged: (value) => ref
              .read(libraryConfigurationProvider.notifier)
              .save(
                widget.configuration.copyWith(
                  seatNumbering: widget.configuration.seatNumbering.copyWith(
                    style: value,
                  ),
                ),
              ),
          child: Column(
            children: SeatNumberingStyle.values
                .map(
                  (style) => AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: Column(
                      children: [
                        _SettingRow(
                          icon: _numberingIcon(style),
                          title: _numberingTitle(style),
                          description: _numberingExample(style),
                          trailing: Radio<SeatNumberingStyle>(value: style),
                        ),
                        if (widget.configuration.seatNumbering.style == style)
                          _numberingFields(style),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _numberingFields(SeatNumberingStyle style) {
    final showPrefix = style == SeatNumberingStyle.alphabetic;
    const showStartingNumber = true;
    final colors = Theme.of(context).colorScheme;
    final currentSectionName = _selectedSectionId != null
        ? widget.configuration.sections.firstWhere((s) => s.id == _selectedSectionId, orElse: () => widget.configuration.sections.first).name
        : 'All Sections';

    return Container(
      key: ValueKey('numbering-fields-container-$_selectedSectionId'),
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(34, 2, 0, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showPrefix)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: ValueKey('numbering-prefix-$_selectedSectionId-$prefix'),
                    initialValue: prefix,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 1,
                    decoration: const InputDecoration(
                      labelText: 'Starting Alphabet',
                      counterText: '',
                    ),
                    onChanged: (value) =>
                        setState(() => prefix = value.trim().toUpperCase()),
                    onFieldSubmitted: (_) => _saveNumbering(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    key: ValueKey('numbering-ending-prefix-$_selectedSectionId-$endingPrefix'),
                    initialValue: endingPrefix,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 1,
                    decoration: const InputDecoration(
                      labelText: 'Ending Alphabet',
                      counterText: '',
                    ),
                    onChanged: (value) => setState(
                      () => endingPrefix = value.trim().toUpperCase(),
                    ),
                    onFieldSubmitted: (_) => _saveNumbering(),
                  ),
                ),
              ],
            ),
          if (showPrefix) ...[
            const SizedBox(height: 10),
            TextFormField(
              key: ValueKey('numbering-per-prefix-$_selectedSectionId-$numbersPerPrefix'),
              initialValue: numbersPerPrefix.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Numbers per Alphabet',
              ),
              onChanged: (value) =>
                  setState(() => numbersPerPrefix = int.tryParse(value) ?? 1),
              onFieldSubmitted: (_) => _saveNumbering(),
            ),
          ],
          if (showPrefix && showStartingNumber) const SizedBox(height: 10),
          if (showStartingNumber)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: ValueKey('numbering-start-$_selectedSectionId-$startingNumber'),
                    initialValue: startingNumber.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Starting Number',
                    ),
                    onChanged: (value) => setState(
                      () => startingNumber = int.tryParse(value) ?? 1,
                    ),
                    onFieldSubmitted: (_) => _saveNumbering(),
                  ),
                ),
                if (style == SeatNumberingStyle.numeric) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      key: ValueKey('numbering-end-$_selectedSectionId-$endingNumber'),
                      initialValue: endingNumber.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Ending Number',
                      ),
                      onChanged: (value) => setState(
                        () => endingNumber = int.tryParse(value) ?? 1,
                      ),
                      onFieldSubmitted: (_) => _saveNumbering(),
                    ),
                  ),
                ],
              ],
            ),
          const SizedBox(height: 12),
          Text(
            'Preview for $currentSectionName',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: _preview(
              style,
            ).map((label) => Chip(label: Text(label))).toList(),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              icon: const Icon(Icons.save_rounded, size: 18),
              onPressed: _saveNumbering,
              label: Text('Save $currentSectionName Numbering'),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _preview(SeatNumberingStyle style) {
    final cleanPrefix = prefix.isEmpty ? 'A' : prefix;
    if (style == SeatNumberingStyle.numeric) {
      final end = endingNumber < startingNumber ? startingNumber : endingNumber;
      return List.generate(
        (end - startingNumber + 1).clamp(1, 6),
        (index) => '${startingNumber + index}',
      );
    }
    final startCode = cleanPrefix.codeUnitAt(0).clamp(65, 90);
    final cleanEnd = endingPrefix.isEmpty ? cleanPrefix : endingPrefix;
    final endCode = cleanEnd.codeUnitAt(0).clamp(startCode, 90);
    final labels = <String>[];
    for (var code = startCode; code <= endCode && labels.length < 6; code++) {
      for (
        var number = startingNumber;
        number < startingNumber + numbersPerPrefix.clamp(1, 10000) &&
            labels.length < 6;
        number++
      ) {
        labels.add('${String.fromCharCode(code)}$number');
      }
    }
    return labels;
  }

  Future<void> _saveNumbering() async {
    final cleanPrefix = prefix.trim().toUpperCase();
    final cleanEndingPrefix = endingPrefix.trim().toUpperCase();
    final newNumbering = widget.configuration.seatNumbering.copyWith(
      startingNumber: startingNumber < 1 ? 1 : startingNumber,
      endingNumber: endingNumber < startingNumber
          ? startingNumber
          : endingNumber,
      prefix: cleanPrefix.isEmpty ? 'A' : cleanPrefix,
      endingPrefix: cleanEndingPrefix.isEmpty
          ? (cleanPrefix.isEmpty ? 'A' : cleanPrefix)
          : cleanEndingPrefix,
      numbersPerPrefix: numbersPerPrefix < 1 ? 1 : numbersPerPrefix,
    );

    final sections = widget.configuration.sections.map((section) {
      if (section.id == _selectedSectionId) {
        return section.copyWith(seatNumbering: newNumbering);
      }
      return section;
    }).toList();

    await ref
        .read(libraryConfigurationProvider.notifier)
        .save(
          widget.configuration.copyWith(
            sections: sections,
            seatNumbering: newNumbering,
          ),
        );

    if (_selectedSectionId != null) {
      await ref
          .read(seatsProvider.notifier)
          .applySectionNumbering(_selectedSectionId!, newNumbering);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Section seat numbering saved & generated successfully!')),
      );
    }
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.description,
    required this.trailing,
  });
  final IconData icon;
  final String title;
  final String description;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.onSurfaceVariant),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}

IconData _documentIcon(StudentDocumentRequirement value) => switch (value) {
  StudentDocumentRequirement.studentPhoto => Icons.account_circle_outlined,
  StudentDocumentRequirement.aadhaarCard => Icons.badge_outlined,
  StudentDocumentRequirement.addressProof => Icons.home_outlined,
  StudentDocumentRequirement.parentId => Icons.family_restroom_outlined,
  StudentDocumentRequirement.collegeId => Icons.school_outlined,
};

IconData _planIcon(MembershipPeriod value) => switch (value) {
  MembershipPeriod.monthly => Icons.calendar_today_outlined,
  MembershipPeriod.quarterly => Icons.date_range_outlined,
  MembershipPeriod.halfYearly => Icons.calendar_month_outlined,
  MembershipPeriod.annual => Icons.event_available_outlined,
  MembershipPeriod.custom => Icons.edit_calendar_outlined,
};

IconData _numberingIcon(SeatNumberingStyle value) => switch (value) {
  SeatNumberingStyle.numeric => Icons.onetwothree_rounded,
  SeatNumberingStyle.alphabetic => Icons.text_fields_rounded,
};

String _numberingTitle(SeatNumberingStyle value) => switch (value) {
  SeatNumberingStyle.numeric => 'Numeric',
  SeatNumberingStyle.alphabetic => 'Alphabetic',
};

String _numberingExample(SeatNumberingStyle value) => switch (value) {
  SeatNumberingStyle.numeric => 'Example: 1, 2, 3',
  SeatNumberingStyle.alphabetic => 'Example: A1, A2, B1',
};

String _amountText(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(2);

class _MoneyField extends StatefulWidget {
  const _MoneyField({
    required this.label,
    required this.value,
    required this.onSaved,
    this.helperText,
  });

  final String label;
  final double value;
  final String? helperText;
  final Future<void> Function(double value) onSaved;

  @override
  State<_MoneyField> createState() => _MoneyFieldState();
}

class _MoneyFieldState extends State<_MoneyField> {
  late final TextEditingController controller;
  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: _amountText(widget.value));
    focusNode = FocusNode()..addListener(_handleFocus);
  }

  @override
  void dispose() {
    focusNode
      ..removeListener(_handleFocus)
      ..dispose();
    controller.dispose();
    super.dispose();
  }

  void _handleFocus() {
    if (!focusNode.hasFocus) _save();
  }

  void _save() {
    final amount = double.tryParse(controller.text.trim());
    if (amount != null && amount >= 0 && amount != widget.value) {
      widget.onSaved(amount);
    }
  }

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    focusNode: focusNode,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(
      labelText: widget.label,
      prefixText: '₹ ',
      helperText: widget.helperText,
    ),
    onFieldSubmitted: (_) => _save(),
  );
}

void _message(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

Future<bool> _confirmIfUsed(
  BuildContext context,
  WidgetRef ref, {
  required String title,
  required String field,
  required String match,
}) async {
  final libraryId = ref.read(currentLibraryIdProvider);
  if (libraryId == null || libraryId.isEmpty) return false;
  final students = await ref
      .read(studentsRepositoryProvider)
      .getStudents(limit: 10000);
  final normalized = match.replaceAll('_', ' ').toLowerCase();
  final inUse = students.any((student) {
    final data = student.toFirestore();
    final source = switch (field) {
      'plan' => '${data['planName'] ?? ''} ${data['membershipPeriod'] ?? ''}',
      'seatType' =>
        '${data['seatType'] ?? ''} ${data['planName'] ?? ''} ${data['shift'] ?? ''}',
      'section' => '${data['sectionId'] ?? ''} ${data['category'] ?? ''}',
      _ => '',
    };
    if (field == 'seatType' && match.startsWith('halfTime')) {
      return source.toLowerCase().contains('half');
    }
    if (field == 'seatType' && match == 'fullTimeReserved') {
      return source.toLowerCase().contains('full');
    }
    return source.toLowerCase().contains(normalized);
  });
  if (!inUse || !context.mounted) return true;
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.info_outline_rounded),
          title: Text(title),
          content: const Text(
            'Active students currently use this option. Existing records will remain visible and unchanged, but this option will no longer be available for new admissions, assignments, or renewals.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Keep enabled'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Disable for future use'),
            ),
          ],
        ),
      ) ??
      false;
}
