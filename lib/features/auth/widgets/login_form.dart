import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../controllers/auth_controller.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});
  @override
  State<LoginForm> createState() => _State();
}

class _State extends State<LoginForm> {
  final form = GlobalKey<FormState>();
  final controller = const AuthController();
  bool hidden = true, remember = true;
  @override
  Widget build(BuildContext context) => Form(
    key: form,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Email address',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFF565B6D),
          ),
        ),
        const SizedBox(height: 9),
        SizedBox(
          height: 58,
          child: TextFormField(
            initialValue: 'owner@thestudyroom.in',
            validator: controller.validateEmail,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.alternate_email, color: Color(0xFFA1A6B4)),
              filled: true,
              fillColor: Color(0xFFFAFBFD),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFF565B6D),
          ),
        ),
        const SizedBox(height: 9),
        SizedBox(
          height: 58,
          child: TextFormField(
            initialValue: 'studydesk123',
            obscureText: hidden,
            validator: controller.validatePassword,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.key_outlined,
                color: Color(0xFFA1A6B4),
              ),
              filled: true,
              fillColor: const Color(0xFFFAFBFD),
              suffixIcon: IconButton(
                onPressed: () => setState(() => hidden = !hidden),
                icon: Icon(
                  hidden
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF9BA0AE),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Checkbox(
              value: remember,
              onChanged: (v) => setState(() => remember = v ?? false),
            ),
            const Text('Remember me', style: TextStyle(fontSize: 12)),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Forgot password?',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: () {
            if (form.currentState!.validate()) context.go('/app');
          },
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(58),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 8,
            shadowColor: const Color(0x405145EA),
          ),
          child: const Row(
            children: [
              SizedBox(width: 8),
              Text(
                'Sign in',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              Spacer(),
              Icon(Icons.north_east, size: 20),
              SizedBox(width: 8),
            ],
          ),
        ),
      ],
    ),
  );
}
