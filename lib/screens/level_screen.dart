import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/components_data.dart';
import '../data/levels_data.dart';
import '../models/block.dart';
import '../models/component.dart';
import '../models/game_state.dart';
import '../models/level.dart';
import '../theme/app_theme.dart';
import '../utils/simulator.dart';
import '../widgets/mentor_bubble.dart';
import '../widgets/robot_view.dart';

/// The heart of the game: a three-stage flow (Design -> Code -> Test) for a
/// single level. All transient build state lives here.
class LevelScreen extends StatefulWidget {
  final int levelNumber;
  const LevelScreen({super.key, required this.levelNumber});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  late final GameLevel level = levelByNumber(widget.levelNumber);

  int _stage = 0; // 0 design, 1 code, 2 test
  final Map<SlotType, RobotComponent?> _equipped = {
    SlotType.chassis: null,
    SlotType.wheel: null,
    SlotType.sensor: null,
    SlotType.tool: null,
  };
  final List<ProgramBlock> _program = [];
  int _uidCounter = 0;

  // Test/animation state.
  SimulationResult? _result;
  List<RobotFrame> _frames = const [];
  int _frameIndex = 0;
  Timer? _timer;
  bool _running = false;
  String? _mentorReaction;

  @override
  void initState() {
    super.initState();
    // Pre-mount a chassis so kids always have a body to start from.
    _equipped[SlotType.chassis] = componentById('chassis_basic');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _newUid() => 'b${_uidCounter++}';

  bool get _requiredSlotsFilled =>
      level.requiredSlots.every((s) => _equipped[s] != null);

  // ------------------------------------------------------------------ build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lv ${level.number}: ${level.title}'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _stageHeader(),
            Expanded(child: _stageBody()),
            _bottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _stageHeader() {
    final labels = ['Design', 'Code', 'Test'];
    return Container(
      color: AppTheme.primary.withOpacity(0.08),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(labels.length, (i) {
          final active = i == _stage;
          final done = i < _stage;
          return Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: active || done
                    ? AppTheme.primary
                    : Colors.grey.shade400,
                child: done
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : Text('${i + 1}',
                        style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 6),
              Text(labels[i],
                  style: TextStyle(
                    fontWeight: active ? FontWeight.bold : FontWeight.normal,
                    color: active ? AppTheme.primary : Colors.black54,
                  )),
              if (i < labels.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.chevron_right, color: Colors.grey),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _stageBody() {
    switch (_stage) {
      case 0:
        return _designStage();
      case 1:
        return _codingStage();
      default:
        return _testStage();
    }
  }

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          if (_stage > 0)
            OutlinedButton.icon(
              onPressed: () => setState(() => _stage--),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
            ),
          const Spacer(),
          if (_stage < 2)
            ElevatedButton.icon(
              onPressed: _canAdvance() ? () => setState(() => _stage++) : null,
              icon: const Icon(Icons.arrow_forward),
              label: Text(_stage == 0 ? 'To Coding' : 'To Test'),
            ),
        ],
      ),
    );
  }

  bool _canAdvance() {
    if (_stage == 0) return _requiredSlotsFilled;
    if (_stage == 1) return _program.isNotEmpty;
    return false;
  }

  // ---------------------------------------------------------------- DESIGN
  Widget _designStage() {
    // Which slots this level lets the player work with.
    final slots = <SlotType>[SlotType.wheel];
    if (game.isComponentUnlocked('sensor_distance')) slots.add(SlotType.sensor);
    if (game.isComponentUnlocked('tool_gripper')) slots.add(SlotType.tool);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MentorBubble(tips: ['Step 1: Build your robot.', ...level.mentorTips]),
          const SizedBox(height: 12),
          _problemCard(),
          const SizedBox(height: 12),
          Center(
            child: RobotView(
              equipped: _equipped,
              patternId: game.equippedPattern,
              accessoryId: game.equippedAccessory,
              size: 150,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            level.requiredSlots
                .map((s) => 'Needs: ${s.label}')
                .join('   •   '),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          const Text('Mount points',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: slots.map(_slotTarget).toList(),
          ),
          const SizedBox(height: 20),
          const Text('Parts box  (drag a part onto its mount)',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: kAllComponents
                .where((c) =>
                    c.slot != SlotType.chassis &&
                    game.isComponentUnlocked(c.id))
                .map(_draggablePart)
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _slotTarget(SlotType slot) {
    final current = _equipped[slot];
    final required = level.requiredSlots.contains(slot);
    return DragTarget<RobotComponent>(
      onWillAcceptWithDetails: (d) => d.data.slot == slot,
      onAcceptWithDetails: (d) =>
          setState(() => _equipped[slot] = d.data),
      builder: (context, candidate, rejected) {
        final highlight = candidate.isNotEmpty;
        return Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: highlight
                ? AppTheme.accent.withOpacity(0.2)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: current != null
                  ? Colors.green
                  : (required ? AppTheme.accent : Colors.grey),
              width: 2.5,
            ),
          ),
          child: current == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.grey.shade500),
                    Text(slot.label,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                  ],
                )
              : Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(current.icon, color: current.color, size: 30),
                          const SizedBox(height: 4),
                          Text(slot.label,
                              style: const TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () =>
                            setState(() => _equipped[slot] = null),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _draggablePart(RobotComponent c) {
    final chip = _partChip(c);
    return Draggable<RobotComponent>(
      data: c,
      feedback: Material(color: Colors.transparent, child: _partChip(c, drag: true)),
      childWhenDragging: Opacity(opacity: 0.4, child: chip),
      child: chip,
    );
  }

  Widget _partChip(RobotComponent c, {bool drag = false}) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.color, width: 2),
        boxShadow: drag
            ? const [BoxShadow(color: Colors.black26, blurRadius: 8)]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(c.icon, color: c.color, size: 28),
          const SizedBox(height: 4),
          Text(c.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold)),
          Text(c.description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _problemCard() {
    return Card(
      color: AppTheme.primary.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag, color: AppTheme.accent),
                const SizedBox(width: 6),
                Text('Concept: ${level.concept}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary)),
              ],
            ),
            const SizedBox(height: 6),
            Text(level.problem, style: const TextStyle(height: 1.3)),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- CODING
  Widget _codingStage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: MentorBubble(
              tips: ['Step 2: Program your robot with blocks.', ...level.mentorTips]),
        ),
        Expanded(
          child: _program.isEmpty
              ? const Center(
                  child: Text(
                    'Tap a block below to add it to your program.',
                    style: TextStyle(color: Colors.black45),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _program.length,
                  itemBuilder: (context, i) =>
                      _programBlockTile(_program[i], i),
                ),
        ),
        _blockPalette(),
      ],
    );
  }

  Widget _programBlockTile(ProgramBlock b, int index) {
    if (b.type == BlockType.repeat) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: BlockType.repeat.color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: BlockType.repeat.color, width: 2),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 8),
                Icon(BlockType.repeat.icon, color: BlockType.repeat.color),
                const SizedBox(width: 6),
                const Text('Repeat',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: b.count > 1
                      ? () => setState(() => b.count--)
                      : null,
                ),
                Text('${b.count}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: b.count < 20
                      ? () => setState(() => b.count++)
                      : null,
                ),
                const Text('times'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => setState(() => _program.removeAt(index)),
                ),
              ],
            ),
            // Nested children.
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 12, bottom: 8),
              child: Column(
                children: [
                  ...b.children.asMap().entries.map((e) => _childTile(b, e.key)),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add step inside'),
                      onPressed: () => _addInsideRepeat(b),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Simple block.
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: b.type.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: b.type.color, width: 2),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(b.type.icon, color: b.type.color),
        title: Text(b.type.label,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => setState(() => _program.removeAt(index)),
        ),
      ),
    );
  }

  Widget _childTile(ProgramBlock parent, int childIndex) {
    final c = parent.children[childIndex];
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: c.type.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.type.color, width: 1.5),
      ),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        leading: Icon(c.type.icon, color: c.type.color, size: 20),
        title: Text(c.type.label),
        trailing: IconButton(
          icon: const Icon(Icons.close, color: Colors.red, size: 20),
          onPressed: () =>
              setState(() => parent.children.removeAt(childIndex)),
        ),
      ),
    );
  }

  void _addInsideRepeat(ProgramBlock repeat) {
    final options = level.allowedBlocks
        .where((t) => t != BlockType.repeat)
        .toList();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: options
              .map((t) => ListTile(
                    leading: Icon(t.icon, color: t.color),
                    title: Text(t.label),
                    onTap: () {
                      setState(() => repeat.children
                          .add(ProgramBlock(uid: _newUid(), type: t)));
                      Navigator.pop(ctx);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _blockPalette() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Block box  (tap to add)',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: level.allowedBlocks.map((t) {
              return ActionChip(
                avatar: Icon(t.icon, color: Colors.white, size: 20),
                label: Text(t.label,
                    style: const TextStyle(color: Colors.white)),
                backgroundColor: t.color,
                onPressed: () => setState(() => _program
                    .add(ProgramBlock(uid: _newUid(), type: t))),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ TEST
  Widget _testStage() {
    final frame = _frames.isEmpty
        ? RobotFrame(
            x: level.startX,
            y: level.startY,
            dir: level.startDir,
            collected: const {})
        : _frames[_frameIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          MentorBubble(
            tips: ['Step 3: Test it! If it fails, go back and improve.'],
            override: _mentorReaction,
          ),
          const SizedBox(height: 14),
          Center(
            child: _GridBoard(
              level: level,
              frame: frame,
              robotColor: game.equippedPattern == null
                  ? AppTheme.primary
                  : _patternColor(game.equippedPattern!),
            ),
          ),
          const SizedBox(height: 14),
          if (_result != null && !_running)
            Text(
              _result!.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _result!.success ? Colors.green : Colors.red,
              ),
            ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, minimumSize: const Size(200, 52)),
            onPressed: _running ? null : _runProgram,
            icon: const Icon(Icons.play_circle_fill, size: 28),
            label: Text(_running ? 'Running...' : 'TEST ROBOT'),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => setState(() => _stage = 1),
            icon: const Icon(Icons.edit),
            label: const Text('Edit my program'),
          ),
        ],
      ),
    );
  }

  Color _patternColor(String id) {
    // Lazy lookup without importing shop data list here twice.
    switch (id) {
      case 'pattern_blue':
        return const Color(0xFF2196F3);
      case 'pattern_red':
        return const Color(0xFFF44336);
      case 'pattern_green':
        return const Color(0xFF4CAF50);
      case 'pattern_purple':
        return const Color(0xFF9C27B0);
      default:
        return AppTheme.primary;
    }
  }

  void _runProgram() {
    // Validate the build supports the program's actions.
    final usesGrab = _programUses(BlockType.grab);
    if (usesGrab && _equipped[SlotType.tool] == null) {
      setState(() => _mentorReaction =
          'Your program uses Grab, but there is no Gripper Arm equipped. Go back to Design!');
      return;
    }
    if (!_requiredSlotsFilled) {
      setState(() => _mentorReaction =
          'Your robot is missing a required part. Check the Design step.');
      return;
    }

    final result = Simulator.run(level, _program);
    _timer?.cancel();
    setState(() {
      _result = result;
      _frames = result.frames;
      _frameIndex = 0;
      _running = true;
      _mentorReaction = 'Watch closely...';
    });

    _timer = Timer.periodic(const Duration(milliseconds: 400), (t) {
      if (_frameIndex >= _frames.length - 1) {
        t.cancel();
        setState(() {
          _running = false;
          _mentorReaction = result.success
              ? 'You did it! 🎉'
              : '${result.message}  Go back, tweak a block, and retest!';
        });
        if (result.success) _onWin();
      } else {
        setState(() => _frameIndex++);
      }
    });
  }

  bool _programUses(BlockType type) {
    bool scan(List<ProgramBlock> blocks) {
      for (final b in blocks) {
        if (b.type == type) return true;
        if (b.type == BlockType.repeat && scan(b.children)) return true;
      }
      return false;
    }

    return scan(_program);
  }

  void _onWin() {
    final earned = game.completeLevel(level.number);
    final unlockId = level.unlocksComponentId;
    final hasNext = level.number < kLevels.length;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Column(
          children: [
            Icon(Icons.emoji_events, color: AppTheme.coin, size: 56),
            SizedBox(height: 8),
            Text('Level Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (earned > 0)
              Text('You earned $earned coins!',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold))
            else
              const Text('Replayed — no new coins this time.'),
            if (unlockId != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_open, color: Colors.green),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'New part unlocked: ${componentById(unlockId).name}!',
                        style:
                            const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // back to level select
            },
            child: const Text('Levels'),
          ),
          if (hasNext)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        LevelScreen(levelNumber: level.number + 1),
                  ),
                );
              },
              child: const Text('Next Level'),
            ),
        ],
      ),
    );
  }

  // Read (not watch): this screen rebuilds via its own setState, and GameState
  // changes here happen in event handlers where watch() is illegal.
  GameState get game => context.read<GameState>();
}

