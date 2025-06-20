import '../models/unit.dart';

/// Abstract interface for unit database operations
abstract class UnitDatabaseInterface {
  Future<void> loadData();
  Unit? findUnit(String unitName);
  List<Unit> getUnitsForFaction(String faction);
  List<String> get availableFactions;
  bool get isLoaded;
}
