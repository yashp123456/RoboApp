import '../models/block.dart';
import '../models/component.dart';
import '../models/level.dart';

/// The hand-designed campaign. Each level teaches one new concept and (from
/// level 3 on) unlocks a new component when first completed.
const List<GameLevel> kLevels = [
  // ---------------------------------------------------------------- Level 1
  GameLevel(
    number: 1,
    title: 'First Steps',
    concept: 'Movement',
    problem:
        'Drive your robot across the floor to reach the green goal. Use Move '
        'Forward blocks to get there!',
    gridSize: 5,
    startX: 0,
    startY: 2,
    startDir: 1, // facing right
    goalX: 4,
    goalY: 2,
    requiredSlots: [SlotType.wheel],
    allowedBlocks: [BlockType.moveForward],
    coinReward: 10,
    mentorTips: [
      "Hi, I'm Volt! Every robot needs wheels to move. Snap a pair on first.",
      'The goal is 4 squares ahead. How many Move Forward blocks will you need?',
      'Press TEST when your program is ready. If it fails, just try again!',
    ],
  ),

  // ---------------------------------------------------------------- Level 2
  GameLevel(
    number: 2,
    title: 'Around the Corner',
    concept: 'Turning',
    problem:
        'The goal is up and to the right. Mix Move Forward with Turn blocks to '
        'steer your robot around the corner.',
    gridSize: 5,
    startX: 0,
    startY: 4,
    startDir: 0, // facing up
    goalX: 4,
    goalY: 0,
    requiredSlots: [SlotType.wheel],
    allowedBlocks: [
      BlockType.moveForward,
      BlockType.turnLeft,
      BlockType.turnRight,
    ],
    coinReward: 10,
    mentorTips: [
      'Turn blocks rotate your robot without moving it. Turn, THEN drive.',
      'Try: move up to the top, then Turn Right to face the goal.',
      'A Turn Right when facing up makes you face right. Picture it!',
    ],
  ),

  // ---------------------------------------------------------------- Level 3
  GameLevel(
    number: 3,
    title: 'Going the Distance',
    concept: 'Loops',
    problem:
        'A long path! Instead of stacking lots of Move blocks, use a Repeat '
        'block to run the same step many times.',
    gridSize: 6,
    startX: 0,
    startY: 0,
    startDir: 2, // facing down
    goalX: 5,
    goalY: 5,
    requiredSlots: [SlotType.wheel],
    allowedBlocks: [
      BlockType.moveForward,
      BlockType.turnLeft,
      BlockType.turnRight,
      BlockType.repeat,
    ],
    unlocksComponentId: 'sensor_distance',
    coinReward: 15,
    mentorTips: [
      'Repeat blocks save time. Tap the number to change how many times it runs.',
      'Drag a Move Forward INTO the Repeat block to loop it.',
      'Drive down 5, Turn Left, then drive 5 more to reach the goal.',
      'Finish this level to unlock the Distance Sensor!',
    ],
  ),

  // ---------------------------------------------------------------- Level 4
  GameLevel(
    number: 4,
    title: 'Mind the Wall',
    concept: 'Sensors',
    problem:
        'A wall blocks the direct path. Equip a Distance Sensor so your robot '
        'can handle obstacles, then steer around it.',
    gridSize: 5,
    startX: 0,
    startY: 0,
    startDir: 1, // facing right
    goalX: 4,
    goalY: 0,
    walls: {'2,0'},
    requiredSlots: [SlotType.wheel, SlotType.sensor],
    allowedBlocks: [
      BlockType.moveForward,
      BlockType.turnLeft,
      BlockType.turnRight,
      BlockType.repeat,
    ],
    unlocksComponentId: 'tool_gripper',
    coinReward: 20,
    mentorTips: [
      'This level needs a Distance Sensor in the sensor slot. Snap it on!',
      'You cannot drive through walls. Detour down, across, then back up.',
      'Finish this level to unlock the Gripper Arm!',
    ],
  ),

  // ---------------------------------------------------------------- Level 5
  GameLevel(
    number: 5,
    title: 'Pick It Up',
    concept: 'Tools',
    problem:
        'Collect the orange part before reaching the goal. Equip a Gripper Arm '
        'and use the Grab block while standing on the part.',
    gridSize: 5,
    startX: 0,
    startY: 2,
    startDir: 1, // facing right
    goalX: 4,
    goalY: 2,
    items: {'2,2'},
    requiredSlots: [SlotType.wheel, SlotType.tool],
    allowedBlocks: [
      BlockType.moveForward,
      BlockType.turnLeft,
      BlockType.turnRight,
      BlockType.grab,
      BlockType.repeat,
    ],
    coinReward: 25,
    mentorTips: [
      'Equip the Gripper Arm in the tool slot to use Grab blocks.',
      'Drive onto the orange part, Grab it, THEN continue to the goal.',
      'You must collect the part first, or the goal will not count!',
    ],
  ),

  // ---------------------------------------------------------------- Level 6
  GameLevel(
    number: 6,
    title: 'The Full Build',
    concept: 'Engineering Design Cycle',
    problem:
        'Put it all together: wheels, sensor, and gripper. Grab the part, dodge '
        'the wall, and reach the goal. Design, test, improve!',
    gridSize: 6,
    startX: 0,
    startY: 5,
    startDir: 0, // facing up
    goalX: 5,
    goalY: 0,
    walls: {'3,0'},
    items: {'2,0'},
    requiredSlots: [SlotType.wheel, SlotType.sensor, SlotType.tool],
    allowedBlocks: [
      BlockType.moveForward,
      BlockType.turnLeft,
      BlockType.turnRight,
      BlockType.grab,
      BlockType.repeat,
    ],
    coinReward: 30,
    mentorTips: [
      'Equip everything this time: wheels, a sensor, AND a gripper.',
      'Drive up the left side, turn right, grab the part, then weave past the wall.',
      'Stuck? Test, watch where it goes wrong, tweak one block, test again.',
      'This is the engineering design cycle. Real engineers do exactly this!',
    ],
  ),
];

GameLevel levelByNumber(int n) => kLevels.firstWhere((l) => l.number == n);
