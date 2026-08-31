import 'package:flutter/material.dart';
import '../utils/date_utils.dart';
import '../theme/app_theme.dart';

/// Color-coded category chip used on memory cards and detail views.
class CategoryChipWidget extends StatelessWidget {
  final String category;
  final bool small;

  const CategoryChipWidget({
    super.key,
    required this.category,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final accentColor = AppTheme.getCategoryAccent(category, isDark);
    final bgColor = isDark 
        ? accentColor.withValues(alpha: 0.15) 
        : accentColor.withValues(alpha: 0.1);
        
    final label = '${categoryEmoji(category)} ${categoryLabel(category)}';
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: small ? 10 : 12,
          fontWeight: FontWeight.w600,
          color: accentColor,
        ),
      ),
    );
  }
}
