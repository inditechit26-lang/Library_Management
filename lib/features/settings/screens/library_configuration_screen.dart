import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../controllers/library_configuration_controller.dart';
import '../controllers/payment_settings_controller.dart';
import '../models/library_configuration.dart';
import '../models/pricing_settings.dart';

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

class _ConfigurationCard extends StatelessWidget {
  const _ConfigurationCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget child;

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
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    icon,
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
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}

class _PlanOptionCard extends StatelessWidget {
  const _PlanOptionCard({
    required this.period,
    required this.selected,
    required this.onToggle,
    this.child,
  });

  final MembershipPeriod period;
  final bool selected;
  final ValueChanged<bool> onToggle;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected
            ? colors.primaryContainer.withValues(alpha: .22)
            : colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected
              ? colors.primary.withValues(alpha: .55)
              : colors.outlineVariant.withValues(alpha: .78),
          width: selected ? 1.25 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: selected ? .09 : .035),
            blurRadius: selected ? 18 : 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => onToggle(!selected),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? colors.primary
                            : colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: colors.primary.withValues(alpha: .2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        _planIcon(period),
                        size: 20,
                        color: selected
                            ? colors.onPrimary
                            : colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        period.label == 'Annual' ? 'Yearly' : period.label,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.1,
                        ),
                      ),
                    ),
                    Transform.scale(
                      scale: .94,
                      child: Checkbox(
                        value: selected,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        side: BorderSide(
                          color: selected ? colors.primary : colors.outline,
                          width: 1.5,
                        ),
                        onChanged: (value) => onToggle(value ?? false),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (child != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: .78),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: .7),
                  ),
                ),
                child: child,
              ),
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
          RadioGroup<String>(
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
                            onPressed: () => controller.removeUpiId(upiId),
                          )
                        : null,
                    onTap: () => controller.setActiveUpiId(upiId),
                  ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => _addUpiId(context, controller),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add New UPI ID'),
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
}

