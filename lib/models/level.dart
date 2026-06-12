import 'block.dart';
import 'component.dart';

/// What sits in a single grid cell of a level.
enum CellKind { empty, wall, goal, item }

/// A fixed, hand-designed puzzle. The robot starts at [startX]/[startY] facing
/// [startDir] (0=up, 1=right, 2=down, 3=left) and must reach the goal cell.
class GameLevel {
  final int number;
  final String title;
  final String concept;
  final String problem;

  final int gridSize;
  final int startX;
  final int startY;
  final int startDir;
  final int goalX;
  final int goalY;

  /// Walls as "x,y" keys.
  final Set<String> walls;

  /// Items that must be grabbed before reaching the goal, as "x,y" keys.
  final Set<String> items;

  /// Slot types the player must fill on the chassis to be allowed to run.
  final List<SlotType> requiredSlots;

  /// Blocks the player is allowed to use on this level.
  final List<BlockType> allowedBlocks;

  /// Component id unlocked the first time this level is completed (or null).
  final String? unlocksComponentId;

  final int coinReward;
  final List<String> mentorTips;

  const GameLevel({
    required this.number,
    required this.title,
    required this.concept,
    required this.problem,
    required this.gridSize,
    required this.startX,
    required this.startY,
    required this.startDir,
    required this.goalX,
    required this.goalY,
    this.walls = const {},
    this.items = const {},
    required this.requiredSlots,
    required this.allowedBlocks,
    this.unlocksComponentId,
    required this.coinReward,
    required this.mentorTips,
  });

  CellKind cellAt(int x, int y) {
    final key = '$x,$y';
    if (x == goalX && y == goalY) return CellKind.goal;
    if (walls.contains(key)) return CellKind.wall;
    if (items.contains(key)) return CellKind.item;
    return CellKind.empty;
  }
}
