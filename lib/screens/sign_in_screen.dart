import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'app_shell.dart';
import 'create_account_screen.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;

  late AnimationController _animController;
  late Animation<double> _logoAnim;
  late Animation<double> _cardsAnim;
  late Animation<double> _formAnim;
  late Animation<double> _formScaleAnim;
  late Animation<double> _btnAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _logoAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );

    _cardsAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    );

    _formAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
    );

    _formScaleAnim = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _btnAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _signIn() async {
    await ref.read(authProvider.notifier).authenticate();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AppShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.mlColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _BackgroundPainter(colors: colors),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FadeTransition(
                    opacity: _logoAnim,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
                        ),
                        const Spacer(),
                        Icon(Icons.camera_alt, color: colors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'MemoryLens',
                          style: GoogleFonts.yellowtail(
                            fontSize: 20,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  FadeTransition(
                    opacity: _cardsAnim,
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(_cardsAnim),
                      child: Center(
                        child: SizedBox(
                          height: 180,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              _buildMiniCard(colors, 5, 20, '📌 HACKATHON 2026', 'Sep 5'),
                              _buildMiniCard(colors, -3, 10, '💼 INTERNSHIP', 'Apply by Sep 15'),
                              _buildMiniCard(colors, 0, 0, '🧾 ELECTRICITY BILL', '₹1,842'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _formAnim,
                    child: Column(
                      children: [
                        Text(
                          'Let\'s find what you forgot.',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Welcome back.',
                          style: GoogleFonts.manrope(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your memories have been waiting.',
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            color: colors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  FadeTransition(
                    opacity: _formAnim,
                    child: ScaleTransition(
                      scale: _formScaleAnim,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: colors.surfaceElevated,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: colors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email',
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.mail_outline),
                                hintText: 'you@example.com',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Password',
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock_outline),
                                hintText: '••••••••',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _signIn(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _btnAnim,
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: colors.surface,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            minimumSize: const Size(double.infinity, 56),
                          ),
                          child: Text(
                            'Sign In →',
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'New here?',
                              style: GoogleFonts.manrope(
                                color: colors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => const CreateAccountScreen(),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      const begin = Offset(1.0, 0.0);
                                      const end = Offset.zero;
                                      const curve = Curves.ease;
                                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                      return SlideTransition(position: animation.drive(tween), child: child);
                                    },
                                  ),
                                );
                              },
                              child: Text(
                                'Create your memory space',
                                style: GoogleFonts.manrope(
                                  color: colors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Memories stored on-device · AI processing uses remote services',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            color: colors.textSecondary.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCard(MemoryLensColors colors, double rotationDeg, double yOffset, String title, String subtitle) {
    return Transform.translate(
      offset: Offset(0, yOffset),
      child: Transform.rotate(
        angle: rotationDeg * pi / 180,
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: colors.textPrimary.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final MemoryLensColors colors;

  _BackgroundPainter({required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = colors.primary.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;
    
    final paint2 = Paint()
      ..color = colors.primary.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.2), 120, paint1);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.5), 150, paint1);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.8), 100, paint1);

    final path = Path();
    path.moveTo(0, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.3, size.width, size.height * 0.5);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    canvas.drawPath(path, paint2);

    final path2 = Path();
    path2.moveTo(0, size.height);
    path2.lineTo(size.width, size.height);
    path2.lineTo(size.width, size.height * 0.7);
    path2.quadraticBezierTo(size.width * 0.5, size.height * 0.9, 0, size.height * 0.8);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
