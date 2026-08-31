import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/memory.dart';
import '../providers/memory_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/memory_card.dart';
import '../widgets/manual_reminder_sheet.dart';
import 'memory_details_screen.dart';
import 'search_screen.dart';

/// Full-screen memory browser with category filtering.
/// Accessed from Home → "View all memories".
/// NOT a bottom nav destination.
class MemoriesScreen extends ConsumerStatefulWidget {
  const MemoriesScreen({super.key});

  @override
  ConsumerState<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends ConsumerState<MemoriesScreen> {
  String _selected = 'all';

  static const _tabs = [
    ('all', 'All', '🗂️'),
    ('event', 'Events', '📅'),
    ('receipt', 'Receipts', '🧾'),
    ('notice', 'Notices', '📋'),
    ('opportunity', 'Opportunities', '🌱'),
    ('document', 'Documents', '📄'),
  ];

  @override
  Widget build(BuildContext context) {
    final mlColors = context.mlColors;
    final memoriesAsync = ref.watch(memoriesProvider);

    return Scaffold(
      backgroundColor: mlColors.background,
      appBar: AppBar(
        title: const Text('Memories'),
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded, color: mlColors.icon),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // ─── Category Filter Tabs ───
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final (id, label, emoji) = _tabs[i];
                final isSelected = _selected == id;
                return GestureDetector(
                  onTap: () => setState(() => _selected = id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? mlColors.primaryContainer : mlColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? mlColors.primary.withValues(alpha: 0.4) : mlColors.border,
                      ),
                    ),
                    child: Text(
                      '$emoji $label',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? mlColors.primary : mlColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 4),

          // ─── Memory List ───
          Expanded(
            child: memoriesAsync.when(
              loading: () => Center(child: CircularProgressIndicator(color: mlColors.primary)),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (memories) {
                final filtered = _selected == 'all'
                    ? memories
                    : memories.where((m) => m.category == _selected).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('📭', style: const TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        Text(
                          'No ${_selected == 'all' ? 'memories' : '${_selected}s'} yet',
                          style: GoogleFonts.manrope(
                            fontSize: 16, fontWeight: FontWeight.w700, color: mlColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Capture something to get started.',
                          style: GoogleFonts.manrope(fontSize: 13, color: mlColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 40),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) => MemoryCard(
                    memory: filtered[i],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MemoryDetailsScreen(memory: filtered[i])),
                    ).then((_) => ref.read(memoriesProvider.notifier).refresh()),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const ManualReminderSheet(),
          );
        },
        backgroundColor: mlColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_calendar_rounded, size: 20),
        label: Text('Manual Reminder', style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