class _SectionsEditor extends ConsumerWidget {
  const _SectionsEditor({required this.configuration});
  final LibraryConfiguration configuration;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    children: [
      ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        buildDefaultDragHandles: false,
        itemCount: configuration.sections.length,
        onReorder: (oldIndex, newIndex) async {
          final sections = [...configuration.sections];
          if (newIndex > oldIndex) newIndex--;
          final moved = sections.removeAt(oldIndex);
          sections.insert(newIndex, moved);
          await ref
              .read(libraryConfigurationProvider.notifier)
              .save(configuration.copyWith(sections: sections));
        },
        itemBuilder: (context, index) {
          final section = configuration.sections[index];
          return _SectionRow(
            key: ValueKey(section.id),
            section: section,
            configuration: configuration,
            index: index,
            onEdit: () => _editSection(context, ref, section),
            onDelete: () => _deleteSection(context, ref, section),
            onChanged: (value) async {
              if (!value.isEnabled &&
                  !await _confirmIfUsed(
                    context,
                    ref,
                    title: 'Disable ${section.name}?',
                    field: 'section',
                    match: section.id,
                  )) {
                return;
              }
              final sections = [
                for (final item in configuration.sections)
                  if (item.id == value.id) value else item,
              ];
              await ref
                  .read(libraryConfigurationProvider.notifier)
                  .save(configuration.copyWith(sections: sections));
            },
          );
        },
      ),
      const SizedBox(height: 8),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => _addSection(context, ref),
          icon: const Icon(Icons.add_rounded, size: 19),
          label: const Text('Add custom section'),
        ),
      ),
    ],
  );

  Future<void> _addSection(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    var selectedColor = _sectionColors.first;
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add library section'),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  maxLength: 32,
                  decoration: const InputDecoration(
                    labelText: 'Section name',
                    hintText: 'e.g. Reading Room',
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Color tag'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: _sectionColors
                      .map(
                        (color) => InkWell(
                          onTap: () => setState(() => selectedColor = color),
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: color == selectedColor
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: color == selectedColor
                                ? const Icon(
                                    Icons.check,
                                    size: 17,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isNotEmpty) Navigator.pop(dialogContext, value);
              },
              child: const Text('Add section'),
            ),
          ],
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 320));
    controller.dispose();
    if (name == null || !context.mounted) return;
    if (configuration.sections.any(
      (section) => section.name.toLowerCase() == name.toLowerCase(),
    )) {
      _message(context, 'A section with this name already exists.');
      return;
    }
    final section = LibrarySection(
      id: 'section_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      colorValue: selectedColor.toARGB32(),
    );
    await ref
        .read(libraryConfigurationProvider.notifier)
        .save(
          configuration.copyWith(
            sections: [...configuration.sections, section],
          ),
        );
  }

  Future<void> _editSection(
    BuildContext context,
    WidgetRef ref,
    LibrarySection section,
  ) async {
    final controller = TextEditingController(text: section.name);
    var selectedColor = section.color;
    final updated = await showDialog<LibrarySection>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit library section'),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  maxLength: 32,
                  decoration: const InputDecoration(labelText: 'Section name'),
                ),
                const SizedBox(height: 12),
                const Text('Color tag'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: _sectionColors
                      .map(
                        (color) => InkWell(
                          onTap: () => setState(() => selectedColor = color),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: color == selectedColor
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  Navigator.pop(
                    dialogContext,
                    section.copyWith(
                      name: name,
                      colorValue: selectedColor.toARGB32(),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 320));
    controller.dispose();
    if (updated == null) return;
    final sections = [
      for (final item in configuration.sections)
        if (item.id == updated.id) updated else item,
    ];
    await ref
        .read(libraryConfigurationProvider.notifier)
        .save(configuration.copyWith(sections: sections));
  }

  Future<void> _deleteSection(
    BuildContext context,
    WidgetRef ref,
    LibrarySection section,
  ) async {
    if (configuration.sections.length == 1) {
      _message(context, 'At least one section must remain.');
      return;
    }
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text('Delete ${section.name}?'),
            content: const Text('Existing student records are preserved.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    await ref
        .read(libraryConfigurationProvider.notifier)
        .save(
          configuration.copyWith(
            sections: configuration.sections
                .where((item) => item.id != section.id)
                .toList(),
          ),
        );
  }
}

class _SectionRow extends StatelessWidget {
  const _SectionRow({
    super.key,
    required this.section,
    required this.configuration,
    required this.index,
    required this.onChanged,
    required this.onEdit,
    required this.onDelete,
  });
  final LibrarySection section;
  final LibraryConfiguration configuration;
  final int index;
  final ValueChanged<LibrarySection> onChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Container(
          width: 10,
          height: 38,
          decoration: BoxDecoration(
            color: section.color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        title: Text(
          section.name,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text('${section.membershipPeriods.length} Membership Plans'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: section.isEnabled,
              onChanged: (value) =>
                  onChanged(section.copyWith(isEnabled: value)),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit Section')),
                PopupMenuItem(value: 'delete', child: Text('Delete Section')),
              ],
            ),
            ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.drag_handle_rounded),
              ),
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        children: [
          for (final period in MembershipPeriod.values)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _PlanOptionCard(
                period: period,
                selected: section.membershipPeriods.contains(period),
                onToggle: (enabled) {
                  if (!enabled && section.membershipPeriods.length == 1) {
                    _message(
                      context,
                      'At least one membership plan must remain enabled.',
                    );
                    return;
                  }
                  final periods = {...section.membershipPeriods};
                  enabled ? periods.add(period) : periods.remove(period);
                  onChanged(section.copyWith(membershipPeriods: periods));
                },
                child: section.membershipPeriods.contains(period)
                    ? _MoneyField(
                        key: ValueKey(
                          '${section.id}-${period.name}-${section.planPrices[period]}',
                        ),
                        label: period == MembershipPeriod.custom
                            ? 'Default Price'
                            : 'Price',
                        value: section.planPrices[period] ?? 0,
                        helperText: period == MembershipPeriod.custom
                            ? 'Suggested starting value; it can be overridden during admission.'
                            : null,
                        onSaved: (price) async {
                          final prices = {...section.planPrices, period: price};
                          onChanged(section.copyWith(planPrices: prices));
                        },
                      )
                    : null,
              ),
            ),
        ],
      ),
    ),
  );
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
  late int startingNumber;
  late int endingNumber;
  late String prefix;
  late String endingPrefix;
  late int numbersPerPrefix;

  @override
  void initState() {
    super.initState();
    startingNumber = widget.configuration.seatNumbering.startingNumber;
    endingNumber = widget.configuration.seatNumbering.endingNumber;
    prefix = widget.configuration.seatNumbering.prefix;
    endingPrefix = widget.configuration.seatNumbering.endingPrefix;
    numbersPerPrefix = widget.configuration.seatNumbering.numbersPerPrefix;
  }

  @override
  void didUpdateWidget(covariant _SeatNumbering oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.configuration.seatNumbering !=
        widget.configuration.seatNumbering) {
      startingNumber = widget.configuration.seatNumbering.startingNumber;
      endingNumber = widget.configuration.seatNumbering.endingNumber;
      prefix = widget.configuration.seatNumbering.prefix;
      endingPrefix = widget.configuration.seatNumbering.endingPrefix;
      numbersPerPrefix = widget.configuration.seatNumbering.numbersPerPrefix;
    }
  }

  @override
  Widget build(BuildContext context) => RadioGroup<SeatNumberingStyle>(
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
  );

  Widget _numberingFields(SeatNumberingStyle style) {
    final showPrefix = style == SeatNumberingStyle.alphabetic;
    const showStartingNumber = true;
    final colors = Theme.of(context).colorScheme;
    return Container(
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
                    key: const ValueKey('numbering-prefix'),
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
                    key: const ValueKey('numbering-ending-prefix'),
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
              key: const ValueKey('numbering-per-prefix'),
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
                    key: const ValueKey('numbering-start'),
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
                      key: const ValueKey('numbering-end'),
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
            'Preview',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: _preview(
              style,
            ).map((label) => Chip(label: Text(label))).toList(),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonal(
              onPressed: _saveNumbering,
              child: const Text('Save numbering'),
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

  Future<void> _saveNumbering() {
    final cleanPrefix = prefix.trim().toUpperCase();
    final cleanEndingPrefix = endingPrefix.trim().toUpperCase();
    return ref
        .read(libraryConfigurationProvider.notifier)
        .save(
          widget.configuration.copyWith(
            seatNumbering: widget.configuration.seatNumbering.copyWith(
              startingNumber: startingNumber < 1 ? 1 : startingNumber,
              endingNumber: endingNumber < startingNumber
                  ? startingNumber
                  : endingNumber,
              prefix: cleanPrefix.isEmpty ? 'A' : cleanPrefix,
              endingPrefix: cleanEndingPrefix.isEmpty
                  ? (cleanPrefix.isEmpty ? 'A' : cleanPrefix)
                  : cleanEndingPrefix,
              numbersPerPrefix: numbersPerPrefix < 1 ? 1 : numbersPerPrefix,
            ),
          ),
        );
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

const _sectionColors = [
  Color(0xFF4F6BED),
  Color(0xFF6B5DD3),
  Color(0xFF267A5E),
  Color(0xFFA56722),
  Color(0xFFB0445C),
  Color(0xFF5F6B7A),
];

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
    super.key,
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
  final snapshot = await FirebaseFirestore.instance
      .collection('libraries')
      .doc(libraryId)
      .collection('students')
      .where('isDeleted', isEqualTo: false)
      .get();
  final normalized = match.replaceAll('_', ' ').toLowerCase();
  final inUse = snapshot.docs.any((document) {
    final data = document.data();
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
