class HistoryItem {
  final int id;
  final DateTime createdAt;
  final String modelName;
  final String modelVersion;
  final double defaultProbability;
  final int predictedDefault;
  final String riskBand;

  const HistoryItem({
    required this.id,
    required this.createdAt,
    required this.modelName,
    required this.modelVersion,
    required this.defaultProbability,
    required this.predictedDefault,
    required this.riskBand,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      modelName: json['model_name'] as String,
      modelVersion: json['model_version'] as String,
      defaultProbability: (json['default_probability'] as num).toDouble(),
      predictedDefault: json['predicted_default'] as int,
      riskBand: json['risk_band'] as String,
    );
  }
}
