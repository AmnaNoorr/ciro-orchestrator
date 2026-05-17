import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../providers/crisis_provider.dart';
import '../theme/app_theme.dart';
import '../config/constants.dart';
import '../widgets/alert_card.dart';
import '../widgets/ticket_card.dart';
import '../models/simulation_model.dart';
import 'dart:async';
import 'dart:ui';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  bool _showAfter = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CrisisProvider>(context, listen: false).runSimulation();
    });
  }

  Set<Polyline> _buildPolylines(SimulationModel simulation) {
    final Set<Polyline> lines = {};

    final blockedRoutes = simulation.blockedRoutes ?? [];
    final reroutedPaths = simulation.reroutedPaths ?? [];

    // BLOCKED ROUTES (Current view)
    for (int i = 0; i < blockedRoutes.length; i++) {
      lines.add(
        Polyline(
          polylineId: PolylineId('blocked_$i'),
          points: blockedRoutes[i],
          color: AppTheme.emergencyRed,
          width: 6,
          patterns: [
            PatternItem.dash(20),
            PatternItem.gap(10),
          ],
        ),
      );
    }

    // REROUTED PATHS (After simulation)
    if (_showAfter) {
      for (int i = 0; i < reroutedPaths.length; i++) {
        lines.add(
          Polyline(
            polylineId: PolylineId('rerouted_$i'),
            points: reroutedPaths[i],
            color: AppTheme.successGreen,
            width: 5,
          ),
        );
      }
    }

    return lines;
  }

  Widget _buildKpiCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardNavy.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('COMMAND CENTER'),
        backgroundColor: AppTheme.darkNavy.withOpacity(0.7),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: Consumer<CrisisProvider>(
        builder: (context, provider, child) {
          if (provider.isSimulating ||
              provider.selectedSimulation == null ||
              provider.selectedCrisis == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.neonBlue),
                  SizedBox(height: 16),
                  Text('Calculating Response Strategies...'),
                ],
              ),
            );
          }

          final simulation = provider.selectedSimulation!;
          final crisis = provider.selectedCrisis!;

          return Stack(
            children: [
              // MAP
              GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: crisis.coordinates,
                  zoom: AppConstants.defaultZoomLevel,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                polylines: _buildPolylines(simulation),
                markers: {
                  Marker(
                    markerId: const MarkerId('crisis_epicenter'),
                    position: crisis.coordinates,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed,
                    ),
                    infoWindow: InfoWindow(title: crisis.type),
                  ),
                },
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),

              // TOGGLE
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardNavy,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: AppTheme.borderGlow),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _showAfter = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: !_showAfter
                                    ? AppTheme.neonBlue.withOpacity(0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                'Current',
                                style: TextStyle(
                                  color: !_showAfter
                                      ? AppTheme.neonBlue
                                      : AppTheme.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _showAfter = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: _showAfter
                                    ? AppTheme.successGreen.withOpacity(0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                'Simulated',
                                style: TextStyle(
                                  color: _showAfter
                                      ? AppTheme.successGreen
                                      : AppTheme.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // BOTTOM DASHBOARD
              if (_showAfter)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTheme.darkNavy.withOpacity(0.9),
                          AppTheme.darkNavy,
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildKpiCard(
                                  'Congestion Reduced',
                                  '${simulation.kpis.congestionReduced}%',
                                  LucideIcons.trendingDown,
                                  AppTheme.successGreen,
                                ),
                                const SizedBox(width: 8),
                                _buildKpiCard(
                                  'Routes Cleared',
                                  '${simulation.kpis.routesCleared}',
                                  LucideIcons.map,
                                  AppTheme.neonBlue,
                                ),
                                const SizedBox(width: 8),
                                _buildKpiCard(
                                  'Alerts Sent',
                                  '${simulation.kpis.alertsSent}',
                                  LucideIcons.radio,
                                  AppTheme.amberWarning,
                                ),
                                const SizedBox(width: 8),
                                _buildKpiCard(
                                  'Units Dispatched',
                                  '${simulation.kpis.unitsDispatched}',
                                  LucideIcons.truck,
                                  AppTheme.neonBlue,
                                ),
                              ],
                            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2),
                          ),
                          const SizedBox(height: 16),
                          AlertCard(message: simulation.alertMessage)
                              .animate()
                              .fadeIn(delay: 300.ms),
                          const SizedBox(height: 12),
                          TicketCard(ticket: simulation.ticket)
                              .animate()
                              .fadeIn(delay: 600.ms),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}