import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import '../config/constants.dart';
import '../models/simulation_model.dart';

class SimulationService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));

  Future<SimulationModel?> runSimulation(String crisisId) async {
    if (kDemoMode) {
      await Future.delayed(AppConstants.animationSlow);
      final String response = await rootBundle.loadString('assets/mock/simulation.json');
      final Map<String, dynamic> data = json.decode(response);
      
      if (data.containsKey(crisisId)) {
        return SimulationModel.fromJson(data[crisisId]);
      } else {
        // Fallback for missing ids
        return SimulationModel.fromJson(data['c-001']);
      }
    } else {
      try {
        final response = await _dio.post('/simulate/$crisisId');
        return SimulationModel.fromJson(response.data);
      } catch (e) {
        throw Exception('Failed to run simulation: $e');
      }
    }
  }
}
