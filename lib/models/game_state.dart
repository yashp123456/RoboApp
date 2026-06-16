import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/components_data.dart';
import '../data/levels_data.dart';

/// Holds all player progress and syncs it to Cloud Firestore under the signed-in
/// user's document (`players/{uid}`). A single instance is provided app-wide via
/// Provider. Firestore's built-in offline cache keeps the game playable without a
/// connection and syncs back up when the device reconnects.
class GameState extends ChangeNotifier {
  int coins = 0;
  int highestUnlockedLevel = 1;
  final Set<String> completedLevels = {};
  final Set<String> unlockedComponents = {...kStarterComponents};
  final Set<String> ownedCosmetics = {};
  String? equippedPattern;
  String? equippedAccessory;

  /// The uid whose progress is currently loaded (null = signed out).
  String? _uid;
  String? get uid => _uid;

  bool _loaded = false;
  bool get loaded => _loaded;

  DocumentReference<Map<String, dynamic>>? get _doc => _uid == null
      ? null
      : FirebaseFirestore.instance.collection('players').doc(_uid);

  /// Loads (or initializes) the given user's saved progress from Firestore.
  Future<void> loadForUser(String uid) async {
    _uid = uid;
    _loaded = false;
    notifyListeners();

    final doc = FirebaseFirestore.instance.collection('players').doc(uid);
    final snap = await doc.get();

    if (snap.exists && snap.data() != null) {
      final d = snap.data()!;
      coins = (d['coins'] as num?)?.toInt() ?? 0;
      highestUnlockedLevel = (d['highestUnlockedLevel'] as num?)?.toInt() ?? 1;
      completedLevels
        ..clear()
        ..addAll(_strings(d['completedLevels']));
      unlockedComponents
        ..clear()
        ..addAll(_strings(d['unlockedComponents'], fallback: kStarterComponents));
      ownedCosmetics
        ..clear()
        ..addAll(_strings(d['ownedCosmetics']));
      equippedPattern = d['equippedPattern'] as String?;
      equippedAccessory = d['equippedAccessory'] as String?;
    } else {
      // Brand-new account: start fresh and write the initial document.
      _resetFields();
      await _save();
    }

    _loaded = true;
    notifyListeners();
  }

  /// Clears in-memory state on sign-out so the next user never sees stale data.
  void clear() {
    _uid = null;
    _loaded = false;
    _resetFields();
    notifyListeners();
  }

  List<String> _strings(dynamic value, {Set<String>? fallback}) {
    if (value is List) return value.map((e) => e.toString()).toList();
    return (fallback ?? const <String>{}).toList();
  }

  void _resetFields() {
    coins = 0;
    highestUnlockedLevel = 1;
    completedLevels.clear();
    unlockedComponents
      ..clear()
      ..addAll(kStarterComponents);
    ownedCosmetics.clear();
    equippedPattern = null;
    equippedAccessory = null;
  }

  Future<void> _save() async {
    final doc = _doc;
    if (doc == null) return;
    await doc.set({
      'coins': coins,
      'highestUnlockedLevel': highestUnlockedLevel,
      'completedLevels': completedLevels.toList(),
      'unlockedComponents': unlockedComponents.toList(),
      'ownedCosmetics': ownedCosmetics.toList(),
      'equippedPattern': equippedPattern,
      'equippedAccessory': equippedAccessory,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
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

  /// Wipes all progress for the current account.
  Future<void> resetProgress() async {
    _resetFields();
    await _save();
    notifyListeners();
  }
}
