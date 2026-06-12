import 'package:flutter_test/flutter_test.dart';
import 'package:robobuilders/data/levels_data.dart';
import 'package:robobuilders/models/block.dart';
import 'package:robobuilders/utils/simulator.dart';

ProgramBlock _b(BlockType t, {int count = 2, List<ProgramBlock>? children}) =>
    ProgramBlock(uid: 'x', type: t, count: count, children: children);

void main() {
  group('Simulator', () {
    test('Level 1 is solved by driving straight to the goal', () {
      final level = levelByNumber(1);
      final program = List.generate(4, (_) => _b(BlockType.moveForward));
      final result = Simulator.run(level, program);
      expect(result.success, isTrue);
    });

    test('Empty program does not win', () {
      final result = Simulator.run(levelByNumber(1), []);
      expect(result.success, isFalse);
    });

    test('Driving into a wall fails the run', () {
      // Level 4 has a wall at 2,0 directly ahead of the start.
      final level = levelByNumber(4);
      final program = List.generate(3, (_) => _b(BlockType.moveForward));
      final result = Simulator.run(level, program);
      expect(result.success, isFalse);
      expect(result.message.toLowerCase(), contains('wall'));
    });

    test('Repeat block expands and reaches the goal on Level 3', () {
      final level = levelByNumber(3);
      // Down 5, turn left to face right, then right 5.
      final program = [
        _b(BlockType.repeat,
            count: 5, children: [_b(BlockType.moveForward)]),
        _b(BlockType.turnLeft),
        _b(BlockType.repeat,
            count: 5, children: [_b(BlockType.moveForward)]),
      ];
      final result = Simulator.run(level, program);
      expect(result.success, isTrue);
    });

    test('Item must be grabbed before the goal counts (Level 5)', () {
      final level = levelByNumber(5);
      // Reach the goal WITHOUT grabbing -> should fail.
      final noGrab = List.generate(4, (_) => _b(BlockType.moveForward));
      expect(Simulator.run(level, noGrab).success, isFalse);

      // Grab on the item cell, then continue -> should succeed.
      final withGrab = [
        _b(BlockType.moveForward),
        _b(BlockType.moveForward),
        _b(BlockType.grab),
        _b(BlockType.moveForward),
        _b(BlockType.moveForward),
      ];
      expect(Simulator.run(level, withGrab).success, isTrue);
    });
  });
}
