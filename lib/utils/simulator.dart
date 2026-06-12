import '../models/block.dart';
import '../models/level.dart';

/// A single snapshot of the robot during a run, used to animate the test.
class RobotFrame {
  final int x;
  final int y;
  final int dir;
  final Set<String> collected;
  final String? note;

  const RobotFrame({
    required this.x,
    required this.y,
    required this.dir,
    required this.collected,
    this.note,
  });
}

class SimulationResult {
  final bool success;
  final String message;
  final List<RobotFrame> frames;

  const SimulationResult({
    required this.success,
    required this.message,
    required this.frames,
  });
}

/// Runs the player's [program] against [level] and returns the outcome plus an
/// animation timeline. Pure logic — no Flutter dependencies.
class Simulator {
  static const int maxSteps = 400;

  static SimulationResult run(GameLevel level, List<ProgramBlock> program) {
    int x = level.startX;
    int y = level.startY;
    int dir = level.startDir;
    final collected = <String>{};

    final frames = <RobotFrame>[
      RobotFrame(x: x, y: y, dir: dir, collected: {...collected}),
    ];

    // Flatten the (possibly nested) program into primitive instructions.
    final primitives = <BlockType>[];
    void flatten(List<ProgramBlock> blocks) {
      for (final b in blocks) {
        if (primitives.length > maxSteps) return;
        if (b.type == BlockType.repeat) {
          final times = b.count.clamp(0, 50);
          for (var i = 0; i < times; i++) {
            flatten(b.children);
            if (primitives.length > maxSteps) return;
          }
        } else {
          primitives.add(b.type);
        }
      }
    }

    flatten(program);

    if (primitives.isEmpty) {
      return SimulationResult(
        success: false,
        message: 'Your program is empty. Add some blocks and try again!',
        frames: frames,
      );
    }

    bool crashed = false;
    String? crashNote;

    for (final p in primitives) {
      switch (p) {
        case BlockType.turnLeft:
          dir = (dir + 3) % 4;
          frames.add(RobotFrame(x: x, y: y, dir: dir, collected: {...collected}));
          break;
        case BlockType.turnRight:
          dir = (dir + 1) % 4;
          frames.add(RobotFrame(x: x, y: y, dir: dir, collected: {...collected}));
          break;
        case BlockType.grab:
          final key = '$x,$y';
          String? note;
          if (level.items.contains(key) && !collected.contains(key)) {
            collected.add(key);
            note = 'Grabbed a part!';
          }
          frames.add(RobotFrame(
              x: x, y: y, dir: dir, collected: {...collected}, note: note));
          break;
        case BlockType.moveForward:
          final nx = x + _delta(dir).$1;
          final ny = y + _delta(dir).$2;
          final outOfBounds =
              nx < 0 || ny < 0 || nx >= level.gridSize || ny >= level.gridSize;
          final hitsWall = level.walls.contains('$nx,$ny');
          if (outOfBounds || hitsWall) {
            crashed = true;
            crashNote = outOfBounds
                ? 'Oops! The robot drove off the edge.'
                : 'Bonk! The robot hit a wall.';
            frames.add(RobotFrame(
                x: x, y: y, dir: dir, collected: {...collected}, note: crashNote));
          } else {
            x = nx;
            y = ny;
            frames.add(
                RobotFrame(x: x, y: y, dir: dir, collected: {...collected}));
          }
          break;
        case BlockType.repeat:
          break; // already flattened
      }
      if (crashed) break;
    }

    final reachedGoal = x == level.goalX && y == level.goalY;
    final gotAllItems = collected.length == level.items.length;

    if (crashed) {
      return SimulationResult(
          success: false, message: crashNote!, frames: frames);
    }
    if (reachedGoal && gotAllItems) {
      return SimulationResult(
        success: true,
        message: 'Level complete! Great engineering!',
        frames: frames,
      );
    }
    if (reachedGoal && !gotAllItems) {
      return SimulationResult(
        success: false,
        message: 'You reached the goal but forgot to grab a part!',
        frames: frames,
      );
    }
    return SimulationResult(
      success: false,
      message: 'Not quite at the goal yet. Adjust your blocks and retest.',
      frames: frames,
    );
  }

  /// Returns the (dx, dy) for a direction. 0=up,1=right,2=down,3=left.
  static (int, int) _delta(int dir) {
    switch (dir) {
      case 0:
        return (0, -1);
      case 1:
        return (1, 0);
      case 2:
        return (0, 1);
      default:
        return (-1, 0);
    }
  }
}
