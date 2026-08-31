import 'package:intl/intl.dart';

/// Returns a human-readable relative date string, e.g. "2 days ago", "just now".
String relativeDate(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'yesterday';
  if (diff.inDays < 7) return '${diff.inDays} days ago';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
  return DateFormat('MMM d, yyyy').format(dt);
}

/// Category display names (singular)
String categoryLabel(String category) {
  switch (category) {
    case 'event':
      return 'Event';
    case 'receipt':
      return 'Receipt';
    case 'contact':
      return 'Contact';
    case 'document':
      return 'Document';
    case 'notice':
      return 'Notice';
    default:
      return 'Other';
  }
}

/// Category icon emojis
String categoryEmoji(String category) {
  switch (category) {
    case 'event':
      return '🎯';
    case 'receipt':
      return '🧾';
    case 'contact':
      return '👤';
    case 'document':
      return '📄';
    case 'notice':
      return '📢';
    default:
      return '📁';
  }
}
