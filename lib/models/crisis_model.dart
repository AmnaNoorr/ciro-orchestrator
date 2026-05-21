import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../config/constants.dart';

class ImpactModel {
  final String icon;
  final String text;

  ImpactModel({required this.icon, required this.text});

  factory ImpactModel.fromJson(Map<String, dynamic> json) {
    return ImpactModel(
      icon: json['icon'] ?? '',
      text: json['text'] ?? '',
    );
  }
}

class CrisisModel {
  final String id;
  final String type;
  final String location;
  final LatLng coordinates;
  final String severity; // HIGH, MEDIUM, LOW
  final DateTime timestamp;
  final String description;
  final double confidence;
  final List<ImpactModel> impacts;
  final List<String> recommendedActions;
  final String explanation;

  CrisisModel({
    required this.id,
    required this.type,
    required this.location,
    required this.coordinates,
    required this.severity,
    required this.timestamp,
    required this.description,
    required this.confidence,
    required this.impacts,
    required this.recommendedActions,
    required this.explanation,
  });

  factory CrisisModel.fromJson(Map<String, dynamic> json) {
    final location = (json['location'] ?? '').toString();
    final LatLng parsedCoordinates = _parseCoordinates(json, location: location);

    var impactsList = json['impacts'] as List? ?? [];
    List<ImpactModel> parsedImpacts = impactsList.map((i) => ImpactModel.fromJson(i)).toList();

    var actionsList = json['recommendedActions'] as List? ?? [];
    List<String> parsedActions = actionsList.map((e) => e.toString()).toList();

    return CrisisModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      location: location,
      coordinates: parsedCoordinates,
      severity: json['severity'] ?? 'LOW',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      description: json['description'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      impacts: parsedImpacts,
      recommendedActions: parsedActions,
      explanation: json['explanation'] ?? '',
    );
  }

  static LatLng _parseCoordinates(
    Map<String, dynamic> json, {
    required String location,
  }) {
    final dynamic rawCoords = json['coordinates'];

    double? lat;
    double? lng;

    if (rawCoords is Map) {
      lat = _asDouble(rawCoords['lat']) ?? _asDouble(rawCoords['latitude']);
      lng = _asDouble(rawCoords['lng']) ?? _asDouble(rawCoords['longitude']);
    } else if (rawCoords is List && rawCoords.length >= 2) {
      lat = _asDouble(rawCoords[0]);
      lng = _asDouble(rawCoords[1]);
    }

    lat ??= _asDouble(json['lat']) ?? _asDouble(json['latitude']);
    lng ??= _asDouble(json['lng']) ?? _asDouble(json['longitude']);

    if (_isValidCoordinate(lat, lng)) {
      return LatLng(lat!, lng!);
    }

    final inferred = _inferCoordinatesFromLocation(location);
    if (inferred != null) return inferred;

    return AppConstants.defaultMapCenter;
  }

  static double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static bool _isValidCoordinate(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    if (lat == 0.0 && lng == 0.0) return false;
    if (lat < -90.0 || lat > 90.0) return false;
    if (lng < -180.0 || lng > 180.0) return false;
    return true;
  }

  static LatLng? _inferCoordinatesFromLocation(String location) {
    final value = location.toLowerCase();
    const cityCenters = <String, LatLng>{
      'islamabad': LatLng(33.6844, 73.0479),
      'rawalpindi': LatLng(33.6007, 73.0679),
      'lahore': LatLng(31.5204, 74.3587),
      'karachi': LatLng(24.8607, 67.0011),
      'multan': LatLng(30.1575, 71.5249),
      'faisalabad': LatLng(31.4504, 73.1350),
      'peshawar': LatLng(34.0151, 71.5249),
      'quetta': LatLng(30.1798, 66.9750),
      'hyderabad': LatLng(25.3960, 68.3578),
      'sialkot': LatLng(32.4945, 74.5229),
      'gujranwala': LatLng(32.1877, 74.1945),
      'bahawalpur': LatLng(29.3956, 71.6836),
      'sukkur': LatLng(27.7052, 68.8574),
      'abbottabad': LatLng(34.1688, 73.2215),
      'swat': LatLng(34.7717, 72.3602),
      'gilgit': LatLng(35.9208, 74.3144),
      'muzaffarabad': LatLng(34.3700, 73.4700),
    };

    for (final entry in cityCenters.entries) {
      if (value.contains(entry.key)) return entry.value;
    }

    return null;
  }
}
