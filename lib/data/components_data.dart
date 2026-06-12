import 'package:flutter/material.dart';
import '../models/component.dart';

/// Every component in the game. Some start unlocked; others unlock as levels
/// are completed (see GameLevel.unlocksComponentId).
const List<RobotComponent> kAllComponents = [
  RobotComponent(
    id: 'chassis_basic',
    name: 'Base Chassis',
    description: 'The body that holds everything together.',
    slot: SlotType.chassis,
    icon: Icons.crop_square,
    color: Color(0xFF607D8B),
  ),
  RobotComponent(
    id: 'wheels_standard',
    name: 'Standard Wheels',
    description: 'Let your robot roll forward and turn.',
    slot: SlotType.wheel,
    icon: Icons.settings,
    color: Color(0xFF455A64),
  ),
  RobotComponent(
    id: 'sensor_distance',
    name: 'Distance Sensor',
    description: 'Detects walls and obstacles ahead.',
    slot: SlotType.sensor,
    icon: Icons.sensors,
    color: Color(0xFF00BCD4),
  ),
  RobotComponent(
    id: 'tool_gripper',
    name: 'Gripper Arm',
    description: 'Picks up items the robot drives over.',
    slot: SlotType.tool,
    icon: Icons.pan_tool,
    color: Color(0xFFFF9800),
  ),
];

RobotComponent componentById(String id) =>
    kAllComponents.firstWhere((c) => c.id == id);

List<RobotComponent> componentsForSlot(SlotType slot) =>
    kAllComponents.where((c) => c.slot == slot).toList();

/// Component ids that are available from the very first level.
const Set<String> kStarterComponents = {
  'chassis_basic',
  'wheels_standard',
};
