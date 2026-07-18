import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../students/controllers/students_controller.dart';
import '../../students/models/student.dart';
import '../controllers/admission_controller.dart';
import 'plan_selector.dart';

class AdmissionForm extends ConsumerStatefulWidget {
  const AdmissionForm({super.key});
  @override
  ConsumerState<AdmissionForm> createState() => _AdmissionFormState();
}

class _AdmissionFormState extends ConsumerState<AdmissionForm> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      phone = TextEditingController(),
      seat = TextEditingController(),
      fee = TextEditingController(text: '1800');
  MembershipType type = MembershipType.fullTime;
  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    seat.dispose();
    fee.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Form(
    key: form,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: name,
          validator: (value) => value!.trim().isEmpty ? 'Required' : null,
          decoration: const InputDecoration(labelText: 'Student name'),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: phone,
          validator: (value) =>
              value!.length < 10 ? 'Enter mobile number' : null,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Mobile number'),
        ),
        const SizedBox(height: 10),
        PlanSelector(
          value: type,
          onChanged: (value) => setState(() => type = value),
        ),
        const SizedBox(height: 10),
        if (type == MembershipType.fullTime)
          TextFormField(
            controller: seat,
            decoration: const InputDecoration(labelText: 'Seat number'),
          ),
        const SizedBox(height: 10),
        TextFormField(
          controller: fee,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Monthly fee'),
        ),
        const SizedBox(height: 18),
        FilledButton(onPressed: _submit, child: const Text('Create Admission')),
      ],
    ),
  );
  void _submit() {
    if (!form.currentState!.validate()) return;
    final students = ref.read(studentsProvider);
    ref
        .read(studentsProvider.notifier)
        .add(
          AdmissionController.create(
            id: students.length + 1,
            name: name.text,
            phone: phone.text,
            seat: seat.text,
            fee: fee.text,
            membership: type,
          ),
        );
    Navigator.pop(context);
  }
}
