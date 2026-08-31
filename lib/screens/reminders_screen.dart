import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/memory.dart';
import '../providers/memory_provider.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart';
import 'memory_details_screen.dart';

/// Dedicated Reminders screen — accessed from Home and RememberScreen
/// via "View all reminders". Shows memories grouped by urgency.
/// NOT a bottom nav destination.
class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoriesAsync = ref.watch(memoriesProvider);
    final mlColors = context.mlColors;

    return Scaffold(
      backgroundColor: mlColors.background,
      appBar: AppBar(
        title: const Text('Reminders'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: mlColors.icon),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: memoriesAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: mlColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (memories) => _ReminderBody(memories: memories, mlColors: mlColors),
      ),
    );
  }
}

class _ReminderBody extends StatelessWidget {
  final List<Memory> memories;
  final MemoryLensColors mlColors;

  const _ReminderBody({required this.memories, required this.mlColors});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // Memories that have any deadline or action with a due date
    final withDates = memories.where((m) {
      if (m.deadline != null) return true;
      return m.actions.any((a) => a.dueDate != null);
    }).toList();

    DateTime? _effectiveDate(Memory m) {
      if (m.deadline != null) return m.deadline!.value;
      return m.actions.where((a) => a.dueDate != null).map((a) => a.dueDate!).firstOrNull;
    }

    final overdue = withDates
        .where((m) => _effectiveDate(m) != null && _effectiveDate(m)!.isBefore(now))
        .toList()
      ..sort((a, b) => _effectiveDate(b)!.compareTo(_effectiveDate(a)!));

    final urgent = withDates
        .where((m) {
          final d = _effectiveDate(m);
          if (d == null) return false;
          final diff = d.difference(now).inDays;
          return d.isAfter(now) && diff <= 3;
        })
        .toList()
      ..sort((a, b) => _effectiveDate(a)!.compareTo(_effectiveDate(b)!));

    final later = withDates
        .where((m) {
          final d = _effectiveDate(m);
          if (d == null) return false;
          return d.isAfter(now) && d.difference(now).inDays > 3;
        })
        .toList()
      ..sort((a, b) => _effectiveDate(a)!.compareTo(_effectiveDate(b)!));

    final completed = memories.where((m) => m.reminderSet && _effectiveDate(m) == null ||
        m.actions.every((a) => a.isCompleted) && m.reminderSet).toList();

    if (withDates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🔔', style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text('No reminders yet', style: GoogleFonts.manrope(
              fontSize: 18, fontWeight: FontWeight.w700, color: mlColors.textPrimary,
            )),
            const SizedBox(height: 8),
            Text(
              'Memories with deadlines or\nactions will appear here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(fontSize: 14, color: mlColors.textSecondary, height: 1.5),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        Text('Reminders', style: GoogleFonts.manrope(
          fontSize: 26, fontWeight: FontWeight.w800, color: mlColors.textPrimary,
        )),
        const SizedBox(height: 4),
        Text('Things MemoryLens is keeping track of.', style: GoogleFonts.manrope(
          fontSize: 13, color: mlColors.textSecondary,
        )),
        const SizedBox(height: 24),

        if (overdue.isNotEmpty) ...[
          _SectionLabel(label: 'OVERDUE', color: mlColors.error),
          ...overdue.map((m) => _ReminderTile(
            memory: m, dueDate: _effectiveDate(m)!, urgency: _Urgency.overdue, mlColors: mlColors,
          )),
          const SizedBox(height: 20),
        ],

        if (urgent.isNotEmpty) ...[
          _SectionLabel(label: 'COMING SOON', color: mlColors.warning),
          ...urgent.map((m) => _ReminderTile(
            memory: m, dueDate: _effectiveDate(m)!, urgency: _Urgency.soon, mlColors: mlColors,
          )),
          const SizedBox(height: 20),
        ],

        if (later.isNotEmpty) ...[
          _SectionLabel(label: 'LATER', color: mlColors.textSecondary),
          ...later.map((m) => _ReminderTile(
            memory: m, dueDate: _effectiveDate(m)!, urgency: _Urgency.later, mlColors: mlColors,
          )),
          const SizedBox(height: 20),
        ],

        if (completed.isNotEmpty) ...[
          _SectionLabel(label: 'COMPLETED', color: mlColors.success),
          ...completed.map((m) => _ReminderTile(
            memory: m, dueDate: now, urgency: _Urgency.done, mlColors: mlColors,
          )),
        ],
      ],
    );
  }
}

enum _Urgency { overdue, soon, later, done }

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(label, style: GoogleFonts.manrope(
      fontSize: 11, fontWeight: FontWeight.w800, color: color, letterSpacing: 1.2,
    )),
  );
}

class _ReminderTile extends StatelessWidget {
  final Memory memory;
  final DateTime dueDate;
  final _Urgency urgency;
  final MemoryLensColors mlColors;

  const _ReminderTile({
    required this.memory, required this.dueDate,
    required this.urgency, required this.mlColors,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final Color dotColor = switch (urgency) {
      _Urgency.overdue => mlColors.error,
      _Urgency.soon    => mlColors.warning,
      _Urgency.later   => mlColors.textSecondary,
      _Urgency.done    => mlColors.success,
    };

    final String emoji = switch (urgency) {
      _Urgency.overdue => '🔴',
      _Urgency.soon    => '🟡',
      _Urgency.later   => '🔵',
      _Urgency.done    => '✓',
    };

    final daysLeft = dueDate.difference(now).inDays;
    String timeLabel;
    if (urgency == _Urgency.done) {
      timeLabel = 'Done';
    } else if (urgency == _Urgency.overdue) {
      timeLabel = '${daysLeft.abs()} day${daysLeft.abs() == 1 ? '' : 's'} overdue';
    } else if (daysLeft == 0) {
      timeLabel = 'Today';
    } else if (daysLeft == 1) {
      timeLabel = 'Tomorrow';
    } else {
      timeLabel = relativeDate(dueDate);
    }

    // Action descriptions for this memory
    final pending = memory.actions.where((a) => !a.isCompleted).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: mlColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => MemoryDetailsScreen(memory: memory),
          )),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: dotColor.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(memory.title, style: GoogleFonts.manrope(
                        fontSize: 14, fontWeight: FontWeight.w700, color: mlColors.textPrimary,
                      )),
                      if (pending.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(pending.first.description, style: GoogleFonts.manrope(
                          fontSize: 12, color: mlColors.textSecondary,
                        ), overflow: TextOverflow.ellipsis),
                      ],
                      const SizedBox(height: 4),
                      Text(timeLabel, style: GoogleFonts.manrope(
                        fontSize: 12, fontWeight: FontWeight.w700, color: dotColor,
                      )),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 13, color: mlColors.icon),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
