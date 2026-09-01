import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'app_shell.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
      curve: const Interval(0.2, 0.6, curve: Curves.easeOutBack),
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    
    _animController.dispose();
    super.dispose();
  }

  void _createAccount() async {
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
                              child: ScaleTransition(
                                scale: Tween<double>(begin: 0.8, end: 1.0).animate(_cardsAnim),
                                child: Center(
                                  child: Container(
                                    width: double.infinity,
                                    height: 160,
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: colors.surfaceElevated.withValues(alpha: 0.8),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: CustomPaint(
                                      painter: _DashedBorderPainter(color: colors.primary, strokeWidth: 3, radius: 24),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_circle_outline, color: colors.primary, size: 48),
                                          const SizedBox(height: 16),
                                          Text(
                                            'New Memory Space',
                                            style: GoogleFonts.manrope(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w900,
                                              color: colors.textPrimary,
                                              letterSpacing: 1.2,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            FadeTransition(
                              opacity: _formAnim,
                              child: Column(
                                children: [
                                  Text(
                                    'Let\'s make some memories.',
                                    style: GoogleFonts.manrope(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: colors.textPrimary,
                                      height: 1.2,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Not the emotional kind. The searchable kind.',
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
                                        color: colors.primary.withValues(alpha: 0.1),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('Full Name', colors),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: _nameController,
                                        focusNode: _nameFocusNode,
                                        decoration: const InputDecoration(
                                          prefixIcon: Icon(Icons.person_outline),
                                          hintText: 'John Doe',
                                        ),
                                        textInputAction: TextInputAction.next,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildLabel('Email', colors),
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
                                      _buildLabel('Password', colors),
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
                                        textInputAction: TextInputAction.next,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildLabel('Confirm Password', colors),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: _confirmPasswordController,
                                        focusNode: _confirmPasswordFocusNode,
                                        obscureText: _obscureConfirmPassword,
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(Icons.lock_reset_outlined),
                                          hintText: '••••••••',
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscureConfirmPassword = !_obscureConfirmPassword;
                                              });
                                            },
                                          ),
                                        ),
                                        textInputAction: TextInputAction.done,
                                        onSubmitted: (_) => _createAccount(),
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
                                    onPressed: _createAccount,
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
                                      'Create Account →',
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
                                        'Already have an account?',
                                        style: GoogleFonts.manrope(
                                          color: colors.textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          'Sign In →',
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

  Widget _buildLabel(String text, MemoryLensColors colors) {
    return Text(
      text,
      style: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: colors.textPrimary,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;

  _DashedBorderPainter({required this.color, required this.strokeWidth, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final RRect rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    final Path path = Path()..addRRect(rrect);
    
    Path dashPath = Path();
    const double dashWidth = 10.0;
    const double dashSpace = 8.0;
    double distance = 0.0;
    
    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
      distance = 0.0;
    }
    
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ArtisticBackgroundPainter extends CustomPainter {
  final MemoryLensColors colors;
  final bool isDark;
  final double animationValue;

  _ArtisticBackgroundPainter({required this.colors, required this.isDark, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final double opacityBase = isDark ? 0.3 : 0.2;
    
    final paint1 = Paint()
      ..color = colors.primary.withValues(alpha: opacityBase)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
      
    final paint2 = Paint()
      ..color = colors.accent.withValues(alpha: opacityBase * 0.8)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);
      
    final paint3 = Paint()
      ..color = const Color(0xFFF28888).withValues(alpha: opacityBase * 0.6) // Terracotta/Peach
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);

    // Animated blobs
    final offset1 = sin(animationValue * pi) * 20;
    canvas.drawCircle(Offset(size.width * 0.8 + offset1, size.height * 0.2 - offset1), 180, paint1);
    canvas.drawCircle(Offset(size.width * 0.2 - offset1, size.height * 0.7 + offset1), 200, paint2);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.9), 150, paint3);
    
    // Lens rings
    final ringPaint = Paint()
      ..color = colors.primary.withValues(alpha: isDark ? 0.1 : 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
      
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.3), 300, ringPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.3), 400, ringPaint..strokeWidth = 1.0);
    
    // Tiny floating accents
    final accentPaint = Paint()
      ..color = colors.accent.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.15), 4, accentPaint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.6), 3, accentPaint);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.85), 5, accentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
