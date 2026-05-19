import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';

import '../config/constants.dart';
import '../models/crisis_model.dart';
import '../models/trace_model.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<List<CrisisModel>> getCrises() async {
    if (kDemoMode) {
      await Future.delayed(AppConstants.animationFast);

      final String response =
          await rootBundle.loadString('assets/mock/crises.json');

      final List<dynamic> data = json.decode(response);

      return data.map((e) => CrisisModel.fromJson(e)).toList();
    }

    try {
      final response = await _dio.get('/crises');

      final data = response.data;

      if (data is List) {
        return data.map((e) => CrisisModel.fromJson(e)).toList();
      } else {
        throw Exception("Expected List but got ${data.runtimeType}");
      }
    } catch (e) {
      throw Exception('Failed to load crises: $e');
    }
  }

  Future<bool> ingestSignal(String text, {String? imagePath}) async {
    if (kDemoMode) {
      await Future.delayed(AppConstants.animationMedium);
      return true;
    }

    try {
      await _dio.post('/ingest', data: {
        'text': text,
        'imagePath': imagePath,
      });

      return true;
    } catch (e) {
      throw Exception('Failed to ingest signal: $e');
    }
  }

  Future<TraceModel?> getTrace(String crisisId) async {
    if (kDemoMode) {
      await Future.delayed(AppConstants.animationFast);

      final String response =
          await rootBundle.loadString('assets/mock/traces.json');

      final decoded = json.decode(response);

      // ✅ CASE 1: API returns a LIST
      if (decoded is List) {
        final traceData = decoded.firstWhere(
          (t) => t['crisisId'] == crisisId,
          orElse: () => null,
        );

        if (traceData == null) return null;

        return TraceModel.fromJson(
          Map<String, dynamic>.from(traceData),
        );
      }

      // ✅ CASE 2: API returns a MAP (most likely your case)
      if (decoded is Map<String, dynamic>) {
        if (decoded['crisisId'] == crisisId) {
          return TraceModel.fromJson(decoded);
        }
        return null;
      }

      return null;
    } else {
      try {
        final response = await _dio.get('/traces/$crisisId');

        return TraceModel.fromJson(
          Map<String, dynamic>.from(response.data),
        );
      } catch (e) {
        throw Exception('Failed to load trace: $e');
      }
    }
  }
}
