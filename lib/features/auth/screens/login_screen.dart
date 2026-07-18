import 'package:flutter/material.dart';
import '../widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF3F1FF), Colors.white, Colors.white],
          stops: [0, .42, 1],
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 135, 22, 30),
          children: [
            Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF574DEB),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x30574DEB),
                            blurRadius: 22,
                            offset: Offset(0, 9),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.menu_book_outlined,
                        color: Colors.white,
                        size: 27,
                      ),
                    ),
                    const Positioned(
                      right: -2,
                      top: -2,
                      child: CircleAvatar(
                        radius: 3,
                        backgroundColor: Color(0xFF72DFB3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 13),
                const Text(
                  'StudyDesk',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 68),
            const Text(
              'WELCOME BACK',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 2,
                color: Color(0xFF999EAF),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Sign in to your library',
              style: TextStyle(
                fontSize: 29,
                height: 1,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Enter your details to continue to your workspace.',
              style: TextStyle(fontSize: 14, color: Color(0xFF9196A8)),
            ),
            const SizedBox(height: 34),
            const LoginForm(),
            const SizedBox(height: 28),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield_outlined, color: Color(0xFF3AB080), size: 17),
                SizedBox(width: 8),
                Text(
                  'Secure owner-only access',
                  style: TextStyle(fontSize: 11, color: Color(0xFF9A9FAE)),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
