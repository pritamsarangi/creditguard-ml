class RiskInfo {
  final String level;
  final String label;
  final double estimatedProbability;
  final int percentage;

  const RiskInfo({
    required this.level,
    required this.label,
    required this.estimatedProbability,
    required this.percentage,
  });

  factory RiskInfo.fromJson(Map<String, dynamic> json) {
    return RiskInfo(
      level: json['level']?.toString() ?? 'unknown',
      label: json['label']?.toString() ?? 'Unknown Risk',
      estimatedProbability:
          (json['estimated_probability'] as num?)?.toDouble() ?? 0,
      percentage: (json['percentage'] as num?)?.toInt() ?? 0,
    );
  }
}

class PredictionSummary {
  final String title;
  final String message;

  const PredictionSummary({
    required this.title,
    required this.message,
  });

  factory PredictionSummary.fromJson(Map<String, dynamic> json) {
    return PredictionSummary(
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }
}

class PredictionFactor {
  final String title;
  final String status;
  final String message;

  const PredictionFactor({
    required this.title,
    required this.status,
    required this.message,
  });

  factory PredictionFactor.fromJson(Map<String, dynamic> json) {
    return PredictionFactor(
      title: json['title']?.toString() ?? '',
      status: json['status']?.toString() ?? 'neutral',
      message: json['message']?.toString() ?? '',
    );
  }
}

class PredictionResponse {
  final int id;
  final DateTime createdAt;
  final RiskInfo risk;
  final PredictionSummary summary;
  final List<PredictionFactor> factors;
  final String explanationNote;
  final String disclaimer;

  const PredictionResponse({
    required this.id,
    required this.createdAt,
    required this.risk,
    required this.summary,
    required this.factors,
    required this.explanationNote,
    required this.disclaimer,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    return PredictionResponse(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      risk: RiskInfo.fromJson(json['risk'] as Map<String, dynamic>),
      summary: PredictionSummary.fromJson(
        json['summary'] as Map<String, dynamic>,
      ),
      factors: (json['factors'] as List<dynamic>? ?? [])
          .map(
            (item) => PredictionFactor.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      explanationNote: json['explanation_note']?.toString() ?? '',
      disclaimer: json['disclaimer']?.toString() ?? '',
    );
  }
}
