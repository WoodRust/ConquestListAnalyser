import '../models/army_list.dart';
import '../models/regiment.dart';
import '../models/warband.dart';

/// Service for managing warbands and applying Forward Force special rule
class WarbandManager {
  /// Infer warbands from an army list based on parse order
  /// Regular characters (not character monsters) start warbands
  /// Following non-character regiments join that warband until next regular character
  /// Regiments appearing before any character are added to the first character's warband
  static List<Warband> inferWarbands(ArmyList armyList) {
    final List<Warband> warbands = [];
    Regiment? currentCharacter;
    List<Regiment> currentRegiments = [];
    List<Regiment> orphanedRegiments = []; // Regiments before first character

    for (final regiment in armyList.regiments) {
      final isRegularCharacter = regiment.unit.regimentClass.toLowerCase() == 'character' &&
          regiment.unit.type.toLowerCase() != 'monster';

      if (isRegularCharacter) {
        // Save previous warband if exists
        if (currentCharacter != null) {
          warbands.add(Warband(
            character: currentCharacter,
            regiments: List.from(currentRegiments),
          ));
        }

        // Start new warband
        currentCharacter = regiment;
        currentRegiments = [];
        
        // Add any orphaned regiments to first character's warband
        if (orphanedRegiments.isNotEmpty) {
          currentRegiments.addAll(orphanedRegiments);
          orphanedRegiments = [];
        }
      } else if (currentCharacter != null) {
        // Add non-character regiment to current warband
        // This includes regular regiments and character monsters
        currentRegiments.add(regiment);
      } else {
        // No character yet - store as orphaned
        orphanedRegiments.add(regiment);
      }
    }

    // Add final warband if exists
    if (currentCharacter != null) {
      warbands.add(Warband(
        character: currentCharacter,
        regiments: List.from(currentRegiments),
      ));
    }

    return warbands;
  }

  /// Apply Forward Force special rule to warbands
  /// Returns a map of Regiment -> hasComputedFlank
  /// For each character with Forward Force, grant Flank to the heaviest
  /// non-monster regiment in their warband that doesn't already have Flank
  static Map<Regiment, bool> applyForwardForce(List<Warband> warbands) {
    final Map<Regiment, bool> computedFlank = {};

    for (final warband in warbands) {
      if (!warband.hasForwardForce) {
        continue;
      }

      // Find eligible regiments: non-monsters without Flank
      final eligibleRegiments = warband.regiments.where((regiment) {
        final isMonster = regiment.unit.type.toLowerCase() == 'monster';
        final hasFlank = regiment.unit.specialRules
            .any((rule) => rule.name.toLowerCase() == 'flank');
        return !isMonster && !hasFlank;
      }).toList();

      if (eligibleRegiments.isEmpty) {
        continue;
      }

      // Prioritize by weight class: Heavy > Medium > Light (ignore points)
      Regiment? selectedRegiment;
      
      // Try Heavy first
      for (final regiment in eligibleRegiments) {
        if (regiment.unit.regimentClass.toLowerCase() == 'heavy') {
          selectedRegiment = regiment;
          break;
        }
      }

      // Try Medium if no Heavy found
      if (selectedRegiment == null) {
        for (final regiment in eligibleRegiments) {
          if (regiment.unit.regimentClass.toLowerCase() == 'medium') {
            selectedRegiment = regiment;
            break;
          }
        }
      }

      // Try Light if no Medium found
      if (selectedRegiment == null) {
        for (final regiment in eligibleRegiments) {
          if (regiment.unit.regimentClass.toLowerCase() == 'light') {
            selectedRegiment = regiment;
            break;
          }
        }
      }

      // Grant Flank to selected regiment
      if (selectedRegiment != null) {
        computedFlank[selectedRegiment] = true;
      }
    }

    return computedFlank;
  }

  /// Check if a regiment has Flank (either from special rule or Forward Force)
  static bool hasFlank(Regiment regiment, Map<Regiment, bool> computedFlank) {
    // Check direct Flank special rule
    final hasDirectFlank = regiment.unit.specialRules
        .any((rule) => rule.name.toLowerCase() == 'flank');
    
    // Check computed Flank from Forward Force
    final hasComputedFlank = computedFlank[regiment] ?? false;
    
    return hasDirectFlank || hasComputedFlank;
  }

  /// Get the regiment that a character is connected to within their warband
  /// Returns null if character has no warband or no eligible regiments
  /// Priority: Heavy > Medium > Light (monsters are excluded from connection)
  static Regiment? getConnectedRegiment(
      Regiment character, List<Regiment> warbandRegiments) {
    // Filter out monsters (characters can't connect to monsters)
    final eligibleRegiments = warbandRegiments
        .where((r) => r.unit.type.toLowerCase() != 'monster')
        .toList();

    if (eligibleRegiments.isEmpty) return null;

    // Priority: Heavy > Medium > Light
    for (final regiment in eligibleRegiments) {
      if (regiment.unit.regimentClass.toLowerCase() == 'heavy') {
        return regiment;
      }
    }

    for (final regiment in eligibleRegiments) {
      if (regiment.unit.regimentClass.toLowerCase() == 'medium') {
        return regiment;
      }
    }

    for (final regiment in eligibleRegiments) {
      if (regiment.unit.regimentClass.toLowerCase() == 'light') {
        return regiment;
      }
    }

    return null;
  }
}
