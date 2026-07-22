import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StudentInformationCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController name, phone, emergency, notes;
  const StudentInformationCard({
    super.key,
    required this.formKey,
    required this.name,
    required this.phone,
    required this.emergency,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) => Form(
    key: formKey,
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: _decoration,
      child: Column(
        children: [
          TextFormField(
            controller: name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Student Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 13),
          TextFormField(
            controller: phone,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Mobile Number',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            validator: (value) =>
                (value ?? '').replaceAll(RegExp(r'\D'), '').length != 10
                ? 'Enter a valid 10-digit mobile number'
                : null,
          ),
          const SizedBox(height: 13),
          TextFormField(
            controller: emergency,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Emergency Contact (Optional)',
              prefixIcon: Icon(Icons.contact_phone_outlined),
            ),
          ),
          const SizedBox(height: 13),
          TextFormField(
            controller: notes,
            textCapitalization: TextCapitalization.sentences,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notes (Optional)',
              prefixIcon: Icon(Icons.notes_outlined),
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    ),
  );

  static final _decoration = BoxDecoration(
    color: Colors.white,
    border: Border.all(color: const Color(0xFFE5E7EF)),
    borderRadius: BorderRadius.circular(22),
    boxShadow: const [
      BoxShadow(color: Color(0x0A20243B), blurRadius: 28, offset: Offset(0, 9)),
    ],
  );
}
