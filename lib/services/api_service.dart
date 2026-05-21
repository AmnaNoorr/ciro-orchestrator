import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';

import '../config/constants.dart';
import '../models/crisis_model.dart';
import '../models/trace_model.dart';

class IngestResult {
  final bool success;
  final String? crisisId;
  final String? message;
  final CrisisModel? crisis;

  const IngestResult({
    required this.success,
    this.crisisId,
    this.message,
    this.crisis,
  });
}

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

  Future<IngestResult> ingestSignal(
    String text, {
    String? imagePath,
    String language = 'en',
    String? location,
  }) async {
    if (kDemoMode) {
      await Future.delayed(AppConstants.animationMedium);
      final crises = await getCrises();
      final latest = crises.isNotEmpty ? crises.first : null;
      return IngestResult(
        success: latest != null,
        crisisId: latest?.id,
        message: latest != null ? 'Demo crisis loaded' : 'No demo crisis found',
        crisis: latest,
      );
    }

    try {
      final response = await _dio.post('/ingest', data: {
        'text': text,
        'language': language,
        'location': location,
        'photo_url': imagePath,
      });

      final payload = Map<String, dynamic>.from(response.data as Map);
      final status = payload['status']?.toString() ?? '';
      final crisisId = payload['crisis_id']?.toString();
      final message = payload['message']?.toString();

      if (status != 'crisis_detected' || crisisId == null || crisisId.isEmpty) {
        return IngestResult(
          success: false,
          crisisId: crisisId,
          message: message ?? 'Signal did not produce a crisis',
        );
      }

      final crisis = await getCrisisById(crisisId);
      return IngestResult(
        success: true,
        crisisId: crisisId,
        message: message,
        crisis: crisis,
      );
    } catch (e) {
      throw Exception('Failed to ingest signal: $e');
    }
  }

  Future<CrisisModel> getCrisisById(String crisisId) async {
    if (kDemoMode) {
      final crises = await getCrises();
      return crises.firstWhere(
        (c) => c.id == crisisId,
        orElse: () => crises.first,
      );
    }
    final response = await _dio.get('/crises/$crisisId');
    return CrisisModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<TraceModel?> getTrace(String crisisId) async {
    if (kDemoMode) {
      await Future.delayed(AppConstants.animationFast);

      final String response =
          await rootBundle.loadString('assets/mock/traces.json');

      final decoded = json.decode(response);

      // ✅ If traces.json is a LIST
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

      // ✅ If traces.json is a SINGLE OBJECT
      if (decoded is Map<String, dynamic>) {
        return TraceModel.fromJson(decoded);
      }

      return null;
    } else {
      try {
        final response = await _dio.get('/traces/$crisisId');

        // ✅ FIX HERE
        final data = Map<String, dynamic>.from(response.data);

        return TraceModel.fromJson(data);
      } on DioException catch (e) {
        throw Exception('Failed to load trace: ${e.message}');
      } catch (e) {
        throw Exception('Failed to load trace: $e');
      }
    }
  }
}
