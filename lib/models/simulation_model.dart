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
    var kpisJson = json['kpis'] ?? {};
    var ticketJson = json['ticket'] ?? {};

    var blockedList = json['blockedRoutes'] as List? ?? [];
    List<List<LatLng>> parsedBlocked = blockedList.map((route) {
      return (route as List).map((point) {
        return LatLng((point['lat'] ?? 0.0).toDouble(), (point['lng'] ?? 0.0).toDouble());
      }).toList();
    }).toList();

    var reroutedList = json['reroutedPaths'] as List? ?? [];
    List<List<LatLng>> parsedRerouted = reroutedList.map((route) {
      return (route as List).map((point) {
        return LatLng((point['lat'] ?? 0.0).toDouble(), (point['lng'] ?? 0.0).toDouble());
      }).toList();
    }).toList();

    return SimulationModel(
      kpis: SimulationKpi.fromJson(kpisJson),
      blockedRoutes: parsedBlocked,
      reroutedPaths: parsedRerouted,
      ticket: TicketModel.fromJson(ticketJson),
      alertMessage: json['alertMessage'] ?? '',
    );
  }
}
