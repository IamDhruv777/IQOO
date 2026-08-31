import 'package:flutter/material.dart';

/// Animated staged progress indicator for the Processing screen.
/// Shows a sequence of status messages with a smooth step indicator.
class StagedProgress extends StatefulWidget {
  final List<String> stages;
  final int currentStage;

  const StagedProgress({
    super.key,
    required this.stages,
    required this.currentStage,
  });

  @override
  State<StagedProgress> createState() => _StagedProgressState();
}

class _StagedProgressState extends State<StagedProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pulsing AI icon
        AnimatedBuilder(
          animation: _pulse,
          builder: (_, __) => Opacity(
            opacity: 0.6 + 0.4 * _pulse.value,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 40,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        // Stage steps
        ...widget.stages.asMap().entries.map((entry) {
          final i = entry.key;
          final label = entry.value;
          final isDone = i < widget.currentStage;
          final isActive = i == widget.currentStage;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: (isDone || isActive) ? 1.0 : 0.3,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: isDone
                        ? Icon(Icons.check_circle_rounded,
                            key: ValueKey('done_$i'),
                            color: theme.colorScheme.primary,
                            size: 20)
                        : isActive
                            ? AnimatedBuilder(
                                animation: _pulse,
                                builder: (_, __) => Icon(
                                  Icons.circle,
                                  key: ValueKey('active_$i'),
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.4 + 0.6 * _pulse.value),
                                  size: 20,
                                ),
                              )
                            : Icon(Icons.circle_outlined,
                                key: ValueKey('pending_$i'),
                                color: theme.colorScheme.outline,
                                size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive
                          ? theme.colorScheme.primary
                          : isDone
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
