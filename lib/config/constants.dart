/// Global Demo Mode Toggle
/// When true: Uses mock JSON and simulated events.
/// When false: Connects to real backend endpoints.
import 'package:google_maps_flutter/google_maps_flutter.dart';

const bool kDemoMode = false;

class AppConstants {
  // API Configuration
  // static const String baseUrl = 'http://10.0.2.2:8000';
  static const String baseUrl = 'http://192.168.1.10:8000';
  // static const String websocketUrl = 'ws://10.0.2.2:8000/ws';
  static const String websocketUrl = 'ws://192.168.1.10:8000/ws';

  // Demo Specific
  static const int demoEventIntervalSeconds = 6;
  static const LatLng defaultMapCenter = LatLng(33.6844, 73.0479);
  static const LatLng g10MapCenter = LatLng(33.6670, 72.9911); // G-10 Islamabad
  static const double defaultZoomLevel = 13.5;

  // Spacing & Layout
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadius = 16.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 300);
  static const Duration animationMedium = Duration(milliseconds: 600);
  static const Duration animationSlow = Duration(milliseconds: 1200);
}

// Minimal LatLng mock for constants if google_maps is not yet imported
// class LatLng {
//   final double latitude;
//   final double longitude;
//   const LatLng(this.latitude, this.longitude);
// }
