import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../settings/controllers/pricing_controller.dart';
import '../models/student.dart';

class EditStudentSheet extends ConsumerStatefulWidget {
  final Student student;
  final ValueChanged<Student> onSave;
  const EditStudentSheet({
    super.key,
    required this.student,
    required this.onSave,
  });
  @override
  ConsumerState<EditStudentSheet> createState() => _State();
}

class _State extends ConsumerState<EditStudentSheet> {
  final form = GlobalKey<FormState>();
  late final TextEditingController name, phone, seat, fee, emergency, notes;
  late MembershipType membership;
  late SeatCategory category;
  String? photoPath;
  String? selectedShift;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.student.name);
    phone = TextEditingController(text: widget.student.phone);
    seat = TextEditingController(text: widget.student.seat);
    fee = TextEditingController(text: widget.student.fee.toStringAsFixed(0));
    emergency = TextEditingController(text: widget.student.emergencyContact);
    notes = TextEditingController(text: widget.student.notes);
    membership = widget.student.membership;
    category = widget.student.category;
    photoPath = widget.student.photoPath;

    if (widget.student.seat.startsWith('Flexible (') &&
        widget.student.seat.endsWith(')')) {
      selectedShift = widget.student.seat.substring(
        10,
        widget.student.seat.length - 1,
      );
    }
  }

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    seat.dispose();
    fee.dispose();
    emergency.dispose();
    notes.dispose();
    super.dispose();
  }

  Future<void> _pickCustomTimeRange() async {
    final start = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      helpText: 'Select Half-Time Shift Start Time',
    );
    if (start == null || !mounted) return;

    final end = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: (start.hour + 6) % 24, minute: start.minute),
      helpText: 'Select Half-Time Shift End Time',
    );
    if (end == null || !mounted) return;

    final formatted =
        'Custom (${start.format(context)} - ${end.format(context)})';
    setState(() {
      selectedShift = formatted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pricing = ref.watch(pricingProvider);
    final shifts = pricing.halfTimeShifts;

    if (membership == MembershipType.halfTime &&
        selectedShift == null &&
        shifts.isNotEmpty) {
      selectedShift = shifts.first;
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.viewInsetsOf(context).bottom +
            MediaQuery.paddingOf(context).bottom +
            20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      backgroundImage: photoPath == null
                          ? null
                          : FileImage(File(photoPath!)),
                      child: photoPath == null
                          ? Text(
                              widget.student.initials,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: IconButton.filled(
                        onPressed: _pickPhoto,
                        icon: const Icon(Icons.camera_alt_outlined, size: 17),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Edit Student',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Student Name'),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emergency,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Emergency Contact',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: notes,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              const SizedBox(height: 12),
              SegmentedButton<SeatCategory>(
                segments: const [
                  ButtonSegment(
                    value: SeatCategory.ac,
                    label: Text('AC Section'),
                    icon: Icon(Icons.ac_unit_rounded, size: 16),
                  ),
                  ButtonSegment(
                    value: SeatCategory.nonAc,
                    label: Text('Non-AC Section'),
                    icon: Icon(Icons.air_rounded, size: 16),
                  ),
                ],
                selected: {category},
                onSelectionChanged: (value) =>
                    setState(() => category = value.first),
              ),
              const SizedBox(height: 12),
              SegmentedButton<MembershipType>(
                segments: const [
                  ButtonSegment(
                    value: MembershipType.fullTime,
                    label: Text('Full Time'),
                  ),
                  ButtonSegment(
                    value: MembershipType.halfTime,
                    label: Text('Half Time'),
                  ),
                ],
                selected: {membership},
                onSelectionChanged: (value) =>
                    setState(() => membership = value.first),
              ),
              if (membership == MembershipType.fullTime) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: seat,
                  decoration: const InputDecoration(labelText: 'Seat Number'),
                  validator: _required,
                ),
              ] else ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Shift Time Manager',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...shifts.map((shiftOption) {
                            final isSelected = selectedShift == shiftOption;
                            return ChoiceChip(
                              label: Text(shiftOption),
                              selected: isSelected,
                              onSelected: (val) {
                                if (val) {
                                  setState(() => selectedShift = shiftOption);
                                }
                              },
                            );
                          }),
                          ActionChip(
                            avatar: const Icon(
                              Icons.more_time_rounded,
                              size: 16,
                            ),
                            label: const Text('Custom Time'),
                            onPressed: _pickCustomTimeRange,
                          ),
                        ],
                      ),
                      if (selectedShift != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          'Selected Shift: $selectedShift',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: fee,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monthly Fee',
                  prefixText: '₹  ',
                ),
                validator: _required,
              ),
              const SizedBox(height: 18),
              FilledButton(onPressed: _save, child: const Text('Save Changes')),
            ],
          ),
        ),
      ),
    );
  }

  static String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;
  void _save() {
    if (!(form.currentState?.validate() ?? false)) return;
    final finalSeat = membership == MembershipType.fullTime
        ? seat.text.trim()
        : selectedShift != null
        ? 'Flexible ($selectedShift)'
        : 'Flexible';
    widget.onSave(
      widget.student.copyWith(
        name: name.text.trim(),
        phone: phone.text.trim(),
        seat: finalSeat,
        fee: double.tryParse(fee.text) ?? widget.student.fee,
        membership: membership,
        category: category,
        photoPath: photoPath,
        emergencyContact: emergency.text.trim(),
        notes: notes.text.trim(),
      ),
    );
    Navigator.pop(context);
  }

  Future<void> _pickPhoto() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (image != null && mounted) setState(() => photoPath = image.path);
  }
}
