import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/trace_model.dart';
import 'package:timelines_plus/timelines_plus.dart';

class TraceTile extends StatelessWidget {
  final TraceLogStep step;
  final bool isFirst;
  final bool isLast;

  const TraceTile({
    super.key,
    required this.step,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    // Parse hex color string to Color
    Color badgeColor = AppTheme.neonBlue;
    try {
      if (step.colorHex.startsWith('#')) {
        badgeColor = Color(int.parse(step.colorHex.substring(1, 7), radix: 16) + 0xFF000000);
      }
    } catch (_) {}

    return TimelineTile(
      nodeAlign: TimelineNodeAlign.start,
      contents: Padding(
        padding: const EdgeInsets.only(left: 16.0, bottom: 24.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardNavy,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: badgeColor.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      step.agent,
                      style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  Text(
                    '${step.timestamp.hour}:${step.timestamp.minute.toString().padLeft(2, '0')}:${step.timestamp.second.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                step.action,
                style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                step.reasoning,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
      node: TimelineNode(
        indicator: OutlinedDotIndicator(
          color: badgeColor,
          borderWidth: 2.5,
        ),
        startConnector: isFirst ? null : SolidLineConnector(color: badgeColor.withOpacity(0.5)),
        endConnector: isLast ? null : SolidLineConnector(color: badgeColor.withOpacity(0.5)),
      ),
    );
  }
}
