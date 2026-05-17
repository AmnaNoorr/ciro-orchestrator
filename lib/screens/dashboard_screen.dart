import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../providers/crisis_provider.dart';
import '../widgets/crisis_card.dart';
import '../theme/app_theme.dart';
import 'crisis_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CrisisProvider>(context, listen: false).loadCrises();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.activity, color: AppTheme.emergencyRed),
            SizedBox(width: 8),
            Text('LIVE FEED'),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: const Icon(LucideIcons.radioTower, color: AppTheme.neonBlue)
                .animate(onPlay: (controller) => controller.repeat())
                .fade(duration: 1.seconds),
          )
        ],
      ),
      body: Consumer<CrisisProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.crises.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.neonBlue));
          }

          if (provider.crises.isEmpty) {
            return const Center(child: Text('No active crises detected.'));
          }

          return RefreshIndicator(
            color: AppTheme.neonBlue,
            backgroundColor: AppTheme.cardNavy,
            onRefresh: () => provider.loadCrises(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: provider.crises.length,
              itemBuilder: (context, index) {
                final crisis = provider.crises[index];
                return CrisisCard(
                  crisis: crisis,
                  onTap: () {
                    provider.selectCrisis(crisis);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CrisisDetailScreen()),
                    );
                  },
                ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
              },
            ),
          );
        },
      ),
    );
  }
}
