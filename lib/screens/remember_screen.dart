import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/memory.dart';
import '../providers/memory_provider.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart';
import 'memory_details_screen.dart';
import 'reminders_screen.dart';
import 'search_screen.dart';

/// The "Remember" tab — surfaces what MemoryLens knows the user
/// should not forget: upcoming deadlines, pending actions, category
/// summaries, connected memories, and quick AI question shortcuts.
class RememberScreen extends ConsumerWidget {
  const RememberScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoriesAsync = ref.watch(memoriesProvider);
    final mlColors = context.mlColors;

    return Scaffold(
      backgroundColor: mlColors.background,
      body: SafeArea(
        child: memoriesAsync.when(
          loading: () => Center(child: CircularProgressIndicator(color: mlColors.primary)),
          error: (e, _) => Center(child: Text('Error: $e', style: TextStyle(color: mlColors.error))),
          data: (memories) => _RememberBody(memories: memories, mlColors: mlColors),
        ),
      ),
    );
  }
}

class _RememberBody extends StatelessWidget {
  final List<Memory> memories;
  final MemoryLensColors mlColors;

  const _RememberBody({required this.memories, required this.mlColors});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final upcoming = memories.where((m) =>
      m.deadline != null && m.deadline!.value.isAfter(now) ||
      m.actions.any((a) => !a.isCompleted && a.dueDate != null && a.dueDate!.isAfter(now))
    ).toList()
      ..sort((a, b) {
        final aDate = a.deadline?.value ?? a.actions.where((x) => x.dueDate != null).map((x) => x.dueDate!).firstOrNull;
        final bDate = b.deadline?.value ?? b.actions.where((x) => x.dueDate != null).map((x) => x.dueDate!).firstOrNull;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return aDate.compareTo(bDate);
      });

    final allActions = memories
        .expand((m) => m.actions.where((a) => !a.isCompleted))
        .toList();

    final categoryCounts = <String, int>{};
    for (final m in memories) {
      categoryCounts[m.category] = (categoryCounts[m.category] ?? 0) + 1;
    }

    // Connected memories: group by shared entity keywords
    final connected = _findConnectedGroups(memories);

    final suggestions = [
      'What deadlines are coming up?',
      'What should I not forget?',
      'What opportunities did I save?',
      'What do I know about the hackathon?',
    ];

    return CustomScrollView(
      slivers: [
        // ─── Header ───
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Remember', style: GoogleFonts.manrope(
                  fontSize: 30, fontWeight: FontWeight.w800, color: mlColors.textPrimary,
                )),
                const SizedBox(height: 4),
                Text(
                  'Here\'s what you may want to remember.',
                  style: GoogleFonts.manrope(fontSize: 14, color: mlColors.textSecondary),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),

        // ─── Section 1: Coming Up ───
        if (upcoming.isNotEmpty) ...[
          _SectionHeader(title: 'Coming Up', icon: Icons.notifications_outlined, mlColors: mlColors),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < upcoming.take(5).length) {
                  return _UpcomingCard(memory: upcoming[index], mlColors: mlColors);
                }
                return null;
              },
              childCount: upcoming.take(5).length,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: TextButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RemindersScreen())),
                icon: Icon(Icons.arrow_forward_rounded, size: 16, color: mlColors.primary),
                label: Text('View all reminders', style: TextStyle(color: mlColors.primary, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],

        // ─── Section 2: Don't Forget ───
        if (allActions.isNotEmpty) ...[
          _SectionHeader(title: "Don't Forget", icon: Icons.checklist_rounded, mlColors: mlColors),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: mlColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: mlColors.border),
                ),
                child: Column(
                  children: allActions.take(6).map((a) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Container(
                            width: 6, height: 6,
                            decoration: BoxDecoration(color: mlColors.primary, shape: BoxShape.circle),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(a.description, style: GoogleFonts.manrope(
                            fontSize: 14, color: mlColors.textPrimary, height: 1.4,
                          )),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ),
            ),
          ),
        ],

        // ─── Section 3: Recently Discovered ───
        if (categoryCounts.isNotEmpty) ...[
          _SectionHeader(title: 'Recently Discovered', icon: Icons.auto_awesome_outlined, mlColors: mlColors),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('You recently saved:', style: GoogleFonts.manrope(
                    fontSize: 13, color: mlColors.textSecondary,
                  )),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: categoryCounts.entries
                        .where((e) => e.value > 0)
                        .map((e) => _CategoryPill(
                          category: e.key, count: e.value, mlColors: mlColors,
                        ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],

        // ─── Section 4: Connected Memories ───
        if (connected.isNotEmpty) ...[
          _SectionHeader(title: 'Connected Memories', icon: Icons.hub_outlined, mlColors: mlColors),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _ConnectedGroup(
                group: connected[index], mlColors: mlColors,
              ),
              childCount: connected.take(3).length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],

        // ─── Section 5: Quick Questions ───
        _SectionHeader(title: 'Quick Questions', icon: Icons.chat_bubble_outline_rounded, mlColors: mlColors),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            child: Column(
              children: suggestions.map((q) => _QuestionChip(
                question: q,
                mlColors: mlColors,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SearchScreen(initialQuery: q)),
                ),
              )).toList(),
            ),
          ),
        ),
      ],
    );
  }

  List<_MemoryGroup> _findConnectedGroups(List<Memory> memories) {
    final groups = <String, List<Memory>>{};
    for (final m in memories) {
      for (final entity in m.entities.values) {
        final key = entity.toLowerCase().trim();
        if (key.length > 4) {
          groups.putIfAbsent(key, () => []);
          if (!groups[key]!.contains(m)) groups[key]!.add(m);
        }
      }
    }
    return groups.entries
        .where((e) => e.value.length >= 2)
        .map((e) => _MemoryGroup(label: e.key, memories: e.value))
        .toList()
      ..sort((a, b) => b.memories.length.compareTo(a.memories.length));
  }
}

