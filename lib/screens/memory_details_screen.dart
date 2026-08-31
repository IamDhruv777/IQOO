import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/memory.dart';
import '../models/memory_date.dart';
import '../providers/memory_provider.dart';
import '../services/notification_service.dart';
import '../utils/date_utils.dart';
import '../widgets/category_chip.dart';
import '../widgets/date_badge.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

/// Memory detail view — always shows the original captured image.
/// If a deadline exists and no reminder is set, shows the "Set reminder" action.
class MemoryDetailsScreen extends ConsumerStatefulWidget {
  final Memory memory;

  const MemoryDetailsScreen({super.key, required this.memory});

  @override
  ConsumerState<MemoryDetailsScreen> createState() =>
      _MemoryDetailsScreenState();
}

class _MemoryDetailsScreenState extends ConsumerState<MemoryDetailsScreen> {
  late Memory _memory;
  bool _settingReminder = false;

  @override
  void initState() {
    super.initState();
    _memory = widget.memory;
  }

  Future<void> _setReminder() async {
    final deadline = _memory.deadline;
    if (deadline == null) return;
    setState(() => _settingReminder = true);
    try {
      await NotificationService().scheduleReminder(_memory, deadline.value);
      final updated = _memory.copyWith(reminderSet: true);
      await ref.read(memoriesProvider.notifier).updateMemory(updated);
      if (mounted) {
        setState(() => _memory = updated);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Reminder set!'),
            backgroundColor: context.mlColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not set reminder: $e')),
        );
      }
    }
    if (mounted) setState(() => _settingReminder = false);
  }

  @override
  Widget build(BuildContext context) {
    final mlColors = context.mlColors;
    final deadline = _memory.deadline;

    return Scaffold(
      backgroundColor: mlColors.background,
      body: CustomScrollView(
        slivers: [
          // ─── Collapsible image header ───
          SliverAppBar(
            backgroundColor: mlColors.background,
            expandedHeight: 340,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _buildHeroImage(mlColors),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, mlColors.background],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(
                _memory.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: mlColors.textPrimary,
                  shadows: const [
                    Shadow(color: Colors.black54, blurRadius: 4),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              titlePadding:
                  const EdgeInsets.only(left: 72, bottom: 14, right: 16),
            ),
            iconTheme: IconThemeData(color: mlColors.textPrimary),
            actions: [
              IconButton(
                icon: Icon(Icons.delete_outline, color: mlColors.error, shadows: const [
                  Shadow(color: Colors.black54, blurRadius: 4),
                ]),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      backgroundColor: mlColors.surface,
                      title: Text('Delete Memory?', style: TextStyle(color: mlColors.textPrimary)),
                      content: Text('Are you sure you want to delete this memory? This cannot be undone.', style: TextStyle(color: mlColors.textSecondary)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(c, false), child: Text('Cancel', style: TextStyle(color: mlColors.textSecondary))),
                        TextButton(
                          onPressed: () => Navigator.pop(c, true),
                          child: Text('Delete', style: TextStyle(color: mlColors.error)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ref.read(memoriesProvider.notifier).deleteMemory(_memory.id);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
          // ─── Content ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + category
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _memory.title,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: mlColors.textPrimary,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CategoryChipWidget(category: _memory.category),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Captured ${relativeDate(_memory.createdAt)}',
                    style: TextStyle(
                        fontSize: 12, color: mlColors.textSecondary),
                  ),
                  // ─── Deadline / Reminder block ───
                  if (deadline != null) ...[
                    const SizedBox(height: 16),
                    _DeadlineCard(
                      deadline: deadline,
                      reminderSet: _memory.reminderSet,
                      settingReminder: _settingReminder,
                      onSetReminder: _setReminder,
                      mlColors: mlColors,
                    ),
                  ],
                  const SizedBox(height: 20),
                  // Summary
                  if (_memory.summary.isNotEmpty) ...[
                    _Label('Summary', mlColors),
                    const SizedBox(height: 6),
                    Text(
                      _memory.summary,
                      style: TextStyle(
                        fontSize: 15,
                        color: mlColors.textPrimary.withValues(alpha: 0.9),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  // Dates
                  if (_memory.dates.isNotEmpty) ...[
                    _Label('Dates', mlColors),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _memory.dates
                          .map((d) => DateBadge(date: d))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                  // Extracted text & entities
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Label('Extracted Text', mlColors),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: mlColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: mlColors.border),
                              ),
                              child: Text(
                                _memory.extractedText.isNotEmpty
                                    ? _memory.extractedText
                                    : 'No text found.',
                                style: TextStyle(
                                    fontSize: 12, color: mlColors.textSecondary),
                                maxLines: 6,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Label('Key Entities', mlColors),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: mlColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: mlColors.border),
                              ),
                              child: _memory.entities.isEmpty
                                  ? Text('No entities identified.',
                                      style: TextStyle(
                                          fontSize: 12, color: mlColors.textSecondary))
                                  : Wrap(
                                      spacing: 4,
                                      runSpacing: 4,
                                      children: _memory.entities.entries
                                          .map((e) => Container(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: mlColors.primaryContainer,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  '${e.key}: ${e.value}',
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      color: mlColors.primary),
                                                ),
                                              ))
                                          .toList(),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Actions
                  if (_memory.actions.isNotEmpty) ...[
                    _Label('Actions', mlColors),
                    const SizedBox(height: 8),
                    ..._memory.actions.map((a) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: mlColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: mlColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: mlColors.surfaceSecondary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.assignment_turned_in, color: mlColors.primary, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      a.description,
                                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: mlColors.textPrimary),
                                    ),
                                    if (a.dueDate != null)
                                      Text(
                                        'Due: ${a.dueDate!.toLocal().toString().split(' ')[0]}',
                                        style: TextStyle(fontSize: 13, color: mlColors.textSecondary),
                                      ),
                                  ],
                                ),
                              ),
                              if (a.dueDate != null)
                                IconButton(
                                  icon: Icon(Icons.notification_add, color: mlColors.primary),
                                  tooltip: 'Set reminder for this action',
                                  onPressed: () async {
                                    setState(() => _settingReminder = true);
                                    try {
                                      await NotificationService().scheduleReminder(_memory, a.dueDate!);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: const Text('✅ Action reminder set!'), backgroundColor: mlColors.success),
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Could not set reminder: $e')),
                                        );
                                      }
                                    }
                                    if (mounted) setState(() => _settingReminder = false);
                                  },
                                )
                            ],
                          ),
                        )),
                    const SizedBox(height: 20),
                  ],
                  // Entities
                  if (_memory.entities.isNotEmpty) ...[
                    _Label('Details', mlColors),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: mlColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: mlColors.border),
                      ),
                      child: Column(
                        children: _memory.entities.entries
                            .toList()
                            .asMap()
                            .entries
                            .map((entry) {
                          final idx = entry.key;
                          final e = entry.value;
                          return Column(
                            children: [
                              if (idx > 0)
                                Divider(
                                    height: 1,
                                    color: mlColors.border),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 100,
                                      child: Text(
                                        e.key
                                            .replaceAll('_', ' ')
                                            .toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: mlColors.textSecondary,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        e.value,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: mlColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  // Extracted text (collapsible)
                  if (_memory.extractedText.isNotEmpty) ...[
                    Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                        listTileTheme: ListTileThemeData(
                          iconColor: mlColors.icon,
                        ),
                      ),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: _Label('Extracted text', mlColors),
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: mlColors.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: mlColors.border),
                            ),
                            child: Text(
                              _memory.extractedText,
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'monospace',
                                color: mlColors.textSecondary,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  // Related Memories
                  FutureBuilder<List<Memory>>(
                    future: DatabaseService().getRelatedMemories(_memory),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
                      final related = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          _Label('Related Memories', mlColors),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 160,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: related.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final r = related[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => MemoryDetailsScreen(memory: r)),
                                    );
                                  },
                                  child: Container(
                                    width: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: mlColors.border),
                                      image: DecorationImage(
                                        image: FileImage(File(r.imagePath)),
                                        fit: BoxFit.cover,
                                        colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.3), BlendMode.darken),
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          r.title,
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11), // white needed on image overlay
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(MemoryLensColors mlColors) {
    if (_memory.imagePath.isEmpty || !File(_memory.imagePath).existsSync()) {
      return Container(
        color: mlColors.surfaceSecondary,
        child: Center(
          child: Icon(Icons.image_not_supported_outlined,
              size: 48, color: mlColors.icon),
        ),
      );
    }
    return Image.file(
      File(_memory.imagePath),
      fit: BoxFit.cover,
      width: double.infinity,
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final MemoryLensColors mlColors;
  const _Label(this.text, this.mlColors);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: mlColors.primary,
          letterSpacing: 0.3,
        ),
      );
}

class _DeadlineCard extends StatelessWidget {
  final MemoryDate deadline;
  final bool reminderSet;
  final bool settingReminder;
  final VoidCallback onSetReminder;
  final MemoryLensColors mlColors;

  const _DeadlineCard({
    required this.deadline,
    required this.reminderSet,
    required this.settingReminder,
    required this.onSetReminder,
    required this.mlColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: reminderSet
            ? mlColors.success.withValues(alpha: 0.1)
            : mlColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: reminderSet
              ? mlColors.success.withValues(alpha: 0.4)
              : mlColors.warning.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Text(
            reminderSet ? '✅' : '🔔',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminderSet ? 'Reminder set' : 'Deadline detected',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: reminderSet ? mlColors.success : mlColors.warning,
                  ),
                ),
                Text(
                  deadline.fullFormattedValue,
                  style: TextStyle(
                    fontSize: 13,
                    color: reminderSet
                        ? mlColors.success.withValues(alpha: 0.8)
                        : mlColors.warning.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          if (!reminderSet)
            FilledButton(
              onPressed: settingReminder ? null : onSetReminder,
              style: FilledButton.styleFrom(
                backgroundColor: mlColors.primary,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: settingReminder
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Remind me',
                      style: TextStyle(fontSize: 13, color: Colors.white)),
            ),
        ],
      ),
    );
  }
}
