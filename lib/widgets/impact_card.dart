import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/crisis_model.dart';
import '../theme/app_theme.dart';

class ImpactCard extends StatelessWidget {
  final ImpactModel impact;

  const ImpactCard({super.key, required this.impact});

  @override
  Widget build(BuildContext context) {
    IconData getIcon(String name) {
      switch (name.toLowerCase()) {
        case 'traffic': return LucideIcons.car;
        case 'car': return LucideIcons.car;
        case 'home': return LucideIcons.home;
        case 'building': return LucideIcons.building;
        case 'wind': return LucideIcons.wind;
        default: return LucideIcons.alertTriangle;
      }
    }

    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.darkNavy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGlow),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(getIcon(impact.icon), color: AppTheme.neonBlue, size: 32),
          const SizedBox(height: 8),
          Text(
            impact.text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
