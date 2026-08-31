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

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  void _handleCreateAccount() {
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
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
              const SizedBox(height: 16),
              Text(
                "Let's make some\nmemories.",
                style: GoogleFonts.manrope(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: mlColors.textPrimary,
                  height: 1.1,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Not the emotional kind. The searchable kind.",
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  color: mlColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),

              // Name Field
              Text(
                'Full Name',
                style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: mlColors.textPrimary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: GoogleFonts.manrope(color: mlColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'John Doe',
                  prefixIcon: Icon(Icons.person_outline, color: mlColors.icon),
                ),
              ),
              
              const SizedBox(height: 20),

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
              
              const SizedBox(height: 20),

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

              const SizedBox(height: 20),

              // Confirm Password Field
              Text(
                'Confirm Password',
                style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: mlColors.textPrimary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                style: GoogleFonts.manrope(color: mlColors.textPrimary),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: Icon(Icons.lock_outline, color: mlColors.icon),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: mlColors.icon,
                    ),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
              ),
              
              const SizedBox(height: 48),

              // Create Button
              ElevatedButton(
                onPressed: _handleCreateAccount,
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
                      'Create Account',
                      style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              Center(
                child: Text(
                  "Your future self will thank you.",
                  style: GoogleFonts.manrope(color: mlColors.textSecondary, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
