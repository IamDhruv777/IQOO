import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/memory.dart';
import '../providers/memory_provider.dart';
import '../services/ai_service.dart';
import '../services/image_service.dart';
import '../services/sync_service.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart';
import '../utils/seed_data.dart';
import '../widgets/empty_state.dart';
import 'memory_details_screen.dart';
import 'memories_screen.dart';
import 'processing_screen.dart';
import 'profile_screen.dart';
import 'reminders_screen.dart';
import 'search_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _seedLoading = false;
  bool _isSyncing = false;
  int _syncProgress = 0;
  int _syncTotal = 0;

  @override
  void initState() {
    super.initState();
    _ensureSeedData();
  }

  Future<void> _ensureSeedData() async {
    if (_seedLoading) return;
    setState(() => _seedLoading = true);
    try {
      await insertSeedData();
      if (mounted) ref.read(memoriesProvider.notifier).refresh();
    } catch (_) {}
    if (mounted) setState(() => _seedLoading = false);
  }

  Future<void> _handleCapture(ImageSource source) async {
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
        builder: (_) => ProcessingScreen(imageFile: File(localPath), localPath: localPath),
      ),
    ).then((_) {
      if (mounted) ref.read(memoriesProvider.notifier).refresh();
    });
  }

  Future<void> _handleSmartSync() async {
    setState(() { _isSyncing = true; _syncProgress = 0; _syncTotal = 0; });
    final files = await SyncService().getRecentImages(count: 5);
    if (files.isEmpty) {
      setState(() => _isSyncing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No images found. Check gallery permissions in Settings.'),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      }
      return;
    }
    setState(() => _syncTotal = files.length);
    for (final file in files) {
      Memory result;
      try {
        result = await AiService().extractFromImage(file, file.path);
      } catch (e) {
        result = Memory(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          imagePath: file.path, title: 'Sync Failed',
          createdAt: DateTime.now(), processingFailed: true,
        );
      }
      await ref.read(memoriesProvider.notifier).addMemory(result);
      if (mounted) { setState(() => _syncProgress++); ref.read(memoriesProvider.notifier).refresh(); }
      await Future.delayed(const Duration(milliseconds: 1500));
    }
    if (mounted) {
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Smart Sync complete!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final memoriesAsync = ref.watch(memoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mlColors = context.mlColors;

    return Scaffold(
      backgroundColor: mlColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ─── Header ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: branding + avatar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting(),
                              style: GoogleFonts.manrope(
                                fontSize: 13, fontWeight: FontWeight.w500,
                                color: mlColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Visionary',
                              style: GoogleFonts.yellowtail(fontSize: 34, color: mlColors.primary),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // Smart Sync icon button
                            GestureDetector(
                              onTap: _isSyncing ? null : _handleSmartSync,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: mlColors.surfaceSecondary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: mlColors.border),
                                ),
                                child: _isSyncing
                                    ? Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: CircularProgressIndicator(strokeWidth: 2, color: mlColors.primary),
                                      )
                                    : Icon(Icons.sync_rounded, size: 20, color: mlColors.icon),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Seed indicator
                            if (_seedLoading)
                              SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: mlColors.primary),
                              ),
                            const SizedBox(width: 10),
                            // Avatar → Profile
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ProfileScreen()),
                              ),
                              child: Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: mlColors.primaryContainer,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: mlColors.primary.withValues(alpha: 0.3)),
                                ),
                                child: Center(
                                  child: Text('V', style: TextStyle(
                                    fontWeight: FontWeight.bold, color: mlColors.primary, fontSize: 16,
                                  )),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your memories, understood.',
                      style: GoogleFonts.manrope(fontSize: 13, color: mlColors.textSecondary),
                    ),
                    const SizedBox(height: 24),

                    // ─── Capture CTAs ───
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: GestureDetector(
                            onTap: () => _handleCapture(ImageSource.camera),
                            child: Container(
                              height: 130,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [mlColors.accent, mlColors.primary],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: mlColors.primary.withValues(alpha: 0.28),
                                    blurRadius: 16, offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.camera_alt_rounded, color: Colors.white, size: 30),
                                    Text('Capture\nMemory',
                                      style: TextStyle(color: Colors.white, fontSize: 15,
                                        fontWeight: FontWeight.w800, height: 1.2)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: () => _handleCapture(ImageSource.gallery),
                            child: Container(
                              height: 130,
                              decoration: BoxDecoration(
                                color: mlColors.surfaceSecondary,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: mlColors.border),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.photo_library_rounded, color: mlColors.primary, size: 28),
                                  const SizedBox(height: 8),
                                  Text('Gallery',
                                    style: GoogleFonts.manrope(
                                      fontSize: 13, fontWeight: FontWeight.w700, color: mlColors.textPrimary,
                                    )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ─── Search Bar ───
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context, MaterialPageRoute(builder: (_) => const SearchScreen()),
                      ),
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: mlColors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: mlColors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search_rounded, color: mlColors.icon, size: 20),
                            const SizedBox(width: 10),
                            Text('Search your memories...',
                              style: GoogleFonts.manrope(color: mlColors.textSecondary, fontSize: 14)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: mlColors.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.auto_awesome, color: mlColors.primary, size: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ─── Coming Up / Reminders ───
                    memoriesAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (memories) {
                        final now = DateTime.now();
                        final upcoming = memories.where((m) =>
                          (m.deadline != null && m.deadline!.value.isAfter(now)) ||
                          m.actions.any((a) => !a.isCompleted && a.dueDate != null && a.dueDate!.isAfter(now))
                        ).take(3).toList();

                        if (upcoming.isEmpty) return const SizedBox.shrink();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('You may want to remember',
                                  style: GoogleFonts.manrope(
                                    fontSize: 15, fontWeight: FontWeight.w700, color: mlColors.textPrimary,
                                  )),
                                TextButton(
                                  onPressed: () => Navigator.push(context, MaterialPageRoute(
                                    builder: (_) => const RemindersScreen(),
                                  )),
                                  child: Text('View all',
                                    style: GoogleFonts.manrope(
                                      fontSize: 13, fontWeight: FontWeight.w600, color: mlColors.primary,
                                    )),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...upcoming.map((m) {
                              final action = m.actions.where((a) =>
                                !a.isCompleted && a.dueDate != null && a.dueDate!.isAfter(now)
                              ).firstOrNull;
                              final dueDate = m.deadline?.value ?? action?.dueDate;
                              final daysLeft = dueDate?.difference(now).inDays;
                              final isUrgent = daysLeft != null && daysLeft <= 3;

                              return GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => MemoryDetailsScreen(memory: m),
                                )),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: mlColors.surface,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isUrgent
                                          ? mlColors.error.withValues(alpha: 0.35)
                                          : mlColors.border,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isUrgent
                                              ? mlColors.error.withValues(alpha: 0.1)
                                              : mlColors.warning.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          isUrgent ? Icons.error_outline : Icons.notifications_none_rounded,
                                          color: isUrgent ? mlColors.error : mlColors.warning,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(m.title,
                                              style: GoogleFonts.manrope(
                                                fontSize: 13, fontWeight: FontWeight.w700,
                                                color: mlColors.textPrimary,
                                              )),
                                            if (dueDate != null)
                                              Text(
                                                daysLeft == 0
                                                    ? 'Today!'
                                                    : daysLeft == 1
                                                        ? '1 day left'
                                                        : '$daysLeft days left',
                                                style: GoogleFonts.manrope(
                                                  fontSize: 11, fontWeight: FontWeight.w600,
                                                  color: isUrgent ? mlColors.error : mlColors.warning,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.arrow_forward_ios_rounded, size: 12, color: mlColors.icon),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 20),
                          ],
                        );
                      },
                    ),

                    // ─── Recent Memories Header ───
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent memories',
                          style: GoogleFonts.manrope(
                            fontSize: 15, fontWeight: FontWeight.w700, color: mlColors.textPrimary,
                          )),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const MemoriesScreen(),
                          )),
                          child: Text('View all',
                            style: GoogleFonts.manrope(
                              fontSize: 13, fontWeight: FontWeight.w600, color: mlColors.primary,
                            )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // ─── Recent Memories Grid ───
            memoriesAsync.when(
              loading: () => SliverToBoxAdapter(
                child: Center(child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: mlColors.primary),
                )),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(child: Text('Error: $e', style: TextStyle(color: mlColors.error))),
              ),
              data: (memories) {
                if (memories.isEmpty) {
                  return SliverToBoxAdapter(
                    child: EmptyStateWidget(
                      emoji: '📸',
                      title: 'No memories yet',
                      subtitle: 'Capture a notice, receipt or photo\nto start your memory timeline.',
                      ctaLabel: 'Capture Memory',
                      onCta: () => _handleCapture(ImageSource.camera),
                    ),
                  );
                }
                final recent = memories.take(8).toList();
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childCount: recent.length,
                    itemBuilder: (_, i) => _TimelinePhotoCard(
                      memory: recent[i],
                      isDark: isDark,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MemoryDetailsScreen(memory: recent[i])),
                      ).then((_) {
                        if (mounted) ref.read(memoriesProvider.notifier).refresh();
                      }),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 17) return 'Good afternoon,';
    return 'Good evening,';
  }
}

// ─────────────────────────────────────────────────────────
// Masonry card widget
// ─────────────────────────────────────────────────────────

class _TimelinePhotoCard extends StatelessWidget {
  final Memory memory;
  final bool isDark;
  final VoidCallback onTap;

  const _TimelinePhotoCard({required this.memory, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final mlColors = context.mlColors;
    final surfaceColor = AppTheme.getCategorySurface(memory.category, isDark);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: mlColors.border.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0 : 0.02),
              blurRadius: 8, offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.file(
                File(memory.imagePath),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 110,
                  color: mlColors.surfaceSecondary,
                  child: Icon(Icons.broken_image_rounded, color: mlColors.icon),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    memory.title,
                    style: GoogleFonts.manrope(
                      fontSize: 12, fontWeight: FontWeight.w700, color: mlColors.textPrimary,
                    ),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    relativeDate(memory.createdAt),
                    style: GoogleFonts.manrope(fontSize: 10, color: mlColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
