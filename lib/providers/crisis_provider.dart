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
  
  // Selected state
  CrisisModel? _selectedCrisis;
  TraceModel? _selectedTrace;
  SimulationModel? _selectedSimulation;
  bool _isSimulating = false;

  List<CrisisModel> get crises => _crises;
  bool get isLoading => _isLoading;
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
      // Add to top of list
      _crises.insert(0, newCrisis);
      notifyListeners();
    });
  }

  Future<void> loadCrises() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _crises = await _apiService.getCrises();
    } catch (e) {
      print("Error loading crises: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> ingestSignal(String text, {String? imagePath}) async {
    _isLoading = true;
    notifyListeners();
    
    bool success = false;
    try {
      success = await _apiService.ingestSignal(text, imagePath: imagePath);
    } catch (e) {
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
    if (_selectedCrisis == null) return;
    
    _isSimulating = true;
    notifyListeners();
    
    try {
      _selectedSimulation = await _simulationService.runSimulation(_selectedCrisis!.id);
    } catch (e) {
      print("Error running simulation: $e");
    } finally {
      _isSimulating = false;
      notifyListeners();
    }
  }

  Future<void> loadTrace() async {
    if (_selectedCrisis == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      _selectedTrace = await _apiService.getTrace(_selectedCrisis!.id);
    } catch (e) {
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
