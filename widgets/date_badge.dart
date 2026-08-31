import 'package:flutter/material.dart';
import '../models/memory_date.dart';
import '../theme/app_theme.dart';

/// Displays a date with a type badge. Deadline dates are highlighted semantically.
class DateBadge extends StatelessWidget {
  final MemoryDate date;

  const DateBadge({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final mlColors = context.mlColors;
    final isDeadline = date.isDeadline;

    final bg = isDeadline
        ? mlColors.error.withValues(alpha: 0.1)
        : mlColors.surfaceSecondary;
    final fg = isDeadline ? mlColors.error : mlColors.textPrimary;
    final border = isDeadline
        ? Border.all(color: mlColors.error.withValues(alpha: 0.3), width: 1)
        : Border.all(color: mlColors.border);
    final icon = isDeadline ? '🔴' : _typeIcon();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _typeLabel(),
                style: TextStyle(
                  color: fg,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                date.formattedValue,
                style: TextStyle(
                  color: fg,
                  fontSize: 13,
                  fontWeight: isDeadline ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _typeLabel() {
    switch (date.type) {
      case 'deadline':
        return 'DEADLINE';
      case 'event_date':
        return 'EVENT DATE';
      case 'issue_date':
        return 'ISSUED';
      default:
        return 'DATE';
    }
  }

  String _typeIcon() {
    switch (date.type) {
      case 'event_date':
        return '📅';
      case 'issue_date':
        return '🗓️';
      default:
        return '📆';
    }
  }
}
