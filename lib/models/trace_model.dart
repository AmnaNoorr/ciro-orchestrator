class TraceLogStep {
  final String agent;
  final String action;
  final DateTime timestamp;
  final String reasoning;
  final String colorHex;

  TraceLogStep({
    required this.agent,
    required this.action,
    required this.timestamp,
    required this.reasoning,
    required this.colorHex,
  });

  factory TraceLogStep.fromJson(Map<String, dynamic> json) {
    return TraceLogStep(
      agent: json['agent'] ?? '',
      action: json['action'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      reasoning: json['reasoning'] ?? '',
      colorHex: json['color'] ?? '#FFFFFF',
    );
  }
}

class TraceModel {
  final String crisisId;
  final List<TraceLogStep> logs;

  TraceModel({
    required this.crisisId,
    required this.logs,
  });

  factory TraceModel.fromJson(Map<String, dynamic> json) {
    var logsList = json['logs'] as List? ?? [];
    List<TraceLogStep> parsedLogs = logsList.map((l) => TraceLogStep.fromJson(l)).toList();

    return TraceModel(
      crisisId: json['crisisId'] ?? '',
      logs: parsedLogs,
    );
  }
}
