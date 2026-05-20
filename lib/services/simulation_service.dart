import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../config/constants.dart';
import '../models/simulation_model.dart';

class SimulationService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  Future<SimulationModel?> runSimulation(
    String crisisId, {
    LatLng? crisisCoordinates,
  }) async {
    if (kDemoMode) {
      await Future.delayed(AppConstants.animationSlow);
      final String response = await rootBundle.loadString('assets/mock/simulation.json');
      final Map<String, dynamic> data = json.decode(response);

      if (data.containsKey(crisisId) && data[crisisId] is Map) {
        final payload = Map<String, dynamic>.from(data[crisisId]);
        _injectCoordinates(payload, crisisCoordinates);
        return SimulationModel.fromJson(payload);
      } else if (data.containsKey('c-001') && data['c-001'] is Map) {
        // Fallback for missing ids
        final payload = Map<String, dynamic>.from(data['c-001']);
        _injectCoordinates(payload, crisisCoordinates);
        return SimulationModel.fromJson(payload);
      } else {
        // Also allow direct simulation object in demo file.
        _injectCoordinates(data, crisisCoordinates);
        return SimulationModel.fromJson(data);
      }
    } else {
      try {
        final response = await _dio.get('/simulation/$crisisId');
        final Map<String, dynamic> data = Map<String, dynamic>.from(response.data);
        if (data.containsKey(crisisId) && data[crisisId] is Map) {
          final payload = Map<String, dynamic>.from(data[crisisId]);
          _injectCoordinates(payload, crisisCoordinates);
          return SimulationModel.fromJson(payload);
        }
        // Accept direct simulation payload without crisis-id wrapper.
        _injectCoordinates(data, crisisCoordinates);
        return SimulationModel.fromJson(data);
      } on DioException catch (e) {
        throw Exception('Failed to run simulation: ${e.message}');
      } catch (e) {
        throw Exception('Failed to run simulation: $e');
      }
    }
  }

  void _injectCoordinates(Map<String, dynamic> payload, LatLng? coordinates) {
    if (coordinates == null) return;
    if (payload['coordinates'] != null) return;
    payload['coordinates'] = <String, dynamic>{
      'lat': coordinates.latitude,
      'lng': coordinates.longitude,
    };
  }
}
