import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'sign_in_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with SingleTickerProviderStateMixin {
  final List<String> _quotes = [
    "Because 'I'll remember this' is historically unreliable.",
    "Your brain called. It wants some storage space back.",
    "Take the photo. Forget the details. We've got the memory.",
    "Life is short. Your camera roll is not.",
    "Your gallery stores pictures. MemoryLens stores why they mattered."
  ];

  int _currentQuoteIndex = 0;
  Timer? _timer;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentQuoteIndex = (_currentQuoteIndex + 1) % _quotes.length;
        });
      }
    });

    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));

    _animController.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mlColors = context.mlColors;
    
    return Scaffold(
      backgroundColor: mlColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Logo
              FadeTransition(
                opacity: _fadeAnimation,
                child: Row(
                  children: [
                    Icon(Icons.camera_alt_outlined, color: mlColors.primary, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'MemoryLens',
                      style: GoogleFonts.yellowtail(
                        fontSize: 28,
                        color: mlColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(flex: 2),

              // Hero Statement
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your camera\nremembers what',
                        style: GoogleFonts.manrope(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: mlColors.textPrimary,
                          height: 1.1,
                          letterSpacing: -1,
                        ),
                      ),
                      Text(
                        "you don't.",
                        style: GoogleFonts.yellowtail(
                          fontSize: 48,
                          color: mlColors.primary,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // Floating Memory Visual
              FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: mlColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: mlColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: mlColors.primary.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: mlColors.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.push_pin_outlined, color: mlColors.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('HACKATHON 2026', style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w800, color: mlColors.textPrimary)),
                                Text('Registration closes Sep 5', style: GoogleFonts.manrope(fontSize: 12, color: mlColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Rotating Quote
              SizedBox(
                height: 48,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 800),
                    child: Text(
                      _quotes[_currentQuoteIndex],
                      key: ValueKey<int>(_currentQuoteIndex),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: mlColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),

              // Get Started Button
              ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutBack)),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const SignInScreen(),
                          transitionsBuilder: (_, a, __, c) => SlideTransition(
                            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(
                              CurvedAnimation(parent: a, curve: Curves.easeOutCubic),
                            ),
                            child: c,
                          ),
                          transitionDuration: const Duration(milliseconds: 400),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mlColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Get Started',
                          style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
