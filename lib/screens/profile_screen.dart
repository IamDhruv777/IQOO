import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/memory_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mlColors = context.mlColors;
    final memoriesState = ref.watch(memoriesProvider);
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: mlColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: mlColors.icon),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Avatar
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [mlColors.accent, mlColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: mlColors.border, width: 3),
                ),
                child: const Center(
                  child: Text(
                    'V',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Visionary',
                style: GoogleFonts.yellowtail(
                  fontSize: 32,
                  color: mlColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'visionary@hackathon.com',
                style: TextStyle(
                  fontSize: 14,
                  color: mlColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),

              // Stats Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: mlColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: mlColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          memoriesState.maybeWhen(
                            data: (memories) => memories.length.toString(),
                            orElse: () => '-',
                          ),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: mlColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Memories',
                          style: TextStyle(
                            fontSize: 12,
                            color: mlColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Container(width: 1, height: 40, color: mlColors.border),
                    Column(
                      children: [
                        Text(
                          '0',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: mlColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Reminders',
                          style: TextStyle(
                            fontSize: 12,
                            color: mlColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Theme Settings
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Appearance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: mlColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: mlColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: mlColors.border),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.brightness_auto, color: mlColors.primary),
                      title: Text('System Default', style: TextStyle(color: mlColors.textPrimary)),
                      subtitle: Text('Follows your device', style: TextStyle(color: mlColors.textSecondary, fontSize: 12)),
                      trailing: themeMode == ThemeMode.system
                          ? Icon(Icons.check_circle, color: mlColors.primary)
                          : null,
                      onTap: () => ref.read(themeProvider.notifier).setTheme(ThemeMode.system),
                    ),
                    Divider(height: 1, color: mlColors.border),
                    ListTile(
                      leading: Icon(Icons.light_mode, color: mlColors.primary),
                      title: Text('Light Mode', style: TextStyle(color: mlColors.textPrimary)),
                      subtitle: Text('Warm cream', style: TextStyle(color: mlColors.textSecondary, fontSize: 12)),
                      trailing: themeMode == ThemeMode.light
                          ? Icon(Icons.check_circle, color: mlColors.primary)
                          : null,
                      onTap: () => ref.read(themeProvider.notifier).setTheme(ThemeMode.light),
                    ),
                    Divider(height: 1, color: mlColors.border),
                    ListTile(
                      leading: Icon(Icons.dark_mode, color: mlColors.primary),
                      title: Text('Dark Mode', style: TextStyle(color: mlColors.textPrimary)),
                      subtitle: Text('Deep warm brown', style: TextStyle(color: mlColors.textSecondary, fontSize: 12)),
                      trailing: themeMode == ThemeMode.dark
                          ? Icon(Icons.check_circle, color: mlColors.primary)
                          : null,
                      onTap: () => ref.read(themeProvider.notifier).setTheme(ThemeMode.dark),
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
