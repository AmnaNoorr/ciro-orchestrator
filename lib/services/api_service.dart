import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import '../config/constants.dart';
import '../models/crisis_model.dart';
import '../models/trace_model.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));

  Future<List<CrisisModel>> getCrises() async {
    if (kDemoMode) {
      // Simulate network delay
      await Future.delayed(AppConstants.animationFast);
      final String response = await rootBundle.loadString('assets/mock/crises.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) => CrisisModel.fromJson(json)).toList();
    } else {
      try {
        final response = await _dio.get('/crises');
        final List<dynamic> data = response.data;
        return data.map((json) => CrisisModel.fromJson(json)).toList();
      } catch (e) {
        throw Exception('Failed to load crises: $e');
      }
    }
  }

  Future<bool> ingestSignal(String text, {String? imagePath}) async {
    if (kDemoMode) {
      await Future.delayed(AppConstants.animationMedium);
      return true;
    } else {
      try {
        await _dio.post('/ingest', data: {'text': text, 'imagePath': imagePath});
        return true;
      } catch (e) {
        throw Exception('Failed to ingest signal: $e');
      }
    }
  }

  Future<TraceModel?> getTrace(String crisisId) async {
    if (kDemoMode) {
      await Future.delayed(AppConstants.animationFast);
      final String response = await rootBundle.loadString('assets/mock/traces.json');
      final List<dynamic> data = json.decode(response);
      try {
        final traceData = data.firstWhere((t) => t['crisisId'] == crisisId);
        return TraceModel.fromJson(traceData);
      } catch (e) {
        return null;
      }
    } else {
      try {
        final response = await _dio.get('/trace/$crisisId');
        return TraceModel.fromJson(response.data);
      } catch (e) {
        throw Exception('Failed to load trace: $e');
      }
    }
  }
}
