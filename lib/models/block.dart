import 'package:flutter/material.dart';

/// The instruction a block represents when the robot program runs.
enum BlockType {
  moveForward,
  turnLeft,
  turnRight,
  grab,
  repeat,
}

extension BlockTypeInfo on BlockType {
  String get label {
    switch (this) {
      case BlockType.moveForward:
        return 'Move Forward';
      case BlockType.turnLeft:
        return 'Turn Left';
      case BlockType.turnRight:
        return 'Turn Right';
      case BlockType.grab:
        return 'Grab';
      case BlockType.repeat:
        return 'Repeat';
    }
  }

  IconData get icon {
    switch (this) {
      case BlockType.moveForward:
        return Icons.arrow_upward;
      case BlockType.turnLeft:
        return Icons.turn_left;
      case BlockType.turnRight:
        return Icons.turn_right;
      case BlockType.grab:
        return Icons.pan_tool;
      case BlockType.repeat:
        return Icons.repeat;
    }
  }

  Color get color {
    switch (this) {
      case BlockType.moveForward:
        return const Color(0xFF4CAF50);
      case BlockType.turnLeft:
        return const Color(0xFF2196F3);
      case BlockType.turnRight:
        return const Color(0xFF03A9F4);
      case BlockType.grab:
        return const Color(0xFFFF9800);
      case BlockType.repeat:
        return const Color(0xFF9C27B0);
    }
  }
}

/// A single block in the player's program. `repeat` blocks own [children]
/// that run [count] times.
class ProgramBlock {
  final String uid;
  final BlockType type;
  int count; // only used by repeat
  final List<ProgramBlock> children; // only used by repeat

  ProgramBlock({
    required this.uid,
    required this.type,
    this.count = 2,
    List<ProgramBlock>? children,
  }) : children = children ?? [];
}
