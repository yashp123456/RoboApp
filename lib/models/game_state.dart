import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/components_data.dart';
import '../data/levels_data.dart';

/// Holds all player progress and persists it to the device. A single instance
/// is provided to the whole app via Provider.
class GameState extends ChangeNotifier {
  int coins = 0;
  int highestUnlockedLevel = 1;
  final Set<String> completedLevels = {};
  final Set<String> unlockedComponents = {...kStarterComponents};
  final Set<String> ownedCosmetics = {};
  String? equippedPattern;
  String? equippedAccessory;

  bool _loaded = false;
  bool get loaded => _loaded;

  SharedPreferences? _prefs;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final p = _prefs!;
    coins = p.getInt('coins') ?? 0;
    highestUnlockedLevel = p.getInt('highestUnlockedLevel') ?? 1;
    completedLevels
      ..clear()
      ..addAll(p.getStringList('completedLevels') ?? const []);
    unlockedComponents
      ..clear()
      ..addAll(p.getStringList('unlockedComponents') ?? kStarterComponents.toList());
    ownedCosmetics
      ..clear()
      ..addAll(p.getStringList('ownedCosmetics') ?? const []);
    equippedPattern = p.getString('equippedPattern');
    equippedAccessory = p.getString('equippedAccessory');
    _loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final p = _prefs;
    if (p == null) return;
    await p.setInt('coins', coins);
    await p.setInt('highestUnlockedLevel', highestUnlockedLevel);
    await p.setStringList('completedLevels', completedLevels.toList());
    await p.setStringList('unlockedComponents', unlockedComponents.toList());
    await p.setStringList('ownedCosmetics', ownedCosmetics.toList());
    if (equippedPattern != null) {
      await p.setString('equippedPattern', equippedPattern!);
    } else {
      await p.remove('equippedPattern');
    }
    if (equippedAccessory != null) {
      await p.setString('equippedAccessory', equippedAccessory!);
    } else {
      await p.remove('equippedAccessory');
    }
  }

  bool isLevelUnlocked(int number) => number <= highestUnlockedLevel;
  bool isLevelCompleted(int number) => completedLevels.contains('$number');
  bool isComponentUnlocked(String id) => unlockedComponents.contains(id);
  bool ownsCosmetic(String id) => ownedCosmetics.contains(id);

  /// Records a level win: awards coins (first time only), unlocks the reward
  /// component and the next level. Returns the coins earned this run.
  int completeLevel(int number) {
    final level = levelByNumber(number);
    final firstTime = !isLevelCompleted(number);
    completedLevels.add('$number');

    if (number + 1 <= kLevels.length && number + 1 > highestUnlockedLevel) {
      highestUnlockedLevel = number + 1;
    }
    final unlockId = level.unlocksComponentId;
    if (unlockId != null) {
      unlockedComponents.add(unlockId);
    }

    var earned = 0;
    if (firstTime) {
      earned = level.coinReward;
      coins += earned;
    }
    _save();
    notifyListeners();
    return earned;
  }

  bool buyCosmetic(String id, int price) {
    if (ownsCosmetic(id) || coins < price) return false;
    coins -= price;
    ownedCosmetics.add(id);
    _save();
    notifyListeners();
    return true;
  }

  void equipPattern(String? id) {
    equippedPattern = id;
    _save();
    notifyListeners();
  }

  void equipAccessory(String? id) {
    equippedAccessory = id;
    _save();
    notifyListeners();
  }

  /// Wipes all progress. Used by the "reset" button in Settings.
  Future<void> resetProgress() async {
    coins = 0;
    highestUnlockedLevel = 1;
    completedLevels.clear();
    unlockedComponents
      ..clear()
      ..addAll(kStarterComponents);
    ownedCosmetics.clear();
    equippedPattern = null;
    equippedAccessory = null;
    await _save();
    notifyListeners();
  }
}
