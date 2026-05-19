import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import '../config/constants.dart';
import '../models/simulation_model.dart';

class SimulationService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

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
        final response = await _dio.get('/simulation/$crisisId');
        final Map<String, dynamic> data = response.data;
        if (data.containsKey(crisisId)) {
          return SimulationModel.fromJson(data[crisisId]);
        }
        throw Exception("Simulation data missing for crisis $crisisId");
      } on DioException catch (e) {
        throw Exception('Failed to run simulation: ${e.message}');
      } catch (e) {
        throw Exception('Failed to run simulation: $e');
      }
    }
  }
}
