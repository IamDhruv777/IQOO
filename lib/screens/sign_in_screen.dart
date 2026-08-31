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

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _handleSignIn() {
    // Prototype: Accept any input and authenticate
    ref.read(authProvider.notifier).authenticate();
    
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AppShell(),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mlColors = context.mlColors;

    return Scaffold(
      backgroundColor: mlColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: mlColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'MemoryLens',
          style: GoogleFonts.yellowtail(color: mlColors.textPrimary, fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text(
                'Welcome back.',
                style: GoogleFonts.manrope(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: mlColors.textPrimary,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Let's find what you forgot.",
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  color: mlColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),

              // Email Field
              Text(
                'Email',
                style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: mlColors.textPrimary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.manrope(color: mlColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'you@example.com',
                  prefixIcon: Icon(Icons.mail_outline, color: mlColors.icon),
                ),
              ),
              
              const SizedBox(height: 24),

              // Password Field
              Text(
                'Password',
                style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: mlColors.textPrimary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: GoogleFonts.manrope(color: mlColors.textPrimary),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: Icon(Icons.lock_outline, color: mlColors.icon),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: mlColors.icon,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              
              const SizedBox(height: 48),

              // Sign In Button
              ElevatedButton(
                onPressed: _handleSignIn,
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
                      'Sign In',
                      style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Create Account Link
              Center(
                child: Column(
                  children: [
                    Text(
                      'New around here?',
                      style: GoogleFonts.manrope(color: mlColors.textSecondary, fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const CreateAccountScreen(),
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
                      style: TextButton.styleFrom(
                        foregroundColor: mlColors.primary,
                      ),
                      child: Text(
                        'Create your memory space',
                        style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