/// Renders the level's grid and the robot at a given animation frame.
class _GridBoard extends StatelessWidget {
  final GameLevel level;
  final RobotFrame frame;
  final Color robotColor;

  const _GridBoard({
    required this.level,
    required this.frame,
    required this.robotColor,
  });

  @override
  Widget build(BuildContext context) {
    const board = 300.0;
    final cell = board / level.gridSize;

    final cells = <Widget>[];
    for (var y = 0; y < level.gridSize; y++) {
      for (var x = 0; x < level.gridSize; x++) {
        final kind = level.cellAt(x, y);
        final collected = frame.collected.contains('$x,$y');
        cells.add(Positioned(
          left: x * cell,
          top: y * cell,
          width: cell,
          height: cell,
          child: Container(
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: _cellColor(kind, collected),
              borderRadius: BorderRadius.circular(4),
            ),
            child: _cellIcon(kind, collected, cell),
          ),
        ));
      }
    }

    return Container(
      width: board,
      height: board,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200, width: 2),
      ),
      child: Stack(
        children: [
          ...cells,
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: frame.x * cell,
            top: frame.y * cell,
            width: cell,
            height: cell,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Transform.rotate(
                angle: frame.dir * 1.5708, // 90° per direction
                child: Container(
                  decoration: BoxDecoration(
                    color: robotColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.black54, width: 2),
                  ),
                  child: const Icon(Icons.navigation,
                      color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _cellColor(CellKind kind, bool collected) {
    switch (kind) {
      case CellKind.wall:
        return Colors.brown.shade400;
      case CellKind.goal:
        return Colors.green.shade300;
      case CellKind.item:
        return collected ? Colors.grey.shade200 : Colors.orange.shade100;
      case CellKind.empty:
        return Colors.white;
    }
  }

  Widget? _cellIcon(CellKind kind, bool collected, double cell) {
    switch (kind) {
      case CellKind.goal:
        return Icon(Icons.flag, color: Colors.green.shade800, size: cell * 0.5);
      case CellKind.item:
        return collected
            ? null
            : Icon(Icons.widgets,
                color: Colors.orange.shade700, size: cell * 0.5);
      case CellKind.wall:
        return Icon(Icons.block, color: Colors.brown.shade800, size: cell * 0.4);
      case CellKind.empty:
        return null;
    }
  }
}
