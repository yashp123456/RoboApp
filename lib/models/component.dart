import 'package:flutter/material.dart';

/// The kind of slot a component can be mounted into.
enum SlotType { chassis, wheel, sensor, tool }

extension SlotTypeLabel on SlotType {
  String get label {
    switch (this) {
      case SlotType.chassis:
        return 'Chassis';
      case SlotType.wheel:
        return 'Wheels';
      case SlotType.sensor:
        return 'Sensor';
      case SlotType.tool:
        return 'Tool';
    }
  }
}

/// A buildable robot part the player can drag onto the chassis.
class RobotComponent {
  final String id;
  final String name;
  final String description;
  final SlotType slot;
  final IconData icon;
  final Color color;

  const RobotComponent({
    required this.id,
    required this.name,
    required this.description,
    required this.slot,
    required this.icon,
    required this.color,
  });
}
