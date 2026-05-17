import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SeverityBadge extends StatelessWidget {
  final String severity;

  const SeverityBadge({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String text;

    switch (severity.toUpperCase()) {
      case 'HIGH':
        badgeColor = AppTheme.emergencyRed;
        text = 'HIGH';
        break;
      case 'MEDIUM':
        badgeColor = AppTheme.amberWarning;
        text = 'MEDIUM';
        break;
      case 'LOW':
      default:
        badgeColor = AppTheme.successGreen;
        text = 'LOW';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        border: Border.all(color: badgeColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: badgeColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
