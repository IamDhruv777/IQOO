import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_service.dart';
import '../theme/app_theme.dart';
import '../widgets/manual_reminder_sheet.dart';
import 'home_screen.dart';
import 'memories_screen.dart';
import 'remember_screen.dart';
import 'search_screen.dart';
import 'processing_screen.dart';

/// The main navigation shell. Wraps Home, Remember, and Search in an
/// IndexedStack with a persistent bottom NavigationBar.
/// The Capture destination (index 2) intercepts the tap and opens the
/// capture bottom sheet instead of switching to a screen.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _navIndex = 0; // Stores the NavigationBar index (0, 1, 2, 3)
  bool _captureBusy = false;

  static const _screens = [
    HomeScreen(),
    MemoriesScreen(),
    SearchScreen(),
  ];

  // Map bottom nav index to screen index (skip index 1 which is capture)
  int _screenIndex(int navIdx) => navIdx == 0 ? 0 : navIdx - 1;

  void _onNavTap(int index) {
    if (index == 1) { // Capture is at index 1
      _showCaptureSheet();
      return; // Do not update _navIndex
    }
    if (_navIndex != index) {
      setState(() => _navIndex = index);
    }
  }

  Future<void> _showCaptureSheet() async {
    if (_captureBusy) return;
    final mlColors = context.mlColors;

    await showModalBottomSheet(
      context: context,
      backgroundColor: mlColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // drag handle
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: mlColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Add a Memory',
                style: GoogleFonts.manrope(
                  fontSize: 20, fontWeight: FontWeight.w700, color: mlColors.textPrimary,
                ),
              ),
              Text(
                'Capture something worth remembering.',
                style: GoogleFonts.manrope(fontSize: 13, color: mlColors.textSecondary),
              ),
              const SizedBox(height: 24),
              _CaptureOption(
                icon: Icons.camera_alt_rounded,
                label: 'Take Photo',
                subtitle: 'Use your camera',
                color: mlColors.primary,
                onTap: () {
                  Navigator.pop(ctx);
                  _capture(ImageSource.camera);
                },
                mlColors: mlColors,
              ),
              const SizedBox(height: 12),
              _CaptureOption(
                icon: Icons.photo_library_rounded,
                label: 'Choose from Gallery',
                subtitle: 'Pick an existing photo',
                color: mlColors.accent,
                onTap: () {
                  Navigator.pop(ctx);
                  _capture(ImageSource.gallery);
                },
                mlColors: mlColors,
              ),
              const SizedBox(height: 12),
              _CaptureOption(
                icon: Icons.edit_calendar_rounded,
                label: 'Manual Reminder',
                subtitle: 'Skip AI, pick a photo and set reminder',
                color: mlColors.warning,
                onTap: () {
                  Navigator.pop(ctx);
                  _manualReminder();
                },
                mlColors: mlColors,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _manualReminder() async {
    if (_captureBusy) return;
    setState(() => _captureBusy = true);
    try {
      final imageService = ImageService();
      final xFile = await imageService.pickFromGallery();
      if (xFile == null || !mounted) return;
      final localPath = await imageService.saveImageLocally(xFile);
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => ManualReminderSheet(imageFile: File(localPath)),
      );
    } finally {
      if (mounted) setState(() => _captureBusy = false);
    }
  }

  Future<void> _capture(ImageSource source) async {
    if (_captureBusy) return;
    setState(() => _captureBusy = true);
    try {
      final imageService = ImageService();
      final xFile = source == ImageSource.camera
          ? await imageService.captureFromCamera()
          : await imageService.pickFromGallery();
      if (xFile == null || !mounted) return;
      final localPath = await imageService.saveImageLocally(xFile);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProcessingScreen(
            imageFile: File(localPath),
            localPath: localPath,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _captureBusy = false);
    }
  }

  Future<bool?> _showExitDialog() {
    final mlColors = context.mlColors;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: mlColors.surface,
        title: Text('Escaping reality? 🚪', 
            style: TextStyle(color: mlColors.textPrimary, fontWeight: FontWeight.bold)),
        content: Text('Your past is safely stored here. Do you really want to return to the present?',
            style: TextStyle(color: mlColors.textSecondary, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Stay in the Past', style: TextStyle(color: mlColors.primary, fontWeight: FontWeight.bold)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: mlColors.error),
            child: const Text('Exit App'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mlColors = context.mlColors;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (_navIndex != 0) {
          setState(() => _navIndex = 0);
        } else {
          final exit = await _showExitDialog();
          if (exit == true) {
            SystemNavigator.pop();
          }
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: mlColors.surface,
        systemNavigationBarIconBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: mlColors.background,
        body: IndexedStack(
          index: _screenIndex(_navIndex),
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: mlColors.border, width: 0.5)),
          ),
          child: NavigationBar(
            selectedIndex: _navIndex,
            onDestinationSelected: _onNavTap,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              // Capture — styled distinctly, placed 2nd
              NavigationDestination(
                icon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: mlColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                ),
                selectedIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: mlColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                ),
                label: 'Capture',
              ),
              const NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view_rounded),
                label: 'Memories',
              ),
              const NavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search_rounded),
                label: 'Search',
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}

class _CaptureOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final MemoryLensColors mlColors;

  const _CaptureOption({
    required this.icon, required this.label, required this.subtitle,
    required this.color, required this.onTap, required this.mlColors,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: mlColors.surfaceSecondary,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: mlColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.manrope(
                    fontSize: 15, fontWeight: FontWeight.w700, color: mlColors.textPrimary,
                  )),
                  Text(subtitle, style: GoogleFonts.manrope(
                    fontSize: 12, color: mlColors.textSecondary,
                  )),
                ],
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: mlColors.icon),
            ],
          ),
        ),
      ),
    );
  }
}
