import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/memory.dart';
import '../providers/memory_provider.dart';
import '../services/ai_service.dart';
import '../theme/app_theme.dart';
import '../widgets/staged_progress.dart';
import 'extraction_review_screen.dart';

class ProcessingScreen extends ConsumerStatefulWidget {
  final File imageFile;
  final String localPath;

  const ProcessingScreen({
    super.key,
    required this.imageFile,
    required this.localPath,
  });

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen> {
  static const _stages = [
    'Looking at your memory…',
    'Reading the important details…',
    'Understanding what matters…',
    'Creating your memory…',
  ];

  int _stage = 0;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _runExtraction();
  }

  Future<void> _runExtraction() async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _stage = 1);

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _stage = 2);

    Memory result;
    try {
      result = await AiService().extractFromImage(widget.imageFile, widget.localPath);
    } catch (e) {
      result = Memory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath: widget.localPath,
        title: 'Untitled capture',
        createdAt: DateTime.now(),
        processingFailed: true,
      );
    }

    if (!mounted) return;
    setState(() => _stage = 3);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    if (result.processingFailed) {
      await ref.read(memoriesProvider.notifier).addMemory(result);
      setState(() => _failed = true);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ExtractionReviewScreen(memory: result)),
      );
    }
  }

  Future<void> _retry() async {
    setState(() { _stage = 0; _failed = false; });
    _runExtraction();
  }

  @override
  Widget build(BuildContext context) {
    final mlColors = context.mlColors;
    return Scaffold(
      backgroundColor: mlColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Processing', style: GoogleFonts.manrope(
          color: mlColors.textPrimary, fontWeight: FontWeight.w700,
        )),
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: mlColors.icon),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _failed ? _buildFailedState(mlColors) : _buildLoadingState(mlColors),
        ),
      ),
    );
  }

  Widget _buildLoadingState(MemoryLensColors mlColors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image preview
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: mlColors.border, width: 2),
              boxShadow: [
                BoxShadow(
                  color: mlColors.primary.withValues(alpha: 0.08),
                  blurRadius: 20, spreadRadius: 4,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.file(
                widget.imageFile,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 48),
          // Spinning logo
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: mlColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(Icons.auto_awesome, color: mlColors.primary, size: 28),
            ),
          ),
          const SizedBox(height: 20),
          StagedProgress(stages: _stages, currentStage: _stage),
          const SizedBox(height: 12),
          Text(
            _stage < _stages.length ? _stages[_stage] : _stages.last,
            style: GoogleFonts.manrope(
              fontSize: 15, fontWeight: FontWeight.w600, color: mlColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'MemoryLens is understanding what matters.',
            style: GoogleFonts.manrope(fontSize: 12, color: mlColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFailedState(MemoryLensColors mlColors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: mlColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.file(widget.imageFile, height: 200, width: double.infinity, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: mlColors.warning.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.cloud_off_rounded, size: 40, color: mlColors.warning),
          ),
          const SizedBox(height: 16),
          Text('AI processing failed', style: GoogleFonts.manrope(
            fontSize: 18, fontWeight: FontWeight.w700, color: mlColors.textPrimary,
          )),
          const SizedBox(height: 8),
          Text(
            'Your capture was saved.\nCheck your network and try again.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(fontSize: 13, color: mlColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: mlColors.border),
                  foregroundColor: mlColors.textPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text('Close', style: GoogleFonts.manrope(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _retry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text('Retry AI', style: GoogleFonts.manrope(fontWeight: FontWeight.w600)),
                style: FilledButton.styleFrom(
                  backgroundColor: mlColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
