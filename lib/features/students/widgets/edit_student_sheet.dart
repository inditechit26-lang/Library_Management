import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/student.dart';

class EditStudentSheet extends StatefulWidget {
  final Student student;
  final ValueChanged<Student> onSave;
  const EditStudentSheet({
    super.key,
    required this.student,
    required this.onSave,
  });
  @override
  State<EditStudentSheet> createState() => _State();
}

class _State extends State<EditStudentSheet> {
  final form = GlobalKey<FormState>();
  late final TextEditingController name, phone, seat, fee, emergency, notes;
  late MembershipType membership;
  String? photoPath;
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
    photoPath = widget.student.photoPath;
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

  @override
  Widget build(BuildContext context) => Padding(
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
                  color: const Color(0xFFD9DBE4),
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
                            style: const TextStyle(fontWeight: FontWeight.w800),
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
              decoration: const InputDecoration(labelText: 'Emergency Contact'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: notes,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notes'),
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

  static String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;
  void _save() {
    if (!(form.currentState?.validate() ?? false)) return;
    widget.onSave(
      widget.student.copyWith(
        name: name.text.trim(),
        phone: phone.text.trim(),
        seat: membership == MembershipType.fullTime
            ? seat.text.trim()
            : 'Flexible',
        fee: double.tryParse(fee.text) ?? widget.student.fee,
        membership: membership,
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
