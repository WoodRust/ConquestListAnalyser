import 'dart:math';
import '../models/army_list.dart';
import '../models/regiment.dart';
import '../models/reinforcement_metrics.dart';
import 'warband_manager.dart';

/// Simulates reinforcement arrival timing using Monte Carlo method
class ReinforcementSimulator {
  final Random _random;

  /// Create simulator with optional seed for deterministic testing
  ReinforcementSimulator({int? seed}) : _random = Random(seed);

  /// Run Monte Carlo simulation to compute reinforcement timing metrics
  /// Returns average arrival percentages and percentiles for turns 1-5
  ReinforcementMetrics simulate(ArmyList armyList, {int simulations = 10000}) {
    // Infer warbands and apply Forward Force
    final warbands = WarbandManager.inferWarbands(armyList);
    final computedFlank = WarbandManager.applyForwardForce(warbands);

    // Get all regiments that need to arrive (excluding regular characters)
    final regimentsToArrive = _getRegimentsForReinforcement(armyList);
    
    // Calculate total regiment count (excluding regular characters)
    final totalRegiments = regimentsToArrive.length;

    if (totalRegiments == 0) {
      // Edge case: no regiments to deploy
      return ReinforcementMetrics(
        totalEligibleRegiments: 0,
        turn1Through5P10: [0, 0, 0, 0, 0],
        turn1Through5P20: [0, 0, 0, 0, 0],
        turn1Through5P30: [0, 0, 0, 0, 0],
        turn1Through5P40: [0, 0, 0, 0, 0],
        turn1Through5P50: [0, 0, 0, 0, 0],
        turn1Through5P60: [0, 0, 0, 0, 0],
        turn1Through5P70: [0, 0, 0, 0, 0],
        turn1Through5P80: [0, 0, 0, 0, 0],
        turn1Through5P90: [0, 0, 0, 0, 0],
      );
    }

    // Run simulations
    final List<List<double>> allSimulations = [];
    for (int i = 0; i < simulations; i++) {
      final turnResults = _runSingleSimulation(
        regimentsToArrive,
        computedFlank,
        totalRegiments,
      );
      allSimulations.add(turnResults);
    }

    // Calculate percentiles
    final p10Values = _calculatePercentiles(allSimulations, 0.10);
    final p20Values = _calculatePercentiles(allSimulations, 0.20);
    final p30Values = _calculatePercentiles(allSimulations, 0.30);
    final p40Values = _calculatePercentiles(allSimulations, 0.40);
    final p50Values = _calculatePercentiles(allSimulations, 0.50);
    final p60Values = _calculatePercentiles(allSimulations, 0.60);
    final p70Values = _calculatePercentiles(allSimulations, 0.70);
    final p80Values = _calculatePercentiles(allSimulations, 0.80);
    final p90Values = _calculatePercentiles(allSimulations, 0.90);

    return ReinforcementMetrics(
      totalEligibleRegiments: totalRegiments,
      turn1Through5P10: p10Values,
      turn1Through5P20: p20Values,
      turn1Through5P30: p30Values,
      turn1Through5P40: p40Values,
      turn1Through5P50: p50Values,
      turn1Through5P60: p60Values,
      turn1Through5P70: p70Values,
      turn1Through5P80: p80Values,
      turn1Through5P90: p90Values,
    );
  }

  /// Get all regiments that participate in reinforcement
  /// Includes regular regiments and character monsters
  /// Excludes regular characters (non-monster characters)
  List<Regiment> _getRegimentsForReinforcement(ArmyList armyList) {
    return armyList.regiments.where((regiment) {
      final isRegularCharacter = regiment.unit.regimentClass.toLowerCase() == 'character' &&
          regiment.unit.type.toLowerCase() != 'monster';
      return !isRegularCharacter;
    }).toList();
  }

