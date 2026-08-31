import 'dart:io';
import 'package:flutter/material.dart';
import '../models/memory.dart';
import '../utils/date_utils.dart';
import 'category_chip.dart';
import '../theme/app_theme.dart';

/// Reusable card showing a memory's thumbnail, title, category, and relative date.
/// Used in Home (recent memories list) and Search results.
class MemoryCard extends StatelessWidget {
  final Memory memory;
  final VoidCallback? onTap;

  const MemoryCard({super.key, required this.memory, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mlColors = context.mlColors;
    
    final surfaceColor = AppTheme.getCategorySurface(memory.category, isDark);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      color: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: mlColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: _buildThumbnail(mlColors, isDark),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            memory.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: mlColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (memory.processingFailed)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(Icons.warning_amber_rounded,
                                color: mlColors.warning, size: 16),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (memory.summary.isNotEmpty)
                      Text(
                        memory.summary,
                        style: TextStyle(
                          fontSize: 12,
                          color: mlColors.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CategoryChipWidget(
                            category: memory.category, small: true),
                        const Spacer(),
                        if (memory.deadline != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🔴',
                                    style: TextStyle(fontSize: 9)),
                                const SizedBox(width: 2),
                                Text(
                                  memory.deadline!.formattedValue,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: mlColors.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Text(
                          relativeDate(memory.createdAt),
                          style: TextStyle(
                            fontSize: 10,
                            color: mlColors.textSecondary.withValues(alpha: 0.8),
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
      ),
    );
  }

  Widget _buildThumbnail(MemoryLensColors mlColors, bool isDark) {
    if (memory.imagePath.isEmpty || !File(memory.imagePath).existsSync()) {
      return Container(
        color: isDark ? const Color(0xFF1C1513) : const Color(0xFFF8E9DF),
        child: Icon(Icons.image_not_supported_outlined,
            color: mlColors.icon, size: 24),
      );
    }
    return Image.file(
      File(memory.imagePath),
      fit: BoxFit.cover,
    );
  }
}
