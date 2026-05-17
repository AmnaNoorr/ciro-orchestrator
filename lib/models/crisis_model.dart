import 'package:google_maps_flutter/google_maps_flutter.dart';

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
    var coords = json['coordinates'] as Map<String, dynamic>? ?? {};
    double lat = (coords['lat'] ?? 0.0).toDouble();
    double lng = (coords['lng'] ?? 0.0).toDouble();

    var impactsList = json['impacts'] as List? ?? [];
    List<ImpactModel> parsedImpacts = impactsList.map((i) => ImpactModel.fromJson(i)).toList();

    var actionsList = json['recommendedActions'] as List? ?? [];
    List<String> parsedActions = actionsList.map((e) => e.toString()).toList();

    return CrisisModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      location: json['location'] ?? '',
      coordinates: LatLng(lat, lng),
      severity: json['severity'] ?? 'LOW',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      description: json['description'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      impacts: parsedImpacts,
      recommendedActions: parsedActions,
      explanation: json['explanation'] ?? '',
    );
  }
}
