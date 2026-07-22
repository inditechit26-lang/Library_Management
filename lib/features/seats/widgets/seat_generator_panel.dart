import 'package:flutter/material.dart';

enum SeatGeneratorMode { numeric, alphabetic, custom }

class SeatGeneratorPanel extends StatefulWidget {
  final void Function(int total) onNumeric;
  final void Function(int rows, int seatsPerRow) onAlphabetic;
  final VoidCallback onCustom;
  const SeatGeneratorPanel({
    super.key,
    required this.onNumeric,
    required this.onAlphabetic,
    required this.onCustom,
  });
  @override
  State<SeatGeneratorPanel> createState() => _SeatGeneratorPanelState();
}

class _SeatGeneratorPanelState extends State<SeatGeneratorPanel> {
  SeatGeneratorMode mode = SeatGeneratorMode.numeric;
  final total = TextEditingController(text: '100');
  final rows = TextEditingController(text: '4');
  final perRow = TextEditingController(text: '25');
  @override
  void dispose() {
    total.dispose();
    rows.dispose();
    perRow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 520;
      final width = compact
          ? (constraints.maxWidth - 10) / 2
          : (constraints.maxWidth - 20) / 3;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SizedBox(
                width: width,
                child: _ModeCard(
                  title: 'Numeric',
                  example: '1, 2, 3…',
                  icon: Icons.pin_outlined,
                  selected: mode == SeatGeneratorMode.numeric,
                  onTap: () => setState(() => mode = SeatGeneratorMode.numeric),
                ),
              ),
              SizedBox(
                width: width,
                child: _ModeCard(
                  title: 'Alphabetic',
                  example: 'A1, A2, B1…',
                  icon: Icons.sort_by_alpha_rounded,
                  selected: mode == SeatGeneratorMode.alphabetic,
                  onTap: () =>
                      setState(() => mode = SeatGeneratorMode.alphabetic),
                ),
              ),
              SizedBox(
                width: width,
                child: _ModeCard(
                  title: 'Custom Labels',
                  example: 'VIP-01, G12…',
                  icon: Icons.edit_note_rounded,
                  selected: mode == SeatGeneratorMode.custom,
                  onTap: () => setState(() => mode = SeatGeneratorMode.custom),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: switch (mode) {
              SeatGeneratorMode.numeric => _GeneratorForm(
                key: const ValueKey('numeric'),
                compact: compact,
                fields: [_NumberField(controller: total, label: 'Total seats')],
                onGenerate: () =>
                    widget.onNumeric(int.tryParse(total.text) ?? 0),
              ),
              SeatGeneratorMode.alphabetic => _GeneratorForm(
                key: const ValueKey('alpha'),
                compact: compact,
                fields: [
                  _NumberField(controller: rows, label: 'Rows (A–Z)'),
                  _NumberField(controller: perRow, label: 'Seats per row'),
                ],
                onGenerate: () => widget.onAlphabetic(
                  int.tryParse(rows.text) ?? 0,
                  int.tryParse(perRow.text) ?? 0,
                ),
              ),
              SeatGeneratorMode.custom => Align(
                key: const ValueKey('custom'),
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  onPressed: widget.onCustom,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Seat'),
                ),
              ),
            },
          ),
        ],
      );
    },
  );
}

class _GeneratorForm extends StatelessWidget {
  final bool compact;
  final List<Widget> fields;
  final VoidCallback onGenerate;
  const _GeneratorForm({
    super.key,
    required this.compact,
    required this.fields,
    required this.onGenerate,
  });
  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        for (var i = 0; i < fields.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: fields[i]),
        ],
      ],
    );
    if (compact) {
      return Column(
        children: [
          row,
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onGenerate,
              child: const Text('Generate'),
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: row),
        const SizedBox(width: 10),
        FilledButton(onPressed: onGenerate, child: const Text('Generate')),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title, example;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _ModeCard({
    required this.title,
    required this.example,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              example,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  const _NumberField({required this.controller, required this.label});
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(labelText: label, isDense: true),
  );
}
