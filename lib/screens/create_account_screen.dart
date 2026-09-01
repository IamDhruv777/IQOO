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
                        child: Container(
                          width: 200,
                          height: 140,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colors.surfaceElevated.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colors.primary.withValues(alpha: 0.4),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_circle_outline, color: colors.primary, size: 32),
                              const SizedBox(height: 12),
                              Text(
                                'Your first memory\nstarts here.',
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
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
                          'Future you is going to appreciate this.',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Let\'s make some memories.',
                          style: GoogleFonts.manrope(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
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
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _btnAnim,
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: _createAccount,
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
                            'Create Account →',
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
                              'Already have an account?',
                              style: GoogleFonts.manrope(
                                color: colors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Sign In →',
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
                        const SizedBox(height: 16),
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
