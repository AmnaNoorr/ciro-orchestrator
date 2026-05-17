import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/crisis_model.dart';
import '../theme/app_theme.dart';
import 'severity_badge.dart';
import 'package:timeago/timeago.dart' as timeago;

class CrisisCard extends StatelessWidget {
  final CrisisModel crisis;
  final VoidCallback onTap;

  const CrisisCard({super.key, required this.crisis, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        crisis.type.toLowerCase().contains('flood') 
                          ? LucideIcons.waves 
                          : LucideIcons.flame,
                        color: AppTheme.neonBlue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        crisis.type,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  SeverityBadge(severity: crisis.severity),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(LucideIcons.mapPin, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(crisis.location, style: Theme.of(context).textTheme.bodyMedium),
                  const Spacer(),
                  const Icon(LucideIcons.clock, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    timeago.format(crisis.timestamp),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                crisis.description,
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
