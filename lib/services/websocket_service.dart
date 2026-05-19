import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/constants.dart';
import '../models/crisis_model.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final StreamController<CrisisModel> _crisisStreamController = StreamController<CrisisModel>.broadcast();
  Timer? _mockTimer;

  Stream<CrisisModel> get crisisStream => _crisisStreamController.stream;

  void connect() {
    if (kDemoMode) {
      _startMockLiveFeed();
    } else {
      _connectWebSocket();
    }
  }

  void _connectWebSocket() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(AppConstants.websocketUrl));
      _channel!.stream.listen(
        (message) {
          try {
            final payload = json.decode(message);
            if (payload is Map<String, dynamic> && payload['event'] == 'crisis_detected') {
              final data = payload['data'];
              if (data != null) {
                _crisisStreamController.add(CrisisModel.fromJson(data));
              }
            }
          } catch (e) {
            print('WebSocket decode error: $e');
          }
        },
        onDone: () {
          print('WebSocket disconnected, attempting reconnect...');
          Future.delayed(const Duration(seconds: 3), _connectWebSocket);
        },
        onError: (error) {
          print('WebSocket error: $error');
        },
      );
    } catch (e) {
      print('WebSocket connection error: $e');
      Future.delayed(const Duration(seconds: 3), _connectWebSocket);
    }
  }

  void _startMockLiveFeed() {
    final random = Random();
    
    _mockTimer = Timer.periodic(const Duration(seconds: AppConstants.demoEventIntervalSeconds), (timer) {
      final isHighSeverity = random.nextBool();
      final types = ['Flooding Detected', 'Accident Spike', 'Congestion Update', 'Ambulance Dispatched'];
      final locations = ['F-8, Islamabad', 'Kashmir Highway', 'Zero Point', 'I-8 Markaz'];
      
      final mockEvent = CrisisModel(
        id: 'ws-${DateTime.now().millisecondsSinceEpoch}',
        type: types[random.nextInt(types.length)],
        location: locations[random.nextInt(locations.length)],
        coordinates: AppConstants.defaultMapCenter,
        severity: isHighSeverity ? 'HIGH' : (random.nextBool() ? 'MEDIUM' : 'LOW'),
        timestamp: DateTime.now(),
        description: 'Live update received from IoT sensors and smart cameras.',
        confidence: 0.70 + (random.nextDouble() * 0.25),
        impacts: [],
        recommendedActions: [],
        explanation: 'Automated live feed from city orchestrator.',
      );

      _crisisStreamController.add(mockEvent);
    });
  }

  void dispose() {
    _mockTimer?.cancel();
    _channel?.sink.close();
    _crisisStreamController.close();
  }
}
