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
      duration: const Duration(milliseconds: 900),
    );

    _logoAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );

    _cardsAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOutBack),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ArtisticBackgroundPainter(
                    colors: colors,
                    isDark: isDark,
                    animationValue: _animController.value,
                  ),
                );
              }
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
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
                                  Icon(Icons.camera_alt, color: colors.primary, size: 24),
                                  const SizedBox(width: 8),
                                  Text(
                                    'MemoryLens',
                                    style: GoogleFonts.yellowtail(
                                      fontSize: 24,
                                      color: colors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            FadeTransition(
                              opacity: _cardsAnim,
                              child: SlideTransition(
                                position: Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero).animate(_cardsAnim),
                                child: Center(
                                  child: SizedBox(
                                    height: 220,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        _build3DCard(colors, -25, 0.8, -40, '📌 HACKATHON 2026', 'Sep 5', const Color(0xFF9D88F2)),
                                        _build3DCard(colors, 15, 0.9, 20, '💼 INTERNSHIP', 'Apply by Sep 15', const Color(0xFFF28888)),
                                        _build3DCard(colors, -5, 1.0, 0, '🧾 ELECTRICITY BILL', '₹1,842', const Color(0xFF88F2A3)),
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
                                    'Welcome back.',
                                    style: GoogleFonts.manrope(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w900,
                                      color: colors.textPrimary,
                                      height: 1.1,
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
                                    boxShadow: [
                                      BoxShadow(
                                        color: colors.primary.withValues(alpha: 0.15),
                                        blurRadius: 30,
                                        offset: const Offset(0, 15),
                                      ),
                                    ],
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
                            const Expanded(child: SizedBox(height: 24)),
                            FadeTransition(
                              opacity: _btnAnim,
                              child: Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: _signIn,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colors.primary,
                                      foregroundColor: colors.surface,
                                      padding: const EdgeInsets.symmetric(vertical: 20),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 8,
                                      shadowColor: colors.primary.withValues(alpha: 0.5),
                                      minimumSize: const Size(double.infinity, 60),
                                    ),
                                    child: Text(
                                      'Sign In →',
                                      style: GoogleFonts.manrope(
                                        fontSize: 18,
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
                                          fontWeight: FontWeight.w600,
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
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DCard(MemoryLensColors colors, double rotationDeg, double scale, double yOffset, String title, String subtitle, Color iconColor) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..translate(0.0, yOffset, 0.0)
        ..rotateZ(rotationDeg * pi / 180)
        ..scale(scale),
      alignment: FractionalOffset.center,
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border, width: 2),
          boxShadow: [
            BoxShadow(
              color: colors.textPrimary.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.memory, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: iconColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtisticBackgroundPainter extends CustomPainter {
  final MemoryLensColors colors;
  final bool isDark;
  final double animationValue;

  _ArtisticBackgroundPainter({required this.colors, required this.isDark, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final double opacityBase = isDark ? 0.35 : 0.25;
    
    final paint1 = Paint()
      ..color = colors.primary.withValues(alpha: opacityBase)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
      
    final paint2 = Paint()
      ..color = colors.accent.withValues(alpha: opacityBase * 0.8)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);
      
    final paint3 = Paint()
      ..color = const Color(0xFFF28888).withValues(alpha: opacityBase * 0.6)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);

    final offset1 = sin(animationValue * pi) * 20;
    
    canvas.drawCircle(Offset(size.width * 0.2 - offset1, size.height * 0.2 + offset1), 200, paint1);
    canvas.drawCircle(Offset(size.width * 0.8 + offset1, size.height * 0.6 - offset1), 180, paint2);
    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.9), 160, paint3);
    
    final ringPaint = Paint()
      ..color = colors.primary.withValues(alpha: isDark ? 0.15 : 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
      
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.4), 280, ringPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.4), 360, ringPaint..strokeWidth = 1.0);
    
    final accentPaint = Paint()
      ..color = colors.accent.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), 6, accentPaint);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.5), 4, accentPaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.8), 5, accentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