class _MemoryGroup {
  final String label;
  final List<Memory> memories;
  const _MemoryGroup({required this.label, required this.memories});
}

// ─────────────────────────────────────────────────────────
// Widgets
// ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final MemoryLensColors mlColors;
  const _SectionHeader({required this.title, required this.icon, required this.mlColors});

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: mlColors.primary),
          const SizedBox(width: 8),
          Text(title, style: GoogleFonts.manrope(
            fontSize: 13, fontWeight: FontWeight.w700,
            color: mlColors.textSecondary, letterSpacing: 0.5,
          ).copyWith(inherit: false, color: mlColors.textSecondary)),
        ],
      ),
    ),
  );
}

class _UpcomingCard extends StatelessWidget {
  final Memory memory;
  final MemoryLensColors mlColors;

  const _UpcomingCard({required this.memory, required this.mlColors});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    DateTime? dueDate = memory.deadline?.value;
    String actionDesc = '';
    if (dueDate == null) {
      final action = memory.actions.where((a) => !a.isCompleted && a.dueDate != null && a.dueDate!.isAfter(now)).firstOrNull;
      dueDate = action?.dueDate;
      actionDesc = action?.description ?? '';
    }

    final daysLeft = dueDate != null ? dueDate.difference(now).inDays : null;
    final isUrgent = daysLeft != null && daysLeft <= 3;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        decoration: BoxDecoration(
          color: mlColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUrgent ? mlColors.error.withValues(alpha: 0.4) : mlColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (memory.imagePath.isNotEmpty && File(memory.imagePath).existsSync())
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: Image.file(File(memory.imagePath), fit: BoxFit.cover),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isUrgent ? Icons.error_outline : Icons.notifications_none_rounded,
                        color: isUrgent ? mlColors.error : mlColors.warning,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(memory.title, style: GoogleFonts.manrope(
                          fontSize: 15, fontWeight: FontWeight.w700, color: mlColors.textPrimary,
                        )),
                      ),
                    ],
                  ),
                  if (actionDesc.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(actionDesc, style: GoogleFonts.manrope(fontSize: 12, color: mlColors.textSecondary)),
                  ],
                  if (dueDate != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      daysLeft != null
                        ? daysLeft == 0 ? 'Today!' : '$daysLeft day${daysLeft == 1 ? '' : 's'} left'
                        : relativeDate(dueDate),
                      style: GoogleFonts.manrope(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: isUrgent ? mlColors.error : mlColors.warning,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => MemoryDetailsScreen(memory: memory),
                          )),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: mlColors.border),
                            foregroundColor: mlColors.textPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text('View memory', style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: () async {
                            if (dueDate == null) return;
                            await NotificationService().scheduleReminder(memory, dueDate);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Reminder set for ${memory.title}')),
                              );
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: mlColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text('Remind me', style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
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

class _CategoryPill extends StatelessWidget {
  final String category;
  final int count;
  final MemoryLensColors mlColors;

  const _CategoryPill({required this.category, required this.count, required this.mlColors});

  static const _emojis = {
    'event': '📅', 'receipt': '🧾', 'notice': '📋',
    'opportunity': '🌱', 'document': '📄', 'contact': '👤', 'other': '📁',
  };
  static const _labels = {
    'event': 'events', 'receipt': 'receipts', 'notice': 'notices',
    'opportunity': 'opportunities', 'document': 'documents', 'contact': 'contacts', 'other': 'items',
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppTheme.getCategoryAccent(category, isDark);
    final surface = AppTheme.getCategorySurface(category, isDark);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Text(
        '${_emojis[category] ?? '📁'} $count ${_labels[category] ?? 'items'}',
        style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w600, color: accent),
      ),
    );
  }
}

class _ConnectedGroup extends StatelessWidget {
  final _MemoryGroup group;
  final MemoryLensColors mlColors;

  const _ConnectedGroup({required this.group, required this.mlColors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: mlColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: mlColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, size: 14, color: mlColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    group.label,
                    style: GoogleFonts.manrope(
                      fontSize: 15, fontWeight: FontWeight.w700, color: mlColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${group.memories.length} related memories',
              style: GoogleFonts.manrope(fontSize: 12, color: mlColors.textSecondary),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: group.memories.take(4).map((m) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: mlColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: mlColors.border),
                ),
                child: Text(m.title, style: GoogleFonts.manrope(
                  fontSize: 11, fontWeight: FontWeight.w600, color: mlColors.textPrimary,
                ), overflow: TextOverflow.ellipsis),
              )).toList(),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => MemoryDetailsScreen(memory: group.memories.first),
              )),
              child: Text('View collection →', style: GoogleFonts.manrope(
                fontSize: 13, fontWeight: FontWeight.w700, color: mlColors.primary,
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionChip extends StatelessWidget {
  final String question;
  final MemoryLensColors mlColors;
  final VoidCallback onTap;

  const _QuestionChip({required this.question, required this.mlColors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: mlColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: mlColors.border),
          ),
          child: Row(
            children: [
              Icon(Icons.chat_bubble_outline_rounded, size: 16, color: mlColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '"$question"',
                  style: GoogleFonts.manrope(
                    fontSize: 13, color: mlColors.textPrimary, fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 12, color: mlColors.icon),
            ],
          ),
        ),
      ),
    );
  }
}
