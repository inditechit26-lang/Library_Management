import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../widgets/login_form.dart';
import '../widgets/signup_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgAnimationController;
  late final AnimationController _entranceController;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool _isSignUp = false;

  @override
  void initState() {
    super.initState();

    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));

    _entranceController.forward();
  }

  @override
  void dispose() {
    _bgAnimationController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    // Billion-dollar curated luxury color palette (CRED / Stripe dark mode aesthetic)
    final bgGradient = isDark
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D0F17),
              Color(0xFF07080C),
              Color(0xFF0B0D14),
            ],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFEEF2F6),
              Color(0xFFF1F5F9),
            ],
          );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: Stack(
          children: [
            // Ambient Low-Opacity Shimmer Orbs (Billion Dollar Glow Effect)
            AnimatedBuilder(
              animation: _bgAnimationController,
              builder: (context, child) {
                final val = _bgAnimationController.value;
                final dx1 = math.sin(val * math.pi * 2) * 22;
                final dy1 = math.cos(val * math.pi * 2) * 26;

                return Stack(
                  children: [
                    // Top Primary Glow Orb
                    Positioned(
                      top: -120 + dy1,
                      right: -100 + dx1,
                      child: Container(
                        width: 440,
                        height: 440,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF6366F1).withOpacity(isDark ? 0.28 : 0.16),
                              const Color(0xFF4F46E5).withOpacity(isDark ? 0.10 : 0.05),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Secondary Violet Accent Glow Orb
                    Positioned(
                      bottom: -130 - dy1,
                      left: -100 - dx1,
                      child: Container(
                        width: 420,
                        height: 420,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF8B5CF6).withOpacity(isDark ? 0.22 : 0.12),
                              const Color(0xFF7C3AED).withOpacity(isDark ? 0.08 : 0.03),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Top Section: Large App Logo, Title & Subtitle Centered
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF6366F1),
                                    Color(0xFF8B5CF6),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6366F1).withOpacity(0.42),
                                    blurRadius: 28,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.local_library_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Library Management',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.9,
                                fontSize: 27,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Smart Management for Modern Libraries',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.1,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Floating Authentication Card (36px rounded corners, glass effect)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 320),
                              curve: Curves.easeInOutCubic,
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF131724).withOpacity(0.94)
                                    : Colors.white.withOpacity(0.96),
                                borderRadius: BorderRadius.circular(36),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF262C40)
                                      : const Color(0xFFE2E8F0),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? Colors.black.withOpacity(0.55)
                                        : const Color(0xFF1E293B).withOpacity(0.09),
                                    blurRadius: 44,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 18),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isSignUp ? 'Create Your Account' : 'Welcome Back',
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 22,
                                      letterSpacing: -0.6,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _isSignUp
                                        ? 'Start managing your library in minutes.'
                                        : 'Sign in to continue managing your library.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 28),

                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: _isSignUp
                                        ? SignupForm(
                                            key: const ValueKey('signup'),
                                            onLoginTap: () => setState(() => _isSignUp = false),
                                          )
                                        : LoginForm(
                                            key: const ValueKey('login'),
                                            onSignupTap: () => setState(() => _isSignUp = true),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Bottom Switch Text
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _isSignUp
                                      ? 'Already have an account? '
                                      : "Don't have an account? ",
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() => _isSignUp = !_isSignUp),
                                  child: Text(
                                    _isSignUp ? 'Sign In' : 'Create Account',
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF6366F1),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
