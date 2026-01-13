/// Results from Monte Carlo simulation of reinforcement timing
class ReinforcementMetrics {
  /// Total number of regiments eligible for reinforcement (excludes regular characters)
  final int totalEligibleRegiments;

  /// Percentile arrival percentages for each turn (1-5)
  final List<double> turn1Through5P10;
  final List<double> turn1Through5P20;
  final List<double> turn1Through5P30;
  final List<double> turn1Through5P40;
  final List<double> turn1Through5P50;
  final List<double> turn1Through5P60;
  final List<double> turn1Through5P70;
  final List<double> turn1Through5P80;
  final List<double> turn1Through5P90;

  const ReinforcementMetrics({
    required this.totalEligibleRegiments,
    required this.turn1Through5P10,
    required this.turn1Through5P20,
    required this.turn1Through5P30,
    required this.turn1Through5P40,
    required this.turn1Through5P50,
    required this.turn1Through5P60,
    required this.turn1Through5P70,
    required this.turn1Through5P80,
    required this.turn1Through5P90,
  });

  /// Get percentile for a specific turn (1-5) and percentile level
  double getPercentile(int turn, int percentile) {
    if (turn < 1 || turn > 5) {
      throw ArgumentError('Turn must be between 1 and 5');
    }
    switch (percentile) {
      case 10:
        return turn1Through5P10[turn - 1];
      case 20:
        return turn1Through5P20[turn - 1];
      case 30:
        return turn1Through5P30[turn - 1];
      case 40:
        return turn1Through5P40[turn - 1];
      case 50:
        return turn1Through5P50[turn - 1];
      case 60:
        return turn1Through5P60[turn - 1];
      case 70:
        return turn1Through5P70[turn - 1];
      case 80:
        return turn1Through5P80[turn - 1];
      case 90:
        return turn1Through5P90[turn - 1];
      default:
        throw ArgumentError('Percentile must be 10, 20, 30, 40, 50, 60, 70, 80, or 90');
    }
  }

  /// Get regiment count for a specific turn and percentile
  int getRegimentCount(int turn, int percentile) {
    final percentage = getPercentile(turn, percentile);
    return ((percentage / 100) * totalEligibleRegiments).round();
  }

  /// Get 20th percentile for a specific turn (1-5)
  double getP20(int turn) {
    if (turn < 1 || turn > 5) {
      throw ArgumentError('Turn must be between 1 and 5');
    }
    return turn1Through5P20[turn - 1];
  }

  /// Get 50th percentile (median) for a specific turn (1-5)
  double getP50(int turn) {
    if (turn < 1 || turn > 5) {
      throw ArgumentError('Turn must be between 1 and 5');
    }
    return turn1Through5P50[turn - 1];
  }

  /// Get 80th percentile for a specific turn (1-5)
  double getP80(int turn) {
    if (turn < 1 || turn > 5) {
      throw ArgumentError('Turn must be between 1 and 5');
    }
    return turn1Through5P80[turn - 1];
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'totalEligibleRegiments': totalEligibleRegiments,
      'turn1Through5P10': turn1Through5P10,
      'turn1Through5P20': turn1Through5P20,
      'turn1Through5P30': turn1Through5P30,
      'turn1Through5P40': turn1Through5P40,
      'turn1Through5P50': turn1Through5P50,
      'turn1Through5P60': turn1Through5P60,
      'turn1Through5P70': turn1Through5P70,
      'turn1Through5P80': turn1Through5P80,
      'turn1Through5P90': turn1Through5P90,
    };
  }

  /// Create from JSON
  factory ReinforcementMetrics.fromJson(Map<String, dynamic> json) {
    return ReinforcementMetrics(
      totalEligibleRegiments: json['totalEligibleRegiments'] as int,
      turn1Through5P10: List<double>.from(json['turn1Through5P10']),
      turn1Through5P20: List<double>.from(json['turn1Through5P20']),
      turn1Through5P30: List<double>.from(json['turn1Through5P30']),
      turn1Through5P40: List<double>.from(json['turn1Through5P40']),
      turn1Through5P50: List<double>.from(json['turn1Through5P50']),
      turn1Through5P60: List<double>.from(json['turn1Through5P60']),
      turn1Through5P70: List<double>.from(json['turn1Through5P70']),
      turn1Through5P80: List<double>.from(json['turn1Through5P80']),
      turn1Through5P90: List<double>.from(json['turn1Through5P90']),
    );
  }

  /// Format for shareable text output
  String toShareableText() {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('REINFORCEMENT TIMING ($totalEligibleRegiments regiments):');
    
    for (int turn = 1; turn <= 5; turn++) {
      final p20 = getP20(turn).round();
      final p50 = getP50(turn).round();
      final p80 = getP80(turn).round();
      final r20 = getRegimentCount(turn, 20);
      final r50 = getRegimentCount(turn, 50);
      final r80 = getRegimentCount(turn, 80);
      buffer.writeln('Turn $turn: $p20%-$p50%-$p80% ($r20-$r50-$r80 regiments)');
    }
    
    return buffer.toString();
  }

  @override
  String toString() {
    return toShareableText();
  }
}