  /// Run a single simulation and return cumulative arrival percentages for turns 1-5
  List<double> _runSingleSimulation(
    List<Regiment> regiments,
    Map<Regiment, bool> computedFlank,
    int totalRegiments,
  ) {
    // Track which regiments have arrived
    final Set<Regiment> arrived = {};
    final List<double> turnPercentages = [];

    // Simulate each turn
    for (int turn = 1; turn <= 5; turn++) {
      // Get regiments that can arrive this turn (not yet arrived)
      final notArrived = regiments.where((r) => !arrived.contains(r)).toList();
      
      if (notArrived.isEmpty) {
        // All arrived - maintain 100%
        turnPercentages.add(100.0);
        continue;
      }

      // Process Flank auto-arrivals
      final flankArrivals = _processFlankArrivals(notArrived, computedFlank, turn);
      arrived.addAll(flankArrivals);

      // Refresh not-arrived list
      final remainingNotArrived = regiments.where((r) => !arrived.contains(r)).toList();
      
      if (remainingNotArrived.isEmpty) {
        turnPercentages.add(_calculateArrivalPercentage(arrived, totalRegiments));
        continue;
      }

      // Player selects one unit to auto-arrive (highest value in eligible weight class)
      final playerSelected = _selectPlayerUnit(remainingNotArrived, turn);
      if (playerSelected != null) {
        arrived.add(playerSelected);
      }

      // Refresh not-arrived list again
      final finalNotArrived = regiments.where((r) => !arrived.contains(r)).toList();
      
      if (finalNotArrived.isEmpty) {
        turnPercentages.add(_calculateArrivalPercentage(arrived, totalRegiments));
        continue;
      }

      // Roll for reinforcements by weight class
      final diceArrivals = _rollForReinforcements(finalNotArrived, turn);
      arrived.addAll(diceArrivals);

      // Calculate cumulative arrival percentage
      turnPercentages.add(_calculateArrivalPercentage(arrived, totalRegiments));
    }

    return turnPercentages;
  }

  /// Process Flank units that auto-arrive at their earliest eligible turn
  List<Regiment> _processFlankArrivals(
    List<Regiment> notArrived,
    Map<Regiment, bool> computedFlank,
    int turn,
  ) {
    final List<Regiment> arrivals = [];

    for (final regiment in notArrived) {
      if (!WarbandManager.hasFlank(regiment, computedFlank)) {
        continue;
      }

      // Get weight class for this regiment
      final weightClass = _getWeightClass(regiment);
      final eligibleTurn = _getEarliestEligibleTurn(weightClass);

      if (turn >= eligibleTurn) {
        arrivals.add(regiment);
      }
    }

    return arrivals;
  }

  /// Select one unit for player to auto-arrive this turn
  /// Choose highest points unit in eligible weight classes
  Regiment? _selectPlayerUnit(List<Regiment> notArrived, int turn) {
    // Determine which weight classes are eligible this turn
    final eligibleWeights = <String>[];
    if (turn >= 1) eligibleWeights.add('light');
    if (turn >= 2) eligibleWeights.add('medium');
    if (turn >= 3) eligibleWeights.add('heavy');

    // Filter to eligible regiments
    final eligible = notArrived.where((regiment) {
      final weightClass = _getWeightClass(regiment);
      return eligibleWeights.contains(weightClass);
    }).toList();

    if (eligible.isEmpty) {
      return null;
    }

    // Select highest points unit (with weight class priority as tiebreaker)
    eligible.sort((a, b) {
      // First by points (descending)
      final pointsCompare = b.pointsCost.compareTo(a.pointsCost);
      if (pointsCompare != 0) return pointsCompare;

      // Tiebreaker: Heavy > Medium > Light
      final weightA = _getWeightClass(a);
      final weightB = _getWeightClass(b);
      return _weightPriority(weightB).compareTo(_weightPriority(weightA));
    });

    return eligible.first;
  }

