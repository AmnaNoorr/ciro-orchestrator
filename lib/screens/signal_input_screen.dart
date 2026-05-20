import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:ui';
import '../theme/app_theme.dart';
import '../providers/crisis_provider.dart';
import 'dashboard_screen.dart';

class SignalInputScreen extends StatefulWidget {
  const SignalInputScreen({super.key});

  @override
  State<SignalInputScreen> createState() => _SignalInputScreenState();
}

class _SignalInputScreenState extends State<SignalInputScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isUrdu = false;

  void _submitSignal() async {
    if (_controller.text.trim().isEmpty) return;
    
    final provider = Provider.of<CrisisProvider>(context, listen: false);
    final success = await provider.ingestSignal(_controller.text);
    
    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else if (mounted) {
      final error = provider.errorMessage ?? 'Unable to send signal right now.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CrisisProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Glow Elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.neonBlue.withOpacity(0.15),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .scaleXY(end: 1.2, duration: const Duration(seconds: 4)),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'CIRO',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppTheme.neonBlue,
                      letterSpacing: 4,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.5, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'Crisis Intelligence & Response Orchestrator',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 300.ms),
                  const Spacer(),
                  
                  // Glassmorphism Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.cardNavy.withOpacity(0.7),
                          border: Border.all(color: AppTheme.borderGlow),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Report Signal', style: Theme.of(context).textTheme.titleLarge),
                                Row(
                                  children: [
                                    Text('EN', style: TextStyle(color: !_isUrdu ? AppTheme.neonBlue : AppTheme.textSecondary)),
                                    Switch(
                                      value: _isUrdu,
                                      activeThumbColor: AppTheme.neonBlue,
                                      onChanged: (val) => setState(() => _isUrdu = val),
                                    ),
                                    Text('UR', style: TextStyle(color: _isUrdu ? AppTheme.neonBlue : AppTheme.textSecondary)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Directionality(
                              textDirection: _isUrdu ? TextDirection.rtl : TextDirection.ltr,
                              child: TextField(
                                controller: _controller,
                                maxLines: 4,
                                style: const TextStyle(color: AppTheme.textPrimary),
                                decoration: InputDecoration(
                                  hintText: _isUrdu ? 'G-10 mein pani bhar gaya hai...' : 'Flash flood happening in G-10...',
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(LucideIcons.camera, color: AppTheme.textSecondary),
                                  onPressed: () {
                                    // Optional image picker mock
                                  },
                                ),
                                const Spacer(),
                                ElevatedButton(
                                  onPressed: provider.isLoading ? null : _submitSignal,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                  ),
                                  child: provider.isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.darkNavy),
                                        )
                                      : const Text('ENGAGE CIRO'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
                  
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
