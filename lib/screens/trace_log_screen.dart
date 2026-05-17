import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import '../providers/crisis_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/trace_tile.dart';

class TraceLogScreen extends StatefulWidget {
  const TraceLogScreen({super.key});

  @override
  State<TraceLogScreen> createState() => _TraceLogScreenState();
}

class _TraceLogScreenState extends State<TraceLogScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CrisisProvider>(context, listen: false).loadTrace();
    });
  }

  void _exportJson(BuildContext context, Map<String, dynamic> data) {
    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    Share.share(jsonStr, subject: 'CIRO Agent Trace Export');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AGENT TRACE LOGS'),
        actions: [
          Consumer<CrisisProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: const Icon(LucideIcons.download),
                onPressed: provider.selectedTrace == null
                    ? null
                    : () {
                        // Generate a simple map to represent the export
                        final exportData = {
                          "crisisId": provider.selectedTrace!.crisisId,
                          "logs": provider.selectedTrace!.logs.map((e) => {
                            "agent": e.agent,
                            "action": e.action,
                            "timestamp": e.timestamp.toIso8601String(),
                            "reasoning": e.reasoning
                          }).toList()
                        };
                        _exportJson(context, exportData);
                      },
              );
            },
          ),
        ],
      ),
      body: Consumer<CrisisProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading || provider.selectedTrace == null) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.neonBlue));
          }

          final trace = provider.selectedTrace!;
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: trace.logs.length,
            itemBuilder: (context, index) {
              return TraceTile(
                step: trace.logs[index],
                isFirst: index == 0,
                isLast: index == trace.logs.length - 1,
              );
            },
          );
        },
      ),
    );
  }
}
