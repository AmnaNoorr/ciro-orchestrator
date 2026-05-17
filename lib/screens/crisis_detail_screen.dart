import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/crisis_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/impact_card.dart';
import 'simulation_screen.dart';
import 'trace_log_screen.dart';

class CrisisDetailScreen extends StatelessWidget {
  const CrisisDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CrisisProvider>(context);
    final crisis = provider.selectedCrisis;

    if (crisis == null) {
      return const Scaffold(body: Center(child: Text('No crisis selected')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI ANALYSIS'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.cpu, color: AppTheme.neonBlue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TraceLogScreen()),
              );
            },
            tooltip: 'View Agent Trace',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              crisis.type.toUpperCase(),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppTheme.emergencyRed),
            ).animate().fadeIn().slideX(begin: -0.1),
            const SizedBox(height: 8),
            Text(
              crisis.location,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.textSecondary),
            ).animate().fadeIn(delay: 100.ms),
            
            const SizedBox(height: 24),
            
            // Confidence Indicator
            Center(
              child: CircularPercentIndicator(
                radius: 80.0,
                lineWidth: 12.0,
                animation: true,
                percent: crisis.confidence,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(crisis.confidence * 100).toInt()}%',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const Text('CONFIDENCE', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                  ],
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: AppTheme.neonBlue,
                backgroundColor: AppTheme.cardNavy,
              ).animate().scale(delay: 200.ms, duration: 400.ms),
            ),
            
            const SizedBox(height: 32),
            Text('EXPECTED IMPACT', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: crisis.impacts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return ImpactCard(impact: crisis.impacts[index])
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: 300 + (index * 100)))
                      .slideX(begin: 0.2);
                },
              ),
            ),
            
            const SizedBox(height: 32),
            Text('RECOMMENDED ACTIONS', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...crisis.recommendedActions.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(LucideIcons.checkCircle2, color: AppTheme.successGreen, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(entry.value, style: const TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: Duration(milliseconds: 400 + (entry.key * 100)));
            }),
            
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardNavy,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.textSecondary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(LucideIcons.bot, color: AppTheme.amberWarning),
                      SizedBox(width: 8),
                      Text('AI EXPLANATION', style: TextStyle(color: AppTheme.amberWarning, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    crisis.explanation,
                    style: const TextStyle(color: AppTheme.textSecondary, height: 1.5),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 800.ms),
            
            const SizedBox(height: 100), // padding for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SimulationScreen()),
          );
        },
        backgroundColor: AppTheme.neonBlue,
        foregroundColor: AppTheme.darkNavy,
        icon: const Icon(LucideIcons.play),
        label: const Text('RUN SIMULATION', style: TextStyle(fontWeight: FontWeight.bold)),
      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
       .scaleXY(end: 1.05, duration: 1.seconds),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