  /// Roll dice for reinforcements based on turn and weight class
  List<Regiment> _rollForReinforcements(List<Regiment> notArrived, int turn) {
    final List<Regiment> arrivals = [];

    // Group by weight class
    final lights = notArrived.where((r) => _getWeightClass(r) == 'light').toList();
    final mediums = notArrived.where((r) => _getWeightClass(r) == 'medium').toList();
    final heavies = notArrived.where((r) => _getWeightClass(r) == 'heavy').toList();

    // Process each weight class based on turn rules
    if (turn == 1) {
      // Turn 1: Lights arrive on 4 or less
      arrivals.addAll(_rollForWeightClass(lights, 4));
    } else if (turn == 2) {
      // Turn 2: Lights on 4 or less, Mediums on 2 or less
      arrivals.addAll(_rollForWeightClass(lights, 4));
      arrivals.addAll(_rollForWeightClass(mediums, 2));
    } else if (turn == 3) {
      // Turn 3: Lights auto, Mediums on 4 or less, Heavies on 2 or less
      arrivals.addAll(lights);
      arrivals.addAll(_rollForWeightClass(mediums, 4));
      arrivals.addAll(_rollForWeightClass(heavies, 2));
    } else if (turn == 4) {
      // Turn 4: Mediums auto, Heavies on 4 or less
      arrivals.addAll(mediums);
      arrivals.addAll(_rollForWeightClass(heavies, 4));
    } else if (turn == 5) {
      // Turn 5: Heavies auto
      arrivals.addAll(heavies);
    }

    return arrivals;
  }

  /// Roll dice for a group of regiments in same weight class
  /// Each regiment rolls separately
  List<Regiment> _rollForWeightClass(List<Regiment> regiments, int threshold) {
    final List<Regiment> arrivals = [];

    for (final regiment in regiments) {
      final roll = _random.nextInt(6) + 1; // D6: 1-6
      if (roll <= threshold) {
        arrivals.add(regiment);
      }
    }

    return arrivals;
  }

  /// Get weight class for a regiment (handles character monsters)
  String _getWeightClass(Regiment regiment) {
    // Character monsters use actualRegimentClass
    if (regiment.unit.regimentClass.toLowerCase() == 'character' &&
        regiment.unit.actualRegimentClass != null) {
      return regiment.unit.actualRegimentClass!.toLowerCase();
    }
    
    // Regular regiments use regimentClass
    return regiment.unit.regimentClass.toLowerCase();
  }

  /// Get earliest eligible turn for a weight class
  int _getEarliestEligibleTurn(String weightClass) {
    switch (weightClass) {
      case 'light':
        return 1;
      case 'medium':
        return 2;
      case 'heavy':
        return 3;
      default:
        return 1;
    }
  }

  /// Get priority value for weight class (higher = higher priority)
  int _weightPriority(String weightClass) {
    switch (weightClass) {
      case 'heavy':
        return 3;
      case 'medium':
        return 2;
      case 'light':
        return 1;
      default:
        return 0;
    }
  }

  /// Calculate arrival percentage based on regiment count
  double _calculateArrivalPercentage(Set<Regiment> arrived, int totalRegiments) {
    final regimentsArrived = arrived.length;
    return (regimentsArrived / totalRegiments) * 100.0;
  }

  /// Calculate percentile values across all simulations for each turn
  List<double> _calculatePercentiles(List<List<double>> allSimulations, double percentile) {
    final List<double> percentiles = [];
    
    for (int turn = 0; turn < 5; turn++) {
      // Extract values for this turn from all simulations
      final turnValues = allSimulations.map((sim) => sim[turn]).toList();
      turnValues.sort();
      
      // Calculate percentile index
      final index = (turnValues.length * percentile).floor();
      final clampedIndex = index.clamp(0, turnValues.length - 1);
      percentiles.add(turnValues[clampedIndex]);
    }
    
    return percentiles;
  }
}
