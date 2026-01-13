/// Results from Monte Carlo simulation of reinforcement timing
class ReinforcementMetrics {
  /// Expected arrival percentage for each turn (1-5)
  /// Values represent percentage of total army points on board by end of turn
  final List<double> turn1Through5ArrivalPercent;

  /// 20th percentile arrival percentage for each turn (1-5)
  /// Lower bound of "typical" outcomes (80% of simulations had this or more)
  final List<double> turn1Through5P20;

  /// 80th percentile arrival percentage for each turn (1-5)
  /// Upper bound of "typical" outcomes (20% of simulations had this or more)
  final List<double> turn1Through5P80;

  const ReinforcementMetrics({
    required this.turn1Through5ArrivalPercent,
    required this.turn1Through5P20,
    required this.turn1Through5P80,
  });

  /// Get expected arrival percent for a specific turn (1-5)
  double getArrivalPercent(int turn) {
    if (turn < 1 || turn > 5) {
      throw ArgumentError('Turn must be between 1 and 5');
    }
    return turn1Through5ArrivalPercent[turn - 1];
  }

  /// Get 20th percentile for a specific turn (1-5)
  double getP20(int turn) {
    if (turn < 1 || turn > 5) {
      throw ArgumentError('Turn must be between 1 and 5');
    }
    return turn1Through5P20[turn - 1];
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
      'turn1Through5ArrivalPercent': turn1Through5ArrivalPercent,
      'turn1Through5P20': turn1Through5P20,
      'turn1Through5P80': turn1Through5P80,
    };
  }

  /// Create from JSON
  factory ReinforcementMetrics.fromJson(Map<String, dynamic> json) {
    return ReinforcementMetrics(
      turn1Through5ArrivalPercent: List<double>.from(json['turn1Through5ArrivalPercent']),
      turn1Through5P20: List<double>.from(json['turn1Through5P20']),
      turn1Through5P80: List<double>.from(json['turn1Through5P80']),
    );
  }

  /// Format for shareable text output
  String toShareableText() {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('REINFORCEMENT TIMING:');
    
    for (int turn = 1; turn <= 5; turn++) {
      final avg = getArrivalPercent(turn).round();
      final p20 = getP20(turn).round();
      final p80 = getP80(turn).round();
      buffer.writeln('Turn $turn: $avg% ($p20%-$p80%)');
    }
    
    return buffer.toString();
  }

  @override
  String toString() {
    return toShareableText();
  }
}
