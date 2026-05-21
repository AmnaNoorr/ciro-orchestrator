import 'package:flutter/foundation.dart';
import '../models/crisis_model.dart';
import '../models/trace_model.dart';
import '../models/simulation_model.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';
import '../services/simulation_service.dart';

class CrisisProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final WebSocketService _webSocketService = WebSocketService();
  final SimulationService _simulationService = SimulationService();

  List<CrisisModel> _crises = [];
  bool _isLoading = false;
  String? _errorMessage;

  CrisisModel? _selectedCrisis;
  TraceModel? _selectedTrace;
  SimulationModel? _selectedSimulation;
  bool _isSimulating = false;

  List<CrisisModel> get crises => _crises;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CrisisModel? get selectedCrisis => _selectedCrisis;
  TraceModel? get selectedTrace => _selectedTrace;
  SimulationModel? get selectedSimulation => _selectedSimulation;
  bool get isSimulating => _isSimulating;

  CrisisProvider() {
    _initWebSocket();
  }

  void _initWebSocket() {
    _webSocketService.connect();
    _webSocketService.crisisStream.listen((newCrisis) {
      _crises.insert(0, newCrisis);
      notifyListeners();
    });
  }

  Future<void> loadCrises() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _crises = await _apiService.getCrises();
    } catch (e) {
      _errorMessage = e.toString();
      print("Error loading crises: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> ingestSignal(
    String text, {
    String? imagePath,
    String language = 'en',
    String? location,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    bool success = false;

    try {
      final result = await _apiService.ingestSignal(
        text,
        imagePath: imagePath,
        language: language,
        location: location,
      );
      success = result.success;

      if (!success) {
        _errorMessage = result.message ?? 'Signal did not produce a crisis.';
      } else if (result.crisis != null) {
        final crisis = result.crisis!;
        final existingIndex = _crises.indexWhere((c) => c.id == crisis.id);
        if (existingIndex >= 0) {
          _crises[existingIndex] = crisis;
        } else {
          _crises.insert(0, crisis);
        }
        _selectedCrisis = crisis;
        _selectedTrace = null;
        _selectedSimulation = null;
      }
    } catch (e) {
      _errorMessage = e.toString();
      print("Error ingesting signal: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return success;
  }

  void selectCrisis(CrisisModel crisis) {
    _selectedCrisis = crisis;
    _selectedTrace = null;
    _selectedSimulation = null;
    notifyListeners();
  }

  Future<void> runSimulation() async {
    if (_selectedCrisis == null) {
      _errorMessage = "No crisis selected";
      notifyListeners();
      return;
    }

    _isSimulating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedSimulation =
          await _simulationService.runSimulation(
            _selectedCrisis!.id,
            crisisCoordinates: _selectedCrisis!.coordinates,
          );
    } catch (e) {
      _errorMessage = e.toString();
      print("Error running simulation: $e");
    } finally {
      _isSimulating = false;
      notifyListeners();
    }
  }

  Future<void> loadTrace() async {
    if (_selectedCrisis == null) {
      _errorMessage = "No crisis selected for trace";
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedTrace =
          await _apiService.getTrace(_selectedCrisis!.id);
    } catch (e) {
      _errorMessage = e.toString();
      print("Error loading trace: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _webSocketService.dispose();
    super.dispose();
  }
}
