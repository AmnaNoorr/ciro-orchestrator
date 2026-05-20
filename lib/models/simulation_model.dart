import 'package:google_maps_flutter/google_maps_flutter.dart';

class SimulationKpi {
  final int congestionReduced;
  final int routesCleared;
  final int alertsSent;
  final int unitsDispatched;

  SimulationKpi({
    required this.congestionReduced,
    required this.routesCleared,
    required this.alertsSent,
    required this.unitsDispatched,
  });

  factory SimulationKpi.fromJson(Map<String, dynamic> json) {
    return SimulationKpi(
      congestionReduced: json['congestionReduced'] ?? 0,
      routesCleared: json['routesCleared'] ?? 0,
      alertsSent: json['alertsSent'] ?? 0,
      unitsDispatched: json['unitsDispatched'] ?? 0,
    );
  }
}

class TicketModel {
  final String id;
  final String unit;
  final String eta;
  final String status;

  TicketModel({
    required this.id,
    required this.unit,
    required this.eta,
    required this.status,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] ?? '',
      unit: json['unit'] ?? '',
      eta: json['eta'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class SimulationModel {
  final SimulationKpi kpis;
  final List<List<LatLng>>? blockedRoutes; 
  final List<List<LatLng>>? reroutedPaths;
  final TicketModel ticket;
  final String alertMessage;

  SimulationModel({
    required this.kpis,
    required this.blockedRoutes,
    required this.reroutedPaths,
    required this.ticket,
    required this.alertMessage,
  });

  factory SimulationModel.fromJson(Map<String, dynamic> json) {
    final kpisJson = _asMap(json['kpis']) ?? <String, dynamic>{};
    final ticketJson = _asMap(json['ticket']) ?? <String, dynamic>{};

    var parsedBlocked = _parseRouteGroups(
      json['blockedRoutes'] ?? json['blocked_routes'] ?? json['currentRoute'] ?? json['current_route'],
    );
    var parsedRerouted = _parseRouteGroups(
      json['reroutedPaths'] ?? json['rerouted_paths'] ?? json['simulatedRoute'] ?? json['simulated_route'],
    );

    // Demo-safe fallback: synthesize simple geometry if backend omits route data.
    if (parsedBlocked.isEmpty || parsedRerouted.isEmpty) {
      final fallbackCenter = _parseCenterPoint(json);
      if (fallbackCenter != null) {
        parsedBlocked = parsedBlocked.isEmpty
            ? _buildFallbackBlockedRoutes(fallbackCenter)
            : parsedBlocked;
        parsedRerouted = parsedRerouted.isEmpty
            ? _buildFallbackSimulatedRoutes(fallbackCenter)
            : parsedRerouted;
      }
    }

    return SimulationModel(
      kpis: SimulationKpi.fromJson(kpisJson),
      blockedRoutes: parsedBlocked,
      reroutedPaths: parsedRerouted,
      ticket: TicketModel.fromJson(ticketJson),
      alertMessage: (json['alertMessage'] ?? json['alert_message'] ?? '').toString(),
    );
  }

  static List<List<LatLng>> _parseRouteGroups(dynamic raw) {
    if (raw is! List || raw.isEmpty) return <List<LatLng>>[];

    // Accept either:
    // 1) [[{lat,lng},...], [{lat,lng},...]]
    // 2) [{lat,lng}, {lat,lng}]  (single route)
    if (raw.first is Map || raw.first is List) {
      if (raw.first is Map) {
        final single = _parseSingleRoute(raw);
        return single.isEmpty ? <List<LatLng>>[] : <List<LatLng>>[single];
      }

      return raw
          .whereType<List>()
          .map(_parseSingleRoute)
          .where((route) => route.length >= 2)
          .toList();
    }

    return <List<LatLng>>[];
  }

  static List<LatLng> _parseSingleRoute(List route) {
    return route
        .whereType<Map>()
        .map((point) {
          final lat = _toDouble(point['lat'] ?? point['latitude']);
          final lng = _toDouble(point['lng'] ?? point['lon'] ?? point['longitude']);
          if (lat == null || lng == null) return null;
          return LatLng(lat, lng);
        })
        .whereType<LatLng>()
        .toList();
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static LatLng? _parseCenterPoint(Map<String, dynamic> json) {
    final dynamic raw = json['coordinates'];
    if (raw is Map) {
      final lat = _toDouble(raw['lat'] ?? raw['latitude']);
      final lng = _toDouble(raw['lng'] ?? raw['lon'] ?? raw['longitude']);
      if (lat != null && lng != null) return LatLng(lat, lng);
    }
    final lat = _toDouble(json['lat'] ?? json['latitude']);
    final lng = _toDouble(json['lng'] ?? json['lon'] ?? json['longitude']);
    if (lat != null && lng != null) return LatLng(lat, lng);
    return null;
  }

  static List<List<LatLng>> _buildFallbackBlockedRoutes(LatLng c) {
    return <List<LatLng>>[
      <LatLng>[
        LatLng(c.latitude - 0.0020, c.longitude - 0.0010),
        LatLng(c.latitude, c.longitude),
      ],
      <LatLng>[
        LatLng(c.latitude, c.longitude),
        LatLng(c.latitude + 0.0015, c.longitude + 0.0020),
      ],
    ];
  }

  static List<List<LatLng>> _buildFallbackSimulatedRoutes(LatLng c) {
    return <List<LatLng>>[
      <LatLng>[
        LatLng(c.latitude - 0.0020, c.longitude - 0.0010),
        LatLng(c.latitude - 0.0010, c.longitude + 0.0015),
      ],
      <LatLng>[
        LatLng(c.latitude - 0.0010, c.longitude + 0.0015),
        LatLng(c.latitude + 0.0015, c.longitude + 0.0020),
      ],
    ];
  }
}
