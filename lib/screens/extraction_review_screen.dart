import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/memory.dart';
import '../providers/memory_provider.dart';
import '../widgets/category_chip.dart';
import '../widgets/date_badge.dart';
import 'memory_details_screen.dart';

/// Shows extracted memory fields for user review before saving.
/// The title is editable; other fields are display-only in this prototype.
class ExtractionReviewScreen extends ConsumerStatefulWidget {
  final Memory memory;

  const ExtractionReviewScreen({super.key, required this.memory});

  @override
  ConsumerState<ExtractionReviewScreen> createState() =>
      _ExtractionReviewScreenState();
}

class _ExtractionReviewScreenState
    extends ConsumerState<ExtractionReviewScreen> {
  late TextEditingController _titleController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.memory.title);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _saveMemory() async {
    final updatedMemory = widget.memory.copyWith(
      title: _titleController.text.trim().isEmpty
          ? 'Untitled'
          : _titleController.text.trim(),
    );
    setState(() => _saving = true);
    await ref.read(memoriesProvider.notifier).addMemory(updatedMemory);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MemoryDetailsScreen(memory: updatedMemory),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.memory;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Review & Save'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _saveMemory,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Privacy disclosure — required per spec
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFD54F)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 16, color: Color(0xFFF57F17)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This image was processed by a remote AI service (Google Gemini). Your image was sent over the internet for analysis.',
                        style:
                            TextStyle(fontSize: 11, color: Color(0xFF795548)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Captured image
              if (m.imagePath.isNotEmpty && File(m.imagePath).existsSync())
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(
                    File(m.imagePath),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 20),
              // Editable title
              _SectionLabel('Title', theme),
              const SizedBox(height: 6),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Give this memory a title',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              // Summary
              if (m.summary.isNotEmpty) ...[
                _SectionLabel('Summary', theme),
                const SizedBox(height: 6),
                _InfoBox(m.summary),
                const SizedBox(height: 16),
              ],
              // Category
              _SectionLabel('Category', theme),
              const SizedBox(height: 6),
              CategoryChipWidget(category: m.category),
              const SizedBox(height: 16),
              // Entities
              if (m.entities.isNotEmpty) ...[
                _SectionLabel('Extracted details', theme),
                const SizedBox(height: 8),
                ...m.entities.entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 110,
                            child: Text(
                              e.key.replaceAll('_', ' ').toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF9CA3AF),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5),
                            ),
                          ),
                          Expanded(
                            child: Text(e.value,
                                style: const TextStyle(
                                    fontSize: 13, color: Color(0xFF1F2937))),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),
              ],
              // Dates
              if (m.dates.isNotEmpty) ...[
                _SectionLabel('Dates detected', theme),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: m.dates.map((d) => DateBadge(date: d)).toList(),
                ),
                const SizedBox(height: 16),
              ],
              // Actions
              if (m.actions.isNotEmpty) ...[
                _SectionLabel('Extracted actions', theme),
                const SizedBox(height: 8),
                ...m.actions.map((a) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.task_alt, size: 20, color: Color(0xFF4CAF50)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.description,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1F2937)),
                            ),
                            if (a.dueDate != null)
                              Text(
                                'Due: ${a.dueDate!.toLocal().toString().split(' ')[0]}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFFE53935)),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 16),
              ],
              // Extracted text
              if (m.extractedText.isNotEmpty) ...[
                _SectionLabel('Extracted text', theme),
                const SizedBox(height: 6),
                _InfoBox(m.extractedText, monospace: true),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _saveMemory,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_alt_rounded),
                  label: Text(_saving ? 'Saving…' : 'Save memory'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final ThemeData theme;
  const _SectionLabel(this.text, this.theme);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.primary,
        ),
      );
}

class _InfoBox extends StatelessWidget {
  final String text;
  final bool monospace;
  const _InfoBox(this.text, {this.monospace = false});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: monospace ? 12 : 13,
            fontFamily: monospace ? 'monospace' : null,
            color: const Color(0xFF374151),
            height: 1.5,
          ),
        ),
      );
}
